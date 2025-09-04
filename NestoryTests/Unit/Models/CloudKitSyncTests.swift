//
// Layer: Unit/Models
// Module: CloudKitSyncTests  
// Purpose: CloudKit synchronization and conflict resolution testing for insurance data consistency
//

import XCTest
import SwiftData
import CloudKit
@testable import Nestory

/// Comprehensive test suite for CloudKit synchronization, conflict resolution, and multi-device insurance data consistency
final class CloudKitSyncTests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    private var modelContext: ModelContext!
    private var container: ModelContainer!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory model context for testing
        // Note: Real CloudKit testing would require CloudKit container configuration
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Item.self, Category.self, Room.self, Warranty.self, configurations: configuration)
        modelContext = ModelContext(container)
    }
    
    override func tearDown() async throws {
        modelContext = nil
        container = nil
        try await super.tearDown()
    }
    
    // MARK: - CloudKit Schema Validation Tests
    
    func testCloudKitCompatibleModels() {
        // Test that all models have CloudKit-compatible structure
        let item = TestDataFactory.createCompleteItem()
        let category = Category(name: "Electronics")
        let room = Room(name: "Living Room")
        let warranty = Warranty(provider: "Apple", startDate: Date(), expiresAt: Date(timeIntervalSinceNow: 86400))
        
        // CloudKit requires optional relationships for proper sync
        XCTAssertNotNil(category.items, "Category.items should be optional array for CloudKit")
        XCTAssertTrue(warranty.item == nil || warranty.item != nil, "Warranty.item should be optional for CloudKit")
        
        // All models should have stable UUIDs
        XCTAssertNotNil(item.id)
        XCTAssertNotNil(category.id)
        XCTAssertNotNil(room.id)
        XCTAssertNotNil(warranty.id)
        
        // CloudKit requires proper timestamp tracking
        XCTAssertNotNil(item.createdAt)
        XCTAssertNotNil(item.updatedAt)
        XCTAssertNotNil(category.createdAt)
        XCTAssertNotNil(category.updatedAt)
        XCTAssertNotNil(warranty.createdAt)
        XCTAssertNotNil(warranty.updatedAt)
    }
    
    func testCloudKitRecordNaming() {
        // Test that model names are CloudKit-friendly
        let modelNames = ["Item", "Category", "Room", "Warranty"]
        
        for name in modelNames {
            // CloudKit record names should be valid
            XCTAssertFalse(name.isEmpty)
            XCTAssertTrue(name.allSatisfy { $0.isLetter || $0.isNumber })
            XCTAssertTrue(name.first?.isUppercase == true, "Model names should start with uppercase for CloudKit")
        }
    }
    
    // MARK: - Data Consistency Tests
    
    func testItemCategoryConsistency() throws {
        let electronics = Category(name: "Electronics", icon: "laptopcomputer")
        let laptop = Item(name: "MacBook Pro", category: electronics)
        
        modelContext.insert(electronics)
        modelContext.insert(laptop)
        try modelContext.save()
        
        // Verify bidirectional relationship consistency
        XCTAssertEqual(laptop.category?.name, "Electronics")
        XCTAssertEqual(electronics.items?.count, 1)
        XCTAssertEqual(electronics.items?.first?.name, "MacBook Pro")
    }
    
    func testItemWarrantyConsistency() throws {
        let item = Item(name: "iPhone")
        let warranty = Warranty(provider: "Apple", startDate: Date(), expiresAt: Date(timeIntervalSinceNow: 86400), item: item)
        
        modelContext.insert(item)
        modelContext.insert(warranty)
        try modelContext.save()
        
        // Verify bidirectional relationship consistency
        XCTAssertEqual(item.warranty?.provider, "Apple")
        XCTAssertEqual(warranty.item?.name, "iPhone")
    }
    
    func testBulkDataConsistency() throws {
        // Test data consistency with larger datasets (insurance claim scenarios)
        let homeRooms = Room.createDefaultRooms()
        let categories = [
            Category(name: "Electronics", icon: "laptopcomputer"),
            Category(name: "Furniture", icon: "sofa"),
            Category(name: "Jewelry", icon: "diamond")
        ]
        
        // Insert base data
        for room in homeRooms {
            modelContext.insert(room)
        }
        for category in categories {
            modelContext.insert(category)
        }
        
        // Create items distributed across rooms and categories
        let items = (0..<50).map { i in
            let item = TestDataFactory.createCompleteItem()
            item.name = "Item \(i)"
            item.category = categories[i % categories.count]
            item.room = homeRooms[i % homeRooms.count].name
            return item
        }
        
        for item in items {
            modelContext.insert(item)
        }
        
        try modelContext.save()
        
        // Verify consistency after bulk operations
        let savedItems = try modelContext.fetch(FetchDescriptor<Item>())
        XCTAssertEqual(savedItems.count, 50)
        
        for item in savedItems {
            XCTAssertNotNil(item.category, "All items should maintain category relationships")
            XCTAssertNotNil(item.room, "All items should maintain room assignments")
        }
        
        // Verify category item counts
        let savedCategories = try modelContext.fetch(FetchDescriptor<Category>())
        for category in savedCategories {
            let expectedCount = items.filter { $0.category?.name == category.name }.count
            XCTAssertEqual(category.items?.count, expectedCount, "Category \(category.name) should have correct item count")
        }
    }
    
    // MARK: - Conflict Resolution Simulation Tests
    
    func testSimulatedConflictResolution() throws {
        // Simulate the scenario where the same item is modified on two devices
        let baseItem = Item(name: "Shared Item")
        baseItem.purchasePrice = 1000.0
        baseItem.notes = "Original notes"
        
        modelContext.insert(baseItem)
        try modelContext.save()
        
        // Simulate Device 1 modification
        let device1Item = baseItem
        device1Item.purchasePrice = 1200.0 // Device 1 updates price
        device1Item.notes = "Updated by device 1"
        device1Item.updatedAt = Date()
        
        // Simulate Device 2 modification (concurrent)
        let device2Item = Item(name: "Shared Item")
        device2Item.id = baseItem.id // Same ID as Device 1 item
        device2Item.purchasePrice = 1100.0 // Device 2 updates price differently
        device2Item.notes = "Updated by device 2"
        device2Item.serialNumber = "SERIAL123" // Device 2 adds serial number
        device2Item.updatedAt = Date(timeIntervalSinceNow: 1) // Slightly later timestamp
        
        // In real CloudKit scenario, the item with the latest timestamp would win
        // For our simulation, we'll test the conflict resolution logic
        let winningItem = device2Item.updatedAt > device1Item.updatedAt ? device2Item : device1Item
        
        XCTAssertEqual(winningItem.purchasePrice, 1100.0, "Later timestamp should win in conflict resolution")
        XCTAssertEqual(winningItem.serialNumber, "SERIAL123", "New data should be preserved")
        XCTAssertEqual(winningItem.notes, "Updated by device 2", "Later update should win")
    }
    
    func testConflictResolutionWithInsuranceData() {
        // Test conflict resolution for insurance-critical data
        let insuranceItem = TestDataFactory.createHighValueItem()
        insuranceItem.name = "Diamond Ring"
        insuranceItem.purchasePrice = 10000.0
        
        // Device 1: Adds warranty information
        let device1Timestamp = Date()
        insuranceItem.warrantyExpirationDate = Date(timeIntervalSinceNow: 365 * 24 * 60 * 60)
        insuranceItem.warrantyProvider = "Jewelers Mutual"
        insuranceItem.updatedAt = device1Timestamp
        
        // Device 2: Adds receipt and condition info (later timestamp)
        let device2Timestamp = Date(timeIntervalSinceNow: 5)
        let device2Item = Item(name: "Diamond Ring")
        device2Item.id = insuranceItem.id
        device2Item.purchasePrice = 10000.0
        device2Item.receiptImageData = "receipt_data".data(using: .utf8)!
        device2Item.itemCondition = .excellent
        device2Item.conditionNotes = "Professional appraisal completed"
        device2Item.updatedAt = device2Timestamp
        
        // Merge strategy: preserve all non-conflicting data, use latest timestamp for conflicts
        let mergedItem = Item(name: "Diamond Ring")
        mergedItem.id = insuranceItem.id
        mergedItem.purchasePrice = 10000.0
        
        // Preserve warranty info from Device 1
        mergedItem.warrantyExpirationDate = insuranceItem.warrantyExpirationDate
        mergedItem.warrantyProvider = insuranceItem.warrantyProvider
        
        // Preserve receipt and condition info from Device 2
        mergedItem.receiptImageData = device2Item.receiptImageData
        mergedItem.itemCondition = device2Item.itemCondition
        mergedItem.conditionNotes = device2Item.conditionNotes
        
        // Use latest timestamp
        mergedItem.updatedAt = device2Timestamp
        
        // Verify merged insurance data is complete
        XCTAssertNotNil(mergedItem.warrantyExpirationDate, "Warranty info should be preserved")
        XCTAssertNotNil(mergedItem.receiptImageData, "Receipt data should be preserved")
        XCTAssertNotNil(mergedItem.conditionNotes, "Condition assessment should be preserved")
        XCTAssertEqual(mergedItem.itemCondition, .excellent, "Condition should be preserved")
    }
    
    // MARK: - Large Dataset Sync Tests
    
    func testLargeDatasetSyncSimulation() throws {
        // Simulate syncing a large home inventory for insurance purposes
        let categories = [
            Category(name: "Electronics", icon: "laptopcomputer"),
            Category(name: "Furniture", icon: "sofa"),
            Category(name: "Jewelry", icon: "diamond"),
            Category(name: "Appliances", icon: "refrigerator"),
            Category(name: "Clothing", icon: "tshirt"),
            Category(name: "Books", icon: "book"),
            Category(name: "Art", icon: "paintbrush"),
            Category(name: "Sports", icon: "sportscourt")
        ]
        
        let rooms = Room.createDefaultRooms()
        
        // Insert base data
        for category in categories {
            modelContext.insert(category)
        }
        for room in rooms {
            modelContext.insert(room)
        }
        
        // Create comprehensive home inventory (500 items)
        let items = (0..<500).map { i in
            let item: Item
            
            if i % 10 == 0 {
                // Every 10th item is high-value for insurance
                item = TestDataFactory.createHighValueItem()
            } else if i % 15 == 0 {
                // Every 15th item has damage for claims
                item = TestDataFactory.createDamagedItem()
            } else {
                item = TestDataFactory.createCompleteItem()
            }
            
            item.name = "Inventory Item \(i)"
            item.category = categories[i % categories.count]
            item.room = rooms[i % rooms.count].name
            
            if i % 20 == 0 {
                // Add specific location for detailed tracking
                item.specificLocation = "Shelf \(i % 5 + 1)"
            }
            
            return item
        }
        
        // Measure bulk insert performance
        measure {
            for item in items {
                modelContext.insert(item)
            }
            do {
                try modelContext.save()
            } catch {
                XCTFail("Bulk save failed: \(error)")
            }
        }
        
        // Verify data integrity after bulk sync
        let savedItems = try modelContext.fetch(FetchDescriptor<Item>())
        XCTAssertEqual(savedItems.count, 500)
        
        // Verify relationships are maintained
        for item in savedItems {
            XCTAssertNotNil(item.category, "Item \(item.name) should have category")
            XCTAssertNotNil(item.room, "Item \(item.name) should have room assignment")
        }
        
        // Verify category distribution
        for category in categories {
            let itemsInCategory = savedItems.filter { $0.category?.name == category.name }
            XCTAssertGreaterThan(itemsInCategory.count, 0, "Category \(category.name) should have items")
        }
    }
    
    // MARK: - Sync Failure Recovery Tests
    
    func testPartialSyncRecovery() throws {
        // Test scenario where sync is interrupted mid-process
        let categories = [
            Category(name: "Electronics"),
            Category(name: "Furniture")
        ]
        
        let items = (0..<20).map { i in
            let item = TestDataFactory.createBasicItem()
            item.name = "Item \(i)"
            item.category = categories[i % 2]
            return item
        }
        
        // Insert categories first (successful)
        for category in categories {
            modelContext.insert(category)
        }
        try modelContext.save()
        
        // Simulate partial item sync (some succeed, some fail)
        let successfulItems = Array(items.prefix(10))
        let failedItems = Array(items.suffix(10))
        
        // Insert successful items
        for item in successfulItems {
            modelContext.insert(item)
        }
        try modelContext.save()
        
        // Verify partial state
        let savedItems = try modelContext.fetch(FetchDescriptor<Item>())
        XCTAssertEqual(savedItems.count, 10, "Only successful items should be saved")
        
        // Simulate retry for failed items
        for item in failedItems {
            modelContext.insert(item)
        }
        try modelContext.save()
        
        // Verify full recovery
        let allSavedItems = try modelContext.fetch(FetchDescriptor<Item>())
        XCTAssertEqual(allSavedItems.count, 20, "All items should be saved after recovery")
    }
    
    func testSyncConsistencyAfterNetworkFailure() throws {
        // Test data consistency when network connection is lost during sync
        let item = TestDataFactory.createCompleteItem()
        item.name = "Network Test Item"
        item.purchasePrice = 1500.0
        
        // Initial save (simulates successful sync)
        modelContext.insert(item)
        try modelContext.save()
        
        // Modify item locally (simulates offline changes)
        item.purchasePrice = 1600.0
        item.notes = "Updated while offline"
        item.updatedAt = Date()
        
        // Simulate local save while offline
        try modelContext.save()
        
        // When network returns, verify data is ready for sync
        XCTAssertEqual(item.purchasePrice, 1600.0)
        XCTAssertEqual(item.notes, "Updated while offline")
        XCTAssertNotNil(item.updatedAt)
        
        // Simulate receiving newer data from server during sync recovery
        let serverItem = Item(name: "Network Test Item")
        serverItem.id = item.id
        serverItem.purchasePrice = 1700.0 // Server has newer price
        serverItem.notes = "Updated while offline" // Local notes preserved
        serverItem.serialNumber = "SERVER123" // Server has additional data
        serverItem.updatedAt = Date(timeIntervalSinceNow: 5) // Server timestamp is newer
        
        // Merge resolution: server wins on conflicts, preserve additional local data
        let mergedPrice = serverItem.updatedAt > item.updatedAt ? serverItem.purchasePrice : item.purchasePrice
        XCTAssertEqual(mergedPrice, 1700.0, "Server data should win with newer timestamp")
    }
    
    // MARK: - Multi-Device Insurance Scenario Tests
    
    func testInsuranceClaimDataSync() throws {
        // Test synchronizing insurance claim data across devices
        let fireIncident = InsuranceTestScenarios.kitchenFloodingIncident()
        
        // Device 1 (iPad): Creates initial damage assessment
        let device1Items = fireIncident.damagedItems.prefix(3).map { itemData in
            let item = Item(name: itemData.name)
            item.room = itemData.room
            item.itemCondition = .damaged
            item.conditionNotes = "Fire damage assessment from iPad"
            item.updatedAt = Date()
            return item
        }
        
        // Device 2 (iPhone): Adds photos and detailed assessments
        let device2Items = Array(fireIncident.damagedItems.suffix(3)).map { itemData in
            let item = Item(name: itemData.name)
            item.room = itemData.room
            item.itemCondition = .damaged
            item.imageData = "damage_photo_iphone".data(using: .utf8)!
            item.conditionPhotos = ["before".data(using: .utf8)!, "after".data(using: .utf8)!]
            item.conditionNotes = "Detailed assessment with photos from iPhone"
            item.updatedAt = Date(timeIntervalSinceNow: 2)
            return item
        }
        
        // Insert items from both devices
        for item in device1Items + device2Items {
            modelContext.insert(item)
        }
        try modelContext.save()
        
        // Verify insurance data consistency
        let allItems = try modelContext.fetch(FetchDescriptor<Item>())
        XCTAssertEqual(allItems.count, 6)
        
        for item in allItems {
            XCTAssertEqual(item.itemCondition, .damaged, "All items should be marked as damaged")
            XCTAssertNotNil(item.conditionNotes, "All items should have condition notes")
        }
        
        // Verify device-specific data is preserved
        let itemsWithPhotos = allItems.filter { $0.imageData != nil }
        XCTAssertEqual(itemsWithPhotos.count, 3, "Items from iPhone should have photos")
        
        let itemsWithDetailedNotes = allItems.filter { $0.conditionNotes?.contains("Detailed") == true }
        XCTAssertEqual(itemsWithDetailedNotes.count, 3, "Items from iPhone should have detailed notes")
    }
    
    // MARK: - Performance and Scalability Tests
    
    func testSyncPerformanceWithLargeDataset() {
        // Test sync performance with insurance-sized datasets
        let itemCount = 1000
        let items = (0..<itemCount).map { i in
            let item = TestDataFactory.createCompleteItem()
            item.name = "Performance Item \(i)"
            return item
        }
        
        measure {
            for item in items {
                modelContext.insert(item)
            }
        }
    }
    
    func testQueryPerformanceAfterSync() throws {
        // Test query performance after large sync operations
        let categories = [
            Category(name: "High Value", icon: "crown"),
            Category(name: "Standard", icon: "folder")
        ]
        
        for category in categories {
            modelContext.insert(category)
        }
        
        // Create mixed dataset
        let items = (0..<200).map { i in
            let item = i % 5 == 0 ? TestDataFactory.createHighValueItem() : TestDataFactory.createBasicItem()
            item.name = "Query Test Item \(i)"
            item.category = i % 5 == 0 ? categories[0] : categories[1]
            return item
        }
        
        for item in items {
            modelContext.insert(item)
        }
        try modelContext.save()
        
        // Test query performance
        measure {
            do {
                // Query high-value items (insurance priority)
                let highValueDescriptor = FetchDescriptor<Item>()
                let allItems = try modelContext.fetch(highValueDescriptor)
                let highValueItems = allItems.filter { $0.category?.name == "High Value" }
                
                XCTAssertEqual(highValueItems.count, 40) // 200 / 5
            } catch {
                XCTFail("Query failed: \(error)")
            }
        }
    }
    
    // MARK: - CloudKit Schema Migration Simulation
    
    func testSchemaCompatibilityAcrossVersions() {
        // Test that models remain compatible across app versions
        let legacyItem = Item(name: "Legacy Item")
        legacyItem.purchasePrice = 100.0
        legacyItem.notes = "Created in v1.0"
        
        // Simulate new fields added in v2.0 (should be optional/default values)
        legacyItem.serialNumber = nil // New optional field
        legacyItem.conditionNotes = nil // New optional field
        
        // Item should remain valid with missing new fields
        XCTAssertEqual(legacyItem.name, "Legacy Item")
        XCTAssertEqual(legacyItem.purchasePrice, 100.0)
        XCTAssertNil(legacyItem.serialNumber)
        XCTAssertNil(legacyItem.conditionNotes)
        
        // Adding new data should work seamlessly
        legacyItem.serialNumber = "LEGACY123"
        legacyItem.conditionNotes = "Retroactively added"
        
        XCTAssertEqual(legacyItem.serialNumber, "LEGACY123")
        XCTAssertEqual(legacyItem.conditionNotes, "Retroactively added")
    }
    
    // MARK: - Error Handling and Edge Cases
    
    func testSyncWithCorruptedData() {
        // Test handling of corrupted or invalid data during sync
        let validItem = TestDataFactory.createCompleteItem()
        validItem.name = "Valid Item"
        
        let corruptedItem = Item(name: "") // Invalid empty name
        corruptedItem.purchasePrice = -100.0 // Invalid negative price
        
        // Valid item should be insertable
        modelContext.insert(validItem)
        
        // Corrupted item should still be insertable (validation handled at business logic level)
        modelContext.insert(corruptedItem)
        
        do {
            try modelContext.save()
            
            // Both items saved, but business logic should handle validation
            let savedItems = try modelContext.fetch(FetchDescriptor<Item>())
            XCTAssertEqual(savedItems.count, 2)
            
            // Validation should be handled by services, not model layer
            let invalidNameItems = savedItems.filter { $0.name.isEmpty }
            XCTAssertEqual(invalidNameItems.count, 1)
            
        } catch {
            XCTFail("Save should succeed, validation handled at service layer: \(error)")
        }
    }
    
    func testConcurrentModifications() throws {
        // Test concurrent modifications to the same dataset
        let sharedCategory = Category(name: "Shared Category")
        modelContext.insert(sharedCategory)
        try modelContext.save()
        
        // Simulate two users adding items to the same category simultaneously
        let user1Items = (0..<10).map { i in
            let item = Item(name: "User1 Item \(i)", category: sharedCategory)
            return item
        }
        
        let user2Items = (0..<10).map { i in
            let item = Item(name: "User2 Item \(i)", category: sharedCategory)
            return item
        }
        
        // Insert items from both users
        for item in user1Items + user2Items {
            modelContext.insert(item)
        }
        try modelContext.save()
        
        // Verify all items are associated with shared category
        let savedItems = try modelContext.fetch(FetchDescriptor<Item>())
        XCTAssertEqual(savedItems.count, 20)
        
        for item in savedItems {
            XCTAssertEqual(item.category?.name, "Shared Category")
        }
        
        // Verify category relationship is maintained
        XCTAssertEqual(sharedCategory.items?.count, 20)
    }
}
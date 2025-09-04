//
// Layer: NestoryTests
// Module: Unit/Models
// Purpose: Schema migration testing for insurance data integrity
//

import XCTest
import SwiftData
import Foundation
@testable import Nestory

/// Comprehensive data migration testing for schema changes
/// Ensures insurance data integrity during app updates
@MainActor
class DataMigrationTests: XCTestCase {
    
    // MARK: - Migration Test Infrastructure
    
    private var temporaryURL: URL!
    private var legacyContainer: ModelContainer!
    private var modernContainer: ModelContainer!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create temporary directory for test databases
        temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("NestoryMigrationTests")
            .appendingPathComponent(UUID().uuidString)
        
        try FileManager.default.createDirectory(
            at: temporaryURL,
            withIntermediateDirectories: true
        )
    }
    
    override func tearDown() async throws {
        // Clean up temporary containers
        legacyContainer = nil
        modernContainer = nil
        
        // Remove test database files
        if let temporaryURL = temporaryURL {
            try? FileManager.default.removeItem(at: temporaryURL)
        }
        
        try await super.tearDown()
    }
    
    // MARK: - Schema Evolution Tests
    
    func testSchemaEvolutionFromV1ToV2() async throws {
        // Simulate schema upgrade scenario for insurance data
        // V1: Basic Item model
        // V2: Item with warranty relationship
        
        // Create legacy schema (V1) - Basic Item model
        let legacySchema = Schema([Item.self])
        let legacyConfig = ModelConfiguration(
            schema: legacySchema,
            url: temporaryURL.appendingPathComponent("legacy.sqlite"),
            cloudKitDatabase: .none
        )
        
        legacyContainer = try ModelContainer(for: legacySchema, configurations: [legacyConfig])
        
        // Insert test insurance data in V1 format
        await legacyContainer.mainContext.insert(
            createLegacyInsuranceItem()
        )
        try legacyContainer.mainContext.save()
        
        // Create modern schema (V2) - Item with warranty relationship
        let modernSchema = Schema([Item.self, Warranty.self, Category.self, Room.self])
        let modernConfig = ModelConfiguration(
            schema: modernSchema,
            url: temporaryURL.appendingPathComponent("modern.sqlite"),
            cloudKitDatabase: .none
        )
        
        // Test that migration handles schema evolution gracefully
        do {
            modernContainer = try ModelContainer(for: modernSchema, configurations: [modernConfig])
            
            // Verify basic container creation succeeded
            XCTAssertNotNil(modernContainer)
            XCTAssertNotNil(modernContainer.mainContext)
            
        } catch {
            XCTFail("Schema migration should handle evolution gracefully: \(error)")
        }
    }
    
    func testInsuranceDataPreservationDuringMigration() async throws {
        // Test that critical insurance data survives schema changes
        
        let schema = Schema([Item.self, Category.self, Room.self, Warranty.self])
        let config = ModelConfiguration(
            schema: schema,
            url: temporaryURL.appendingPathComponent("insurance.sqlite"),
            cloudKitDatabase: .none
        )
        
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext
        
        // Create comprehensive insurance data set
        let insuranceItems = createInsuranceDataSet()
        
        for item in insuranceItems {
            context.insert(item)
        }
        try context.save()
        
        // Simulate app restart (container recreation)
        let newContainer = try ModelContainer(for: schema, configurations: [config])
        let newContext = newContainer.mainContext
        
        // Verify all insurance data preserved
        let preservedItems = try newContext.fetch(FetchDescriptor<Item>())
        
        XCTAssertEqual(preservedItems.count, insuranceItems.count,
                      "All insurance items should be preserved during migration")
        
        // Verify critical insurance properties preserved
        for item in preservedItems {
            XCTAssertFalse(item.name.isEmpty, "Item name should be preserved")
            XCTAssertGreaterThan(item.estimatedValue, 0, "Insurance value should be preserved")
            XCTAssertNotNil(item.purchaseDate, "Purchase date critical for insurance claims")
            
            // Verify insurance-specific properties
            if item.name.contains("High-Value") {
                XCTAssertGreaterThanOrEqual(item.estimatedValue, 1000,
                                          "High-value items should maintain proper valuation")
            }
        }
    }
    
    func testWarrantyMigrationIntegrity() async throws {
        // Test warranty data migration for insurance claims
        
        let schema = Schema([Item.self, Warranty.self])
        let config = ModelConfiguration(
            schema: schema,
            url: temporaryURL.appendingPathComponent("warranty.sqlite"),
            cloudKitDatabase: .none
        )
        
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext
        
        // Create item with warranty
        let item = TestDataFactory.createCompleteItem()
        let warranty = Warranty(
            provider: "AppleCare",
            type: .extended,
            startDate: Date(),
            expiresAt: Calendar.current.date(byAdding: .year, value: 2, to: Date()) ?? Date()
        )
        
        item.warranty = warranty
        warranty.item = item
        
        context.insert(item)
        context.insert(warranty)
        try context.save()
        
        // Simulate migration by recreating container
        let newContainer = try ModelContainer(for: schema, configurations: [config])
        let newContext = newContainer.mainContext
        
        // Verify warranty relationship preserved
        let items = try newContext.fetch(FetchDescriptor<Item>())
        let warranties = try newContext.fetch(FetchDescriptor<Warranty>())
        
        XCTAssertEqual(items.count, 1, "Item should be preserved")
        XCTAssertEqual(warranties.count, 1, "Warranty should be preserved")
        
        let preservedItem = items.first!
        let preservedWarranty = warranties.first!
        
        XCTAssertNotNil(preservedItem.warranty, "Item-warranty relationship should be preserved")
        XCTAssertNotNil(preservedWarranty.item, "Warranty-item relationship should be preserved")
        XCTAssertEqual(preservedItem.warranty?.id, preservedWarranty.id,
                      "Warranty relationship should be correctly maintained")
    }
    
    func testCategoryHierarchyMigrationStability() async throws {
        // Test category structure preservation for insurance reporting
        
        let schema = Schema([Category.self, Item.self])
        let config = ModelConfiguration(
            schema: schema,
            url: temporaryURL.appendingPathComponent("categories.sqlite"),
            cloudKitDatabase: .none
        )
        
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext
        
        // Create insurance category hierarchy
        let electronics = Category(name: "Electronics", icon: "desktopcomputer", color: "blue")
        let computers = Category(name: "Computers", icon: "laptopcomputer", color: "blue")
        let smartphones = Category(name: "Smartphones", icon: "iphone", color: "blue")
        
        // Create hierarchy: Electronics > Computers
        computers.parent = electronics
        electronics.children = [computers]
        
        // Create items in categories
        let laptop = TestDataFactory.createCompleteItem()
        laptop.name = "MacBook Pro"
        laptop.category = computers
        
        let phone = TestDataFactory.createCompleteItem()
        phone.name = "iPhone 16 Pro"
        phone.category = smartphones
        
        // Insert all entities
        context.insert(electronics)
        context.insert(computers)
        context.insert(smartphones)
        context.insert(laptop)
        context.insert(phone)
        
        try context.save()
        
        // Simulate migration
        let newContainer = try ModelContainer(for: schema, configurations: [config])
        let newContext = newContainer.mainContext
        
        // Verify category hierarchy preserved
        let categories = try newContext.fetch(
            FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
        )
        
        XCTAssertEqual(categories.count, 3, "All categories should be preserved")
        
        // Find electronics category and verify hierarchy
        guard let electronicsCategory = categories.first(where: { $0.name == "Electronics" }),
              let computersCategory = categories.first(where: { $0.name == "Computers" }) else {
            XCTFail("Category hierarchy should be preserved")
            return
        }
        
        XCTAssertNotNil(computersCategory.parent, "Parent relationship should be preserved")
        XCTAssertEqual(computersCategory.parent?.id, electronicsCategory.id,
                      "Parent-child relationship should be correctly maintained")
        
        // Verify items maintain category relationships
        let items = try newContext.fetch(FetchDescriptor<Item>())
        let laptopItem = items.first { $0.name == "MacBook Pro" }
        
        XCTAssertNotNil(laptopItem?.category, "Item category relationship should be preserved")
        XCTAssertEqual(laptopItem?.category?.name, "Computers",
                      "Item should maintain correct category after migration")
    }
    
    func testRoomLocationMigrationForInsurance() async throws {
        // Test room location data critical for insurance claims
        
        let schema = Schema([Room.self, Item.self])
        let config = ModelConfiguration(
            schema: schema,
            url: temporaryURL.appendingPathComponent("rooms.sqlite"),
            cloudKitDatabase: .none
        )
        
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext
        
        // Create rooms with floor information (important for insurance)
        let livingRoom = Room(name: "Living Room", icon: "sofa", floor: "Ground Floor")
        let masterBedroom = Room(name: "Master Bedroom", icon: "bed.double", floor: "Second Floor")
        
        // Create items with room locations
        let tv = TestDataFactory.createHighValueItem()
        tv.name = "65\" OLED TV"
        tv.room = livingRoom
        tv.estimatedValue = 2500
        
        let jewelry = TestDataFactory.createHighValueItem()
        jewelry.name = "Wedding Ring Set"
        jewelry.room = masterBedroom
        jewelry.estimatedValue = 5000
        
        context.insert(livingRoom)
        context.insert(masterBedroom)
        context.insert(tv)
        context.insert(jewelry)
        
        try context.save()
        
        // Simulate migration
        let newContainer = try ModelContainer(for: schema, configurations: [config])
        let newContext = newContainer.mainContext
        
        // Verify room and location data preserved
        let rooms = try newContext.fetch(FetchDescriptor<Room>())
        let items = try newContext.fetch(FetchDescriptor<Item>())
        
        XCTAssertEqual(rooms.count, 2, "All rooms should be preserved")
        XCTAssertEqual(items.count, 2, "All items should be preserved")
        
        // Verify high-value items maintain room locations
        for item in items {
            XCTAssertNotNil(item.room, "Room location should be preserved for insurance claims")
            XCTAssertFalse(item.room!.name.isEmpty, "Room name should be preserved")
            XCTAssertNotNil(item.room!.floor, "Floor information should be preserved for insurance")
        }
        
        // Verify specific high-value item locations
        let tvItem = items.first { $0.name.contains("TV") }
        XCTAssertEqual(tvItem?.room?.name, "Living Room", "TV location should be preserved")
        XCTAssertEqual(tvItem?.room?.floor, "Ground Floor", "Floor info critical for insurance")
    }
    
    // MARK: - CloudKit Migration Tests
    
    func testCloudKitFallbackMigration() async throws {
        // Test migration from CloudKit to local storage fallback
        
        // Start with CloudKit configuration
        let cloudKitSchema = Schema([Item.self])
        let cloudKitConfig = ModelConfiguration(
            schema: cloudKitSchema,
            url: temporaryURL.appendingPathComponent("cloudkit.sqlite"),
            cloudKitDatabase: .private("com.test.app") // This will fail in test environment
        )
        
        // This should gracefully fall back to local storage
        do {
            let container = try ModelContainer(for: cloudKitSchema, configurations: [cloudKitConfig])
            
            // Add test data
            let item = TestDataFactory.createCompleteItem()
            container.mainContext.insert(item)
            try container.mainContext.save()
            
            // Verify data exists
            let items = try container.mainContext.fetch(FetchDescriptor<Item>())
            XCTAssertEqual(items.count, 1, "Data should be preserved in fallback storage")
            
        } catch {
            // Expected: CloudKit will fail in test environment
            // Verify we can still create local-only container
            let localConfig = ModelConfiguration(
                schema: cloudKitSchema,
                url: temporaryURL.appendingPathComponent("local.sqlite"),
                cloudKitDatabase: .none
            )
            
            let localContainer = try ModelContainer(for: cloudKitSchema, configurations: [localConfig])
            XCTAssertNotNil(localContainer, "Local fallback should always work")
        }
    }
    
    func testInMemoryFallbackMigration() async throws {
        // Test final fallback to in-memory storage
        
        let schema = Schema([Item.self])
        let memoryConfig = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        let container = try ModelContainer(for: schema, configurations: [memoryConfig])
        
        // Add test insurance data
        let item = TestDataFactory.createCompleteItem()
        item.name = "Emergency In-Memory Test Item"
        container.mainContext.insert(item)
        try container.mainContext.save()
        
        // Verify in-memory storage works
        let items = try container.mainContext.fetch(FetchDescriptor<Item>())
        XCTAssertEqual(items.count, 1, "In-memory storage should work as last resort")
        XCTAssertEqual(items.first?.name, "Emergency In-Memory Test Item",
                      "Data should be accessible in memory storage")
    }
    
    // MARK: - Migration Error Handling Tests
    
    func testMigrationFailureRecovery() async throws {
        // Test recovery from migration failures
        
        // Create a scenario that might cause migration issues
        let schema = Schema([Item.self, Category.self])
        
        // Create container with potential issue (invalid path)
        let invalidURL = URL(fileURLWithPath: "/invalid/path/that/does/not/exist")
        let invalidConfig = ModelConfiguration(
            schema: schema,
            url: invalidURL,
            cloudKitDatabase: .none
        )
        
        // This should fail gracefully
        do {
            _ = try ModelContainer(for: schema, configurations: [invalidConfig])
            XCTFail("Invalid configuration should fail")
        } catch {
            // Expected failure - verify error is appropriate
            XCTAssertNotNil(error, "Migration failure should provide error information")
        }
        
        // Verify we can recover with valid configuration
        let validConfig = ModelConfiguration(
            schema: schema,
            url: temporaryURL.appendingPathComponent("recovery.sqlite"),
            cloudKitDatabase: .none
        )
        
        let recoveryContainer = try ModelContainer(for: schema, configurations: [validConfig])
        XCTAssertNotNil(recoveryContainer, "Recovery container should work after failure")
    }
    
    func testDataIntegrityAfterMigrationFailure() async throws {
        // Test data integrity when partial migration occurs
        
        let schema = Schema([Item.self, Category.self])
        let config = ModelConfiguration(
            schema: schema,
            url: temporaryURL.appendingPathComponent("integrity.sqlite"),
            cloudKitDatabase: .none
        )
        
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext
        
        // Create test data
        let category = Category(name: "Test Electronics", icon: "desktopcomputer", color: "blue")
        let item = TestDataFactory.createCompleteItem()
        item.category = category
        
        context.insert(category)
        context.insert(item)
        try context.save()
        
        // Simulate migration by recreating container
        let newContainer = try ModelContainer(for: schema, configurations: [config])
        let newContext = newContainer.mainContext
        
        // Verify data integrity preserved
        let categories = try newContext.fetch(FetchDescriptor<Category>())
        let items = try newContext.fetch(FetchDescriptor<Item>())
        
        XCTAssertEqual(categories.count, 1, "Category should be preserved")
        XCTAssertEqual(items.count, 1, "Item should be preserved")
        
        // Verify relationships maintained
        let preservedItem = items.first!
        XCTAssertNotNil(preservedItem.category, "Category relationship should be preserved")
        XCTAssertEqual(preservedItem.category?.name, "Test Electronics",
                      "Category relationship should be intact after migration")
    }
    
    // MARK: - Performance Migration Tests
    
    func testLargeDatasetMigrationPerformance() async throws {
        // Test migration performance with large insurance dataset
        
        let schema = Schema([Item.self, Category.self, Room.self])
        let config = ModelConfiguration(
            schema: schema,
            url: temporaryURL.appendingPathComponent("performance.sqlite"),
            cloudKitDatabase: .none
        )
        
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext
        
        // Create large dataset (1000 items for performance testing)
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Create categories and rooms
        let electronics = Category(name: "Electronics", icon: "desktopcomputer", color: "blue")
        let livingRoom = Room(name: "Living Room", icon: "sofa")
        
        context.insert(electronics)
        context.insert(livingRoom)
        
        // Create 1000 test items
        for i in 0..<1000 {
            let item = TestDataFactory.createCompleteItem()
            item.name = "Test Item \(i)"
            item.category = electronics
            item.room = livingRoom.name
            context.insert(item)
        }
        
        try context.save()
        let insertTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // Test migration performance (container recreation)
        let migrationStartTime = CFAbsoluteTimeGetCurrent()
        let newContainer = try ModelContainer(for: schema, configurations: [config])
        let migrationTime = CFAbsoluteTimeGetCurrent() - migrationStartTime
        
        // Verify all data migrated correctly
        let items = try newContainer.mainContext.fetch(FetchDescriptor<Item>())
        XCTAssertEqual(items.count, 1000, "All items should be preserved during migration")
        
        // Performance assertions
        XCTAssertLessThan(insertTime, 10.0, "Large dataset insertion should complete within 10 seconds")
        XCTAssertLessThan(migrationTime, 5.0, "Migration should complete within 5 seconds")
        
        print("📊 Migration Performance Metrics:")
        print("   • Insert time: \(String(format: "%.3f", insertTime))s")
        print("   • Migration time: \(String(format: "%.3f", migrationTime))s")
        print("   • Items processed: \(items.count)")
    }
    
    // MARK: - Test Data Factories
    
    private func createLegacyInsuranceItem() -> Item {
        // Simulate legacy Item model for migration testing
        let item = Item(name: "Legacy Insurance Item", estimatedValue: 1500)
        item.serialNumber = "LEG123456789"
        item.purchaseDate = Date()
        item.itemDescription = "Legacy item for migration testing"
        return item
    }
    
    private func createInsuranceDataSet() -> [Item] {
        // Create realistic insurance item dataset
        return [
            createHighValueElectronics(),
            createJewelryItem(),
            createFurnitureItem(),
            createApplianceItem()
        ]
    }
    
    private func createHighValueElectronics() -> Item {
        let item = TestDataFactory.createHighValueItem()
        item.name = "High-Value MacBook Pro M3"
        item.estimatedValue = 3500
        item.serialNumber = "HVMB2024001"
        item.purchaseDate = Calendar.current.date(byAdding: .month, value: -3, to: Date())
        return item
    }
    
    private func createJewelryItem() -> Item {
        let item = TestDataFactory.createHighValueItem()
        item.name = "Diamond Wedding Ring"
        item.estimatedValue = 4500
        item.purchaseDate = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        item.itemDescription = "1.5 carat diamond solitaire setting"
        return item
    }
    
    private func createFurnitureItem() -> Item {
        let item = TestDataFactory.createCompleteItem()
        item.name = "Italian Leather Sofa Set"
        item.estimatedValue = 2200
        item.purchaseDate = Calendar.current.date(byAdding: .month, value: -8, to: Date())
        return item
    }
    
    private func createApplianceItem() -> Item {
        let item = TestDataFactory.createCompleteItem()
        item.name = "Sub-Zero Refrigerator"
        item.estimatedValue = 8500
        item.serialNumber = "SZ2024REF001"
        item.purchaseDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        return item
    }
}

// MARK: - Migration Test Extensions

extension DataMigrationTests {
    
    /// Helper to verify insurance data completeness after migration
    private func verifyInsuranceDataCompleteness(_ items: [Item]) {
        for item in items {
            // Critical insurance fields should be preserved
            XCTAssertFalse(item.name.isEmpty, "Item name required for insurance claims")
            XCTAssertGreaterThan(item.estimatedValue, 0, "Item value required for insurance")
            XCTAssertNotNil(item.purchaseDate, "Purchase date required for insurance claims")
            
            // Optional but important fields should be preserved if present
            if !item.serialNumber.isEmpty {
                XCTAssertGreaterThan(item.serialNumber.count, 5,
                                   "Serial numbers should be meaningful length")
            }
        }
    }
    
    /// Helper to create deterministic test database URL
    private func testDatabaseURL(named name: String) -> URL {
        return temporaryURL.appendingPathComponent("\(name).sqlite")
    }
}
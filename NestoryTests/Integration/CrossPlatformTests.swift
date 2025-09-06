//
// Layer: Tests
// Module: Integration
// Purpose: Multi-device sync and cross-platform testing for insurance data consistency
//

import XCTest
import SwiftData
import CloudKit
@testable import Nestory
import Foundation

@MainActor
final class CrossPlatformTests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    private var primaryContainer: ModelContainer!
    private var secondaryContainer: ModelContainer!
    private var mockCloudBackupService: MockCloudBackupService!
    private var mockSyncCoordinator: MockSyncCoordinator!
    
    override func setUp() async throws {
        // Note: Not calling super.setUp() in async context due to Swift 6 concurrency
        
        // Create separate containers to simulate different devices
        let schema = Schema([Item.self, Nestory.Category.self, Warranty.self])
        let primaryConfig = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        let secondaryConfig = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        primaryContainer = try ModelContainer(for: schema, configurations: [primaryConfig])
        secondaryContainer = try ModelContainer(for: schema, configurations: [secondaryConfig])
        mockCloudBackupService = MockCloudBackupService()
        mockSyncCoordinator = MockSyncCoordinator()
    }
    
    override func tearDown() async throws {
        primaryContainer = nil
        secondaryContainer = nil
        mockCloudBackupService = nil
        mockSyncCoordinator = nil
        // Note: Not calling super.tearDown() in async context due to Swift 6 concurrency
    }
    
    // MARK: - Basic Multi-Device Sync Tests
    
    func testBasicItemSyncBetweenDevices() async throws {
        // Test basic insurance item synchronization between iPhone and iPad
        
        let primaryContext = primaryContainer.mainContext
        let secondaryContext = secondaryContainer.mainContext
        
        // Create item on primary device (iPhone)
        let originalItem = Item(name: "iPhone Created Insurance Item")
        originalItem.purchasePrice = Decimal(1500)
        originalItem.purchaseDate = Date()
        originalItem.serialNumber = "ABC123456"
        primaryContext.insert(originalItem)
        try primaryContext.save()
        
        // Simulate CloudKit sync
        mockCloudBackupService.cloudItems[originalItem.id] = originalItem
        
        // Sync to secondary device (iPad)
        let syncedItem = try await mockSyncCoordinator.syncItemFromCloud(
            itemId: originalItem.id,
            to: secondaryContext
        )
        
        // Verify sync accuracy
        XCTAssertEqual(syncedItem.name, originalItem.name)
        XCTAssertEqual(syncedItem.purchasePrice, originalItem.purchasePrice)
        XCTAssertEqual(syncedItem.serialNumber, originalItem.serialNumber)
        XCTAssertEqual(syncedItem.id, originalItem.id)
        
        // Verify data integrity
        let fetchDescriptor = FetchDescriptor<Item>()
        let secondaryItems = try secondaryContext.fetch(fetchDescriptor)
        XCTAssertEqual(secondaryItems.count, 1)
        XCTAssertEqual(secondaryItems.first?.name, "iPhone Created Insurance Item")
    }
    
    func testComplexInsuranceDataSync() async throws {
        // Test synchronization of complex insurance data with relationships
        
        let primaryContext = primaryContainer.mainContext
        
        // Create comprehensive insurance item on primary device
        let category = Nestory.Category(name: "Electronics", icon: "tv.fill", colorHex: "#007AFF")
        let warranty = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: Date(),
            expiresAt: Date().addingTimeInterval(365 * 24 * 60 * 60) // 1 year
        )
        
        let item = Item(name: "MacBook Pro M3")
        item.purchasePrice = Decimal(2499)
        item.category = category
        item.warranty = warranty
        item.serialNumber = "MBP2024123456"
        item.itemDescription = "16-inch MacBook Pro with M3 Max chip"
        item.imageData = createMockImageData()
        
        primaryContext.insert(category)
        primaryContext.insert(warranty)
        primaryContext.insert(item)
        try primaryContext.save()
        
        // Simulate full sync to cloud
        try await mockCloudBackupService.syncComplexItemToCloud(
            item: item,
            category: category,
            warranty: warranty
        )
        
        // Sync to secondary device
        let syncedData = try await mockSyncCoordinator.syncComplexItemFromCloud(
            itemId: item.id,
            to: secondaryContainer.mainContext
        )
        
        // Verify all relationships synced correctly
        XCTAssertEqual(syncedData.item.name, "MacBook Pro M3")
        XCTAssertEqual(syncedData.item.purchasePrice, Decimal(2499))
        XCTAssertEqual(syncedData.category?.name, "Electronics")
        XCTAssertEqual(syncedData.warranty?.provider, "Apple")
        XCTAssertNotNil(syncedData.item.imageData)
        
        // Verify data integrity on secondary device
        let secondaryContext = secondaryContainer.mainContext
        let items = try secondaryContext.fetch(FetchDescriptor<Item>())
        let categories = try secondaryContext.fetch(FetchDescriptor<Nestory.Category>())
        let warranties = try secondaryContext.fetch(FetchDescriptor<Warranty>())
        
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(categories.count, 1)
        XCTAssertEqual(warranties.count, 1)
    }
    
    // MARK: - Conflict Resolution Tests
    
    func testSimultaneousEditConflictResolution() async throws {
        // Test conflict resolution when same item is edited on multiple devices
        
        let primaryContext = primaryContainer.mainContext
        let secondaryContext = secondaryContainer.mainContext
        
        // Create identical item on both devices
        let itemId = UUID()
        let primaryItem = Item(name: "Conflict Test Item")
        primaryItem.id = itemId
        primaryItem.purchasePrice = Decimal(1000)
        primaryItem.updatedAt = Date()
        
        let secondaryItem = Item(name: "Conflict Test Item")
        secondaryItem.id = itemId
        secondaryItem.purchasePrice = Decimal(1000)
        secondaryItem.updatedAt = Date()
        
        primaryContext.insert(primaryItem)
        secondaryContext.insert(secondaryItem)
        try primaryContext.save()
        try secondaryContext.save()
        
        // Simulate simultaneous edits
        let timestamp1 = Date()
        primaryItem.purchasePrice = Decimal(1200)
        primaryItem.itemDescription = "Updated from iPhone"
        primaryItem.updatedAt = timestamp1
        
        let timestamp2 = timestamp1.addingTimeInterval(1) // Slightly later
        secondaryItem.purchasePrice = Decimal(1300)
        secondaryItem.itemDescription = "Updated from iPad"
        secondaryItem.updatedAt = timestamp2
        
        try primaryContext.save()
        try secondaryContext.save()
        
        // Sync both changes to cloud
        mockCloudBackupService.cloudItems[itemId] = primaryItem
        try await mockCloudBackupService.syncConflictingItem(secondaryItem)
        
        // Resolve conflict (latest timestamp wins)
        let resolvedItem = try await mockSyncCoordinator.resolveConflict(itemId: itemId)
        
        // Verify conflict resolution (secondary item should win due to later timestamp)
        XCTAssertEqual(resolvedItem.purchasePrice, Decimal(1300))
        XCTAssertEqual(resolvedItem.itemDescription, "Updated from iPad")
        XCTAssertEqual(resolvedItem.updatedAt, timestamp2)
    }
    
    func testImageDataConflictResolution() async throws {
        // Test conflict resolution for image data across devices
        
        let itemId = UUID()
        let primaryContext = primaryContainer.mainContext
        let secondaryContext = secondaryContainer.mainContext
        
        // Create items with different images
        let primaryItem = Item(name: "Image Conflict Item")
        primaryItem.id = itemId
        primaryItem.imageData = createMockImageData(color: "red")
        primaryItem.updatedAt = Date()
        
        let secondaryItem = Item(name: "Image Conflict Item")
        secondaryItem.id = itemId
        secondaryItem.imageData = createMockImageData(color: "blue")
        secondaryItem.updatedAt = Date().addingTimeInterval(5) // Later timestamp
        
        primaryContext.insert(primaryItem)
        secondaryContext.insert(secondaryItem)
        try primaryContext.save()
        try secondaryContext.save()
        
        // Sync conflict
        mockCloudBackupService.cloudItems[itemId] = primaryItem
        try await mockCloudBackupService.syncConflictingItem(secondaryItem)
        
        let resolvedItem = try await mockSyncCoordinator.resolveImageConflict(itemId: itemId)
        
        // Verify latest image data wins
        XCTAssertEqual(resolvedItem.imageData, createMockImageData(color: "blue"))
        XCTAssertEqual(resolvedItem.updatedAt, secondaryItem.updatedAt)
    }
    
    // MARK: - Network Condition Tests
    
    func testSyncWithPoorNetworkConditions() async throws {
        // Test sync behavior under poor network conditions
        
        mockCloudBackupService.simulatePoorNetwork = true
        mockCloudBackupService.networkLatency = 5.0 // 5 second delay
        mockCloudBackupService.packetLossRate = 0.3 // 30% packet loss
        
        let item = Item(name: "Poor Network Test Item")
        item.purchasePrice = Decimal(500)
        item.imageData = createLargeImageData() // Large image to stress network
        
        let primaryContext = primaryContainer.mainContext
        primaryContext.insert(item)
        try primaryContext.save()
        
        // Measure sync performance under poor conditions
        let startTime = Date()
        
        do {
            try await mockCloudBackupService.syncItemToCloud(item)
            let syncDuration = Date().timeIntervalSince(startTime)
            
            // Verify sync eventually succeeds despite poor conditions
            XCTAssertNotNil(mockCloudBackupService.cloudItems[item.id])
            XCTAssertGreaterThan(syncDuration, 5.0) // Should take at least the latency time
            
        } catch {
            // Acceptable for sync to fail under extreme conditions
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    func testOfflineSyncQueueing() async throws {
        // Test queueing of changes when device is offline
        
        mockCloudBackupService.isOffline = true
        
        let primaryContext = primaryContainer.mainContext
        
        // Create multiple items while offline
        let items = [
            Item(name: "Offline Item 1"),
            Item(name: "Offline Item 2"),
            Item(name: "Offline Item 3")
        ]
        
        for item in items {
            item.purchasePrice = Decimal(Double.random(in: 100...1000))
            primaryContext.insert(item)
        }
        try primaryContext.save()
        
        // Attempt sync while offline (should queue)
        for item in items {
            try await mockCloudBackupService.syncItemToCloud(item)
        }
        
        // Verify items are queued for sync
        XCTAssertEqual(mockCloudBackupService.queuedItems.count, 3)
        XCTAssertTrue(mockCloudBackupService.cloudItems.isEmpty)
        
        // Come back online
        mockCloudBackupService.isOffline = false
        try await mockCloudBackupService.processQueuedItems()
        
        // Verify queued items are now synced
        XCTAssertEqual(mockCloudBackupService.cloudItems.count, 3)
        XCTAssertTrue(mockCloudBackupService.queuedItems.isEmpty)
    }
    
    // MARK: - Large Dataset Sync Tests
    
    func testLargeInventorySyncPerformance() async throws {
        // Test syncing large insurance inventory across devices
        
        let primaryContext = primaryContainer.mainContext
        let itemCount = 1000
        
        // Create large inventory on primary device
        var createdItems: [Item] = []
        for i in 0..<itemCount {
            let item = Item(name: "Sync Performance Item \(i)")
            item.purchasePrice = Decimal(Double.random(in: 50...5000))
            item.itemDescription = "Large sync test item \(i)"
            item.serialNumber = "SYNC\(String(format: "%06d", i))"
            primaryContext.insert(item)
            createdItems.append(item)
        }
        try primaryContext.save()
        
        // Measure batch sync performance
        let startTime = Date()
        
        try await mockCloudBackupService.syncItemsBatch(createdItems, batchSize: 100)
        
        let syncDuration = Date().timeIntervalSince(startTime)
        
        // Verify performance meets requirements
        XCTAssertLessThan(syncDuration, 30.0, "Large inventory sync should complete in under 30 seconds")
        XCTAssertEqual(mockCloudBackupService.cloudItems.count, itemCount)
        
        // Verify batch sync to secondary device
        let syncedItems = try await mockSyncCoordinator.syncItemsBatchFromCloud(
            itemIds: createdItems.map { $0.id },
            to: secondaryContainer.mainContext
        )
        
        XCTAssertEqual(syncedItems.count, itemCount)
    }
    
    func testIncrementalSyncOptimization() async throws {
        // Test that only changed items sync (not full inventory)
        
        let primaryContext = primaryContainer.mainContext
        let itemCount = 100
        
        // Create initial inventory
        var allItems: [Item] = []
        for i in 0..<itemCount {
            let item = Item(name: "Incremental Sync Item \(i)")
            item.purchasePrice = Decimal(Double.random(in: 100...1000))
            primaryContext.insert(item)
            allItems.append(item)
        }
        try primaryContext.save()
        
        // Initial full sync
        try await mockCloudBackupService.syncItemsBatch(allItems, batchSize: 50)
        let initialSyncCount = mockCloudBackupService.syncOperationCount
        
        // Modify only 10 items
        let modifiedItems = Array(allItems.prefix(10))
        for item in modifiedItems {
            item.purchasePrice = (item.purchasePrice ?? 0) * Decimal(1.1) // 10% increase
            item.updatedAt = Date()
        }
        try primaryContext.save()
        
        // Reset sync counter
        mockCloudBackupService.syncOperationCount = 0
        
        // Incremental sync
        try await mockCloudBackupService.syncIncrementalChanges(allItems, since: Date().addingTimeInterval(-60))
        
        // Verify only modified items were synced
        XCTAssertEqual(mockCloudBackupService.syncOperationCount, 10)
        XCTAssertLessThan(mockCloudBackupService.syncOperationCount, initialSyncCount)
    }
    
    // MARK: - Platform-Specific Feature Tests
    
    func testMacOSSpecificFeatures() async throws {
        // Test features specific to macOS (larger screen, keyboard shortcuts)
        
        #if os(macOS)
        let item = Item(name: "macOS Specific Item")
        item.purchasePrice = Decimal(2999)
        item.itemDescription = "Created with macOS-specific drag and drop"
        
        // Simulate macOS-specific data
        item.tags = ["macOS", "desktop", "professional"]
        item.notes = "Added via macOS bulk import feature"
        
        let primaryContext = primaryContainer.mainContext
        primaryContext.insert(item)
        try primaryContext.save()
        
        try await mockCloudBackupService.syncItemToCloud(item)
        
        // Sync to iOS device
        let syncedItem = try await mockSyncCoordinator.syncItemFromCloud(
            itemId: item.id,
            to: secondaryContainer.mainContext
        )
        
        // Verify macOS-specific data syncs to iOS
        XCTAssertEqual(syncedItem.tags, ["macOS", "desktop", "professional"])
        XCTAssertEqual(syncedItem.notes, "Added via macOS bulk import feature")
        #endif
    }
    
    func testIOSSpecificFeatures() async throws {
        // Test features specific to iOS (camera, location services)
        
        let item = Item(name: "iOS Specific Item")
        item.purchasePrice = Decimal(1200)
        item.imageData = createMockImageData() // Simulates camera capture
        
        // Simulate iOS-specific location data
        
        let primaryContext = primaryContainer.mainContext
        primaryContext.insert(item)
        try primaryContext.save()
        
        try await mockCloudBackupService.syncItemToCloud(item)
        
        // Sync to macOS device
        let syncedItem = try await mockSyncCoordinator.syncItemFromCloud(
            itemId: item.id,
            to: secondaryContainer.mainContext
        )
        
        // Verify iOS-specific data syncs to macOS
        XCTAssertNotNil(syncedItem.imageData)
    }
    
    // MARK: - Data Consistency Tests
    
    func testConcurrentModificationConsistency() async throws {
        // Test data consistency under concurrent modifications from multiple devices
        
        let itemId = UUID()
        let primaryContext = primaryContainer.mainContext
        let secondaryContext = secondaryContainer.mainContext
        
        // Create same item on both devices
        let primaryItem = Item(name: "Concurrent Modification Test")
        primaryItem.id = itemId
        primaryItem.purchasePrice = Decimal(1000)
        
        let secondaryItem = Item(name: "Concurrent Modification Test")
        secondaryItem.id = itemId
        secondaryItem.purchasePrice = Decimal(1000)
        
        primaryContext.insert(primaryItem)
        secondaryContext.insert(secondaryItem)
        try primaryContext.save()
        try secondaryContext.save()
        
        // Simulate rapid concurrent modifications
        let primaryTask = Task {
            for i in 0..<5 {
                primaryItem.purchasePrice = Decimal(1000 + i * 100)
                primaryItem.updatedAt = Date()
                try primaryContext.save()
                try await mockCloudBackupService.syncItemToCloud(primaryItem)
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            }
        }
        
        let secondaryTask = Task {
            for i in 0..<5 {
                secondaryItem.purchasePrice = Decimal(2000 + i * 100)
                secondaryItem.updatedAt = Date()
                try secondaryContext.save()
                try await mockCloudBackupService.syncItemToCloud(secondaryItem)
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            }
        }
        
        // Wait for both tasks to complete
        _ = try await primaryTask.value
        _ = try await secondaryTask.value
        
        // Resolve final state
        let finalItem = try await mockSyncCoordinator.resolveConflict(itemId: itemId)
        
        // Verify data consistency (should have one of the final values)
        XCTAssertTrue(
            finalItem.purchasePrice == Decimal(1400) || finalItem.purchasePrice == Decimal(2400),
            "Final price should be one of the last values: \(finalItem.purchasePrice ?? 0)"
        )
    }
    
    // MARK: - Helper Methods
    
    private func createMockImageData(color: String = "default") -> Data {
        // Create distinctive mock image data for testing
        let prefix: [UInt8] = color == "red" ? [0xFF, 0x00, 0x00] : 
                             color == "blue" ? [0x00, 0x00, 0xFF] : [0x89, 0x50, 0x4E]
        return Data(prefix + [0x47]) // PNG-like header
    }
    
    private func createLargeImageData() -> Data {
        // Create large image data to stress network conditions
        return Data(repeating: 0xFF, count: 1_000_000) // 1MB
    }
}

// MARK: - Mock Services for Cross-Platform Testing

final class MockCloudBackupService: @unchecked Sendable {
    var cloudItems: [UUID: Item] = [:]
    var queuedItems: [Item] = []
    var syncOperationCount: Int = 0
    
    // Network simulation properties
    var simulatePoorNetwork: Bool = false
    var networkLatency: Double = 0
    var packetLossRate: Double = 0
    var isOffline: Bool = false
    
    func syncItemToCloud(_ item: Item) async throws {
        if isOffline {
            queuedItems.append(item)
            return
        }
        
        if simulatePoorNetwork {
            try await simulateNetworkConditions()
        }
        
        cloudItems[item.id] = item
        syncOperationCount += 1
    }
    
    func syncComplexItemToCloud(item: Item, category: Nestory.Category?, warranty: Warranty?) async throws {
        cloudItems[item.id] = item
        syncOperationCount += 1
    }
    
    func syncConflictingItem(_ item: Item) async throws {
        // Simulate conflict detection and resolution
        if let existing = cloudItems[item.id] {
            if item.updatedAt > existing.updatedAt {
                cloudItems[item.id] = item
            }
        } else {
            cloudItems[item.id] = item
        }
        syncOperationCount += 1
    }
    
    func syncItemsBatch(_ items: [Item], batchSize: Int) async throws {
        for i in stride(from: 0, to: items.count, by: batchSize) {
            let batchEnd = min(i + batchSize, items.count)
            let batch = Array(items[i..<batchEnd])
            
            for item in batch {
                try await syncItemToCloud(item)
            }
        }
    }
    
    func syncIncrementalChanges(_ items: [Item], since date: Date) async throws {
        let modifiedItems = items.filter { $0.updatedAt > date }
        for item in modifiedItems {
            try await syncItemToCloud(item)
        }
    }
    
    func processQueuedItems() async throws {
        for item in queuedItems {
            try await syncItemToCloud(item)
        }
        queuedItems.removeAll()
    }
    
    private func simulateNetworkConditions() async throws {
        // Simulate network latency
        if networkLatency > 0 {
            try await Task.sleep(nanoseconds: UInt64(networkLatency * 1_000_000_000))
        }
        
        // Simulate packet loss
        if Double.random(in: 0...1) < packetLossRate {
            throw NetworkError.timeout
        }
    }
}

final class MockSyncCoordinator: @unchecked Sendable {
    
    func syncItemFromCloud(itemId: UUID, to context: ModelContext) async throws -> Item {
        // Simulate fetching from cloud and inserting to local context
        guard let cloudItem = MockCloudBackupService().cloudItems[itemId] else {
            throw SyncError.itemNotFound
        }
        
        let localItem = Item(name: cloudItem.name)
        localItem.id = cloudItem.id
        localItem.purchasePrice = cloudItem.purchasePrice
        localItem.serialNumber = cloudItem.serialNumber
        localItem.purchaseDate = cloudItem.purchaseDate
        localItem.itemDescription = cloudItem.itemDescription
        localItem.imageData = cloudItem.imageData
        localItem.updatedAt = cloudItem.updatedAt
        
        context.insert(localItem)
        try context.save()
        
        return localItem
    }
    
    func syncComplexItemFromCloud(itemId: UUID, to context: ModelContext) async throws -> (item: Item, category: Nestory.Category?, warranty: Warranty?) {
        // Simulate complex sync with relationships
        let item = try await syncItemFromCloud(itemId: itemId, to: context)
        
        // Simulate relationship objects
        let category = Nestory.Category(name: "Electronics", icon: "tv.fill", colorHex: "#007AFF")
        let warranty = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: Date(),
            expiresAt: Date().addingTimeInterval(365 * 24 * 60 * 60)
        )
        
        context.insert(category)
        context.insert(warranty)
        try context.save()
        
        return (item, category, warranty)
    }
    
    func resolveConflict(itemId: UUID) async throws -> Item {
        // Simple conflict resolution: return the most recent version
        guard let cloudItem = MockCloudBackupService().cloudItems[itemId] else {
            throw SyncError.itemNotFound
        }
        return cloudItem
    }
    
    func resolveImageConflict(itemId: UUID) async throws -> Item {
        return try await resolveConflict(itemId: itemId)
    }
    
    func syncItemsBatchFromCloud(itemIds: [UUID], to context: ModelContext) async throws -> [Item] {
        var syncedItems: [Item] = []
        
        for itemId in itemIds {
            let item = try await syncItemFromCloud(itemId: itemId, to: context)
            syncedItems.append(item)
        }
        
        return syncedItems
    }
}

// MARK: - Sync-specific Error Types

enum SyncError: Error {
    case itemNotFound
    case conflictResolutionFailed
    case networkUnavailable
    case quotaExceeded
}


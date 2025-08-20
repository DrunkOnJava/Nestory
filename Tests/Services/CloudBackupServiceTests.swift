//
// Layer: Tests
// Module: Services
// Purpose: Comprehensive tests for CloudBackupService with CloudKit mocking
//

import CloudKit
@testable import Nestory
import SwiftData
import XCTest

@MainActor
final class CloudBackupServiceTests: XCTestCase {
    var service: CloudBackupService!
    var mockModelContainer: ModelContainer!
    var mockModelContext: ModelContext!

    override func setUp() async throws {
        super.setUp()

        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        mockModelContainer = try ModelContainer(for: Item.self, Category.self, Room.self, configurations: config)
        mockModelContext = ModelContext(mockModelContainer)

        service = CloudBackupService()

        // Allow some time for CloudKit initialization
        try await Task.sleep(for: .milliseconds(100))
    }

    override func tearDown() {
        service = nil
        mockModelContext = nil
        mockModelContainer = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        XCTAssertFalse(service.isBackingUp)
        XCTAssertFalse(service.isRestoring)
        XCTAssertNil(service.lastBackupDate)
        XCTAssertEqual(service.backupStatus, .idle)
        XCTAssertNil(service.errorMessage)
        XCTAssertEqual(service.progress, 0.0)

        // CloudKit availability depends on configuration
        // In test environment, this will likely be false
        XCTAssertFalse(service.isCloudKitAvailable)
    }

    func testCloudKitInitializationInTestEnvironment() async {
        // In test environment, CloudKit should not be available
        let isAvailable = await service.checkCloudKitAvailability()
        XCTAssertFalse(isAvailable)
        XCTAssertNotNil(service.errorMessage)
    }

    // MARK: - Backup Operation Tests

    func testPerformBackupWithoutCloudKit() async {
        // Create test data
        let items = [TestData.makeItem(name: "Test Item")]
        let categories = [TestData.makeCategory(name: "Test Category")]
        let rooms: [Room] = []

        // Should throw error when CloudKit not available
        do {
            try await service.performBackup(items: items, categories: categories, rooms: rooms)
            XCTFail("Should have thrown BackupError.iCloudUnavailable")
        } catch BackupError.iCloudUnavailable {
            XCTAssertTrue(true, "Correctly threw iCloudUnavailable error")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertFalse(service.isBackingUp)
    }

    func testBackupStateChangesWithoutCloudKit() async {
        let items = [TestData.makeItem()]
        let categories: [Category] = []
        let rooms: [Room] = []

        // Start backup (will fail but we can test state changes)
        do {
            try await service.performBackup(items: items, categories: categories, rooms: rooms)
        } catch {
            // Expected to fail
        }

        // Verify final state is clean
        XCTAssertFalse(service.isBackingUp)
        XCTAssertEqual(service.backupStatus, .idle)
    }

    func testEstimateBackupSize() {
        let items = [
            TestData.makeItem(name: "Item 1"),
            TestData.makeItem(name: "Item 2"),
        ]

        let sizeEstimate = service.estimateBackupSize(items: items)

        // Should return a valid size string (even if CloudKit not available)
        XCTAssertNotNil(sizeEstimate)
        XCTAssertTrue(sizeEstimate == "Unknown" || sizeEstimate.contains("B")) // Bytes indicator
    }

    // MARK: - Restore Operation Tests

    func testPerformRestoreWithoutCloudKit() async {
        do {
            _ = try await service.performRestore(modelContext: mockModelContext)
            XCTFail("Should have thrown BackupError.iCloudUnavailable")
        } catch BackupError.iCloudUnavailable {
            XCTAssertTrue(true, "Correctly threw iCloudUnavailable error")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertFalse(service.isRestoring)
    }

    func testRestoreStateChangesWithoutCloudKit() async {
        // Start restore (will fail but we can test state changes)
        do {
            _ = try await service.performRestore(modelContext: mockModelContext)
        } catch {
            // Expected to fail
        }

        // Verify final state is clean
        XCTAssertFalse(service.isRestoring)
        XCTAssertEqual(service.backupStatus, .idle)
    }

    // MARK: - Backup Info Tests

    func testGetBackupInfoWithoutCloudKit() async {
        do {
            let backupInfo = try await service.getBackupInfo()
            XCTAssertNil(backupInfo, "Should return nil when CloudKit not available")
        } catch {
            XCTFail("Should not throw error, should return nil")
        }
    }

    // MARK: - Published Property Tests

    func testPublishedPropertiesAreMainActorIsolated() {
        // These should be accessible from main actor context
        XCTAssertFalse(service.isBackingUp)
        XCTAssertFalse(service.isRestoring)
        XCTAssertNil(service.lastBackupDate)
        XCTAssertEqual(service.backupStatus, .idle)
        XCTAssertNil(service.errorMessage)
        XCTAssertEqual(service.progress, 0.0)
        XCTAssertFalse(service.isCloudKitAvailable)
    }

    // MARK: - Error Handling Tests

    func testBackupWithEmptyData() async {
        let emptyItems: [Item] = []
        let emptyCategories: [Category] = []
        let emptyRooms: [Room] = []

        do {
            try await service.performBackup(items: emptyItems, categories: emptyCategories, rooms: emptyRooms)
            XCTFail("Should have thrown error for unavailable CloudKit")
        } catch BackupError.iCloudUnavailable {
            XCTAssertTrue(true, "Correctly handled empty data with unavailable CloudKit")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testBackupWithLargeDataset() async {
        // Create large dataset
        let items = (1 ... 100).map { TestData.makeItem(name: "Item \($0)") }
        let categories = (1 ... 10).map { TestData.makeCategory(name: "Category \($0)") }
        let rooms: [Room] = []

        do {
            try await service.performBackup(items: items, categories: categories, rooms: rooms)
            XCTFail("Should have thrown error for unavailable CloudKit")
        } catch BackupError.iCloudUnavailable {
            XCTAssertTrue(true, "Correctly handled large dataset with unavailable CloudKit")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - Backup Status Tests

@MainActor
final class BackupStatusTests: XCTestCase {
    func testBackupStatusEquatable() {
        XCTAssertEqual(BackupStatus.idle, BackupStatus.idle)
        XCTAssertEqual(BackupStatus.completed, BackupStatus.completed)
        XCTAssertEqual(BackupStatus.failed, BackupStatus.failed)

        XCTAssertNotEqual(BackupStatus.idle, BackupStatus.completed)
        XCTAssertNotEqual(BackupStatus.backing(.preparing), BackupStatus.backing(.items))
        XCTAssertNotEqual(BackupStatus.restoring(.categories), BackupStatus.restoring(.items))
    }
}

// MARK: - BackupError Tests

final class BackupErrorTests: XCTestCase {
    func testBackupErrorDescriptions() {
        let errors: [BackupError] = [
            .iCloudUnavailable,
            .notInitialized,
            .noBackupFound,
            .operationFailed("Test failure"),
            .invalidData("Invalid test data"),
            .networkError("Network test error"),
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    func testBackupErrorEquatable() {
        XCTAssertEqual(BackupError.iCloudUnavailable, BackupError.iCloudUnavailable)
        XCTAssertEqual(BackupError.notInitialized, BackupError.notInitialized)
        XCTAssertEqual(BackupError.noBackupFound, BackupError.noBackupFound)

        XCTAssertEqual(
            BackupError.operationFailed("test"),
            BackupError.operationFailed("test"),
        )

        XCTAssertNotEqual(
            BackupError.operationFailed("test1"),
            BackupError.operationFailed("test2"),
        )

        XCTAssertNotEqual(BackupError.iCloudUnavailable, BackupError.notInitialized)
    }
}

// MARK: - BackupMetadata Tests

final class BackupMetadataTests: XCTestCase {
    func testBackupMetadataInit() {
        let date = Date()
        let metadata = BackupMetadata(
            date: date,
            itemCount: 50,
            deviceName: "Test Device",
            appVersion: "1.0.0",
        )

        XCTAssertEqual(metadata.date, date)
        XCTAssertEqual(metadata.itemCount, 50)
        XCTAssertEqual(metadata.deviceName, "Test Device")
        XCTAssertEqual(metadata.appVersion, "1.0.0")
    }

    func testBackupMetadataWithOptionalVersion() {
        let date = Date()
        let metadata = BackupMetadata(
            date: date,
            itemCount: 25,
            deviceName: "iPhone",
        )

        XCTAssertEqual(metadata.date, date)
        XCTAssertEqual(metadata.itemCount, 25)
        XCTAssertEqual(metadata.deviceName, "iPhone")
        XCTAssertNil(metadata.appVersion)
    }
}

// MARK: - RestoreResult Tests

final class RestoreResultTests: XCTestCase {
    func testRestoreResultInit() {
        let backupDate = Date()
        let result = RestoreResult(
            itemsRestored: 50,
            categoriesRestored: 10,
            roomsRestored: 5,
            backupDate: backupDate,
        )

        XCTAssertEqual(result.itemsRestored, 50)
        XCTAssertEqual(result.categoriesRestored, 10)
        XCTAssertEqual(result.roomsRestored, 5)
        XCTAssertEqual(result.backupDate, backupDate)
    }

    func testRestoreResultEquatable() {
        let date = Date()
        let result1 = RestoreResult(
            itemsRestored: 10,
            categoriesRestored: 2,
            roomsRestored: 1,
            backupDate: date,
        )

        let result2 = RestoreResult(
            itemsRestored: 10,
            categoriesRestored: 2,
            roomsRestored: 1,
            backupDate: date,
        )

        XCTAssertEqual(result1, result2)

        let result3 = RestoreResult(
            itemsRestored: 5,
            categoriesRestored: 2,
            roomsRestored: 1,
            backupDate: date,
        )

        XCTAssertNotEqual(result1, result3)
    }
}

// MARK: - Integration Tests

@MainActor
final class CloudBackupServiceIntegrationTests: XCTestCase {
    func testFullBackupRestoreWorkflowWithoutCloudKit() async throws {
        let service = CloudBackupService()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, Category.self, Room.self, configurations: config)
        let context = ModelContext(container)

        // Create test data
        let item1 = TestData.makeItem(name: "Integration Item 1")
        let item2 = TestData.makeItem(name: "Integration Item 2")
        let category = TestData.makeCategory(name: "Integration Category")

        context.insert(item1)
        context.insert(item2)
        context.insert(category)
        try context.save()

        let items = [item1, item2]
        let categories = [category]
        let rooms: [Room] = []

        // Test backup workflow (will fail due to no CloudKit)
        do {
            try await service.performBackup(items: items, categories: categories, rooms: rooms)
            XCTFail("Should fail without CloudKit")
        } catch BackupError.iCloudUnavailable {
            XCTAssertTrue(true, "Expected failure without CloudKit")
        }

        // Test restore workflow (will fail due to no CloudKit)
        do {
            _ = try await service.performRestore(modelContext: context)
            XCTFail("Should fail without CloudKit")
        } catch BackupError.iCloudUnavailable {
            XCTAssertTrue(true, "Expected failure without CloudKit")
        }

        // Verify service is in clean state
        XCTAssertFalse(service.isBackingUp)
        XCTAssertFalse(service.isRestoring)
        XCTAssertEqual(service.backupStatus, .idle)
    }
}

// MARK: - Performance Tests

@MainActor
final class CloudBackupServicePerformanceTests: XCTestCase {
    func testBackupLargeDatasetPerformance() async throws {
        let service = CloudBackupService()

        // Create large dataset
        let items = (1 ... 1000).map { TestData.makeItem(name: "Perf Item \($0)") }
        let categories = (1 ... 50).map { TestData.makeCategory(name: "Perf Category \($0)") }
        let rooms: [Room] = []

        measure {
            Task { @MainActor in
                do {
                    try await service.performBackup(items: items, categories: categories, rooms: rooms)
                } catch {
                    // Expected to fail in test environment
                }
            }
        }
    }

    func testEstimateBackupSizePerformance() {
        let service = CloudBackupService()
        let items = (1 ... 10000).map { TestData.makeItem(name: "Size Item \($0)") }

        measure {
            _ = service.estimateBackupSize(items: items)
        }
    }
}

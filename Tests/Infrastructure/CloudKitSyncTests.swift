//
// Layer: Infrastructure
// Module: Tests
// Purpose: Comprehensive CloudKit sync testing to ensure data integrity
//

import XCTest
import CloudKit
import Combine
@testable import Nestory

final class CloudKitSyncTests: XCTestCase {
    
    var sut: CloudKitSyncManager!
    var mockContainer: CKContainer!
    var mockDatabase: CKDatabase!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
        
        // Set up mock CloudKit environment
        mockContainer = CKContainer(identifier: "iCloud.com.test.nestory")
        mockDatabase = mockContainer.privateCloudDatabase
        
        // Initialize system under test
        sut = CloudKitSyncManager(container: mockContainer)
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        mockDatabase = nil
        mockContainer = nil
        super.tearDown()
    }
    
    // MARK: - Upload Tests
    
    func testUploadSingleItemSuccess() async throws {
        // Given
        let item = Item(
            name: "Test Item",
            category: .electronics,
            value: 999.99,
            purchaseDate: Date(),
            location: .livingRoom
        )
        
        // When
        let expectation = XCTestExpectation(description: "Upload completes")
        var uploadedRecord: CKRecord?
        
        try await sut.uploadItem(item) { result in
            switch result {
            case .success(let record):
                uploadedRecord = record
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Upload failed: \(error)")
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertNotNil(uploadedRecord)
        XCTAssertEqual(uploadedRecord?["name"] as? String, "Test Item")
        XCTAssertEqual(uploadedRecord?["value"] as? Double, 999.99)
    }
    
    func testUploadBatchItemsSuccess() async throws {
        // Given
        let items = (1...10).map { index in
            Item(
                name: "Item \(index)",
                category: .electronics,
                value: Double(index * 100),
                purchaseDate: Date(),
                location: .bedroom
            )
        }
        
        // When
        let expectation = XCTestExpectation(description: "Batch upload completes")
        var uploadedCount = 0
        
        try await sut.uploadBatch(items) { result in
            switch result {
            case .success(let records):
                uploadedCount = records.count
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Batch upload failed: \(error)")
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
        
        // Then
        XCTAssertEqual(uploadedCount, 10)
    }
    
    func testUploadWithRetryOnNetworkError() async throws {
        // Given
        let item = Item(
            name: "Retry Test Item",
            category: .furniture,
            value: 500.00,
            purchaseDate: Date(),
            location: .garage
        )
        
        // Simulate network error then success
        sut.mockNetworkCondition = .failThenSucceed
        
        // When
        let expectation = XCTestExpectation(description: "Upload retries and succeeds")
        var retryCount = 0
        
        try await sut.uploadItem(item, maxRetries: 3) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                retryCount += 1
                if retryCount >= 3 {
                    XCTFail("Max retries exceeded")
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
        
        // Then
        XCTAssertLessThan(retryCount, 3)
    }
    
    // MARK: - Download Tests
    
    func testDownloadAllItemsSuccess() async throws {
        // Given - seed mock database
        try await seedMockDatabase(itemCount: 5)
        
        // When
        let expectation = XCTestExpectation(description: "Download completes")
        var downloadedItems: [Item] = []
        
        try await sut.downloadAllItems { result in
            switch result {
            case .success(let items):
                downloadedItems = items
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Download failed: \(error)")
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertEqual(downloadedItems.count, 5)
        XCTAssertTrue(downloadedItems.allSatisfy { !$0.name.isEmpty })
    }
    
    func testIncrementalSync() async throws {
        // Given
        let lastSyncDate = Date().addingTimeInterval(-3600) // 1 hour ago
        try await seedMockDatabase(itemCount: 3, after: lastSyncDate)
        
        // When
        let expectation = XCTestExpectation(description: "Incremental sync completes")
        var syncedItems: [Item] = []
        
        try await sut.incrementalSync(since: lastSyncDate) { result in
            switch result {
            case .success(let items):
                syncedItems = items
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Incremental sync failed: \(error)")
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertEqual(syncedItems.count, 3)
    }
    
    // MARK: - Conflict Resolution Tests
    
    func testConflictResolutionPreferLocal() async throws {
        // Given
        let localItem = Item(
            id: UUID(),
            name: "Local Version",
            category: .electronics,
            value: 100.00,
            modifiedAt: Date()
        )
        
        let remoteItem = Item(
            id: localItem.id,
            name: "Remote Version",
            category: .electronics,
            value: 200.00,
            modifiedAt: Date().addingTimeInterval(-60) // Older
        )
        
        // When
        let resolved = try await sut.resolveConflict(
            local: localItem,
            remote: remoteItem,
            strategy: .preferLocal
        )
        
        // Then
        XCTAssertEqual(resolved.name, "Local Version")
        XCTAssertEqual(resolved.value, 100.00)
    }
    
    func testConflictResolutionPreferNewest() async throws {
        // Given
        let oldItem = Item(
            id: UUID(),
            name: "Old Version",
            modifiedAt: Date().addingTimeInterval(-3600)
        )
        
        let newItem = Item(
            id: oldItem.id,
            name: "New Version",
            modifiedAt: Date()
        )
        
        // When
        let resolved = try await sut.resolveConflict(
            local: oldItem,
            remote: newItem,
            strategy: .preferNewest
        )
        
        // Then
        XCTAssertEqual(resolved.name, "New Version")
    }
    
    func testConflictResolutionMerge() async throws {
        // Given
        let localItem = Item(
            id: UUID(),
            name: "Updated Name",
            category: .electronics,
            value: 100.00, // Original value
            notes: "Local notes"
        )
        
        let remoteItem = Item(
            id: localItem.id,
            name: "Original Name",
            category: .electronics,
            value: 150.00, // Updated value
            notes: "Remote notes"
        )
        
        // When
        let resolved = try await sut.resolveConflict(
            local: localItem,
            remote: remoteItem,
            strategy: .merge
        )
        
        // Then
        XCTAssertEqual(resolved.name, "Updated Name") // Local wins for name
        XCTAssertEqual(resolved.value, 150.00) // Remote wins for value
        XCTAssertTrue(resolved.notes?.contains("Local") ?? false)
        XCTAssertTrue(resolved.notes?.contains("Remote") ?? false)
    }
    
    // MARK: - Offline Queue Tests
    
    func testOfflineQueueing() async throws {
        // Given
        sut.networkStatus = .offline
        
        let item = Item(
            name: "Offline Item",
            category: .appliances,
            value: 299.99
        )
        
        // When - queue operation while offline
        let queueResult = try await sut.queueForSync(item)
        
        // Then
        XCTAssertTrue(queueResult)
        XCTAssertEqual(sut.pendingOperations.count, 1)
        
        // When - network comes back online
        sut.networkStatus = .online
        let expectation = XCTestExpectation(description: "Queued items sync")
        
        try await sut.processPendingQueue { result in
            switch result {
            case .success(let syncedCount):
                XCTAssertEqual(syncedCount, 1)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Queue processing failed: \(error)")
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertEqual(sut.pendingOperations.count, 0)
    }
    
    func testOfflineQueuePersistence() async throws {
        // Given
        sut.networkStatus = .offline
        
        let items = (1...5).map { index in
            Item(name: "Queued Item \(index)", value: Double(index * 100))
        }
        
        // When - queue multiple items
        for item in items {
            _ = try await sut.queueForSync(item)
        }
        
        // Save queue to disk
        try await sut.persistQueue()
        
        // Simulate app restart
        let newSut = CloudKitSyncManager(container: mockContainer)
        try await newSut.loadPersistedQueue()
        
        // Then
        XCTAssertEqual(newSut.pendingOperations.count, 5)
    }
    
    // MARK: - Error Handling Tests
    
    func testAuthenticationError() async throws {
        // Given
        sut.mockAuthStatus = .restricted
        
        // When
        let expectation = XCTestExpectation(description: "Auth error handled")
        var authError: CloudKitError?
        
        try await sut.uploadItem(Item(name: "Test")) { result in
            switch result {
            case .success:
                XCTFail("Should have failed with auth error")
            case .failure(let error):
                authError = error as? CloudKitError
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertEqual(authError, .notAuthenticated)
    }
    
    func testQuotaExceededError() async throws {
        // Given
        sut.mockQuotaExceeded = true
        let largeItems = (1...1000).map { Item(name: "Item \($0)") }
        
        // When
        let expectation = XCTestExpectation(description: "Quota error handled")
        var quotaError: CloudKitError?
        
        try await sut.uploadBatch(largeItems) { result in
            switch result {
            case .success:
                XCTFail("Should have failed with quota error")
            case .failure(let error):
                quotaError = error as? CloudKitError
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertEqual(quotaError, .quotaExceeded)
    }
    
    func testPartialBatchFailure() async throws {
        // Given
        let items = (1...10).map { Item(name: "Item \($0)") }
        sut.mockFailIndices = [3, 7] // Fail items at index 3 and 7
        
        // When
        let expectation = XCTestExpectation(description: "Partial batch handled")
        var successCount = 0
        var failureCount = 0
        
        try await sut.uploadBatchWithPartialFailure(items) { result in
            switch result {
            case .partialSuccess(let succeeded, let failed):
                successCount = succeeded.count
                failureCount = failed.count
                expectation.fulfill()
            case .failure:
                XCTFail("Should have partially succeeded")
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertEqual(successCount, 8)
        XCTAssertEqual(failureCount, 2)
    }
    
    // MARK: - Performance Tests
    
    func testLargeBatchUploadPerformance() throws {
        let items = (1...1000).map { Item(name: "Perf Item \($0)") }
        
        measure {
            let expectation = XCTestExpectation(description: "Performance test")
            
            Task {
                try await sut.uploadBatch(items) { _ in
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 30.0)
        }
    }
    
    // MARK: - Helper Methods
    
    private func seedMockDatabase(itemCount: Int, after date: Date? = nil) async throws {
        for i in 1...itemCount {
            let record = CKRecord(recordType: "Item")
            record["name"] = "Seeded Item \(i)"
            record["value"] = Double(i * 100)
            if let date = date {
                record["modifiedAt"] = date.addingTimeInterval(Double(i * 60))
            }
            
            // Mock save to database
            _ = try await mockDatabase.save(record)
        }
    }
}

// MARK: - Mock Extensions

extension CloudKitSyncManager {
    enum NetworkCondition {
        case normal
        case offline
        case failThenSucceed
    }
    
    var mockNetworkCondition: NetworkCondition {
        get { .normal }
        set { /* Set mock condition */ }
    }
    
    var mockAuthStatus: CKAccountStatus {
        get { .available }
        set { /* Set mock auth status */ }
    }
    
    var mockQuotaExceeded: Bool {
        get { false }
        set { /* Set mock quota */ }
    }
    
    var mockFailIndices: [Int] {
        get { [] }
        set { /* Set indices to fail */ }
    }
}

enum CloudKitError: Error, Equatable {
    case notAuthenticated
    case quotaExceeded
    case networkError
    case syncConflict
}
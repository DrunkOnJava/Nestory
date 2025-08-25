//
// ComprehensiveServiceTests.swift
// NestoryTests
//
// Comprehensive service layer testing
//

import Foundation
@testable import Nestory
import Testing

@Suite("Service Layer Integration Tests")
struct ComprehensiveServiceTests {
    // MARK: - Analytics Service Tests

    @Suite("Analytics Service")
    struct AnalyticsServiceTests {
        @Test("Track item addition event")
        func testTrackItemAddition() async {
            let mockService = MockAnalyticsService()
            let item = ItemBuilder()
                .with(name: "Test Item")
                .with(category: "Electronics")
                .build()

            mockService.trackItemAddition(item)

            #expect(mockService.trackItemAdditionCalls.count == 1)
            #expect(mockService.trackItemAdditionCalls.first?.name == "Test Item")
        }

        @Test("Track multiple events maintains order")
        func multipleEventsOrder() async {
            let mockService = MockAnalyticsService()

            mockService.trackEvent("event1", parameters: [:])
            mockService.trackEvent("event2", parameters: [:])
            mockService.trackEvent("event3", parameters: [:])

            #expect(mockService.trackEventCalls.count == 3)
            #expect(mockService.trackEventCalls[0].0 == "event1")
            #expect(mockService.trackEventCalls[1].0 == "event2")
            #expect(mockService.trackEventCalls[2].0 == "event3")
        }

        @Test("Analytics service reset clears all tracking")
        func analyticsServiceReset() async {
            let mockService = MockAnalyticsService()

            mockService.trackEvent("test", parameters: [:])
            #expect(mockService.trackEventCalls.count == 1)

            mockService.reset()
            #expect(mockService.trackEventCalls.isEmpty)
        }
    }

    // MARK: - Cloud Backup Service Tests

    @Suite("Cloud Backup Service")
    struct CloudBackupServiceTests {
        @Test("Successful backup operation")
        func successfulBackup() async throws {
            let mockService = MockCloudBackupService()
            let items = TestFixtures.sampleItems

            let result = try await mockService.backup(items)

            #expect(mockService.backupCalls.count == 1)
            #expect(mockService.backupCalls.first?.items.count == items.count)

            if case let .success(metadata) = result {
                #expect(metadata.itemCount == 0) // Using default mock value
            } else {
                Issue.record("Expected successful backup result")
            }
        }

        @Test("Backup failure throws error")
        func backupFailure() async throws {
            let mockService = MockCloudBackupService()
            mockService.shouldFail = true
            mockService.error = TestError.mockError

            let items = TestFixtures.sampleItems

            await #expect(throws: TestError.self) {
                try await mockService.backup(items)
            }
        }

        @Test("Successful restore operation")
        func successfulRestore() async throws {
            let mockService = MockCloudBackupService()
            mockService.restoreResult = .success(TestFixtures.sampleItems)

            let result = try await mockService.restore()

            #expect(mockService.restoreCalls.count == 1)

            if case let .success(items) = result {
                #expect(items.count == TestFixtures.sampleItems.count)
            } else {
                Issue.record("Expected successful restore result")
            }
        }

        @Test("Restore failure throws error")
        func restoreFailure() async throws {
            let mockService = MockCloudBackupService()
            mockService.shouldFail = true
            mockService.error = TestError.mockError

            await #expect(throws: TestError.self) {
                try await mockService.restore()
            }
        }

        @Test("Concurrent backup operations are handled safely")
        func concurrentBackupOperations() async throws {
            let mockService = MockCloudBackupService()
            let items = TestFixtures.sampleItems

            // Perform multiple concurrent backup operations
            let results = try await testConcurrentAccess(iterations: 10) {
                try await mockService.backup(items)
            }

            #expect(results.count == 10)
            #expect(mockService.backupCalls.count == 10)
        }
    }

    // MARK: - Integration Tests

    @Suite("Service Integration")
    struct ServiceIntegrationTests {
        @Test("Analytics and backup services work together")
        func analyticsAndBackupIntegration() async throws {
            let analyticsService = MockAnalyticsService()
            let backupService = MockCloudBackupService()

            let items = TestFixtures.sampleItems

            // Simulate workflow: track event, then backup
            analyticsService.trackEvent("backup_initiated", parameters: ["item_count": items.count])
            let result = try await backupService.backup(items)

            #expect(analyticsService.trackEventCalls.count == 1)
            #expect(backupService.backupCalls.count == 1)

            if case .success = result {
                analyticsService.trackEvent("backup_completed", parameters: [:])
                #expect(analyticsService.trackEventCalls.count == 2)
            }
        }

        @Test("Service error handling coordination")
        func serviceErrorHandlingCoordination() async throws {
            let analyticsService = MockAnalyticsService()
            let backupService = MockCloudBackupService()

            // Setup backup to fail
            backupService.shouldFail = true
            backupService.error = TestError.mockError

            let items = TestFixtures.sampleItems

            analyticsService.trackEvent("backup_initiated", parameters: [:])

            do {
                _ = try await backupService.backup(items)
                Issue.record("Expected backup to fail")
            } catch {
                // Track error
                analyticsService.trackEvent("backup_failed", parameters: ["error": error.localizedDescription])
                #expect(analyticsService.trackEventCalls.count == 2)
            }
        }
    }

    // MARK: - Performance Tests

    @Suite("Service Performance")
    struct ServicePerformanceTests {
        @Test("Analytics service handles high-frequency events")
        func analyticsHighFrequencyEvents() async {
            let mockService = MockAnalyticsService()

            let (_, time) = measureTime {
                for i in 0 ..< 1000 {
                    mockService.trackEvent("high_frequency_event_\(i)", parameters: [:])
                }
            }

            #expect(time < 0.5, "Should handle 1000 events quickly")
            #expect(mockService.trackEventCalls.count == 1000)
        }

        @Test("Backup service handles large item collections")
        func backupLargeItemCollections() async throws {
            let mockService = MockCloudBackupService()

            // Create large collection of items
            let largeItemCollection = (0 ..< 1000).map { index in
                ItemBuilder()
                    .with(name: "Item \(index)")
                    .with(category: "Test Category")
                    .build()
            }

            let (result, time) = try await measureTimeAsync {
                try await mockService.backup(largeItemCollection)
            }

            #expect(time < 2.0, "Should handle large collections efficiently")
            #expect(mockService.backupCalls.count == 1)
            #expect(mockService.backupCalls.first?.items.count == 1000)
        }
    }

    // MARK: - Memory Management Tests

    @Suite("Service Memory Management")
    struct ServiceMemoryManagementTests {
        @Test("Analytics service doesn't retain items after tracking")
        func analyticsServiceMemoryManagement() async throws {
            try await withLeakDetection(
                { MockAnalyticsService() },
            ) { service in
                let item = ItemBuilder().build()
                service.trackItemAddition(item)
                // Service should not retain the item
            }
        }

        @Test("Backup service doesn't retain items after operation")
        func backupServiceMemoryManagement() async throws {
            try await withLeakDetection(
                { MockCloudBackupService() },
            ) { service in
                let items = TestFixtures.sampleItems
                _ = try await service.backup(items)
                // Service should not retain the items
            }
        }
    }

    // MARK: - Thread Safety Tests

    @Suite("Service Thread Safety")
    struct ServiceThreadSafetyTests {
        @Test("Analytics service is thread-safe")
        func analyticsServiceThreadSafety() async throws {
            let mockService = MockAnalyticsService()

            // Perform concurrent operations
            try await testConcurrentAccess(iterations: 100) {
                mockService.trackEvent("concurrent_event", parameters: [:])
                return true
            }

            #expect(mockService.trackEventCalls.count == 100)
        }

        @Test("Backup service handles concurrent access")
        func backupServiceThreadSafety() async throws {
            let mockService = MockCloudBackupService()
            let items = [TestFixtures.sampleItems.first!]

            // Perform concurrent backup operations
            let results = try await testConcurrentAccess(iterations: 50) {
                try await mockService.backup(items)
            }

            #expect(results.count == 50)
            #expect(mockService.backupCalls.count == 50)
        }
    }
}

// MARK: - Test Error Types

enum TestError: Error, Equatable {
    case mockError
    case networkError
    case dataCorruption

    var localizedDescription: String {
        switch self {
        case .mockError:
            "Mock error for testing"
        case .networkError:
            "Network connection failed"
        case .dataCorruption:
            "Data integrity check failed"
        }
    }
}

// MARK: - Mock Protocol Definitions

protocol AnalyticsServiceProtocol {
    func trackEvent(_ eventName: String, parameters: [String: Any])
    func trackItemAddition(_ item: Item)
    func trackItemUpdate(_ item: Item)
    func trackItemDeletion(_ itemId: UUID)
}

// CloudBackupServiceProtocol removed - using the actual CloudBackupService protocol from Services layer

// Note: BackupMetadata is now defined in Foundation/Models/BackupMetadata.swift

// Layer: Tests
// Module: Services
// Purpose: Sync service tests

@testable import Nestory
import XCTest

final class SyncServiceTests: XCTestCase {
    var service: TestSyncService!

    override func setUp() {
        super.setUp()
        service = TestSyncService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    func testSetupCloudKit() async throws {
        service.setupCloudKitResult = .success(())

        try await service.setupCloudKit()

        XCTAssertTrue(service.setupCloudKitCalled)
    }

    func testSyncInventory() async throws {
        let result = SyncResult(
            pushedCount: 5,
            pulledCount: 3,
            conflictsResolved: 1,
            timestamp: Date(),
        )
        service.syncInventoryResult = .success(result)

        let syncResult = try await service.syncInventory()

        XCTAssertTrue(service.syncInventoryCalled)
        XCTAssertEqual(syncResult.pushedCount, 5)
        XCTAssertEqual(syncResult.pulledCount, 3)
        XCTAssertEqual(syncResult.conflictsResolved, 1)
    }

    func testPushChanges() async throws {
        let changes = [
            SyncChange(
                recordID: "test-1",
                recordType: "Item",
                action: .create,
                fields: [:],
                timestamp: Date(),
            ),
        ]

        try await service.pushChanges(changes)

        XCTAssertTrue(service.pushChangesCalled)
        XCTAssertEqual(service.pushedChanges.count, 1)
        XCTAssertEqual(service.pushedChanges.first?.recordID, "test-1")
    }

    func testPullChanges() async throws {
        let changes = [
            SyncChange(
                recordID: "test-2",
                recordType: "Item",
                action: .update,
                fields: [:],
                timestamp: Date(),
            ),
        ]
        service.pullChangesResult = .success(changes)

        let since = Date()
        let result = try await service.pullChanges(since: since)

        XCTAssertTrue(service.pullChangesCalled)
        XCTAssertEqual(service.pullChangesSince, since)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.recordID, "test-2")
    }
}

final class ConflictResolverTests: XCTestCase {
    func testAutomaticResolver() async throws {
        let resolver = AutomaticConflictResolver()

        let conflicts = [
            SyncConflict(
                recordID: "test-1",
                localChange: SyncChange(
                    recordID: "test-1",
                    recordType: "Item",
                    action: .update,
                    fields: [:],
                    timestamp: Date().addingTimeInterval(100),
                ),
                remoteChange: SyncChange(
                    recordID: "test-1",
                    recordType: "Item",
                    action: .update,
                    fields: [:],
                    timestamp: Date(),
                ),
            ),
        ]

        let resolutions = try await resolver.resolve(conflicts)

        XCTAssertEqual(resolutions.count, 1)
        XCTAssertEqual(resolutions.first?.strategy, .useLocal)
    }

    func testManualResolver() async throws {
        let resolver = ManualConflictResolver { _ in
            .useRemote
        }

        let conflicts = [
            SyncConflict(
                recordID: "test-1",
                localChange: SyncChange(
                    recordID: "test-1",
                    recordType: "Item",
                    action: .update,
                    fields: [:],
                    timestamp: Date(),
                ),
                remoteChange: SyncChange(
                    recordID: "test-1",
                    recordType: "Item",
                    action: .update,
                    fields: [:],
                    timestamp: Date(),
                ),
            ),
        ]

        let resolutions = try await resolver.resolve(conflicts)

        XCTAssertEqual(resolutions.count, 1)
        XCTAssertEqual(resolutions.first?.strategy, .useRemote)
    }

    func testRuleBasedResolver() async throws {
        let rules = [
            RuleBasedConflictResolver.Rule.preferNewest,
        ]

        let resolver = RuleBasedConflictResolver(rules: rules)

        let conflicts = [
            SyncConflict(
                recordID: "test-1",
                localChange: SyncChange(
                    recordID: "test-1",
                    recordType: "Item",
                    action: .update,
                    fields: ["updatedAt": Date().addingTimeInterval(100)],
                    timestamp: Date().addingTimeInterval(100),
                ),
                remoteChange: SyncChange(
                    recordID: "test-1",
                    recordType: "Item",
                    action: .update,
                    fields: ["updatedAt": Date()],
                    timestamp: Date(),
                ),
            ),
        ]

        let resolutions = try await resolver.resolve(conflicts)

        XCTAssertEqual(resolutions.count, 1)
        XCTAssertEqual(resolutions.first?.strategy, .useLocal)
    }
}

final class SyncErrorTests: XCTestCase {
    func testErrorDescriptions() {
        let errors: [SyncError] = [
            .iCloudAccountUnavailable,
            .setupFailed("test"),
            .fetchFailed("test"),
            .pushFailed("test"),
            .conflictResolutionFailed("test"),
            .tooManyRetries,
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
        }
    }
}

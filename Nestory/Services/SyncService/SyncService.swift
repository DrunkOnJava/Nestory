// Layer: Services
// Module: SyncService
// Purpose: CloudKit sync with zones and subscriptions

import CloudKit
import Foundation
import os.log

public protocol SyncService {
    func setupCloudKit() async throws
    func syncInventory() async throws -> SyncResult
    func pushChanges(_ changes: [SyncChange]) async throws
    func pullChanges(since date: Date?) async throws -> [SyncChange]
    func resolveConflicts(_ conflicts: [SyncConflict]) async throws
    func createSubscription(for recordType: String) async throws
    func fetchUserRecordID() async throws -> CKRecord.ID
}

public struct LiveSyncService: SyncService {
    private let container: CKContainer
    private let database: CKDatabase
    private let zoneID: CKRecordZone.ID
    private let conflictResolver: ConflictResolver
    private let logger = Logger(subsystem: "com.nestory", category: "SyncService")

    private let retryConfig = RetryConfig(
        maxAttempts: 5,
        baseDelay: 2.0,
        maxDelay: 60.0
    )

    public init(
        containerIdentifier: String = "iCloud.com.nestory",
        conflictResolver: ConflictResolver = AutomaticConflictResolver()
    ) {
        container = CKContainer(identifier: containerIdentifier)
        database = container.privateCloudDatabase
        zoneID = CKRecordZone.ID(
            zoneName: "InventoryZone",
            ownerName: CKCurrentUserDefaultName
        )
        self.conflictResolver = conflictResolver
    }

    public func setupCloudKit() async throws {
        let signpost = OSSignposter()
        let state = signpost.beginInterval("setup_cloudkit", id: signpost.makeSignpostID())
        defer { signpost.endInterval("setup_cloudkit", state) }

        let accountStatus = try await container.accountStatus()
        guard accountStatus == .available else {
            throw SyncError.iCloudAccountUnavailable
        }

        let zone = CKRecordZone(zoneID: zoneID)
        do {
            _ = try await database.save(zone)
            logger.info("Created CloudKit zone: \(zoneID.zoneName)")
        } catch let error as CKError where error.code == .zoneNotFound {
            logger.info("Zone already exists: \(zoneID.zoneName)")
        }

        try await createSubscription(for: "Item")
        try await createSubscription(for: "Category")
    }

    public func syncInventory() async throws -> SyncResult {
        let signpost = OSSignposter()
        let state = signpost.beginInterval("sync_inventory", id: signpost.makeSignpostID())
        defer { signpost.endInterval("sync_inventory", state) }

        let lastSyncDate = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date

        async let pushResult = pushLocalChanges()
        async let pullResult = pullChanges(since: lastSyncDate)

        let (pushed, pulled) = try await (pushResult, pullResult)

        let conflicts = detectConflicts(local: pushed, remote: pulled)
        if !conflicts.isEmpty {
            try await resolveConflicts(conflicts)
        }

        UserDefaults.standard.set(Date(), forKey: "lastSyncDate")

        let result = SyncResult(
            pushedCount: pushed.count,
            pulledCount: pulled.count,
            conflictsResolved: conflicts.count,
            timestamp: Date()
        )

        logger.info("Sync completed: \(result)")
        return result
    }

    public func pushChanges(_ changes: [SyncChange]) async throws {
        guard !changes.isEmpty else { return }

        let records = changes.map { change -> CKRecord in
            let record = CKRecord(
                recordType: change.recordType,
                recordID: CKRecord.ID(recordName: change.recordID, zoneID: zoneID)
            )

            for (key, value) in change.fields {
                record[key] = value as? CKRecordValue
            }

            return record
        }

        let operation = CKModifyRecordsOperation(
            recordsToSave: records,
            recordIDsToDelete: nil
        )

        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInitiated

        try await withRetry(config: retryConfig) {
            try await database.modifyRecords(
                saving: records,
                deleting: [],
                savePolicy: .changedKeys
            )
        }

        logger.info("Pushed \(changes.count) changes to CloudKit")
    }

    public func pullChanges(since date: Date?) async throws -> [SyncChange] {
        var allChanges: [SyncChange] = []
        var cursor: CKQueryOperation.Cursor?

        repeat {
            let changes = try await fetchBatch(since: date, cursor: cursor)
            allChanges.append(contentsOf: changes.changes)
            cursor = changes.cursor
        } while cursor != nil

        logger.info("Pulled \(allChanges.count) changes from CloudKit")
        return allChanges
    }

    public func resolveConflicts(_ conflicts: [SyncConflict]) async throws {
        let resolutions = try await conflictResolver.resolve(conflicts)

        for resolution in resolutions {
            switch resolution.strategy {
            case .useLocal:
                try await pushChanges([resolution.localChange])
            case .useRemote:
                break
            case .merge:
                if let merged = resolution.mergedChange {
                    try await pushChanges([merged])
                }
            }
        }

        logger.info("Resolved \(conflicts.count) conflicts")
    }

    public func createSubscription(for recordType: String) async throws {
        let subscriptionID = "\(recordType)Subscription"

        let existingSubscriptions = try await database.allSubscriptions()
        if existingSubscriptions.contains(where: { $0.subscriptionID == subscriptionID }) {
            logger.debug("Subscription already exists for \(recordType)")
            return
        }

        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(
            recordType: recordType,
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )

        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        notification.alertBody = "Inventory updated"
        subscription.notificationInfo = notification

        _ = try await database.save(subscription)
        logger.info("Created subscription for \(recordType)")
    }

    public func fetchUserRecordID() async throws -> CKRecord.ID {
        try await container.userRecordID()
    }

    private func pushLocalChanges() async throws -> [SyncChange] {
        []
    }

    private func fetchBatch(
        since date: Date?,
        cursor: CKQueryOperation.Cursor?
    ) async throws -> (changes: [SyncChange], cursor: CKQueryOperation.Cursor?) {
        var changes: [SyncChange] = []

        let predicate = if let date {
            NSPredicate(format: "modificationDate > %@", date as NSDate)
        } else {
            NSPredicate(value: true)
        }

        let query = CKQuery(recordType: "Item", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]

        let operation = if let cursor {
            CKQueryOperation(cursor: cursor)
        } else {
            CKQueryOperation(query: query)
        }

        operation.resultsLimit = 100
        operation.qualityOfService = .userInitiated

        return try await withCheckedThrowingContinuation { continuation in
            var fetchedChanges: [SyncChange] = []

            operation.recordMatchedBlock = { _, result in
                switch result {
                case let .success(record):
                    let change = SyncChange(
                        recordID: record.recordID.recordName,
                        recordType: record.recordType,
                        action: .update,
                        fields: record.allKeys().reduce(into: [:]) { dict, key in
                            dict[key] = record[key]
                        },
                        timestamp: record.modificationDate ?? Date()
                    )
                    fetchedChanges.append(change)
                case let .failure(error):
                    logger.error("Failed to fetch record: \(error.localizedDescription)")
                }
            }

            operation.queryResultBlock = { result in
                switch result {
                case let .success(cursor):
                    continuation.resume(returning: (fetchedChanges, cursor))
                case let .failure(error):
                    continuation.resume(throwing: SyncError.fetchFailed(error.localizedDescription))
                }
            }

            database.add(operation)
        }
    }

    private func detectConflicts(local: [SyncChange], remote: [SyncChange]) -> [SyncConflict] {
        var conflicts: [SyncConflict] = []

        for localChange in local {
            if let remoteChange = remote.first(where: { $0.recordID == localChange.recordID }) {
                if localChange.timestamp != remoteChange.timestamp {
                    conflicts.append(SyncConflict(
                        recordID: localChange.recordID,
                        localChange: localChange,
                        remoteChange: remoteChange
                    ))
                }
            }
        }

        return conflicts
    }

    private func withRetry<T>(
        config: RetryConfig,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        for attempt in 0 ..< config.maxAttempts {
            do {
                return try await operation()
            } catch let error as CKError {
                if !isRetryable(error) || attempt == config.maxAttempts - 1 {
                    throw error
                }

                let delay = config.delay(for: attempt)
                logger.debug("CloudKit retry attempt \(attempt + 1) after \(delay)s")

                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }

        throw SyncError.tooManyRetries
    }

    private func isRetryable(_ error: CKError) -> Bool {
        switch error.code {
        case .networkFailure, .networkUnavailable, .requestRateLimited, .serviceUnavailable:
            true
        default:
            false
        }
    }
}

public struct SyncResult {
    public let pushedCount: Int
    public let pulledCount: Int
    public let conflictsResolved: Int
    public let timestamp: Date
}

public struct SyncChange {
    public let recordID: String
    public let recordType: String
    public let action: SyncAction
    public let fields: [String: Any]
    public let timestamp: Date
}

public enum SyncAction {
    case create
    case update
    case delete
}

public struct SyncConflict {
    public let recordID: String
    public let localChange: SyncChange
    public let remoteChange: SyncChange
}

public enum SyncError: LocalizedError {
    case iCloudAccountUnavailable
    case setupFailed(String)
    case fetchFailed(String)
    case pushFailed(String)
    case conflictResolutionFailed(String)
    case tooManyRetries

    public var errorDescription: String? {
        switch self {
        case .iCloudAccountUnavailable:
            "iCloud account is not available"
        case let .setupFailed(reason):
            "CloudKit setup failed: \(reason)"
        case let .fetchFailed(reason):
            "Failed to fetch changes: \(reason)"
        case let .pushFailed(reason):
            "Failed to push changes: \(reason)"
        case let .conflictResolutionFailed(reason):
            "Conflict resolution failed: \(reason)"
        case .tooManyRetries:
            "Operation failed after maximum retry attempts"
        }
    }
}

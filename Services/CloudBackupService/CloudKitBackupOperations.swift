//
// Layer: Services
// Module: CloudBackup
// Purpose: CloudKit backup and restore operations
//

import CloudKit
import Foundation

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with CloudKit - Already using CloudKit but could leverage CKSyncEngine for automatic sync management

public struct CloudKitBackupOperations: @unchecked Sendable {
    private let privateDatabase: CKDatabase
    private let backupZone: CKRecordZone

    public init(database: CKDatabase, zone: CKRecordZone) {
        privateDatabase = database
        backupZone = zone
    }

    // MARK: - Zone Management

    public func createBackupZone() async throws {
        do {
            _ = try await privateDatabase.save(backupZone)
        } catch {
            // Zone might already exist, which is fine
            if !error.localizedDescription.contains("Duplicate") {
                throw error
            }
        }
    }

    // MARK: - Cleanup Operations

    public func clearPreviousBackup() async {
        let query = CKQuery(recordType: "BackupItem", predicate: NSPredicate(value: true))

        do {
            let results = try await privateDatabase.records(
                matching: query,
                inZoneWith: backupZone.zoneID,
                desiredKeys: nil,
                resultsLimit: CKQueryOperation.maximumResults,
            )

            for (recordID, _) in results.matchResults {
                _ = try? await privateDatabase.deleteRecord(withID: recordID)
            }
        } catch {
            // Ignore errors during cleanup
        }
    }

    // MARK: - Save Operations

    public func saveRecord(_ record: CKRecord) async throws {
        _ = try await privateDatabase.save(record)
    }

    public func saveRecords(_ records: [CKRecord]) async throws {
        for record in records {
            _ = try await privateDatabase.save(record)
        }
    }

    // MARK: - Fetch Operations

    public func fetchRecords(
        recordType: String,
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int = CKQueryOperation.maximumResults,
    ) async throws -> [(CKRecord.ID, Result<CKRecord, Error>)] {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        query.sortDescriptors = sortDescriptors

        let results = try await privateDatabase.records(
            matching: query,
            inZoneWith: backupZone.zoneID,
            desiredKeys: nil,
            resultsLimit: limit,
        )

        return results.matchResults
    }

    // MARK: - Metadata Operations

    public func saveBackupMetadata(itemCount: Int, deviceName: String, appVersion: String) async throws {
        let recordID = CKRecord.ID(zoneID: backupZone.zoneID)
        let record = CKRecord(recordType: "BackupMetadata", recordID: recordID)
        record["date"] = Date()
        record["itemCount"] = itemCount
        record["deviceName"] = deviceName
        record["appVersion"] = appVersion
        _ = try await privateDatabase.save(record)
    }

    public func fetchBackupMetadata() async throws -> CKRecord? {
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let results = try await fetchRecords(
            recordType: "BackupMetadata",
            sortDescriptors: sortDescriptors,
            limit: 1,
        )

        guard let (_, result) = results.first,
              case let .success(record) = result
        else {
            return nil
        }

        return record
    }

    // MARK: - Delete Operations

    public func deleteRecord(withID recordID: CKRecord.ID) async throws {
        _ = try await privateDatabase.deleteRecord(withID: recordID)
    }
}

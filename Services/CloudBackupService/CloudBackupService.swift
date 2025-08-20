//
// Layer: Services
// Module: CloudBackupService
// Purpose: Protocol-first CloudKit backup service for data backup and restore
//

import Foundation
import SwiftData

/// Protocol defining cloud backup capabilities for inventory data
@MainActor
public protocol CloudBackupService: AnyObject {
    // MARK: - Published Properties

    var isBackingUp: Bool { get }
    var isRestoring: Bool { get }
    var lastBackupDate: Date? { get }
    var backupStatus: BackupStatus { get }
    var errorMessage: String? { get }
    var progress: Double { get }
    var isCloudKitAvailable: Bool { get }

    // MARK: - CloudKit Management

    func checkCloudKitAvailability() async -> Bool

    // MARK: - Backup Operations

    func performBackup(items: [Item], categories: [Category], rooms: [Room]) async throws
    func estimateBackupSize(items: [Item]) -> String
    func getBackupInfo() async throws -> BackupMetadata?

    // MARK: - Restore Operations

    func performRestore(modelContext: ModelContext) async throws -> RestoreResult
}

//
// Layer: Services
// Module: CloudBackup
// Purpose: Data models for CloudKit backup service
//

import Foundation

// MARK: - Backup Status

public enum BackupStatus: Equatable {
    case idle
    case backing(BackupPhase)
    case restoring(RestorePhase)
    case completed
    case failed

    public enum BackupPhase: String {
        case preparing = "Preparing backup..."
        case clearing = "Clearing previous backup..."
        case categories = "Backing up categories..."
        case rooms = "Backing up rooms..."
        case items = "Backing up items..."
        case metadata = "Saving metadata..."
    }

    public enum RestorePhase: String {
        case preparing = "Preparing restore..."
        case categories = "Restoring categories..."
        case rooms = "Restoring rooms..."
        case items = "Restoring items..."
    }
}

// MARK: - Backup Metadata

public struct BackupMetadata {
    public let date: Date
    public let itemCount: Int
    public let deviceName: String

    public init(date: Date, itemCount: Int, deviceName: String) {
        self.date = date
        self.itemCount = itemCount
        self.deviceName = deviceName
    }
}

// MARK: - Restore Result

public struct RestoreResult {
    public let itemsRestored: Int
    public let categoriesRestored: Int
    public let roomsRestored: Int
    public let backupDate: Date

    public init(
        itemsRestored: Int,
        categoriesRestored: Int,
        roomsRestored: Int,
        backupDate: Date
    ) {
        self.itemsRestored = itemsRestored
        self.categoriesRestored = categoriesRestored
        self.roomsRestored = roomsRestored
        self.backupDate = backupDate
    }
}

// MARK: - Backup Errors

public enum BackupError: LocalizedError {
    case iCloudUnavailable
    case notInitialized
    case noBackupFound
    case backupFailed(String)
    case restoreFailed(String)

    public var errorDescription: String? {
        switch self {
        case .iCloudUnavailable:
            "iCloud is not available. Please check your iCloud settings."
        case .notInitialized:
            "CloudKit backup service is not initialized. This may be due to missing entitlements."
        case .noBackupFound:
            "No backup found in iCloud."
        case let .backupFailed(reason):
            "Backup failed: \(reason)"
        case let .restoreFailed(reason):
            "Restore failed: \(reason)"
        }
    }
}

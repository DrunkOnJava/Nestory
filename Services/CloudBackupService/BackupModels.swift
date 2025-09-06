//
// Layer: Services
// Module: CloudBackup
// Purpose: Data models for CloudKit backup service
//

import Foundation
import SwiftUI

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
        case items = "Backing up items..."
        case metadata = "Saving metadata..."
    }

    public enum RestorePhase: String {
        case preparing = "Preparing restore..."
        case categories = "Restoring categories..."
        case items = "Restoring items..."
    }
    
    public var iconName: String {
        switch self {
        case .idle: "circle"
        case .backing: "arrow.up.circle"
        case .restoring: "arrow.down.circle"
        case .completed: "checkmark.circle"
        case .failed: "xmark.circle"
        }
    }
    
    public var color: Color {
        switch self {
        case .idle: .gray
        case .backing: .blue
        case .restoring: .orange
        case .completed: .green
        case .failed: .red
        }
    }
    
    public var displayName: String {
        switch self {
        case .idle: "Idle"
        case .backing(let phase): phase.rawValue
        case .restoring(let phase): phase.rawValue
        case .completed: "Completed"
        case .failed: "Failed"
        }
    }
}

// MARK: - Backup Metadata

// Note: BackupMetadata is now defined in Foundation/Models/BackupMetadata.swift

// MARK: - Restore Result

public struct RestoreResult {
    public let itemsRestored: Int
    public let categoriesRestored: Int
    public let backupDate: Date

    public init(
        itemsRestored: Int,
        categoriesRestored: Int,
        backupDate: Date
    ) {
        self.itemsRestored = itemsRestored
        self.categoriesRestored = categoriesRestored
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

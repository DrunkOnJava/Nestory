//
// Layer: Services
// Module: CloudBackup
// Purpose: CloudKit backup service coordinator - Main service orchestrator
//
// REMINDER: This service MUST be wired up in SettingsView for user access

import CloudKit
import Foundation
import SwiftData
import UIKit

@MainActor
public final class CloudBackupService: ObservableObject {
    @Published public var isBackingUp = false
    @Published public var isRestoring = false
    @Published public var lastBackupDate: Date?
    @Published public var backupStatus: BackupStatus = .idle
    @Published public var errorMessage: String?
    @Published public var progress: Double = 0.0
    @Published public var isCloudKitAvailable = false

    private var container: CKContainer?
    private var privateDatabase: CKDatabase?
    private let backupZone = CKRecordZone(zoneName: "NestoryBackup")

    private var operations: CloudKitBackupOperations?
    private var backupTransformer: BackupDataTransformer?
    private var restoreTransformer: RestoreDataTransformer?
    private var assetManager: CloudKitAssetManager?

    public init() {
        // Defer CloudKit initialization to avoid crash when not configured
        Task { @MainActor in
            await initializeCloudKitIfAvailable()
        }
    }
    
    @MainActor
    private func initializeCloudKitIfAvailable() async {
        do {
            // Use specific container identifier to avoid crash
            let testContainer = CKContainer(identifier: "iCloud.com.nestory.app")
            let status = try await testContainer.accountStatus()
            
            if status == .available {
                self.container = testContainer
                self.privateDatabase = testContainer.privateCloudDatabase
                
                self.assetManager = CloudKitAssetManager()
                self.operations = CloudKitBackupOperations(database: privateDatabase!, zone: backupZone)
                self.backupTransformer = BackupDataTransformer(zone: backupZone, assetManager: assetManager!)
                self.restoreTransformer = RestoreDataTransformer(assetManager: assetManager!)
                self.isCloudKitAvailable = true
            } else {
                self.isCloudKitAvailable = false
                self.errorMessage = "iCloud not available: \(status)"
            }
        } catch {
            self.isCloudKitAvailable = false
            self.errorMessage = "CloudKit not configured for this build"
            // This is expected in development/TestFlight builds without CloudKit entitlements
        }
    }

    // MARK: - Account Status

    public func checkCloudKitAvailability() async -> Bool {
        guard let container = container else {
            errorMessage = "CloudKit not initialized"
            return false
        }
        
        do {
            let status = try await container.accountStatus()
            switch status {
            case .available:
                return true
            case .noAccount:
                errorMessage = "No iCloud account. Please sign in to iCloud in Settings."
                return false
            case .restricted:
                errorMessage = "iCloud is restricted on this device."
                return false
            case .couldNotDetermine:
                errorMessage = "Could not determine iCloud status."
                return false
            case .temporarilyUnavailable:
                errorMessage = "iCloud is temporarily unavailable."
                return false
            @unknown default:
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Backup Operations

    public func performBackup(items: [Item], categories: [Category], rooms: [Room]) async throws {
        guard await checkCloudKitAvailability() else {
            throw BackupError.iCloudUnavailable
        }
        
        guard let operations = operations,
              let backupTransformer = backupTransformer,
              let assetManager = assetManager else {
            throw BackupError.notInitialized
        }

        isBackingUp = true
        backupStatus = .backing(.preparing)
        progress = 0.0

        defer {
            isBackingUp = false
            if backupStatus != .failed {
                backupStatus = .idle
            }
            assetManager.cleanupTemporaryFiles()
        }

        // Create backup zone if needed
        try await operations.createBackupZone()

        // Clear previous backup
        backupStatus = .backing(.clearing)
        progress = 0.1
        await operations.clearPreviousBackup()

        // Backup categories
        backupStatus = .backing(.categories)
        progress = 0.2
        let categoryRecords = backupTransformer.transformCategories(categories)
        try await operations.saveRecords(categoryRecords)

        // Backup rooms
        backupStatus = .backing(.rooms)
        progress = 0.3
        let roomRecords = backupTransformer.transformRooms(rooms)
        try await operations.saveRecords(roomRecords)

        // Backup items with progress
        backupStatus = .backing(.items)
        let totalItems = items.count
        for (index, item) in items.enumerated() {
            let record = try await backupTransformer.transformItem(item)
            try await operations.saveRecord(record)
            progress = 0.3 + (0.6 * Double(index + 1) / Double(totalItems))
        }

        // Save backup metadata
        backupStatus = .backing(.metadata)
        progress = 0.9
        try await operations.saveBackupMetadata(
            itemCount: items.count,
            deviceName: UIDevice.current.name,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
        )

        lastBackupDate = Date()
        backupStatus = .completed
        progress = 1.0
    }

    // MARK: - Restore Operations

    public func performRestore(modelContext: ModelContext) async throws -> RestoreResult {
        guard await checkCloudKitAvailability() else {
            throw BackupError.iCloudUnavailable
        }
        
        guard let operations = operations,
              let restoreTransformer = restoreTransformer,
              let assetManager = assetManager else {
            throw BackupError.notInitialized
        }

        isRestoring = true
        backupStatus = .restoring(.preparing)
        progress = 0.0

        defer {
            isRestoring = false
            if backupStatus != .failed {
                backupStatus = .idle
            }
            assetManager.cleanupTemporaryFiles()
        }

        // Check for existing backup
        guard let metadataRecord = try await operations.fetchBackupMetadata() else {
            throw BackupError.noBackupFound
        }

        let metadata = BackupMetadata(
            date: metadataRecord["date"] as? Date ?? Date(),
            itemCount: metadataRecord["itemCount"] as? Int ?? 0,
            deviceName: metadataRecord["deviceName"] as? String ?? "Unknown",
        )

        // Restore categories
        backupStatus = .restoring(.categories)
        progress = 0.2
        let categoryRecords = try await operations.fetchRecords(recordType: "BackupCategory")
        let categories = restoreTransformer.restoreCategories(from: categoryRecords, modelContext: modelContext)

        // Restore rooms
        backupStatus = .restoring(.rooms)
        progress = 0.3
        let roomRecords = try await operations.fetchRecords(recordType: "BackupRoom")
        let rooms = restoreTransformer.restoreRooms(from: roomRecords, modelContext: modelContext)

        // Restore items
        backupStatus = .restoring(.items)
        let itemRecords = try await operations.fetchRecords(recordType: "BackupItem")
        let items = try await restoreTransformer.restoreItems(
            from: itemRecords,
            modelContext: modelContext,
        ) { [weak self] itemProgress in
            Task { @MainActor in
                self?.progress = 0.3 + (0.6 * itemProgress)
            }
        }

        backupStatus = .completed
        progress = 1.0

        return RestoreResult(
            itemsRestored: items.count,
            categoriesRestored: categories.count,
            roomsRestored: rooms.count,
            backupDate: metadata.date,
        )
    }

    // MARK: - Utility Methods

    public func getBackupInfo() async throws -> BackupMetadata? {
        guard await checkCloudKitAvailability() else {
            return nil
        }

        guard let record = try await operations.fetchBackupMetadata() else {
            return nil
        }

        return BackupMetadata(
            date: record["date"] as? Date ?? Date(),
            itemCount: record["itemCount"] as? Int ?? 0,
            deviceName: record["deviceName"] as? String ?? "Unknown",
        )
    }

    public func estimateBackupSize(items: [Item]) -> String {
        let totalSize = assetManager.totalAssetSize(for: items)
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(totalSize))
    }
}

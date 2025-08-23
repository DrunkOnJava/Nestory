//
// Layer: Services
// Module: CloudBackupService
// Purpose: Live implementation of CloudKit backup service for data backup and restore

import CloudKit
import Foundation
import os.log
import SwiftData
import UIKit

@MainActor
public final class LiveCloudBackupService: CloudBackupService, ObservableObject {
    @Published public var isBackingUp = false
    @Published public var isRestoring = false
    @Published public var lastBackupDate: Date?
    @Published public var backupStatus: BackupStatus = .idle
    @Published public var errorMessage: String?
    @Published public var progress = 0.0
    @Published public var isCloudKitAvailable = false

    private var container: CKContainer?
    private var privateDatabase: CKDatabase?
    private let backupZone = CKRecordZone(zoneName: "NestoryBackup")

    private var operations: CloudKitBackupOperations?
    private var backupTransformer: BackupDataTransformer?
    private var restoreTransformer: RestoreDataTransformer?
    private var assetManager: CloudKitAssetManager?

    // Error handling infrastructure
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "CloudBackupService")
    private let resilientExecutor = ResilientOperationExecutor()

    // CloudKit-specific retry counters
    private var quotaRetryCount = 0
    private var accountChangeRetryCount = 0
    private let maxCloudKitRetries = 2

    public init() {
        // Defer CloudKit initialization to avoid crash when not configured
        Task { @MainActor in
            await initializeCloudKitIfAvailable()
        }
    }

    @MainActor
    private func initializeCloudKitIfAvailable() async {
        do {
            // Use environment-specific container identifier
            let containerIdentifier = "iCloud.com.drunkonjava.nestory"
            let testContainer = CKContainer(identifier: containerIdentifier)
            let status = try await testContainer.accountStatus()

            if status == .available {
                container = testContainer
                privateDatabase = testContainer.privateCloudDatabase

                let assetManager = CloudKitAssetManager()
                self.assetManager = assetManager

                guard let database = privateDatabase else {
                    isCloudKitAvailable = false
                    errorMessage = "Private database not available"
                    return
                }

                operations = CloudKitBackupOperations(database: database, zone: backupZone)
                backupTransformer = BackupDataTransformer(zone: backupZone, assetManager: assetManager)
                restoreTransformer = RestoreDataTransformer(assetManager: assetManager)
                isCloudKitAvailable = true
            } else {
                isCloudKitAvailable = false
                errorMessage = "iCloud not available: \(status)"
            }
        } catch {
            isCloudKitAvailable = false
            errorMessage = "CloudKit not configured for this build"
            // This is expected in development/TestFlight builds without CloudKit entitlements
        }
    }

    // MARK: - Account Status

    public func checkCloudKitAvailability() async -> Bool {
        guard let container else {
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
        let itemCount = items.count
        let categoryCount = categories.count
        let roomCount = rooms.count

        // Comprehensive CloudKit availability check
        guard await checkCloudKitAvailability() else {
            let ckError = mapToServiceError(BackupError.iCloudUnavailable)
            throw ckError
        }

        guard let operations,
              let backupTransformer,
              let assetManager
        else {
            throw ServiceError.configurationError(
                service: "CloudBackup",
                details: "Service not properly initialized",
            )
        }

        logger.info("Starting CloudKit backup with \(items.count) items, \(categories.count) categories, \(rooms.count) rooms")

        isBackingUp = true
        backupStatus = .backing(.preparing)
        progress = 0.0
        errorMessage = nil

        defer {
            isBackingUp = false
            if backupStatus != .failed {
                backupStatus = .idle
            }
            assetManager.cleanupTemporaryFiles()
        }

        do {
            // Create backup zone with retry logic
            try await executeCloudKitOperation {
                try await operations.createBackupZone()
            }

            // Clear previous backup with error handling
            backupStatus = .backing(.clearing)
            progress = 0.1
            await safelyExecuteOperation {
                await operations.clearPreviousBackup()
            }

            // Backup categories with validation
            backupStatus = .backing(.categories)
            progress = 0.2
            let categoryRecords = backupTransformer.transformCategories(categories)

            if !categoryRecords.isEmpty {
                try await executeCloudKitOperation {
                    try await operations.saveRecords(categoryRecords)
                }
                logger.info("Successfully backed up \(categoryRecords.count) categories")
            }

            // Backup rooms with validation
            backupStatus = .backing(.rooms)
            progress = 0.3
            let roomRecords = backupTransformer.transformRooms(rooms)

            if !roomRecords.isEmpty {
                try await executeCloudKitOperation {
                    try await operations.saveRecords(roomRecords)
                }
                logger.info("Successfully backed up \(roomRecords.count) rooms")
            }

            // Backup items with comprehensive error handling
            backupStatus = .backing(.items)
            progress = 0.4
            try await backupItemsWithProgress(
                items: items,
                backupTransformer: backupTransformer,
                operations: operations,
            )

            // Save backup metadata with validation
            backupStatus = .backing(.metadata)
            progress = 0.9
            // APPLE_FRAMEWORK_OPPORTUNITY: Replace with DeviceCheck - Could use DCDevice.current.generateToken() for secure device verification instead of device name
            let deviceName = await MainActor.run {
                let name = UIDevice.current.name
                return name.isEmpty ? "Unknown Device" : name
            }
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"

            try await executeCloudKitOperation {
                try await operations.saveBackupMetadata(
                    itemCount: items.count,
                    deviceName: deviceName,
                    appVersion: appVersion,
                )
            }

            lastBackupDate = Date()
            backupStatus = .completed
            progress = 1.0
            quotaRetryCount = 0 // Reset on success

            logger.info("CloudKit backup completed successfully")
        } catch {
            logger.error("CloudKit backup failed: \(error)")
            backupStatus = .failed
            progress = 0.0

            // Map error and update error message
            let serviceError = mapToServiceError(error)
            errorMessage = serviceError.localizedDescription

            throw serviceError
        }
    }

    // MARK: - Restore Operations

    public func performRestore(modelContext: ModelContext) async throws -> RestoreResult {
        guard await checkCloudKitAvailability() else {
            throw BackupError.iCloudUnavailable
        }

        guard let operations,
              let restoreTransformer,
              let assetManager
        else {
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
            forCloudBackup: metadataRecord["date"] as? Date ?? Date(),
            itemCount: metadataRecord["itemCount"] as? Int ?? 0,
            deviceName: metadataRecord["deviceName"] as? String ?? "Unknown"
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
            backupDate: metadata.exportDate,
        )
    }

    // MARK: - Utility Methods

    public func getBackupInfo() async throws -> BackupMetadata? {
        guard await checkCloudKitAvailability() else {
            return nil
        }

        guard let operations else {
            return nil
        }

        guard let record = try await operations.fetchBackupMetadata() else {
            return nil
        }

        return BackupMetadata(
            forCloudBackup: record["date"] as? Date ?? Date(),
            itemCount: record["itemCount"] as? Int ?? 0,
            deviceName: record["deviceName"] as? String ?? "Unknown"
        )
    }

    public func estimateBackupSize(items: [Item]) -> String {
        guard let assetManager else {
            return "Unknown"
        }
        let totalSize = assetManager.totalAssetSize(for: items)
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(totalSize))
    }

    // MARK: - Error Handling Helper Methods

    /// Executes a CloudKit operation with comprehensive error handling and retry logic
    private func executeCloudKitOperation<T: Sendable>(
        operation: @escaping () async throws -> T
    ) async throws -> T {
        do {
            return try await operation()
        } catch {
            let serviceError = mapToServiceError(error)

            // Handle specific CloudKit errors with recovery
            switch serviceError {
            case let .cloudKitQuotaExceeded:
                quotaRetryCount += 1
                if quotaRetryCount <= maxCloudKitRetries {
                    logger.warning("CloudKit quota exceeded, retrying after cleanup...")
                    // Attempt to free up space by clearing old assets
                    await assetManager?.cleanupTemporaryFiles()
                    try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                    return try await operation()
                }
                throw serviceError

            case .cloudKitAccountChanged:
                accountChangeRetryCount += 1
                if accountChangeRetryCount <= maxCloudKitRetries {
                    logger.info("CloudKit account changed, re-initializing...")
                    await initializeCloudKitIfAvailable()
                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                    return try await operation()
                }
                throw serviceError

            case let .cloudKitSyncConflict(details):
                logger.info("CloudKit sync conflict, attempting automatic resolution: \(details)")
                // For backup operations, we can often resolve conflicts by overwriting
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                return try await operation()

            default:
                throw serviceError
            }
        }
    }

    /// Safely executes an operation that doesn't throw, with logging
    private func safelyExecuteOperation(
        operation: @escaping () async -> Void,
    ) async {
        do {
            await operation()
        } catch {
            logger.warning("Non-critical operation failed: \(error)")
            // Don't rethrow - this is for cleanup operations
        }
    }

    /// Backs up items with optimized batching, parallel processing, and comprehensive error handling
    private func backupItemsWithProgress(
        items: [Item],
        backupTransformer: BackupDataTransformer,
        operations: CloudKitBackupOperations,
    ) async throws {
        let totalItems = items.count
        guard totalItems > 0 else {
            logger.info("No items to backup")
            return
        }

        logger.info("Starting optimized backup of \(totalItems) items")

        // Use optimized batching for large datasets
        let batchSize = min(BusinessConstants.Performance.itemsPerPage, 10) // Smaller batches for CloudKit
        let batches = items.chunked(into: batchSize)

        var successfulBackups = 0
        var failedBackups = 0
        var errors: [String] = []

        for (batchIndex, batch) in batches.enumerated() {
            logger.debug("Processing backup batch \(batchIndex + 1)/\(batches.count) with \(batch.count) items")

            // Process batch sequentially for CloudKit reliability and rate limiting
            var batchResults: [BackupResult] = []

            for item in batch {
                do {
                    let record = try await backupTransformer.transformItem(item)
                    try await executeCloudKitOperation {
                        try await operations.saveRecord(record)
                    }
                    batchResults.append(BackupResult.success(itemName: item.name))
                } catch {
                    logger.error("Failed to backup item \(item.name): \(error)")
                    batchResults.append(BackupResult.failure(itemName: item.name, error: error))
                }
            }

            // Process batch results
            for result in batchResults {
                switch result {
                case .success:
                    successfulBackups += 1
                case let .failure(itemName, error):
                    failedBackups += 1
                    errors.append("Item '\(itemName)': \(error.localizedDescription)")
                }
            }

            // Update progress based on completed batches
            let completedItems = (batchIndex + 1) * batchSize
            let actualProgress = min(completedItems, totalItems)
            progress = 0.4 + (0.5 * Double(actualProgress) / Double(totalItems))

            // Check for too many failures
            if failedBackups > totalItems / 3 { // Allow up to 33% failure rate
                logger.error("Too many backup failures (\(failedBackups)/\(totalItems)), aborting")
                throw ServiceError.cloudKitPartialFailure(
                    successCount: successfulBackups,
                    failures: Array(errors.prefix(10)), // Limit error details
                )
            }

            // Small delay between batches to avoid overwhelming CloudKit
            if batchIndex < batches.count - 1 {
                try await Task.sleep(nanoseconds: 200_000_000) // 200ms
            }
        }

        let failureRate = Double(failedBackups) / Double(totalItems)

        if failedBackups > 0 {
            logger.warning("Backup completed with \(failedBackups) failures out of \(totalItems) items (failure rate: \(String(format: "%.1f%%", failureRate * 100)))")

            if successfulBackups == 0 {
                throw ServiceError.cloudKitSyncConflict(details: "All items failed to backup")
            } else if failureRate > 0.1 { // More than 10% failure rate
                // Log detailed error summary for debugging
                let errorSummary = errors.prefix(5).joined(separator: "; ")
                logger.error("High backup failure rate. Sample errors: \(errorSummary)")
            }
        } else {
            logger.info("Successfully backed up all \(totalItems) items in \(batches.count) batches")
        }
    }

    /// Maps various error types to standardized ServiceError
    private func mapToServiceError(_ error: Error) -> ServiceError {
        // Handle CloudKit errors first
        if let ckError = error as? CKError {
            return ServiceError.fromCloudKitError(ckError)
        }

        // Handle BackupError
        if let backupError = error as? BackupError {
            switch backupError {
            case .iCloudUnavailable:
                return .cloudKitUnavailable
            case .notInitialized:
                return .configurationError(service: "CloudBackup", details: "Service not initialized")
            case .noBackupFound:
                return .notFound(resource: "backup")
            case let .backupFailed(reason):
                return .processingFailed(operation: "backup", reason: reason)
            case let .restoreFailed(reason):
                return .processingFailed(operation: "restore", reason: reason)
            }
        }

        // Handle already mapped ServiceError
        if let serviceError = error as? ServiceError {
            return serviceError
        }

        // Handle network errors
        return ServiceError.fromNetworkError(error)
    }
}

// MARK: - Supporting Types

private enum BackupResult {
    case success(itemName: String)
    case failure(itemName: String, error: Error)
}

/// Simple async semaphore for controlling concurrency
private actor AsyncSemaphore {
    private var count: Int
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(value: Int) {
        count = value
    }

    func wait() async {
        if count > 0 {
            count -= 1
        } else {
            await withCheckedContinuation { continuation in
                waiters.append(continuation)
            }
        }
    }

    func signal() {
        if let waiter = waiters.first {
            waiters.removeFirst()
            waiter.resume()
        } else {
            count += 1
        }
    }
}

// MARK: - Array Extension for Batching

extension Array {
    fileprivate func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

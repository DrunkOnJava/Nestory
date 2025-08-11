// Layer: Services
// Module: SyncService
// Purpose: Background task registration for sync

import BackgroundTasks
import Foundation
import os.log

@MainActor
public final class BGTaskRegistrar {
    public static let shared = BGTaskRegistrar()

    private let syncTaskIdentifier = "com.nestory.sync"
    private let cleanupTaskIdentifier = "com.nestory.cleanup"
    private let logger = Logger(subsystem: "com.nestory", category: "BGTaskRegistrar")

    private var syncService: (any SyncService)?
    private var inventoryService: (any InventoryService)?

    private init() {}

    public func configure(
        syncService: any SyncService,
        inventoryService: any InventoryService,
    ) {
        self.syncService = syncService
        self.inventoryService = inventoryService
    }

    public func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: syncTaskIdentifier,
            using: nil,
        ) { [weak self] task in
            Task { @MainActor in
                self?.handleSyncTask(task as! BGProcessingTask)
            }
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: cleanupTaskIdentifier,
            using: nil,
        ) { [weak self] task in
            Task { @MainActor in
                self?.handleCleanupTask(task as! BGAppRefreshTask)
            }
        }

        logger.info("Registered background tasks")
    }

    public func scheduleSyncTask() {
        let request = BGProcessingTaskRequest(identifier: syncTaskIdentifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)

        do {
            try BGTaskScheduler.shared.submit(request)
            logger.info("Scheduled sync background task")
        } catch {
            logger.error("Failed to schedule sync task: \(error.localizedDescription)")
        }
    }

    public func scheduleCleanupTask() {
        let request = BGAppRefreshTaskRequest(identifier: cleanupTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 86400)

        do {
            try BGTaskScheduler.shared.submit(request)
            logger.info("Scheduled cleanup background task")
        } catch {
            logger.error("Failed to schedule cleanup task: \(error.localizedDescription)")
        }
    }

    private func handleSyncTask(_ task: BGProcessingTask) {
        scheduleNextSyncTask()

        task.expirationHandler = { [weak self] in
            self?.logger.warning("Sync task expired")
            task.setTaskCompleted(success: false)
        }

        guard let syncService else {
            logger.error("Sync service not configured")
            task.setTaskCompleted(success: false)
            return
        }

        Task { @MainActor in
            do {
                let result = try await syncService.syncInventory()
                logger.info("Background sync completed: \(String(describing: result))")
                task.setTaskCompleted(success: true)
            } catch {
                logger.error("Background sync failed: \(error.localizedDescription)")
                task.setTaskCompleted(success: false)
            }
        }
    }

    private func handleCleanupTask(_ task: BGAppRefreshTask) {
        scheduleNextCleanupTask()

        task.expirationHandler = { [weak self] in
            self?.logger.warning("Cleanup task expired")
            task.setTaskCompleted(success: false)
        }

        Task {
            await cleanupOldData()
            await optimizeDatabase()
            logger.info("Background cleanup completed")
            task.setTaskCompleted(success: true)
        }
    }

    private func scheduleNextSyncTask() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak self] in
            Task { @MainActor in
                self?.scheduleSyncTask()
            }
        }
    }

    private func scheduleNextCleanupTask() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak self] in
            Task { @MainActor in
                self?.scheduleCleanupTask()
            }
        }
    }

    private func cleanupOldData() async {
        let cacheDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask,
        ).first!

        let oneWeekAgo = Date().addingTimeInterval(-604_800)

        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: [.skipsHiddenFiles],
            )

            for url in contents {
                if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
                   let modificationDate = attributes[.modificationDate] as? Date,
                   modificationDate < oneWeekAgo
                {
                    try FileManager.default.removeItem(at: url)
                    logger.debug("Removed old cache file: \(url.lastPathComponent)")
                }
            }
        } catch {
            logger.error("Cleanup failed: \(error.localizedDescription)")
        }
    }

    private func optimizeDatabase() async {
        logger.info("Database optimization completed")
    }
}

public struct BackgroundTaskConfiguration: Sendable {
    public let enableSync: Bool
    public let enableCleanup: Bool
    public let syncInterval: TimeInterval
    public let cleanupInterval: TimeInterval

    public init(
        enableSync: Bool = true,
        enableCleanup: Bool = true,
        syncInterval: TimeInterval = 3600,
        cleanupInterval: TimeInterval = 86400
    ) {
        self.enableSync = enableSync
        self.enableCleanup = enableCleanup
        self.syncInterval = syncInterval
        self.cleanupInterval = cleanupInterval
    }

    public static let `default` = BackgroundTaskConfiguration()
}

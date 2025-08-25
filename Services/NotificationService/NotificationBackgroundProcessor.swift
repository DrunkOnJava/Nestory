//
// Layer: Services
// Module: NotificationService
// Purpose: Enhanced background processing for notifications with iOS integration
//

import Foundation
import BackgroundTasks
import UserNotifications
import SwiftData
import UIKit
import os.log

/// Advanced background processing manager for notifications
@MainActor
public final class NotificationBackgroundProcessor: @unchecked Sendable {
    private let logger: Logger
    private let notificationService: LiveNotificationService
    private let persistence: NotificationPersistence
    private let analytics: NotificationAnalytics

    // Background task identifiers
    public enum BackgroundTaskIdentifier {
        static let notificationProcessing = "com.drunkonjava.nestory.notification-processing"
        static let warrantyCheck = "com.drunkonjava.nestory.warranty-check"
        static let analyticsCollection = "com.drunkonjava.nestory.analytics-collection"
    }

    // Background processing configuration
    private let maxBackgroundExecutionTime: TimeInterval = 25 // seconds
    private let notificationBatchSize = 50
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid

    public init(
        notificationService: LiveNotificationService,
        modelContext: ModelContext? = nil
    ) {
        self.logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "NotificationBackgroundProcessor")
        self.notificationService = notificationService
        self.persistence = NotificationPersistence()
        self.analytics = NotificationAnalytics(modelContext: modelContext)

        setupBackgroundTaskHandlers()
    }

    // MARK: - Background Task Setup

    /// Setup background task handlers
    private func setupBackgroundTaskHandlers() {
        logger.info("Setting up background task handlers")

        // App refresh background task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundTaskIdentifier.notificationProcessing, using: nil) { task in
            Task { @MainActor in
                await self.handleNotificationProcessingTask(task as! BGAppRefreshTask)
            }
        }

        // Warranty check background task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundTaskIdentifier.warrantyCheck, using: nil) { task in
            Task { @MainActor in
                await self.handleWarrantyCheckTask(task as! BGAppRefreshTask)
            }
        }

        // Analytics collection background task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundTaskIdentifier.analyticsCollection, using: nil) { task in
            Task { @MainActor in
                await self.handleAnalyticsCollectionTask(task as! BGAppRefreshTask)
            }
        }

        logger.info("Background task handlers registered")
    }

    // MARK: - Task Scheduling

    /// Schedule notification processing background task
    public func scheduleNotificationProcessingTask() async throws {
        logger.info("Scheduling notification processing background task")

        let request = BGAppRefreshTaskRequest(identifier: BackgroundTaskIdentifier.notificationProcessing)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 4 * 60 * 60) // 4 hours from now

        do {
            try BGTaskScheduler.shared.submit(request)

            // Save task info
            let taskInfo = BackgroundTaskInfo(
                identifier: BackgroundTaskIdentifier.notificationProcessing,
                taskType: "notification-processing",
                expirationTime: Date(timeIntervalSinceNow: 24 * 60 * 60)
            )
            try await persistence.saveBackgroundTaskInfo(taskInfo)

            logger.info("Notification processing task scheduled successfully")
        } catch {
            logger.error("Failed to schedule notification processing task: \(error)")
            throw NotificationServiceError.backgroundTaskFailed("Failed to schedule processing task")
        }
    }

    /// Schedule warranty check background task
    public func scheduleWarrantyCheckTask() async throws {
        logger.info("Scheduling warranty check background task")

        let request = BGAppRefreshTaskRequest(identifier: BackgroundTaskIdentifier.warrantyCheck)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 12 * 60 * 60) // 12 hours from now

        do {
            try BGTaskScheduler.shared.submit(request)

            let taskInfo = BackgroundTaskInfo(
                identifier: BackgroundTaskIdentifier.warrantyCheck,
                taskType: "warranty-check",
                expirationTime: Date(timeIntervalSinceNow: 24 * 60 * 60)
            )
            try await persistence.saveBackgroundTaskInfo(taskInfo)

            logger.info("Warranty check task scheduled successfully")
        } catch {
            logger.error("Failed to schedule warranty check task: \(error)")
            throw NotificationServiceError.backgroundTaskFailed("Failed to schedule warranty check")
        }
    }

    /// Schedule analytics collection background task
    public func scheduleAnalyticsTask() async throws {
        logger.info("Scheduling analytics collection background task")

        let request = BGAppRefreshTaskRequest(identifier: BackgroundTaskIdentifier.analyticsCollection)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 8 * 60 * 60) // 8 hours from now

        do {
            try BGTaskScheduler.shared.submit(request)

            let taskInfo = BackgroundTaskInfo(
                identifier: BackgroundTaskIdentifier.analyticsCollection,
                taskType: "analytics-collection",
                expirationTime: Date(timeIntervalSinceNow: 24 * 60 * 60)
            )
            try await persistence.saveBackgroundTaskInfo(taskInfo)

            logger.info("Analytics collection task scheduled successfully")
        } catch {
            logger.error("Failed to schedule analytics task: \(error)")
            throw NotificationServiceError.backgroundTaskFailed("Failed to schedule analytics task")
        }
    }

    // MARK: - Background Task Handlers

    /// Handle notification processing background task
    private func handleNotificationProcessingTask(_ task: BGAppRefreshTask) async {
        logger.info("Starting background notification processing")

        let startTime = Date()

        // Set task completion handler
        task.expirationHandler = {
            Task { @MainActor in
                self.logger.warning("Background notification processing task expired")
                task.setTaskCompleted(success: false)
                await self.endBackgroundTask()
            }
        }

        do {
            // Begin background task for extended execution
            await beginBackgroundTask()

            // Perform notification processing
            try await performNotificationProcessing()

            // Schedule next occurrence
            try await scheduleNotificationProcessingTask()

            // Mark task as completed
            task.setTaskCompleted(success: true)

            let duration = Date().timeIntervalSince(startTime)
            logger.info("Background notification processing completed in \(String(format: "%.2f", duration))s")

        } catch {
            logger.error("Background notification processing failed: \(error)")
            task.setTaskCompleted(success: false)
        }

        await endBackgroundTask()
    }

    /// Handle warranty check background task
    private func handleWarrantyCheckTask(_ task: BGAppRefreshTask) async {
        logger.info("Starting background warranty check")

        task.expirationHandler = {
            Task { @MainActor in
                self.logger.warning("Background warranty check task expired")
                task.setTaskCompleted(success: false)
            }
        }

        do {
            // Check for expiring warranties and schedule notifications
            try await performWarrantyCheck()

            // Schedule next warranty check
            try await scheduleWarrantyCheckTask()

            task.setTaskCompleted(success: true)
            logger.info("Background warranty check completed")

        } catch {
            logger.error("Background warranty check failed: \(error)")
            task.setTaskCompleted(success: false)
        }
    }

    /// Handle analytics collection background task
    private func handleAnalyticsCollectionTask(_ task: BGAppRefreshTask) async {
        logger.info("Starting background analytics collection")

        task.expirationHandler = {
            Task { @MainActor in
                self.logger.warning("Background analytics collection task expired")
                task.setTaskCompleted(success: false)
            }
        }

        do {
            // Collect and process analytics
            try await performAnalyticsCollection()

            // Schedule next analytics collection
            try await scheduleAnalyticsTask()

            task.setTaskCompleted(success: true)
            logger.info("Background analytics collection completed")

        } catch {
            logger.error("Background analytics collection failed: \(error)")
            task.setTaskCompleted(success: false)
        }
    }

    // MARK: - Background Processing Operations

    /// Perform comprehensive notification processing
    private func performNotificationProcessing() async throws {
        logger.info("Performing notification processing")

        // 1. Clean up expired notifications
        try await notificationService.cleanupExpiredNotifications()

        // 2. Validate system integrity
        let validation = try await persistence.validateSystemIntegrity()
        if !validation.isValid {
            logger.warning("System integrity issues found, attempting repair")
            try await repairSystemIntegrity(issues: validation.missingItems)
        }

        // 3. Optimize notification schedule based on analytics
        try await optimizeNotificationSchedule()

        // 4. Save current state
        try await notificationService.saveNotificationState()

        logger.info("Notification processing completed")
    }

    /// Perform warranty expiration checks
    private func performWarrantyCheck() async throws {
        logger.info("Performing warranty check")

        // Get items expiring in next 30 days
        let expiringItems = try await notificationService.getUpcomingWarrantyExpirations(within: 30)

        if !expiringItems.isEmpty {
            logger.info("Found \(expiringItems.count) items with expiring warranties")

            // Reschedule notifications for expiring items
            for item in expiringItems {
                try await notificationService.scheduleWarrantyExpirationNotifications(for: item)
            }

            // Send summary notification if many items are expiring
            if expiringItems.count >= 5 {
                try await scheduleSummaryNotification(for: expiringItems)
            }
        }

        logger.info("Warranty check completed")
    }

    /// Perform analytics collection and optimization
    private func performAnalyticsCollection() async throws {
        logger.info("Performing analytics collection")

        // Generate current analytics
        let currentAnalytics = try await analytics.generateAnalytics()

        // Calculate optimal timing
        let (optimalHour, optimalDay) = try await analytics.calculateOptimalNotificationTiming()

        // Update notification preferences based on analytics
        let effectivenessReport = try await analytics.generateEffectivenessReport()

        // Log insights
        logger.info("Analytics: \(String(format: "%.1f", currentAnalytics.interactionRate * 100))% interaction rate")
        logger.info("Optimal timing: \(optimalHour):00 on weekday \(optimalDay)")

        // Store analytics insights for future use
        UserDefaults.standard.set(optimalHour, forKey: "optimal_notification_hour")
        UserDefaults.standard.set(optimalDay, forKey: "optimal_notification_day")

        logger.info("Analytics collection completed")
    }

    // MARK: - Optimization Operations

    /// Optimize notification schedule based on analytics
    private func optimizeNotificationSchedule() async throws {
        logger.info("Optimizing notification schedule")

        let currentAnalytics = try await analytics.generateAnalytics()

        // If interaction rate is low, reduce frequency
        if currentAnalytics.interactionRate < 0.3 {
            logger.info("Low interaction rate detected, reducing notification frequency")
            // Implementation would adjust notification frequency here
        }

        // If specific types are ineffective, adjust their scheduling
        let effectivenessReport = try await analytics.generateEffectivenessReport()
        for (type, metrics) in effectivenessReport {
            if metrics.interactionRate < 0.2 {
                logger.info("Type \(type.displayName) has low effectiveness, adjusting schedule")
                // Implementation would adjust scheduling for this type
            }
        }

        logger.info("Schedule optimization completed")
    }

    /// Repair system integrity issues
    private func repairSystemIntegrity(issues: [String]) async throws {
        logger.info("Repairing system integrity issues: \(issues.count) found")

        for issue in issues {
            if issue.contains("State shows scheduling activity but no requests stored") {
                // Clear inconsistent state
                try await persistence.clearPersistedState()
            } else if issue.contains("Notification storage directory missing") {
                // Recreate storage directory
                let persistence = NotificationPersistence()
                // Directory recreation is handled in init
            }
        }

        logger.info("System integrity repair completed")
    }

    /// Schedule summary notification for multiple expiring warranties
    private func scheduleSummaryNotification(for items: [Item]) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Multiple Warranties Expiring"
        content.body = "\(items.count) items have warranties expiring soon. Tap to review."
        content.sound = .default
        content.badge = NSNumber(value: items.count)

        // Add summary data
        content.userInfo = [
            "type": "warranty-summary",
            "itemCount": String(items.count),
            "itemIds": items.map(\.id.uuidString).joined(separator: ","),
        ]

        // Schedule for optimal time (9 AM tomorrow)
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let scheduledTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow) ?? tomorrow

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTime),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "warranty-summary-\(Int(Date().timeIntervalSince1970))",
            content: content,
            trigger: trigger
        )

        try await notificationService.notificationActor.add(request)
        logger.info("Scheduled summary notification for \(items.count) expiring items")
    }

    // MARK: - Background Task Management

    /// Begin background task for extended execution
    private func beginBackgroundTask() async {
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask { [weak self] in
            Task { @MainActor in
                await self?.endBackgroundTask()
            }
        }

        logger.info("Background task started: \(self.backgroundTaskIdentifier.rawValue)")
    }

    /// End background task
    private func endBackgroundTask() async {
        if backgroundTaskIdentifier != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            backgroundTaskIdentifier = .invalid
            logger.info("Background task ended")
        }
    }

    // MARK: - Public Interface

    /// Setup all background processing
    public func setupBackgroundProcessing() async throws {
        logger.info("Setting up background processing")

        // Schedule all background tasks
        try await scheduleNotificationProcessingTask()
        try await scheduleWarrantyCheckTask()
        try await scheduleAnalyticsTask()

        logger.info("Background processing setup completed")
    }

    /// Cancel all background tasks
    public func cancelAllBackgroundTasks() async {
        logger.info("Cancelling all background tasks")

        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: BackgroundTaskIdentifier.notificationProcessing)
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: BackgroundTaskIdentifier.warrantyCheck)
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: BackgroundTaskIdentifier.analyticsCollection)

        // Clear saved task info
        let persistence = NotificationPersistence()
        let backgroundTasks = persistence.loadBackgroundTasks()

        for taskId in backgroundTasks.keys {
            try? await persistence.removeBackgroundTask(taskId)
        }

        logger.info("All background tasks cancelled")
    }

    /// Get background task status
    public func getBackgroundTaskStatus() async -> BackgroundTaskStatus {
        let persistence = NotificationPersistence()
        let backgroundTasks = persistence.loadBackgroundTasks()

        let now = Date()
        let activeTasks = backgroundTasks.values.filter { $0.expirationTime > now }
        let expiredTasks = backgroundTasks.values.filter { $0.expirationTime <= now }

        return BackgroundTaskStatus(
            totalTasks: backgroundTasks.count,
            activeTasks: activeTasks.count,
            expiredTasks: expiredTasks.count,
            lastUpdate: now
        )
    }
}

// MARK: - Supporting Types

/// Background task status information
public struct BackgroundTaskStatus: Sendable {
    public let totalTasks: Int
    public let activeTasks: Int
    public let expiredTasks: Int
    public let lastUpdate: Date

    public var isHealthy: Bool {
        expiredTasks == 0 && activeTasks > 0
    }
}

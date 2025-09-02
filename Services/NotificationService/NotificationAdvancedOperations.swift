//
// Layer: Services
// Module: NotificationService
// Purpose: Advanced notification operations for LiveNotificationService
//

import Foundation
import os.log
import SwiftData
@preconcurrency import UserNotifications
import BackgroundTasks

// MARK: - Advanced Notification Operations

extension LiveNotificationService {
    // MARK: - Smart Scheduling

    /// Schedule smart notifications based on item priority and user patterns
    public func scheduleSmartNotifications(for items: [Item]) async throws {
        logger.info("Scheduling smart notifications for \(items.count) items")

        guard isAuthorized else {
            throw NotificationServiceError.authorizationDenied
        }

        let scheduler = NotificationScheduler(modelContext: modelContext)
        let result = try await scheduler.scheduleNotificationsWithLoadBalancing(for: items)

        logger.info("Smart scheduling completed: \(result.successfullyScheduled) successful, \(result.failed) failed")
    }

    /// Reschedule notifications with updated priority
    public func rescheduleNotificationsWithPriority() async throws {
        logger.info("Rescheduling notifications with updated priority")

        guard let modelContext else {
            throw NotificationServiceError.persistenceFailed("No model context available")
        }

        // Get all items with warranties
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate { item in
                item.warrantyExpirationDate != nil
            }
        )

        let items = try modelContext.fetch(descriptor)

        // Cancel existing notifications
        await cancelAllNotifications()

        // Reschedule with smart algorithms
        try await scheduleSmartNotifications(for: items)

        logger.info("Successfully rescheduled notifications for \(items.count) items")
    }

    /// Schedule recurring reminders
    public func scheduleRecurringReminders(
        for itemId: UUID,
        interval: RecurringInterval,
        reminderType: ReminderType
    ) async throws {
        logger.info("Scheduling recurring reminders for item \(itemId): \(reminderType.displayName) every \(interval.displayName)")

        guard isAuthorized else {
            throw NotificationServiceError.authorizationDenied
        }

        let scheduler = NotificationScheduler(modelContext: modelContext)
        let requests = try await scheduler.scheduleRecurringReminder(
            for: itemId,
            type: reminderType,
            startDate: Date(),
            interval: interval,
            maxOccurrences: 10
        )

        let result = try await batchScheduleNotifications(requests)

        if result.failed > 0 {
            throw NotificationServiceError.schedulingFailed("Failed to schedule \(result.failed) recurring reminders")
        }

        logger.info("Scheduled \(result.successfullyScheduled) recurring reminders")
    }

    /// Update notification frequency for an item
    public func updateNotificationFrequency(
        for itemId: UUID,
        frequency: NotificationFrequency
    ) async throws {
        logger.info("Updating notification frequency for item \(itemId) to \(frequency.displayName)")

        // Cancel existing notifications for this item
        await cancelWarrantyNotifications(for: itemId)

        // Get the item
        guard let modelContext else {
            throw NotificationServiceError.persistenceFailed("No model context available")
        }

        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { item in
                item.id == itemId
            }
        )

        guard let item = try modelContext.fetch(descriptor).first else {
            throw NotificationServiceError.itemNotFound("Item not found: \(itemId)")
        }

        // Reschedule with new frequency
        let scheduler = NotificationScheduler(modelContext: modelContext)
        var notificationDates = try await scheduler.calculateSmartNotificationDates(for: item)

        // Apply frequency multiplier
        switch frequency {
        case .minimal:
            // Keep only the most important notifications
            notificationDates = Array(notificationDates.suffix(2))
        case .normal:
            // Use as calculated
            break
        case .frequent:
            // Add additional mid-term notifications
            if let warrantyDate = item.warrantyExpirationDate {
                let additionalDates = scheduler.calculateOptimalDates(
                    from: warrantyDate,
                    daysBefore: [45, 15, 5]
                )
                notificationDates.append(contentsOf: additionalDates)
                notificationDates.sort()
            }
        case .maximum:
            // Add even more notifications
            if let warrantyDate = item.warrantyExpirationDate {
                let additionalDates = scheduler.calculateOptimalDates(
                    from: warrantyDate,
                    daysBefore: [120, 75, 45, 21, 10, 5, 2]
                )
                notificationDates.append(contentsOf: additionalDates)
                notificationDates.sort()
            }
        }

        // Schedule the notifications
        try await scheduleWarrantyExpirationNotifications(for: item)

        logger.info("Updated notification frequency for item \(itemId)")
    }

    // MARK: - Snooze Management

    /// Snooze a notification for specified duration
    public func snoozeNotification(identifier: String, for duration: SnoozeDuration) async throws {
        logger.info("Snoozing notification \(identifier) for \(duration.displayName)")

        // Cancel the current notification
        await notificationActor.removePendingNotificationRequests(withIdentifiers: [identifier])

        // Create new notification for later
        let snoozeDate = Date().addingTimeInterval(duration.timeInterval)

        // Extract item info from identifier (this would need proper parsing in real implementation)
        // For now, create a generic snoozed notification
        let content = UNMutableNotificationContent()
        content.title = "Snoozed Reminder"
        content.body = "You snoozed this notification. Time to check again."
        content.sound = .default
        content.badge = 1

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: snoozeDate
        )

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let snoozedIdentifier = "\(identifier)_snoozed_\(Int(Date().timeIntervalSince1970))"
        let request = UNNotificationRequest(identifier: snoozedIdentifier, content: content, trigger: trigger)

        try await notificationActor.add(request)

        // Record snooze analytics
        let analytics = NotificationAnalytics(modelContext: modelContext)
        try await analytics.recordNotificationSnoozed(identifier, snoozeDuration: duration, snoozeCount: 1)

        logger.info("Successfully snoozed notification until \(snoozeDate)")
    }

    // MARK: - Batch Operations

    /// Schedule multiple notifications in batch
    public func batchScheduleNotifications(_ requests: [NotificationScheduleRequest]) async throws -> BatchScheduleResult {
        logger.info("Batch scheduling \(requests.count) notifications")

        guard isAuthorized else {
            throw NotificationServiceError.authorizationDenied
        }

        var successCount = 0
        var errors: [String] = []

        for request in requests {
            do {
                try await scheduleIndividualRequest(request)
                successCount += 1
            } catch {
                logger.error("Failed to schedule notification for item \(request.itemId): \(error)")
                errors.append("Item \(request.itemId): \(error.localizedDescription)")
            }
        }

        let result = BatchScheduleResult(
            totalRequests: requests.count,
            successfullyScheduled: successCount,
            failed: requests.count - successCount,
            errors: errors
        )

        logger.info("Batch scheduling completed: \(successCount)/\(requests.count) successful")
        return result
    }

    private func scheduleIndividualRequest(_ request: NotificationScheduleRequest) async throws {
        let content = UNMutableNotificationContent()
        content.title = request.title
        content.body = request.body
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = request.type.categoryIdentifier

        // Add metadata to userInfo
        var userInfo = request.metadata
        userInfo["itemId"] = request.itemId.uuidString
        userInfo["type"] = request.type.rawValue
        userInfo["priority"] = String(request.priority.rawValue)
        content.userInfo = userInfo

        // Create trigger
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: request.scheduledDate
        )

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let identifier = "\(request.type.rawValue)_\(request.itemId.uuidString)_\(Int(request.scheduledDate.timeIntervalSince1970))"
        let notificationRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try await notificationActor.add(notificationRequest)
    }

    // MARK: - Analytics Integration

    /// Get notification analytics
    public func getNotificationAnalytics() async throws -> NotificationAnalyticsData {
        logger.info("Generating notification analytics")

        let analytics = NotificationAnalytics(modelContext: modelContext)
        return try await analytics.generateAnalytics()
    }

    /// Get notification history
    public func getNotificationHistory(for itemId: UUID?) async throws -> [NotificationHistoryEntry] {
        let analytics = NotificationAnalytics(modelContext: modelContext)
        return try await analytics.getNotificationHistory(for: itemId)
    }

    /// Mark notification as interacted
    public func markNotificationInteracted(_ identifier: String, action: NotificationAction) async throws {
        logger.info("Recording notification interaction: \(identifier) -> \(action.rawValue)")

        let analytics = NotificationAnalytics(modelContext: modelContext)
        try await analytics.recordNotificationInteraction(identifier, action: action, responseTime: nil)
    }

    // MARK: - Persistence Operations

    /// Save current notification state
    public func saveNotificationState() async throws {
        logger.info("Saving notification state")

        let persistence = NotificationPersistence()
        let requests = try await loadScheduledRequests()
        let state = NotificationState(scheduledRequests: requests, lastSchedulingDate: Date())

        try await persistence.saveNotificationState(state)
        logger.info("Notification state saved successfully")
    }

    /// Restore notification state from persistence
    public func restoreNotificationState() async throws {
        logger.info("Restoring notification state")

        let persistence = NotificationPersistence()
        let recoveryResult = try await persistence.performRecovery()

        logger.info("Restored \(recoveryResult.totalRestored) notifications, \(recoveryResult.futureRequests) still valid")

        // Validate system integrity
        let validation = try await persistence.validateSystemIntegrity()
        if !validation.isValid {
            logger.warning("Notification system integrity issues found: \(validation.issues)")
        }
    }

    private func loadScheduledRequests() async throws -> [NotificationScheduleRequest] {
        let persistence = NotificationPersistence()
        return try await persistence.loadScheduledRequests()
    }

    // MARK: - Background Processing

    /// Process notifications in background
    public func processBackgroundNotifications() async throws {
        logger.info("Processing background notifications")

        // Perform cleanup
        let persistence = NotificationPersistence()
        try await persistence.performCleanup()

        // Reschedule expired notifications if needed
        try await rescheduleNotificationsWithPriority()

        logger.info("Background notification processing completed")
    }

    /// Register background task for notification processing
    public func registerBackgroundTask() async throws -> String {
        let taskIdentifier = "com.drunkonjava.nestory.notification-processing"
        logger.info("Registering background task: \(taskIdentifier)")

        // Register background task request
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 4 * 60 * 60) // 4 hours

        do {
            try BGTaskScheduler.shared.submit(request)

            // Save task info for persistence
            let persistence = NotificationPersistence()
            let taskInfo = BackgroundTaskInfo(
                identifier: taskIdentifier,
                taskType: "app-refresh",
                expirationTime: Date(timeIntervalSinceNow: 24 * 60 * 60) // 24 hours
            )

            try await persistence.saveBackgroundTaskInfo(taskInfo)

            logger.info("Background task registered successfully")
            return taskIdentifier

        } catch {
            logger.error("Failed to register background task: \(error)")
            throw NotificationServiceError.backgroundTaskFailed("Failed to register: \(error.localizedDescription)")
        }
    }

    /// Clean up expired notifications
    public func cleanupExpiredNotifications() async throws {
        logger.info("Cleaning up expired notifications")

        #if targetEnvironment(simulator)
        // Skip cleanup on simulator due to Sendable/actor issues
        logger.info("Skipping notification cleanup on simulator")
        return
        #else
        // Real device implementation with proper UNNotificationRequest handling
        let pendingRequests = await notificationActor.getPendingNotificationRequests()
        
        let now = Date()
        
        // Collect expired requests first to avoid data race
        let expiredRequests = pendingRequests.compactMap { request -> String? in
            if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger,
               let triggerDate = calendarTrigger.nextTriggerDate(),
               triggerDate < now
            {
                return request.identifier
            }
            return nil
        }
        
        // Remove expired requests
        if !expiredRequests.isEmpty {
            await notificationActor.removePendingNotificationRequests(withIdentifiers: expiredRequests)
        }

        // Also clean up persistence data
        let persistence = NotificationPersistence()
        try await persistence.performCleanup()

        logger.info("Cleaned up \(expiredRequests.count) expired notifications")
        #endif
    }
}

// MARK: - Supporting Extensions

// Note: calculateOptimalDates method is implemented privately in NotificationScheduler.swift

// MARK: - Error Extensions

extension NotificationServiceError {
    static func itemNotFound(_ message: String) -> NotificationServiceError {
        .schedulingFailed(message)
    }

    static func backgroundTaskFailed(_ message: String) -> NotificationServiceError {
        .schedulingFailed(message)
    }
}

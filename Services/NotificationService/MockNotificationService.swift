//
// Layer: Services
// Module: NotificationService
// Purpose: Mock implementation of notification service for testing
//

import Foundation
import SwiftData
import UserNotifications

public final class MockNotificationService: NotificationService, @unchecked Sendable {
    public var isAuthorized = false
    public var authorizationStatus: UNAuthorizationStatus = .notDetermined

    // Track calls for testing
    public var authorizationRequested = false
    public var scheduledNotifications: [String] = []
    public var cancelledNotifications: [UUID] = []

    nonisolated public init() {}

    // MARK: - Authorization

    public func requestAuthorization() async throws -> Bool {
        authorizationRequested = true
        isAuthorized = true
        authorizationStatus = .authorized
        return true
    }

    public func checkAuthorizationStatus() async {
        // Mock implementation - do nothing
    }

    // MARK: - Warranty Notifications

    public func scheduleWarrantyExpirationNotifications(for item: Item) async throws {
        scheduledNotifications.append("warranty_\(item.id)")
    }

    public func cancelWarrantyNotifications(for itemId: UUID) async {
        cancelledNotifications.append(itemId)
    }

    public func scheduleAllWarrantyNotifications() async throws {
        scheduledNotifications.append("all_warranties")
    }

    public func getUpcomingWarrantyExpirations(within _: Int = 30) async throws -> [Item] {
        [] // Mock empty array
    }

    // MARK: - Other Notification Types

    public func scheduleInsurancePolicyRenewal(
        policyName: String,
        renewalDate _: Date,
        policyType _: String,
        estimatedValue _: Decimal? = nil,
        policyId _: String? = nil,
    ) async throws {
        scheduledNotifications.append("insurance_\(policyName)")
    }

    public func scheduleDocumentUpdateReminder(for item: Item, afterDays _: Int = 30) async throws {
        scheduledNotifications.append("document_\(item.id)")
    }

    public func scheduleMaintenanceReminder(
        for item: Item,
        maintenanceType _: String,
        scheduledDate _: Date,
        intervalMonths _: Int = 12,
    ) async throws {
        scheduledNotifications.append("maintenance_\(item.id)")
    }

    public func scheduleNotification(
        id: String,
        content: UNNotificationContent,
        trigger: UNNotificationTrigger
    ) async throws {
        scheduledNotifications.append("custom_\(id)")
    }

    // MARK: - Management

    public func getPendingNotifications() async -> [NotificationRequestData] {
        scheduledNotifications.map { id in
            NotificationRequestData(
                identifier: id,
                title: "Mock Notification",
                body: "Mock notification body",
                badge: nil,
                userInfo: [:],
                triggerDate: Date(),
            )
        }
    }

    public func cancelAllNotifications() async {
        scheduledNotifications.removeAll()
    }

    public func clearDeliveredNotifications() async {
        // Mock implementation - do nothing
    }

    public func setupNotificationCategories() async {
        // Mock implementation - do nothing
    }

    // MARK: - Advanced Scheduling

    public func scheduleSmartNotifications(for items: [Item]) async throws {
        for item in items {
            scheduledNotifications.append("smart_\(item.id)")
        }
    }

    public func rescheduleNotificationsWithPriority() async throws {
        scheduledNotifications.append("priority_reschedule")
    }

    public func scheduleRecurringReminders(for itemId: UUID, interval: RecurringInterval, reminderType: ReminderType) async throws {
        scheduledNotifications.append("recurring_\(itemId)_\(reminderType.rawValue)")
    }

    public func updateNotificationFrequency(for itemId: UUID, frequency: NotificationFrequency) async throws {
        scheduledNotifications.append("frequency_update_\(itemId)")
    }

    public func snoozeNotification(identifier: String, for duration: SnoozeDuration) async throws {
        scheduledNotifications.append("snooze_\(identifier)_\(duration.rawValue)")
    }

    public func batchScheduleNotifications(_ requests: [NotificationScheduleRequest]) async throws -> BatchScheduleResult {
        for request in requests {
            scheduledNotifications.append("batch_\(request.itemId)")
        }
        return BatchScheduleResult(
            totalRequests: requests.count,
            successfullyScheduled: requests.count,
            failed: 0,
            errors: []
        )
    }

    // MARK: - Analytics & Persistence

    public func getNotificationAnalytics() async throws -> NotificationAnalyticsData {
        NotificationAnalyticsData(
            totalScheduled: scheduledNotifications.count,
            totalDelivered: scheduledNotifications.count,
            totalInteracted: 0,
            averageResponseTime: 0,
            mostEffectiveTime: Date(),
            leastEffectiveTime: nil,
            interactionRateByType: [:],
            snoozePattersByType: [:]
        )
    }

    public func getNotificationHistory(for itemId: UUID?) async throws -> [NotificationHistoryEntry] {
        guard let itemId else { return [] }
        return [
            NotificationHistoryEntry(
                itemId: itemId,
                type: .warranty,
                scheduledDate: Date(),
                deliveredDate: nil,
                interactionDate: nil,
                title: "Mock History Entry",
                body: "Mock notification history"
            )
        ]
    }

    public func markNotificationInteracted(_ identifier: String, action: NotificationAction) async throws {
        scheduledNotifications.append("interaction_\(identifier)_\(action.rawValue)")
    }

    public func saveNotificationState() async throws {
        // Mock implementation - do nothing
    }

    public func restoreNotificationState() async throws {
        // Mock implementation - do nothing
    }

    // MARK: - Background Processing

    public func processBackgroundNotifications() async throws {
        scheduledNotifications.append("background_processing")
    }

    public func registerBackgroundTask() async throws -> String {
        let taskId = UUID().uuidString
        scheduledNotifications.append("background_task_\(taskId)")
        return taskId
    }

    public func cleanupExpiredNotifications() async throws {
        scheduledNotifications.append("cleanup_expired")
    }
}

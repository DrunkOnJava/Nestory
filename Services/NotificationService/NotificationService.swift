//
// Layer: Services
// Module: NotificationService
// Purpose: Protocol-first notification service for warranty expiration and other notifications
//

import Foundation
import SwiftData
import UserNotifications

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with BackgroundTasks - Use BGTaskScheduler for system-managed background processing of notifications instead of manual scheduling

/// Protocol defining notification service capabilities for warranty tracking and reminders
@MainActor
public protocol NotificationService: AnyObject {
    // MARK: - Authorization

    var isAuthorized: Bool { get }
    var authorizationStatus: UNAuthorizationStatus { get }

    func requestAuthorization() async throws -> Bool
    func checkAuthorizationStatus() async

    // MARK: - Warranty Notifications

    func scheduleWarrantyExpirationNotifications(for item: Item) async throws
    func cancelWarrantyNotifications(for itemId: UUID) async
    func scheduleAllWarrantyNotifications() async throws
    func getUpcomingWarrantyExpirations(within days: Int) async throws -> [Item]

    // MARK: - Advanced Scheduling

    func scheduleSmartNotifications(for items: [Item]) async throws
    func rescheduleNotificationsWithPriority() async throws
    func scheduleRecurringReminders(for itemId: UUID, interval: RecurringInterval, reminderType: ReminderType) async throws
    func updateNotificationFrequency(for itemId: UUID, frequency: NotificationFrequency) async throws
    func snoozeNotification(identifier: String, for duration: SnoozeDuration) async throws
    func batchScheduleNotifications(_ requests: [NotificationScheduleRequest]) async throws -> BatchScheduleResult

    // MARK: - Other Notification Types

    func scheduleInsurancePolicyRenewal(
        policyName: String,
        renewalDate: Date,
        policyType: String,
        estimatedValue: Decimal?,
        policyId: String?,
    ) async throws

    func scheduleDocumentUpdateReminder(for item: Item, afterDays days: Int) async throws

    func scheduleMaintenanceReminder(
        for item: Item,
        maintenanceType: String,
        scheduledDate: Date,
        intervalMonths: Int,
    ) async throws

    // MARK: - Management

    func getPendingNotifications() async -> [NotificationRequestData]
    func cancelAllNotifications() async
    func clearDeliveredNotifications() async
    func setupNotificationCategories() async

    // MARK: - Analytics & Persistence

    func getNotificationAnalytics() async throws -> NotificationAnalytics
    func getNotificationHistory(for itemId: UUID?) async throws -> [NotificationHistoryEntry]
    func markNotificationInteracted(_ identifier: String, action: NotificationAction) async throws
    func saveNotificationState() async throws
    func restoreNotificationState() async throws

    // MARK: - Background Processing

    func processBackgroundNotifications() async throws
    func registerBackgroundTask() async throws -> String
    func cleanupExpiredNotifications() async throws
}

// MARK: - Supporting Data Types

// NotificationRequestData is defined in Infrastructure/Actors/NotificationActor.swift
// Additional types are defined in NotificationSchedulingTypes.swift

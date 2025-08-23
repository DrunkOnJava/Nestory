//
// Layer: Services
// Module: NotificationService
// Purpose: TCA compatibility layer for NotificationService concurrency requirements
//

import Foundation
import UserNotifications

// MARK: - Temporary Nonisolated Mock for TCA Compatibility

/// Temporary mock service for TCA compatibility
/// This allows TCA to access the service from background queues during migration
/// Uses @unchecked Sendable to work around MainActor requirement
final class UnIsolatedMockNotificationService: @unchecked Sendable {
    private let _isAuthorized = LockIsolated(false)
    private let _authorizationStatus = LockIsolated(UNAuthorizationStatus.notDetermined)
    
    init() {}
}

extension UnIsolatedMockNotificationService: NotificationService {
    var isAuthorized: Bool {
        _isAuthorized.value
    }
    
    var authorizationStatus: UNAuthorizationStatus {
        _authorizationStatus.value
    }
    
    // MARK: - Authorization
    func requestAuthorization() async throws -> Bool {
        _isAuthorized.setValue(true)
        _authorizationStatus.setValue(.authorized)
        return true
    }
    
    func checkAuthorizationStatus() async {
        // Mock implementation - no-op
    }
    
    // MARK: - Warranty Notifications
    func scheduleWarrantyExpirationNotifications(for item: Item) async throws {
        // Mock implementation - no-op
    }
    
    func cancelWarrantyNotifications(for itemId: UUID) async {
        // Mock implementation - no-op
    }
    
    func scheduleAllWarrantyNotifications() async throws {
        // Mock implementation - no-op
    }
    
    func getUpcomingWarrantyExpirations(within days: Int) async throws -> [Item] {
        return []
    }
    
    // MARK: - Advanced Scheduling
    func scheduleSmartNotifications(for items: [Item]) async throws {
        // Mock implementation - no-op
    }
    
    func rescheduleNotificationsWithPriority() async throws {
        // Mock implementation - no-op
    }
    
    func scheduleRecurringReminders(for itemId: UUID, interval: RecurringInterval, reminderType: ReminderType) async throws {
        // Mock implementation - no-op
    }
    
    func updateNotificationFrequency(for itemId: UUID, frequency: NotificationFrequency) async throws {
        // Mock implementation - no-op
    }
    
    func snoozeNotification(identifier: String, for duration: SnoozeDuration) async throws {
        // Mock implementation - no-op
    }
    
    func batchScheduleNotifications(_ requests: [NotificationScheduleRequest]) async throws -> BatchScheduleResult {
        return BatchScheduleResult(
            totalRequests: requests.count,
            successfullyScheduled: requests.count,
            failed: 0,
            errors: []
        )
    }
    
    // MARK: - Other Notification Types
    func scheduleInsurancePolicyRenewal(
        policyName: String,
        renewalDate: Date,
        policyType: String,
        estimatedValue: Decimal?,
        policyId: String?
    ) async throws {
        // Mock implementation - no-op
    }
    
    func scheduleDocumentUpdateReminder(for item: Item, afterDays days: Int) async throws {
        // Mock implementation - no-op
    }
    
    func scheduleMaintenanceReminder(
        for item: Item,
        maintenanceType: String,
        scheduledDate: Date,
        intervalMonths: Int
    ) async throws {
        // Mock implementation - no-op
    }
    
    func scheduleNotification(
        id: String,
        content: UNNotificationContent,
        trigger: UNNotificationTrigger
    ) async throws {
        // Mock implementation - no-op
    }
    
    // MARK: - Management
    func getPendingNotifications() async -> [NotificationRequestData] {
        return []
    }
    
    func cancelAllNotifications() async {
        // Mock implementation - no-op
    }
    
    func clearDeliveredNotifications() async {
        // Mock implementation - no-op
    }
    
    func setupNotificationCategories() async {
        // Mock implementation - no-op
    }
    
    // MARK: - Analytics & Persistence
    func getNotificationAnalytics() async throws -> NotificationAnalyticsData {
        return NotificationAnalyticsData(
            totalScheduled: 0,
            totalDelivered: 0,
            totalInteracted: 0,
            averageResponseTime: 0,
            mostEffectiveTime: Date(),
            leastEffectiveTime: nil,
            interactionRateByType: [:],
            snoozePattersByType: [:]
        )
    }
    
    func getNotificationHistory(for itemId: UUID?) async throws -> [NotificationHistoryEntry] {
        return []
    }
    
    func markNotificationInteracted(_ identifier: String, action: NotificationAction) async throws {
        // Mock implementation - no-op
    }
    
    func saveNotificationState() async throws {
        // Mock implementation - no-op
    }
    
    func restoreNotificationState() async throws {
        // Mock implementation - no-op
    }
    
    // MARK: - Background Processing
    func processBackgroundNotifications() async throws {
        // Mock implementation - no-op
    }
    
    func registerBackgroundTask() async throws -> String {
        return UUID().uuidString
    }
    
    func cleanupExpiredNotifications() async throws {
        // Mock implementation - no-op
    }
}
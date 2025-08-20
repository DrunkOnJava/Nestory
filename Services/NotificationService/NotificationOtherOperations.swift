//
// Layer: Services
// Module: NotificationService
// Purpose: Insurance, document, and maintenance notification operations for NotificationService
//

import Foundation
import os.log
import UserNotifications

// MARK: - Other Notification Operations

extension LiveNotificationService {
    // MARK: - Insurance Policy Notifications

    public func scheduleInsurancePolicyRenewal(
        policyName: String,
        renewalDate: Date,
        policyType _: String,
        estimatedValue _: Decimal? = nil,
        policyId: String? = nil,
    ) async throws {
        guard isAuthorized else { return }

        // Schedule 30 days before renewal
        let notificationDate = renewalDate.addingTimeInterval(-Double(BusinessConstants.Warranty.renewalNotificationDays * BusinessConstants.Notifications.dayCalculationMultiplier))

        guard notificationDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Insurance Policy Renewal"
        content.body = "\(policyName) needs renewal in \(BusinessConstants.Warranty.renewalNotificationDays) days"
        content.sound = .default
        content.categoryIdentifier = "INSURANCE_RENEWAL"
        content.userInfo = ["policyId": policyId ?? UUID().uuidString]

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour],
            from: notificationDate,
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false,
        )

        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.insurancePolicyRenewal(policyId: policyId ?? UUID().uuidString),
            content: content,
            trigger: trigger,
        )

        try await notificationActor.add(request)
    }

    // MARK: - Document Update Reminders

    public func scheduleDocumentUpdateReminder(for item: Item, afterDays days: Int = BusinessConstants.Warranty.documentUpdateReminderDays) async throws {
        guard isAuthorized else { return }

        let reminderDate = Date().addingTimeInterval(Double(days * BusinessConstants.Notifications.dayCalculationMultiplier))

        let content = UNMutableNotificationContent()
        content.title = "Document Update Reminder"
        content.body = "Review and update documentation for \(item.name)"
        content.sound = .default
        content.categoryIdentifier = "DOCUMENT_UPDATE"
        content.userInfo = ["itemId": item.id.uuidString]

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour],
            from: reminderDate,
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false,
        )

        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.documentUpdateReminder(itemId: item.id),
            content: content,
            trigger: trigger,
        )

        try await notificationActor.add(request)
    }

    // MARK: - Maintenance Reminders

    public func scheduleMaintenanceReminder(
        for item: Item,
        maintenanceType: String,
        scheduledDate: Date,
        intervalMonths _: Int = 12,
    ) async throws {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Maintenance Reminder"
        content.body = "\(item.name) needs \(maintenanceType)"
        content.sound = .default
        content.categoryIdentifier = "MAINTENANCE"
        content.userInfo = [
            "itemId": item.id.uuidString,
            "maintenanceType": maintenanceType,
        ]

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour],
            from: scheduledDate,
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false,
        )

        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.maintenanceReminder(itemId: item.id),
            content: content,
            trigger: trigger,
        )

        try await notificationActor.add(request)
    }
}

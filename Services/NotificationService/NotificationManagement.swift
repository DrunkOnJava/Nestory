//
// Layer: Services
// Module: NotificationService
// Purpose: Notification management utilities and settings for NotificationService
//

import Foundation
import os.log
import UserNotifications

// MARK: - Notification Management

extension LiveNotificationService {
    // MARK: - General Management

    public func getPendingNotifications() async -> [NotificationRequestData] {
        await notificationActor.getPendingRequestsData()
    }

    public func cancelAllNotifications() async {
        await notificationActor.removeAllPendingNotificationRequests()
        await notificationActor.removeAllDeliveredNotifications()
    }

    public func clearDeliveredNotifications() async {
        await notificationActor.removeAllDeliveredNotifications()
    }

    // MARK: - Notification Categories Setup

    public func setupNotificationCategories() async {
        let warrantyCategory = UNNotificationCategory(
            identifier: "WARRANTY_EXPIRATION",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_ITEM",
                    title: "View Item",
                    options: .foreground,
                ),
                UNNotificationAction(
                    identifier: "RENEW_WARRANTY",
                    title: "Renew Warranty",
                    options: .foreground,
                ),
            ],
            intentIdentifiers: [],
        )

        let insuranceCategory = UNNotificationCategory(
            identifier: "INSURANCE_RENEWAL",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_POLICY",
                    title: "View Policy",
                    options: .foreground,
                ),
            ],
            intentIdentifiers: [],
        )

        let documentCategory = UNNotificationCategory(
            identifier: "DOCUMENT_UPDATE",
            actions: [
                UNNotificationAction(
                    identifier: "UPDATE_NOW",
                    title: "Update Now",
                    options: .foreground,
                ),
                UNNotificationAction(
                    identifier: "REMIND_LATER",
                    title: "Remind in 1 Week",
                    options: [],
                ),
            ],
            intentIdentifiers: [],
        )

        let maintenanceCategory = UNNotificationCategory(
            identifier: "MAINTENANCE",
            actions: [
                UNNotificationAction(
                    identifier: "MARK_COMPLETE",
                    title: "Mark Complete",
                    options: [],
                ),
                UNNotificationAction(
                    identifier: "RESCHEDULE",
                    title: "Reschedule",
                    options: .foreground,
                ),
            ],
            intentIdentifiers: [],
        )

        await notificationActor.setNotificationCategories([
            warrantyCategory,
            insuranceCategory,
            documentCategory,
            maintenanceCategory,
        ])
    }
}

// MARK: - Notification Settings Extension

extension LiveNotificationService {
    public func updateNotificationSettings(
        warrantyEnabled: Bool? = nil,
        insuranceEnabled: Bool? = nil,
        documentEnabled: Bool? = nil,
        maintenanceEnabled: Bool? = nil,
        notificationDays: [Int]? = nil,
    ) {
        let defaults = UserDefaults.standard

        if let warrantyEnabled {
            defaults.set(warrantyEnabled, forKey: NotificationDefaults.warrantyNotificationsEnabled)
        }

        if let insuranceEnabled {
            defaults.set(insuranceEnabled, forKey: NotificationDefaults.insuranceNotificationsEnabled)
        }

        if let documentEnabled {
            defaults.set(documentEnabled, forKey: NotificationDefaults.documentNotificationsEnabled)
        }

        if let maintenanceEnabled {
            defaults.set(maintenanceEnabled, forKey: NotificationDefaults.maintenanceNotificationsEnabled)
        }

        if let notificationDays {
            defaults.set(notificationDays, forKey: NotificationDefaults.warrantyNotificationDays)
        }
    }

    public func getNotificationSettings() -> (
        warranty: Bool,
        insurance: Bool,
        document: Bool,
        maintenance: Bool,
        days: [Int]
    ) {
        let defaults = UserDefaults.standard

        return (
            warranty: defaults.bool(forKey: NotificationDefaults.warrantyNotificationsEnabled),
            insurance: defaults.bool(forKey: NotificationDefaults.insuranceNotificationsEnabled),
            document: defaults.bool(forKey: NotificationDefaults.documentNotificationsEnabled),
            maintenance: defaults.bool(forKey: NotificationDefaults.maintenanceNotificationsEnabled),
            days: defaults.array(forKey: NotificationDefaults.warrantyNotificationDays) as? [Int] ??
                NotificationDefaults.defaultNotificationDays,
        )
    }
}

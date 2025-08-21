//
// Layer: Services
// Module: NotificationService
// Purpose: Notification settings and preferences management
//

import Foundation
import UserNotifications

/// Notification settings and preferences
public struct NotificationSettings {
    // UserDefaults keys
    public static let warrantyNotificationDays = "warranty_notification_days"
    public static let notificationFrequency = "notification_frequency"
    public static let optimalNotificationTime = "optimal_notification_time"
    public static let weekendNotificationsEnabled = "weekend_notifications_enabled"
    public static let summaryNotificationsEnabled = "summary_notifications_enabled"
    public static let analyticsEnabled = "notification_analytics_enabled"

    // Default settings
    public static let defaultNotificationDays: [Int] = [30, 7, 1]
    public static let defaultFrequency: NotificationFrequency = .normal
    public static let defaultNotificationHour = 9 // 9 AM
    public static let defaultWeekendEnabled = false
    public static let defaultSummaryEnabled = true
    public static let defaultAnalyticsEnabled = true

    // Current settings instance
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Warranty Notification Settings

    /// Days before warranty expiration to send notifications
    public var warrantyNotificationDays: [Int] {
        get {
            let stored = userDefaults.array(forKey: Self.warrantyNotificationDays) as? [Int]
            return stored ?? Self.defaultNotificationDays
        }
        set {
            userDefaults.set(newValue, forKey: Self.warrantyNotificationDays)
        }
    }

    /// Overall notification frequency preference
    public var frequency: NotificationFrequency {
        get {
            let rawValue = userDefaults.string(forKey: Self.notificationFrequency) ?? Self.defaultFrequency.rawValue
            return NotificationFrequency(rawValue: rawValue) ?? Self.defaultFrequency
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Self.notificationFrequency)
        }
    }

    /// Optimal notification time (hour of day)
    public var optimalNotificationHour: Int {
        get {
            let stored = userDefaults.integer(forKey: Self.optimalNotificationTime)
            return stored > 0 ? stored : Self.defaultNotificationHour
        }
        set {
            userDefaults.set(max(0, min(23, newValue)), forKey: Self.optimalNotificationTime)
        }
    }

    /// Whether to send notifications on weekends
    public var weekendNotificationsEnabled: Bool {
        get {
            userDefaults.bool(forKey: Self.weekendNotificationsEnabled)
        }
        set {
            userDefaults.set(newValue, forKey: Self.weekendNotificationsEnabled)
        }
    }

    /// Whether to send summary notifications
    public var summaryNotificationsEnabled: Bool {
        get {
            userDefaults.bool(forKey: Self.summaryNotificationsEnabled)
        }
        set {
            userDefaults.set(newValue, forKey: Self.summaryNotificationsEnabled)
        }
    }

    /// Whether analytics collection is enabled
    public var analyticsEnabled: Bool {
        get {
            userDefaults.bool(forKey: Self.analyticsEnabled)
        }
        set {
            userDefaults.set(newValue, forKey: Self.analyticsEnabled)
        }
    }

    // MARK: - Convenience Methods

    /// Reset all settings to defaults
    public func resetToDefaults() {
        warrantyNotificationDays = Self.defaultNotificationDays
        frequency = Self.defaultFrequency
        optimalNotificationHour = Self.defaultNotificationHour
        weekendNotificationsEnabled = Self.defaultWeekendEnabled
        summaryNotificationsEnabled = Self.defaultSummaryEnabled
        analyticsEnabled = Self.defaultAnalyticsEnabled
    }

    /// Export current settings
    public func exportSettings() -> [String: Any] {
        [
            "warrantyNotificationDays": warrantyNotificationDays,
            "frequency": frequency.rawValue,
            "optimalNotificationHour": optimalNotificationHour,
            "weekendNotificationsEnabled": weekendNotificationsEnabled,
            "summaryNotificationsEnabled": summaryNotificationsEnabled,
            "analyticsEnabled": analyticsEnabled,
            "exportedAt": Date().timeIntervalSince1970,
        ]
    }

    /// Import settings from dictionary
    public func importSettings(_ settings: [String: Any]) {
        if let days = settings["warrantyNotificationDays"] as? [Int] {
            warrantyNotificationDays = days
        }

        if let frequencyString = settings["frequency"] as? String,
           let importedFrequency = NotificationFrequency(rawValue: frequencyString)
        {
            frequency = importedFrequency
        }

        if let hour = settings["optimalNotificationHour"] as? Int {
            optimalNotificationHour = hour
        }

        if let weekendEnabled = settings["weekendNotificationsEnabled"] as? Bool {
            weekendNotificationsEnabled = weekendEnabled
        }

        if let summaryEnabled = settings["summaryNotificationsEnabled"] as? Bool {
            summaryNotificationsEnabled = summaryEnabled
        }

        if let analyticsEnabled = settings["analyticsEnabled"] as? Bool {
            self.analyticsEnabled = analyticsEnabled
        }
    }

    /// Get recommended settings based on user's item count and types
    public func getRecommendedSettings(itemCount: Int, hasHighValueItems: Bool) -> NotificationSettings {
        var recommended = NotificationSettings()

        if itemCount < 10 {
            // Few items - can afford more notifications
            recommended.frequency = .frequent
            recommended.warrantyNotificationDays = [90, 30, 7, 1]
        } else if itemCount < 50 {
            // Moderate items - standard frequency
            recommended.frequency = .normal
            recommended.warrantyNotificationDays = [30, 7, 1]
        } else {
            // Many items - reduce frequency to avoid overwhelm
            recommended.frequency = .minimal
            recommended.warrantyNotificationDays = [30, 1]
        }

        if hasHighValueItems {
            // High value items need more attention
            if recommended.frequency == .minimal {
                recommended.frequency = .normal
            }
            recommended.summaryNotificationsEnabled = true
        }

        return recommended
    }
}

/// Notification categories and their configurations
public struct NotificationCategory {
    public let identifier: String
    public let title: String
    public let subtitle: String?
    public let actions: [NotificationAction]

    public init(identifier: String, title: String, subtitle: String? = nil, actions: [NotificationAction] = []) {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.actions = actions
    }

    /// Create UNNotificationCategory for system registration
    public func createSystemCategory() -> UNNotificationCategory {
        let systemActions = actions.map { action in
            UNNotificationAction(
                identifier: action.identifier,
                title: action.title,
                options: action.options
            )
        }

        return UNNotificationCategory(
            identifier: identifier,
            actions: systemActions,
            intentIdentifiers: [],
            options: []
        )
    }

    // MARK: - Predefined Categories

    public static let warrantyExpiration = NotificationCategory(
        identifier: BusinessConstants.Notifications.warrantyExpirationCategory,
        title: "Warranty Expiring",
        subtitle: "Take action to protect your item",
        actions: [
            NotificationAction(
                identifier: "extend_warranty",
                title: "Extend Warranty",
                options: [.foreground]
            ),
            NotificationAction(
                identifier: "contact_vendor",
                title: "Contact Vendor",
                options: [.foreground]
            ),
            NotificationAction(
                identifier: "dismiss",
                title: "Dismiss",
                options: []
            ),
        ]
    )

    public static let maintenanceReminder = NotificationCategory(
        identifier: BusinessConstants.Notifications.maintenanceReminderCategory,
        title: "Maintenance Due",
        subtitle: "Keep your item in good condition",
        actions: [
            NotificationAction(
                identifier: "mark_completed",
                title: "Mark Completed",
                options: []
            ),
            NotificationAction(
                identifier: "snooze_1day",
                title: "Remind Tomorrow",
                options: []
            ),
            NotificationAction(
                identifier: "dismiss",
                title: "Dismiss",
                options: []
            ),
        ]
    )

    public static let documentUpdate = NotificationCategory(
        identifier: BusinessConstants.Notifications.documentUpdateCategory,
        title: "Document Update",
        subtitle: "Keep your records current",
        actions: [
            NotificationAction(
                identifier: "update_documents",
                title: "Update Now",
                options: [.foreground]
            ),
            NotificationAction(
                identifier: "snooze_1week",
                title: "Remind Next Week",
                options: []
            ),
        ]
    )

    public static let insuranceRenewal = NotificationCategory(
        identifier: BusinessConstants.Notifications.insuranceRenewalCategory,
        title: "Insurance Review",
        subtitle: "Ensure adequate coverage",
        actions: [
            NotificationAction(
                identifier: "review_coverage",
                title: "Review Coverage",
                options: [.foreground]
            ),
            NotificationAction(
                identifier: "contact_agent",
                title: "Contact Agent",
                options: [.foreground]
            ),
        ]
    )

    /// All predefined categories
    public static let allCategories: [NotificationCategory] = [
        warrantyExpiration,
        maintenanceReminder,
        documentUpdate,
        insuranceRenewal,
    ]
}

/// Notification action configuration
public struct NotificationAction {
    public let identifier: String
    public let title: String
    public let options: UNNotificationActionOptions

    public init(identifier: String, title: String, options: UNNotificationActionOptions = []) {
        self.identifier = identifier
        self.title = title
        self.options = options
    }
}

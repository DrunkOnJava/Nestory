//
// Layer: Services
// Module: NotificationService
// Purpose: Error types and notification identifier utilities for NotificationService
//

import Foundation

// MARK: - Notification Service Errors

public enum NotificationServiceError: LocalizedError {
    case authorizationDenied
    case authorizationNotDetermined
    case systemNotificationsDisabled
    case invalidNotificationContent
    case schedulingFailed(String)
    case itemNotFound(UUID)
    case invalidWarrantyDate(Date?)
    case persistenceFailed(String)

    public var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            "Notification permission has been denied"
        case .authorizationNotDetermined:
            "Notification permission has not been requested"
        case .systemNotificationsDisabled:
            "System notifications are disabled"
        case .invalidNotificationContent:
            "Notification content is invalid"
        case let .schedulingFailed(reason):
            "Failed to schedule notification: \(reason)"
        case let .itemNotFound(id):
            "Item not found: \(id)"
        case let .invalidWarrantyDate(date):
            "Invalid warranty date: \(date?.description ?? "nil")"
        case let .persistenceFailed(reason):
            "Failed to persist notification data: \(reason)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .authorizationDenied, .authorizationNotDetermined:
            "Please enable notifications in Settings"
        case .systemNotificationsDisabled:
            "Enable notifications in System Settings"
        case .invalidNotificationContent:
            "Check notification data and try again"
        case .schedulingFailed:
            "Try again or restart the app"
        case .itemNotFound:
            "Refresh the item list and try again"
        case .invalidWarrantyDate:
            "Set a valid warranty expiration date"
        case .persistenceFailed:
            "Try again or restart the app if the problem persists"
        }
    }
}

// MARK: - Notification Identifier Utilities

enum NotificationIdentifier {
    static func warrantyExpiration(itemId: UUID, days: Int) -> String {
        "warranty-expiration-\(itemId)-\(days)days"
    }

    static func insurancePolicyRenewal(policyId: String) -> String {
        "insurance-renewal-\(policyId)"
    }

    static func documentUpdateReminder(itemId: UUID) -> String {
        "document-update-\(itemId)"
    }

    static func maintenanceReminder(itemId: UUID) -> String {
        "maintenance-reminder-\(itemId)"
    }
}

// MARK: - Notification Settings Keys

enum NotificationSettings {
    static let notificationsEnabled = "notificationsEnabled"
    static let warrantyNotificationsEnabled = "warrantyNotificationsEnabled"
    static let insuranceNotificationsEnabled = "insuranceNotificationsEnabled"
    static let documentNotificationsEnabled = "documentNotificationsEnabled"
    static let maintenanceNotificationsEnabled = "maintenanceNotificationsEnabled"

    // Days before expiration to notify
    static let warrantyNotificationDays = "warrantyNotificationDays"
    static let defaultNotificationDays = BusinessConstants.Warranty.defaultNotificationDays
}

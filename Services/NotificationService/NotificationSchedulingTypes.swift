//
// Layer: Services
// Module: NotificationService
// Purpose: Data types for advanced notification scheduling and management
//

import Foundation

// MARK: - Scheduling Enums

/// Recurring notification intervals for maintenance and reminders
public enum RecurringInterval: String, CaseIterable, Sendable, Codable {
    case weekly
    case monthly
    case quarterly
    case semiAnnually
    case annually
    case custom

    public var days: Int {
        switch self {
        case .weekly: 7
        case .monthly: 30
        case .quarterly: 90
        case .semiAnnually: 180
        case .annually: 365
        case .custom: 30 // Default, should be overridden
        }
    }

    public var displayName: String {
        switch self {
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        case .quarterly: "Quarterly"
        case .semiAnnually: "Every 6 Months"
        case .annually: "Annually"
        case .custom: "Custom"
        }
    }
}

/// Types of reminders that can be scheduled
public enum ReminderType: String, CaseIterable, Sendable, Codable {
    case maintenance
    case documentUpdate
    case warranty
    case insurance
    case inspection
    case cleaning
    case backup

    public var displayName: String {
        switch self {
        case .maintenance: "Maintenance"
        case .documentUpdate: "Document Update"
        case .warranty: "Warranty Check"
        case .insurance: "Insurance Review"
        case .inspection: "Inspection"
        case .cleaning: "Cleaning"
        case .backup: "Backup Reminder"
        }
    }

    public var categoryIdentifier: String {
        switch self {
        case .maintenance: BusinessConstants.Notifications.maintenanceReminderCategory
        case .documentUpdate: BusinessConstants.Notifications.documentUpdateCategory
        case .warranty: BusinessConstants.Notifications.warrantyExpirationCategory
        case .insurance: BusinessConstants.Notifications.insuranceRenewalCategory
        case .inspection: "INSPECTION_REMINDER"
        case .cleaning: "CLEANING_REMINDER"
        case .backup: "BACKUP_REMINDER"
        }
    }
}

/// Notification frequency preferences
public enum NotificationFrequency: String, CaseIterable, Sendable {
    case minimal // Only critical notifications
    case normal // Standard frequency
    case frequent // More notifications
    case maximum // All possible notifications

    public var multiplier: Double {
        switch self {
        case .minimal: 0.5
        case .normal: 1.0
        case .frequent: 1.5
        case .maximum: 2.0
        }
    }

    public var displayName: String {
        switch self {
        case .minimal: "Minimal"
        case .normal: "Normal"
        case .frequent: "Frequent"
        case .maximum: "Maximum"
        }
    }
}

/// Snooze duration options
public enum SnoozeDuration: String, CaseIterable, Sendable, Codable {
    case fifteenMinutes = "15min"
    case oneHour = "1hour"
    case fourHours = "4hours"
    case oneDay = "1day"
    case threeDays = "3days"
    case oneWeek = "1week"

    public var timeInterval: TimeInterval {
        switch self {
        case .fifteenMinutes: 15 * 60
        case .oneHour: 60 * 60
        case .fourHours: 4 * 60 * 60
        case .oneDay: 24 * 60 * 60
        case .threeDays: 3 * 24 * 60 * 60
        case .oneWeek: 7 * 24 * 60 * 60
        }
    }

    public var displayName: String {
        switch self {
        case .fifteenMinutes: "15 minutes"
        case .oneHour: "1 hour"
        case .fourHours: "4 hours"
        case .oneDay: "1 day"
        case .threeDays: "3 days"
        case .oneWeek: "1 week"
        }
    }
}

/// Actions that can be taken on notifications
public enum NotificationAction: String, Sendable, Codable {
    case viewed
    case dismissed
    case snoozed
    case actionTaken
    case ignored
}

// MARK: - Data Types

/// Request for scheduling a notification
public struct NotificationScheduleRequest: Sendable, Codable {
    public let itemId: UUID
    public let type: ReminderType
    public let scheduledDate: Date
    public let title: String
    public let body: String
    public let priority: NotificationPriority
    public let recurring: RecurringInterval?
    public let customInterval: Int? // Days for custom recurring
    public let metadata: [String: String]

    public init(
        itemId: UUID,
        type: ReminderType,
        scheduledDate: Date,
        title: String,
        body: String,
        priority: NotificationPriority = .normal,
        recurring: RecurringInterval? = nil,
        customInterval: Int? = nil,
        metadata: [String: String] = [:]
    ) {
        self.itemId = itemId
        self.type = type
        self.scheduledDate = scheduledDate
        self.title = title
        self.body = body
        self.priority = priority
        self.recurring = recurring
        self.customInterval = customInterval
        self.metadata = metadata
    }
}

/// Priority levels for notifications
public enum NotificationPriority: Int, CaseIterable, Sendable, Codable {
    case low = 1
    case normal = 2
    case high = 3
    case urgent = 4

    public var displayName: String {
        switch self {
        case .low: "Low"
        case .normal: "Normal"
        case .high: "High"
        case .urgent: "Urgent"
        }
    }

    public var sound: String {
        switch self {
        case .low: "default"
        case .normal: "default"
        case .high: "alert.caf"
        case .urgent: "alarm.caf"
        }
    }
}

/// Result of batch scheduling operation
public struct BatchScheduleResult: Sendable {
    public let totalRequests: Int
    public let successfullyScheduled: Int
    public let failed: Int
    public let errors: [String]

    public var successRate: Double {
        guard totalRequests > 0 else { return 0 }
        return Double(successfullyScheduled) / Double(totalRequests)
    }

    public init(totalRequests: Int, successfullyScheduled: Int, failed: Int, errors: [String]) {
        self.totalRequests = totalRequests
        self.successfullyScheduled = successfullyScheduled
        self.failed = failed
        self.errors = errors
    }
}

/// Analytics data for notification effectiveness
public struct NotificationAnalyticsData: Sendable {
    public let totalScheduled: Int
    public let totalDelivered: Int
    public let totalInteracted: Int
    public let averageResponseTime: TimeInterval
    public let mostEffectiveTime: Date?
    public let leastEffectiveTime: Date?
    public let interactionRateByType: [ReminderType: Double]
    public let snoozePattersByType: [ReminderType: Int]
    public let generatedDate: Date

    public var deliveryRate: Double {
        guard totalScheduled > 0 else { return 0 }
        return Double(totalDelivered) / Double(totalScheduled)
    }

    public var interactionRate: Double {
        guard totalDelivered > 0 else { return 0 }
        return Double(totalInteracted) / Double(totalDelivered)
    }

    public init(
        totalScheduled: Int,
        totalDelivered: Int,
        totalInteracted: Int,
        averageResponseTime: TimeInterval,
        mostEffectiveTime: Date?,
        leastEffectiveTime: Date?,
        interactionRateByType: [ReminderType: Double],
        snoozePattersByType: [ReminderType: Int]
    ) {
        self.totalScheduled = totalScheduled
        self.totalDelivered = totalDelivered
        self.totalInteracted = totalInteracted
        self.averageResponseTime = averageResponseTime
        self.mostEffectiveTime = mostEffectiveTime
        self.leastEffectiveTime = leastEffectiveTime
        self.interactionRateByType = interactionRateByType
        self.snoozePattersByType = snoozePattersByType
        self.generatedDate = Date()
    }
}

/// History entry for notification tracking
public struct NotificationHistoryEntry: Sendable, Codable {
    public let id: UUID
    public let itemId: UUID
    public let type: ReminderType
    public let scheduledDate: Date
    public let deliveredDate: Date?
    public let interactionDate: Date?
    public let action: NotificationAction?
    public let title: String
    public let body: String
    public let snoozedUntil: Date?

    public init(
        id: UUID = UUID(),
        itemId: UUID,
        type: ReminderType,
        scheduledDate: Date,
        deliveredDate: Date? = nil,
        interactionDate: Date? = nil,
        action: NotificationAction? = nil,
        title: String,
        body: String,
        snoozedUntil: Date? = nil
    ) {
        self.id = id
        self.itemId = itemId
        self.type = type
        self.scheduledDate = scheduledDate
        self.deliveredDate = deliveredDate
        self.interactionDate = interactionDate
        self.action = action
        self.title = title
        self.body = body
        self.snoozedUntil = snoozedUntil
    }
}

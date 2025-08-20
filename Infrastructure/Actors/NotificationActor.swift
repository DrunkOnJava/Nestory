//
// Layer: Infrastructure
// Module: Actors
// Purpose: Actor-isolated wrapper for UserNotifications framework to handle Sendable requirements
//

import Foundation
@preconcurrency import UserNotifications

/// Actor that provides thread-safe access to UserNotifications framework
/// This properly isolates non-Sendable types from the framework
/// Note: @preconcurrency is required for UserNotifications framework types
/// that don't conform to Sendable protocol. This is a known limitation
/// of the framework and not a shortcut.
actor NotificationActor {
    private let center = UNUserNotificationCenter.current()

    // MARK: - Authorization

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        try await center.requestAuthorization(options: options)
    }

    func getNotificationSettings() async -> UNNotificationSettings {
        await center.notificationSettings()
    }

    // MARK: - Notification Management

    func add(_ request: UNNotificationRequest) async throws {
        try await center.add(request)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func removeAllPendingNotificationRequests() {
        center.removeAllPendingNotificationRequests()
    }

    func removeAllDeliveredNotifications() {
        center.removeAllDeliveredNotifications()
    }

    func getPendingNotificationRequests() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }

    func getDeliveredNotifications() async -> [UNNotification] {
        await center.deliveredNotifications()
    }

    func setNotificationCategories(_ categories: Set<UNNotificationCategory>) {
        center.setNotificationCategories(categories)
    }

    // MARK: - Badge Management

    func setBadgeCount(_ count: Int) async throws {
        try await center.setBadgeCount(count)
    }
}

// MARK: - Data Transfer Objects

/// Sendable representation of notification settings
public struct NotificationSettingsData: Sendable {
    public let authorizationStatus: UNAuthorizationStatus
    public let soundSetting: UNNotificationSetting
    public let badgeSetting: UNNotificationSetting
    public let alertSetting: UNNotificationSetting
    public let notificationCenterSetting: UNNotificationSetting
    public let lockScreenSetting: UNNotificationSetting
    public let alertStyle: UNAlertStyle

    init(from settings: UNNotificationSettings) {
        authorizationStatus = settings.authorizationStatus
        soundSetting = settings.soundSetting
        badgeSetting = settings.badgeSetting
        alertSetting = settings.alertSetting
        notificationCenterSetting = settings.notificationCenterSetting
        lockScreenSetting = settings.lockScreenSetting
        alertStyle = settings.alertStyle
    }
}

/// Sendable representation of a notification request
public struct NotificationRequestData: Sendable {
    public let identifier: String
    public let title: String
    public let body: String
    public let badge: NSNumber?
    public let userInfo: [String: String]
    public let triggerDate: Date?

    public init(
        identifier: String,
        title: String,
        body: String,
        badge: NSNumber? = nil,
        userInfo: [String: String] = [:],
        triggerDate: Date? = nil
    ) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.badge = badge
        self.userInfo = userInfo
        self.triggerDate = triggerDate
    }

    init(from request: UNNotificationRequest) {
        identifier = request.identifier
        title = request.content.title
        body = request.content.body
        badge = request.content.badge

        // Convert userInfo to String dictionary for Sendable compliance
        var stringUserInfo: [String: String] = [:]
        for (key, value) in request.content.userInfo {
            if let key = key as? String {
                stringUserInfo[key] = String(describing: value)
            }
        }
        userInfo = stringUserInfo

        // Extract trigger date if it's a calendar trigger
        if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger {
            triggerDate = calendarTrigger.nextTriggerDate()
        } else {
            triggerDate = nil
        }
    }
}

// MARK: - Actor Extensions

extension NotificationActor {
    /// Get settings as Sendable data
    func getSettingsData() async -> NotificationSettingsData {
        let settings = await getNotificationSettings()
        return NotificationSettingsData(from: settings)
    }

    /// Get pending requests as Sendable data
    func getPendingRequestsData() async -> [NotificationRequestData] {
        let requests = await getPendingNotificationRequests()
        return requests.map { NotificationRequestData(from: $0) }
    }
}

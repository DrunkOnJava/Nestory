//
// Layer: Infrastructure
// Module: Notifications
// Purpose: UserNotifications abstraction for Services layer
//

import Foundation
import UserNotifications

// MARK: - Notification Provider Protocol

/// Abstract notification provider interface for Services layer
/// Abstracts UserNotifications specifics to enable testing and alternative providers
public protocol NotificationProvider: Sendable {
    /// Request notification permissions from the user
    func requestPermissions() async throws -> Bool
    
    /// Schedule a local notification
    func schedule(_ notification: LocalNotification) async throws
    
    /// Cancel pending notifications by identifier
    func cancel(identifiers: [String]) async
    
    /// Cancel all pending notifications
    func cancelAll() async
    
    /// Get current badge count
    func getBadgeCount() async -> Int
    
    /// Set badge count
    func setBadgeCount(_ count: Int) async
    
    /// Get authorization status
    func getAuthorizationStatus() async -> AuthorizationStatus
    
    /// Get pending notifications
    func getPendingNotifications() async -> [PendingNotification]
}

// MARK: - Supporting Types

/// Represents a local notification to be scheduled
public struct LocalNotification: Sendable, Identifiable {
    public let id: String
    public let title: String
    public let body: String
    public let triggerDate: Date
    public let categoryIdentifier: String?
    public let userInfo: [String: Any]
    public let sound: NotificationSound
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        triggerDate: Date,
        categoryIdentifier: String? = nil,
        userInfo: [String: Any] = [:],
        sound: NotificationSound = .default
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.triggerDate = triggerDate
        self.categoryIdentifier = categoryIdentifier
        self.userInfo = userInfo
        self.sound = sound
    }
}

/// Notification sound options
public enum NotificationSound: Sendable {
    case `default`
    case critical
    case none
    case custom(String)
}

/// Authorization status for notifications
public enum AuthorizationStatus: Sendable, Equatable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral
}

/// Represents a pending notification
public struct PendingNotification: Sendable, Identifiable {
    public let id: String
    public let title: String
    public let body: String
    public let triggerDate: Date?
    
    public init(id: String, title: String, body: String, triggerDate: Date?) {
        self.id = id
        self.title = title
        self.body = body
        self.triggerDate = triggerDate
    }
}

// MARK: - UserNotifications Implementation

/// Live implementation using Apple's UserNotifications framework
public actor AppleNotificationProvider: NotificationProvider {
    private let center = UNUserNotificationCenter.current()
    
    public init() {}
    
    public func requestPermissions() async throws -> Bool {
        let authorizationStatus = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        return authorizationStatus
    }
    
    public func schedule(_ notification: LocalNotification) async throws {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.userInfo = notification.userInfo
        
        if let categoryIdentifier = notification.categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        
        // Configure sound
        switch notification.sound {
        case .default:
            content.sound = .default
        case .critical:
            content.sound = .defaultCritical
        case .none:
            content.sound = nil
        case .custom(let soundName):
            content.sound = UNNotificationSound(named: UNNotificationSoundName(soundName))
        }
        
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: notification.triggerDate
            ),
            repeats: false
        )
        
        // Create request
        let request = UNNotificationRequest(
            identifier: notification.id,
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
    }
    
    public func cancel(identifiers: [String]) async {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    public func cancelAll() async {
        center.removeAllPendingNotificationRequests()
    }
    
    public func getBadgeCount() async -> Int {
        await UIApplication.shared.applicationIconBadgeNumber
    }
    
    public func setBadgeCount(_ count: Int) async {
        await UIApplication.shared.setApplicationIconBadgeNumber(count)
    }
    
    public func getAuthorizationStatus() async -> AuthorizationStatus {
        let settings = await center.notificationSettings()
        return mapUNAuthorizationStatus(settings.authorizationStatus)
    }
    
    public func getPendingNotifications() async -> [PendingNotification] {
        let requests = await center.pendingNotificationRequests()
        return requests.map { request in
            let triggerDate = (request.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()
            return PendingNotification(
                id: request.identifier,
                title: request.content.title,
                body: request.content.body,
                triggerDate: triggerDate
            )
        }
    }
    
    private func mapUNAuthorizationStatus(_ status: UNAuthorizationStatus) -> AuthorizationStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .authorized: return .authorized
        case .provisional: return .provisional
        case .ephemeral: return .ephemeral
        @unknown default: return .notDetermined
        }
    }
}

// MARK: - Mock Implementation

/// Mock implementation for testing
public final class MockNotificationProvider: NotificationProvider {
    private var scheduledNotifications: [LocalNotification] = []
    private var _badgeCount = 0
    private var _authorizationStatus: AuthorizationStatus = .notDetermined
    public var shouldThrowError = false
    
    public init() {}
    
    public func requestPermissions() async throws -> Bool {
        if shouldThrowError {
            throw NotificationError.permissionDenied
        }
        _authorizationStatus = .authorized
        return true
    }
    
    public func schedule(_ notification: LocalNotification) async throws {
        if shouldThrowError {
            throw NotificationError.schedulingFailed("Mock error")
        }
        scheduledNotifications.append(notification)
    }
    
    public func cancel(identifiers: [String]) async {
        scheduledNotifications.removeAll { notification in
            identifiers.contains(notification.id)
        }
    }
    
    public func cancelAll() async {
        scheduledNotifications.removeAll()
    }
    
    public func getBadgeCount() async -> Int {
        _badgeCount
    }
    
    public func setBadgeCount(_ count: Int) async {
        _badgeCount = count
    }
    
    public func getAuthorizationStatus() async -> AuthorizationStatus {
        _authorizationStatus
    }
    
    public func getPendingNotifications() async -> [PendingNotification] {
        scheduledNotifications.map { notification in
            PendingNotification(
                id: notification.id,
                title: notification.title,
                body: notification.body,
                triggerDate: notification.triggerDate
            )
        }
    }
    
    // Test helpers
    public func setAuthorizationStatus(_ status: AuthorizationStatus) {
        _authorizationStatus = status
    }
    
    public func getScheduledNotifications() -> [LocalNotification] {
        scheduledNotifications
    }
}

// MARK: - Error Types

public enum NotificationError: LocalizedError, Sendable {
    case permissionDenied
    case schedulingFailed(String)
    case invalidNotification
    
    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Notification permission denied"
        case let .schedulingFailed(reason):
            return "Failed to schedule notification: \(reason)"
        case .invalidNotification:
            return "Invalid notification configuration"
        }
    }
}
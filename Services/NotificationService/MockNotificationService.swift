//
// Layer: Services
// Module: NotificationService
// Purpose: Mock implementation of notification service for testing
//

import Foundation
import SwiftData
import UserNotifications

public final class MockNotificationService: NotificationService {
    public var isAuthorized = false
    public var authorizationStatus: UNAuthorizationStatus = .notDetermined

    // Track calls for testing
    public var authorizationRequested = false
    public var scheduledNotifications: [String] = []
    public var cancelledNotifications: [UUID] = []

    public init() {}

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
}

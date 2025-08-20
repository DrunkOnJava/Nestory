//
// Layer: Services
// Module: NotificationService
// Purpose: Protocol-first notification service for warranty expiration and other notifications
//

import Foundation
import SwiftData
import UserNotifications

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
}

// MARK: - Supporting Data Types

// NotificationRequestData is defined in Infrastructure/Actors/NotificationActor.swift

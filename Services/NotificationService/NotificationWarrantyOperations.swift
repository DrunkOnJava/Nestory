//
// Layer: Services
// Module: NotificationService
// Purpose: Warranty notification scheduling operations for NotificationService
//

import Foundation
import os.log
import SwiftData
import UserNotifications

// MARK: - Warranty Notification Operations

extension LiveNotificationService {
    // MARK: - Individual Warranty Notifications

    public func scheduleWarrantyExpirationNotifications(for item: Item) async throws {
        try await resilientExecutor.execute(
            operation: { @MainActor [weak self] in
                guard let self else {
                    throw ServiceError.unknown(underlying: "NotificationService deallocated")
                }

                // Validate authorization
                guard isAuthorized else {
                    if authorizationStatus == .notDetermined {
                        throw NotificationServiceError.authorizationNotDetermined
                    } else {
                        throw NotificationServiceError.authorizationDenied
                    }
                }

                // Validate warranty date
                guard let warrantyDate = item.warrantyExpirationDate else {
                    throw NotificationServiceError.invalidWarrantyDate(nil)
                }

                // Ensure warranty date is in the future
                guard warrantyDate > Date() else {
                    throw NotificationServiceError.invalidWarrantyDate(warrantyDate)
                }

                logger.info("Scheduling warranty notifications for item: \(item.name)")

                // Cancel existing notifications for this item
                await cancelWarrantyNotifications(for: item.id)

                // Get notification days from settings or use defaults
                let notificationDays = UserDefaults.standard.array(
                    forKey: NotificationDefaults.warrantyNotificationDays,
                ) as? [Int] ?? NotificationDefaults.defaultNotificationDays

                var scheduledCount = 0
                var lastError: (any Error)?

                // Schedule notifications for each reminder period
                for days in notificationDays {
                    do {
                        try await scheduleIndividualWarrantyNotification(
                            for: item,
                            warrantyDate: warrantyDate,
                            daysBeforeExpiration: days,
                        )
                        scheduledCount += 1
                    } catch {
                        logger.warning("Failed to schedule notification for \(days) days: \(error)")
                        lastError = error
                        // Continue trying to schedule other notifications
                    }
                }

                if scheduledCount == 0 {
                    throw NotificationServiceError.schedulingFailed(
                        lastError?.localizedDescription ?? "No notifications could be scheduled",
                    )
                }

                logger.info("Successfully scheduled \(scheduledCount) warranty notifications for \(item.name)")
            },
            operationType: "scheduleWarrantyNotifications",
        )
    }

    private func scheduleIndividualWarrantyNotification(
        for item: Item,
        warrantyDate: Date,
        daysBeforeExpiration: Int,
    ) async throws {
        let notificationDate = warrantyDate.addingTimeInterval(
            -Double(daysBeforeExpiration * BusinessConstants.Notifications.dayCalculationMultiplier),
        )

        // Only schedule if the notification date is in the future
        guard notificationDate > Date() else {
            logger.debug("Skipping notification for \(item.name) - date \(notificationDate) is in the past")
            return
        }

        // Create and validate notification content
        let content = UNMutableNotificationContent()
        content.title = "Warranty Expiring Soon"
        content.body = "\(item.name) warranty expires in \(daysBeforeExpiration) days"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = BusinessConstants.Notifications.warrantyExpirationCategory

        // Add comprehensive item info to userInfo for deep linking
        content.userInfo = [
            "itemId": item.id.uuidString,
            "itemName": item.name,
            "warrantyDate": warrantyDate.timeIntervalSince1970,
            "daysRemaining": daysBeforeExpiration,
            "notificationType": "warranty-expiration",
        ]

        // Validate content
        guard !content.title.isEmpty, !content.body.isEmpty else {
            throw NotificationServiceError.invalidNotificationContent
        }

        // Create date components for the trigger
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notificationDate,
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false,
        )

        let identifier = NotificationIdentifier.warrantyExpiration(
            itemId: item.id,
            days: daysBeforeExpiration,
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger,
        )

        do {
            try await notificationActor.add(request)
            logger.info("Scheduled warranty notification: \(identifier)")
        } catch {
            logger.error("Failed to add notification request \(identifier): \(error)")
            throw NotificationServiceError.schedulingFailed(error.localizedDescription)
        }
    }

    public func cancelWarrantyNotifications(for itemId: UUID) async {
        let identifiers = BusinessConstants.Warranty.defaultNotificationDays.map { days in
            NotificationIdentifier.warrantyExpiration(itemId: itemId, days: days)
        }

        await notificationActor.removePendingNotificationRequests(withIdentifiers: identifiers)
        logger.info("Cancelled warranty notifications for item: \(itemId)")
    }

    // MARK: - Batch Scheduling

    public func scheduleAllWarrantyNotifications() async throws {
        guard let modelContext else {
            logger.error("No model context available")
            return
        }

        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate { item in
                item.warrantyExpirationDate != nil
            }
        )

        do {
            let items = try modelContext.fetch(descriptor)
            logger.info("Found \(items.count) items with warranty dates")

            for item in items {
                try await scheduleWarrantyExpirationNotifications(for: item)
            }
        } catch {
            logger.error("Failed to fetch items: \(error)")
            throw error
        }
    }

    // MARK: - Upcoming Warranties

    public func getUpcomingWarrantyExpirations(within days: Int = BusinessConstants.Warranty.defaultExpirationLookAhead) async throws -> [Item] {
        guard let modelContext else {
            return []
        }

        let futureDate = Date().addingTimeInterval(Double(days * BusinessConstants.Notifications.dayCalculationMultiplier))
        let now = Date()

        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate { item in
                item.warrantyExpirationDate != nil &&
                    item.warrantyExpirationDate! > now &&
                    item.warrantyExpirationDate! <= futureDate
            },
            sortBy: [SortDescriptor(\.warrantyExpirationDate)]
        )

        return try modelContext.fetch(descriptor)
    }
}

//
// Layer: Services
// Module: NotificationService
// Purpose: Intelligent notification scheduling algorithms with priority-based timing and smart batching
//

import Foundation
import SwiftData
import os.log

/// Sophisticated notification scheduler with intelligent timing algorithms
@MainActor
public final class NotificationScheduler: @unchecked Sendable {
    private let logger: Logger
    private let modelContext: ModelContext?

    // Smart scheduling configuration
    private let optimalNotificationHour = 9 // 9 AM - optimal user attention time
    private let maxDailyNotifications = 3 // Prevent notification fatigue
    private let weekdayPreference: Set<Int> = [2, 3, 4, 5, 6] // Tuesday-Saturday (1=Sunday)

    public init(modelContext: ModelContext? = nil) {
        self.logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "NotificationScheduler")
        self.modelContext = modelContext
    }

    // MARK: - Smart Scheduling Algorithms

    /// Calculate smart notification dates based on item value, importance, and user patterns
    public func calculateSmartNotificationDates(for item: Item) async throws -> [Date] {
        guard let warrantyDate = item.warrantyExpirationDate else {
            return []
        }

        let itemValue = item.purchasePrice ?? 0
        let priority = calculateItemPriority(item: item, value: itemValue)
        let timeUntilExpiration = warrantyDate.timeIntervalSince(Date())
        let daysUntilExpiration = Int(timeUntilExpiration / (24 * 60 * 60))

        logger.info("Calculating smart notifications for \(item.name), priority: \(priority.displayName), days until expiration: \(daysUntilExpiration)")

        var notificationDates: [Date] = []

        // Algorithm: More valuable items get more notifications, earlier warnings
        switch priority {
        case .urgent:
            // High-value items: 90, 60, 30, 14, 7, 3, 1 days before
            notificationDates = calculateOptimalDates(
                from: warrantyDate,
                daysBefore: [90, 60, 30, 14, 7, 3, 1]
            )
        case .high:
            // Medium-high items: 60, 30, 14, 7, 1 days before
            notificationDates = calculateOptimalDates(
                from: warrantyDate,
                daysBefore: [60, 30, 14, 7, 1]
            )
        case .normal:
            // Standard items: 30, 7, 1 days before
            notificationDates = calculateOptimalDates(
                from: warrantyDate,
                daysBefore: [30, 7, 1]
            )
        case .low:
            // Low-priority items: 30, 1 days before
            notificationDates = calculateOptimalDates(
                from: warrantyDate,
                daysBefore: [30, 1]
            )
        }

        // Filter out dates that are in the past
        let futureNotifications = notificationDates.filter { $0 > Date() }

        logger.info("Generated \(futureNotifications.count) smart notification dates for \(item.name)")
        return futureNotifications
    }

    /// Calculate item priority based on value, warranty status, and category importance
    public func calculateItemPriority(item: Item, value: Decimal) -> NotificationPriority {
        let numericValue = value as NSDecimalNumber
        let doubleValue = numericValue.doubleValue

        // Base priority on purchase price
        var priority: NotificationPriority = .normal

        if doubleValue >= 5000 {
            priority = .urgent
        } else if doubleValue >= 1000 {
            priority = .high
        } else if doubleValue >= 250 {
            priority = .normal
        } else {
            priority = .low
        }

        // Adjust based on category (certain categories are more important)
        let importantCategories: Set<String> = [
            "Electronics", "Appliances", "Tools", "Jewelry", "Art",
            "Medical Equipment", "Safety Equipment", "Vehicle Parts",
        ]

        if let category = item.category?.name, importantCategories.contains(category) {
            // Bump priority up one level for important categories
            switch priority {
            case .low: priority = .normal
            case .normal: priority = .high
            case .high: priority = .urgent
            case .urgent: break // Already at max
            }
        }

        // Consider warranty time remaining - shorter time = higher priority
        if let warrantyDate = item.warrantyExpirationDate {
            let daysUntilExpiration = Calendar.current.dateComponents([.day], from: Date(), to: warrantyDate).day ?? 0

            if daysUntilExpiration <= 7, priority == .low {
                priority = .normal // Bump up items expiring soon
            } else if daysUntilExpiration <= 3, priority == .normal {
                priority = .high // Very urgent for items expiring very soon
            }
        }

        logger.debug("Calculated priority \(priority.displayName) for \(item.name) (value: $\(doubleValue))")
        return priority
    }

    /// Calculate optimal notification dates, avoiding weekends and clustering
    internal func calculateOptimalDates(from warrantyDate: Date, daysBefore: [Int]) -> [Date] {
        var optimalDates: [Date] = []
        let calendar = Calendar.current

        for days in daysBefore {
            let baseDate = warrantyDate.addingTimeInterval(-Double(days * 24 * 60 * 60))

            // Find the best day of the week for this notification
            let optimalDate = findOptimalNotificationDate(around: baseDate)

            // Set optimal time (9 AM by default)
            if let adjustedDate = calendar.date(bySettingHour: optimalNotificationHour, minute: 0, second: 0, of: optimalDate) {
                optimalDates.append(adjustedDate)
            } else {
                optimalDates.append(optimalDate)
            }
        }

        return optimalDates
    }

    /// Find optimal notification date, avoiding weekends and clustering
    private func findOptimalNotificationDate(around date: Date) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)

        // If it's already a good weekday, use it
        if weekdayPreference.contains(weekday) {
            return date
        }

        // If it's weekend, move to Monday
        if weekday == 1 { // Sunday -> Monday
            return calendar.date(byAdding: .day, value: 1, to: date) ?? date
        } else if weekday == 7 { // Saturday -> Monday
            return calendar.date(byAdding: .day, value: 2, to: date) ?? date
        }

        return date
    }

    // MARK: - Batch Scheduling with Load Balancing

    /// Schedule notifications for multiple items with intelligent load balancing
    public func scheduleNotificationsWithLoadBalancing(for items: [Item]) async throws -> BatchScheduleResult {
        logger.info("Starting batch scheduling for \(items.count) items with load balancing")

        var scheduleRequests: [NotificationScheduleRequest] = []
        var successCount = 0
        var errors: [String] = []

        // Generate all potential notification dates
        for item in items {
            do {
                let smartDates = try await calculateSmartNotificationDates(for: item)
                let priority = calculateItemPriority(item: item, value: item.purchasePrice ?? 0)

                for date in smartDates {
                    let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
                    let request = NotificationScheduleRequest(
                        itemId: item.id,
                        type: .warranty,
                        scheduledDate: date,
                        title: createSmartNotificationTitle(for: item, daysUntil: daysUntil),
                        body: createSmartNotificationBody(for: item, daysUntil: daysUntil, priority: priority),
                        priority: priority,
                        metadata: [
                            "itemName": item.name,
                            "itemValue": String(describing: item.purchasePrice ?? 0),
                            "algorithmVersion": "smart-v1.0",
                        ]
                    )
                    scheduleRequests.append(request)
                }
            } catch {
                logger.error("Failed to calculate smart dates for item \(item.name): \(error)")
                errors.append("Item \(item.name): \(error.localizedDescription)")
            }
        }

        // Apply load balancing - spread notifications across time to avoid clustering
        let balancedRequests = try await applyLoadBalancing(to: scheduleRequests)

        logger.info("Generated \(balancedRequests.count) balanced notification requests")
        return BatchScheduleResult(
            totalRequests: items.count,
            successfullyScheduled: balancedRequests.count,
            failed: scheduleRequests.count - balancedRequests.count,
            errors: errors
        )
    }

    /// Apply load balancing to prevent notification clustering
    private func applyLoadBalancing(to requests: [NotificationScheduleRequest]) async throws -> [NotificationScheduleRequest] {
        let calendar = Calendar.current
        var balancedRequests: [NotificationScheduleRequest] = []
        var dailyNotificationCount: [String: Int] = [:] // Date string -> count

        // Sort by priority and date
        let sortedRequests = requests.sorted { request1, request2 in
            if request1.priority.rawValue != request2.priority.rawValue {
                return request1.priority.rawValue > request2.priority.rawValue // Higher priority first
            }
            return request1.scheduledDate < request2.scheduledDate
        }

        for request in sortedRequests {
            let dateKey = calendar.startOfDay(for: request.scheduledDate)
            let dayKey = ISO8601DateFormatter().string(from: dateKey)
            let currentCount = dailyNotificationCount[dayKey] ?? 0

            if currentCount < maxDailyNotifications {
                // Schedule as-is
                balancedRequests.append(request)
                dailyNotificationCount[dayKey] = currentCount + 1
            } else if request.priority == .urgent {
                // Always schedule urgent notifications, even if it exceeds daily limit
                balancedRequests.append(request)
                dailyNotificationCount[dayKey] = currentCount + 1
            } else {
                // Try to reschedule to next available day
                if let rescheduledRequest = try rescheduleToNextAvailableSlot(request: request, dailyCount: dailyNotificationCount) {
                    balancedRequests.append(rescheduledRequest)
                    let rescheduledDayKey = ISO8601DateFormatter().string(from: calendar.startOfDay(for: rescheduledRequest.scheduledDate))
                    dailyNotificationCount[rescheduledDayKey] = (dailyNotificationCount[rescheduledDayKey] ?? 0) + 1
                }
            }
        }

        logger.info("Load balancing completed: \(requests.count) -> \(balancedRequests.count) notifications")
        return balancedRequests
    }

    /// Reschedule notification to next available slot
    private func rescheduleToNextAvailableSlot(
        request: NotificationScheduleRequest,
        dailyCount: [String: Int]
    ) throws -> NotificationScheduleRequest? {
        let calendar = Calendar.current
        var checkDate = request.scheduledDate

        // Try up to 7 days forward
        for _ in 0 ..< 7 {
            checkDate = calendar.date(byAdding: .day, value: 1, to: checkDate) ?? checkDate
            let dayKey = ISO8601DateFormatter().string(from: calendar.startOfDay(for: checkDate))
            let count = dailyCount[dayKey] ?? 0

            if count < maxDailyNotifications {
                // Found available slot
                var rescheduledRequest = request
                rescheduledRequest = NotificationScheduleRequest(
                    itemId: request.itemId,
                    type: request.type,
                    scheduledDate: checkDate,
                    title: request.title,
                    body: request.body + " (Rescheduled)",
                    priority: request.priority,
                    recurring: request.recurring,
                    customInterval: request.customInterval,
                    metadata: request.metadata
                )
                return rescheduledRequest
            }
        }

        // No available slot found within 7 days
        logger.warning("No available slot found for notification within 7 days")
        return nil
    }

    // MARK: - Smart Content Generation

    /// Create contextually appropriate notification titles
    private func createSmartNotificationTitle(for item: Item, daysUntil: Int) -> String {
        let itemValue = item.purchasePrice ?? 0
        let isHighValue = (itemValue as NSDecimalNumber).doubleValue >= 1000

        switch daysUntil {
        case 0:
            return "⚠️ Warranty Expires Today"
        case 1:
            return "⚠️ Warranty Expires Tomorrow"
        case 2 ... 7:
            return "⚠️ Warranty Expires Soon"
        case 8 ... 30:
            return "📅 Warranty Check Reminder"
        case 31 ... 90:
            if isHighValue {
                return "💰 Important Warranty Notice"
            } else {
                return "📅 Warranty Update Available"
            }
        default:
            return "📋 Warranty Planning Reminder"
        }
    }

    /// Create contextually appropriate notification bodies
    private func createSmartNotificationBody(for item: Item, daysUntil: Int, priority: NotificationPriority) -> String {
        let itemName = item.name
        let hasReceiptImage = item.receiptImageData != nil
        let hasManual = item.manualPDFData != nil

        var body = ""

        switch daysUntil {
        case 0:
            body = "\(itemName) warranty expires today. "
        case 1:
            body = "\(itemName) warranty expires tomorrow. "
        case 2 ... 7:
            body = "\(itemName) warranty expires in \(daysUntil) days. "
        default:
            body = "\(itemName) warranty expires in \(daysUntil) days. "
        }

        // Add context-specific advice
        if priority == .urgent || priority == .high {
            if !hasReceiptImage {
                body += "Consider uploading receipt for protection."
            } else if !hasManual {
                body += "Add manual/documentation if available."
            } else {
                body += "Review coverage details and contact vendor if needed."
            }
        } else {
            body += "Check if renewal or extension is needed."
        }

        return body
    }

    // MARK: - Recurring Notification Management

    /// Calculate next occurrence date for recurring notifications
    public func calculateNextRecurrence(from date: Date, interval: RecurringInterval, customDays: Int? = nil) -> Date? {
        let calendar = Calendar.current

        switch interval {
        case .weekly:
            return calendar.date(byAdding: .day, value: 7, to: date)
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date)
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: date)
        case .semiAnnually:
            return calendar.date(byAdding: .month, value: 6, to: date)
        case .annually:
            return calendar.date(byAdding: .year, value: 1, to: date)
        case .custom:
            let days = customDays ?? 30
            return calendar.date(byAdding: .day, value: days, to: date)
        }
    }

    /// Schedule recurring maintenance reminders
    public func scheduleRecurringReminder(
        for itemId: UUID,
        type: ReminderType,
        startDate: Date,
        interval: RecurringInterval,
        customDays: Int? = nil,
        maxOccurrences: Int = 10
    ) async throws -> [NotificationScheduleRequest] {
        var requests: [NotificationScheduleRequest] = []
        var currentDate = startDate

        for occurrence in 1 ... maxOccurrences {
            guard let nextDate = calculateNextRecurrence(from: currentDate, interval: interval, customDays: customDays) else {
                break
            }

            // Only schedule future dates
            if nextDate > Date() {
                let request = NotificationScheduleRequest(
                    itemId: itemId,
                    type: type,
                    scheduledDate: nextDate,
                    title: "\(type.displayName) Due",
                    body: "Scheduled \(type.displayName.lowercased()) is due today.",
                    priority: .normal,
                    recurring: interval,
                    customInterval: customDays,
                    metadata: [
                        "occurrence": String(occurrence),
                        "maxOccurrences": String(maxOccurrences),
                        "recurringType": interval.rawValue,
                    ]
                )
                requests.append(request)
            }

            currentDate = nextDate
        }

        logger.info("Generated \(requests.count) recurring notifications for \(type.displayName)")
        return requests
    }
}

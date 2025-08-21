//
// Layer: Services
// Module: NotificationService
// Purpose: Analytics and effectiveness tracking for notification optimization
//

import Foundation
import SwiftData
import os.log

/// Analytics engine for tracking notification effectiveness and user engagement patterns
@MainActor
public final class NotificationAnalytics: @unchecked Sendable {
    private let logger: Logger
    private let modelContext: ModelContext?
    private let userDefaults: UserDefaults

    // Analytics storage keys
    private enum Keys {
        static let notificationHistory = "notification_history_v2"
        static let interactionMetrics = "notification_interaction_metrics"
        static let effectivenessData = "notification_effectiveness_data"
        static let userEngagementPatterns = "user_engagement_patterns"
        static let optimalTimingData = "optimal_timing_data"
    }

    public init(modelContext: ModelContext? = nil, userDefaults: UserDefaults = .standard) {
        self.logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "NotificationAnalytics")
        self.modelContext = modelContext
        self.userDefaults = userDefaults
    }

    // MARK: - Analytics Collection

    /// Record notification delivery
    public func recordNotificationDelivered(_ identifier: String, type: ReminderType, scheduledTime: Date) async throws {
        let entry = NotificationHistoryEntry(
            itemId: UUID(), // Would be extracted from identifier in real implementation
            type: type,
            scheduledDate: scheduledTime,
            deliveredDate: Date(),
            title: "Notification",
            body: "Body"
        )

        try await saveHistoryEntry(entry)
        try await updateDeliveryMetrics(for: type)

        logger.info("Recorded delivery for notification: \(identifier)")
    }

    /// Record notification interaction
    public func recordNotificationInteraction(_ identifier: String, action: NotificationAction, responseTime: TimeInterval?) async throws {
        let interactionTime = Date()

        // Update interaction metrics
        var metrics = loadInteractionMetrics()
        metrics[identifier] = InteractionRecord(
            action: action,
            timestamp: interactionTime,
            responseTime: responseTime ?? 0
        )
        saveInteractionMetrics(metrics)

        // Track optimal timing patterns
        try await updateOptimalTimingData(interactionTime: interactionTime, action: action)

        logger.info("Recorded interaction for notification \(identifier): \(action.rawValue)")
    }

    /// Record notification snooze behavior
    public func recordNotificationSnoozed(_ identifier: String, snoozeDuration: SnoozeDuration, snoozeCount: Int) async throws {
        let snoozeData = SnoozeRecord(
            identifier: identifier,
            duration: snoozeDuration,
            snoozeCount: snoozeCount,
            timestamp: Date()
        )

        try await saveSnoozeRecord(snoozeData)
        try await updateSnoozePatterns(for: identifier, count: snoozeCount)

        logger.info("Recorded snooze for notification \(identifier): \(snoozeDuration.displayName), count: \(snoozeCount)")
    }

    // MARK: - Analytics Generation

    /// Generate comprehensive notification analytics
    public func generateAnalytics() async throws -> NotificationAnalytics {
        logger.info("Generating notification analytics report")

        let history = loadNotificationHistory()
        let interactions = loadInteractionMetrics()
        let timingData = loadOptimalTimingData()

        let totalScheduled = history.count
        let totalDelivered = history.count(where: { $0.deliveredDate != nil })
        let totalInteracted = interactions.values.count(where: { $0.action != .ignored })

        let averageResponseTime = calculateAverageResponseTime(from: interactions)
        let (mostEffectiveTime, leastEffectiveTime) = calculateEffectiveTimes(from: timingData)
        let interactionRateByType = calculateInteractionRateByType(from: history, interactions: interactions)
        let snoozePattersByType = calculateSnoozePattersByType()

        let analytics = NotificationAnalytics(
            totalScheduled: totalScheduled,
            totalDelivered: totalDelivered,
            totalInteracted: totalInteracted,
            averageResponseTime: averageResponseTime,
            mostEffectiveTime: mostEffectiveTime,
            leastEffectiveTime: leastEffectiveTime,
            interactionRateByType: interactionRateByType,
            snoozePattersByType: snoozePattersByType
        )

        logger.info("Generated analytics: \(analytics.interactionRate * 100, specifier: "%.1f")% interaction rate")
        return analytics
    }

    /// Get notification history for specific item or all items
    public func getNotificationHistory(for itemId: UUID?) async throws -> [NotificationHistoryEntry] {
        let allHistory = loadNotificationHistory()

        if let itemId {
            return allHistory.filter { $0.itemId == itemId }
        } else {
            return allHistory
        }
    }

    /// Calculate optimal notification timing based on user patterns
    public func calculateOptimalNotificationTiming() async throws -> (hour: Int, dayOfWeek: Int) {
        let timingData = loadOptimalTimingData()
        let calendar = Calendar.current

        var hourInteractions: [Int: Int] = [:]
        var dayOfWeekInteractions: [Int: Int] = [:]

        for record in timingData {
            if record.wasInteracted {
                let components = calendar.dateComponents([.hour, .weekday], from: record.timestamp)

                if let hour = components.hour {
                    hourInteractions[hour, default: 0] += 1
                }

                if let weekday = components.weekday {
                    dayOfWeekInteractions[weekday, default: 0] += 1
                }
            }
        }

        let optimalHour = hourInteractions.max(by: { $0.value < $1.value })?.key ?? 9
        let optimalDay = dayOfWeekInteractions.max(by: { $0.value < $1.value })?.key ?? 3 // Tuesday

        logger.info("Calculated optimal timing: \(optimalHour):00 on weekday \(optimalDay)")
        return (hour: optimalHour, dayOfWeek: optimalDay)
    }

    /// Generate effectiveness report for notification types
    public func generateEffectivenessReport() async throws -> [ReminderType: EffectivenessMetrics] {
        let history = loadNotificationHistory()
        let interactions = loadInteractionMetrics()

        var report: [ReminderType: EffectivenessMetrics] = [:]

        for type in ReminderType.allCases {
            let typeHistory = history.filter { $0.type == type }
            let typeInteractions = interactions.values.filter { record in
                // In real implementation, would match by type from identifier
                record.action != .ignored
            }

            let deliveryRate = Double(typeHistory.count(where: { $0.deliveredDate != nil })) / Double(max(typeHistory.count, 1))
            let interactionRate = Double(typeInteractions.count) / Double(max(typeHistory.count, 1))
            let averageResponseTime = typeInteractions.reduce(0) { $0 + $1.responseTime } / Double(max(typeInteractions.count, 1))

            report[type] = EffectivenessMetrics(
                deliveryRate: deliveryRate,
                interactionRate: interactionRate,
                averageResponseTime: averageResponseTime,
                totalScheduled: typeHistory.count,
                totalDelivered: typeHistory.count(where: { $0.deliveredDate != nil })
            )
        }

        logger.info("Generated effectiveness report for \(report.count) notification types")
        return report
    }

    // MARK: - Data Persistence

    private func saveHistoryEntry(_ entry: NotificationHistoryEntry) async throws {
        var history = loadNotificationHistory()
        history.append(entry)

        // Keep only last 1000 entries to prevent storage bloat
        if history.count > 1000 {
            history = Array(history.suffix(1000))
        }

        let data = try JSONEncoder().encode(history)
        userDefaults.set(data, forKey: Keys.notificationHistory)
    }

    private func loadNotificationHistory() -> [NotificationHistoryEntry] {
        guard let data = userDefaults.data(forKey: Keys.notificationHistory),
              let history = try? JSONDecoder().decode([NotificationHistoryEntry].self, from: data)
        else {
            return []
        }
        return history
    }

    private func saveInteractionMetrics(_ metrics: [String: InteractionRecord]) {
        guard let data = try? JSONEncoder().encode(metrics) else { return }
        userDefaults.set(data, forKey: Keys.interactionMetrics)
    }

    private func loadInteractionMetrics() -> [String: InteractionRecord] {
        guard let data = userDefaults.data(forKey: Keys.interactionMetrics),
              let metrics = try? JSONDecoder().decode([String: InteractionRecord].self, from: data)
        else {
            return [:]
        }
        return metrics
    }

    private func updateDeliveryMetrics(for type: ReminderType) async throws {
        // Update delivery tracking for the specific type
        var metrics = userDefaults.object(forKey: Keys.effectivenessData) as? [String: Any] ?? [:]
        let typeKey = type.rawValue
        var typeMetrics = metrics[typeKey] as? [String: Any] ?? [:]

        let currentDelivered = typeMetrics["delivered"] as? Int ?? 0
        typeMetrics["delivered"] = currentDelivered + 1
        typeMetrics["lastDelivery"] = Date().timeIntervalSince1970

        metrics[typeKey] = typeMetrics
        userDefaults.set(metrics, forKey: Keys.effectivenessData)
    }

    private func updateOptimalTimingData(interactionTime: Date, action: NotificationAction) async throws {
        var timingData = loadOptimalTimingData()

        let record = TimingRecord(
            timestamp: interactionTime,
            wasInteracted: action != .ignored && action != .dismissed
        )

        timingData.append(record)

        // Keep only last 500 records
        if timingData.count > 500 {
            timingData = Array(timingData.suffix(500))
        }

        guard let data = try? JSONEncoder().encode(timingData) else { return }
        userDefaults.set(data, forKey: Keys.optimalTimingData)
    }

    private func loadOptimalTimingData() -> [TimingRecord] {
        guard let data = userDefaults.data(forKey: Keys.optimalTimingData),
              let records = try? JSONDecoder().decode([TimingRecord].self, from: data)
        else {
            return []
        }
        return records
    }

    private func saveSnoozeRecord(_ record: SnoozeRecord) async throws {
        var snoozeData = userDefaults.object(forKey: "snooze_records") as? [[String: Any]] ?? []

        let recordDict: [String: Any] = [
            "identifier": record.identifier,
            "duration": record.duration.rawValue,
            "count": record.snoozeCount,
            "timestamp": record.timestamp.timeIntervalSince1970,
        ]

        snoozeData.append(recordDict)

        // Keep only last 200 records
        if snoozeData.count > 200 {
            snoozeData = Array(snoozeData.suffix(200))
        }

        userDefaults.set(snoozeData, forKey: "snooze_records")
    }

    private func updateSnoozePatterns(for identifier: String, count: Int) async throws {
        var patterns = userDefaults.object(forKey: "snooze_patterns") as? [String: Int] ?? [:]
        patterns[identifier] = count
        userDefaults.set(patterns, forKey: "snooze_patterns")
    }

    // MARK: - Analytics Calculations

    private func calculateAverageResponseTime(from interactions: [String: InteractionRecord]) -> TimeInterval {
        let responseTimes = interactions.values.compactMap { record -> TimeInterval? in
            guard record.responseTime > 0, record.action != .ignored else { return nil }
            return record.responseTime
        }

        guard !responseTimes.isEmpty else { return 0 }
        return responseTimes.reduce(0, +) / Double(responseTimes.count)
    }

    private func calculateEffectiveTimes(from timingData: [TimingRecord]) -> (Date?, Date?) {
        let interactedRecords = timingData.filter(\.wasInteracted)
        guard !interactedRecords.isEmpty else { return (nil, nil) }

        let calendar = Calendar.current
        var hourCounts: [Int: Int] = [:]

        for record in interactedRecords {
            let hour = calendar.component(.hour, from: record.timestamp)
            hourCounts[hour, default: 0] += 1
        }

        let mostEffectiveHour = hourCounts.max(by: { $0.value < $1.value })?.key
        let leastEffectiveHour = hourCounts.min(by: { $0.value < $1.value })?.key

        var mostEffectiveTime: Date?
        var leastEffectiveTime: Date?

        if let hour = mostEffectiveHour {
            mostEffectiveTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date())
        }

        if let hour = leastEffectiveHour {
            leastEffectiveTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date())
        }

        return (mostEffectiveTime, leastEffectiveTime)
    }

    private func calculateInteractionRateByType(
        from history: [NotificationHistoryEntry],
        interactions _: [String: InteractionRecord]
    ) -> [ReminderType: Double] {
        var ratesByType: [ReminderType: Double] = [:]

        for type in ReminderType.allCases {
            let typeHistory = history.filter { $0.type == type }
            let interactedCount = typeHistory.count(where: { entry in
                // In real implementation, would check interactions by matching identifier
                entry.interactionDate != nil
            })

            let rate = Double(interactedCount) / Double(max(typeHistory.count, 1))
            ratesByType[type] = rate
        }

        return ratesByType
    }

    private func calculateSnoozePattersByType() -> [ReminderType: Int] {
        let patterns = userDefaults.object(forKey: "snooze_patterns") as? [String: Int] ?? [:]

        var snoozeByType: [ReminderType: Int] = [:]
        for type in ReminderType.allCases {
            // In real implementation, would aggregate by type from identifier patterns
            snoozeByType[type] = patterns.values.reduce(0, +) / ReminderType.allCases.count
        }

        return snoozeByType
    }
}

// MARK: - Supporting Data Types

private struct InteractionRecord: Codable {
    let action: NotificationAction
    let timestamp: Date
    let responseTime: TimeInterval
}

private struct TimingRecord: Codable {
    let timestamp: Date
    let wasInteracted: Bool
}

private struct SnoozeRecord: Codable {
    let identifier: String
    let duration: SnoozeDuration
    let snoozeCount: Int
    let timestamp: Date
}

/// Effectiveness metrics for notification types
public struct EffectivenessMetrics: Sendable {
    public let deliveryRate: Double
    public let interactionRate: Double
    public let averageResponseTime: TimeInterval
    public let totalScheduled: Int
    public let totalDelivered: Int

    public var effectiveness: Double {
        // Combined score weighted 60% interaction rate, 40% delivery rate
        (interactionRate * 0.6) + (deliveryRate * 0.4)
    }
}

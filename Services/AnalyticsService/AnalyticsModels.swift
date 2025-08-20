//
// Layer: Services
// Module: AnalyticsService
// Purpose: Data models and types for analytics operations
//

import Foundation

// MARK: - Analytics Data Models

public struct DashboardData: Codable {
    public let totalItems: Int
    public let totalValue: Decimal
    public let categoryBreakdown: [CategoryBreakdown]
    public let topValueItemIds: [UUID]
    public let recentItemIds: [UUID]
    public let valueTrends: [TrendPoint]
    public let totalDepreciation: Decimal
    public let lastUpdated: Date

    // Non-Codable computed properties for UI
    public var topValueItems: [Item] = []
    public var recentItems: [Item] = []

    enum CodingKeys: String, CodingKey {
        case totalItems, totalValue, categoryBreakdown
        case topValueItemIds, recentItemIds, valueTrends
        case totalDepreciation, lastUpdated
    }
}

public struct CategoryBreakdown: Codable, Sendable {
    public var categoryName: String
    public var itemCount: Int
    public var totalValue: Decimal
    public var percentage: Double
}

public struct TrendPoint: Codable, Sendable {
    public let date: Date
    public let value: Decimal
    public let itemCount: Int
}

public struct DepreciationReport {
    public let itemId: UUID
    public let itemName: String
    public let originalValue: Decimal
    public let currentValue: Decimal
    public let totalDepreciation: Decimal
    public let depreciationRate: Double
    public let ageInYears: Int
}

public enum TrendPeriod {
    case daily
    case weekly
    case monthly
    case yearly

    func intervals(from date: Date) -> [(start: Date, end: Date)] {
        let calendar = Calendar.current
        var intervals: [(Date, Date)] = []

        switch self {
        case .daily:
            for i in 0 ..< 30 {
                let start = calendar.date(byAdding: .day, value: -i, to: date)!
                let end = calendar.date(byAdding: .day, value: 1, to: start)!
                intervals.append((start, end))
            }
        case .weekly:
            for i in 0 ..< 12 {
                let start = calendar.date(byAdding: .weekOfYear, value: -i, to: date)!
                let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
                intervals.append((start, end))
            }
        case .monthly:
            for i in 0 ..< 12 {
                let start = calendar.date(byAdding: .month, value: -i, to: date)!
                let end = calendar.date(byAdding: .month, value: 1, to: start)!
                intervals.append((start, end))
            }
        case .yearly:
            for i in 0 ..< 5 {
                let start = calendar.date(byAdding: .year, value: -i, to: date)!
                let end = calendar.date(byAdding: .year, value: 1, to: start)!
                intervals.append((start, end))
            }
        }

        return intervals.reversed()
    }
}

public struct AnalyticsEvent {
    public let name: String
    public let parameters: [String: Any]
    public let timestamp: Date

    public init(name: String, parameters: [String: Any] = [:]) {
        self.name = name
        self.parameters = parameters
        timestamp = Date()
    }
}

extension AnalyticsEvent {
    public static func itemAdded(itemId: UUID, value: Decimal?) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "item_added",
            parameters: [
                "item_id": itemId.uuidString,
                "value": value?.description ?? "0",
            ],
        )
    }

    public static func itemDeleted(itemId: UUID) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "item_deleted",
            parameters: ["item_id": itemId.uuidString],
        )
    }

    public static func categoryCreated(name: String) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "category_created",
            parameters: ["name": name],
        )
    }

    public static func exportCompleted(format: String, itemCount: Int) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "export_completed",
            parameters: [
                "format": format,
                "item_count": itemCount,
            ],
        )
    }

    public static func syncCompleted(result: String) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "sync_completed",
            parameters: [
                "result": result,
                "timestamp": Date().timeIntervalSince1970,
            ],
        )
    }
}

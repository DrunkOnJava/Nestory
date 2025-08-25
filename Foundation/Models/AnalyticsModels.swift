//
// Layer: Foundation
// Module: Models
// Purpose: Core data models for analytics operations
//

import Foundation

// MARK: - Analytics Data Models

public struct DashboardData: Codable, Equatable, Sendable {
    public let totalItems: Int
    public let totalValue: Decimal
    public let categoryBreakdowns: [CategoryBreakdown]
    public let topValueItemIds: [UUID]
    public let recentItemIds: [UUID]
    public let valueTrends: [TrendPoint]
    public let totalDepreciation: Decimal
    public let lastUpdated: Date
    public let insights: [AnalyticsInsight]

    public init(
        totalItems: Int,
        totalValue: Decimal,
        categoryBreakdowns: [CategoryBreakdown],
        topValueItemIds: [UUID] = [],
        recentItemIds: [UUID] = [],
        valueTrends: [TrendPoint] = [],
        totalDepreciation: Decimal = 0,
        lastUpdated: Date = Date(),
        insights: [AnalyticsInsight] = []
    ) {
        self.totalItems = totalItems
        self.totalValue = totalValue
        self.categoryBreakdowns = categoryBreakdowns
        self.topValueItemIds = topValueItemIds
        self.recentItemIds = recentItemIds
        self.valueTrends = valueTrends
        self.totalDepreciation = totalDepreciation
        self.lastUpdated = lastUpdated
        self.insights = insights
    }
}

public struct CategoryBreakdown: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let categoryName: String
    public let itemCount: Int
    public let totalValue: Decimal
    public let percentage: Double
    
    public init(categoryName: String, itemCount: Int, totalValue: Decimal, percentage: Double) {
        self.id = UUID()
        self.categoryName = categoryName
        self.itemCount = itemCount
        self.totalValue = totalValue
        self.percentage = percentage
    }
}

public struct TrendPoint: Codable, Sendable, Equatable {
    public let date: Date
    public let value: Decimal
    public let itemCount: Int
    
    public init(date: Date, value: Decimal, itemCount: Int) {
        self.date = date
        self.value = value
        self.itemCount = itemCount
    }
}

public struct AnalyticsInsight: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let title: String
    public let description: String
    public let category: InsightCategory
    public let severity: InsightSeverity
    public let actionRequired: Bool
    public let createdAt: Date
    
    public init(
        title: String,
        description: String,
        category: InsightCategory,
        severity: InsightSeverity = .info,
        actionRequired: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.category = category
        self.severity = severity
        self.actionRequired = actionRequired
        self.createdAt = createdAt
    }
}

public enum InsightCategory: String, Codable, Sendable, CaseIterable {
    case coverage = "coverage"
    case documentation = "documentation"
    case value = "value"
    case organization = "organization"
    case maintenance = "maintenance"
}

public enum InsightSeverity: String, Codable, Sendable, CaseIterable {
    case info = "info"
    case warning = "warning"
    case critical = "critical"
}

public struct DepreciationReport: Codable, Sendable, Equatable {
    public let itemId: UUID
    public let itemName: String
    public let originalValue: Decimal
    public let currentValue: Decimal
    public let totalDepreciation: Decimal
    public let depreciationRate: Double
    public let ageInYears: Int
    
    public init(
        itemId: UUID,
        itemName: String,
        originalValue: Decimal,
        currentValue: Decimal,
        totalDepreciation: Decimal,
        depreciationRate: Double,
        ageInYears: Int
    ) {
        self.itemId = itemId
        self.itemName = itemName
        self.originalValue = originalValue
        self.currentValue = currentValue
        self.totalDepreciation = totalDepreciation
        self.depreciationRate = depreciationRate
        self.ageInYears = ageInYears
    }
}

public enum TrendPeriod: String, Codable, Sendable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"

    public func intervals(from date: Date) -> [(start: Date, end: Date)] {
        let calendar = Calendar.current
        var intervals: [(Date, Date)] = []

        switch self {
        case .daily:
            for i in 0..<30 {
                let start = calendar.date(byAdding: .day, value: -i, to: date)!
                let end = calendar.date(byAdding: .day, value: 1, to: start)!
                intervals.append((start, end))
            }
        case .weekly:
            for i in 0..<12 {
                let start = calendar.date(byAdding: .weekOfYear, value: -i, to: date)!
                let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
                intervals.append((start, end))
            }
        case .monthly:
            for i in 0..<12 {
                let start = calendar.date(byAdding: .month, value: -i, to: date)!
                let end = calendar.date(byAdding: .month, value: 1, to: start)!
                intervals.append((start, end))
            }
        case .yearly:
            for i in 0..<5 {
                let start = calendar.date(byAdding: .year, value: -i, to: date)!
                let end = calendar.date(byAdding: .year, value: 1, to: start)!
                intervals.append((start, end))
            }
        }

        return intervals.reversed()
    }
}

public struct AnalyticsEvent: Sendable {
    public let name: String
    public let parameters: [String: String] // Simplified to String for Sendable
    public let timestamp: Date

    public init(name: String, parameters: [String: String] = [:]) {
        self.name = name
        self.parameters = parameters
        self.timestamp = Date()
    }
}

extension AnalyticsEvent {
    public static func itemAdded(itemId: UUID, value: Decimal?) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "item_added",
            parameters: [
                "item_id": itemId.uuidString,
                "value": value?.description ?? "0"
            ]
        )
    }

    public static func itemDeleted(itemId: UUID) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "item_deleted",
            parameters: ["item_id": itemId.uuidString]
        )
    }

    public static func categoryCreated(name: String) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "category_created",
            parameters: ["name": name]
        )
    }

    public static func exportCompleted(format: String, itemCount: Int) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "export_completed",
            parameters: [
                "format": format,
                "item_count": String(itemCount)
            ]
        )
    }

    public static func syncCompleted(result: String) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "sync_completed",
            parameters: [
                "result": result,
                "timestamp": String(Date().timeIntervalSince1970)
            ]
        )
    }
}
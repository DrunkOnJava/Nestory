// Layer: Services
// Module: AnalyticsService
// Purpose: Analytics and dashboard calculations

import Foundation
import os.log
import SwiftData

public protocol AnalyticsService {
    func calculateTotalValue(for items: [Item]) async -> Decimal
    func calculateCategoryBreakdown(for items: [Item]) async -> [CategoryBreakdown]
    func calculateValueTrends(for items: [Item], period: TrendPeriod) async -> [TrendPoint]
    func calculateTopItems(from items: [Item], limit: Int) async -> [Item]
    func calculateDepreciation(for items: [Item]) async -> [DepreciationReport]
    func generateDashboard(for items: [Item]) async -> DashboardData
    func trackEvent(_ event: AnalyticsEvent) async
}

public struct LiveAnalyticsService: AnalyticsService {
    private let cache: Cache<String, DashboardData>
    private let logger = Logger(subsystem: "com.nestory", category: "AnalyticsService")
    private let currencyService: CurrencyService

    public init(currencyService: CurrencyService) throws {
        cache = try Cache(name: "analytics", maxMemoryCount: 50, ttl: 300)
        self.currencyService = currencyService
    }

    public func calculateTotalValue(for items: [Item]) async -> Decimal {
        let signpost = OSSignposter()
        let state = signpost.beginInterval("calculate_total_value", id: signpost.makeSignpostID())
        defer { signpost.endInterval("calculate_total_value", state) }

        var totalValue: Decimal = 0

        for item in items {
            if let price = item.purchasePrice {
                let quantity = Decimal(item.quantity)
                let itemValue = price * quantity

                if let currency = item.currency, currency != "USD" {
                    if let convertedValue = try? await currencyService.convert(
                        amount: itemValue,
                        from: currency,
                        to: "USD"
                    ) {
                        totalValue += convertedValue
                    } else {
                        totalValue += itemValue
                    }
                } else {
                    totalValue += itemValue
                }
            }
        }

        logger.debug("Calculated total value: \(totalValue)")
        return totalValue
    }

    public func calculateCategoryBreakdown(for items: [Item]) async -> [CategoryBreakdown] {
        var categoryMap: [String: CategoryBreakdown] = [:]

        for item in items {
            let categoryName = item.category?.name ?? "Uncategorized"

            var breakdown = categoryMap[categoryName] ?? CategoryBreakdown(
                categoryName: categoryName,
                itemCount: 0,
                totalValue: 0,
                percentage: 0
            )

            breakdown.itemCount += 1

            if let price = item.purchasePrice {
                let itemValue = price * Decimal(item.quantity)

                if let currency = item.currency, currency != "USD" {
                    if let convertedValue = try? await currencyService.convert(
                        amount: itemValue,
                        from: currency,
                        to: "USD"
                    ) {
                        breakdown.totalValue += convertedValue
                    } else {
                        breakdown.totalValue += itemValue
                    }
                } else {
                    breakdown.totalValue += itemValue
                }
            }

            categoryMap[categoryName] = breakdown
        }

        let totalValue = categoryMap.values.reduce(Decimal(0)) { $0 + $1.totalValue }

        for key in categoryMap.keys {
            if totalValue > 0 {
                categoryMap[key]?.percentage = Double(truncating: (categoryMap[key]!.totalValue / totalValue * 100) as NSNumber)
            }
        }

        return Array(categoryMap.values).sorted { $0.totalValue > $1.totalValue }
    }

    public func calculateValueTrends(for items: [Item], period: TrendPeriod) async -> [TrendPoint] {
        let calendar = Calendar.current
        let now = Date()
        var trendPoints: [TrendPoint] = []

        let intervals = period.intervals(from: now)

        for interval in intervals {
            let itemsInInterval = items.filter { item in
                guard let purchaseDate = item.purchaseDate else { return false }
                return purchaseDate >= interval.start && purchaseDate < interval.end
            }

            let value = await calculateTotalValue(for: itemsInInterval)

            trendPoints.append(TrendPoint(
                date: interval.start,
                value: value,
                itemCount: itemsInInterval.count
            ))
        }

        logger.debug("Calculated \(trendPoints.count) trend points for \(period)")
        return trendPoints
    }

    public func calculateTopItems(from items: [Item], limit: Int = 10) async -> [Item] {
        let sortedItems = items.sorted { item1, item2 in
            let value1 = (item1.purchasePrice ?? 0) * Decimal(item1.quantity)
            let value2 = (item2.purchasePrice ?? 0) * Decimal(item2.quantity)
            return value1 > value2
        }

        return Array(sortedItems.prefix(limit))
    }

    public func calculateDepreciation(for items: [Item]) async -> [DepreciationReport] {
        var reports: [DepreciationReport] = []

        for item in items {
            guard let purchasePrice = item.purchasePrice,
                  let purchaseDate = item.purchaseDate
            else {
                continue
            }

            let ageInYears = Calendar.current.dateComponents(
                [.year],
                from: purchaseDate,
                to: Date()
            ).year ?? 0

            let depreciationRate = item.depreciationRate ?? 0.15
            let currentValue = purchasePrice * pow(Decimal(1 - depreciationRate), ageInYears)
            let totalDepreciation = purchasePrice - currentValue

            reports.append(DepreciationReport(
                itemId: item.id,
                itemName: item.name,
                originalValue: purchasePrice,
                currentValue: currentValue,
                totalDepreciation: totalDepreciation,
                depreciationRate: depreciationRate,
                ageInYears: ageInYears
            ))
        }

        return reports.sorted { $0.totalDepreciation > $1.totalDepreciation }
    }

    public func generateDashboard(for items: [Item]) async -> DashboardData {
        let cacheKey = "dashboard_\(items.count)"

        if let cached = await cache.get(for: cacheKey) {
            logger.debug("Returning cached dashboard data")
            return cached
        }

        let signpost = OSSignposter()
        let state = signpost.beginInterval("generate_dashboard", id: signpost.makeSignpostID())
        defer { signpost.endInterval("generate_dashboard", state) }

        async let totalValue = calculateTotalValue(for: items)
        async let categoryBreakdown = calculateCategoryBreakdown(for: items)
        async let topItems = calculateTopItems(from: items, limit: 5)
        async let monthlyTrends = calculateValueTrends(for: items, period: .monthly)
        async let depreciationReports = calculateDepreciation(for: items)

        let (value, categories, top, trends, depreciation) = await (
            totalValue,
            categoryBreakdown,
            topItems,
            monthlyTrends,
            depreciationReports
        )

        let recentItems = items
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(10)
            .map(\.self)

        let dashboard = DashboardData(
            totalItems: items.count,
            totalValue: value,
            categoryBreakdown: categories,
            topValueItems: top,
            recentItems: recentItems,
            valueTrends: trends,
            totalDepreciation: depreciation.reduce(Decimal(0)) { $0 + $1.totalDepreciation },
            lastUpdated: Date()
        )

        await cache.set(dashboard, for: cacheKey)

        logger.info("Generated dashboard with \(items.count) items")
        return dashboard
    }

    public func trackEvent(_ event: AnalyticsEvent) async {
        logger.info("Analytics event: \(event.name) - \(event.parameters)")

        UserDefaults.standard.set(
            UserDefaults.standard.integer(forKey: "analytics.\(event.name)") + 1,
            forKey: "analytics.\(event.name)"
        )
    }
}

public struct DashboardData: Codable {
    public let totalItems: Int
    public let totalValue: Decimal
    public let categoryBreakdown: [CategoryBreakdown]
    public let topValueItems: [Item]
    public let recentItems: [Item]
    public let valueTrends: [TrendPoint]
    public let totalDepreciation: Decimal
    public let lastUpdated: Date
}

public struct CategoryBreakdown: Codable {
    public var categoryName: String
    public var itemCount: Int
    public var totalValue: Decimal
    public var percentage: Double
}

public struct TrendPoint: Codable {
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

public extension AnalyticsEvent {
    static func itemAdded(itemId: UUID, value: Decimal?) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "item_added",
            parameters: [
                "item_id": itemId.uuidString,
                "value": value?.description ?? "0",
            ]
        )
    }

    static func itemDeleted(itemId: UUID) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "item_deleted",
            parameters: ["item_id": itemId.uuidString]
        )
    }

    static func categoryCreated(name: String) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "category_created",
            parameters: ["name": name]
        )
    }

    static func exportCompleted(format: String, itemCount: Int) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "export_completed",
            parameters: [
                "format": format,
                "item_count": itemCount,
            ]
        )
    }

    static func syncCompleted(result: SyncResult) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "sync_completed",
            parameters: [
                "pushed": result.pushedCount,
                "pulled": result.pulledCount,
                "conflicts": result.conflictsResolved,
            ]
        )
    }
}

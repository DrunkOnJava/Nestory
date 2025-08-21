// Layer: Services
// Module: AnalyticsService
// Purpose: Live implementation of analytics service with calculations and dashboard generation

import Foundation
import os.log
import SwiftData

public struct LiveAnalyticsService: AnalyticsService, Sendable {
    private let cache: Cache<String, DashboardData>
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "AnalyticsService")
    let currencyService: any CurrencyService
    let resilientExecutor = ResilientOperationExecutor()

    // Enhanced caching system for better performance
    // Currency conversion cache to avoid repeated API calls
    let conversionCache: SmartCache<String, Decimal>

    public init(currencyService: any CurrencyService) throws {
        cache = try Cache(name: "analytics", maxMemoryCount: 50, ttl: 300)
        conversionCache = try SmartCache(
            name: "currency-conversions",
            maxMemoryCount: 200,
            defaultTTL: CacheConstants.TTL.medium,
            enablePredictiveLoading: true,
        )
        self.currencyService = currencyService
    }

    public nonisolated func calculateTotalValue(for items: [Item]) async -> Decimal {
        let signpost = OSSignposter()
        let state = signpost.beginInterval("calculate_total_value", id: signpost.makeSignpostID())
        defer { signpost.endInterval("calculate_total_value", state) }

        guard !items.isEmpty else {
            logger.debug("No items provided for total value calculation")
            return 0
        }

        var totalValue: Decimal = 0
        var conversionFailures = 0
        let totalItems = items.count

        for item in items {
            guard let purchasePrice = item.purchasePrice else {
                continue // Skip items without purchase prices
            }

            let currencyCode = item.currency

            if currencyCode != "USD" {
                // Attempt currency conversion with comprehensive error handling
                do {
                    let convertedValue = try await convertCurrencyWithFallback(
                        amount: purchasePrice,
                        from: currencyCode,
                        to: "USD",
                        itemName: item.name,
                    )
                    totalValue += convertedValue
                } catch {
                    conversionFailures += 1
                    logger.warning("Currency conversion failed for \(item.name): \(error)")

                    // Fallback: Use original value with warning
                    totalValue += purchasePrice
                }
            } else {
                totalValue += purchasePrice
            }
        }

        if conversionFailures > 0 {
            let failureRate = Double(conversionFailures) / Double(totalItems)
            if failureRate > 0.5 {
                logger.error("High currency conversion failure rate: \(conversionFailures)/\(totalItems)")
            } else {
                logger.info("Some currency conversions failed: \(conversionFailures)/\(totalItems)")
            }
        }

        logger.debug("Calculated total value: \(totalValue) (with \(conversionFailures) conversion failures)")
        return totalValue
    }

    public nonisolated func calculateCategoryBreakdown(for items: [Item]) async -> [CategoryBreakdown] {
        var categoryMap: [String: CategoryBreakdown] = [:]

        for item in items {
            let categoryName = item.category?.name ?? "Uncategorized"

            var breakdown = categoryMap[categoryName] ?? CategoryBreakdown(
                categoryName: categoryName,
                itemCount: 0,
                totalValue: 0,
                percentage: 0,
            )

            breakdown.itemCount += 1

            if let purchasePrice = item.purchasePrice {
                let itemValue = purchasePrice
                let currencyCode = item.currency

                if currencyCode != "USD" {
                    if let convertedValue = try? await currencyService.convert(
                        amount: itemValue,
                        from: currencyCode,
                        to: "USD",
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
                let categoryValue = categoryMap[key]!.totalValue
                let percentage = Double(truncating: (categoryValue / totalValue * 100) as NSNumber)
                categoryMap[key]?.percentage = percentage
            }
        }

        return Array(categoryMap.values).sorted { $0.totalValue > $1.totalValue }
    }

    public nonisolated func calculateValueTrends(for items: [Item], period: TrendPeriod) async -> [TrendPoint] {
        _ = Calendar.current
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
                itemCount: itemsInInterval.count,
            ))
        }

        logger.debug("Calculated \(trendPoints.count) trend points for \(String(describing: period))")
        return trendPoints
    }

    public nonisolated func calculateTopItems(from items: [Item], limit: Int = 10) async -> [Item] {
        let sortedItems = items.sorted { item1, item2 in
            let value1 = item1.purchasePrice ?? 0
            let value2 = item2.purchasePrice ?? 0
            return value1 > value2
        }

        return Array(sortedItems.prefix(limit))
    }

    public nonisolated func calculateDepreciation(for items: [Item]) async -> [DepreciationReport] {
        // APPLE_FRAMEWORK_OPPORTUNITY: Replace with Accelerate Framework - Use vDSP functions for batch mathematical operations on depreciation calculations
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
                to: Date(),
            ).year ?? 0

            let depreciationRate = Decimal(0.15) // Default 15% annual depreciation
            let depreciationMultiplier = Decimal(1) - depreciationRate
            let depreciationDouble = NSDecimalNumber(decimal: depreciationMultiplier).doubleValue
            let currentValue = purchasePrice * Decimal(pow(depreciationDouble, Double(ageInYears)))
            let totalDepreciation = purchasePrice - currentValue

            reports.append(DepreciationReport(
                itemId: item.id,
                itemName: item.name,
                originalValue: purchasePrice,
                currentValue: currentValue,
                totalDepreciation: totalDepreciation,
                depreciationRate: Double(truncating: depreciationRate as NSNumber),
                ageInYears: ageInYears,
            ))
        }

        return reports.sorted { $0.totalDepreciation > $1.totalDepreciation }
    }

    public nonisolated func generateDashboard(for items: [Item]) async -> DashboardData {
        let cacheKey = "dashboard_\(items.count)"

        if let cached = await cache.get(for: cacheKey) {
            logger.debug("Returning cached dashboard data")
            return cached
        }

        let signpost = OSSignposter()
        let state = signpost.beginInterval("generate_dashboard", id: signpost.makeSignpostID())
        defer { signpost.endInterval("generate_dashboard", state) }

        // Calculate all values sequentially to avoid data races with non-Sendable Item
        let value = await calculateTotalValue(for: items)
        let categories = await calculateCategoryBreakdown(for: items)
        let top = await calculateTopItems(from: items, limit: 5)
        let trends = await calculateValueTrends(for: items, period: .monthly)
        let depreciation = await calculateDepreciation(for: items)

        let recentItems = items
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(10)
            .map(\.self)

        var dashboard = DashboardData(
            totalItems: items.count,
            totalValue: value,
            categoryBreakdown: categories,
            topValueItemIds: top.map(\.id),
            recentItemIds: Array(recentItems.map(\.id)),
            valueTrends: trends,
            totalDepreciation: depreciation.reduce(Decimal(0)) { $0 + $1.totalDepreciation },
            lastUpdated: Date(),
        )

        // Set non-Codable properties for immediate use
        dashboard.topValueItems = top
        dashboard.recentItems = Array(recentItems)

        await cache.set(dashboard, for: cacheKey)

        logger.info("Generated dashboard with \(items.count) items")
        return dashboard
    }

    public nonisolated func trackEvent(_ event: AnalyticsEvent) async {
        logger.info("Analytics event: \(event.name) - \(event.parameters)")

        UserDefaults.standard.set(
            UserDefaults.standard.integer(forKey: "analytics.\(event.name)") + 1,
            forKey: "analytics.\(event.name)",
        )
    }

    // Currency operations have been moved to AnalyticsCurrencyOperations.swift
}

//
// Layer: App-Main
// Module: AnalyticsViews
// Purpose: Provide analytics calculations and computed properties
//

import Foundation
import SwiftData

class AnalyticsDataProvider: ObservableObject {
    let items: [Item]
    let categories: [Category]
    let selectedTimeRange: TimeRange

    init(items: [Item], categories: [Category], timeRange: TimeRange = .month) {
        self.items = items
        self.categories = categories
        selectedTimeRange = timeRange
    }

    // MARK: - Time Range

    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case all = "All Time"

        var days: Int {
            switch self {
            case .week:
                7
            case .month:
                30
            case .year:
                365
            case .all:
                9999
            }
        }
    }

    // MARK: - Computed Values

    var totalValue: Decimal {
        items.compactMap(\.purchasePrice).reduce(0, +)
    }

    var averageValue: Decimal {
        let total = totalValue
        let itemsWithPrices = items.filter { $0.purchasePrice != nil }
        return !itemsWithPrices.isEmpty ? total / Decimal(itemsWithPrices.count) : 0
    }

    var categoriesWithItems: [Category] {
        categories.filter { category in
            items.contains { $0.category?.id == category.id }
        }
    }

    var itemsNeedingDocumentation: [Item] {
        items.filter { $0.serialNumber == nil || $0.purchasePrice == nil || $0.imageData == nil }
    }

    var mostValuableCategory: Category? {
        var categoryValues: [Category: Decimal] = [:]

        for item in items {
            if let category = item.category,
               let price = item.purchasePrice
            {
                categoryValues[category, default: 0] += price * Decimal(item.quantity)
            }
        }

        return categoryValues.max { $0.value < $1.value }?.key
    }

    var recentItems: [Item] {
        let cutoffDate = Calendar.current.date(
            byAdding: .day,
            value: -selectedTimeRange.days,
            to: Date(),
        ) ?? Date()
        return items.filter { $0.createdAt > cutoffDate }
    }

    var recentlyAddedCount: Int {
        let cutoffDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return items.count { $0.createdAt > cutoffDate }
    }

    var uncategorizedCount: Int {
        items.count { $0.category == nil }
    }

    // MARK: - Chart Data

    func categoryDistributionData() -> [(category: Category, count: Int)] {
        categoriesWithItems.map { category in
            let count = items.count { $0.category?.id == category.id }
            return (category, count)
        }
    }

    func valueByCategoryData() -> [(category: Category, value: Decimal)] {
        categoriesWithItems.compactMap { category in
            let categoryItems = items.filter { $0.category?.id == category.id }
            let value = categoryItems.compactMap(\.purchasePrice).reduce(0, +)
            return value > 0 ? (category, value) : nil
        }
        .sorted { $0.value > $1.value }
        .prefix(5)
        .reversed()
    }

    func statusData() -> [(label: String, count: Int, color: String)] {
        let fullyDocumented = items.count { item in
            item.imageData != nil && item.purchasePrice != nil && item.serialNumber != nil
        }
        let partiallyDocumented = items.count { item in
            (item.imageData != nil || item.purchasePrice != nil || item.serialNumber != nil) &&
                !(item.imageData != nil && item.purchasePrice != nil && item.serialNumber != nil)
        }
        let needsDocumentation = items.count { item in
            item.imageData == nil && item.purchasePrice == nil && item.serialNumber == nil
        }

        return [
            ("Complete", fullyDocumented, "green"),
            ("Partial", partiallyDocumented, "orange"),
            ("Missing", needsDocumentation, "red"),
        ]
    }
}

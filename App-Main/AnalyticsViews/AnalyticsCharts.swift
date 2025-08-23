//
// Layer: App-Main
// Module: AnalyticsViews
// Purpose: Chart visualizations for analytics dashboard
//

import Charts
import SwiftData
import SwiftUI

// MARK: - Chart Container

struct ChartContainer<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            content
                .frame(height: 200)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
        }
    }
}

// MARK: - Category Distribution Chart

struct CategoryDistributionChart: View {
    let categories: [Category]
    let items: [Item]

    init(categories: [Category], items: [Item] = []) {
        self.categories = categories
        self.items = items
    }

    var categoryData: [(category: Category, count: Int)] {
        categories.map { category in
            let count = items.count { $0.category?.id == category.id }
            return (category, count)
        }
        .filter { $0.count > 0 } // Only show categories with items
    }

    var body: some View {
        if categoryData.isEmpty {
            Text("No category data available")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart(categoryData, id: \.category.id) { data in
                SectorMark(
                    angle: .value("Count", data.count),
                    innerRadius: .ratio(0.5)
                )
                .foregroundStyle(Color(hex: data.category.colorHex) ?? .blue)
                .annotation(position: .overlay) {
                    if data.count > 0 {
                        Text("\(data.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            .chartLegend(position: .bottom, alignment: .center, spacing: 8)
        }
    }
}

// MARK: - Value by Category Chart

struct ValueByCategoryChart: View {
    let categories: [Category]
    let items: [Item]

    var categoryData: [(category: Category, value: Decimal)] {
        categories.compactMap { category in
            let categoryItems = items.filter { $0.category?.id == category.id }
            let value = categoryItems.compactMap(\.purchasePrice).reduce(0, +)
            return value > 0 ? (category, value) : nil
        }
        .sorted { $0.value > $1.value }
        .prefix(5)
        .reversed()
    }

    var body: some View {
        if categoryData.isEmpty {
            Text("No value data available")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart(categoryData, id: \.category.id) { data in
                BarMark(
                    x: .value("Value", data.value),
                    y: .value("Category", data.category.name)
                )
                .foregroundStyle(Color(hex: data.category.colorHex) ?? .blue)
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .currency(code: "USD"))
                }
            }
        }
    }
}

// MARK: - Recent Activity Chart

struct RecentActivityChart: View {
    let items: [Item]
    let timeRange: AnalyticsDataProvider.TimeRange

    var activityData: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        var groupedItems: [Date: Int] = [:]

        for item in items {
            let startOfDay = calendar.startOfDay(for: item.createdAt)
            groupedItems[startOfDay, default: 0] += 1
        }

        return groupedItems.map { ($0.key, $0.value) }
            .sorted { $0.date < $1.date }
            .suffix(timeRange == .week ? 7 : 30)
    }

    var body: some View {
        if activityData.isEmpty {
            Text("No recent activity")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart(activityData, id: \.date) { data in
                LineMark(
                    x: .value("Date", data.date),
                    y: .value("Items", data.count),
                )
                .foregroundStyle(.blue)

                AreaMark(
                    x: .value("Date", data.date),
                    y: .value("Items", data.count),
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom,
                    ),
                )
            }
        }
    }
}

// MARK: - Item Status Chart

struct ItemStatusChart: View {
    let items: [Item]

    var statusData: [(label: String, count: Int, color: Color)] {
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
            ("Complete", fullyDocumented, .green),
            ("Partial", partiallyDocumented, .orange),
            ("Missing", needsDocumentation, .red),
        ]
    }

    var body: some View {
        HStack(spacing: 12) {
            ForEach(statusData, id: \.label) { data in
                VStack(spacing: 8) {
                    Text("\(data.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(data.color)

                    Text(data.label)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(data.color.opacity(0.2))
                        .frame(height: 60)
                        .overlay(
                            GeometryReader { geometry in
                                VStack {
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(data.color)
                                        .frame(
                                            height: geometry.size.height * CGFloat(data.count) /
                                                CGFloat(max(items.count, 1)),
                                        )
                                }
                            },
                        )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Enhanced Analytics Charts

// MARK: - Category Breakdown Chart

struct CategoryBreakdownChart: View {
    let breakdown: [CategoryBreakdown]

    var body: some View {
        if breakdown.isEmpty {
            Text("No category data available")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart(breakdown, id: \.categoryName) { data in
                SectorMark(
                    angle: .value("Value", data.totalValue),
                    innerRadius: .ratio(0.5)
                )
                .foregroundStyle(by: .value("Category", data.categoryName))
                .annotation(position: .overlay) {
                    if data.percentage > 5 { // Only show percentage if it's significant
                        Text("\(Int(data.percentage))%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            .chartLegend(position: .bottom, alignment: .center, spacing: 8)
        }
    }
}

// MARK: - Value Trends Chart

struct ValueTrendsChart: View {
    let trends: [TrendPoint]
    let period: TrendPeriod

    var body: some View {
        if trends.isEmpty {
            Text("No trend data available")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart(trends, id: \.date) { trend in
                LineMark(
                    x: .value("Date", trend.date),
                    y: .value("Value", trend.value)
                )
                .foregroundStyle(.blue)
                .symbol(.circle)

                AreaMark(
                    x: .value("Date", trend.date),
                    y: .value("Value", trend.value)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: xAxisStride)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .currency(code: "USD"))
                }
            }
        }
    }

    private var xAxisStride: Calendar.Component {
        switch period {
        case .weekly: .day
        case .monthly: .month
        case .yearly: .year
        default: .month
        }
    }
}

// MARK: - Top Items Chart

struct TopItemsChart: View {
    let items: [Item]

    var body: some View {
        if items.isEmpty {
            Text("No items available")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart(items, id: \.id) { item in
                BarMark(
                    x: .value("Value", item.purchasePrice ?? 0),
                    y: .value("Item", item.name)
                )
                .foregroundStyle(.blue)
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .currency(code: "USD"))
                }
            }
        }
    }
}

// MARK: - Depreciation Chart

struct DepreciationChart: View {
    let reports: [DepreciationReport]

    var displayReports: [DepreciationReport] {
        Array(reports.prefix(10)) // Show top 10 most depreciated items
    }

    var body: some View {
        if displayReports.isEmpty {
            Text("No depreciation data available")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart(displayReports, id: \.itemId) { report in
                BarMark(
                    x: .value("Depreciation", report.totalDepreciation),
                    y: .value("Item", report.itemName)
                )
                .foregroundStyle(.red)
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .currency(code: "USD"))
                }
            }
        }
    }
}

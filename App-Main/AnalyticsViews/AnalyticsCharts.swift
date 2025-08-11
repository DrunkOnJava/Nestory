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
    @Query private var items: [Item]

    var body: some View {
        Chart {
            ForEach(categories) { category in
                let count = items.count(where: { $0.category?.id == category.id })
                SectorMark(
                    angle: .value("Count", count),
                    innerRadius: .ratio(0.5),
                )
                .foregroundStyle(Color(hex: category.colorHex) ?? .blue)
                .annotation(position: .overlay) {
                    if !categories.isEmpty {
                        Text("\(count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
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
        Chart(categoryData, id: \.category.id) { data in
            BarMark(
                x: .value("Value", data.value),
                y: .value("Category", data.category.name),
            )
            .foregroundStyle(Color(hex: data.category.colorHex) ?? .blue)
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
        let fullyDocumented = items.count(where: { item in
            item.imageData != nil && item.purchasePrice != nil && item.serialNumber != nil
        })
        let partiallyDocumented = items.count(where: { item in
            (item.imageData != nil || item.purchasePrice != nil || item.serialNumber != nil) &&
                !(item.imageData != nil && item.purchasePrice != nil && item.serialNumber != nil)
        })
        let needsDocumentation = items.count(where: { item in
            item.imageData == nil && item.purchasePrice == nil && item.serialNumber == nil
        })

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
                                                CGFloat(max(items.count, 1))
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

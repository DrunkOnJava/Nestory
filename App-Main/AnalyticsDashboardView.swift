//
// Layer: App-Main
// Module: Analytics
// Purpose: Main analytics dashboard coordinator view
//

import Charts
import SwiftData
import SwiftUI

struct AnalyticsDashboardView: View {
    @Query private var items: [Item]
    @Query private var categories: [Category]
    @State private var selectedTimeRange: AnalyticsDataProvider.TimeRange = .month

    private var dataProvider: AnalyticsDataProvider {
        AnalyticsDataProvider(items: items, categories: categories, timeRange: selectedTimeRange)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Picker
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(AnalyticsDataProvider.TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Summary Cards
                    SummaryCardsView(
                        totalItems: items.count,
                        totalValue: dataProvider.totalValue,
                        categoriesCount: dataProvider.categoriesWithItems.count,
                        averageValue: dataProvider.averageValue,
                    )
                    .padding(.horizontal)

                    // Charts Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Category Distribution Chart
                        ChartContainer(title: "Category Distribution") {
                            CategoryDistributionChart(categories: dataProvider.categoriesWithItems)
                        }

                        // Value by Category Chart
                        ChartContainer(title: "Value by Category") {
                            ValueByCategoryChart(
                                categories: dataProvider.categoriesWithItems,
                                items: items,
                            )
                        }

                        // Recent Activity Chart
                        ChartContainer(title: "Recent Activity") {
                            RecentActivityChart(
                                items: dataProvider.recentItems,
                                timeRange: selectedTimeRange,
                            )
                        }

                        // Item Categories Overview
                        ChartContainer(title: "Item Status Overview") {
                            ItemStatusChart(items: items)
                        }
                    }
                    .padding(.horizontal)

                    // Insights Section
                    InsightsView(dataProvider: dataProvider)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    AnalyticsDashboardView()
        .modelContainer(for: [Item.self, Category.self], inMemory: true)
}

//
// Layer: Features
// Module: Analytics
// Purpose: TCA-driven Analytics Dashboard View
//

import Charts
import ComposableArchitecture
import SwiftData
import SwiftUI

public struct AnalyticsDashboardView: View {
    @Bindable var store: StoreOf<AnalyticsFeature>

    private var timeRangeMapping: [AnalyticsFeature.State.TimeRange: AnalyticsDataProvider.TimeRange] = [
        .week: .week,
        .month: .month,
        .quarter: .quarter,
        .year: .year,
        .all: .all,
    ]

    private var dataProvider: AnalyticsDataProvider {
        AnalyticsDataProvider(
            items: store.items,
            categories: store.categories,
            timeRange: timeRangeMapping[store.selectedTimeRange] ?? .month
        )
    }
    
    init(store: StoreOf<AnalyticsFeature>) {
        self.store = store
    }
    
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $store.selectedTimeRange.sending(\.timeRangeChanged)) {
            ForEach(AnalyticsFeature.State.TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var summaryCardsSection: some View {
        Group {
            if let summaryData = store.summaryData {
                SummaryCardsView(
                    totalItems: summaryData.totalItems,
                    totalValue: summaryData.totalValue,
                    categoriesCount: summaryData.categoriesCount,
                    averageValue: summaryData.averageValue
                )
                .padding(.horizontal)
            } else {
                let provider = dataProvider
                SummaryCardsView(
                    totalItems: store.totalItems,
                    totalValue: provider.totalValue,
                    categoriesCount: provider.categoriesWithItems.count,
                    averageValue: provider.averageValue
                )
                .padding(.horizontal)
            }
        }
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Picker
                    timeRangePicker
                        .padding(.horizontal)

                    // Summary Cards (using TCA state)
                    summaryCardsSection

                    // Enhanced Analytics Summary (using TCA dashboard data)
                    if let data = store.dashboardData {
                        EnhancedAnalyticsSummaryView(dashboardData: data)
                            .padding(.horizontal)
                    } else if store.isLoading {
                        ProgressView("Loading enhanced analytics...")
                            .frame(height: 100)
                            .padding(.horizontal)
                    }

                    // Charts Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Category Distribution Chart (existing)
                        ChartContainer(title: "Category Distribution") {
                            let categories = dataProvider.categoriesWithItems
                            CategoryDistributionChart(categories: categories)
                        }

                        // Value by Category Chart (using TCA state)
                        ChartContainer(title: "Value by Category") {
                            let categories = dataProvider.categoriesWithItems
                            let items = store.filteredItems
                            ValueByCategoryChart(categories: categories, items: items)
                        }

                        // Recent Activity Chart (using TCA state)
                        ChartContainer(title: "Recent Activity") {
                            let items = dataProvider.recentItems
                            let timeRange = timeRangeMapping[store.selectedTimeRange] ?? .month
                            RecentActivityChart(items: items, timeRange: timeRange)
                        }

                        // Item Status Overview (using TCA state)  
                        ChartContainer(title: "Item Status Overview") {
                            let items = store.filteredItems
                            ItemStatusChart(items: items)
                        }
                    }
                    .padding(.horizontal)

                    // Insights Section (using TCA state)
                    InsightsView(dataProvider: dataProvider)
                        .padding(.horizontal)

                    if let data = store.dashboardData {
                        EnhancedInsightsView(
                            dashboardData: data,
                            depreciationReports: []
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                store.send(.onAppear)
            }
            .refreshable {
                await store.send(.refresh).finish()
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

#Preview {
    AnalyticsDashboardView(
        store: Store(initialState: AnalyticsFeature.State()) {
            AnalyticsFeature()
        }
    )
}

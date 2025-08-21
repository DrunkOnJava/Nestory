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
    
    public init(store: StoreOf<AnalyticsFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Picker
                    Picker("Time Range", selection: $store.selectedTimeRange.sending(\.timeRangeChanged)) {
                        ForEach(AnalyticsFeature.State.TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Summary Cards (using TCA state)
                    if let summaryData = store.summaryData {
                        SummaryCardsView(
                            totalItems: summaryData.totalItems,
                            totalValue: summaryData.totalValue,
                            categoriesCount: summaryData.categoriesCount,
                            averageValue: summaryData.averageValue
                        )
                        .padding(.horizontal)
                    } else {
                        SummaryCardsView(
                            totalItems: store.totalItems,
                            totalValue: dataProvider.totalValue,
                            categoriesCount: dataProvider.categoriesWithItems.count,
                            averageValue: dataProvider.averageValue
                        )
                        .padding(.horizontal)
                    }

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
                            CategoryDistributionChart(categories: dataProvider.categoriesWithItems)
                        }

                        // Value by Category Chart (using TCA state)
                        ChartContainer(title: "Value by Category") {
                            if let chartsData = store.chartsData {
                                ValueByCategoryChart(
                                    categories: dataProvider.categoriesWithItems,
                                    items: store.filteredItems
                                )
                            } else {
                                ValueByCategoryChart(
                                    categories: dataProvider.categoriesWithItems,
                                    items: store.filteredItems
                                )
                            }
                        }

                        // Recent Activity Chart (using TCA state)
                        ChartContainer(title: "Recent Activity") {
                            RecentActivityChart(
                                items: dataProvider.recentItems,
                                timeRange: timeRangeMapping[store.selectedTimeRange] ?? .month
                            )
                        }

                        // Item Status Overview (using TCA state)
                        ChartContainer(title: "Item Status Overview") {
                            ItemStatusChart(items: store.filteredItems)
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

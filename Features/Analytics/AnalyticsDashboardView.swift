//
// Layer: Features
// Module: Analytics
// Purpose: TCA-driven Analytics Dashboard View
//

import Charts
import ComposableArchitecture
import SwiftData
import SwiftUI

// Temporary local implementation of SummaryCardsView
private struct SummaryCardsView: View {
    let totalItems: Int
    let totalValue: Decimal
    let categoriesCount: Int
    let averageValue: Decimal
    
    var body: some View {
        HStack(spacing: 16) {
            MetricCard(title: "Total Items", value: "\(totalItems)")
            MetricCard(title: "Total Value", value: "$\(totalValue)")
            MetricCard(title: "Categories", value: "\(categoriesCount)")
            MetricCard(title: "Avg Value", value: "$\(averageValue)")
        }
        .padding(.horizontal)
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

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
    
    private var warrantyAnalyticsSection: some View {
        ChartContainer(title: "Warranty Analytics") {
            let items = store.filteredItems
            WarrantyAnalyticsView(items: items)
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
                            CategoryDistributionChart(categories: categories, items: store.items)
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
                        
                        // Warranty Analytics Section
                        warrantyAnalyticsSection
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

// MARK: - Warranty Analytics View

private struct WarrantyAnalyticsView: View {
    let items: [Item]
    
    @State private var warrantyStats: WarrantyTrackingStatistics?
    @State private var categoryAnalysis: CategoryCoverageAnalysis?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading warranty analytics...")
                    .frame(height: 120)
            } else if let stats = warrantyStats {
                VStack(spacing: 16) {
                    // Warranty Status Overview Cards
                    warrantyStatusCards(stats: stats)
                    
                    // Category Coverage Analysis
                    if let analysis = categoryAnalysis {
                        warrantyCoverageByCategory(analysis: analysis)
                    }
                }
            } else {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.title)
                        .foregroundColor(.gray)
                    Text("No warranty data available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 80)
            }
        }
        .task {
            await loadWarrantyAnalytics()
        }
    }
    
    private func warrantyStatusCards(stats: WarrantyTrackingStatistics) -> some View {
        HStack(spacing: 12) {
            WarrantyMetricCard(
                title: "Active",
                value: "\(stats.activeWarranties)",
                color: .green,
                systemImage: "shield.checkered"
            )
            
            WarrantyMetricCard(
                title: "Expiring Soon",
                value: "\(stats.expiringSoonCount)",
                color: .orange,
                systemImage: "clock.badge.exclamationmark"
            )
            
            WarrantyMetricCard(
                title: "Expired",
                value: "\(stats.expiredWarranties)",
                color: .red,
                systemImage: "shield.slash"
            )
            
            WarrantyMetricCard(
                title: "No Warranty",
                value: "\(stats.noWarrantyCount)",
                color: .gray,
                systemImage: "shield"
            )
        }
    }
    
    private func warrantyCoverageByCategory(analysis: CategoryCoverageAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Coverage by Category")
                .font(.headline)
                .padding(.horizontal)
            
            if analysis.categoryStats.isEmpty {
                Text("No category data available")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ForEach(analysis.categoryStats.prefix(4), id: \.categoryName) { category in
                    AnalyticsCategoryCoverageRow(categoryStats: category)
                }
                
                if analysis.categoryStats.count > 4 {
                    Text("+ \(analysis.categoryStats.count - 4) more categories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
            }
        }
    }
    
    private func loadWarrantyAnalytics() async {
        isLoading = true
        
        do {
            let analyticsEngine = WarrantyAnalyticsEngine()
            let stats = try await analyticsEngine.generateStatistics(from: items)
            let analysis = analyticsEngine.analyzeCoverageByCategory(from: items)
            
            await MainActor.run {
                self.warrantyStats = stats
                self.categoryAnalysis = analysis
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}

private struct WarrantyMetricCard: View {
    let title: String
    let value: String
    let color: Color
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

private struct AnalyticsCategoryCoverageRow: View {
    let categoryStats: CategoryStats
    
    var body: some View {
        HStack {
            Text(categoryStats.categoryName)
                .font(.subheadline)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(categoryStats.coveragePercentage))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(coverageColor)
                
                Text("\(categoryStats.itemsWithWarranty)/\(categoryStats.totalItems)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
    
    private var coverageColor: Color {
        let percentage = categoryStats.coveragePercentage
        if percentage >= 80 { return .green }
        else if percentage >= 50 { return .orange }
        else { return .red }
    }
}

#Preview {
    AnalyticsDashboardView(
        store: Store(initialState: AnalyticsFeature.State()) {
            AnalyticsFeature()
        }
    )
}

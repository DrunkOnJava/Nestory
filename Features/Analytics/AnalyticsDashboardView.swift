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
            } else if let dashboardData = store.dashboardData {
                // Use TCA-managed analytics data from AnalyticsService
                SummaryCardsView(
                    totalItems: dashboardData.totalItems,
                    totalValue: dashboardData.totalValue,
                    categoriesCount: dashboardData.categoryBreakdowns.count,
                    averageValue: dashboardData.totalItems > 0 ? 
                        dashboardData.totalValue / Decimal(dashboardData.totalItems) : 0
                )
                .padding(.horizontal)
            } else {
                // Loading state or fallback
                SummaryCardsView(
                    totalItems: store.items.count,
                    totalValue: 0,
                    categoriesCount: store.categories.count,
                    averageValue: 0
                )
                .padding(.horizontal)
                .opacity(0.6)
                .overlay(
                    ProgressView()
                        .scaleEffect(0.8)
                )
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
                    timeRangeSection
                    summarySection
                    enhancedAnalyticsSection
                    chartsSection
                    insightsSection
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
    
    private var timeRangeSection: some View {
        timeRangePicker
            .padding(.horizontal)
    }
    
    private var summarySection: some View {
        summaryCardsSection
    }
    
    private var enhancedAnalyticsSection: some View {
        Group {
            if let data = store.dashboardData {
                EnhancedAnalyticsSummaryView(dashboardData: data)
                    .padding(.horizontal)
            } else if store.isLoading {
                ProgressView("Loading enhanced analytics...")
                    .frame(height: 100)
                    .padding(.horizontal)
            }
        }
    }
    
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            categoryDistributionChart
            valueByCategoryChart
            valueTrendsChart
            itemStatusChart
            warrantyAnalyticsSection
        }
        .padding(.horizontal)
    }
    
    private var insightsSection: some View {
        VStack(spacing: 20) {
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
    }
    
    private var categoryDistributionChart: some View {
        ChartContainer(title: "Category Distribution") {
            if let dashboardData = store.dashboardData {
                CategoryBreakdownChart(serviceData: dashboardData.categoryBreakdowns)
            } else {
                let categories = store.categories.filter { category in
                    store.items.contains(where: { $0.category?.id == category.id })
                }
                CategoryDistributionChart(categories: categories, items: store.items)
            }
        }
    }
    
    private var valueByCategoryChart: some View {
        ChartContainer(title: "Value by Category") {
            if let dashboardData = store.dashboardData {
                let serviceCategories = dashboardData.categoryBreakdowns.compactMap { breakdown in
                    store.categories.first { $0.name == breakdown.categoryName }
                }
                ValueByCategoryChart(categories: serviceCategories, items: store.filteredItems)
            } else {
                let categories = store.categories.filter { category in
                    store.items.contains(where: { $0.category?.id == category.id })
                }
                ValueByCategoryChart(categories: categories, items: store.filteredItems)
            }
        }
    }
    
    private var valueTrendsChart: some View {
        ChartContainer(title: "Value Trends") {
            if let dashboardData = store.dashboardData, !dashboardData.valueTrends.isEmpty {
                ValueTrendsChart(trends: dashboardData.valueTrends, period: .monthly)
            } else if store.isLoading {
                ProgressView("Loading trend data...")
                    .frame(height: 200)
            } else {
                Text("No trend data available")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
            }
        }
    }
    
    private var itemStatusChart: some View {
        ChartContainer(title: "Item Status Overview") {
            ItemStatusChart(items: store.filteredItems)
        }
    }
}

// MARK: - TCA Service Integration Helpers

extension CategoryBreakdownChart {
    init(serviceData categoryBreakdowns: [CategoryBreakdown]) {
        self.breakdown = categoryBreakdowns
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

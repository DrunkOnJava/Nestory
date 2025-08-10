//
//  AnalyticsDashboardView.swift
//  Nestory
//

import SwiftUI
import SwiftData
import Charts

struct AnalyticsDashboardView: View {
    @Query private var items: [Item]
    @Query private var categories: [Category]
    @State private var selectedTimeRange: TimeRange = .month
    @State private var showingInsights = false
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case all = "All Time"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            case .all: return 9999
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Picker
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Summary Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        SummaryCard(
                            title: "Total Items",
                            value: "\(items.count)",
                            icon: "shippingbox.fill",
                            color: .blue
                        )
                        
                        SummaryCard(
                            title: "Total Value",
                            value: formatCurrency(totalValue),
                            icon: "dollarsign.circle.fill",
                            color: .green
                        )
                        
                        SummaryCard(
                            title: "Categories",
                            value: "\(categoriesWithItems.count)",
                            icon: "square.grid.2x2.fill",
                            color: .purple
                        )
                        
                        SummaryCard(
                            title: "Avg. Value",
                            value: formatCurrency(averageValue),
                            icon: "chart.line.uptrend.xyaxis",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                    
                    // Charts Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Category Distribution Chart
                        ChartContainer(title: "Category Distribution") {
                            CategoryDistributionChart(categories: categoriesWithItems)
                        }
                        
                        // Value by Category Chart
                        ChartContainer(title: "Value by Category") {
                            ValueByCategoryChart(categories: categoriesWithItems, items: items)
                        }
                        
                        // Recent Activity Chart
                        ChartContainer(title: "Recent Activity") {
                            RecentActivityChart(items: recentItems, timeRange: selectedTimeRange)
                        }
                        
                        // Item Categories Overview
                        ChartContainer(title: "Item Status Overview") {
                            ItemStatusChart(items: items)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Insights Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Insights")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: { showingInsights.toggle() }) {
                                Image(systemName: showingInsights ? "chevron.up" : "chevron.down")
                            }
                        }
                        
                        if showingInsights {
                            VStack(alignment: .leading, spacing: 12) {
                                InsightRow(
                                    icon: "doc.text.fill",
                                    text: "\(itemsNeedingDocumentation.count) items need documentation",
                                    color: .orange
                                )
                                
                                if let mostValuableCategory = mostValuableCategory {
                                    InsightRow(
                                        icon: "crown.fill",
                                        text: "\(mostValuableCategory.name) is your most valuable category",
                                        color: .yellow
                                    )
                                }
                                
                                InsightRow(
                                    icon: "chart.line.uptrend.xyaxis",
                                    text: "You've added \(recentlyAddedCount) items this month",
                                    color: .green
                                )
                                
                                if uncategorizedCount > 0 {
                                    InsightRow(
                                        icon: "questionmark.folder.fill",
                                        text: "\(uncategorizedCount) items need categorization",
                                        color: .red
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalValue: Decimal {
        items.compactMap { $0.purchasePrice }.reduce(0, +)
    }
    
    private var averageValue: Decimal {
        let total = totalValue
        let count = items.filter { $0.purchasePrice != nil }.count
        return count > 0 ? total / Decimal(count) : 0
    }
    
    private var categoriesWithItems: [Category] {
        categories.filter { category in
            items.contains { $0.category?.id == category.id }
        }
    }
    
    private var itemsNeedingDocumentation: [Item] {
        items.filter { $0.serialNumber == nil || $0.purchasePrice == nil || $0.imageData == nil }
    }
    
    private var mostValuableCategory: Category? {
        var categoryValues: [Category: Decimal] = [:]
        
        for item in items {
            if let category = item.category,
               let price = item.purchasePrice {
                categoryValues[category, default: 0] += price * Decimal(item.quantity)
            }
        }
        
        return categoryValues.max(by: { $0.value < $1.value })?.key
    }
    
    private var recentItems: [Item] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -selectedTimeRange.days, to: Date()) ?? Date()
        return items.filter { $0.createdAt > cutoffDate }
    }
    
    private var recentlyAddedCount: Int {
        let cutoffDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return items.filter { $0.createdAt > cutoffDate }.count
    }
    
    private var uncategorizedCount: Int {
        items.filter { $0.category == nil }.count
    }
    
    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSNumber) ?? "$0"
    }
}

// MARK: - Summary Card Component

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

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

// MARK: - Custom Chart Views

struct CategoryDistributionChart: View {
    let categories: [Category]
    @Query private var items: [Item]
    
    var body: some View {
        Chart {
            ForEach(categories) { category in
                let count = items.filter { $0.category?.id == category.id }.count
                SectorMark(
                    angle: .value("Count", count),
                    innerRadius: .ratio(0.5)
                )
                .foregroundStyle(Color(hex: category.colorHex) ?? .blue)
                .annotation(position: .overlay) {
                    if count > 0 {
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

struct ValueByCategoryChart: View {
    let categories: [Category]
    let items: [Item]
    
    var categoryData: [(category: Category, value: Decimal)] {
        categories.compactMap { category in
            let categoryItems = items.filter { $0.category?.id == category.id }
            let value = categoryItems.compactMap { $0.purchasePrice }.reduce(0, +)
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
                y: .value("Category", data.category.name)
            )
            .foregroundStyle(Color(hex: data.category.colorHex) ?? .blue)
        }
    }
}

struct RecentActivityChart: View {
    let items: [Item]
    let timeRange: AnalyticsDashboardView.TimeRange
    
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
                    y: .value("Items", data.count)
                )
                .foregroundStyle(.blue)
                
                AreaMark(
                    x: .value("Date", data.date),
                    y: .value("Items", data.count)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
}

struct ItemStatusChart: View {
    let items: [Item]
    
    var statusData: [(label: String, count: Int, color: Color)] {
        let fullyDocumented = items.filter { item in
            item.imageData != nil && item.purchasePrice != nil && item.serialNumber != nil
        }.count
        let partiallyDocumented = items.filter { item in
            (item.imageData != nil || item.purchasePrice != nil || item.serialNumber != nil) &&
            !(item.imageData != nil && item.purchasePrice != nil && item.serialNumber != nil)
        }.count
        let needsDocumentation = items.filter { item in
            item.imageData == nil && item.purchasePrice == nil && item.serialNumber == nil
        }.count
        
        return [
            ("Complete", fullyDocumented, .green),
            ("Partial", partiallyDocumented, .orange),
            ("Missing", needsDocumentation, .red)
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
                                        .frame(height: geometry.size.height * CGFloat(data.count) / CGFloat(max(items.count, 1)))
                                }
                            }
                        )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Insight Row

struct InsightRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    AnalyticsDashboardView()
        .modelContainer(for: [Item.self, Category.self], inMemory: true)
}
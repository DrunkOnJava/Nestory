//
// Layer: Features
// Module: Analytics
// Purpose: Analytics Feature TCA Reducer
//
// 🏗️ TCA FEATURE PATTERN: Business Logic Coordinator for Analytics
// - Manages analytics dashboard state and calculations using TCA patterns
// - Coordinates with AnalyticsService through dependency injection
// - Handles async data loading and time range filtering
// - FOLLOWS 6-layer architecture: can import UI, Services, Foundation, ComposableArchitecture
//
// 🎯 BUSINESS FOCUS: Insurance-focused analytics and financial insights
// - Portfolio value tracking for insurance coverage planning
// - Category breakdown analysis for specialized riders
// - Documentation completeness scoring for claim readiness
// - Trend analysis for identifying coverage gaps and risks
//
// 📋 TCA STANDARDS:
// - State must be Equatable for TCA diffing
// - Actions should be intent-based (loadAnalytics, not setData)
// - Effects return to drive async operations
// - Use @Dependency for service injection
//

import ComposableArchitecture
import SwiftData
import SwiftUI
import Foundation

// Import analytics models from Foundation layer
import Nestory

@Reducer
public struct AnalyticsFeature: Sendable {
    @ObservableState
    public struct State: Equatable {
        // 📊 CORE STATE: Analytics dashboard state
        var items: [Item] = [] // Source data for analytics
        var categories: [Category] = [] // Category definitions
        var selectedTimeRange: TimeRange = .month // User-selected time filter
        var isLoading = false // Loading state for UI feedback
        var error: AnalyticsError? = nil // Error state for user display
        @Presents var alert: AlertState<Action.Alert>?

        // 📈 ANALYTICS DATA: Computed dashboard content
        var dashboardData: DashboardData? = nil // Enhanced analytics from service
        var summaryData: SummaryData? = nil // Basic summary calculations
        var chartsData: ChartsData? = nil // Chart-specific data structures

        // 🔍 COMPUTED PROPERTIES: Real-time derived state
        var filteredItems: [Item] {
            let now = Date()
            let cutoffDate: Date

            switch selectedTimeRange {
            case .week:
                cutoffDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            case .month:
                cutoffDate = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
            case .quarter:
                cutoffDate = Calendar.current.date(byAdding: .month, value: -3, to: now) ?? now
            case .year:
                cutoffDate = Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now
            case .all:
                return items
            }

            return items.filter { $0.createdAt >= cutoffDate }
        }

        var totalItems: Int {
            filteredItems.count
        }

        var categoriesWithItems: [CategoryBreakdown] {
            let itemsByCategory = Dictionary(grouping: filteredItems) { $0.category }
            return itemsByCategory.compactMap { category, items in
                guard let category else { return nil }
                let totalValue = items.compactMap(\.purchasePrice).reduce(0, +)
                return CategoryBreakdown(
                    categoryName: category.name,
                    itemCount: items.count,
                    totalValue: totalValue,
                    percentage: 0 // Will be calculated in the service
                )
            }
        }

        public enum TimeRange: String, CaseIterable, Equatable, Sendable {
            case week = "Week"
            case month = "Month"
            case quarter = "Quarter"
            case year = "Year"
            case all = "All Time"
        }
    }

    public enum Action: Sendable {
        case onAppear
        case loadAnalytics
        case loadItems([Item])
        case loadCategories([Category])
        case timeRangeChanged(State.TimeRange)
        case analyticsLoaded(DashboardData, SummaryData)
        case dataLoadError(any Error)
        case refresh
        case alert(PresentationAction<Alert>)
        case trackEvent(AnalyticsEvent)

        public enum Alert: Equatable, Sendable {
            case dataLoadError
            case calculationError
        }
    }

    @Dependency(\.analyticsService) var analyticsService
    @Dependency(\.inventoryService) var inventoryService

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .send(.loadAnalytics)

            case .loadAnalytics:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    do {
                        let loadedItems = try await inventoryService.fetchItems()
                        let loadedCategories = try await inventoryService.fetchCategories()
                        await send(.loadItems(loadedItems))
                        await send(.loadCategories(loadedCategories))
                        
                        let dashboardData = try await analyticsService.generateDashboard(for: loadedItems)
                        let summaryData = await calculateSummaryData(loadedItems)
                        
                        await send(.analyticsLoaded(dashboardData, summaryData))
                    } catch {
                        await send(.dataLoadError(error))
                    }
                }

            case .loadItems(let items):
                state.items = items
                return .none

            case .loadCategories(let categories):
                state.categories = categories
                return .none

            case .timeRangeChanged(let range):
                state.selectedTimeRange = range
                return .send(.loadAnalytics)

            case .analyticsLoaded(let dashboardData, let summaryData):
                state.dashboardData = dashboardData
                state.summaryData = summaryData
                state.isLoading = false
                return .none

            case .dataLoadError(let error):
                state.error = AnalyticsError.dataLoadError(error)
                state.isLoading = false
                state.alert = AlertState {
                    TextState("Analytics Error")
                } actions: {
                    ButtonState(action: .dataLoadError) {
                        TextState("OK")
                    }
                } message: {
                    TextState("Failed to load analytics data")
                }
                return .none

            case .refresh:
                return .send(.loadAnalytics)

            case .trackEvent(let event):
                return .run { _ in
                    await analyticsService.trackEvent(event)
                }

            case .alert(.presented(.dataLoadError)):
                return .none

            case .alert(.presented(.calculationError)):
                return .none

            case .alert(.dismiss):
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Supporting Types

public struct SummaryData: Equatable, Sendable {
    let totalItems: Int
    let totalValue: Decimal
    let categoriesCount: Int
    let averageValue: Decimal
    let recentItemsCount: Int
    let documentationScore: Double
}

public struct ChartsData: Equatable, Sendable {
    let categoryDistribution: [CategoryBreakdown]
    let valueByCategory: [CategoryValue]
    let recentActivity: [ActivityPoint]
    let statusOverview: ItemStatusSummary
}

public struct CategoryValue: Equatable, Sendable {
    let categoryName: String
    let totalValue: Decimal
    let itemCount: Int
}

public struct ActivityPoint: Equatable, Sendable {
    let date: Date
    let itemsAdded: Int
    let valueAdded: Decimal
}

public struct ItemStatusSummary: Equatable, Sendable {
    let completeDocumentation: Int
    let incompleteDocumentation: Int
    let missingReceipts: Int
    let missingImages: Int
}

public enum AnalyticsError: Error, Equatable {
    case dataLoadError(Error)
    case calculationError(String)
    case serviceUnavailable

    public static func == (lhs: AnalyticsError, rhs: AnalyticsError) -> Bool {
        switch (lhs, rhs) {
        case (.serviceUnavailable, .serviceUnavailable):
            true
        case let (.calculationError(lhsMessage), .calculationError(rhsMessage)):
            lhsMessage == rhsMessage
        case let (.dataLoadError(lhsError), .dataLoadError(rhsError)):
            lhsError.localizedDescription == rhsError.localizedDescription
        default:
            false
        }
    }

    var localizedDescription: String {
        switch self {
        case let .dataLoadError(error):
            "Failed to load data: \(error.localizedDescription)"
        case let .calculationError(message):
            "Calculation error: \(message)"
        case .serviceUnavailable:
            "Analytics service is currently unavailable"
        }
    }
}

// MARK: - Helper Functions

private func calculateSummaryData(_ items: [Item]) async -> SummaryData {
    let totalValue = items.compactMap(\.purchasePrice).reduce(0, +)
    let categories = Set(items.compactMap(\.category))
    let averageValue = items.isEmpty ? 0 : totalValue / Decimal(items.count)

    let weekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
    let recentItems = items.filter { $0.createdAt >= weekAgo }

    let documentsComplete = items.filter { item in
        item.imageData != nil &&
            item.receiptImageData != nil &&
            item.serialNumber?.isEmpty == false
    }
    let documentationScore = items.isEmpty ? 0.0 : Double(documentsComplete.count) / Double(items.count)

    return SummaryData(
        totalItems: items.count,
        totalValue: totalValue,
        categoriesCount: categories.count,
        averageValue: averageValue,
        recentItemsCount: recentItems.count,
        documentationScore: documentationScore
    )
}

private func calculateChartsData(_ items: [Item]) async -> ChartsData {
    // Category distribution
    let itemsByCategory = Dictionary(grouping: items) { $0.category }
    let categoryBreakdowns = itemsByCategory.compactMap { (category, categoryItems) -> CategoryBreakdown? in
        guard let category else { return nil }
        let totalValue = categoryItems.compactMap(\.purchasePrice).reduce(0, +)
        return CategoryBreakdown(
            categoryName: category.name,
            itemCount: categoryItems.count,
            totalValue: totalValue,
            percentage: 0 // Calculate percentage in UI
        )
    }

    // Value by category
    let categoryValues = categoryBreakdowns.map { breakdown in
        CategoryValue(
            categoryName: breakdown.categoryName,
            totalValue: breakdown.totalValue,
            itemCount: breakdown.itemCount
        )
    }

    // Recent activity (last 30 days)
    let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    let recentItems = items.filter { $0.createdAt >= thirtyDaysAgo }

    // Group by day
    let calendar = Calendar.current
    let activityByDay = Dictionary(grouping: recentItems) { item in
        calendar.startOfDay(for: item.createdAt)
    }

    let activityPoints = activityByDay.map { date, dayItems in
        let totalValue = dayItems.compactMap(\.purchasePrice).reduce(0, +)
        return ActivityPoint(
            date: date,
            itemsAdded: dayItems.count,
            valueAdded: totalValue
        )
    }.sorted { $0.date < $1.date }

    // Status overview
    let completeItems = items.filter { item in
        item.imageData != nil &&
            item.receiptImageData != nil &&
            item.serialNumber?.isEmpty == false
    }
    let incompleteItems = items.filter { !completeItems.contains($0) }
    let missingReceipts = items.filter { $0.receiptImageData == nil }
    let missingImages = items.filter { $0.imageData == nil }

    let statusSummary = ItemStatusSummary(
        completeDocumentation: completeItems.count,
        incompleteDocumentation: incompleteItems.count,
        missingReceipts: missingReceipts.count,
        missingImages: missingImages.count
    )

    return ChartsData(
        categoryDistribution: categoryBreakdowns,
        valueByCategory: categoryValues,
        recentActivity: activityPoints,
        statusOverview: statusSummary
    )
}


// MARK: - TCA Integration Notes

//
// 🔗 SERVICE INTEGRATION: Uses Services/AnalyticsService protocol
// - Dependency injection via @Dependency(\.analyticsService)
// - Protocol defined in Services layer with proper implementations
// - Async operations for non-blocking analytics calculations
// - Error handling for robust user experience
//
// 📊 STATE MANAGEMENT: Insurance-focused analytics
// - Time range filtering for relevant data analysis
// - Real-time calculations for immediate feedback
// - Cached results to avoid repeated expensive calculations
// - Loading states for smooth user experience
//

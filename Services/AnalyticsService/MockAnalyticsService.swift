//
// Layer: Services
// Module: AnalyticsService
// Purpose: Mock implementation of analytics service for testing
//

import Foundation

public final class MockAnalyticsService: AnalyticsService {
    // Mock data that can be configured for tests
    public var mockTotalValue: Decimal = 1000.0
    public var mockCategoryBreakdown: [CategoryBreakdown] = []
    public var mockValueTrends: [TrendPoint] = []
    public var mockTopItems: [Item] = []
    public var mockDepreciation: [DepreciationReport] = []
    public var mockDashboardData: DashboardData

    // Track method calls for testing
    public var calculateTotalValueCalled = false
    public var calculateCategoryBreakdownCalled = false
    public var calculateValueTrendsCalled = false
    public var calculateTopItemsCalled = false
    public var calculateDepreciationCalled = false
    public var generateDashboardCalled = false
    public var trackEventCalled = false
    public var lastTrackedEvent: AnalyticsEvent?

    public init() {
        // Initialize with mock dashboard data
        mockDashboardData = DashboardData(
            totalItems: 0,
            totalValue: mockTotalValue,
            categoryBreakdown: mockCategoryBreakdown,
            topValueItemIds: [],
            recentItemIds: [],
            valueTrends: mockValueTrends,
            totalDepreciation: 0,
            lastUpdated: Date(),
        )
    }

    // MARK: - Analytics Protocol Implementation

    public func calculateTotalValue(for _: [Item]) async -> Decimal {
        calculateTotalValueCalled = true
        return mockTotalValue
    }

    public func calculateCategoryBreakdown(for _: [Item]) async -> [CategoryBreakdown] {
        calculateCategoryBreakdownCalled = true
        return mockCategoryBreakdown
    }

    public func calculateValueTrends(for _: [Item], period _: TrendPeriod) async -> [TrendPoint] {
        calculateValueTrendsCalled = true
        return mockValueTrends
    }

    public func calculateTopItems(from _: [Item], limit: Int) async -> [Item] {
        calculateTopItemsCalled = true
        return Array(mockTopItems.prefix(limit))
    }

    public func calculateDepreciation(for _: [Item]) async -> [DepreciationReport] {
        calculateDepreciationCalled = true
        return mockDepreciation
    }

    public func generateDashboard(for _: [Item]) async -> DashboardData {
        generateDashboardCalled = true
        return mockDashboardData
    }

    public func trackEvent(_ event: AnalyticsEvent) async {
        trackEventCalled = true
        lastTrackedEvent = event
    }
}

// MARK: - Test Helpers

extension MockAnalyticsService {
    /// Reset all call tracking flags
    public func resetCallTracking() {
        calculateTotalValueCalled = false
        calculateCategoryBreakdownCalled = false
        calculateValueTrendsCalled = false
        calculateTopItemsCalled = false
        calculateDepreciationCalled = false
        generateDashboardCalled = false
        trackEventCalled = false
        lastTrackedEvent = nil
    }

    /// Configure mock with sample data for testing
    public func configureSampleData() {
        mockTotalValue = 5000.0
        mockCategoryBreakdown = [
            CategoryBreakdown(categoryName: "Electronics", itemCount: 10, totalValue: 2000.0, percentage: 40.0),
            CategoryBreakdown(categoryName: "Furniture", itemCount: 5, totalValue: 1500.0, percentage: 30.0),
            CategoryBreakdown(categoryName: "Appliances", itemCount: 3, totalValue: 1500.0, percentage: 30.0),
        ]
        // Update dashboard data with new values
        mockDashboardData = DashboardData(
            totalItems: 18,
            totalValue: mockTotalValue,
            categoryBreakdown: mockCategoryBreakdown,
            topValueItemIds: [],
            recentItemIds: [],
            valueTrends: mockValueTrends,
            totalDepreciation: 500.0,
            lastUpdated: Date(),
        )
    }
}

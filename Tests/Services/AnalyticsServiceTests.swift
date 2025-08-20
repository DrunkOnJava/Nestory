// Layer: Tests
// Module: Services
// Purpose: Comprehensive tests for AnalyticsService with real implementation

@testable import Nestory
import SwiftData
import XCTest

@MainActor
final class AnalyticsServiceTests: XCTestCase {
    var liveService: LiveAnalyticsService!
    var mockService: TestAnalyticsService!
    var mockCurrencyService: TestCurrencyService!
    var testItems: [Item]!

    override func setUp() async throws {
        super.setUp()

        // Set up currency service mock
        mockCurrencyService = TestCurrencyService()
        mockCurrencyService.convertResult = .success(100) // Default conversion

        // Set up live service with mock currency service
        liveService = try LiveAnalyticsService(currencyService: mockCurrencyService)

        // Set up mock service for comparison tests
        mockService = TestAnalyticsService()

        // Create test data
        testItems = [
            TestData.makeItem(name: "iPhone 15", purchasePrice: 999, quantity: 1),
            TestData.makeItem(name: "MacBook Pro", purchasePrice: 2499, quantity: 1),
            TestData.makeItem(name: "AirPods", purchasePrice: 249, quantity: 2),
        ]

        // Set purchase dates for trend calculations
        let calendar = Calendar.current
        testItems[0].purchaseDate = calendar.date(byAdding: .month, value: -1, to: Date())
        testItems[1].purchaseDate = calendar.date(byAdding: .month, value: -3, to: Date())
        testItems[2].purchaseDate = calendar.date(byAdding: .month, value: -6, to: Date())

        // Set currencies for conversion testing
        testItems[0].currency = "USD"
        testItems[1].currency = "EUR"
        testItems[2].currency = "GBP"
    }

    override func tearDown() {
        liveService = nil
        mockService = nil
        mockCurrencyService = nil
        testItems = nil
        super.tearDown()
    }

    // MARK: - Total Value Calculation Tests

    func testCalculateTotalValueWithUSDCurrency() async {
        // All items in USD - no conversion needed
        let usdItems = testItems.map { item in
            item.currency = "USD"
            return item
        }

        let total = await liveService.calculateTotalValue(for: usdItems)

        // 999 + 2499 + (249 * 2) = 3996
        XCTAssertEqual(total, 3996)
        XCTAssertFalse(mockCurrencyService.convertCalled) // No conversion needed
    }

    func testCalculateTotalValueWithCurrencyConversion() async {
        // Items with different currencies - should trigger conversion
        mockCurrencyService.convertResult = .success(50) // Mock conversion rate

        let total = await liveService.calculateTotalValue(for: testItems)

        XCTAssertTrue(mockCurrencyService.convertCalled)
        // USD item (999) + converted EUR item (50) + converted GBP items (50 * 2) = 1149
        XCTAssertEqual(total, 1149)
    }

    func testCalculateTotalValueWithConversionFailure() async {
        // When conversion fails, should use original value
        mockCurrencyService.convertResult = .failure(CurrencyError.rateNotAvailable(from: "EUR", to: "USD"))

        let total = await liveService.calculateTotalValue(for: testItems)

        XCTAssertTrue(mockCurrencyService.convertCalled)
        // Should use original values: 999 + 2499 + (249 * 2) = 3996
        XCTAssertEqual(total, 3996)
    }

    func testCalculateTotalValueWithEmptyItems() async {
        let total = await liveService.calculateTotalValue(for: [])
        XCTAssertEqual(total, 0)
    }

    func testCalculateTotalValueWithNilPrices() async {
        let itemsWithNilPrices = [
            TestData.makeItem(name: "Free Item", purchasePrice: nil, quantity: 1),
            TestData.makeItem(name: "Priced Item", purchasePrice: 100, quantity: 1),
        ]

        let total = await liveService.calculateTotalValue(for: itemsWithNilPrices)
        XCTAssertEqual(total, 100) // Only the priced item should count
    }

    // Mock service test for comparison
    func testMockCalculateTotalValue() async {
        let items = [
            TestData.makeItem(purchasePrice: 25, quantity: 2),
            TestData.makeItem(purchasePrice: 50, quantity: 1),
        ]
        mockService.calculateTotalValueResult = 100

        let total = await mockService.calculateTotalValue(for: items)

        XCTAssertTrue(mockService.calculateTotalValueCalled)
        XCTAssertEqual(mockService.calculateTotalValueItems.count, 2)
        XCTAssertEqual(total, 100)
    }

    // MARK: - Category Breakdown Tests

    func testCalculateCategoryBreakdown() async {
        // Create items with categories
        let electronics = TestData.makeCategory(name: "Electronics")
        let furniture = TestData.makeCategory(name: "Furniture")

        testItems[0].category = electronics
        testItems[1].category = electronics
        testItems[2].category = furniture

        let breakdown = await liveService.calculateCategoryBreakdown(for: testItems)

        XCTAssertEqual(breakdown.count, 2)

        // Electronics should have higher total value
        let electronicsBreakdown = breakdown.first { $0.categoryName == "Electronics" }
        XCTAssertNotNil(electronicsBreakdown)
        XCTAssertEqual(electronicsBreakdown?.itemCount, 2)

        let furnitureBreakdown = breakdown.first { $0.categoryName == "Furniture" }
        XCTAssertNotNil(furnitureBreakdown)
        XCTAssertEqual(furnitureBreakdown?.itemCount, 1)
    }

    func testCalculateCategoryBreakdownWithUncategorizedItems() async {
        // Items without categories should be "Uncategorized"
        let breakdown = await liveService.calculateCategoryBreakdown(for: testItems)

        XCTAssertEqual(breakdown.count, 1)
        XCTAssertEqual(breakdown.first?.categoryName, "Uncategorized")
        XCTAssertEqual(breakdown.first?.itemCount, testItems.count)
    }

    // MARK: - Value Trends Tests

    func testCalculateValueTrends() async {
        let trends = await liveService.calculateValueTrends(for: testItems, period: .monthly)

        XCTAssertFalse(trends.isEmpty)
        XCTAssertEqual(trends.count, 12) // Monthly trends for 12 months

        // Verify trends are ordered chronologically
        for i in 1 ..< trends.count {
            XCTAssertLessThanOrEqual(trends[i - 1].date, trends[i].date)
        }
    }

    func testCalculateValueTrendsWithDifferentPeriods() async {
        let dailyTrends = await liveService.calculateValueTrends(for: testItems, period: .daily)
        XCTAssertEqual(dailyTrends.count, 30)

        let weeklyTrends = await liveService.calculateValueTrends(for: testItems, period: .weekly)
        XCTAssertEqual(weeklyTrends.count, 12)

        let yearlyTrends = await liveService.calculateValueTrends(for: testItems, period: .yearly)
        XCTAssertEqual(yearlyTrends.count, 5)
    }

    // MARK: - Top Items Tests

    func testCalculateTopItems() async {
        let topItems = await liveService.calculateTopItems(from: testItems, limit: 2)

        XCTAssertEqual(topItems.count, 2)
        // Should be sorted by value (highest first)
        XCTAssertEqual(topItems[0].name, "MacBook Pro") // $2499
        XCTAssertEqual(topItems[1].name, "iPhone 15") // $999
    }

    func testCalculateTopItemsWithLimitExceedingCount() async {
        let topItems = await liveService.calculateTopItems(from: testItems, limit: 10)

        XCTAssertEqual(topItems.count, testItems.count) // Should return all items
    }

    // MARK: - Depreciation Tests

    func testCalculateDepreciation() async {
        let depreciationReports = await liveService.calculateDepreciation(for: testItems)

        XCTAssertEqual(depreciationReports.count, testItems.count)

        for report in depreciationReports {
            XCTAssertGreaterThanOrEqual(report.originalValue, report.currentValue)
            XCTAssertEqual(report.totalDepreciation, report.originalValue - report.currentValue)
            XCTAssertEqual(report.depreciationRate, 0.15) // Default 15%
            XCTAssertGreaterThanOrEqual(report.ageInYears, 0)
        }
    }

    func testCalculateDepreciationWithItemsWithoutPurchaseInfo() async {
        let itemsWithoutInfo = [
            TestData.makeItem(name: "No Price", purchasePrice: nil, quantity: 1),
            TestData.makeItem(name: "No Date", purchasePrice: 100, quantity: 1),
        ]
        // Don't set purchase date for "No Date" item

        let depreciationReports = await liveService.calculateDepreciation(for: itemsWithoutInfo)

        // Should skip items without required info
        XCTAssertEqual(depreciationReports.count, 0)
    }

    // MARK: - Dashboard Generation Tests

    func testGenerateDashboard() async {
        let dashboard = await liveService.generateDashboard(for: testItems)

        XCTAssertEqual(dashboard.totalItems, testItems.count)
        XCTAssertGreaterThan(dashboard.totalValue, 0)
        XCTAssertFalse(dashboard.categoryBreakdown.isEmpty)
        XCTAssertFalse(dashboard.topValueItemIds.isEmpty)
        XCTAssertFalse(dashboard.recentItemIds.isEmpty)
        XCTAssertFalse(dashboard.valueTrends.isEmpty)
        XCTAssertGreaterThanOrEqual(dashboard.totalDepreciation, 0)
        XCTAssertNotNil(dashboard.lastUpdated)
    }

    func testGenerateDashboardCaching() async {
        // First call should calculate
        let dashboard1 = await liveService.generateDashboard(for: testItems)

        // Second call with same items should use cache (we can't easily test this directly,
        // but we can verify the results are consistent)
        let dashboard2 = await liveService.generateDashboard(for: testItems)

        XCTAssertEqual(dashboard1.totalItems, dashboard2.totalItems)
        XCTAssertEqual(dashboard1.totalValue, dashboard2.totalValue)
    }

    // Mock service test for comparison
    func testMockGenerateDashboard() async {
        let items = [TestData.makeItem()]
        mockService.calculateTotalValueResult = 50

        let dashboard = await mockService.generateDashboard(for: items)

        XCTAssertEqual(dashboard.totalItems, 1)
        XCTAssertEqual(dashboard.totalValue, 50)
    }

    // MARK: - Event Tracking Tests

    func testTrackEvent() async {
        let itemId = UUID()
        let event = AnalyticsEvent.itemAdded(itemId: itemId, value: 100)

        await liveService.trackEvent(event)

        // Verify event was stored in UserDefaults
        let count = UserDefaults.standard.integer(forKey: "analytics.item_added")
        XCTAssertGreaterThan(count, 0)
    }

    func testTrackMultipleEvents() async {
        let events = [
            AnalyticsEvent.itemAdded(itemId: UUID(), value: 100),
            AnalyticsEvent.itemDeleted(itemId: UUID()),
            AnalyticsEvent.categoryCreated(name: "Test Category"),
        ]

        for event in events {
            await liveService.trackEvent(event)
        }

        // Verify all events were tracked
        XCTAssertGreaterThan(UserDefaults.standard.integer(forKey: "analytics.item_added"), 0)
        XCTAssertGreaterThan(UserDefaults.standard.integer(forKey: "analytics.item_deleted"), 0)
        XCTAssertGreaterThan(UserDefaults.standard.integer(forKey: "analytics.category_created"), 0)
    }

    // Mock service test for comparison
    func testMockTrackEvent() async {
        let event = AnalyticsEvent.itemAdded(itemId: UUID(), value: 25)

        await mockService.trackEvent(event)

        XCTAssertTrue(mockService.trackEventCalled)
        XCTAssertEqual(mockService.trackedEvents.count, 1)
        XCTAssertEqual(mockService.trackedEvents.first?.name, "item_added")
    }
}

final class DashboardDataTests: XCTestCase {
    func testCodable() throws {
        let dashboard = DashboardData(
            totalItems: TestConstants.Count.many,
            totalValue: TestConstants.Money.large,
            categoryBreakdown: [],
            topValueItems: [],
            recentItems: [],
            valueTrends: [],
            totalDepreciation: TestConstants.Money.small,
            lastUpdated: Date(),
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(dashboard)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DashboardData.self, from: data)

        XCTAssertEqual(decoded.totalItems, dashboard.totalItems)
        XCTAssertEqual(decoded.totalValue, dashboard.totalValue)
        XCTAssertEqual(decoded.totalDepreciation, dashboard.totalDepreciation)
    }
}

final class TrendPeriodTests: XCTestCase {
    func testDailyIntervals() {
        let intervals = TrendPeriod.daily.intervals(from: Date())
        XCTAssertEqual(intervals.count, 30)
    }

    func testWeeklyIntervals() {
        let intervals = TrendPeriod.weekly.intervals(from: Date())
        XCTAssertEqual(intervals.count, 12)
    }

    func testMonthlyIntervals() {
        let intervals = TrendPeriod.monthly.intervals(from: Date())
        XCTAssertEqual(intervals.count, 12)
    }

    func testYearlyIntervals() {
        let intervals = TrendPeriod.yearly.intervals(from: Date())
        XCTAssertEqual(intervals.count, 5)
    }
}

// MARK: - Performance Tests

@MainActor
final class AnalyticsServicePerformanceTests: XCTestCase {
    func testCalculateTotalValuePerformance() async throws {
        let currencyService = TestCurrencyService()
        let service = try LiveAnalyticsService(currencyService: currencyService)

        // Create large dataset
        let items = (1 ... 1000).map { index in
            TestData.makeItem(name: "Item \(index)", purchasePrice: Decimal(index), quantity: 1)
        }

        measure {
            Task { @MainActor in
                _ = await service.calculateTotalValue(for: items)
            }
        }
    }

    func testGenerateDashboardPerformance() async throws {
        let currencyService = TestCurrencyService()
        let service = try LiveAnalyticsService(currencyService: currencyService)

        // Create realistic dataset
        let items = (1 ... 500).map { index in
            let item = TestData.makeItem(name: "Perf Item \(index)", purchasePrice: Decimal(index * 10), quantity: 1)
            item.purchaseDate = Calendar.current.date(byAdding: .day, value: -index, to: Date())
            return item
        }

        measure {
            Task { @MainActor in
                _ = await service.generateDashboard(for: items)
            }
        }
    }
}

// MARK: - Analytics Event Tests

final class AnalyticsEventTests: XCTestCase {
    func testItemAddedEvent() {
        let id = UUID()
        let event = AnalyticsEvent.itemAdded(itemId: id, value: 100)

        XCTAssertEqual(event.name, "item_added")
        XCTAssertEqual(event.parameters["item_id"] as? String, id.uuidString)
        XCTAssertEqual(event.parameters["value"] as? String, "100")
        XCTAssertNotNil(event.timestamp)
    }

    func testItemDeletedEvent() {
        let id = UUID()
        let event = AnalyticsEvent.itemDeleted(itemId: id)

        XCTAssertEqual(event.name, "item_deleted")
        XCTAssertEqual(event.parameters["item_id"] as? String, id.uuidString)
        XCTAssertNotNil(event.timestamp)
    }

    func testCategoryCreatedEvent() {
        let event = AnalyticsEvent.categoryCreated(name: "Electronics")

        XCTAssertEqual(event.name, "category_created")
        XCTAssertEqual(event.parameters["name"] as? String, "Electronics")
        XCTAssertNotNil(event.timestamp)
    }

    func testExportCompletedEvent() {
        let event = AnalyticsEvent.exportCompleted(format: "csv", itemCount: 50)

        XCTAssertEqual(event.name, "export_completed")
        XCTAssertEqual(event.parameters["format"] as? String, "csv")
        XCTAssertEqual(event.parameters["item_count"] as? Int, 50)
        XCTAssertNotNil(event.timestamp)
    }

    func testSyncCompletedEvent() {
        let event = AnalyticsEvent.syncCompleted(result: "success")

        XCTAssertEqual(event.name, "sync_completed")
        XCTAssertEqual(event.parameters["result"] as? String, "success")
        XCTAssertNotNil(event.parameters["timestamp"])
        XCTAssertNotNil(event.timestamp)
    }

    func testEventTimestamp() {
        let beforeTime = Date()
        let event = AnalyticsEvent.itemAdded(itemId: UUID(), value: 100)
        let afterTime = Date()

        XCTAssertGreaterThanOrEqual(event.timestamp, beforeTime)
        XCTAssertLessThanOrEqual(event.timestamp, afterTime)
    }
}

// Layer: Tests
// Module: Services
// Purpose: Analytics service tests

@testable import Nestory
import XCTest

final class AnalyticsServiceTests: XCTestCase {
    var service: TestAnalyticsService!

    override func setUp() {
        super.setUp()
        service = TestAnalyticsService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    func testCalculateTotalValue() async {
        let items = [
            TestData.makeItem(purchasePrice: 100, quantity: 2),
            TestData.makeItem(purchasePrice: 50, quantity: 1),
        ]
        service.calculateTotalValueResult = 250

        let total = await service.calculateTotalValue(for: items)

        XCTAssertTrue(service.calculateTotalValueCalled)
        XCTAssertEqual(service.calculateTotalValueItems.count, 2)
        XCTAssertEqual(total, 250)
    }

    func testGenerateDashboard() async {
        let items = [TestData.makeItem()]
        service.calculateTotalValueResult = 100

        let dashboard = await service.generateDashboard(for: items)

        XCTAssertEqual(dashboard.totalItems, 1)
        XCTAssertEqual(dashboard.totalValue, 100)
    }

    func testTrackEvent() async {
        let event = AnalyticsEvent.itemAdded(itemId: UUID(), value: 100)

        await service.trackEvent(event)

        XCTAssertTrue(service.trackEventCalled)
        XCTAssertEqual(service.trackedEvents.count, 1)
        XCTAssertEqual(service.trackedEvents.first?.name, "item_added")
    }
}

final class DashboardDataTests: XCTestCase {
    func testCodable() throws {
        let dashboard = DashboardData(
            totalItems: 10,
            totalValue: 1000,
            categoryBreakdown: [],
            topValueItems: [],
            recentItems: [],
            valueTrends: [],
            totalDepreciation: 100,
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

final class AnalyticsEventTests: XCTestCase {
    func testItemAddedEvent() {
        let id = UUID()
        let event = AnalyticsEvent.itemAdded(itemId: id, value: 100)

        XCTAssertEqual(event.name, "item_added")
        XCTAssertEqual(event.parameters["item_id"] as? String, id.uuidString)
        XCTAssertEqual(event.parameters["value"] as? String, "100")
    }

    func testItemDeletedEvent() {
        let id = UUID()
        let event = AnalyticsEvent.itemDeleted(itemId: id)

        XCTAssertEqual(event.name, "item_deleted")
        XCTAssertEqual(event.parameters["item_id"] as? String, id.uuidString)
    }

    func testCategoryCreatedEvent() {
        let event = AnalyticsEvent.categoryCreated(name: "Electronics")

        XCTAssertEqual(event.name, "category_created")
        XCTAssertEqual(event.parameters["name"] as? String, "Electronics")
    }

    func testExportCompletedEvent() {
        let event = AnalyticsEvent.exportCompleted(format: "csv", itemCount: 50)

        XCTAssertEqual(event.name, "export_completed")
        XCTAssertEqual(event.parameters["format"] as? String, "csv")
        XCTAssertEqual(event.parameters["item_count"] as? Int, 50)
    }
}

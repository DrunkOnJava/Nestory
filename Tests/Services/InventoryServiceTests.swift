// Layer: Tests
// Module: Services
// Purpose: Inventory service tests

@testable import Nestory
import XCTest

final class InventoryServiceTests: XCTestCase {
    var service: TestInventoryService!

    override func setUp() {
        super.setUp()
        service = TestInventoryService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    func testFetchItems() async throws {
        let items = [TestData.makeItem()]
        service.fetchItemsResult = .success(items)

        let result = try await service.fetchItems()

        XCTAssertTrue(service.fetchItemsCalled)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, items.first?.name)
    }

    func testFetchItem() async throws {
        let item = TestData.makeItem()
        service.fetchItemResult = item

        let result = try await service.fetchItem(id: item.id)

        XCTAssertTrue(service.fetchItemCalled)
        XCTAssertEqual(service.fetchItemId, item.id)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, item.id)
    }

    func testSaveItem() async throws {
        let item = TestData.makeItem()

        try await service.saveItem(item)

        XCTAssertTrue(service.saveItemCalled)
        XCTAssertEqual(service.savedItem?.id, item.id)
    }

    func testUpdateItem() async throws {
        let item = TestData.makeItem()

        try await service.updateItem(item)

        XCTAssertTrue(service.updateItemCalled)
        XCTAssertEqual(service.updatedItem?.id, item.id)
    }

    func testDeleteItem() async throws {
        let id = UUID()

        try await service.deleteItem(id: id)

        XCTAssertTrue(service.deleteItemCalled)
        XCTAssertEqual(service.deletedItemId, id)
    }

    func testSearchItems() async throws {
        let items = [TestData.makeItem(name: "iPhone")]
        service.searchItemsResult = .success(items)

        let result = try await service.searchItems(query: "phone")

        XCTAssertTrue(service.searchItemsCalled)
        XCTAssertEqual(service.searchQuery, "phone")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "iPhone")
    }
}

final class InventoryErrorTests: XCTestCase {
    func testErrorDescriptions() {
        let errors: [InventoryError] = [
            .fetchFailed("test"),
            .saveFailed("test"),
            .updateFailed("test"),
            .deleteFailed("test"),
            .searchFailed("test"),
            .notFound,
            .bulkOperationFailed("test"),
            .exportFailed("test"),
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
        }
    }
}

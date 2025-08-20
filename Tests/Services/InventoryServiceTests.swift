// Layer: Tests
// Module: Services
// Purpose: Comprehensive tests for InventoryService with real SwiftData operations

import SwiftData
import XCTest

@testable import Nestory

@MainActor
final class InventoryServiceTests: XCTestCase {
    var liveService: LiveInventoryService!
    var mockService: TestInventoryService!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        super.setUp()

        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: Item.self, Category.self, Room.self,
            configurations: config,
        )
        modelContext = ModelContext(modelContainer)

        // Set up live service with real ModelContext
        liveService = try LiveInventoryService(modelContext: modelContext)

        // Set up mock service for comparison tests
        mockService = TestInventoryService()
    }

    override func tearDown() {
        liveService = nil
        mockService = nil
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }

    // MARK: - Fetch Items Tests

    func testFetchItemsFromEmptyDatabase() async throws {
        let items = try await liveService.fetchItems()
        XCTAssertEqual(items.count, 0)
    }

    func testFetchItemsWithData() async throws {
        // Insert test items
        let item1 = TestData.makeItem(name: "iPhone 15")
        let item2 = TestData.makeItem(name: "MacBook Pro")

        modelContext.insert(item1)
        modelContext.insert(item2)
        try modelContext.save()

        let items = try await liveService.fetchItems()

        XCTAssertEqual(items.count, 2)

        // Should be sorted by updatedAt descending (most recent first)
        let itemNames = items.map(\.name)
        XCTAssertTrue(itemNames.contains("iPhone 15"))
        XCTAssertTrue(itemNames.contains("MacBook Pro"))
    }

    func testFetchItemsOrderedByUpdatedAt() async throws {
        // Create items with different update times
        let oldItem = TestData.makeItem(name: "Old Item")
        let newItem = TestData.makeItem(name: "New Item")

        // Insert old item first
        modelContext.insert(oldItem)
        try modelContext.save()

        // Wait a bit and insert new item
        try await Task.sleep(for: .milliseconds(10))
        newItem.updatedAt = Date()
        modelContext.insert(newItem)
        try modelContext.save()

        let items = try await liveService.fetchItems()

        // First item should be the most recently updated
        XCTAssertEqual(items.first?.name, "New Item")
    }

    // Mock service test for comparison
    func testMockFetchItems() async throws {
        let items = [TestData.makeItem()]
        mockService.fetchItemsResult = .success(items)

        let result = try await mockService.fetchItems()

        XCTAssertTrue(mockService.fetchItemsCalled)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, items.first?.name)
    }

    // MARK: - Fetch Single Item Tests

    func testFetchItemThatExists() async throws {
        let item = TestData.makeItem(name: "Test Item")
        modelContext.insert(item)
        try modelContext.save()

        let fetchedItem = try await liveService.fetchItem(id: item.id)

        XCTAssertNotNil(fetchedItem)
        XCTAssertEqual(fetchedItem?.id, item.id)
        XCTAssertEqual(fetchedItem?.name, "Test Item")
    }

    func testFetchItemThatDoesNotExist() async throws {
        let nonExistentId = UUID()
        let fetchedItem = try await liveService.fetchItem(id: nonExistentId)

        XCTAssertNil(fetchedItem)
    }

    func testFetchItemUsesCache() async throws {
        let item = TestData.makeItem(name: "Cached Item")
        modelContext.insert(item)
        try modelContext.save()

        // First fetch - should cache the item
        let firstFetch = try await liveService.fetchItem(id: item.id)
        XCTAssertNotNil(firstFetch)

        // Second fetch - should use cache (we can't directly test cache hit,
        // but we can verify consistent results)
        let secondFetch = try await liveService.fetchItem(id: item.id)
        XCTAssertNotNil(secondFetch)
        XCTAssertEqual(firstFetch?.id, secondFetch?.id)
    }

    // Mock service test for comparison
    func testMockFetchItem() async throws {
        let item = TestData.makeItem()
        mockService.fetchItemResult = item

        let result = try await mockService.fetchItem(id: item.id)

        XCTAssertTrue(mockService.fetchItemCalled)
        XCTAssertEqual(mockService.fetchItemId, item.id)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, item.id)
    }

    // MARK: - Save Item Tests

    func testSaveNewItem() async throws {
        let item = TestData.makeItem(name: "New iPhone")

        try await liveService.saveItem(item)

        // Verify item was saved to database
        let fetchedItems = try await liveService.fetchItems()
        XCTAssertEqual(fetchedItems.count, 1)
        XCTAssertEqual(fetchedItems.first?.name, "New iPhone")
    }

    func testSaveMultipleItems() async throws {
        let item1 = TestData.makeItem(name: "Item 1")
        let item2 = TestData.makeItem(name: "Item 2")

        try await liveService.saveItem(item1)
        try await liveService.saveItem(item2)

        let fetchedItems = try await liveService.fetchItems()
        XCTAssertEqual(fetchedItems.count, 2)

        let names = fetchedItems.map(\.name)
        XCTAssertTrue(names.contains("Item 1"))
        XCTAssertTrue(names.contains("Item 2"))
    }

    func testSaveItemUpdatesCache() async throws {
        let item = TestData.makeItem(name: "Cached Save Item")

        try await liveService.saveItem(item)

        // Should be able to fetch from cache immediately
        let fetchedItem = try await liveService.fetchItem(id: item.id)
        XCTAssertNotNil(fetchedItem)
        XCTAssertEqual(fetchedItem?.name, "Cached Save Item")
    }

    // Mock service test for comparison
    func testMockSaveItem() async throws {
        let item = TestData.makeItem()

        try await mockService.saveItem(item)

        XCTAssertTrue(mockService.saveItemCalled)
        XCTAssertEqual(mockService.savedItem?.id, item.id)
    }

    // MARK: - Update Item Tests

    func testUpdateExistingItem() async throws {
        // First save an item
        let item = TestData.makeItem(name: "Original Name")
        modelContext.insert(item)
        try modelContext.save()

        let originalUpdatedAt = item.updatedAt

        // Wait a bit to ensure timestamp changes
        try await Task.sleep(for: .milliseconds(10))

        // Update the item
        item.name = "Updated Name"
        try await liveService.updateItem(item)

        // Verify the update
        let fetchedItem = try await liveService.fetchItem(id: item.id)
        XCTAssertEqual(fetchedItem?.name, "Updated Name")
        XCTAssertGreaterThan(fetchedItem?.updatedAt ?? Date.distantPast, originalUpdatedAt)
    }

    func testUpdateItemUpdatesCache() async throws {
        let item = TestData.makeItem(name: "Cache Update Test")
        modelContext.insert(item)
        try modelContext.save()

        // Fetch to populate cache
        _ = try await liveService.fetchItem(id: item.id)

        // Update item
        item.name = "Updated Cache Test"
        try await liveService.updateItem(item)

        // Fetch should return updated version
        let fetchedItem = try await liveService.fetchItem(id: item.id)
        XCTAssertEqual(fetchedItem?.name, "Updated Cache Test")
    }

    // Mock service test for comparison
    func testMockUpdateItem() async throws {
        let item = TestData.makeItem()

        try await mockService.updateItem(item)

        XCTAssertTrue(mockService.updateItemCalled)
        XCTAssertEqual(mockService.updatedItem?.id, item.id)
    }

    // MARK: - Delete Item Tests

    func testDeleteExistingItem() async throws {
        // First save an item
        let item = TestData.makeItem(name: "Item to Delete")
        modelContext.insert(item)
        try modelContext.save()

        let itemId = item.id

        // Verify item exists
        let beforeDelete = try await liveService.fetchItems()
        XCTAssertEqual(beforeDelete.count, 1)

        // Delete the item
        try await liveService.deleteItem(id: itemId)

        // Verify item was deleted
        let afterDelete = try await liveService.fetchItems()
        XCTAssertEqual(afterDelete.count, 0)

        // Verify item can't be fetched by ID
        let fetchedItem = try await liveService.fetchItem(id: itemId)
        XCTAssertNil(fetchedItem)
    }

    func testDeleteNonExistentItem() async throws {
        let nonExistentId = UUID()

        // Should complete without error even if item doesn't exist
        try await liveService.deleteItem(id: nonExistentId)

        // Database should still be empty
        let items = try await liveService.fetchItems()
        XCTAssertEqual(items.count, 0)
    }

    func testDeleteItemRemovesFromCache() async throws {
        let item = TestData.makeItem(name: "Cache Delete Test")
        modelContext.insert(item)
        try modelContext.save()

        // Populate cache
        _ = try await liveService.fetchItem(id: item.id)

        // Delete item
        try await liveService.deleteItem(id: item.id)

        // Should not be in cache anymore
        let fetchedItem = try await liveService.fetchItem(id: item.id)
        XCTAssertNil(fetchedItem)
    }

    // Mock service test for comparison
    func testMockDeleteItem() async throws {
        let id = UUID()

        try await mockService.deleteItem(id: id)

        XCTAssertTrue(mockService.deleteItemCalled)
        XCTAssertEqual(mockService.deletedItemId, id)
    }

    // MARK: - Search Items Tests

    func testSearchItemsByName() async throws {
        // Create test items with different names
        let iphone = TestData.makeItem(name: "iPhone 15 Pro")
        let macbook = TestData.makeItem(name: "MacBook Pro M3")
        let airpods = TestData.makeItem(name: "AirPods Pro")

        modelContext.insert(iphone)
        modelContext.insert(macbook)
        modelContext.insert(airpods)
        try modelContext.save()

        // Search for "Pro" - should find all three
        let proResults = try await liveService.searchItems(query: "Pro")
        XCTAssertEqual(proResults.count, 3)

        // Search for "iPhone" - should find one
        let iphoneResults = try await liveService.searchItems(query: "iPhone")
        XCTAssertEqual(iphoneResults.count, 1)
        XCTAssertEqual(iphoneResults.first?.name, "iPhone 15 Pro")

        // Search for "Mac" - should find one
        let macResults = try await liveService.searchItems(query: "Mac")
        XCTAssertEqual(macResults.count, 1)
        XCTAssertEqual(macResults.first?.name, "MacBook Pro M3")
    }

    func testSearchItemsByDescription() async throws {
        let item = TestData.makeItem(name: "Device")
        item.itemDescription = "High-performance smartphone with excellent camera"

        modelContext.insert(item)
        try modelContext.save()

        // Search by description content
        let results = try await liveService.searchItems(query: "camera")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Device")
    }

    func testSearchItemsByBrand() async throws {
        let item = TestData.makeItem(name: "Smartphone")
        item.brand = "Apple"

        modelContext.insert(item)
        try modelContext.save()

        let results = try await liveService.searchItems(query: "apple")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Smartphone")
    }

    func testSearchItemsBySerialNumber() async throws {
        let item = TestData.makeItem(name: "Test Item")
        item.serialNumber = "ABC123XYZ"

        modelContext.insert(item)
        try modelContext.save()

        let results = try await liveService.searchItems(query: "ABC123")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.serialNumber, "ABC123XYZ")
    }

    func testSearchWithEmptyQuery() async throws {
        let item = TestData.makeItem(name: "Test Item")
        modelContext.insert(item)
        try modelContext.save()

        // Empty query should return all items
        let results = try await liveService.searchItems(query: "")
        XCTAssertEqual(results.count, 1)

        let whitespaceResults = try await liveService.searchItems(query: "   ")
        XCTAssertEqual(whitespaceResults.count, 1)
    }

    func testSearchWithNoMatches() async throws {
        let item = TestData.makeItem(name: "iPhone")
        modelContext.insert(item)
        try modelContext.save()

        let results = try await liveService.searchItems(query: "Android")
        XCTAssertEqual(results.count, 0)
    }

    func testSearchResultsAreSorted() async throws {
        let zItem = TestData.makeItem(name: "Zebra Device")
        let aItem = TestData.makeItem(name: "Apple Device")

        modelContext.insert(zItem)
        modelContext.insert(aItem)
        try modelContext.save()

        let results = try await liveService.searchItems(query: "Device")
        XCTAssertEqual(results.count, 2)

        // Should be sorted alphabetically by name
        XCTAssertEqual(results[0].name, "Apple Device")
        XCTAssertEqual(results[1].name, "Zebra Device")
    }

    func testSearchCaseInsensitive() async throws {
        let item = TestData.makeItem(name: "iPhone Pro Max")
        modelContext.insert(item)
        try modelContext.save()

        let upperResults = try await liveService.searchItems(query: "IPHONE")
        let lowerResults = try await liveService.searchItems(query: "iphone")
        let mixedResults = try await liveService.searchItems(query: "iPhone")

        XCTAssertEqual(upperResults.count, 1)
        XCTAssertEqual(lowerResults.count, 1)
        XCTAssertEqual(mixedResults.count, 1)
    }

    // Mock service test for comparison
    func testMockSearchItems() async throws {
        let items = [TestData.makeItem(name: "iPhone")]
        mockService.searchItemsResult = .success(items)

        let result = try await mockService.searchItems(query: "phone")

        XCTAssertTrue(mockService.searchItemsCalled)
        XCTAssertEqual(mockService.searchQuery, "phone")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "iPhone")
    }
}

// MARK: - Category Operations Tests

func testFetchCategoriesFromEmptyDatabase() async throws {
    let categories = try await liveService.fetchCategories()
    XCTAssertEqual(categories.count, 0)
}

func testSaveAndFetchCategories() async throws {
    let electronics = TestData.makeCategory(name: "Electronics")
    let furniture = TestData.makeCategory(name: "Furniture")

    try await liveService.saveCategory(electronics)
    try await liveService.saveCategory(furniture)

    let categories = try await liveService.fetchCategories()
    XCTAssertEqual(categories.count, 2)

    let categoryNames = categories.map(\.name).sorted()
    XCTAssertEqual(categoryNames, ["Electronics", "Furniture"])
}

func testAssignItemToCategory() async throws {
    // Create and save category
    let category = TestData.makeCategory(name: "Electronics")
    modelContext.insert(category)
    try modelContext.save()

    // Create and save item
    let item = TestData.makeItem(name: "iPhone")
    modelContext.insert(item)
    try modelContext.save()

    // Assign item to category
    try await liveService.assignItemToCategory(itemId: item.id, categoryId: category.id)

    // Verify assignment
    let fetchedItem = try await liveService.fetchItem(id: item.id)
    XCTAssertNotNil(fetchedItem?.category)
    XCTAssertEqual(fetchedItem?.category?.name, "Electronics")
}

func testFetchItemsByCategory() async throws {
    // Create category
    let electronics = TestData.makeCategory(name: "Electronics")
    modelContext.insert(electronics)
    try modelContext.save()

    // Create items and assign to category
    let iphone = TestData.makeItem(name: "iPhone")
    let macbook = TestData.makeItem(name: "MacBook")
    let chair = TestData.makeItem(name: "Chair") // Not in electronics

    iphone.category = electronics
    macbook.category = electronics

    modelContext.insert(iphone)
    modelContext.insert(macbook)
    modelContext.insert(chair)
    try modelContext.save()

    // Fetch items by category
    let electronicsItems = try await liveService.fetchItemsByCategory(categoryId: electronics.id)
    XCTAssertEqual(electronicsItems.count, 2)

    let itemNames = electronicsItems.map(\.name).sorted()
    XCTAssertEqual(itemNames, ["MacBook", "iPhone"])
}

// MARK: - Bulk Operations Tests

func testBulkImport() async throws {
    let items = [
        TestData.makeItem(name: "Bulk Item 1"),
        TestData.makeItem(name: "Bulk Item 2"),
        TestData.makeItem(name: "Bulk Item 3"),
    ]

    try await liveService.bulkImport(items: items)

    let fetchedItems = try await liveService.fetchItems()
    XCTAssertEqual(fetchedItems.count, 3)

    let names = fetchedItems.map(\.name).sorted()
    XCTAssertEqual(names, ["Bulk Item 1", "Bulk Item 2", "Bulk Item 3"])
}

func testExportInventoryJSON() async throws {
    let item = TestData.makeItem(name: "Export Test Item")
    item.itemDescription = "Test description"
    item.brand = "Test Brand"
    item.purchasePrice = 100

    modelContext.insert(item)
    try modelContext.save()

    let items = try await liveService.fetchItems()
    let jsonData = try await liveService.exportInventory(format: .json)

    XCTAssertGreaterThan(jsonData.count, 0)

    // Verify JSON structure
    let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
    XCTAssertTrue(jsonObject is [Any])

    if let jsonArray = jsonObject as? [[String: Any]] {
        XCTAssertEqual(jsonArray.count, 1)
        XCTAssertEqual(jsonArray.first?["name"] as? String, "Export Test Item")
    }
}

func testExportInventoryCSV() async throws {
    let item = TestData.makeItem(name: "CSV Export Item")
    item.brand = "CSV Brand"
    item.purchasePrice = 200
    item.quantity = 2

    modelContext.insert(item)
    try modelContext.save()

    let items = try await liveService.fetchItems()
    let csvData = try await liveService.exportInventory(format: .csv)

    XCTAssertGreaterThan(csvData.count, 0)

    let csvString = String(data: csvData, encoding: .utf8)
    XCTAssertNotNil(csvString)

    // Verify CSV structure
    let lines = csvString!.components(separatedBy: .newlines)
    XCTAssertGreaterThan(lines.count, 1) // Header + at least one data row

    // Verify header exists
    XCTAssertTrue(lines[0].contains("Name"))
    XCTAssertTrue(lines[0].contains("Brand"))

    // Verify data row
    XCTAssertTrue(lines[1].contains("CSV Export Item"))
}

func testExportInventoryPDFNotImplemented() async throws {
    let item = TestData.makeItem(name: "PDF Test")
    modelContext.insert(item)
    try modelContext.save()

    do {
        _ = try await liveService.exportInventory(format: .pdf)
        XCTFail("Should have thrown exportFailed error")
    } catch let InventoryError.exportFailed(message) {
        XCTAssertTrue(message.contains("PDF export not implemented"))
    } catch {
        XCTFail("Unexpected error: \(error)")
    }
}

// MARK: - Error Handling Tests

@MainActor
final class InventoryServiceErrorTests: XCTestCase {
    func testAssignItemToCategoryWithNonExistentItem() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, Category.self, configurations: config)
        let context = ModelContext(container)
        let service = try LiveInventoryService(modelContext: context)

        let category = TestData.makeCategory(name: "Test Category")
        context.insert(category)
        try context.save()

        do {
            try await service.assignItemToCategory(itemId: UUID(), categoryId: category.id)
            XCTFail("Should have thrown notFound error")
        } catch InventoryError.notFound {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAssignItemToCategoryWithNonExistentCategory() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, Category.self, configurations: config)
        let context = ModelContext(container)
        let service = try LiveInventoryService(modelContext: context)

        let item = TestData.makeItem()
        context.insert(item)
        try context.save()

        do {
            try await service.assignItemToCategory(itemId: item.id, categoryId: UUID())
            XCTFail("Should have thrown notFound error")
        } catch InventoryError.notFound {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - Performance Tests

@MainActor
final class InventoryServicePerformanceTests: XCTestCase {
    func testFetchLargeNumberOfItemsPerformance() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        let context = ModelContext(container)
        let service = try LiveInventoryService(modelContext: context)

        // Create large dataset
        let items = (1 ... 1000).map { index in
            TestData.makeItem(name: "Performance Item \(index)")
        }

        for item in items {
            context.insert(item)
        }
        try context.save()

        measure {
            Task { @MainActor in
                _ = try await service.fetchItems()
            }
        }
    }

    func testSearchPerformance() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        let context = ModelContext(container)
        let service = try LiveInventoryService(modelContext: context)

        // Create dataset with searchable content
        let items = (1 ... 500).map { index in
            let item = TestData.makeItem(name: "Search Item \(index)")
            item.itemDescription = "Description for item number \(index)"
            item.brand = index % 10 == 0 ? "Apple" : "Other Brand"
            return item
        }

        for item in items {
            context.insert(item)
        }
        try context.save()

        measure {
            Task { @MainActor in
                _ = try await service.searchItems(query: "Apple")
            }
        }
    }

    func testBulkImportPerformance() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        let context = ModelContext(container)
        let service = try LiveInventoryService(modelContext: context)

        let items = (1 ... 1000).map { index in
            TestData.makeItem(name: "Bulk Import Item \(index)")
        }

        measure {
            Task { @MainActor in
                try await service.bulkImport(items: items)
            }
        }
    }
}

// MARK: - Model Tests

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
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    func testErrorEquality() {
        XCTAssertEqual(InventoryError.notFound, InventoryError.notFound)
        XCTAssertEqual(
            InventoryError.fetchFailed("test"),
            InventoryError.fetchFailed("test"),
        )
        XCTAssertNotEqual(
            InventoryError.fetchFailed("test1"),
            InventoryError.fetchFailed("test2"),
        )
    }
}

final class ExportFormatTests: XCTestCase {
    func testExportFormatCases() {
        let formats: [ExportFormat] = [.json, .csv, .pdf]
        XCTAssertEqual(formats.count, 3)
    }
}

final class ItemTransferObjectTests: XCTestCase {
    func testItemTransferObjectFromItem() {
        let item = TestData.makeItem(name: "Transfer Test")
        item.itemDescription = "Test description"
        item.brand = "Test Brand"
        item.purchasePrice = 199.99
        item.tags = ["electronics", "smartphone"]

        let transferObject = ItemTransferObject(from: item)

        XCTAssertEqual(transferObject.name, "Transfer Test")
        XCTAssertEqual(transferObject.itemDescription, "Test description")
        XCTAssertEqual(transferObject.brand, "Test Brand")
        XCTAssertEqual(transferObject.purchasePrice, 199.99)
        XCTAssertEqual(transferObject.tags, ["electronics", "smartphone"])
    }

    func testItemTransferObjectToItem() {
        let transferObject = ItemTransferObject(
            name: "Converted Item",
            description: "Converted description",
            brand: "Converted Brand",
            modelNumber: "MODEL123",
            serialNumber: "SERIAL456",
            quantity: 2,
            purchasePrice: 299.99,
            currency: "EUR",
            purchaseDate: Date(),
            tags: ["test", "conversion"],
            notes: "Test notes",
        )

        let item = transferObject.toItem()

        XCTAssertEqual(item.name, "Converted Item")
        XCTAssertEqual(item.itemDescription, "Converted description")
        XCTAssertEqual(item.brand, "Converted Brand")
        XCTAssertEqual(item.modelNumber, "MODEL123")
        XCTAssertEqual(item.serialNumber, "SERIAL456")
        XCTAssertEqual(item.quantity, 2)
        XCTAssertEqual(item.purchasePrice, 299.99)
        XCTAssertEqual(item.currency, "EUR")
        XCTAssertEqual(item.tags, ["test", "conversion"])
        XCTAssertEqual(item.notes, "Test notes")
    }

    func testItemTransferObjectCodable() throws {
        let transferObject = ItemTransferObject(
            name: "Codable Test",
            description: nil,
            brand: "Test Brand",
            modelNumber: nil,
            serialNumber: nil,
            quantity: 1,
            purchasePrice: 100,
            currency: "USD",
            purchaseDate: Date(),
            tags: [],
            notes: nil,
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(transferObject)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ItemTransferObject.self, from: data)

        XCTAssertEqual(decoded.name, transferObject.name)
        XCTAssertEqual(decoded.brand, transferObject.brand)
        XCTAssertEqual(decoded.quantity, transferObject.quantity)
        XCTAssertEqual(decoded.currency, transferObject.currency)
    }
}

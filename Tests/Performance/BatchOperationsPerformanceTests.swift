//
// Layer: Tests
// Module: Performance
// Purpose: Performance tests for batch operations in InventoryService
//

@testable import Nestory
import os.log
import SwiftData
import XCTest

@MainActor
final class BatchOperationsPerformanceTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var inventoryService: LiveInventoryService!
    var testCategories: [Category] = []

    override func setUp() async throws {
        super.setUp()

        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: Item.self, Category.self,
            configurations: config,
        )
        modelContext = ModelContext(modelContainer)
        inventoryService = try LiveInventoryService(modelContext: modelContext)

        // Create test categories
        testCategories = [
            Category(name: "Electronics", icon: "laptopcomputer", colorHex: "#007AFF"),
            Category(name: "Furniture", icon: "chair", colorHex: "#FF9500"),
            Category(name: "Clothing", icon: "tshirt", colorHex: "#FF2D92"),
            Category(name: "Books", icon: "book", colorHex: "#5856D6"),
            Category(name: "Tools", icon: "hammer", colorHex: "#FF3B30"),
        ]

        for category in testCategories {
            modelContext.insert(category)
        }
        try modelContext.save()
    }

    override func tearDown() {
        inventoryService = nil
        modelContext = nil
        modelContainer = nil
        testCategories = []
        super.tearDown()
    }

    // MARK: - Performance Tests

    func testBulkSave500Items() throws {
        let items = generateTestItems(count: 500)

        measure {
            let expectation = expectation(description: "Bulk save 500 items")

            Task {
                do {
                    try await inventoryService.bulkSave(items: items)
                    expectation.fulfill()
                } catch {
                    XCTFail("Bulk save failed: \(error)")
                }
            }

            wait(for: [expectation], timeout: 10.0)
        }

        // Verify all items were saved
        let fetchedItems = try inventoryService.fetchItems()
        XCTAssertEqual(fetchedItems.count, 500, "Should have saved 500 items")
    }

    func testBulkUpdate500Items() throws {
        // First, save 500 items
        let items = generateTestItems(count: 500)
        try await inventoryService.bulkSave(items: items)

        // Modify all items
        for item in items {
            item.name = "Updated \(item.name)"
            item.itemDescription = "Updated description"
        }

        measure {
            let expectation = expectation(description: "Bulk update 500 items")

            Task {
                do {
                    try await inventoryService.bulkUpdate(items: items)
                    expectation.fulfill()
                } catch {
                    XCTFail("Bulk update failed: \(error)")
                }
            }

            wait(for: [expectation], timeout: 10.0)
        }

        // Verify updates
        let fetchedItems = try inventoryService.fetchItems()
        let updatedItems = fetchedItems.filter { $0.name.hasPrefix("Updated") }
        XCTAssertEqual(updatedItems.count, 500, "Should have updated 500 items")
    }

    func testBulkDelete500Items() throws {
        // First, save 500 items
        let items = generateTestItems(count: 500)
        try await inventoryService.bulkSave(items: items)

        let itemIds = items.map(\.id)

        measure {
            let expectation = expectation(description: "Bulk delete 500 items")

            Task {
                do {
                    try await inventoryService.bulkDelete(itemIds: itemIds)
                    expectation.fulfill()
                } catch {
                    XCTFail("Bulk delete failed: \(error)")
                }
            }

            wait(for: [expectation], timeout: 10.0)
        }

        // Verify deletion
        let remainingItems = try inventoryService.fetchItems()
        XCTAssertEqual(remainingItems.count, 0, "Should have deleted all items")
    }

    func testBulkAssignCategory500Items() throws {
        // First, save 500 items
        let items = generateTestItems(count: 500)
        try await inventoryService.bulkSave(items: items)

        let itemIds = items.map(\.id)
        let targetCategory = testCategories.first!

        measure {
            let expectation = expectation(description: "Bulk assign category to 500 items")

            Task {
                do {
                    try await inventoryService.bulkAssignCategory(itemIds: itemIds, categoryId: targetCategory.id)
                    expectation.fulfill()
                } catch {
                    XCTFail("Bulk category assignment failed: \(error)")
                }
            }

            wait(for: [expectation], timeout: 10.0)
        }

        // Verify category assignment
        let fetchedItems = try inventoryService.fetchItems()
        let categorizedItems = fetchedItems.filter { $0.category?.id == targetCategory.id }
        XCTAssertEqual(categorizedItems.count, 500, "Should have assigned category to 500 items")
    }

    // MARK: - Comparison Tests (Batch vs Individual)

    func testBatchVsIndividualSave() throws {
        let batchItems = generateTestItems(count: 100)
        let individualItems = generateTestItems(count: 100, namePrefix: "Individual")

        // Test batch save
        let batchTime = measure {
            let expectation = expectation(description: "Batch save")

            Task {
                do {
                    try await inventoryService.bulkSave(items: batchItems)
                    expectation.fulfill()
                } catch {
                    XCTFail("Batch save failed: \(error)")
                }
            }

            wait(for: [expectation], timeout: 5.0)
        }

        // Clear database
        try await inventoryService.bulkDelete(itemIds: batchItems.map(\.id))

        // Test individual save
        let individualTime = measure {
            let expectation = expectation(description: "Individual saves")

            Task {
                do {
                    for item in individualItems {
                        try await inventoryService.saveItem(item)
                    }
                    expectation.fulfill()
                } catch {
                    XCTFail("Individual saves failed: \(error)")
                }
            }

            wait(for: [expectation], timeout: 10.0)
        }

        print("Batch save time: \(batchTime)")
        print("Individual save time: \(individualTime)")

        // Batch should be faster
        XCTAssertLessThan(batchTime, individualTime, "Batch save should be faster than individual saves")
    }

    func testBatchVsIndividualDelete() throws {
        // Setup two sets of items
        let batchItems = generateTestItems(count: 100)
        let individualItems = generateTestItems(count: 100, namePrefix: "Individual")

        try await inventoryService.bulkSave(items: batchItems + individualItems)

        let batchItemIds = batchItems.map(\.id)
        let individualItemIds = individualItems.map(\.id)

        // Test batch delete
        let batchTime = measure {
            let expectation = expectation(description: "Batch delete")

            Task {
                do {
                    try await inventoryService.bulkDelete(itemIds: batchItemIds)
                    expectation.fulfill()
                } catch {
                    XCTFail("Batch delete failed: \(error)")
                }
            }

            wait(for: [expectation], timeout: 5.0)
        }

        // Test individual delete
        let individualTime = measure {
            let expectation = expectation(description: "Individual deletes")

            Task {
                do {
                    for itemId in individualItemIds {
                        try await inventoryService.deleteItem(id: itemId)
                    }
                    expectation.fulfill()
                } catch {
                    XCTFail("Individual deletes failed: \(error)")
                }
            }

            wait(for: [expectation], timeout: 10.0)
        }

        print("Batch delete time: \(batchTime)")
        print("Individual delete time: \(individualTime)")

        // Batch should be faster
        XCTAssertLessThan(batchTime, individualTime, "Batch delete should be faster than individual deletes")
    }

    // MARK: - Helper Methods

    private func generateTestItems(count: Int, namePrefix: String = "Test Item") -> [Item] {
        var items: [Item] = []

        for i in 1 ... count {
            let item = Item(name: "\(namePrefix) \(i)")
            item.itemDescription = "Description for item \(i)"
            item.brand = "Test Brand \(i % 10)"
            item.modelNumber = "MODEL-\(i)"
            item.serialNumber = "SN\(String(format: "%06d", i))"
            item.quantity = Int.random(in: 1 ... 10)
            item.purchasePrice = Decimal(Double.random(in: 10.0 ... 1000.0))
            item.currency = "USD"
            item.room = ["Living Room", "Kitchen", "Bedroom", "Office", "Garage"][i % 5]
            item.condition = ["excellent", "good", "fair"][i % 3]

            // Randomly assign categories
            if !testCategories.isEmpty {
                item.category = testCategories[i % testCategories.count]
            }

            items.append(item)
        }

        return items
    }

    private func measure(_ block: () -> Void) -> TimeInterval {
        let startTime = CFAbsoluteTimeGetCurrent()
        block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return timeElapsed
    }
}

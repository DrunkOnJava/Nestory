// Layer: Tests
// Module: Services
// Purpose: CRUD operations tests for InventoryService

import SwiftData
import XCTest

@testable import Nestory

@MainActor
final class InventoryServiceCRUDTests: XCTestCase {
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
        // Insert test data
        let item1 = Item(
            name: "iPhone",
            description: "A smartphone",
            estimatedValue: 999.99,
            photos: [],
            updatedAt: Date()
        )
        let item2 = Item(
            name: "MacBook",
            description: "A laptop",
            estimatedValue: 1299.99,
            photos: [],
            updatedAt: Date().addingTimeInterval(-60) // 1 minute ago
        )

        try await liveService.save(item: item1)
        try await liveService.save(item: item2)

        let items = try await liveService.fetchItems()
        XCTAssertEqual(items.count, 2)
        XCTAssertTrue(items.contains { $0.name == "iPhone" })
        XCTAssertTrue(items.contains { $0.name == "MacBook" })
    }

    func testFetchItemsOrderedByUpdatedAt() async throws {
        let now = Date()
        let item1 = Item(name: "First", description: "", estimatedValue: 100, photos: [], updatedAt: now.addingTimeInterval(-120))
        let item2 = Item(name: "Second", description: "", estimatedValue: 200, photos: [], updatedAt: now.addingTimeInterval(-60))
        let item3 = Item(name: "Third", description: "", estimatedValue: 300, photos: [], updatedAt: now)

        // Save in random order
        try await liveService.save(item: item2)
        try await liveService.save(item: item1)
        try await liveService.save(item: item3)

        let items = try await liveService.fetchItems()
        XCTAssertEqual(items.count, 3)

        // Should be ordered by updatedAt desc (newest first)
        XCTAssertEqual(items[0].name, "Third")
        XCTAssertEqual(items[1].name, "Second")
        XCTAssertEqual(items[2].name, "First")
    }

    func testMockFetchItems() async throws {
        // Test that mock returns expected data
        let items = try await mockService.fetchItems()
        
        // Mock should return predefined test data
        XCTAssertGreaterThan(items.count, 0)
        XCTAssertTrue(items.contains { $0.name.contains("Test") })
    }

    // MARK: - Fetch Single Item Tests

    func testFetchItemThatExists() async throws {
        let item = Item(name: "Test Item", description: "Test", estimatedValue: 100, photos: [], updatedAt: Date())
        try await liveService.save(item: item)

        let fetchedItem = try await liveService.fetchItem(withId: item.id)
        XCTAssertNotNil(fetchedItem)
        XCTAssertEqual(fetchedItem?.name, "Test Item")
    }

    func testFetchItemThatDoesNotExist() async throws {
        let nonExistentId = UUID()
        let item = try await liveService.fetchItem(withId: nonExistentId)
        XCTAssertNil(item)
    }

    func testFetchItemUsesCache() async throws {
        let item = Item(name: "Cached Item", description: "Test", estimatedValue: 100, photos: [], updatedAt: Date())
        try await liveService.save(item: item)

        // First fetch - should go to database
        let firstFetch = try await liveService.fetchItem(withId: item.id)
        XCTAssertNotNil(firstFetch)

        // Modify item name directly in context (bypassing service)
        item.name = "Modified Name"
        try modelContext.save()

        // Second fetch - should return cached version (old name)
        let secondFetch = try await liveService.fetchItem(withId: item.id)
        XCTAssertNotNil(secondFetch)
        XCTAssertEqual(secondFetch?.name, "Cached Item") // Should still be cached version
    }

    func testMockFetchItem() async throws {
        // Test mock service behavior
        let items = try await mockService.fetchItems()
        guard let firstItem = items.first else {
            XCTFail("Mock should provide test items")
            return
        }

        let fetchedItem = try await mockService.fetchItem(withId: firstItem.id)
        XCTAssertNotNil(fetchedItem)
        XCTAssertEqual(fetchedItem?.id, firstItem.id)
    }

    // MARK: - Save Item Tests

    func testSaveNewItem() async throws {
        let item = Item(name: "New Item", description: "Brand new", estimatedValue: 500, photos: [], updatedAt: Date())
        
        try await liveService.save(item: item)
        
        let items = try await liveService.fetchItems()
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "New Item")
    }

    func testSaveMultipleItems() async throws {
        let item1 = Item(name: "Item 1", description: "", estimatedValue: 100, photos: [], updatedAt: Date())
        let item2 = Item(name: "Item 2", description: "", estimatedValue: 200, photos: [], updatedAt: Date())
        
        try await liveService.save(item: item1)
        try await liveService.save(item: item2)
        
        let items = try await liveService.fetchItems()
        XCTAssertEqual(items.count, 2)
    }

    func testSaveItemUpdatesCache() async throws {
        let item = Item(name: "Cache Test", description: "", estimatedValue: 100, photos: [], updatedAt: Date())
        try await liveService.save(item: item)
        
        // Modify and save again
        item.name = "Updated Cache Test"
        try await liveService.save(item: item)
        
        // Fetch should return updated version
        let fetchedItem = try await liveService.fetchItem(withId: item.id)
        XCTAssertEqual(fetchedItem?.name, "Updated Cache Test")
    }

    func testMockSaveItem() async throws {
        let item = Item(name: "Mock Save Test", description: "", estimatedValue: 100, photos: [], updatedAt: Date())
        
        try await mockService.save(item: item)
        
        // Mock should now include this item
        let items = try await mockService.fetchItems()
        XCTAssertTrue(items.contains { $0.name == "Mock Save Test" })
    }

    // MARK: - Update Item Tests

    func testUpdateExistingItem() async throws {
        let item = Item(name: "Original Name", description: "Original", estimatedValue: 100, photos: [], updatedAt: Date())
        try await liveService.save(item: item)
        
        // Update the item
        item.name = "Updated Name"
        item.description = "Updated description"
        item.estimatedValue = 200
        
        try await liveService.update(item: item)
        
        // Verify updates persisted
        let updatedItem = try await liveService.fetchItem(withId: item.id)
        XCTAssertEqual(updatedItem?.name, "Updated Name")
        XCTAssertEqual(updatedItem?.description, "Updated description")
        XCTAssertEqual(updatedItem?.estimatedValue, 200)
    }

    func testUpdateItemUpdatesCache() async throws {
        let item = Item(name: "Cache Update Test", description: "", estimatedValue: 100, photos: [], updatedAt: Date())
        try await liveService.save(item: item)
        
        // Update via service
        item.description = "Updated description"
        try await liveService.update(item: item)
        
        // Cache should be updated
        let cachedItem = try await liveService.fetchItem(withId: item.id)
        XCTAssertEqual(cachedItem?.description, "Updated description")
    }

    func testMockUpdateItem() async throws {
        let items = try await mockService.fetchItems()
        guard let existingItem = items.first else {
            XCTFail("Mock should provide test items")
            return
        }
        
        existingItem.name = "Updated Mock Item"
        try await mockService.update(item: existingItem)
        
        let updatedItem = try await mockService.fetchItem(withId: existingItem.id)
        XCTAssertEqual(updatedItem?.name, "Updated Mock Item")
    }

    // MARK: - Delete Item Tests

    func testDeleteExistingItem() async throws {
        let item = Item(name: "To Delete", description: "", estimatedValue: 100, photos: [], updatedAt: Date())
        try await liveService.save(item: item)
        
        // Verify it exists
        let beforeDelete = try await liveService.fetchItems()
        XCTAssertEqual(beforeDelete.count, 1)
        
        // Delete it
        try await liveService.delete(item: item)
        
        // Verify it's gone
        let afterDelete = try await liveService.fetchItems()
        XCTAssertEqual(afterDelete.count, 0)
        
        // Verify fetch by ID returns nil
        let deletedItem = try await liveService.fetchItem(withId: item.id)
        XCTAssertNil(deletedItem)
    }

    func testDeleteNonExistentItem() async throws {
        let nonExistentItem = Item(name: "Non-existent", description: "", estimatedValue: 100, photos: [], updatedAt: Date())
        
        // Should not throw an error when deleting non-existent item
        try await liveService.delete(item: nonExistentItem)
        
        let items = try await liveService.fetchItems()
        XCTAssertEqual(items.count, 0)
    }

    func testDeleteItemRemovesFromCache() async throws {
        let item = Item(name: "Cache Delete Test", description: "", estimatedValue: 100, photos: [], updatedAt: Date())
        try await liveService.save(item: item)
        
        // Ensure it's cached by fetching it
        let cachedItem = try await liveService.fetchItem(withId: item.id)
        XCTAssertNotNil(cachedItem)
        
        // Delete the item
        try await liveService.delete(item: item)
        
        // Cache should be cleared
        let deletedItem = try await liveService.fetchItem(withId: item.id)
        XCTAssertNil(deletedItem)
    }

    func testMockDeleteItem() async throws {
        let items = try await mockService.fetchItems()
        guard let itemToDelete = items.first else {
            XCTFail("Mock should provide test items")
            return
        }
        
        try await mockService.delete(item: itemToDelete)
        
        let remainingItems = try await mockService.fetchItems()
        XCTAssertFalse(remainingItems.contains { $0.id == itemToDelete.id })
    }
}
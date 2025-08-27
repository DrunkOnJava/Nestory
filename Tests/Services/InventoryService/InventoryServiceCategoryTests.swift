// Layer: Tests
// Module: Services
// Purpose: Category management tests for InventoryService

import SwiftData
import XCTest

@testable import Nestory

@MainActor
final class InventoryServiceCategoryTests: XCTestCase {
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

    // MARK: - Category CRUD Tests

    func testFetchCategoriesFromEmptyDatabase() async throws {
        let categories = try await liveService.fetchCategories()
        XCTAssertEqual(categories.count, 0)
    }

    func testSaveAndFetchCategories() async throws {
        let electronics = Category(name: "Electronics", color: .blue, icon: "tv")
        let furniture = Category(name: "Furniture", color: .brown, icon: "chair")

        try await liveService.save(category: electronics)
        try await liveService.save(category: furniture)

        let categories = try await liveService.fetchCategories()
        XCTAssertEqual(categories.count, 2)
        XCTAssertTrue(categories.contains { $0.name == "Electronics" })
        XCTAssertTrue(categories.contains { $0.name == "Furniture" })
    }

    func testAssignItemToCategory() async throws {
        let electronics = Category(name: "Electronics", color: .blue, icon: "tv")
        try await liveService.save(category: electronics)

        let iphone = Item(name: "iPhone", description: "Smartphone", estimatedValue: 999, photos: [], updatedAt: Date())
        try await liveService.save(item: iphone)

        // Assign item to category
        try await liveService.assignItem(iphone.id, to: electronics.id)

        // Verify assignment
        let updatedItem = try await liveService.fetchItem(withId: iphone.id)
        XCTAssertNotNil(updatedItem)
        XCTAssertEqual(updatedItem?.category?.id, electronics.id)
        XCTAssertEqual(updatedItem?.category?.name, "Electronics")
    }

    func testFetchItemsByCategory() async throws {
        // Create categories
        let electronics = Category(name: "Electronics", color: .blue, icon: "tv")
        let furniture = Category(name: "Furniture", color: .brown, icon: "chair")

        try await liveService.save(category: electronics)
        try await liveService.save(category: furniture)

        // Create items
        let iphone = Item(name: "iPhone", description: "Smartphone", estimatedValue: 999, photos: [], updatedAt: Date())
        let ipad = Item(name: "iPad", description: "Tablet", estimatedValue: 599, photos: [], updatedAt: Date())
        let desk = Item(name: "Desk", description: "Office desk", estimatedValue: 300, photos: [], updatedAt: Date())

        try await liveService.save(item: iphone)
        try await liveService.save(item: ipad)
        try await liveService.save(item: desk)

        // Assign items to categories
        try await liveService.assignItem(iphone.id, to: electronics.id)
        try await liveService.assignItem(ipad.id, to: electronics.id)
        try await liveService.assignItem(desk.id, to: furniture.id)

        // Fetch items by category
        let electronicsItems = try await liveService.fetchItems(in: electronics.id)
        XCTAssertEqual(electronicsItems.count, 2)
        XCTAssertTrue(electronicsItems.contains { $0.name == "iPhone" })
        XCTAssertTrue(electronicsItems.contains { $0.name == "iPad" })

        let furnitureItems = try await liveService.fetchItems(in: furniture.id)
        XCTAssertEqual(furnitureItems.count, 1)
        XCTAssertEqual(furnitureItems.first?.name, "Desk")
    }

    // MARK: - Category Assignment Error Tests

    func testAssignItemToCategoryWithNonExistentItem() async throws {
        let electronics = Category(name: "Electronics", color: .blue, icon: "tv")
        try await liveService.save(category: electronics)

        let nonExistentItemId = UUID()

        // This should throw an error or handle gracefully
        do {
            try await liveService.assignItem(nonExistentItemId, to: electronics.id)
            XCTFail("Expected error when assigning non-existent item to category")
        } catch InventoryError.itemNotFound {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAssignItemToCategoryWithNonExistentCategory() async throws {
        let item = Item(name: "Test Item", description: "Test", estimatedValue: 100, photos: [], updatedAt: Date())
        try await liveService.save(item: item)

        let nonExistentCategoryId = UUID()

        // This should throw an error or handle gracefully
        do {
            try await liveService.assignItem(item.id, to: nonExistentCategoryId)
            XCTFail("Expected error when assigning item to non-existent category")
        } catch InventoryError.categoryNotFound {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Category Management Tests

    func testUpdateCategory() async throws {
        let category = Category(name: "Electronics", color: .blue, icon: "tv")
        try await liveService.save(category: category)

        // Update category
        category.name = "Consumer Electronics"
        category.color = .purple
        category.icon = "iphone"

        try await liveService.save(category: category)

        // Verify update
        let categories = try await liveService.fetchCategories()
        let updatedCategory = categories.first { $0.id == category.id }
        XCTAssertNotNil(updatedCategory)
        XCTAssertEqual(updatedCategory?.name, "Consumer Electronics")
        XCTAssertEqual(updatedCategory?.color, .purple)
        XCTAssertEqual(updatedCategory?.icon, "iphone")
    }

    func testDeleteCategory() async throws {
        let category = Category(name: "Test Category", color: .red, icon: "star")
        try await liveService.save(category: category)

        // Create item assigned to this category
        let item = Item(name: "Test Item", description: "Test", estimatedValue: 100, photos: [], updatedAt: Date())
        try await liveService.save(item: item)
        try await liveService.assignItem(item.id, to: category.id)

        // Delete category
        try await liveService.delete(category: category)

        // Verify category is deleted
        let categories = try await liveService.fetchCategories()
        XCTAssertFalse(categories.contains { $0.id == category.id })

        // Verify item's category reference is cleared
        let updatedItem = try await liveService.fetchItem(withId: item.id)
        XCTAssertNil(updatedItem?.category)
    }

    func testFetchCategoryById() async throws {
        let category = Category(name: "Test Category", color: .green, icon: "leaf")
        try await liveService.save(category: category)

        let fetchedCategory = try await liveService.fetchCategory(withId: category.id)
        XCTAssertNotNil(fetchedCategory)
        XCTAssertEqual(fetchedCategory?.name, "Test Category")
        XCTAssertEqual(fetchedCategory?.color, .green)
    }

    func testFetchNonExistentCategory() async throws {
        let nonExistentId = UUID()
        let category = try await liveService.fetchCategory(withId: nonExistentId)
        XCTAssertNil(category)
    }

    // MARK: - Category Integration Tests

    func testCategoryItemCount() async throws {
        let electronics = Category(name: "Electronics", color: .blue, icon: "tv")
        try await liveService.save(category: electronics)

        // Initially no items
        let emptyItems = try await liveService.fetchItems(in: electronics.id)
        XCTAssertEqual(emptyItems.count, 0)

        // Add items
        let iphone = Item(name: "iPhone", description: "Smartphone", estimatedValue: 999, photos: [], updatedAt: Date())
        let ipad = Item(name: "iPad", description: "Tablet", estimatedValue: 599, photos: [], updatedAt: Date())

        try await liveService.save(item: iphone)
        try await liveService.save(item: ipad)

        try await liveService.assignItem(iphone.id, to: electronics.id)
        try await liveService.assignItem(ipad.id, to: electronics.id)

        // Now should have 2 items
        let itemsWithCategory = try await liveService.fetchItems(in: electronics.id)
        XCTAssertEqual(itemsWithCategory.count, 2)
    }

    func testReassignItemToNewCategory() async throws {
        let electronics = Category(name: "Electronics", color: .blue, icon: "tv")
        let appliances = Category(name: "Appliances", color: .gray, icon: "refrigerator")

        try await liveService.save(category: electronics)
        try await liveService.save(category: appliances)

        let item = Item(name: "Smart TV", description: "Television", estimatedValue: 800, photos: [], updatedAt: Date())
        try await liveService.save(item: item)

        // Initially assign to electronics
        try await liveService.assignItem(item.id, to: electronics.id)

        let electronicsAssigned = try await liveService.fetchItem(withId: item.id)
        XCTAssertEqual(electronicsAssigned?.category?.id, electronics.id)

        // Reassign to appliances
        try await liveService.assignItem(item.id, to: appliances.id)

        let appliancesAssigned = try await liveService.fetchItem(withId: item.id)
        XCTAssertEqual(appliancesAssigned?.category?.id, appliances.id)

        // Verify item moved from electronics to appliances
        let electronicsItems = try await liveService.fetchItems(in: electronics.id)
        let applianceItems = try await liveService.fetchItems(in: appliances.id)

        XCTAssertEqual(electronicsItems.count, 0)
        XCTAssertEqual(applianceItems.count, 1)
    }
}
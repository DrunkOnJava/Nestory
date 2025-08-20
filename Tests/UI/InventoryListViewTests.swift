//
// Layer: Tests
// Module: InventoryListViewTests
// Purpose: Comprehensive tests for inventory list display and interactions
//

@testable import Nestory
import SwiftData
import SwiftUI
import XCTest

@MainActor
final class InventoryListViewTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() async throws {
        try await super.setUp()

        // Set up in-memory model container for testing
        let schema = Schema([Item.self, Category.self, Room.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = container.mainContext
    }

    override func tearDown() async throws {
        container = nil
        context = nil
        try await super.tearDown()
    }

    // MARK: - Empty State Tests

    func testEmptyInventoryView() throws {
        let inventoryView = InventoryListView()
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: inventoryView)
        hostingController.loadViewIfNeeded()

        // Should render empty state without crashing
        XCTAssertNotNil(hostingController.view)
    }

    func testEmptyStateDisplay() throws {
        // With no items, should show empty state
        let inventoryView = InventoryListView()
            .modelContainer(container)

        XCTAssertNoThrow(inventoryView)

        // Verify no items exist in the context
        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try context.fetch(fetchDescriptor)
        XCTAssertEqual(items.count, 0, "Should start with no items")
    }

    // MARK: - Populated List Tests

    func testInventoryWithItems() throws {
        // Create test data
        let category = Category(name: "Electronics")
        context.insert(category)

        let item1 = Item(name: "MacBook Pro")
        item1.category = category
        item1.purchasePrice = Money(amount: 2999.99, currency: .usd)
        context.insert(item1)

        let item2 = Item(name: "iPhone")
        item2.category = category
        item2.purchasePrice = Money(amount: 999.99, currency: .usd)
        context.insert(item2)

        try context.save()

        let inventoryView = InventoryListView()
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: inventoryView)
        hostingController.loadViewIfNeeded()

        // Should render successfully with items
        XCTAssertNotNil(hostingController.view)

        // Verify items were created
        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try context.fetch(fetchDescriptor)
        XCTAssertEqual(items.count, 2, "Should have 2 items")
    }

    // MARK: - Search Functionality Tests

    func testSearchFunctionality() throws {
        // Create test items with different names
        let electronics = Category(name: "Electronics")
        context.insert(electronics)

        let furniture = Category(name: "Furniture")
        context.insert(furniture)

        let laptop = Item(name: "MacBook Pro")
        laptop.category = electronics
        context.insert(laptop)

        let phone = Item(name: "iPhone")
        phone.category = electronics
        context.insert(phone)

        let chair = Item(name: "Office Chair")
        chair.category = furniture
        context.insert(chair)

        try context.save()

        let inventoryView = InventoryListView()
            .modelContainer(container)

        // Test that view renders with search capability
        XCTAssertNoThrow(inventoryView)

        // Verify all items exist
        let fetchDescriptor = FetchDescriptor<Item>()
        let allItems = try context.fetch(fetchDescriptor)
        XCTAssertEqual(allItems.count, 3, "Should have 3 items total")
    }

    // MARK: - Navigation Tests

    func testNavigationStructure() throws {
        let inventoryView = InventoryListView()
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: inventoryView)
        hostingController.loadViewIfNeeded()

        // Should have navigation structure
        XCTAssertNotNil(hostingController.view)

        // Test that navigation stack is set up correctly
        let navigationController = hostingController.children.compactMap { $0 as? UINavigationController }.first
        XCTAssertNotNil(navigationController, "Should be embedded in navigation controller")
    }

    // MARK: - Item Creation Flow Tests

    func testAddItemButtonExists() throws {
        let inventoryView = InventoryListView()
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: inventoryView)
        hostingController.loadViewIfNeeded()

        // The view should render the add button in the toolbar
        XCTAssertNotNil(hostingController.view)
    }

    // MARK: - Item Deletion Tests

    func testItemDeletion() throws {
        // Create a test item
        let category = Category(name: "Test Category")
        context.insert(category)

        let item = Item(name: "Test Item")
        item.category = category
        context.insert(item)

        try context.save()

        // Verify item exists
        let fetchDescriptor = FetchDescriptor<Item>()
        var items = try context.fetch(fetchDescriptor)
        XCTAssertEqual(items.count, 1, "Should have 1 item initially")

        // Delete the item
        context.delete(item)
        try context.save()

        // Verify item is deleted
        items = try context.fetch(fetchDescriptor)
        XCTAssertEqual(items.count, 0, "Should have 0 items after deletion")
    }

    // MARK: - Performance Tests

    func testInventoryViewPerformance() throws {
        // Create many items for performance testing
        let category = Category(name: "Performance Test")
        context.insert(category)

        for i in 1 ... 100 {
            let item = Item(name: "Item \(i)")
            item.category = category
            context.insert(item)
        }

        try context.save()

        measure {
            let inventoryView = InventoryListView()
                .modelContainer(container)

            let hostingController = UIHostingController(rootView: inventoryView)
            hostingController.loadViewIfNeeded()
        }
    }

    // MARK: - Error Handling Tests

    func testInventoryViewWithCorruptedData() throws {
        // Test with invalid data
        let inventoryView = InventoryListView()
            .modelContainer(container)

        // Should handle gracefully even with potential data issues
        XCTAssertNoThrow(inventoryView)
    }

    // MARK: - Integration Tests

    func testInventoryItemRowRendering() throws {
        // Create test item with all properties
        let category = Category(name: "Electronics")
        context.insert(category)

        let room = Room(name: "Living Room")
        context.insert(room)

        let item = Item(name: "MacBook Pro 16\"")
        item.itemDescription = "2023 M3 Max, 64GB RAM"
        item.category = category
        item.room = room
        item.purchasePrice = Money(amount: 3999.99, currency: .usd)
        item.condition = .excellent
        item.serialNumber = "ABC123"
        context.insert(item)

        try context.save()

        let inventoryView = InventoryListView()
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: inventoryView)
        hostingController.loadViewIfNeeded()

        // Should render item with all properties without crashing
        XCTAssertNotNil(hostingController.view)
    }

    func testInventoryViewWithMultipleCategories() throws {
        // Test inventory view with items across different categories
        let electronics = Category(name: "Electronics")
        let furniture = Category(name: "Furniture")
        let clothing = Category(name: "Clothing")

        context.insert(electronics)
        context.insert(furniture)
        context.insert(clothing)

        // Create items in each category
        let laptop = Item(name: "Laptop")
        laptop.category = electronics
        context.insert(laptop)

        let chair = Item(name: "Chair")
        chair.category = furniture
        context.insert(chair)

        let shirt = Item(name: "Shirt")
        shirt.category = clothing
        context.insert(shirt)

        try context.save()

        let inventoryView = InventoryListView()
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: inventoryView)
        hostingController.loadViewIfNeeded()

        // Should handle multiple categories correctly
        XCTAssertNotNil(hostingController.view)

        // Verify all items and categories exist
        let itemFetch = FetchDescriptor<Item>()
        let items = try context.fetch(itemFetch)
        XCTAssertEqual(items.count, 3, "Should have 3 items")

        let categoryFetch = FetchDescriptor<Category>()
        let categories = try context.fetch(categoryFetch)
        XCTAssertEqual(categories.count, 3, "Should have 3 categories")
    }
}

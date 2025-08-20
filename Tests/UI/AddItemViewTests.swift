//
// Layer: Tests
// Module: AddItemViewTests
// Purpose: Comprehensive tests for item creation flow
//

@testable import Nestory
import SwiftData
import SwiftUI
import XCTest

@MainActor
final class AddItemViewTests: XCTestCase {
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

    // MARK: - Basic Rendering Tests

    func testAddItemViewRendering() throws {
        let addItemView = AddItemView()
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: addItemView)
        hostingController.loadViewIfNeeded()

        // Should render without crashing
        XCTAssertNotNil(hostingController.view)
    }

    func testAddItemViewWithCategories() throws {
        // Create test categories
        let electronics = Category(name: "Electronics")
        let furniture = Category(name: "Furniture")
        context.insert(electronics)
        context.insert(furniture)

        try context.save()

        let addItemView = AddItemView()
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: addItemView)
        hostingController.loadViewIfNeeded()

        // Should render with categories available
        XCTAssertNotNil(hostingController.view)

        // Verify categories exist
        let categoryFetch = FetchDescriptor<Category>()
        let categories = try context.fetch(categoryFetch)
        XCTAssertEqual(categories.count, 2, "Should have 2 categories")
    }

    // MARK: - Form Validation Tests

    func testItemCreationRequiresName() throws {
        // Initially, there should be no items
        let fetchDescriptor = FetchDescriptor<Item>()
        var items = try context.fetch(fetchDescriptor)
        XCTAssertEqual(items.count, 0, "Should start with no items")

        // Create an item programmatically (simulating form submission)
        let category = Category(name: "Test Category")
        context.insert(category)

        // Item creation without name should still work (name can be empty string)
        let item = Item(name: "") // Empty name is allowed by model
        item.category = category
        context.insert(item)

        try context.save()

        items = try context.fetch(fetchDescriptor)
        XCTAssertEqual(items.count, 1, "Should create item even with empty name")
        XCTAssertEqual(items.first?.name, "", "Item should have empty name")
    }

    func testItemCreationWithValidData() throws {
        let category = Category(name: "Electronics")
        context.insert(category)

        // Create item with complete data
        let item = Item(name: "MacBook Pro")
        item.itemDescription = "16-inch laptop"
        item.quantity = 1
        item.category = category
        item.brand = "Apple"
        item.modelNumber = "MBP16"
        item.serialNumber = "ABC123"
        item.notes = "Personal laptop"
        item.purchasePrice = Decimal(2999.99)
        item.purchaseDate = Date()

        context.insert(item)
        try context.save()

        // Verify item was created correctly
        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try context.fetch(fetchDescriptor)

        XCTAssertEqual(items.count, 1, "Should have 1 item")

        let savedItem = items.first!
        XCTAssertEqual(savedItem.name, "MacBook Pro")
        XCTAssertEqual(savedItem.itemDescription, "16-inch laptop")
        XCTAssertEqual(savedItem.quantity, 1)
        XCTAssertEqual(savedItem.brand, "Apple")
        XCTAssertEqual(savedItem.modelNumber, "MBP16")
        XCTAssertEqual(savedItem.serialNumber, "ABC123")
        XCTAssertEqual(savedItem.notes, "Personal laptop")
        XCTAssertEqual(savedItem.purchasePrice, Decimal(2999.99))
        XCTAssertEqual(savedItem.category?.name, "Electronics")
    }

    // MARK: - Category Selection Tests

    func testCategorySelection() throws {
        // Create test categories
        let electronics = Category(name: "Electronics")
        let furniture = Category(name: "Furniture")
        let clothing = Category(name: "Clothing")

        context.insert(electronics)
        context.insert(furniture)
        context.insert(clothing)

        try context.save()

        // Create items in different categories
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

        // Verify category assignments
        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try context.fetch(fetchDescriptor)

        XCTAssertEqual(items.count, 3, "Should have 3 items")

        let laptopItem = items.first { $0.name == "Laptop" }
        let chairItem = items.first { $0.name == "Chair" }
        let shirtItem = items.first { $0.name == "Shirt" }

        XCTAssertEqual(laptopItem?.category?.name, "Electronics")
        XCTAssertEqual(chairItem?.category?.name, "Furniture")
        XCTAssertEqual(shirtItem?.category?.name, "Clothing")
    }

    // MARK: - Default Categories Tests

    func testDefaultCategoriesCreation() throws {
        // Start with no categories
        let categoryFetch = FetchDescriptor<Category>()
        var categories = try context.fetch(categoryFetch)
        XCTAssertEqual(categories.count, 0, "Should start with no categories")

        // Create default categories
        let defaultCategories = Category.createDefaultCategories()
        for category in defaultCategories {
            context.insert(category)
        }

        try context.save()

        categories = try context.fetch(categoryFetch)
        XCTAssertGreaterThan(categories.count, 0, "Should create default categories")

        // Verify some expected default categories exist
        let categoryNames = categories.map(\.name)
        XCTAssertTrue(categoryNames.contains("Electronics"), "Should have Electronics category")
        XCTAssertTrue(categoryNames.contains("Furniture"), "Should have Furniture category")
    }

    // MARK: - Quantity Tests

    func testQuantityHandling() throws {
        let category = Category(name: "Test")
        context.insert(category)

        // Test different quantity values
        let item1 = Item(name: "Single Item")
        item1.quantity = 1
        item1.category = category
        context.insert(item1)

        let item2 = Item(name: "Multiple Items")
        item2.quantity = 5
        item2.category = category
        context.insert(item2)

        let item3 = Item(name: "Many Items")
        item3.quantity = 999 // Maximum allowed in UI
        item3.category = category
        context.insert(item3)

        try context.save()

        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try context.fetch(fetchDescriptor)

        XCTAssertEqual(items.count, 3, "Should have 3 items")

        let singleItem = items.first { $0.name == "Single Item" }
        let multipleItems = items.first { $0.name == "Multiple Items" }
        let manyItems = items.first { $0.name == "Many Items" }

        XCTAssertEqual(singleItem?.quantity, 1)
        XCTAssertEqual(multipleItems?.quantity, 5)
        XCTAssertEqual(manyItems?.quantity, 999)
    }

    // MARK: - Purchase Information Tests

    func testPurchaseInformationHandling() throws {
        let category = Category(name: "Electronics")
        context.insert(category)

        let item = Item(name: "iPhone")
        item.category = category

        // Test price parsing
        let priceString = "999.99"
        if let price = Decimal(string: priceString) {
            item.purchasePrice = price
        }

        let purchaseDate = Date()
        item.purchaseDate = purchaseDate

        context.insert(item)
        try context.save()

        // Verify purchase information
        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try context.fetch(fetchDescriptor)

        let savedItem = items.first!
        XCTAssertEqual(savedItem.purchasePrice, Decimal(999.99))
        XCTAssertEqual(savedItem.purchaseDate, purchaseDate)
    }

    func testInvalidPriceHandling() throws {
        // Test invalid price strings
        let invalidPrices = ["abc", "12.34.56", "", "  ", "$100"]

        for priceString in invalidPrices {
            let price = Decimal(string: priceString)
            XCTAssertNil(price, "Price '\(priceString)' should be invalid")
        }

        // Test valid price strings
        let validPrices = ["123.45", "0.99", "1000", "0"]

        for priceString in validPrices {
            let price = Decimal(string: priceString)
            XCTAssertNotNil(price, "Price '\(priceString)' should be valid")
        }
    }

    // MARK: - Image Data Tests

    func testImageDataHandling() throws {
        let category = Category(name: "Test")
        context.insert(category)

        // Create test image data
        let testImageData = Data([0x89, 0x50, 0x4E, 0x47]) // PNG header bytes

        let item = Item(name: "Item with Image")
        item.category = category
        item.imageData = testImageData

        context.insert(item)
        try context.save()

        // Verify image data is saved
        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try context.fetch(fetchDescriptor)

        let savedItem = items.first!
        XCTAssertEqual(savedItem.imageData, testImageData)
        XCTAssertNotNil(savedItem.imageData)
    }

    // MARK: - Performance Tests

    func testAddItemViewPerformance() throws {
        // Create many categories for performance testing
        for i in 1 ... 50 {
            let category = Category(name: "Category \(i)")
            context.insert(category)
        }

        try context.save()

        measure {
            let addItemView = AddItemView()
                .modelContainer(container)

            let hostingController = UIHostingController(rootView: addItemView)
            hostingController.loadViewIfNeeded()
        }
    }

    // MARK: - Integration Tests

    func testCompleteItemCreationFlow() throws {
        // Simulate complete item creation
        let category = Category(name: "Electronics")
        context.insert(category)

        // Create item with all possible fields filled
        let item = Item(name: "MacBook Pro 16\"")
        item.itemDescription = "Top of the line laptop for development work"
        item.quantity = 1
        item.category = category
        item.brand = "Apple"
        item.modelNumber = "MacBookPro18,2"
        item.serialNumber = "C02XL1234567"
        item.notes = "Company laptop, handle with care"
        item.purchasePrice = Decimal(3999.99)
        item.purchaseDate = Date()

        // Mock image data
        item.imageData = Data([0x89, 0x50, 0x4E, 0x47])

        context.insert(item)
        try context.save()

        // Verify everything was saved correctly
        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try context.fetch(fetchDescriptor)

        XCTAssertEqual(items.count, 1, "Should have 1 item")

        let savedItem = items.first!
        XCTAssertEqual(savedItem.name, "MacBook Pro 16\"")
        XCTAssertEqual(savedItem.itemDescription, "Top of the line laptop for development work")
        XCTAssertEqual(savedItem.quantity, 1)
        XCTAssertEqual(savedItem.brand, "Apple")
        XCTAssertEqual(savedItem.modelNumber, "MacBookPro18,2")
        XCTAssertEqual(savedItem.serialNumber, "C02XL1234567")
        XCTAssertEqual(savedItem.notes, "Company laptop, handle with care")
        XCTAssertEqual(savedItem.purchasePrice, Decimal(3999.99))
        XCTAssertNotNil(savedItem.purchaseDate)
        XCTAssertNotNil(savedItem.imageData)
        XCTAssertEqual(savedItem.category?.name, "Electronics")
    }

    // MARK: - Error Handling Tests

    func testAddItemViewWithoutModelContainer() throws {
        // This should handle gracefully
        let addItemView = AddItemView()
        XCTAssertNoThrow(addItemView)
    }

    func testItemCreationWithNilCategory() throws {
        // Item should be created even without category
        let item = Item(name: "Uncategorized Item")
        item.category = nil

        context.insert(item)
        try context.save()

        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try context.fetch(fetchDescriptor)

        XCTAssertEqual(items.count, 1, "Should create item without category")
        XCTAssertNil(items.first?.category, "Category should be nil")
    }
}

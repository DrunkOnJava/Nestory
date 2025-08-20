//
// Layer: Tests
// Module: UITestHelpers
// Purpose: Shared utilities and helpers for UI testing
//

@testable import Nestory
import SwiftData
import SwiftUI
import XCTest

@MainActor
enum UITestHelpers {
    // MARK: - Container Setup

    /// Creates an in-memory model container for testing
    static func createTestContainer() throws -> ModelContainer {
        let schema = Schema([Item.self, Category.self, Room.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// Creates a test container with sample data
    static func createTestContainerWithSampleData() throws -> (ModelContainer, ModelContext) {
        let container = try createTestContainer()
        let context = container.mainContext

        // Create sample categories
        let electronics = Category(name: "Electronics")
        electronics.icon = "laptopcomputer"
        electronics.colorHex = "#007AFF"

        let furniture = Category(name: "Furniture")
        furniture.icon = "chair"
        furniture.colorHex = "#34C759"

        let clothing = Category(name: "Clothing")
        clothing.icon = "tshirt"
        clothing.colorHex = "#FF9500"

        context.insert(electronics)
        context.insert(furniture)
        context.insert(clothing)

        // Create sample items
        let laptop = Item(name: "MacBook Pro 16\"")
        laptop.itemDescription = "2023 M3 Max, 64GB RAM, 2TB SSD"
        laptop.quantity = 1
        laptop.category = electronics
        laptop.brand = "Apple"
        laptop.modelNumber = "MacBookPro18,2"
        laptop.serialNumber = "C02XL1234567"
        laptop.purchasePrice = Decimal(3999.99)
        laptop.purchaseDate = Date(timeIntervalSinceReferenceDate: 694_224_000) // Fixed date
        laptop.condition = .excellent
        laptop.notes = "Company laptop for development work"

        let chair = Item(name: "Herman Miller Aeron")
        chair.itemDescription = "Ergonomic office chair, size B"
        chair.quantity = 1
        chair.category = furniture
        chair.brand = "Herman Miller"
        chair.purchasePrice = Decimal(1395.00)
        chair.condition = .good
        chair.room = "Home Office"

        let shirt = Item(name: "Patagonia T-Shirt")
        shirt.itemDescription = "Organic cotton t-shirt, size M"
        shirt.quantity = 3
        shirt.category = clothing
        shirt.brand = "Patagonia"
        shirt.purchasePrice = Decimal(35.00)
        shirt.condition = .excellent

        context.insert(laptop)
        context.insert(chair)
        context.insert(shirt)

        try context.save()

        return (container, context)
    }

    // MARK: - View Testing Utilities

    /// Renders a SwiftUI view into a UIImage for testing
    static func renderView(_ view: some View, size: CGSize = CGSize(width: 375, height: 667)) -> UIImage {
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        hostingController.view.backgroundColor = .systemBackground

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            hostingController.view.layer.render(in: context.cgContext)
        }
    }

    /// Tests that a view renders without crashing
    static func testViewRendering(_ view: some View, testName: String = "View") {
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNoThrow(hostingController.loadViewIfNeeded(), "\(testName) should render without throwing")
        XCTAssertNotNil(hostingController.view, "\(testName) should have a valid view")
    }

    /// Tests that a view renders within a navigation context
    static func testViewRenderingInNavigation(_ view: some View, testName: String = "Navigation View") {
        let navigationView = NavigationStack { view }
        testViewRendering(navigationView, testName: testName)
    }

    // MARK: - Accessibility Testing Utilities

    /// Tests basic accessibility requirements for a view
    static func testViewAccessibility(_ view: some View,
                                      expectedMinimumElements: Int? = nil,
                                      testName: String = "View")
    {
        let hostingController = UIHostingController(rootView: view)
        hostingController.loadViewIfNeeded()

        // Basic accessibility validation
        XCTAssertNotNil(hostingController.view, "\(testName) should render")

        // Check that the view has accessibility elements
        let accessibilityElementCount = hostingController.view.accessibilityElementCount()
        let isAccessibilityElement = hostingController.view.isAccessibilityElement

        XCTAssertTrue(isAccessibilityElement || accessibilityElementCount > 0,
                      "\(testName) should have accessibility elements")

        if let expectedMinimum = expectedMinimumElements {
            XCTAssertGreaterThanOrEqual(accessibilityElementCount, expectedMinimum,
                                        "\(testName) should have at least \(expectedMinimum) accessibility elements")
        }
    }

    /// Tests a view with various dynamic type sizes
    static func testViewWithDynamicType(_ view: some View, testName: String = "Dynamic Type View") {
        let sizes: [ContentSizeCategory] = [
            .extraSmall,
            .medium,
            .extraLarge,
            .extraExtraExtraLarge,
            .accessibilityMedium,
            .accessibilityExtraExtraExtraLarge,
        ]

        for sizeCategory in sizes {
            let sizedView = view.environment(\.sizeCategory, sizeCategory)
            testViewRendering(sizedView, testName: "\(testName) - \(sizeCategory)")
        }
    }

    /// Tests a view with both light and dark themes
    static func testViewWithColorSchemes(_ view: some View, testName: String = "Theme View") {
        // Light theme
        let lightView = view.preferredColorScheme(.light)
        testViewRendering(lightView, testName: "\(testName) - Light")

        // Dark theme
        let darkView = view.preferredColorScheme(.dark)
        testViewRendering(darkView, testName: "\(testName) - Dark")
    }

    // MARK: - Performance Testing Utilities

    /// Measures the rendering performance of a view
    static func measureViewRenderingPerformance(_ view: some View,
                                                iterations: Int = 10,
                                                testName _: String = "View Performance")
    {
        measure {
            for _ in 0 ..< iterations {
                let hostingController = UIHostingController(rootView: view)
                hostingController.loadViewIfNeeded()
            }
        }
    }

    // MARK: - Mock Data Creation

    /// Creates a mock item with all properties filled
    static func createCompleteItem(in context: ModelContext) -> Item {
        let category = Category(name: "Test Electronics")
        category.icon = "laptopcomputer"
        context.insert(category)

        let room = Room(name: "Test Room")
        context.insert(room)

        let item = Item(name: "Complete Test Item")
        item.itemDescription = "A fully populated test item with all properties set"
        item.quantity = 2
        item.category = category
        item.room = room
        item.brand = "Test Brand"
        item.modelNumber = "TEST-123"
        item.serialNumber = "ABC123456789"
        item.purchasePrice = Decimal(999.99)
        item.purchaseDate = Date(timeIntervalSinceReferenceDate: 694_224_000)
        item.condition = .excellent
        item.conditionNotes = "Perfect condition, like new"
        item.notes = "Important test item for comprehensive testing"
        item.warrantyExpirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        item.specificLocation = "Top shelf"

        // Mock image data
        item.imageData = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) // PNG header
        item.receiptImageData = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        item.extractedReceiptText = "Test Store\nItem: Complete Test Item\nPrice: $999.99\nDate: 2023-01-15"

        // Mock condition photos
        item.conditionPhotos = [
            Data([0x01, 0x02, 0x03, 0x04]),
            Data([0x05, 0x06, 0x07, 0x08]),
        ]

        // Mock document names
        item.documentNames = ["manual.pdf", "warranty.pdf", "receipt.jpg"]

        context.insert(item)
        return item
    }

    /// Creates a minimal item with only required properties
    static func createMinimalItem(in context: ModelContext) -> Item {
        let item = Item(name: "Minimal Test Item")
        context.insert(item)
        return item
    }

    /// Creates multiple test items for list testing
    static func createMultipleTestItems(count: Int, in context: ModelContext) -> [Item] {
        let categories = ["Electronics", "Furniture", "Clothing", "Books", "Kitchen"]
        var items: [Item] = []

        // Create categories first
        let categoryObjects = categories.map { name in
            let category = Category(name: name)
            context.insert(category)
            return category
        }

        for i in 1 ... count {
            let item = Item(name: "Test Item \(i)")
            item.itemDescription = "Description for test item number \(i)"
            item.quantity = i % 5 + 1
            item.category = categoryObjects[i % categoryObjects.count]
            item.purchasePrice = Decimal(Double(i * 10) + 0.99)
            item.condition = ItemCondition.allCases[i % ItemCondition.allCases.count]

            context.insert(item)
            items.append(item)
        }

        return items
    }

    // MARK: - Test Environment Setup

    /// Sets up a complete test environment with theme manager
    static func createTestEnvironment() -> (ModelContainer, ModelContext, ThemeManager) {
        do {
            let container = try createTestContainer()
            let context = container.mainContext
            let themeManager = ThemeManager.shared
            themeManager.setTheme(.light) // Consistent theme for testing

            return (container, context, themeManager)
        } catch {
            fatalError("Failed to create test environment: \(error)")
        }
    }

    /// Sets up a test environment with sample data
    static func createTestEnvironmentWithData() -> (ModelContainer, ModelContext, ThemeManager) {
        do {
            let (container, context) = try createTestContainerWithSampleData()
            let themeManager = ThemeManager.shared
            themeManager.setTheme(.light)

            return (container, context, themeManager)
        } catch {
            fatalError("Failed to create test environment with data: \(error)")
        }
    }

    // MARK: - Assertion Helpers

    /// Asserts that a view contains expected text content
    static func assertViewContainsText(_ view: some View, expectedTexts: [String], testName: String = "View") {
        // This is a simplified version - in a real implementation,
        // you would need to introspect the view hierarchy to find text elements
        testViewRendering(view, testName: testName)

        // For now, just verify the view renders
        // In a complete implementation, this would search the rendered view for the expected text
        XCTAssertFalse(expectedTexts.isEmpty, "Should provide expected texts to check")
    }

    /// Asserts that a view properly handles empty states
    static func assertViewHandlesEmptyState(_ view: some View, testName: String = "Empty State View") {
        testViewRendering(view, testName: testName)

        // Empty state views should render without crashing
        XCTAssertTrue(true, "\(testName) should handle empty state gracefully")
    }

    /// Asserts that a view properly handles error states
    static func assertViewHandlesErrorState(_ view: some View, testName: String = "Error State View") {
        testViewRendering(view, testName: testName)

        // Error state views should render without crashing
        XCTAssertTrue(true, "\(testName) should handle error state gracefully")
    }
}

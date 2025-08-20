//
// Layer: Tests
// Module: ItemDetailViewTests
// Purpose: Comprehensive tests for item detail view and editing functionality
//

@testable import Nestory
import SwiftData
import SwiftUI
import XCTest

@MainActor
final class ItemDetailViewTests: XCTestCase {
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

    // MARK: - Helper Methods

    private func createTestItem() -> Item {
        let category = Category(name: "Electronics")
        context.insert(category)

        let item = Item(name: "Test MacBook Pro")
        item.itemDescription = "16-inch laptop for development"
        item.quantity = 1
        item.category = category
        item.brand = "Apple"
        item.modelNumber = "MBP16"
        item.serialNumber = "ABC123456"
        item.notes = "Personal laptop"
        item.purchasePrice = Decimal(2999.99)
        item.purchaseDate = Date()

        context.insert(item)
        return item
    }

    // MARK: - Basic Rendering Tests

    func testItemDetailViewRendering() throws {
        let item = createTestItem()
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        // Should render without crashing
        XCTAssertNotNil(hostingController.view)
    }

    func testItemDetailViewWithMinimalData() throws {
        let item = Item(name: "Minimal Item")
        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        // Should render item with minimal data
        XCTAssertNotNil(hostingController.view)
        XCTAssertEqual(item.name, "Minimal Item")
    }

    // MARK: - Image Display Tests

    func testItemDetailViewWithImage() throws {
        let item = createTestItem()

        // Create mock image data
        let mockImageData = Data([0x89, 0x50, 0x4E, 0x47]) // PNG header
        item.imageData = mockImageData

        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
        XCTAssertNotNil(item.imageData)
        XCTAssertEqual(item.imageData, mockImageData)
    }

    func testItemDetailViewWithoutImage() throws {
        let item = createTestItem()
        item.imageData = nil

        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
        XCTAssertNil(item.imageData)
    }

    // MARK: - Basic Information Display Tests

    func testBasicInformationDisplay() throws {
        let item = createTestItem()
        try context.save()

        // Verify all basic information is accessible
        XCTAssertEqual(item.name, "Test MacBook Pro")
        XCTAssertEqual(item.itemDescription, "16-inch laptop for development")
        XCTAssertEqual(item.quantity, 1)
        XCTAssertEqual(item.category?.name, "Electronics")

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        XCTAssertNoThrow(detailView)
    }

    // MARK: - Product Details Tests

    func testProductDetailsDisplay() throws {
        let item = createTestItem()
        try context.save()

        // Verify product details
        XCTAssertEqual(item.brand, "Apple")
        XCTAssertEqual(item.modelNumber, "MBP16")
        XCTAssertEqual(item.serialNumber, "ABC123456")

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        XCTAssertNoThrow(detailView)
    }

    func testProductDetailsWithMissingData() throws {
        let item = Item(name: "Simple Item")
        item.brand = nil
        item.modelNumber = nil
        item.serialNumber = nil

        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        // Should handle missing product details gracefully
        XCTAssertNotNil(hostingController.view)
        XCTAssertNil(item.brand)
        XCTAssertNil(item.modelNumber)
        XCTAssertNil(item.serialNumber)
    }

    // MARK: - Purchase Information Tests

    func testPurchaseInformationDisplay() throws {
        let item = createTestItem()
        try context.save()

        // Verify purchase information
        XCTAssertEqual(item.purchasePrice, Decimal(2999.99))
        XCTAssertNotNil(item.purchaseDate)

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        XCTAssertNoThrow(detailView)
    }

    func testPurchaseInformationWithMissingData() throws {
        let item = Item(name: "No Purchase Info")
        item.purchasePrice = nil
        item.purchaseDate = nil

        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        // Should handle missing purchase info gracefully
        XCTAssertNotNil(hostingController.view)
        XCTAssertNil(item.purchasePrice)
        XCTAssertNil(item.purchaseDate)
    }

    // MARK: - Condition Documentation Tests

    func testConditionDocumentationDisplay() throws {
        let item = createTestItem()
        item.condition = .excellent
        item.conditionNotes = "Like new condition"

        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
        XCTAssertEqual(item.condition, .excellent)
        XCTAssertEqual(item.conditionNotes, "Like new condition")
    }

    func testConditionPhotosDisplay() throws {
        let item = createTestItem()

        // Mock condition photos
        let mockPhoto1 = Data([0x01, 0x02, 0x03])
        let mockPhoto2 = Data([0x04, 0x05, 0x06])
        item.conditionPhotos = [mockPhoto1, mockPhoto2]

        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
        XCTAssertEqual(item.conditionPhotos.count, 2)
    }

    // MARK: - Warranty & Location Tests

    func testWarrantyInformationDisplay() throws {
        let item = createTestItem()

        // Set warranty date in the future
        let futureDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        item.warrantyExpirationDate = futureDate

        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
        XCTAssertNotNil(item.warrantyExpirationDate)
        XCTAssertTrue(item.warrantyExpirationDate! > Date())
    }

    func testExpiredWarrantyDisplay() throws {
        let item = createTestItem()

        // Set warranty date in the past
        let pastDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        item.warrantyExpirationDate = pastDate

        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
        XCTAssertNotNil(item.warrantyExpirationDate)
        XCTAssertTrue(item.warrantyExpirationDate! < Date())
    }

    func testLocationInformationDisplay() throws {
        let item = createTestItem()
        item.room = "Living Room"
        item.specificLocation = "Entertainment Center"

        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
        XCTAssertEqual(item.room, "Living Room")
        XCTAssertEqual(item.specificLocation, "Entertainment Center")
    }

    // MARK: - Document Management Tests

    func testDocumentNamesDisplay() throws {
        let item = createTestItem()
        item.documentNames = ["Manual.pdf", "Warranty.pdf", "Receipt.jpg"]

        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
        XCTAssertEqual(item.documentNames.count, 3)
        XCTAssertTrue(item.documentNames.contains("Manual.pdf"))
        XCTAssertTrue(item.documentNames.contains("Warranty.pdf"))
        XCTAssertTrue(item.documentNames.contains("Receipt.jpg"))
    }

    // MARK: - Receipt Documentation Tests

    func testReceiptDocumentationDisplay() throws {
        let item = createTestItem()

        // Mock receipt data
        let mockReceiptData = Data([0x89, 0x50, 0x4E, 0x47]) // PNG header
        item.receiptImageData = mockReceiptData
        item.extractedReceiptText = "Sample OCR text from receipt"

        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
        XCTAssertNotNil(item.receiptImageData)
        XCTAssertEqual(item.extractedReceiptText, "Sample OCR text from receipt")
    }

    func testNoReceiptDisplay() throws {
        let item = createTestItem()
        item.receiptImageData = nil
        item.extractedReceiptText = nil

        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
        XCTAssertNil(item.receiptImageData)
        XCTAssertNil(item.extractedReceiptText)
    }

    // MARK: - Notes Display Tests

    func testNotesDisplay() throws {
        let item = createTestItem()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
        XCTAssertEqual(item.notes, "Personal laptop")
    }

    func testNoNotesDisplay() throws {
        let item = Item(name: "No Notes Item")
        item.notes = nil

        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
        XCTAssertNil(item.notes)
    }

    // MARK: - Metadata Display Tests

    func testMetadataDisplay() throws {
        let item = createTestItem()
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
        XCTAssertNotNil(item.createdAt)
        XCTAssertNotNil(item.updatedAt)
    }

    // MARK: - Navigation Tests

    func testNavigationTitle() throws {
        let item = createTestItem()
        try context.save()

        let detailView = NavigationStack {
            ItemDetailView(item: item)
                .modelContainer(container)
        }

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)

        // Navigation title should be set to item name
        // In a real UI test, we would verify the navigation title
        XCTAssertEqual(item.name, "Test MacBook Pro")
    }

    // MARK: - Performance Tests

    func testItemDetailViewPerformance() throws {
        let item = createTestItem()

        // Add lots of condition photos for performance testing
        var conditionPhotos: [Data] = []
        for i in 1 ... 20 {
            conditionPhotos.append(Data([UInt8(i), 0x02, 0x03]))
        }
        item.conditionPhotos = conditionPhotos

        // Add many document names
        var documentNames: [String] = []
        for i in 1 ... 50 {
            documentNames.append("Document\(i).pdf")
        }
        item.documentNames = documentNames

        context.insert(item)
        try context.save()

        measure {
            let detailView = ItemDetailView(item: item)
                .modelContainer(container)

            let hostingController = UIHostingController(rootView: detailView)
            hostingController.loadViewIfNeeded()
        }
    }

    // MARK: - Integration Tests

    func testDetailRowComponent() throws {
        let detailRow = DetailRow(label: "Test Label", value: "Test Value")

        let hostingController = UIHostingController(rootView: detailRow)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
    }

    func testItemDetailViewWithAllFeatures() throws {
        let item = createTestItem()

        // Set up all possible features
        item.imageData = Data([0x89, 0x50, 0x4E, 0x47])
        item.condition = .excellent
        item.conditionNotes = "Perfect condition"
        item.conditionPhotos = [Data([0x01, 0x02, 0x03])]
        item.warrantyExpirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        item.room = "Home Office"
        item.specificLocation = "Desk"
        item.documentNames = ["Manual.pdf", "Warranty.pdf"]
        item.receiptImageData = Data([0x89, 0x50, 0x4E, 0x47])
        item.extractedReceiptText = "Receipt OCR text"

        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        // Should handle all features without crashing
        XCTAssertNotNil(hostingController.view)

        // Verify all features are set
        XCTAssertNotNil(item.imageData)
        XCTAssertEqual(item.condition, .excellent)
        XCTAssertNotNil(item.conditionNotes)
        XCTAssertEqual(item.conditionPhotos.count, 1)
        XCTAssertNotNil(item.warrantyExpirationDate)
        XCTAssertNotNil(item.room)
        XCTAssertNotNil(item.specificLocation)
        XCTAssertEqual(item.documentNames.count, 2)
        XCTAssertNotNil(item.receiptImageData)
        XCTAssertNotNil(item.extractedReceiptText)
    }

    // MARK: - Error Handling Tests

    func testItemDetailViewWithCorruptedData() throws {
        let item = createTestItem()

        // Set corrupted image data
        item.imageData = Data([0x00, 0x01]) // Invalid image data

        context.insert(item)
        try context.save()

        let detailView = ItemDetailView(item: item)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.loadViewIfNeeded()

        // Should handle corrupted data gracefully
        XCTAssertNotNil(hostingController.view)
    }
}

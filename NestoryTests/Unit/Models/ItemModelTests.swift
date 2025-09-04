//
// Layer: Unit/Models
// Module: ItemModelTests
// Purpose: Comprehensive tests for Item model, relationships, and data integrity
//

import XCTest
import SwiftData
@testable import Nestory

/// Comprehensive test suite for Item model covering initialization, relationships, computed properties, and data integrity
final class ItemModelTests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    private var modelContext: ModelContext!
    private var container: ModelContainer!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory model context for testing
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Item.self, Category.self, configurations: configuration)
        modelContext = ModelContext(container)
    }
    
    override func tearDown() async throws {
        modelContext = nil
        container = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testBasicInitialization() {
        let item = Item(name: "MacBook Pro")
        
        // Test required properties
        XCTAssertEqual(item.name, "MacBook Pro")
        XCTAssertNotNil(item.id)
        XCTAssertEqual(item.quantity, 1) // Default value
        XCTAssertEqual(item.currency, "USD") // Default value
        XCTAssertNotNil(item.createdAt)
        XCTAssertNotNil(item.updatedAt)
        
        // Test optional properties are nil by default
        XCTAssertNil(item.itemDescription)
        XCTAssertNil(item.category)
        XCTAssertNil(item.purchasePrice)
        XCTAssertNil(item.serialNumber)
    }
    
    func testFullInitialization() {
        let category = Category(name: "Electronics")
        let item = Item(
            name: "iPhone 16 Pro",
            itemDescription: "Latest flagship phone",
            quantity: 1,
            category: category
        )
        
        XCTAssertEqual(item.name, "iPhone 16 Pro")
        XCTAssertEqual(item.itemDescription, "Latest flagship phone")
        XCTAssertEqual(item.quantity, 1)
        XCTAssertEqual(item.category?.name, "Electronics")
    }
    
    func testUniqueIdentifiers() {
        let item1 = Item(name: "Item 1")
        let item2 = Item(name: "Item 2")
        
        XCTAssertNotEqual(item1.id, item2.id)
    }
    
    // MARK: - Property Tests
    
    func testFinancialProperties() {
        let item = Item(name: "Laptop")
        
        // Test setting financial information
        item.purchasePrice = 2500.0
        item.purchaseDate = Date(timeIntervalSince1970: 1640995200) // 2022-01-01
        item.currency = "EUR"
        
        XCTAssertEqual(item.purchasePrice, 2500.0)
        XCTAssertNotNil(item.purchaseDate)
        XCTAssertEqual(item.currency, "EUR")
    }
    
    func testWarrantyProperties() {
        let item = Item(name: "Phone")
        let futureDate = Date(timeIntervalSinceNow: 365 * 24 * 60 * 60) // 1 year from now
        
        item.warrantyExpirationDate = futureDate
        item.warrantyProvider = "AppleCare+"
        item.warrantyNotes = "Extended warranty with accidental damage coverage"
        
        XCTAssertEqual(item.warrantyExpirationDate, futureDate)
        XCTAssertEqual(item.warrantyProvider, "AppleCare+")
        XCTAssertEqual(item.warrantyNotes, "Extended warranty with accidental damage coverage")
    }
    
    func testLocationProperties() {
        let item = Item(name: "TV")
        
        // Test room only
        item.room = "Living Room"
        XCTAssertEqual(item.location, "Living Room")
        
        // Test room with specific location
        item.specificLocation = "Entertainment Center"
        XCTAssertEqual(item.location, "Living Room - Entertainment Center")
        
        // Test nil room
        item.room = nil
        XCTAssertNil(item.location)
    }
    
    func testConditionProperties() {
        let item = Item(name: "Camera")
        
        // Test default condition
        XCTAssertEqual(item.itemCondition, .excellent)
        XCTAssertEqual(item.condition, "excellent")
        
        // Test setting condition via enum
        item.itemCondition = .good
        XCTAssertEqual(item.itemCondition, .good)
        XCTAssertEqual(item.condition, "good")
        
        // Test setting condition via string
        item.condition = "fair"
        XCTAssertEqual(item.itemCondition, .fair)
        
        // Test invalid condition string defaults to excellent
        item.condition = "invalid_condition"
        XCTAssertEqual(item.itemCondition, .excellent)
    }
    
    func testTagsArray() {
        let item = Item(name: "Watch")
        
        // Test initial empty tags
        XCTAssertTrue(item.tags.isEmpty)
        
        // Test adding tags
        item.tags = ["luxury", "jewelry", "gift"]
        XCTAssertEqual(item.tags.count, 3)
        XCTAssertTrue(item.tags.contains("luxury"))
        XCTAssertTrue(item.tags.contains("jewelry"))
        XCTAssertTrue(item.tags.contains("gift"))
    }
    
    // MARK: - Image and Document Tests
    
    func testImageDataProperties() {
        let item = Item(name: "Artwork")
        let imageData = "fake_image_data".data(using: .utf8)!
        let receiptData = "fake_receipt_data".data(using: .utf8)!
        
        item.imageData = imageData
        item.receiptImageData = receiptData
        
        XCTAssertEqual(item.imageData, imageData)
        XCTAssertEqual(item.receiptImageData, receiptData)
        
        // Test computed photos array
        let photos = item.photos
        XCTAssertEqual(photos.count, 2)
        XCTAssertTrue(photos.contains(imageData))
        XCTAssertTrue(photos.contains(receiptData))
    }
    
    func testConditionPhotos() {
        let item = Item(name: "Furniture")
        let photo1 = "photo1_data".data(using: .utf8)!
        let photo2 = "photo2_data".data(using: .utf8)!
        
        item.conditionPhotos = [photo1, photo2]
        item.conditionPhotoDescriptions = ["Front view", "Side damage"]
        
        XCTAssertEqual(item.conditionPhotos.count, 2)
        XCTAssertEqual(item.conditionPhotoDescriptions.count, 2)
        XCTAssertEqual(item.conditionPhotoDescriptions[0], "Front view")
        XCTAssertEqual(item.conditionPhotoDescriptions[1], "Side damage")
        
        // Test that condition photos are included in computed photos array
        let allPhotos = item.photos
        XCTAssertTrue(allPhotos.contains(photo1))
        XCTAssertTrue(allPhotos.contains(photo2))
    }
    
    func testDocumentAttachments() {
        let item = Item(name: "Appliance")
        let manual = "manual_pdf_data".data(using: .utf8)!
        let document1 = "doc1_data".data(using: .utf8)!
        let document2 = "doc2_data".data(using: .utf8)!
        
        item.manualPDFData = manual
        item.documentAttachments = [document1, document2]
        item.documentNames = ["Warranty Card", "Service Record"]
        
        XCTAssertEqual(item.manualPDFData, manual)
        XCTAssertEqual(item.documentAttachments.count, 2)
        XCTAssertEqual(item.documentNames.count, 2)
        XCTAssertEqual(item.documentNames[0], "Warranty Card")
        XCTAssertEqual(item.documentNames[1], "Service Record")
    }
    
    // MARK: - Relationship Tests
    
    func testCategoryRelationship() throws {
        let category = Category(name: "Home & Garden")
        let item = Item(name: "Garden Tool", category: category)
        
        // Test relationship is set correctly
        XCTAssertEqual(item.category?.name, "Home & Garden")
        
        // Test with model context
        modelContext.insert(category)
        modelContext.insert(item)
        
        try modelContext.save()
        
        // Verify relationship persisted
        XCTAssertEqual(item.category?.name, "Home & Garden")
        XCTAssertEqual(category.items?.count, 1)
        XCTAssertEqual(category.items?.first?.name, "Garden Tool")
    }
    
    func testNilCategoryRelationship() {
        let item = Item(name: "Uncategorized Item")
        
        XCTAssertNil(item.category)
    }
    
    func testMultipleItemsInCategory() throws {
        let category = Category(name: "Books")
        let book1 = Item(name: "Swift Programming", category: category)
        let book2 = Item(name: "iOS Development", category: category)
        
        modelContext.insert(category)
        modelContext.insert(book1)
        modelContext.insert(book2)
        
        try modelContext.save()
        
        XCTAssertEqual(category.items?.count, 2)
        let itemNames = category.items?.map { $0.name }.sorted()
        XCTAssertEqual(itemNames, ["iOS Development", "Swift Programming"])
    }
    
    // MARK: - Receipt OCR Tests
    
    func testReceiptOCRIntegration() {
        let item = Item(name: "Coffee Maker")
        let receiptData = "receipt_image_data".data(using: .utf8)!
        let extractedText = "COFFEE MAKER - $89.99\nDate: 2024-01-15\nStore: Best Electronics"
        
        item.receiptImageData = receiptData
        item.extractedReceiptText = extractedText
        
        XCTAssertEqual(item.receiptImageData, receiptData)
        XCTAssertEqual(item.extractedReceiptText, extractedText)
        XCTAssertTrue(item.extractedReceiptText?.contains("$89.99") == true)
        XCTAssertTrue(item.extractedReceiptText?.contains("2024-01-15") == true)
    }
    
    // MARK: - Insurance Documentation Tests
    
    func testInsuranceReadinessValidation() {
        let item = Item(name: "Jewelry")
        
        // Initially not ready for insurance
        XCTAssertNil(item.imageData)
        XCTAssertNil(item.purchasePrice)
        XCTAssertNil(item.receiptImageData)
        XCTAssertNil(item.serialNumber)
        
        // Make it insurance-ready
        item.imageData = "jewelry_photo".data(using: .utf8)!
        item.purchasePrice = 5000.0
        item.receiptImageData = "receipt_photo".data(using: .utf8)!
        item.serialNumber = "JW123456789"
        item.itemDescription = "14K gold wedding ring with diamond"
        
        // Now it should have comprehensive insurance documentation
        XCTAssertNotNil(item.imageData)
        XCTAssertNotNil(item.purchasePrice)
        XCTAssertNotNil(item.receiptImageData)
        XCTAssertNotNil(item.serialNumber)
        XCTAssertNotNil(item.itemDescription)
    }
    
    func testHighValueItemProperties() {
        let item = Item(name: "Rolex Watch")
        
        // High-value item should have comprehensive documentation
        item.purchasePrice = 15000.0
        item.serialNumber = "116610LN"
        item.brand = "Rolex"
        item.modelNumber = "Submariner Date"
        item.itemDescription = "Stainless steel Submariner with black dial and ceramic bezel"
        item.imageData = "watch_photo".data(using: .utf8)!
        item.receiptImageData = "authorized_dealer_receipt".data(using: .utf8)!
        item.warrantyExpirationDate = Date(timeIntervalSinceNow: 5 * 365 * 24 * 60 * 60) // 5 years
        item.warrantyProvider = "Rolex International Warranty"
        
        XCTAssertEqual(item.purchasePrice, 15000.0)
        XCTAssertEqual(item.serialNumber, "116610LN")
        XCTAssertEqual(item.brand, "Rolex")
        XCTAssertEqual(item.modelNumber, "Submariner Date")
        XCTAssertNotNil(item.imageData)
        XCTAssertNotNil(item.receiptImageData)
        XCTAssertNotNil(item.warrantyExpirationDate)
        XCTAssertEqual(item.warrantyProvider, "Rolex International Warranty")
    }
    
    // MARK: - ItemCondition Enum Tests
    
    func testItemConditionEnum() {
        // Test all condition values
        let conditions: [ItemCondition] = [
            .excellent, .good, .fair, .poor, .damaged, .new, .likeNew, .refurbished
        ]
        
        for condition in conditions {
            let item = Item(name: "Test Item")
            item.itemCondition = condition
            XCTAssertEqual(item.itemCondition, condition)
            XCTAssertEqual(item.condition, condition.rawValue)
        }
    }
    
    func testItemConditionColors() {
        // Test that all conditions have color definitions
        for condition in ItemCondition.allCases {
            let color = condition.color
            XCTAssertFalse(color.isEmpty, "Condition \(condition) should have a color")
        }
    }
    
    // MARK: - Data Integrity Tests
    
    func testTimestampUpdates() {
        let item = Item(name: "Timestamp Test")
        let originalCreated = item.createdAt
        let originalUpdated = item.updatedAt
        
        // Simulate time passing
        Thread.sleep(forTimeInterval: 0.001)
        
        // Update item
        item.updatedAt = Date()
        
        XCTAssertEqual(item.createdAt, originalCreated) // Created should not change
        XCTAssertGreaterThan(item.updatedAt, originalUpdated) // Updated should be newer
    }
    
    func testDefaultValues() {
        let item = Item(name: "Default Test")
        
        // Test all default values
        XCTAssertEqual(item.quantity, 1)
        XCTAssertEqual(item.currency, "USD")
        XCTAssertEqual(item.itemCondition, .excellent)
        XCTAssertTrue(item.tags.isEmpty)
        XCTAssertTrue(item.conditionPhotos.isEmpty)
        XCTAssertTrue(item.documentAttachments.isEmpty)
        XCTAssertTrue(item.documentNames.isEmpty)
    }
    
    func testQuantityValidation() {
        let item = Item(name: "Quantity Test")
        
        // Test various quantity values
        item.quantity = 1
        XCTAssertEqual(item.quantity, 1)
        
        item.quantity = 10
        XCTAssertEqual(item.quantity, 10)
        
        item.quantity = 0 // Should be allowed for "out of stock" scenarios
        XCTAssertEqual(item.quantity, 0)
    }
    
    // MARK: - Performance Tests
    
    func testItemCreationPerformance() {
        measure {
            for i in 0..<1000 {
                let item = Item(name: "Performance Test Item \(i)")
                item.purchasePrice = Decimal(i)
                item.quantity = i % 10 + 1
                _ = item.location // Access computed property
                _ = item.photos // Access computed property
                _ = item.itemCondition // Access computed property
            }
        }
    }
    
    func testComputedPropertyPerformance() {
        let items = (0..<100).map { i in
            let item = Item(name: "Item \(i)")
            item.room = "Room \(i)"
            item.specificLocation = "Location \(i)"
            item.imageData = "data\(i)".data(using: .utf8)!
            item.receiptImageData = "receipt\(i)".data(using: .utf8)!
            item.conditionPhotos = ["photo\(i)_1".data(using: .utf8)!, "photo\(i)_2".data(using: .utf8)!]
            return item
        }
        
        measure {
            for item in items {
                _ = item.location
                _ = item.photos
                _ = item.itemCondition
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyStringProperties() {
        let item = Item(name: "") // Empty name should be allowed
        
        XCTAssertEqual(item.name, "")
        
        item.itemDescription = ""
        item.serialNumber = ""
        item.brand = ""
        
        XCTAssertEqual(item.itemDescription, "")
        XCTAssertEqual(item.serialNumber, "")
        XCTAssertEqual(item.brand, "")
    }
    
    func testVeryLongStringProperties() {
        let item = Item(name: "Test Item")
        let longString = String(repeating: "A", count: 10000)
        
        item.itemDescription = longString
        item.notes = longString
        
        XCTAssertEqual(item.itemDescription?.count, 10000)
        XCTAssertEqual(item.notes?.count, 10000)
    }
    
    func testLargeBinaryData() {
        let item = Item(name: "Large Data Test")
        let largeData = Data(repeating: 0xFF, count: 1_000_000) // 1MB of data
        
        item.imageData = largeData
        item.manualPDFData = largeData
        
        XCTAssertEqual(item.imageData?.count, 1_000_000)
        XCTAssertEqual(item.manualPDFData?.count, 1_000_000)
    }
    
    func testArrayOperations() {
        let item = Item(name: "Array Test")
        
        // Test tags array operations
        item.tags.append("electronics")
        item.tags.append("mobile")
        item.tags.append("apple")
        
        XCTAssertEqual(item.tags.count, 3)
        XCTAssertTrue(item.tags.contains("electronics"))
        
        item.tags.removeAll { $0 == "mobile" }
        XCTAssertEqual(item.tags.count, 2)
        XCTAssertFalse(item.tags.contains("mobile"))
        
        // Test photo arrays
        let photo1 = "photo1".data(using: .utf8)!
        let photo2 = "photo2".data(using: .utf8)!
        
        item.conditionPhotos = [photo1, photo2]
        XCTAssertEqual(item.conditionPhotos.count, 2)
        
        item.conditionPhotos.append("photo3".data(using: .utf8)!)
        XCTAssertEqual(item.conditionPhotos.count, 3)
    }
}
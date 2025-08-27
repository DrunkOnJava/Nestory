//
// Layer: Tests
// Module: Foundation
// Purpose: CloudKit compatibility validation tests
//

import XCTest
import SwiftData
@testable import Nestory

final class CloudKitCompatibilityTests: XCTestCase {
    
    @MainActor
    func testSwiftDataModelsCloudKitCompatibility() {
        // Test that all SwiftData models are CloudKit compatible
        // CloudKit Requirements:
        // 1. No unique constraints on properties
        // 2. Optional relationships or relationships with defaults
        // 3. All required properties have defaults
        
        // Test Item model
        let item = Item(name: "Test Item")
        XCTAssertNotNil(item.id)
        XCTAssertEqual(item.name, "Test Item")
        XCTAssertEqual(item.quantity, 1)
        XCTAssertEqual(item.currency, "USD")
        XCTAssertEqual(item.tags, [])
        XCTAssertNotNil(item.createdAt)
        XCTAssertNotNil(item.updatedAt)
        
        // Test optional relationships
        XCTAssertNil(item.category)
        XCTAssertNil(item.warranty)
        XCTAssertEqual(item.receipts, []) // Should be an empty array, not nil
        
        // Test Category model
        let category = Category(name: "Test Category")
        XCTAssertNotNil(category.id)
        XCTAssertEqual(category.name, "Test Category")
        XCTAssertEqual(category.icon, "folder.fill")
        XCTAssertEqual(category.colorHex, "#007AFF")
        XCTAssertEqual(category.itemCount, 0)
        XCTAssertNotNil(category.createdAt)
        XCTAssertNotNil(category.updatedAt)
        
        // Test Room model
        let room = Room(name: "Test Room")
        XCTAssertNotNil(room.id)
        XCTAssertEqual(room.name, "Test Room")
        XCTAssertEqual(room.icon, "door.left.hand.open")
        XCTAssertNil(room.roomDescription)
        XCTAssertNil(room.floor)
        
        // Test Receipt model
        let receipt = Receipt(
            vendor: "Test Store",
            total: Money(amount: 99.99, currencyCode: "USD"),
            purchaseDate: Date()
        )
        XCTAssertNotNil(receipt.id)
        XCTAssertEqual(receipt.vendor, "Test Store")
        XCTAssertNotNil(receipt.totalMoney)
        XCTAssertNotNil(receipt.purchaseDate)
        XCTAssertNotNil(receipt.createdAt)
        XCTAssertNotNil(receipt.updatedAt)
        
        // Test Warranty model
        let warranty = Warranty(
            provider: "Test Provider",
            type: .manufacturer,
            startDate: Date(),
            expiresAt: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        )
        XCTAssertNotNil(warranty.id)
        XCTAssertEqual(warranty.provider, "Test Provider")
        XCTAssertEqual(warranty.type, .manufacturer)
        XCTAssertNotNil(warranty.startDate)
        XCTAssertNotNil(warranty.expiresAt)
        XCTAssertNotNil(warranty.createdAt)
        XCTAssertNotNil(warranty.updatedAt)
    }
    
    @MainActor
    func testModelContainerLocalOnlyConfiguration() throws {
        // Test that we can create a local-only ModelContainer without CloudKit
        let schema = Schema([Item.self, Category.self, Room.self, Warranty.self, Receipt.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none  // Local-only
        )
        
        let container = try ModelContainer(for: schema, configurations: [config])
        XCTAssertNotNil(container)
        
        let context = container.mainContext
        XCTAssertNotNil(context)
        
        // Test basic data operations
        let testItem = Item(name: "CloudKit Test Item")
        context.insert(testItem)
        
        try context.save()
        
        // Verify item was saved
        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try context.fetch(fetchDescriptor)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "CloudKit Test Item")
    }
    
    func testOptionalReceiptsHandling() {
        // Test that code properly handles optional receipts array
        let item = Item(name: "Test Item")
        
        // Test empty receipts (should be [], not nil)
        XCTAssertEqual(item.receipts, [])
        XCTAssertTrue(item.receipts?.isEmpty ?? true)
        XCTAssertFalse(!(item.receipts?.isEmpty ?? true))
        
        // Test with nil receipts (defensive coding)
        var itemCopy = item
        itemCopy.receipts = nil
        XCTAssertTrue(itemCopy.receipts?.isEmpty ?? true)
        
        // Test our validation logic patterns
        let hasReceipts = !(item.receipts?.isEmpty ?? true)
        XCTAssertFalse(hasReceipts)
        
        let needsReceipts = item.receipts?.isEmpty ?? true
        XCTAssertTrue(needsReceipts)
    }
}
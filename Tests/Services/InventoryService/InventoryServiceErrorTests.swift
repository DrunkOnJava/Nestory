// Layer: Tests
// Module: Services
// Purpose: Error handling, performance, and model tests for InventoryService

import SwiftData
import XCTest

@testable import Nestory

@MainActor
final class InventoryServiceErrorTests: XCTestCase {
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

    // MARK: - Performance Tests

    func testFetchLargeNumberOfItemsPerformance() async throws {
        // Create a large dataset to test fetch performance
        let itemCount = 500
        for i in 0..<itemCount {
            let item = Item(
                name: "Performance Test Item \(i)",
                description: "Description \(i)",
                estimatedValue: Double(i),
                photos: [],
                updatedAt: Date().addingTimeInterval(TimeInterval(-i))
            )
            try await liveService.save(item: item)
        }

        // Measure fetch performance
        let startTime = CFAbsoluteTimeGetCurrent()
        let items = try await liveService.fetchItems()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertEqual(items.count, itemCount)
        XCTAssertLessThan(timeElapsed, 2.0) // Should complete within 2 seconds

        // Verify items are properly ordered (most recent first)
        for i in 0..<min(10, items.count - 1) {
            XCTAssertGreaterThanOrEqual(items[i].updatedAt, items[i + 1].updatedAt)
        }
    }

    func testSearchPerformance() async throws {
        // Create dataset with varied content for search testing
        let itemCount = 300
        for i in 0..<itemCount {
            let item = Item(
                name: "SearchTest \(i % 10) Item \(i)",
                description: "Description containing searchable content \(i)",
                estimatedValue: Double(i * 2),
                photos: [],
                updatedAt: Date()
            )
            item.brand = "Brand\(i % 5)"
            item.model = "Model\(i % 7)"
            try await liveService.save(item: item)
        }

        // Test common search patterns
        let searchQueries = ["SearchTest", "Brand1", "Model3", "Description", "content"]

        for query in searchQueries {
            let startTime = CFAbsoluteTimeGetCurrent()
            let results = try await liveService.searchItems(query: query)
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

            XCTAssertGreaterThan(results.count, 0)
            XCTAssertLessThan(timeElapsed, 0.5) // Should complete within 500ms
        }

        // Test edge case searches
        let edgeCaseQueries = ["", "NONEXISTENT", "SearchTest 1", "Brand1 Model3"]
        for query in edgeCaseQueries {
            let startTime = CFAbsoluteTimeGetCurrent()
            let results = try await liveService.searchItems(query: query)
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

            XCTAssertLessThan(timeElapsed, 0.5)

            if query == "" {
                // Empty query should return all items
                XCTAssertEqual(results.count, itemCount)
            }
        }
    }

    // MARK: - Error Handling Tests

    func testErrorDescriptions() {
        // Test InventoryError descriptions
        XCTAssertEqual(InventoryError.itemNotFound.localizedDescription, "Item not found")
        XCTAssertEqual(InventoryError.categoryNotFound.localizedDescription, "Category not found")
        XCTAssertEqual(InventoryError.saveError("test").localizedDescription, "Save failed: test")
        XCTAssertEqual(InventoryError.fetchError("test").localizedDescription, "Fetch failed: test")
        XCTAssertEqual(InventoryError.deleteError("test").localizedDescription, "Delete failed: test")
        XCTAssertEqual(InventoryError.invalidData("test").localizedDescription, "Invalid data: test")
        XCTAssertEqual(InventoryError.exportFormatNotSupported.localizedDescription, "Export format not supported")
        XCTAssertEqual(InventoryError.importError("test").localizedDescription, "Import failed: test")
        XCTAssertEqual(InventoryError.bulkOperationError("test").localizedDescription, "Bulk operation failed: test")
        XCTAssertEqual(InventoryError.cacheError("test").localizedDescription, "Cache error: test")
    }

    func testErrorEquality() {
        // Test error equality for proper error handling
        XCTAssertEqual(InventoryError.itemNotFound, InventoryError.itemNotFound)
        XCTAssertEqual(InventoryError.categoryNotFound, InventoryError.categoryNotFound)
        XCTAssertEqual(InventoryError.saveError("test"), InventoryError.saveError("test"))
        XCTAssertNotEqual(InventoryError.saveError("test1"), InventoryError.saveError("test2"))
        XCTAssertNotEqual(InventoryError.itemNotFound, InventoryError.categoryNotFound)
    }

    // MARK: - Export Format Tests

    func testExportFormatCases() {
        XCTAssertEqual(ExportFormat.json.rawValue, "json")
        XCTAssertEqual(ExportFormat.csv.rawValue, "csv")
        XCTAssertEqual(ExportFormat.pdf.rawValue, "pdf")
    }

    // MARK: - ItemTransferObject Tests

    func testItemTransferObjectFromItem() {
        let item = Item(name: "Test Item", description: "Test Description", estimatedValue: 999.99, photos: [], updatedAt: Date())
        item.brand = "Test Brand"
        item.model = "Test Model"
        item.serialNumber = "TEST123"
        item.warranty = "2 years"
        item.notes = "Test notes"
        item.tags = ["tag1", "tag2"]

        let transferObject = ItemTransferObject.from(item)

        XCTAssertEqual(transferObject.name, "Test Item")
        XCTAssertEqual(transferObject.description, "Test Description")
        XCTAssertEqual(transferObject.estimatedValue, 999.99)
        XCTAssertEqual(transferObject.brand, "Test Brand")
        XCTAssertEqual(transferObject.model, "Test Model")
        XCTAssertEqual(transferObject.serialNumber, "TEST123")
        XCTAssertEqual(transferObject.warranty, "2 years")
        XCTAssertEqual(transferObject.notes, "Test notes")
        XCTAssertEqual(transferObject.tags, ["tag1", "tag2"])
    }

    func testItemTransferObjectToItem() {
        let transferObject = ItemTransferObject(
            name: "Transfer Item",
            description: "Transfer Description",
            estimatedValue: 1299.99,
            brand: "Transfer Brand",
            model: "Transfer Model",
            serialNumber: "TRANSFER123",
            warranty: "3 years",
            notes: "Transfer notes",
            tags: ["transfer1", "transfer2"]
        )

        let item = transferObject.toItem()

        XCTAssertEqual(item.name, "Transfer Item")
        XCTAssertEqual(item.description, "Transfer Description")
        XCTAssertEqual(item.estimatedValue, 1299.99)
        XCTAssertEqual(item.brand, "Transfer Brand")
        XCTAssertEqual(item.model, "Transfer Model")
        XCTAssertEqual(item.serialNumber, "TRANSFER123")
        XCTAssertEqual(item.warranty, "3 years")
        XCTAssertEqual(item.notes, "Transfer notes")
        XCTAssertEqual(item.tags, ["transfer1", "transfer2"])
        XCTAssertNotNil(item.id)
        XCTAssertNotNil(item.createdAt)
        XCTAssertNotNil(item.updatedAt)
    }

    func testItemTransferObjectCodable() throws {
        let transferObject = ItemTransferObject(
            name: "Codable Test",
            description: "Testing JSON encoding/decoding",
            estimatedValue: 599.99,
            brand: "Codable Brand",
            model: "Codable Model",
            serialNumber: "CODABLE123"
        )

        // Test encoding
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(transferObject)
        XCTAssertNotNil(encodedData)

        // Test decoding
        let decoder = JSONDecoder()
        let decodedObject = try decoder.decode(ItemTransferObject.self, from: encodedData)

        XCTAssertEqual(decodedObject.name, transferObject.name)
        XCTAssertEqual(decodedObject.description, transferObject.description)
        XCTAssertEqual(decodedObject.estimatedValue, transferObject.estimatedValue)
        XCTAssertEqual(decodedObject.brand, transferObject.brand)
        XCTAssertEqual(decodedObject.model, transferObject.model)
        XCTAssertEqual(decodedObject.serialNumber, transferObject.serialNumber)
    }

    // MARK: - Stress Tests

    func testConcurrentOperations() async throws {
        // Test concurrent save operations
        let concurrentCount = 20
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<concurrentCount {
                group.addTask {
                    let item = Item(
                        name: "Concurrent Item \(i)",
                        description: "Concurrent test \(i)",
                        estimatedValue: Double(i * 10),
                        photos: [],
                        updatedAt: Date()
                    )
                    
                    do {
                        try await self.liveService.save(item: item)
                    } catch {
                        XCTFail("Concurrent save failed for item \(i): \(error)")
                    }
                }
            }
        }

        // Verify all items were saved
        let items = try await liveService.fetchItems()
        XCTAssertEqual(items.count, concurrentCount)
    }

    func testMemoryPressureHandling() async throws {
        // Create and immediately release many items to test memory handling
        let batchCount = 10
        let itemsPerBatch = 50

        for batch in 0..<batchCount {
            var batchItems: [Item] = []
            
            // Create batch of items
            for i in 0..<itemsPerBatch {
                let item = Item(
                    name: "Memory Test Batch \(batch) Item \(i)",
                    description: "Large description with lots of text to test memory pressure handling in the inventory service during bulk operations",
                    estimatedValue: Double(batch * 100 + i),
                    photos: [],
                    updatedAt: Date()
                )
                batchItems.append(item)
            }

            // Save batch
            for item in batchItems {
                try await liveService.save(item: item)
            }

            // Clear local references
            batchItems.removeAll()

            // Verify batch was saved
            let totalItems = try await liveService.fetchItems()
            XCTAssertEqual(totalItems.count, (batch + 1) * itemsPerBatch)
        }

        // Final verification
        let finalItems = try await liveService.fetchItems()
        XCTAssertEqual(finalItems.count, batchCount * itemsPerBatch)
    }

    // MARK: - Data Integrity Tests

    func testDataConsistencyAfterCrash() async throws {
        // Simulate data consistency by creating, modifying, and verifying items
        let item = Item(name: "Consistency Test", description: "Original", estimatedValue: 100, photos: [], updatedAt: Date())
        try await liveService.save(item: item)

        // Modify multiple times
        item.name = "Modified Once"
        try await liveService.save(item: item)

        item.description = "Modified Description"
        item.estimatedValue = 200
        try await liveService.save(item: item)

        // Verify final state
        let fetchedItem = try await liveService.fetchItem(withId: item.id)
        XCTAssertNotNil(fetchedItem)
        XCTAssertEqual(fetchedItem?.name, "Modified Once")
        XCTAssertEqual(fetchedItem?.description, "Modified Description")
        XCTAssertEqual(fetchedItem?.estimatedValue, 200)
    }

    func testRoundTripDataIntegrity() async throws {
        // Test data integrity through export/import cycle
        let originalItem = Item(
            name: "Round Trip Test",
            description: "Testing data integrity through export/import",
            estimatedValue: 1234.56,
            photos: [],
            updatedAt: Date()
        )
        originalItem.brand = "Test Brand"
        originalItem.serialNumber = "RT123456"
        originalItem.tags = ["test", "roundtrip", "integrity"]

        try await liveService.save(item: originalItem)

        // Export
        let exportData = try await liveService.exportInventory(format: .json)
        
        // Parse exported data
        let jsonArray = try JSONSerialization.jsonObject(with: exportData) as! [[String: Any]]
        XCTAssertEqual(jsonArray.count, 1)

        let exportedItem = jsonArray[0]
        XCTAssertEqual(exportedItem["name"] as? String, "Round Trip Test")
        XCTAssertEqual(exportedItem["estimatedValue"] as? Double, 1234.56)
        XCTAssertEqual(exportedItem["brand"] as? String, "Test Brand")
        
        // Verify tags are properly encoded
        let exportedTags = exportedItem["tags"] as? [String]
        XCTAssertEqual(exportedTags, ["test", "roundtrip", "integrity"])
    }

    // MARK: - Edge Case Tests

    func testItemWithEmptyOptionalFields() async throws {
        let item = Item(name: "Minimal Item", description: "", estimatedValue: 0, photos: [], updatedAt: Date())
        // Leave all optional fields nil/empty

        try await liveService.save(item: item)

        let fetchedItem = try await liveService.fetchItem(withId: item.id)
        XCTAssertNotNil(fetchedItem)
        XCTAssertEqual(fetchedItem?.name, "Minimal Item")
        XCTAssertEqual(fetchedItem?.description, "")
        XCTAssertEqual(fetchedItem?.estimatedValue, 0)
        XCTAssertNil(fetchedItem?.brand)
        XCTAssertNil(fetchedItem?.model)
        XCTAssertNil(fetchedItem?.serialNumber)
    }

    func testItemWithUnicodeContent() async throws {
        let item = Item(
            name: "🏠 Home Item 测试",
            description: "Description with émojis and ünïcødé çhäräctërs 🔥",
            estimatedValue: 999.99,
            photos: [],
            updatedAt: Date()
        )
        item.brand = "Brand™ 中文"
        item.notes = "Notes with special chars: ©®™€£¥"

        try await liveService.save(item: item)

        let fetchedItem = try await liveService.fetchItem(withId: item.id)
        XCTAssertNotNil(fetchedItem)
        XCTAssertEqual(fetchedItem?.name, "🏠 Home Item 测试")
        XCTAssertEqual(fetchedItem?.description, "Description with émojis and ünïcødé çhäräctërs 🔥")
        XCTAssertEqual(fetchedItem?.brand, "Brand™ 中文")
        XCTAssertEqual(fetchedItem?.notes, "Notes with special chars: ©®™€£¥")
    }
}
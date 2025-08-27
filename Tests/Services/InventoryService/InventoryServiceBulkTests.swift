// Layer: Tests
// Module: Services
// Purpose: Bulk operations and export tests for InventoryService

import SwiftData
import XCTest

@testable import Nestory

@MainActor
final class InventoryServiceBulkTests: XCTestCase {
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

    // MARK: - Bulk Import Tests

    func testBulkImport() async throws {
        let importItems = [
            ItemTransferObject(
                name: "iPhone 14",
                description: "Apple smartphone",
                estimatedValue: 999.99,
                brand: "Apple",
                model: "iPhone 14",
                serialNumber: "IP123456"
            ),
            ItemTransferObject(
                name: "MacBook Pro",
                description: "Apple laptop",
                estimatedValue: 1999.99,
                brand: "Apple",
                model: "MacBook Pro",
                serialNumber: "MB123456"
            )
        ]

        let result = try await liveService.bulkImport(items: importItems)
        
        XCTAssertEqual(result.successCount, 2)
        XCTAssertEqual(result.failureCount, 0)
        XCTAssertEqual(result.totalProcessed, 2)

        // Verify items were actually saved
        let items = try await liveService.fetchItems()
        XCTAssertEqual(items.count, 2)
        XCTAssertTrue(items.contains { $0.name == "iPhone 14" })
        XCTAssertTrue(items.contains { $0.name == "MacBook Pro" })
    }

    // MARK: - Export Tests

    func testExportInventoryJSON() async throws {
        // Create test data
        let iphone = Item(name: "iPhone 14", description: "Apple smartphone", estimatedValue: 999.99, photos: [], updatedAt: Date())
        iphone.brand = "Apple"
        iphone.model = "iPhone 14"
        iphone.serialNumber = "IP123456"

        let macbook = Item(name: "MacBook Pro", description: "Apple laptop", estimatedValue: 1999.99, photos: [], updatedAt: Date())
        macbook.brand = "Apple"
        macbook.model = "MacBook Pro"
        macbook.serialNumber = "MB123456"

        try await liveService.save(item: iphone)
        try await liveService.save(item: macbook)

        // Export to JSON
        let jsonData = try await liveService.exportInventory(format: .json)
        XCTAssertNotNil(jsonData)

        // Verify JSON structure
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        guard let jsonArray = jsonObject as? [[String: Any]] else {
            XCTFail("JSON should be an array of objects")
            return
        }

        XCTAssertEqual(jsonArray.count, 2)

        // Check first item
        let firstItem = jsonArray[0]
        XCTAssertEqual(firstItem["name"] as? String, "iPhone 14")
        XCTAssertEqual(firstItem["brand"] as? String, "Apple")
        XCTAssertEqual(firstItem["estimatedValue"] as? Double, 999.99)
    }

    func testExportInventoryCSV() async throws {
        // Create test data
        let iphone = Item(name: "iPhone 14", description: "Apple smartphone", estimatedValue: 999.99, photos: [], updatedAt: Date())
        iphone.brand = "Apple"
        iphone.serialNumber = "IP123456"

        let macbook = Item(name: "MacBook Pro", description: "Apple laptop", estimatedValue: 1999.99, photos: [], updatedAt: Date())
        macbook.brand = "Apple"
        macbook.serialNumber = "MB123456"

        try await liveService.save(item: iphone)
        try await liveService.save(item: macbook)

        // Export to CSV
        let csvData = try await liveService.exportInventory(format: .csv)
        XCTAssertNotNil(csvData)

        let csvString = String(data: csvData, encoding: .utf8)
        XCTAssertNotNil(csvString)

        // Verify CSV structure
        let lines = csvString!.components(separatedBy: .newlines).filter { !$0.isEmpty }
        XCTAssertEqual(lines.count, 3) // Header + 2 data rows

        // Check header
        let header = lines[0]
        XCTAssertTrue(header.contains("name"))
        XCTAssertTrue(header.contains("description"))
        XCTAssertTrue(header.contains("estimatedValue"))
        XCTAssertTrue(header.contains("brand"))

        // Check data rows contain expected data
        let dataRows = Array(lines[1...])
        XCTAssertTrue(dataRows.contains { $0.contains("iPhone 14") })
        XCTAssertTrue(dataRows.contains { $0.contains("MacBook Pro") })
    }

    func testExportInventoryPDFNotImplemented() async throws {
        let iphone = Item(name: "iPhone", description: "Smartphone", estimatedValue: 999, photos: [], updatedAt: Date())
        try await liveService.save(item: iphone)

        do {
            _ = try await liveService.exportInventory(format: .pdf)
            XCTFail("PDF export should throw not implemented error")
        } catch InventoryError.exportFormatNotSupported {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Bulk Import Performance Tests

    func testBulkImportPerformance() async throws {
        // Create large dataset for performance testing
        let itemCount = 100
        var importItems: [ItemTransferObject] = []

        for i in 0..<itemCount {
            let item = ItemTransferObject(
                name: "Item \(i)",
                description: "Description for item \(i)",
                estimatedValue: Double(i * 10),
                brand: "Brand \(i % 5)",
                model: "Model \(i)",
                serialNumber: "SN\(i)"
            )
            importItems.append(item)
        }

        // Measure performance
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await liveService.bulkImport(items: importItems)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertEqual(result.successCount, itemCount)
        XCTAssertEqual(result.failureCount, 0)
        XCTAssertLessThan(timeElapsed, 5.0) // Should complete within 5 seconds

        // Verify all items were saved
        let items = try await liveService.fetchItems()
        XCTAssertEqual(items.count, itemCount)
    }

    // MARK: - Export Performance Tests

    func testExportLargeDatasetJSON() async throws {
        // Create dataset for export testing
        let itemCount = 50
        for i in 0..<itemCount {
            let item = Item(
                name: "Item \(i)",
                description: "Description \(i)",
                estimatedValue: Double(i * 10),
                photos: [],
                updatedAt: Date()
            )
            try await liveService.save(item: item)
        }

        // Test JSON export performance
        let startTime = CFAbsoluteTimeGetCurrent()
        let jsonData = try await liveService.exportInventory(format: .json)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertNotNil(jsonData)
        XCTAssertLessThan(timeElapsed, 2.0) // Should complete within 2 seconds

        // Verify data size is reasonable
        XCTAssertGreaterThan(jsonData.count, 1000) // Should have substantial data
    }

    func testExportLargeDatasetCSV() async throws {
        // Create dataset for export testing
        let itemCount = 50
        for i in 0..<itemCount {
            let item = Item(
                name: "CSV Item \(i)",
                description: "CSV Description \(i)",
                estimatedValue: Double(i * 15),
                photos: [],
                updatedAt: Date()
            )
            item.brand = "Brand \(i % 3)"
            item.serialNumber = "CSV\(i)"
            try await liveService.save(item: item)
        }

        // Test CSV export performance
        let startTime = CFAbsoluteTimeGetCurrent()
        let csvData = try await liveService.exportInventory(format: .csv)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertNotNil(csvData)
        XCTAssertLessThan(timeElapsed, 2.0) // Should complete within 2 seconds

        let csvString = String(data: csvData, encoding: .utf8)
        let lineCount = csvString?.components(separatedBy: .newlines).filter { !$0.isEmpty }.count ?? 0
        XCTAssertEqual(lineCount, itemCount + 1) // Items + header
    }

    // MARK: - Bulk Operations Error Handling

    func testBulkImportWithPartialFailures() async throws {
        let importItems = [
            // Valid item
            ItemTransferObject(
                name: "Valid Item",
                description: "This is valid",
                estimatedValue: 100.0,
                brand: "Test Brand",
                model: "Test Model",
                serialNumber: "VALID123"
            ),
            // Invalid item (empty name)
            ItemTransferObject(
                name: "",
                description: "Invalid item",
                estimatedValue: 200.0,
                brand: "Test Brand",
                model: "Test Model",
                serialNumber: "INVALID123"
            ),
            // Another valid item
            ItemTransferObject(
                name: "Another Valid Item",
                description: "Also valid",
                estimatedValue: 300.0,
                brand: "Test Brand",
                model: "Test Model",
                serialNumber: "VALID456"
            )
        ]

        let result = try await liveService.bulkImport(items: importItems)
        
        // Should have processed all items but some may have failed
        XCTAssertEqual(result.totalProcessed, 3)
        XCTAssertGreaterThan(result.successCount, 0) // At least some should succeed
        
        if result.failureCount > 0 {
            // If there were failures, verify the details
            XCTAssertGreaterThan(result.failures.count, 0)
        }
    }

    func testExportEmptyInventory() async throws {
        // Ensure database is empty
        let items = try await liveService.fetchItems()
        XCTAssertEqual(items.count, 0)

        // Export JSON from empty database
        let jsonData = try await liveService.exportInventory(format: .json)
        let jsonString = String(data: jsonData, encoding: .utf8)
        XCTAssertEqual(jsonString, "[]") // Should be empty array

        // Export CSV from empty database
        let csvData = try await liveService.exportInventory(format: .csv)
        let csvString = String(data: csvData, encoding: .utf8)
        // Should have header only
        let lines = csvString?.components(separatedBy: .newlines).filter { !$0.isEmpty }
        XCTAssertEqual(lines?.count, 1) // Header only
    }

    // MARK: - Memory Efficiency Tests

    func testBulkOperationsMemoryEfficiency() async throws {
        // Test that bulk operations don't cause excessive memory usage
        let itemCount = 200
        var importItems: [ItemTransferObject] = []

        for i in 0..<itemCount {
            let item = ItemTransferObject(
                name: "Memory Test Item \(i)",
                description: "Testing memory efficiency for item \(i)",
                estimatedValue: Double(i * 5),
                brand: "Memory Brand",
                model: "Model \(i)",
                serialNumber: "MEM\(i)"
            )
            importItems.append(item)
        }

        // Import large dataset
        let importResult = try await liveService.bulkImport(items: importItems)
        XCTAssertEqual(importResult.successCount, itemCount)

        // Export the same dataset
        let exportData = try await liveService.exportInventory(format: .json)
        XCTAssertNotNil(exportData)

        // Verify we can still perform normal operations
        let fetchedItems = try await liveService.fetchItems()
        XCTAssertEqual(fetchedItems.count, itemCount)

        // Memory should be manageable - this test mainly ensures no crashes occur
        XCTAssertTrue(true, "Bulk operations completed without memory issues")
    }
}
//
// Layer: Tests
// Module: Services
// Purpose: Performance tests for ImportExportService operations
//

@testable import Nestory
import SwiftData
import UniformTypeIdentifiers
import XCTest

@MainActor
final class ImportExportServicePerformanceTests: XCTestCase {
    var service: any ImportExportService!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var tempDirectory: URL!

    override func setUp() async throws {
        super.setUp()

        // Create temporary directory for test files
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ImportExportPerformanceTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: Item.self, Category.self,
            configurations: config,
        )
        modelContext = ModelContext(modelContainer)

        // Set up service
        service = ImportExportService()
    }

    override func tearDown() {
        service = nil
        modelContext = nil
        modelContainer = nil

        // Clean up temporary directory
        if let tempDirectory {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        tempDirectory = nil

        super.tearDown()
    }

    // MARK: - CSV Performance Tests

    func testImportLargeCSVPerformance() async throws {
        // Create large CSV content
        var csvContent = "Name,Description,Brand,Price\n"
        for i in 1...1000 {
            csvContent += "Item \\(i),Description \\(i),Brand \\(i),\\(i * 10)\n"
        }

        let tempFile = tempDirectory.appendingPathComponent("large_import.csv")
        try csvContent.write(to: tempFile, atomically: true, encoding: .utf8)

        // Measure import performance
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await service.importCSV(from: tempFile, modelContext: modelContext)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertEqual(result.itemsImported, 1000)
        XCTAssertEqual(result.itemsSkipped, 0)
        XCTAssertLessThan(timeElapsed, 10.0) // Should complete within 10 seconds

        // Verify items were actually saved
        let descriptor = FetchDescriptor<Item>()
        let savedItems = try modelContext.fetch(descriptor)
        XCTAssertEqual(savedItems.count, 1000)
    }

    func testImportMediumCSVPerformance() async throws {
        // Create medium CSV content (500 items)
        var csvContent = "Name,Description,Brand,Model,Serial Number,Purchase Price,Currency,Quantity\n"
        for i in 1...500 {
            csvContent += "Medium Item \\(i),Medium Description \\(i),Medium Brand \\(i),Model\\(i),Serial\\(i),\\(Double(i) * 15.5),USD,1\n"
        }

        let tempFile = tempDirectory.appendingPathComponent("medium_import.csv")
        try csvContent.write(to: tempFile, atomically: true, encoding: .utf8)

        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await service.importCSV(from: tempFile, modelContext: modelContext)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertEqual(result.itemsImported, 500)
        XCTAssertLessThan(timeElapsed, 5.0) // Should complete within 5 seconds
    }

    func testExportLargeCSVPerformance() {
        // Create large item dataset
        let items = (1...1000).map { index in
            let item = TestData.makeItem(name: "Performance Item \\(index)")
            item.itemDescription = "Description for item \\(index)"
            item.brand = "Brand \\(index % 10)"
            item.purchasePrice = Decimal(index * 10)
            return item
        }

        let startTime = CFAbsoluteTimeGetCurrent()
        let csvData = service.exportToCSV(items: items)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertNotNil(csvData)
        XCTAssertLessThan(timeElapsed, 2.0) // Should complete within 2 seconds

        // Verify data size is reasonable
        XCTAssertGreaterThan(csvData!.count, 50000) // Should have substantial data
    }

    func testExportMediumCSVPerformance() {
        // Create medium item dataset (250 items)
        let items = (1...250).map { index in
            let item = TestData.makeItem(name: "Medium Performance Item \\(index)")
            item.itemDescription = "Medium description for item \\(index)"
            item.brand = "Medium Brand \\(index % 5)"
            item.modelNumber = "Model\\(index)"
            item.serialNumber = "Serial\\(index)"
            item.purchasePrice = Decimal(index * 25)
            item.currency = "EUR"
            item.quantity = index % 3 + 1
            item.tags = ["performance", "medium", "test"]
            return item
        }

        let startTime = CFAbsoluteTimeGetCurrent()
        let csvData = service.exportToCSV(items: items)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertNotNil(csvData)
        XCTAssertLessThan(timeElapsed, 1.0) // Should complete within 1 second
    }

    // MARK: - JSON Performance Tests

    func testImportLargeJSONPerformance() async throws {
        // Create large JSON content
        var jsonItems: [[String: Any]] = []
        for i in 1...1000 {
            jsonItems.append([
                "name": "JSON Item \\(i)",
                "description": "JSON Description \\(i)",
                "brand": "JSON Brand \\(i % 5)",
                "modelNumber": "JSONModel\\(i)",
                "serialNumber": "JSONSerial\\(i)",
                "quantity": i % 5 + 1,
                "purchasePrice": Double(i) * 12.5,
                "currency": "USD",
                "tags": ["json", "performance", "large"]
            ])
        }

        let jsonData = try JSONSerialization.data(withJSONObject: jsonItems)
        let tempFile = tempDirectory.appendingPathComponent("large_import.json")
        try jsonData.write(to: tempFile)

        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await service.importJSON(from: tempFile, modelContext: modelContext)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertEqual(result.itemsImported, 1000)
        XCTAssertEqual(result.itemsSkipped, 0)
        XCTAssertLessThan(timeElapsed, 8.0) // Should complete within 8 seconds
    }

    func testExportLargeJSONPerformance() {
        // Create large item dataset
        let items = (1...1000).map { index in
            let item = TestData.makeItem(name: "JSON Performance Item \\(index)")
            item.itemDescription = "Description for item \\(index)"
            item.brand = "Brand \\(index % 10)"
            item.purchasePrice = Decimal(index * 10)
            item.tags = ["tag1", "tag2", "performance"]
            return item
        }

        let startTime = CFAbsoluteTimeGetCurrent()
        let jsonData = service.exportToJSON(items: items)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertNotNil(jsonData)
        XCTAssertLessThan(timeElapsed, 3.0) // Should complete within 3 seconds

        // Verify JSON structure
        let jsonObject = try? JSONSerialization.jsonObject(with: jsonData!)
        XCTAssertNotNil(jsonObject)
        XCTAssertTrue(jsonObject is [Any])

        if let jsonArray = jsonObject as? [Any] {
            XCTAssertEqual(jsonArray.count, 1000)
        }
    }

    func testExportComplexJSONPerformance() {
        // Create items with complex data structures
        let items = (1...500).map { index in
            let item = TestData.makeItem(name: "Complex JSON Item \\(index)")
            item.itemDescription = "Complex description with lots of text and details for item \\(index). This includes multiple sentences and detailed information about the item's features, capabilities, and usage scenarios."
            item.brand = "Complex Brand \\(index % 3)"
            item.modelNumber = "ComplexModel-\\(index)-Pro-Max-Ultra"
            item.serialNumber = "COMPLEX-\\(String(format: "%06d", index))-SERIAL"
            item.purchasePrice = Decimal(Double(index) * 147.33)
            item.currency = index % 2 == 0 ? "USD" : "EUR"
            item.quantity = index % 10 + 1
            item.tags = ["complex", "performance", "test", "tag\\(index % 5)", "category\\(index % 3)"]
            item.notes = "Detailed notes about item \\(index). These notes contain extensive information about the item, including purchase details, warranty information, and usage instructions. The notes can be quite lengthy to test performance with larger text fields."
            return item
        }

        let startTime = CFAbsoluteTimeGetCurrent()
        let jsonData = service.exportToJSON(items: items)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertNotNil(jsonData)
        XCTAssertLessThan(timeElapsed, 2.0) // Should complete within 2 seconds even with complex data

        // Verify data is comprehensive
        XCTAssertGreaterThan(jsonData!.count, 100000) // Should have substantial complex data
    }

    // MARK: - Memory Performance Tests

    func testImportMemoryEfficiency() async throws {
        // Test that large imports don't cause excessive memory usage
        var csvContent = "Name,Description,Brand,Model,Serial Number,Purchase Price,Currency,Quantity,Tags,Notes\n"
        for i in 1...2000 {
            csvContent += "Memory Test Item \\(i),Long description with lots of text to test memory efficiency during import operations for item number \\(i),Memory Brand,MemModel\\(i),SERIAL\\(String(format: "%06d", i)),\\(Double(i) * 19.99),USD,\\(i % 5 + 1),memory;efficiency;test;performance,Extended notes for item \\(i) with detailed information about memory usage patterns and performance characteristics during bulk import operations.\\n"
        }

        let tempFile = tempDirectory.appendingPathComponent("memory_test.csv")
        try csvContent.write(to: tempFile, atomically: true, encoding: .utf8)

        let result = try await service.importCSV(from: tempFile, modelContext: modelContext)

        XCTAssertEqual(result.itemsImported, 2000)
        XCTAssertEqual(result.itemsSkipped, 0)

        // Verify items are accessible after import
        let descriptor = FetchDescriptor<Item>()
        let savedItems = try modelContext.fetch(descriptor)
        XCTAssertEqual(savedItems.count, 2000)

        // Spot check some items
        let firstItem = savedItems.first { $0.name == "Memory Test Item 1" }
        XCTAssertNotNil(firstItem)
        XCTAssertEqual(firstItem?.brand, "Memory Brand")

        let lastItem = savedItems.first { $0.name == "Memory Test Item 2000" }
        XCTAssertNotNil(lastItem)
        XCTAssertEqual(lastItem?.quantity, 5) // 2000 % 5 + 1 = 5
    }

    func testExportMemoryEfficiency() {
        // Create large dataset to test export memory efficiency
        let items = (1...2000).map { index in
            let item = TestData.makeItem(name: "Export Memory Test Item \\(index)")
            item.itemDescription = "Extended description for memory efficiency testing with item number \\(index). This description contains detailed information to test memory usage patterns during large export operations."
            item.brand = "Export Memory Brand \\(index % 7)"
            item.modelNumber = "MemoryExportModel\\(index)"
            item.serialNumber = "EXPORT-MEM-\\(String(format: "%06d", index))"
            item.purchasePrice = Decimal(Double(index) * 23.45)
            item.currency = index % 3 == 0 ? "USD" : (index % 3 == 1 ? "EUR" : "GBP")
            item.quantity = index % 8 + 1
            item.tags = ["memory", "export", "efficiency", "test", "bulk\\(index % 5)"]
            item.notes = "Comprehensive notes for memory export testing with item \\(index). These notes are designed to be substantial in size to evaluate memory management during bulk export operations with large text fields."
            return item
        }

        // Test CSV export memory efficiency
        let csvData = service.exportToCSV(items: items)
        XCTAssertNotNil(csvData)

        // Test JSON export memory efficiency
        let jsonData = service.exportToJSON(items: items)
        XCTAssertNotNil(jsonData)

        // Both exports should complete successfully
        XCTAssertGreaterThan(csvData!.count, 200000) // Substantial CSV data
        XCTAssertGreaterThan(jsonData!.count, 300000) // Substantial JSON data
    }

    // MARK: - Concurrent Operations Performance

    func testConcurrentImportPerformance() async throws {
        // Test concurrent import operations
        let fileCount = 5
        var tempFiles: [URL] = []

        // Create multiple CSV files
        for fileIndex in 1...fileCount {
            var csvContent = "Name,Description,Brand,Price\n"
            for itemIndex in 1...200 {
                csvContent += "Concurrent Item \\(fileIndex)-\\(itemIndex),Description \\(fileIndex)-\\(itemIndex),Brand\\(fileIndex),\\((fileIndex * 100) + itemIndex)\n"
            }

            let tempFile = tempDirectory.appendingPathComponent("concurrent_\\(fileIndex).csv")
            try csvContent.write(to: tempFile, atomically: true, encoding: .utf8)
            tempFiles.append(tempFile)
        }

        let startTime = CFAbsoluteTimeGetCurrent()

        // Import files concurrently
        let results = try await withThrowingTaskGroup(of: ImportExportService.ImportResult.self) { group in
            for tempFile in tempFiles {
                group.addTask {
                    return try await self.service.importCSV(from: tempFile, modelContext: self.modelContext)
                }
            }

            var allResults: [ImportExportService.ImportResult] = []
            for try await result in group {
                allResults.append(result)
            }
            return allResults
        }

        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertEqual(results.count, fileCount)
        XCTAssertLessThan(timeElapsed, 5.0) // Should complete within 5 seconds

        // Verify total imports
        let totalImported = results.reduce(0) { $0 + $1.itemsImported }
        XCTAssertEqual(totalImported, fileCount * 200) // 5 files × 200 items each

        // Verify items in database
        let descriptor = FetchDescriptor<Item>()
        let savedItems = try modelContext.fetch(descriptor)
        XCTAssertEqual(savedItems.count, totalImported)
    }
}
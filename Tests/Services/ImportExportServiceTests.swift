//
// Layer: Tests
// Module: Services
// Purpose: Comprehensive tests for ImportExportService with CSV/JSON processing
//

@testable import Nestory
import SwiftData
import UniformTypeIdentifiers
import XCTest

@MainActor
final class ImportExportServiceTests: XCTestCase {
    var service: ImportExportService!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var tempDirectory: URL!

    override func setUp() async throws {
        super.setUp()

        // Create temporary directory for test files
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ImportExportTests-\(UUID().uuidString)")
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

    // MARK: - CSV Import Tests

    func testImportCSVWithValidData() async throws {
        let csvContent = """
        Name,Description,Brand,Model,Serial Number,Purchase Date,Purchase Price,Currency,Quantity,Location,Tags,Notes
        iPhone 15 Pro,Latest iPhone model,Apple,iPhone 15 Pro,ABC123XYZ,2023-10-15,999.99,USD,1,Home Office,electronics;smartphone,Great phone
        MacBook Pro,Professional laptop,Apple,MacBook Pro M3,DEF456GHI,2023-08-20,2499.00,USD,1,Home Office,electronics;laptop,Work computer
        """

        let csvFile = tempDirectory.appendingPathComponent("test_import.csv")
        try csvContent.write(to: csvFile, atomically: true, encoding: .utf8)

        let result = try await service.importCSV(from: csvFile, modelContext: modelContext)

        XCTAssertEqual(result.itemsImported, 2)
        XCTAssertEqual(result.itemsSkipped, 0)
        XCTAssertTrue(result.errors.isEmpty)

        // Verify items were actually saved
        let descriptor = FetchDescriptor<Item>()
        let savedItems = try modelContext.fetch(descriptor)

        XCTAssertEqual(savedItems.count, 2)

        let iphone = savedItems.first { $0.name == "iPhone 15 Pro" }
        XCTAssertNotNil(iphone)
        XCTAssertEqual(iphone?.brand, "Apple")
        XCTAssertEqual(iphone?.modelNumber, "iPhone 15 Pro")
        XCTAssertEqual(iphone?.serialNumber, "ABC123XYZ")
        XCTAssertEqual(iphone?.purchasePrice, 999.99)
        XCTAssertEqual(iphone?.currency, "USD")
        XCTAssertEqual(iphone?.quantity, 1)
        XCTAssertEqual(iphone?.tags, ["electronics", "smartphone"])
        XCTAssertTrue(iphone?.notes?.contains("Great phone") == true)
        XCTAssertTrue(iphone?.notes?.contains("Location: Home Office") == true)
    }

    func testImportCSVWithMissingName() async throws {
        let csvContent = """
        Name,Description,Brand
        ,Test Description,Test Brand
        Valid Item,Another Description,Another Brand
        """

        let csvFile = tempDirectory.appendingPathComponent("test_missing_name.csv")
        try csvContent.write(to: csvFile, atomically: true, encoding: .utf8)

        let result = try await service.importCSV(from: csvFile, modelContext: modelContext)

        XCTAssertEqual(result.itemsImported, 1) // Only the valid item
        XCTAssertEqual(result.itemsSkipped, 1) // The item without name
        XCTAssertEqual(result.errors.count, 1)
        XCTAssertTrue(result.errors.first?.contains("Row 2") == true)
    }

    func testImportCSVWithColumnCountMismatch() async throws {
        let csvContent = """
        Name,Description,Brand
        iPhone,Good phone,Apple
        MacBook,Great laptop,Apple,Extra Column,Too Many
        """

        let csvFile = tempDirectory.appendingPathComponent("test_column_mismatch.csv")
        try csvContent.write(to: csvFile, atomically: true, encoding: .utf8)

        let result = try await service.importCSV(from: csvFile, modelContext: modelContext)

        XCTAssertEqual(result.itemsImported, 1) // Only the valid row
        XCTAssertEqual(result.itemsSkipped, 1) // The mismatched row
        XCTAssertEqual(result.errors.count, 1)
        XCTAssertTrue(result.errors.first?.contains("Column count mismatch") == true)
    }

    func testImportCSVWithQuotedFields() async throws {
        let csvContent = """
        Name,Description,Notes
        "iPhone 15","Latest iPhone model","Great phone, very fast"
        "MacBook Pro","Professional laptop","Work computer, excellent performance"
        """

        let csvFile = tempDirectory.appendingPathComponent("test_quoted.csv")
        try csvContent.write(to: csvFile, atomically: true, encoding: .utf8)

        let result = try await service.importCSV(from: csvFile, modelContext: modelContext)

        XCTAssertEqual(result.itemsImported, 2)
        XCTAssertEqual(result.itemsSkipped, 0)

        let descriptor = FetchDescriptor<Item>()
        let savedItems = try modelContext.fetch(descriptor)

        let iphone = savedItems.first { $0.name == "iPhone 15" }
        XCTAssertNotNil(iphone)
        XCTAssertEqual(iphone?.itemDescription, "Latest iPhone model")
        XCTAssertEqual(iphone?.notes, "Great phone, very fast")
    }

    func testImportCSVWithDifferentDateFormats() async throws {
        let csvContent = """
        Name,Purchase_Date
        Item1,2023-10-15
        Item2,10/15/2023
        Item3,15/10/2023
        Item4,2023/10/15
        Item5,10-15-2023
        Item6,15-10-2023
        """

        let csvFile = tempDirectory.appendingPathComponent("test_dates.csv")
        try csvContent.write(to: csvFile, atomically: true, encoding: .utf8)

        let result = try await service.importCSV(from: csvFile, modelContext: modelContext)

        XCTAssertEqual(result.itemsImported, 6)
        XCTAssertEqual(result.itemsSkipped, 0)

        let descriptor = FetchDescriptor<Item>()
        let savedItems = try modelContext.fetch(descriptor)

        // All items should have valid purchase dates
        for item in savedItems {
            XCTAssertNotNil(item.purchaseDate)
        }
    }

    func testImportCSVWithAlternativeFieldNames() async throws {
        let csvContent = """
        Name,Qty,Price,Value,Serial,Model_Number
        Item1,2,100.50,,ABC123,Model123
        Item2,1,,200.75,DEF456,Model456
        """

        let csvFile = tempDirectory.appendingPathComponent("test_alternative_fields.csv")
        try csvContent.write(to: csvFile, atomically: true, encoding: .utf8)

        let result = try await service.importCSV(from: csvFile, modelContext: modelContext)

        XCTAssertEqual(result.itemsImported, 2)
        XCTAssertEqual(result.itemsSkipped, 0)

        let descriptor = FetchDescriptor<Item>()
        let savedItems = try modelContext.fetch(descriptor)

        let item1 = savedItems.first { $0.name == "Item1" }
        XCTAssertNotNil(item1)
        XCTAssertEqual(item1?.quantity, 2)
        XCTAssertEqual(item1?.purchasePrice, 100.50)
        XCTAssertEqual(item1?.serialNumber, "ABC123")
        XCTAssertEqual(item1?.modelNumber, "Model123")

        let item2 = savedItems.first { $0.name == "Item2" }
        XCTAssertNotNil(item2)
        XCTAssertEqual(item2?.quantity, 1) // Default
        XCTAssertEqual(item2?.purchasePrice, 200.75)
    }

    func testImportCSVWithInvalidFile() async throws {
        let csvFile = tempDirectory.appendingPathComponent("nonexistent.csv")

        do {
            _ = try await service.importCSV(from: csvFile, modelContext: modelContext)
            XCTFail("Should have thrown an error for nonexistent file")
        } catch {
            XCTAssertTrue(error is CocoaError)
        }
    }

    func testImportCSVWithEmptyFile() async throws {
        let csvContent = ""
        let csvFile = tempDirectory.appendingPathComponent("empty.csv")
        try csvContent.write(to: csvFile, atomically: true, encoding: .utf8)

        do {
            _ = try await service.importCSV(from: csvFile, modelContext: modelContext)
            XCTFail("Should have thrown InvalidFormat error")
        } catch ImportExportService.ImportError.invalidFormat {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testImportCSVWithMissingRequiredFields() async throws {
        let csvContent = """
        Description,Brand
        Test Description,Test Brand
        """

        let csvFile = tempDirectory.appendingPathComponent("missing_required.csv")
        try csvContent.write(to: csvFile, atomically: true, encoding: .utf8)

        do {
            _ = try await service.importCSV(from: csvFile, modelContext: modelContext)
            XCTFail("Should have thrown MissingRequiredFields error")
        } catch ImportExportService.ImportError.missingRequiredFields {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - JSON Import Tests

    func testImportJSONWithArrayOfItems() async throws {
        let jsonContent = """
        [
            {
                "name": "iPhone 15 Pro",
                "description": "Latest iPhone model",
                "brand": "Apple",
                "modelNumber": "iPhone 15 Pro",
                "serialNumber": "ABC123XYZ",
                "quantity": 1,
                "purchasePrice": 999.99,
                "currency": "USD",
                "purchaseDate": "2023-10-15",
                "tags": ["electronics", "smartphone"],
                "notes": "Great phone"
            },
            {
                "name": "MacBook Pro",
                "description": "Professional laptop",
                "brand": "Apple",
                "modelNumber": "MacBook Pro M3",
                "serialNumber": "DEF456GHI",
                "quantity": 1,
                "purchasePrice": 2499.00,
                "currency": "USD",
                "purchaseDate": "2023-08-20T00:00:00Z",
                "tags": ["electronics", "laptop"],
                "notes": "Work computer"
            }
        ]
        """

        let jsonFile = tempDirectory.appendingPathComponent("test_import.json")
        try jsonContent.write(to: jsonFile, atomically: true, encoding: .utf8)

        let result = try await service.importJSON(from: jsonFile, modelContext: modelContext)

        XCTAssertEqual(result.itemsImported, 2)
        XCTAssertEqual(result.itemsSkipped, 0)
        XCTAssertTrue(result.errors.isEmpty)

        // Verify items were actually saved
        let descriptor = FetchDescriptor<Item>()
        let savedItems = try modelContext.fetch(descriptor)

        XCTAssertEqual(savedItems.count, 2)

        let iphone = savedItems.first { $0.name == "iPhone 15 Pro" }
        XCTAssertNotNil(iphone)
        XCTAssertEqual(iphone?.itemDescription, "Latest iPhone model")
        XCTAssertEqual(iphone?.brand, "Apple")
        XCTAssertEqual(iphone?.purchasePrice, 999.99)
        XCTAssertEqual(iphone?.tags, ["electronics", "smartphone"])
    }

    func testImportJSONWithSingleItem() async throws {
        let jsonContent = """
        {
            "name": "Single iPhone",
            "description": "Single item import test",
            "brand": "Apple",
            "quantity": 1,
            "purchasePrice": 999.99,
            "currency": "USD",
            "tags": ["test"],
            "notes": "Single import test"
        }
        """

        let jsonFile = tempDirectory.appendingPathComponent("single_item.json")
        try jsonContent.write(to: jsonFile, atomically: true, encoding: .utf8)

        let result = try await service.importJSON(from: jsonFile, modelContext: modelContext)

        XCTAssertEqual(result.itemsImported, 1)
        XCTAssertEqual(result.itemsSkipped, 0)

        let descriptor = FetchDescriptor<Item>()
        let savedItems = try modelContext.fetch(descriptor)

        XCTAssertEqual(savedItems.count, 1)
        XCTAssertEqual(savedItems.first?.name, "Single iPhone")
    }

    func testImportJSONWithInvalidFormat() async throws {
        let jsonContent = """
        {
            "invalid": "This is not an ImportableItem structure"
        }
        """

        let jsonFile = tempDirectory.appendingPathComponent("invalid.json")
        try jsonContent.write(to: jsonFile, atomically: true, encoding: .utf8)

        do {
            _ = try await service.importJSON(from: jsonFile, modelContext: modelContext)
            XCTFail("Should have thrown InvalidFormat error")
        } catch ImportExportService.ImportError.invalidFormat {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testImportJSONWithMalformedJSON() async throws {
        let jsonContent = """
        {
            "name": "Test Item",
            "invalid": json structure
        """

        let jsonFile = tempDirectory.appendingPathComponent("malformed.json")
        try jsonContent.write(to: jsonFile, atomically: true, encoding: .utf8)

        do {
            _ = try await service.importJSON(from: jsonFile, modelContext: modelContext)
            XCTFail("Should have thrown an error for malformed JSON")
        } catch {
            XCTAssertTrue(error is DecodingError || error is ImportExportService.ImportError)
        }
    }

    // MARK: - CSV Export Tests

    func testExportToCSV() {
        let items = [
            createTestItem(
                name: "iPhone 15 Pro",
                description: "Latest iPhone model",
                brand: "Apple",
                model: "iPhone 15 Pro",
                serial: "ABC123XYZ",
                price: 999.99,
                quantity: 1,
                tags: ["electronics", "smartphone"],
            ),
            createTestItem(
                name: "MacBook Pro",
                description: "Professional laptop",
                brand: "Apple",
                model: "MacBook Pro M3",
                serial: "DEF456GHI",
                price: 2499.00,
                quantity: 1,
                tags: ["electronics", "laptop"],
            ),
        ]

        let csvData = service.exportToCSV(items: items)

        XCTAssertNotNil(csvData)

        let csvString = String(data: csvData!, encoding: .utf8)
        XCTAssertNotNil(csvString)

        let lines = csvString!.components(separatedBy: .newlines)

        // Should have header + 2 data rows + empty line at end
        XCTAssertGreaterThanOrEqual(lines.count, 3)

        // Verify header
        let header = lines[0]
        XCTAssertTrue(header.contains("Name"))
        XCTAssertTrue(header.contains("Description"))
        XCTAssertTrue(header.contains("Brand"))
        XCTAssertTrue(header.contains("Purchase Price"))

        // Verify data rows
        let firstDataRow = lines[1]
        XCTAssertTrue(firstDataRow.contains("iPhone 15 Pro"))
        XCTAssertTrue(firstDataRow.contains("Apple"))
        XCTAssertTrue(firstDataRow.contains("999.99"))

        let secondDataRow = lines[2]
        XCTAssertTrue(secondDataRow.contains("MacBook Pro"))
        XCTAssertTrue(secondDataRow.contains("2499"))
    }

    func testExportToCSVWithSpecialCharacters() {
        let items = [
            createTestItem(
                name: "Item with \"quotes\"",
                description: "Description with, comma",
                notes: "Notes with\nnewlines",
            ),
        ]

        let csvData = service.exportToCSV(items: items)

        XCTAssertNotNil(csvData)

        let csvString = String(data: csvData!, encoding: .utf8)
        XCTAssertNotNil(csvString)

        // Should properly escape special characters
        XCTAssertTrue(csvString!.contains("\"Item with \"\"quotes\"\"\""))
        XCTAssertTrue(csvString!.contains("\"Description with, comma\""))
        XCTAssertTrue(csvString!.contains("\"Notes with\nnewlines\""))
    }

    func testExportToCSVWithEmptyItems() {
        let csvData = service.exportToCSV(items: [])

        XCTAssertNotNil(csvData)

        let csvString = String(data: csvData!, encoding: .utf8)
        XCTAssertNotNil(csvString)

        // Should still have header
        let lines = csvString!.components(separatedBy: .newlines)
        XCTAssertGreaterThanOrEqual(lines.count, 1)
        XCTAssertTrue(lines[0].contains("Name"))
    }

    // MARK: - JSON Export Tests

    func testExportToJSON() {
        let items = [
            createTestItem(
                name: "iPhone 15 Pro",
                description: "Latest iPhone model",
                brand: "Apple",
                model: "iPhone 15 Pro",
                serial: "ABC123XYZ",
                price: 999.99,
                currency: "USD",
                quantity: 1,
                tags: ["electronics", "smartphone"],
            ),
            createTestItem(
                name: "MacBook Pro",
                description: "Professional laptop",
                brand: "Apple",
                model: "MacBook Pro M3",
                serial: "DEF456GHI",
                price: 2499.00,
                currency: "USD",
                quantity: 1,
                tags: ["electronics", "laptop"],
            ),
        ]

        let jsonData = service.exportToJSON(items: items)

        XCTAssertNotNil(jsonData)

        // Verify JSON structure
        let jsonObject = try? JSONSerialization.jsonObject(with: jsonData!)
        XCTAssertNotNil(jsonObject)
        XCTAssertTrue(jsonObject is [Any])

        if let jsonArray = jsonObject as? [[String: Any]] {
            XCTAssertEqual(jsonArray.count, 2)

            let firstItem = jsonArray[0]
            XCTAssertEqual(firstItem["name"] as? String, "iPhone 15 Pro")
            XCTAssertEqual(firstItem["brand"] as? String, "Apple")
            XCTAssertEqual(firstItem["quantity"] as? Int, 1)
        }
    }

    func testExportToJSONWithEmptyItems() {
        let jsonData = service.exportToJSON(items: [])

        XCTAssertNotNil(jsonData)

        let jsonObject = try? JSONSerialization.jsonObject(with: jsonData!)
        XCTAssertNotNil(jsonObject)
        XCTAssertTrue(jsonObject is [Any])

        if let jsonArray = jsonObject as? [Any] {
            XCTAssertEqual(jsonArray.count, 0)
        }
    }

    // MARK: - Helper Methods

    private func createTestItem(
        name: String,
        description: String? = nil,
        brand: String? = nil,
        model: String? = nil,
        serial: String? = nil,
        price: Decimal? = nil,
        currency: String = "USD",
        quantity: Int = 1,
        tags: [String] = [],
        notes: String? = nil,
    ) -> Item {
        let item = Item(name: name)
        item.itemDescription = description
        item.brand = brand
        item.modelNumber = model
        item.serialNumber = serial
        item.purchasePrice = price
        item.currency = currency
        item.quantity = quantity
        item.tags = tags
        item.notes = notes

        if let price {
            item.purchaseDate = Date()
        }

        return item
    }
}

// MARK: - Import Result Tests

final class ImportResultTests: XCTestCase {
    func testImportResultSummary() {
        let result1 = ImportExportService.ImportResult(
            itemsImported: 5,
            itemsSkipped: 2,
            errors: ["Error 1", "Error 2"],
        )

        let summary1 = result1.summary
        XCTAssertTrue(summary1.contains("5 items imported"))
        XCTAssertTrue(summary1.contains("2 items skipped"))
        XCTAssertTrue(summary1.contains("2 errors"))

        let result2 = ImportExportService.ImportResult(
            itemsImported: 10,
            itemsSkipped: 0,
            errors: [],
        )

        let summary2 = result2.summary
        XCTAssertEqual(summary2, "10 items imported")

        let result3 = ImportExportService.ImportResult(
            itemsImported: 0,
            itemsSkipped: 3,
            errors: ["Error"],
        )

        let summary3 = result3.summary
        XCTAssertTrue(summary3.contains("3 items skipped"))
        XCTAssertTrue(summary3.contains("1 errors"))
    }
}

// MARK: - Import Error Tests

final class ImportErrorTests: XCTestCase {
    func testImportErrorDescriptions() {
        let errors: [ImportExportService.ImportError] = [
            .invalidFormat,
            .missingRequiredFields,
            .parsingError("Test parsing error"),
            .dataConversionError,
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }

        // Test specific error messages
        XCTAssertTrue(ImportExportService.ImportError.invalidFormat.errorDescription!.contains("Invalid file format"))
        XCTAssertTrue(ImportExportService.ImportError.missingRequiredFields.errorDescription!.contains("Missing required fields"))
        XCTAssertTrue(ImportExportService.ImportError.parsingError("Test").errorDescription!.contains("Test"))
        XCTAssertTrue(ImportExportService.ImportError.dataConversionError.errorDescription!.contains("Could not convert"))
    }
}

// MARK: - ImportableItem Tests

final class ImportableItemTests: XCTestCase {
    func testImportableItemFromItem() {
        let item = TestData.makeItem(name: "Test Item")
        item.itemDescription = "Test description"
        item.brand = "Test Brand"
        item.modelNumber = "Model123"
        item.serialNumber = "Serial456"
        item.quantity = 2
        item.purchasePrice = 199.99
        item.currency = "EUR"
        item.purchaseDate = Date()
        item.tags = ["test", "import"]
        item.notes = "Test notes"

        let importableItem = ImportableItem(from: item)

        XCTAssertEqual(importableItem.name, "Test Item")
        XCTAssertEqual(importableItem.description, "Test description")
        XCTAssertEqual(importableItem.brand, "Test Brand")
        XCTAssertEqual(importableItem.modelNumber, "Model123")
        XCTAssertEqual(importableItem.serialNumber, "Serial456")
        XCTAssertEqual(importableItem.quantity, 2)
        XCTAssertEqual(importableItem.purchasePrice, 199.99)
        XCTAssertEqual(importableItem.currency, "EUR")
        XCTAssertEqual(importableItem.tags, ["test", "import"])
        XCTAssertEqual(importableItem.notes, "Test notes")
    }

    func testImportableItemToItem() {
        let importableItem = ImportableItem(
            name: "Converted Item",
            description: "Converted description",
            brand: "Converted Brand",
            modelNumber: "ConvertedModel",
            serialNumber: "ConvertedSerial",
            quantity: 3,
            purchasePrice: 299.99,
            currency: "GBP",
            purchaseDate: Date(),
            tags: ["converted", "test"],
            notes: "Converted notes",
        )

        let item = importableItem.toItem()

        XCTAssertEqual(item.name, "Converted Item")
        XCTAssertEqual(item.itemDescription, "Converted description")
        XCTAssertEqual(item.brand, "Converted Brand")
        XCTAssertEqual(item.modelNumber, "ConvertedModel")
        XCTAssertEqual(item.serialNumber, "ConvertedSerial")
        XCTAssertEqual(item.quantity, 3)
        XCTAssertEqual(item.purchasePrice, 299.99)
        XCTAssertEqual(item.currency, "GBP")
        XCTAssertEqual(item.tags, ["converted", "test"])
        XCTAssertEqual(item.notes, "Converted notes")
    }

    func testImportableItemCodable() throws {
        let importableItem = ImportableItem(
            name: "Codable Test Item",
            description: "Test description",
            brand: nil,
            modelNumber: nil,
            serialNumber: nil,
            quantity: 1,
            purchasePrice: 100,
            currency: "USD",
            purchaseDate: Date(),
            tags: ["test"],
            notes: nil,
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(importableItem)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(ImportableItem.self, from: data)

        XCTAssertEqual(decoded.name, importableItem.name)
        XCTAssertEqual(decoded.description, importableItem.description)
        XCTAssertEqual(decoded.quantity, importableItem.quantity)
        XCTAssertEqual(decoded.purchasePrice, importableItem.purchasePrice)
        XCTAssertEqual(decoded.currency, importableItem.currency)
        XCTAssertEqual(decoded.tags, importableItem.tags)
    }
}

// MARK: - Performance Tests

@MainActor
final class ImportExportServicePerformanceTests: XCTestCase {
    func testImportLargeCSVPerformance() async throws {
        let service = ImportExportService()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        let context = ModelContext(container)

        // Create large CSV content
        var csvContent = "Name,Description,Brand,Price\n"
        for i in 1 ... 1000 {
            csvContent += "Item \\(i),Description \\(i),Brand \\(i),\\(i * 10)\n"
        }

        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("large_import.csv")
        try csvContent.write(to: tempFile, atomically: true, encoding: .utf8)

        measure {
            Task { @MainActor in
                _ = try await service.importCSV(from: tempFile, modelContext: context)
            }
        }

        // Clean up
        try? FileManager.default.removeItem(at: tempFile)
    }

    func testExportLargeCSVPerformance() {
        let service = ImportExportService()

        // Create large item dataset
        let items = (1 ... 1000).map { index in
            let item = TestData.makeItem(name: "Performance Item \\(index)")
            item.itemDescription = "Description for item \\(index)"
            item.brand = "Brand \\(index % 10)"
            item.purchasePrice = Decimal(index * 10)
            return item
        }

        measure {
            _ = service.exportToCSV(items: items)
        }
    }

    func testExportLargeJSONPerformance() {
        let service = ImportExportService()

        // Create large item dataset
        let items = (1 ... 1000).map { index in
            let item = TestData.makeItem(name: "JSON Performance Item \\(index)")
            item.itemDescription = "Description for item \\(index)"
            item.brand = "Brand \\(index % 10)"
            item.purchasePrice = Decimal(index * 10)
            item.tags = ["tag1", "tag2", "performance"]
            return item
        }

        measure {
            _ = service.exportToJSON(items: items)
        }
    }
}

// MARK: - UTType Tests

final class UTTypeExtensionTests: XCTestCase {
    func testCSVUTType() {
        XCTAssertNotNil(UTType.csv)
        XCTAssertTrue(UTType.csv.conforms(to: .data))

        // Test that it handles CSV files
        let csvIdentifier = UTType.csv.identifier
        XCTAssertNotNil(csvIdentifier)
    }
}

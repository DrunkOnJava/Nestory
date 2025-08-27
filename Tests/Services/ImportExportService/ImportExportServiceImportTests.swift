//
// Layer: Tests
// Module: Services
// Purpose: Import functionality tests for ImportExportService (CSV and JSON)
//

@testable import Nestory
import SwiftData
import UniformTypeIdentifiers
import XCTest

@MainActor
final class ImportExportServiceImportTests: XCTestCase {
    var service: ImportExportService!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var tempDirectory: URL!

    override func setUp() async throws {
        super.setUp()

        // Create temporary directory for test files
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ImportExportImportTests-\(UUID().uuidString)")
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
}
//
// Layer: Tests
// Module: Services
// Purpose: Data model tests for ImportExportService (ImportResult, ImportableItem, UTType)
//

@testable import Nestory
import SwiftData
import UniformTypeIdentifiers
import XCTest

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

    func testImportResultWithNoResults() {
        let emptyResult = ImportExportService.ImportResult(
            itemsImported: 0,
            itemsSkipped: 0,
            errors: []
        )

        let summary = emptyResult.summary
        XCTAssertTrue(summary.contains("0 items"))
        XCTAssertFalse(summary.contains("errors"))
        XCTAssertFalse(summary.contains("skipped"))
    }

    func testImportResultWithOnlyErrors() {
        let errorResult = ImportExportService.ImportResult(
            itemsImported: 0,
            itemsSkipped: 0,
            errors: ["Parse error", "Invalid format", "Missing field"]
        )

        let summary = errorResult.summary
        XCTAssertTrue(summary.contains("3 errors"))
        XCTAssertTrue(summary.contains("0 items"))
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

    func testImportErrorEquality() {
        XCTAssertEqual(ImportExportService.ImportError.invalidFormat, ImportExportService.ImportError.invalidFormat)
        XCTAssertEqual(ImportExportService.ImportError.missingRequiredFields, ImportExportService.ImportError.missingRequiredFields)
        XCTAssertEqual(ImportExportService.ImportError.dataConversionError, ImportExportService.ImportError.dataConversionError)
        
        XCTAssertEqual(ImportExportService.ImportError.parsingError("test"), ImportExportService.ImportError.parsingError("test"))
        XCTAssertNotEqual(ImportExportService.ImportError.parsingError("test1"), ImportExportService.ImportError.parsingError("test2"))
        
        XCTAssertNotEqual(ImportExportService.ImportError.invalidFormat, ImportExportService.ImportError.missingRequiredFields)
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
            notes: "Converted notes"
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
            notes: nil
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

    func testImportableItemWithMinimalData() {
        let minimal = ImportableItem(
            name: "Minimal Item",
            description: nil,
            brand: nil,
            modelNumber: nil,
            serialNumber: nil,
            quantity: 1,
            purchasePrice: nil,
            currency: "USD",
            purchaseDate: nil,
            tags: [],
            notes: nil
        )

        let item = minimal.toItem()

        XCTAssertEqual(item.name, "Minimal Item")
        XCTAssertNil(item.itemDescription)
        XCTAssertNil(item.brand)
        XCTAssertNil(item.modelNumber)
        XCTAssertNil(item.serialNumber)
        XCTAssertEqual(item.quantity, 1)
        XCTAssertNil(item.purchasePrice)
        XCTAssertEqual(item.currency, "USD")
        XCTAssertNil(item.purchaseDate)
        XCTAssertEqual(item.tags, [])
        XCTAssertNil(item.notes)
    }

    func testImportableItemWithCompleteData() {
        let complete = ImportableItem(
            name: "Complete Item",
            description: "Full description",
            brand: "Complete Brand",
            modelNumber: "CompleteModel",
            serialNumber: "CompleteSerial",
            quantity: 5,
            purchasePrice: 999.99,
            currency: "CAD",
            purchaseDate: Date(),
            tags: ["complete", "full", "test"],
            notes: "Complete notes with full details"
        )

        let item = complete.toItem()

        XCTAssertEqual(item.name, "Complete Item")
        XCTAssertEqual(item.itemDescription, "Full description")
        XCTAssertEqual(item.brand, "Complete Brand")
        XCTAssertEqual(item.modelNumber, "CompleteModel")
        XCTAssertEqual(item.serialNumber, "CompleteSerial")
        XCTAssertEqual(item.quantity, 5)
        XCTAssertEqual(item.purchasePrice, 999.99)
        XCTAssertEqual(item.currency, "CAD")
        XCTAssertNotNil(item.purchaseDate)
        XCTAssertEqual(item.tags, ["complete", "full", "test"])
        XCTAssertEqual(item.notes, "Complete notes with full details")
    }

    func testImportableItemRoundTripConversion() {
        let originalItem = TestData.makeItem(name: "Round Trip Item")
        originalItem.itemDescription = "Round trip description"
        originalItem.brand = "Round Trip Brand"
        originalItem.modelNumber = "RTModel"
        originalItem.serialNumber = "RTSerial"
        originalItem.quantity = 7
        originalItem.purchasePrice = 777.77
        originalItem.currency = "JPY"
        originalItem.purchaseDate = Date()
        originalItem.tags = ["round", "trip", "test"]
        originalItem.notes = "Round trip test notes"

        // Convert to ImportableItem and back
        let importableItem = ImportableItem(from: originalItem)
        let convertedItem = importableItem.toItem()

        // Verify all data is preserved (except ID and dates which are regenerated)
        XCTAssertEqual(convertedItem.name, originalItem.name)
        XCTAssertEqual(convertedItem.itemDescription, originalItem.itemDescription)
        XCTAssertEqual(convertedItem.brand, originalItem.brand)
        XCTAssertEqual(convertedItem.modelNumber, originalItem.modelNumber)
        XCTAssertEqual(convertedItem.serialNumber, originalItem.serialNumber)
        XCTAssertEqual(convertedItem.quantity, originalItem.quantity)
        XCTAssertEqual(convertedItem.purchasePrice, originalItem.purchasePrice)
        XCTAssertEqual(convertedItem.currency, originalItem.currency)
        XCTAssertEqual(convertedItem.tags, originalItem.tags)
        XCTAssertEqual(convertedItem.notes, originalItem.notes)
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

    func testCSVUTTypeProperties() {
        let csvType = UTType.csv
        
        // Verify it conforms to expected types
        XCTAssertTrue(csvType.conforms(to: .data))
        XCTAssertTrue(csvType.conforms(to: .content))
        XCTAssertTrue(csvType.conforms(to: .item))
        
        // Check identifier
        XCTAssertEqual(csvType.identifier, "public.comma-separated-values-text")
    }

    func testJSONUTTypeProperties() {
        let jsonType = UTType.json
        
        // Verify JSON type properties
        XCTAssertTrue(jsonType.conforms(to: .data))
        XCTAssertTrue(jsonType.conforms(to: .content))
        XCTAssertTrue(jsonType.conforms(to: .item))
        XCTAssertTrue(jsonType.conforms(to: .text))
        
        // Check identifier
        XCTAssertEqual(jsonType.identifier, "public.json")
    }
}
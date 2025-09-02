//
// Layer: Tests
// Module: Services
// Purpose: Export functionality tests for ImportExportService (CSV and JSON)
//

@testable import Nestory
import SwiftData
import UniformTypeIdentifiers
import XCTest

@MainActor
final class ImportExportServiceExportTests: XCTestCase {
    var service: any ImportExportService!

    override func setUp() async throws {
        super.setUp()
        service = ImportExportService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
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

    func testExportToJSONWithComplexData() {
        let items = [
            createTestItem(
                name: "Complex Item",
                description: "Item with all fields populated",
                brand: "Test Brand",
                model: "Test Model",
                serial: "ABC123",
                price: 1234.56,
                currency: "EUR",
                quantity: 5,
                tags: ["tag1", "tag2", "tag3"],
                notes: "Detailed notes about this item"
            ),
        ]

        let jsonData = service.exportToJSON(items: items)
        XCTAssertNotNil(jsonData)

        let jsonObject = try? JSONSerialization.jsonObject(with: jsonData!)
        XCTAssertNotNil(jsonObject)

        if let jsonArray = jsonObject as? [[String: Any]],
           let firstItem = jsonArray.first {
            XCTAssertEqual(firstItem["name"] as? String, "Complex Item")
            XCTAssertEqual(firstItem["description"] as? String, "Item with all fields populated")
            XCTAssertEqual(firstItem["brand"] as? String, "Test Brand")
            XCTAssertEqual(firstItem["modelNumber"] as? String, "Test Model")
            XCTAssertEqual(firstItem["serialNumber"] as? String, "ABC123")
            XCTAssertEqual(firstItem["currency"] as? String, "EUR")
            XCTAssertEqual(firstItem["quantity"] as? Int, 5)
            XCTAssertEqual(firstItem["notes"] as? String, "Detailed notes about this item")
            
            let tags = firstItem["tags"] as? [String]
            XCTAssertNotNil(tags)
            XCTAssertEqual(tags, ["tag1", "tag2", "tag3"])
        }
    }

    func testExportToJSONWithNilValues() {
        let items = [
            createTestItem(name: "Minimal Item")
        ]

        let jsonData = service.exportToJSON(items: items)
        XCTAssertNotNil(jsonData)

        let jsonObject = try? JSONSerialization.jsonObject(with: jsonData!)
        XCTAssertNotNil(jsonObject)

        if let jsonArray = jsonObject as? [[String: Any]],
           let firstItem = jsonArray.first {
            XCTAssertEqual(firstItem["name"] as? String, "Minimal Item")
            XCTAssertEqual(firstItem["quantity"] as? Int, 1) // Default value
            XCTAssertEqual(firstItem["currency"] as? String, "USD") // Default value
            
            // Optional fields should be nil or empty
            XCTAssertTrue(firstItem["description"] == nil || (firstItem["description"] as? String)?.isEmpty == true)
            XCTAssertTrue(firstItem["brand"] == nil || (firstItem["brand"] as? String)?.isEmpty == true)
        }
    }

    func testExportToCSVWithUnicodeCharacters() {
        let items = [
            createTestItem(
                name: "Café ☕️",
                description: "Equipment with émojis and ünïcødé",
                brand: "Brand™",
                notes: "Special chars: ©®€£¥"
            ),
        ]

        let csvData = service.exportToCSV(items: items)
        XCTAssertNotNil(csvData)

        let csvString = String(data: csvData!, encoding: .utf8)
        XCTAssertNotNil(csvString)

        // Verify Unicode characters are preserved
        XCTAssertTrue(csvString!.contains("Café ☕️"))
        XCTAssertTrue(csvString!.contains("émojis and ünïcødé"))
        XCTAssertTrue(csvString!.contains("Brand™"))
        XCTAssertTrue(csvString!.contains("©®€£¥"))
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
        notes: String? = nil
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
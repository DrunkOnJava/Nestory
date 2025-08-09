// Layer: Foundation

@testable import Nestory
import XCTest

final class IdentifierTests: XCTestCase {
    func testItemIDCreation() {
        let id1 = ItemID()
        let id2 = ItemID()

        XCTAssertNotEqual(id1, id2)
        XCTAssertNotEqual(id1.value, id2.value)
    }

    func testItemIDWithSpecificUUID() {
        let uuid = UUID()
        let id = ItemID(value: uuid)

        XCTAssertEqual(id.value, uuid)
        XCTAssertEqual(id.description, uuid.uuidString)
    }

    func testCategoryIDCreation() {
        let id1 = CategoryID()
        let id2 = CategoryID()

        XCTAssertNotEqual(id1, id2)
        XCTAssertNotEqual(id1.value, id2.value)
    }

    func testLocationIDCreation() {
        let id1 = LocationID()
        let id2 = LocationID()

        XCTAssertNotEqual(id1, id2)
        XCTAssertNotEqual(id1.value, id2.value)
    }

    func testIdentifierEquality() {
        let uuid = UUID()
        let id1 = ItemID(value: uuid)
        let id2 = ItemID(value: uuid)

        XCTAssertEqual(id1, id2)
        XCTAssertEqual(id1.hashValue, id2.hashValue)
    }

    func testIdentifierCodable() throws {
        let original = ItemID()
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ItemID.self, from: data)

        XCTAssertEqual(original, decoded)
        XCTAssertEqual(original.value, decoded.value)
    }

    func testDifferentIdentifierTypes() {
        let uuid = UUID()
        let itemID = ItemID(value: uuid)
        let categoryID = CategoryID(value: uuid)

        XCTAssertEqual(itemID.value, categoryID.value)
        XCTAssertEqual(itemID.description, categoryID.description)
    }

    func testAllIdentifierTypes() {
        let _ = ItemID()
        let _ = CategoryID()
        let _ = LocationID()
        let _ = PhotoAssetID()
        let _ = ReceiptID()
        let _ = WarrantyID()
        let _ = MaintenanceTaskID()
        let _ = ShareGroupID()
        let _ = UserID()
    }

    func testIdentifierDescription() {
        let uuid = UUID()
        let id = ItemID(value: uuid)

        XCTAssertEqual(id.description, uuid.uuidString)
    }
}

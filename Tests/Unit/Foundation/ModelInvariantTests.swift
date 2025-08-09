// Layer: Foundation

@testable import Nestory
import SwiftData
import XCTest

final class ModelInvariantTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() {
        super.setUp()

        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            container = try ModelContainer(
                for: Item.self, Category.self, Location.self, PhotoAsset.self,
                Receipt.self, Warranty.self, MaintenanceTask.self, ShareGroup.self,
                CurrencyRate.self,
                configurations: config
            )
            context = ModelContext(container)
        } catch {
            XCTFail("Failed to create model container: \(error)")
        }
    }

    override func tearDown() {
        container = nil
        context = nil
        super.tearDown()
    }

    func testItemCreation() throws {
        let item = try Item(
            name: "Test Item",
            description: "Test Description",
            quantity: 5
        )

        XCTAssertEqual(item.name, "Test Item")
        XCTAssertEqual(item.itemDescription, "Test Description")
        XCTAssertEqual(item.quantity, 5)
        XCTAssertEqual(item.slug, "test-item")
        XCTAssertNotNil(item.id)
        XCTAssertNotNil(item.createdAt)
        XCTAssertNotNil(item.updatedAt)
    }

    func testItemInvalidQuantity() {
        XCTAssertThrows {
            _ = try Item(name: "Test", quantity: 0)
        }

        XCTAssertThrows {
            _ = try Item(name: "Test", quantity: -1)
        }
    }

    func testItemPurchasePrice() throws {
        let item = try Item(name: "Test Item")
        let price = try Money(amount: Decimal(99.99), currencyCode: "USD")

        item.purchasePrice = price

        XCTAssertEqual(item.purchasePriceAmount, 9999)
        XCTAssertEqual(item.purchasePriceCurrency, "USD")
        XCTAssertEqual(item.purchasePrice?.amount, Decimal(99.99))
    }

    func testItemTags() throws {
        let item = try Item(name: "Test Item")

        try item.addTag("Electronics")
        try item.addTag("Apple")
        try item.addTag("electronics")

        XCTAssertEqual(item.tags.count, 2)
        XCTAssertTrue(item.tags.contains("electronics"))
        XCTAssertTrue(item.tags.contains("apple"))

        item.removeTag("Apple")
        XCTAssertEqual(item.tags.count, 1)
        XCTAssertFalse(item.tags.contains("apple"))
    }

    func testCategoryCreation() throws {
        let category = try Category(
            name: "Electronics",
            color: "#007AFF"
        )

        XCTAssertEqual(category.name, "Electronics")
        XCTAssertEqual(category.slug, "electronics")
        XCTAssertEqual(category.color, "#007AFF")
        XCTAssertEqual(category.depth, 0)
        XCTAssertEqual(category.itemCount, 0)
    }

    func testCategoryHierarchy() throws {
        let root = try Category(name: "Electronics")
        let child1 = try Category(name: "Computers", parent: root)
        let child2 = try Category(name: "Laptops", parent: child1)

        root.children = [child1]
        child1.children = [child2]

        XCTAssertEqual(child2.depth, 2)
        XCTAssertEqual(child2.rootCategory.name, root.name)
        XCTAssertEqual(root.allSubcategories.count, 2)
    }

    func testLocationCreation() throws {
        let location = try Location(
            name: "Living Room",
            type: .room
        )

        XCTAssertEqual(location.name, "Living Room")
        XCTAssertEqual(location.slug, "living-room")
        XCTAssertEqual(location.type, .room)
        XCTAssertEqual(location.fullPath, "Living Room")
    }

    func testLocationHierarchy() throws {
        let home = try Location(name: "Home", type: .home)
        let room = try Location(name: "Living Room", type: .room, parent: home)
        let shelf = try Location(name: "Bookshelf", type: .shelf, parent: room)

        home.children = [room]
        room.children = [shelf]

        XCTAssertEqual(shelf.depth, 2)
        XCTAssertEqual(shelf.fullPath, "Home > Living Room > Bookshelf")
        XCTAssertEqual(shelf.rootLocation.name, home.name)
        XCTAssertEqual(home.allSublocations.count, 2)
    }

    func testPhotoAssetCreation() throws {
        let photo = try PhotoAsset(
            fileName: "IMG_001.jpg",
            width: 1920,
            height: 1080,
            sizeInBytes: 2_500_000
        )

        XCTAssertEqual(photo.fileName, "IMG_001.jpg")
        XCTAssertEqual(photo.dimensions, "1920 × 1080")
        XCTAssertTrue(photo.isLandscape)
        XCTAssertFalse(photo.isPortrait)
        XCTAssertEqual(photo.aspectRatio, 16.0 / 9.0, accuracy: 0.01)
    }

    func testReceiptCreation() throws {
        let total = try Money(amount: Decimal(149.99), currencyCode: "USD")
        let receipt = try Receipt(
            vendor: "Apple Store",
            total: total,
            purchaseDate: Date()
        )

        XCTAssertEqual(receipt.vendor, "Apple Store")
        XCTAssertEqual(receipt.total?.amount, Decimal(149.99))
        XCTAssertNotNil(receipt.purchaseDate)
    }

    func testWarrantyCreation() throws {
        let startDate = Date()
        let expiresAt = Date().addingTimeInterval(365 * 24 * 60 * 60)

        let warranty = try Warranty(
            provider: "AppleCare+",
            startDate: startDate,
            expiresAt: expiresAt,
            coverageType: .extended
        )

        XCTAssertEqual(warranty.provider, "AppleCare+")
        XCTAssertTrue(warranty.isActive)
        XCTAssertFalse(warranty.isExpired)
        XCTAssertEqual(warranty.coverageType, .extended)
    }

    func testWarrantyInvalidDates() {
        let startDate = Date()
        let pastDate = Date().addingTimeInterval(-86400)

        XCTAssertThrows {
            _ = try Warranty(
                provider: "Test",
                startDate: startDate,
                expiresAt: pastDate
            )
        }
    }

    func testMaintenanceTaskCreation() throws {
        let task = try MaintenanceTask(
            title: "Clean filters",
            schedule: .monthly
        )

        XCTAssertEqual(task.title, "Clean filters")
        XCTAssertEqual(task.schedule, .monthly)
        XCTAssertTrue(task.isActive)
        XCTAssertNotNil(task.nextDueAt)
    }

    func testShareGroupCreation() throws {
        let group = try ShareGroup(name: "Family")

        try group.addMember(userId: "user1", name: "John", role: .owner)
        try group.addMember(userId: "user2", name: "Jane", role: .editor)

        XCTAssertEqual(group.name, "Family")
        XCTAssertEqual(group.memberCount, 2)
        XCTAssertNotNil(group.inviteCode)
        XCTAssertTrue(group.isActive)
    }

    func testShareGroupDuplicateMember() throws {
        let group = try ShareGroup(name: "Family")

        try group.addMember(userId: "user1", name: "John", role: .owner)

        XCTAssertThrows {
            try group.addMember(userId: "user1", name: "John", role: .editor)
        }
    }

    func testNonEmptyString() throws {
        let string1 = try NonEmptyString("  Test  ")
        XCTAssertEqual(string1.value, "Test")

        XCTAssertThrows {
            _ = try NonEmptyString("")
        }

        XCTAssertThrows {
            _ = try NonEmptyString("   ")
        }
    }

    func testSlug() throws {
        let slug1 = try Slug("Hello World!")
        XCTAssertEqual(slug1.value, "hello-world")

        let slug2 = try Slug("  Multiple   Spaces  ")
        XCTAssertEqual(slug2.value, "multiple-spaces")

        let slug3 = try Slug("Special@#$Characters123")
        XCTAssertEqual(slug3.value, "specialcharacters123")

        XCTAssertThrows {
            _ = try Slug("!")
        }
    }
}

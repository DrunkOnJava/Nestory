// Layer: Tests
// Module: Services
// Purpose: Search and filtering tests for InventoryService

import SwiftData
import XCTest

@testable import Nestory

@MainActor
final class InventoryServiceSearchTests: XCTestCase {
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

    // MARK: - Search Tests

    func testSearchItemsByName() async throws {
        // Create test items with different names
        let iphone = Item(name: "iPhone 14", description: "Apple smartphone", estimatedValue: 999, photos: [], updatedAt: Date())
        let ipad = Item(name: "iPad Pro", description: "Apple tablet", estimatedValue: 1099, photos: [], updatedAt: Date())
        let macbook = Item(name: "MacBook Air", description: "Apple laptop", estimatedValue: 1199, photos: [], updatedAt: Date())

        try await liveService.save(item: iphone)
        try await liveService.save(item: ipad)
        try await liveService.save(item: macbook)

        // Search for "iPhone"
        let iphoneResults = try await liveService.searchItems(query: "iPhone")
        XCTAssertEqual(iphoneResults.count, 1)
        XCTAssertEqual(iphoneResults.first?.name, "iPhone 14")

        // Search for "iPad"
        let ipadResults = try await liveService.searchItems(query: "iPad")
        XCTAssertEqual(ipadResults.count, 1)
        XCTAssertEqual(ipadResults.first?.name, "iPad Pro")

        // Search for "Mac"
        let macResults = try await liveService.searchItems(query: "Mac")
        XCTAssertEqual(macResults.count, 1)
        XCTAssertEqual(macResults.first?.name, "MacBook Air")
    }

    func testSearchItemsByDescription() async throws {
        let smartphone = Item(name: "Device A", description: "This is a smartphone with great features", estimatedValue: 500, photos: [], updatedAt: Date())
        let laptop = Item(name: "Device B", description: "This is a laptop for work", estimatedValue: 800, photos: [], updatedAt: Date())

        try await liveService.save(item: smartphone)
        try await liveService.save(item: laptop)

        let smartphoneResults = try await liveService.searchItems(query: "smartphone")
        XCTAssertEqual(smartphoneResults.count, 1)
        XCTAssertEqual(smartphoneResults.first?.name, "Device A")
    }

    func testSearchItemsByBrand() async throws {
        let appleItem = Item(name: "Apple Device", description: "Made by Apple", estimatedValue: 1000, photos: [], updatedAt: Date())
        let samsungItem = Item(name: "Samsung Device", description: "Made by Samsung", estimatedValue: 800, photos: [], updatedAt: Date())

        try await liveService.save(item: appleItem)
        try await liveService.save(item: samsungItem)

        let appleResults = try await liveService.searchItems(query: "Apple")
        XCTAssertEqual(appleResults.count, 1)
        XCTAssertEqual(appleResults.first?.name, "Apple Device")
    }

    func testSearchItemsBySerialNumber() async throws {
        let item = Item(name: "Test Device", description: "Test", estimatedValue: 100, photos: [], updatedAt: Date())
        item.serialNumber = "SN123456789"

        try await liveService.save(item: item)

        let results = try await liveService.searchItems(query: "SN123456789")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.serialNumber, "SN123456789")
    }

    func testSearchWithEmptyQuery() async throws {
        let item1 = Item(name: "Item 1", description: "First item", estimatedValue: 100, photos: [], updatedAt: Date())
        let item2 = Item(name: "Item 2", description: "Second item", estimatedValue: 200, photos: [], updatedAt: Date())

        try await liveService.save(item: item1)
        try await liveService.save(item: item2)

        // Empty query should return all items
        let results = try await liveService.searchItems(query: "")
        XCTAssertEqual(results.count, 2)
    }

    func testSearchWithNoMatches() async throws {
        let item = Item(name: "iPhone", description: "Apple smartphone", estimatedValue: 999, photos: [], updatedAt: Date())
        try await liveService.save(item: item)

        let results = try await liveService.searchItems(query: "Android")
        XCTAssertEqual(results.count, 0)
    }

    func testSearchResultsAreSorted() async throws {
        let now = Date()
        let item1 = Item(name: "Phone A", description: "smartphone", estimatedValue: 100, photos: [], updatedAt: now.addingTimeInterval(-120))
        let item2 = Item(name: "Phone B", description: "smartphone", estimatedValue: 200, photos: [], updatedAt: now.addingTimeInterval(-60))
        let item3 = Item(name: "Phone C", description: "smartphone", estimatedValue: 300, photos: [], updatedAt: now)

        try await liveService.save(item: item1)
        try await liveService.save(item: item2)
        try await liveService.save(item: item3)

        let results = try await liveService.searchItems(query: "smartphone")
        XCTAssertEqual(results.count, 3)

        // Results should be sorted by updatedAt descending
        XCTAssertEqual(results[0].name, "Phone C")
        XCTAssertEqual(results[1].name, "Phone B")
        XCTAssertEqual(results[2].name, "Phone A")
    }

    func testSearchCaseInsensitive() async throws {
        let item = Item(name: "iPhone", description: "Apple Smartphone", estimatedValue: 999, photos: [], updatedAt: Date())
        try await liveService.save(item: item)

        // Test different case variations
        let lowercaseResults = try await liveService.searchItems(query: "iphone")
        let uppercaseResults = try await liveService.searchItems(query: "IPHONE")
        let mixedCaseResults = try await liveService.searchItems(query: "iPhone")

        XCTAssertEqual(lowercaseResults.count, 1)
        XCTAssertEqual(uppercaseResults.count, 1)
        XCTAssertEqual(mixedCaseResults.count, 1)

        // Test description search case insensitive
        let descResults = try await liveService.searchItems(query: "smartphone")
        XCTAssertEqual(descResults.count, 1)
    }

    func testMockSearchItems() async throws {
        // Test mock service search functionality
        let allItems = try await mockService.fetchItems()
        XCTAssertGreaterThan(allItems.count, 0)

        // Assuming mock has items with "Test" in the name
        let testResults = try await mockService.searchItems(query: "Test")
        XCTAssertGreaterThan(testResults.count, 0)
        XCTAssertTrue(testResults.allSatisfy { $0.name.localizedCaseInsensitiveContains("Test") })

        // Search for something that shouldn't exist in mock data
        let noResults = try await mockService.searchItems(query: "XYZ_NONEXISTENT")
        XCTAssertEqual(noResults.count, 0)
    }

    // MARK: - Search Performance Tests

    func testSearchPerformance() async throws {
        // Create a larger dataset for performance testing
        let itemCount = 100
        for i in 0..<itemCount {
            let item = Item(
                name: "Item \(i)",
                description: "Description for item \(i)",
                estimatedValue: Double(i * 10),
                photos: [],
                updatedAt: Date().addingTimeInterval(TimeInterval(-i))
            )
            try await liveService.save(item: item)
        }

        // Measure search performance
        let startTime = CFAbsoluteTimeGetCurrent()
        let results = try await liveService.searchItems(query: "Item")
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertEqual(results.count, itemCount)
        XCTAssertLessThan(timeElapsed, 1.0) // Should complete within 1 second

        // Test more specific search
        let specificStartTime = CFAbsoluteTimeGetCurrent()
        let specificResults = try await liveService.searchItems(query: "Item 50")
        let specificTimeElapsed = CFAbsoluteTimeGetCurrent() - specificStartTime

        XCTAssertEqual(specificResults.count, 1)
        XCTAssertLessThan(specificTimeElapsed, 0.1) // Should be very fast for specific search
    }

    func testSearchMultipleTerms() async throws {
        let phone = Item(name: "iPhone 14 Pro", description: "Apple smartphone with great camera", estimatedValue: 1099, photos: [], updatedAt: Date())
        let laptop = Item(name: "MacBook Pro", description: "Apple laptop for professionals", estimatedValue: 1999, photos: [], updatedAt: Date())
        let tablet = Item(name: "iPad Pro", description: "Apple tablet with Apple Pencil", estimatedValue: 1099, photos: [], updatedAt: Date())

        try await liveService.save(item: phone)
        try await liveService.save(item: laptop)
        try await liveService.save(item: tablet)

        // Search for "Pro" should return all three
        let proResults = try await liveService.searchItems(query: "Pro")
        XCTAssertEqual(proResults.count, 3)

        // Search for "Apple" should return all three
        let appleResults = try await liveService.searchItems(query: "Apple")
        XCTAssertEqual(appleResults.count, 3)

        // Search for "iPhone Pro" should return one
        let specificResults = try await liveService.searchItems(query: "iPhone Pro")
        XCTAssertEqual(specificResults.count, 1)
        XCTAssertEqual(specificResults.first?.name, "iPhone 14 Pro")
    }

    func testSearchWithSpecialCharacters() async throws {
        let item = Item(name: "Test & Development", description: "Special chars: @#$%^&*()", estimatedValue: 100, photos: [], updatedAt: Date())
        try await liveService.save(item: item)

        let ampersandResults = try await liveService.searchItems(query: "&")
        XCTAssertEqual(ampersandResults.count, 1)

        let specialCharResults = try await liveService.searchItems(query: "@#$")
        XCTAssertEqual(specialCharResults.count, 1)
    }

    func testSearchWithUnicodeCharacters() async throws {
        let item = Item(name: "Café Equipment", description: "Équipement de café", estimatedValue: 200, photos: [], updatedAt: Date())
        try await liveService.save(item: item)

        let accentResults = try await liveService.searchItems(query: "Café")
        XCTAssertEqual(accentResults.count, 1)

        let frenchResults = try await liveService.searchItems(query: "Équipement")
        XCTAssertEqual(frenchResults.count, 1)
    }
}
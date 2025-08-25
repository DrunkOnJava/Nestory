//
// Layer: Tests
// Module: WarrantyTrackingServiceTests
// Purpose: Comprehensive tests for warranty tracking service functionality
//

import XCTest
import SwiftData
@testable import Nestory

@MainActor
final class WarrantyTrackingServiceTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var warrantyTrackingService: LiveWarrantyTrackingService!
    var mockNotificationService: MockNotificationService!

    override func setUp() async throws {
        super.setUp()

        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: Item.self, Category.self, Warranty.self,
            configurations: config
        )
        modelContext = ModelContext(modelContainer)

        // Create mock notification service
        mockNotificationService = MockNotificationService()

        // Create warranty tracking service
        warrantyTrackingService = LiveWarrantyTrackingService(
            modelContext: modelContext,
            notificationService: mockNotificationService
        )
    }

    override func tearDown() {
        warrantyTrackingService = nil
        mockNotificationService = nil
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }

    // MARK: - Core Warranty Operations Tests

    func testFetchWarrantiesIncludeExpired() async throws {
        // Given
        let category = Category(name: "Electronics")
        let item1 = Item(name: "Item1", category: category)
        let item2 = Item(name: "Item2", category: category)

        // Create active warranty
        let activeWarranty = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: Date().addingTimeInterval(-86400), // 1 day ago
            expiresAt: Date().addingTimeInterval(86400 * 365), // 1 year from now
            item: item1
        )

        // Create expired warranty
        let expiredWarranty = Warranty(
            provider: "Samsung",
            type: .manufacturer,
            startDate: Date().addingTimeInterval(-86400 * 400), // 400 days ago
            expiresAt: Date().addingTimeInterval(-86400 * 30), // 30 days ago
            item: item2
        )

        item1.warranty = activeWarranty
        item2.warranty = expiredWarranty

        modelContext.insert(category)
        modelContext.insert(item1)
        modelContext.insert(item2)
        modelContext.insert(activeWarranty)
        modelContext.insert(expiredWarranty)
        try modelContext.save()

        // When
        let allWarranties = try await warrantyTrackingService.fetchWarranties(includeExpired: true)
        let activeOnly = try await warrantyTrackingService.fetchWarranties(includeExpired: false)

        // Then
        XCTAssertEqual(allWarranties.count, 2)
        XCTAssertEqual(activeOnly.count, 1)
        XCTAssertEqual(activeOnly.first?.provider, "Apple")
    }

    func testFetchWarrantyForItem() async throws {
        // Given
        let category = Category(name: "Electronics")
        let item = Item(name: "MacBook", category: category)
        let warranty = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: Date(),
            expiresAt: Date().addingTimeInterval(86400 * 365),
            item: item
        )

        item.warranty = warranty

        modelContext.insert(category)
        modelContext.insert(item)
        modelContext.insert(warranty)
        try modelContext.save()

        // When
        let fetchedWarranty = try await warrantyTrackingService.fetchWarranty(for: item.id)

        // Then
        XCTAssertNotNil(fetchedWarranty)
        XCTAssertEqual(fetchedWarranty?.provider, "Apple")
        XCTAssertEqual(fetchedWarranty?.type, .manufacturer)
    }

    func testSaveWarranty() async throws {
        // Given
        let category = Category(name: "Electronics")
        let item = Item(name: "MacBook", category: category)

        modelContext.insert(category)
        modelContext.insert(item)
        try modelContext.save()

        let warranty = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: Date(),
            expiresAt: Date().addingTimeInterval(86400 * 365),
            item: item
        )

        // When
        try await warrantyTrackingService.saveWarranty(warranty, for: item.id)

        // Then
        let savedWarranty = try await warrantyTrackingService.fetchWarranty(for: item.id)
        XCTAssertNotNil(savedWarranty)
        XCTAssertEqual(savedWarranty?.provider, "Apple")

        // Verify notification was scheduled
        XCTAssertTrue(mockNotificationService.scheduleWarrantyExpirationCalled)
        XCTAssertEqual(mockNotificationService.lastScheduledItemId, item.id)
    }

    func testDeleteWarranty() async throws {
        // Given
        let category = Category(name: "Electronics")
        let item = Item(name: "MacBook", category: category)
        let warranty = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: Date(),
            expiresAt: Date().addingTimeInterval(86400 * 365),
            item: item
        )

        item.warranty = warranty

        modelContext.insert(category)
        modelContext.insert(item)
        modelContext.insert(warranty)
        try modelContext.save()

        // When
        try await warrantyTrackingService.deleteWarranty(for: item.id)

        // Then
        let deletedWarranty = try await warrantyTrackingService.fetchWarranty(for: item.id)
        XCTAssertNil(deletedWarranty)

        // Verify notification was cancelled
        XCTAssertTrue(mockNotificationService.cancelWarrantyNotificationsCalled)
        XCTAssertEqual(mockNotificationService.lastCancelledItemId, item.id)
    }

    // MARK: - Smart Detection Tests

    func testCalculateWarrantyExpiration() async throws {
        // Given
        let electronicsCategory = Category(name: "Electronics")
        let item = Item(name: "MacBook", category: electronicsCategory)
        item.purchaseDate = Date()

        modelContext.insert(electronicsCategory)
        modelContext.insert(item)
        try modelContext.save()

        // When
        let expirationDate = try await warrantyTrackingService.calculateWarrantyExpiration(for: item)

        // Then
        XCTAssertNotNil(expirationDate)

        let calendar = Calendar.current

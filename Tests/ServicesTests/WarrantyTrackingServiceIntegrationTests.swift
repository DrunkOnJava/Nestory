        let monthsFromNow = calendar.dateComponents([.month], from: Date(), to: expirationDate!).month!
        XCTAssertEqual(monthsFromNow, 12) // Electronics should have 12 months warranty
    }

    func testCalculateWarrantyExpirationNoPurchaseDate() async throws {
        // Given
        let category = Category(name: "Electronics")
        let item = Item(name: "MacBook", category: category)
        // No purchase date set

        modelContext.insert(category)
        modelContext.insert(item)
        try modelContext.save()

        // When
        let expirationDate = try await warrantyTrackingService.calculateWarrantyExpiration(for: item)

        // Then
        XCTAssertNil(expirationDate)
    }

    func testSuggestWarrantyProvider() async {
        // Given
        let category = Category(name: "Electronics")
        let itemWithBrand = Item(name: "MacBook", category: category)
        itemWithBrand.brand = "Apple"

        let itemWithoutBrand = Item(name: "Generic Laptop", category: category)

        // When
        let providerWithBrand = await warrantyTrackingService.suggestWarrantyProvider(for: itemWithBrand)
        let providerWithoutBrand = await warrantyTrackingService.suggestWarrantyProvider(for: itemWithoutBrand)

        // Then
        XCTAssertEqual(providerWithBrand, "Apple")
        XCTAssertEqual(providerWithoutBrand, "Manufacturer")
    }

    func testDefaultWarrantyDuration() async {
        // Given
        let electronicsCategory = Category(name: "Electronics")
        let furnitureCategory = Category(name: "Furniture")

        // When
        let electronicsDuration = await warrantyTrackingService.defaultWarrantyDuration(for: electronicsCategory)
        let furnitureDuration = await warrantyTrackingService.defaultWarrantyDuration(for: furnitureCategory)
        let noCategoryDuration = await warrantyTrackingService.defaultWarrantyDuration(for: nil)

        // Then
        XCTAssertEqual(electronicsDuration, 12)
        XCTAssertEqual(furnitureDuration, 60)
        XCTAssertEqual(noCategoryDuration, 12) // Default for "Other"
    }

    func testDetectWarrantyFromReceipt() async throws {
        // Given
        let category = Category(name: "Electronics")
        let item = Item(name: "MacBook", category: category)
        item.brand = "Apple"

        let receiptText = "MacBook Pro 13-inch M2 - $1299.00 - 1 year limited warranty from Apple Inc."

        // When
        let result = try await warrantyTrackingService.detectWarrantyFromReceipt(
            item: item,
            receiptText: receiptText
        )

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.suggestedDuration, 12)
        XCTAssertEqual(result?.suggestedProvider, "Apple")
        XCTAssertGreaterThan(result?.confidence ?? 0, 0.5)
    }

    func testDetectWarrantyFromReceiptNoText() async throws {
        // Given
        let category = Category(name: "Electronics")
        let item = Item(name: "MacBook", category: category)

        // When
        let result = try await warrantyTrackingService.detectWarrantyFromReceipt(
            item: item,
            receiptText: nil
        )

        // Then
        XCTAssertNil(result)
    }

    // MARK: - Status Query Tests

    func testGetWarrantyStatusNoWarranty() async throws {
        // Given
        let category = Category(name: "Electronics")
        let item = Item(name: "MacBook", category: category)

        modelContext.insert(category)
        modelContext.insert(item)
        try modelContext.save()

        // When
        let status = try await warrantyTrackingService.getWarrantyStatus(for: item)

        // Then
        XCTAssertEqual(status, .noWarranty)
    }

    func testGetWarrantyStatusActive() async throws {
        // Given
        let category = Category(name: "Electronics")
        let item = Item(name: "MacBook", category: category)
        let warranty = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: Date().addingTimeInterval(-86400), // 1 day ago
            expiresAt: Date().addingTimeInterval(86400 * 100), // 100 days from now
            item: item
        )

        item.warranty = warranty

        modelContext.insert(category)
        modelContext.insert(item)
        modelContext.insert(warranty)
        try modelContext.save()

        // When
        let status = try await warrantyTrackingService.getWarrantyStatus(for: item)

        // Then
        if case let .active(daysRemaining) = status {
            XCTAssertGreaterThan(daysRemaining, 90)
            XCTAssertLessThan(daysRemaining, 110)
        } else {
            XCTFail("Expected active status, got \(status)")
        }
    }

    func testGetWarrantyStatusExpiringSoon() async throws {
        // Given
        let category = Category(name: "Electronics")
        let item = Item(name: "MacBook", category: category)
        let warranty = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: Date().addingTimeInterval(-86400 * 300), // 300 days ago
            expiresAt: Date().addingTimeInterval(86400 * 15), // 15 days from now
            item: item
        )

        item.warranty = warranty

        modelContext.insert(category)
        modelContext.insert(item)
        modelContext.insert(warranty)
        try modelContext.save()

        // When
        let status = try await warrantyTrackingService.getWarrantyStatus(for: item)

        // Then
        if case let .expiringSoon(daysRemaining) = status {
            XCTAssertGreaterThan(daysRemaining, 10)
            XCTAssertLessThan(daysRemaining, 20)
        } else {
            XCTFail("Expected expiringSoon status, got \(status)")
        }
    }

    func testGetWarrantyStatusExpired() async throws {
        // Given
        let category = Category(name: "Electronics")
        let item = Item(name: "MacBook", category: category)
        let warranty = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: Date().addingTimeInterval(-86400 * 400), // 400 days ago
            expiresAt: Date().addingTimeInterval(-86400 * 30), // 30 days ago
            item: item
        )

        item.warranty = warranty

        modelContext.insert(category)
        modelContext.insert(item)
        modelContext.insert(warranty)
        try modelContext.save()

        // When
        let status = try await warrantyTrackingService.getWarrantyStatus(for: item)

        // Then
        if case let .expired(daysAgo) = status {
            XCTAssertGreaterThan(daysAgo, 25)
            XCTAssertLessThan(daysAgo, 35)
        } else {
            XCTFail("Expected expired status, got \(status)")
        }
    }

    func testGetItemsWithExpiringWarranties() async throws {
        // Given
        let category = Category(name: "Electronics")

        let item1 = Item(name: "Item1", category: category)
        let warranty1 = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: Date().addingTimeInterval(-86400 * 300),
            expiresAt: Date().addingTimeInterval(86400 * 15), // 15 days from now
            item: item1
        )
        item1.warranty = warranty1

        let item2 = Item(name: "Item2", category: category)
        let warranty2 = Warranty(
            provider: "Samsung",
            type: .manufacturer,
            startDate: Date().addingTimeInterval(-86400 * 100),
            expiresAt: Date().addingTimeInterval(86400 * 100), // 100 days from now
            item: item2
        )
        item2.warranty = warranty2

        let item3 = Item(name: "Item3", category: category)
        let warranty3 = Warranty(
            provider: "LG",
            type: .manufacturer,
            startDate: Date().addingTimeInterval(-86400 * 500),
            expiresAt: Date().addingTimeInterval(-86400 * 10), // 10 days ago (expired)
            item: item3
        )
        item3.warranty = warranty3

        modelContext.insert(category)
        modelContext.insert(item1)
        modelContext.insert(item2)
        modelContext.insert(item3)
        modelContext.insert(warranty1)
        modelContext.insert(warranty2)
        modelContext.insert(warranty3)
        try modelContext.save()

        // When
        let expiringItems = try await warrantyTrackingService.getItemsWithExpiringWarranties(within: 30)

        // Then
        XCTAssertEqual(expiringItems.count, 1)
        XCTAssertEqual(expiringItems.first?.name, "Item1")
    }

    func testGetItemsMissingWarrantyInfo() async throws {
        // Given
        let electronicsCategory = Category(name: "Electronics")
        let clothingCategory = Category(name: "Clothing")

        // Item with purchase date but no warranty (should be flagged for Electronics)
        let item1 = Item(name: "MacBook", category: electronicsCategory)
        item1.purchaseDate = Date()

        // Item with warranty but missing policy number (should be flagged)
        let item2 = Item(name: "iPhone", category: electronicsCategory)
        let warranty2 = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: Date(),
            expiresAt: Date().addingTimeInterval(86400 * 365),
            item: item2
        )
        // No policy number set
        item2.warranty = warranty2

        // Item with complete warranty info (should not be flagged)
        let item3 = Item(name: "iPad", category: electronicsCategory)
        let warranty3 = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: Date(),
            expiresAt: Date().addingTimeInterval(86400 * 365),
            item: item3
        )
        warranty3.policyNumber = "APL123456"
        item3.warranty = warranty3

        // Clothing item without warranty (should not be flagged - short warranty period)
        let item4 = Item(name: "T-Shirt", category: clothingCategory)
        item4.purchaseDate = Date()

        modelContext.insert(electronicsCategory)
        modelContext.insert(clothingCategory)
        modelContext.insert(item1)
        modelContext.insert(item2)
        modelContext.insert(item3)
        modelContext.insert(item4)
        modelContext.insert(warranty2)
        modelContext.insert(warranty3)
        try modelContext.save()

        // When
        let missingItems = try await warrantyTrackingService.getItemsMissingWarrantyInfo()

        // Then
        XCTAssertEqual(missingItems.count, 2)
        let itemNames = missingItems.map(\.name).sorted()
        XCTAssertEqual(itemNames, ["iPhone", "MacBook"])
    }

    func testGetWarrantyStatistics() async throws {
        // Given
        let category = Category(name: "Electronics")

        // Item with active warranty
        let item1 = Item(name: "Item1", category: category)
        let warranty1 = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: Date().addingTimeInterval(-86400 * 100),
            expiresAt: Date().addingTimeInterval(86400 * 265), // Active
            item: item1
        )
        item1.warranty = warranty1

        // Item with expiring warranty
        let item2 = Item(name: "Item2", category: category)
        let warranty2 = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: Date().addingTimeInterval(-86400 * 340),
            expiresAt: Date().addingTimeInterval(86400 * 25), // Expiring soon
            item: item2
        )
        item2.warranty = warranty2

        // Item with expired warranty
        let item3 = Item(name: "Item3", category: category)
        let warranty3 = Warranty(
            provider: "Samsung",
            type: .manufacturer,
            startDate: Date().addingTimeInterval(-86400 * 500),
            expiresAt: Date().addingTimeInterval(-86400 * 10), // Expired
            item: item3
        )
        item3.warranty = warranty3

        // Item without warranty
        let item4 = Item(name: "Item4", category: category)
        item4.purchaseDate = Date()

        modelContext.insert(category)
        modelContext.insert(item1)
        modelContext.insert(item2)
        modelContext.insert(item3)
        modelContext.insert(item4)
        modelContext.insert(warranty1)
        modelContext.insert(warranty2)
        modelContext.insert(warranty3)
        try modelContext.save()

        // When
        let stats = try await warrantyTrackingService.getWarrantyStatistics()

        // Then
        XCTAssertEqual(stats.totalItems, 4)
        XCTAssertEqual(stats.itemsWithWarranty, 3)
        XCTAssertEqual(stats.activeWarranties, 2) // item1 and item2
        XCTAssertEqual(stats.expiringSoon, 1) // item2
        XCTAssertEqual(stats.expired, 1) // item3
        XCTAssertEqual(stats.missingWarrantyInfo, 1) // item4
        XCTAssertEqual(stats.mostCommonProvider, "Apple")
        XCTAssertEqual(stats.coveragePercentage, 75.0)
    }

    // MARK: - Bulk Operations Tests

    func testBulkCreateWarranties() async throws {
        // Given
        let category = Category(name: "Electronics")

        let item1 = Item(name: "MacBook", category: category)
        item1.purchaseDate = Date()
        item1.brand = "Apple"

        let item2 = Item(name: "Galaxy Phone", category: category)
        item2.purchaseDate = Date().addingTimeInterval(-86400 * 30)
        item2.brand = "Samsung"

        // Item that already has warranty (should be skipped)
        let item3 = Item(name: "iPad", category: category)
        let existingWarranty = Warranty(
            provider: "Apple",
            type: .manufacturer,
            startDate: Date(),
            expiresAt: Date().addingTimeInterval(86400 * 365),
            item: item3
        )
        item3.warranty = existingWarranty

        modelContext.insert(category)
        modelContext.insert(item1)
        modelContext.insert(item2)
        modelContext.insert(item3)
        modelContext.insert(existingWarranty)
        try modelContext.save()

        // When
        let createdWarranties = try await warrantyTrackingService.bulkCreateWarranties(
            for: [item1, item2, item3]
        )

        // Then
        XCTAssertEqual(createdWarranties.count, 2) // item3 should be skipped

        let providers = createdWarranties.map(\.provider).sorted()
        XCTAssertEqual(providers, ["Apple", "Samsung"])

        // Verify warranties were saved
        let warranty1 = try await warrantyTrackingService.fetchWarranty(for: item1.id)
        let warranty2 = try await warrantyTrackingService.fetchWarranty(for: item2.id)

        XCTAssertNotNil(warranty1)
        XCTAssertNotNil(warranty2)
        XCTAssertEqual(warranty1?.provider, "Apple")
        XCTAssertEqual(warranty2?.provider, "Samsung")
    }

    func testUpdateWarrantiesFromReceipts() async throws {
        // Given
        let category = Category(name: "Electronics")

        let item1 = Item(name: "MacBook", category: category)
        item1.extractedReceiptText = "MacBook Pro 13-inch M2 - $1299.00 - 1 year limited warranty"
        item1.purchaseDate = Date()
        item1.brand = "Apple"

        let item2 = Item(name: "Phone", category: category)
        item2.extractedReceiptText = "Generic phone - no warranty info"
        item2.purchaseDate = Date()

        modelContext.insert(category)
        modelContext.insert(item1)
        modelContext.insert(item2)
        try modelContext.save()

        // When
        let updatedCount = try await warrantyTrackingService.updateWarrantiesFromReceipts()

        // Then
        XCTAssertEqual(updatedCount, 1) // Only item1 should get warranty

        let warranty1 = try await warrantyTrackingService.fetchWarranty(for: item1.id)
        let warranty2 = try await warrantyTrackingService.fetchWarranty(for: item2.id)

        XCTAssertNotNil(warranty1)
        XCTAssertNil(warranty2)
        XCTAssertEqual(warranty1?.provider, "Apple")
    }
}

// MARK: - Mock Notification Service

@MainActor
class MockNotificationService: NotificationService {
    var isAuthorized = true
    var authorizationStatus: UNAuthorizationStatus = .authorized

    var scheduleWarrantyExpirationCalled = false
    var lastScheduledItemId: UUID?
    var cancelWarrantyNotificationsCalled = false
    var lastCancelledItemId: UUID?

    func requestAuthorization() async throws -> Bool {
        true
    }

    func checkAuthorizationStatus() async {
        // Mock implementation
    }

    func scheduleWarrantyExpirationNotifications(for item: Item) async throws {
        scheduleWarrantyExpirationCalled = true
        lastScheduledItemId = item.id
    }

    func cancelWarrantyNotifications(for itemId: UUID) async {
        cancelWarrantyNotificationsCalled = true
        lastCancelledItemId = itemId
    }

    func scheduleAllWarrantyNotifications() async throws {
        // Mock implementation
    }

    func getUpcomingWarrantyExpirations(within _: Int) async throws -> [Item] {
        []
    }

    func scheduleInsurancePolicyRenewal(
        policyName _: String,
        renewalDate _: Date,
        policyType _: String,
        estimatedValue _: Decimal?,
        policyId _: String?
    ) async throws {
        // Mock implementation
    }

    func scheduleDocumentUpdateReminder(for _: Item, afterDays _: Int) async throws {
        // Mock implementation
    }

    func scheduleMaintenanceReminder(
        for _: Item,
        maintenanceType _: String,
        scheduledDate _: Date,
        intervalMonths _: Int
    ) async throws {
        // Mock implementation
    }

    func getPendingNotifications() async -> [NotificationRequestData] {
        []
    }

    func cancelAllNotifications() async {
        // Mock implementation
    }

    func clearDeliveredNotifications() async {
        // Mock implementation
    }

    func setupNotificationCategories() async {
        // Mock implementation
    }
}

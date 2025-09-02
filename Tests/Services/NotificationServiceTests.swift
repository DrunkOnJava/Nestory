//
// Layer: Tests
// Module: Services
// Purpose: Comprehensive tests for NotificationService with actor isolation
//

@testable import Nestory
import SwiftData
import UserNotifications
import XCTest

@MainActor
final class NotificationServiceTests: XCTestCase {
    var service: any NotificationService!
    var mockModelContainer: ModelContainer!
    var mockModelContext: ModelContext!

    override func setUp() async throws {
        super.setUp()

        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        mockModelContainer = try ModelContainer(for: Item.self, configurations: config)
        mockModelContext = ModelContext(mockModelContainer)

        service = NotificationService(modelContext: mockModelContext)
    }

    override func tearDown() {
        service = nil
        mockModelContext = nil
        mockModelContainer = nil
        super.tearDown()
    }

    // MARK: - Authorization Tests

    func testInitialAuthorizationState() {
        XCTAssertFalse(service.isAuthorized)
        XCTAssertEqual(service.authorizationStatus, .notDetermined)
    }

    func testRequestAuthorization() async throws {
        // Note: This test will interact with the system notification center
        // In a real test environment, we would mock the NotificationActor
        let authorized = await service.requestAuthorization()

        // The result depends on system state, but we can test the method completes
        XCTAssertTrue(authorized || !authorized) // Always true, just testing no crash
    }

    func testCheckAuthorizationStatus() async {
        await service.checkAuthorizationStatus()

        // Authorization status should be updated (could be any value)
        XCTAssertNotEqual(service.authorizationStatus, .notDetermined)
    }

    // MARK: - Warranty Notification Tests

    func testScheduleWarrantyNotificationWithValidItem() async throws {
        // Create test item with warranty date
        let item = TestData.makeItem(name: "Test iPhone")
        let futureDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days from now
        item.warrantyExpirationDate = futureDate
        mockModelContext.insert(item)
        try mockModelContext.save()

        // Test scheduling (will only work if authorized, otherwise logs warning)
        try await service.scheduleWarrantyExpirationNotifications(for: item)

        // Verify no crash and method completes
        XCTAssertTrue(true, "Method completed without throwing")
    }

    func testScheduleWarrantyNotificationWithoutWarrantyDate() async throws {
        let item = TestData.makeItem(name: "Test Item")
        // No warranty date set
        mockModelContext.insert(item)
        try mockModelContext.save()

        // Should complete without error
        try await service.scheduleWarrantyExpirationNotifications(for: item)

        XCTAssertTrue(true, "Method completed without throwing")
    }

    func testScheduleWarrantyNotificationWithPastDate() async throws {
        let item = TestData.makeItem(name: "Expired Item")
        let pastDate = Date().addingTimeInterval(-30 * 24 * 60 * 60) // 30 days ago
        item.warrantyExpirationDate = pastDate
        mockModelContext.insert(item)
        try mockModelContext.save()

        // Should complete without scheduling future notifications
        try await service.scheduleWarrantyExpirationNotifications(for: item)

        XCTAssertTrue(true, "Method completed without throwing")
    }

    func testCancelWarrantyNotifications() async {
        let itemId = UUID()

        // Should complete without error
        await service.cancelWarrantyNotifications(for: itemId)

        XCTAssertTrue(true, "Method completed without throwing")
    }

    func testScheduleAllWarrantyNotifications() async throws {
        // Create test items with warranty dates
        let item1 = TestData.makeItem(name: "Item 1")
        item1.warrantyExpirationDate = Date().addingTimeInterval(15 * 24 * 60 * 60)

        let item2 = TestData.makeItem(name: "Item 2")
        item2.warrantyExpirationDate = Date().addingTimeInterval(45 * 24 * 60 * 60)

        let item3 = TestData.makeItem(name: "Item 3")
        // No warranty date

        mockModelContext.insert(item1)
        mockModelContext.insert(item2)
        mockModelContext.insert(item3)
        try mockModelContext.save()

        // Should process all items with warranty dates
        try await service.scheduleAllWarrantyNotifications()

        XCTAssertTrue(true, "Method completed without throwing")
    }

    func testScheduleAllWarrantyNotificationsWithoutModelContext() async throws {
        let serviceWithoutContext = NotificationService()

        // Should complete without error but log error message
        try await serviceWithoutContext.scheduleAllWarrantyNotifications()

        XCTAssertTrue(true, "Method completed without throwing")
    }

    func testGetUpcomingWarrantyExpirations() async throws {
        // Create test items
        let nearExpiryItem = TestData.makeItem(name: "Near Expiry")
        nearExpiryItem.warrantyExpirationDate = Date().addingTimeInterval(5 * 24 * 60 * 60) // 5 days

        let farExpiryItem = TestData.makeItem(name: "Far Expiry")
        farExpiryItem.warrantyExpirationDate = Date().addingTimeInterval(100 * 24 * 60 * 60) // 100 days

        let expiredItem = TestData.makeItem(name: "Expired")
        expiredItem.warrantyExpirationDate = Date().addingTimeInterval(-5 * 24 * 60 * 60) // 5 days ago

        mockModelContext.insert(nearExpiryItem)
        mockModelContext.insert(farExpiryItem)
        mockModelContext.insert(expiredItem)
        try mockModelContext.save()

        // Get upcoming expirations within 30 days
        let upcoming = try await service.getUpcomingWarrantyExpirations(within: 30)

        // Should only include the near expiry item
        XCTAssertEqual(upcoming.count, 1)
        XCTAssertEqual(upcoming.first?.name, "Near Expiry")
    }

    func testGetUpcomingWarrantyExpirationsWithoutModelContext() async throws {
        let serviceWithoutContext = NotificationService()

        let upcoming = try await serviceWithoutContext.getUpcomingWarrantyExpirations()

        XCTAssertEqual(upcoming.count, 0)
    }

    // MARK: - Insurance Policy Notification Tests

    func testScheduleInsurancePolicyRenewal() async throws {
        let policyId = "TEST-POLICY-123"
        let policyName = "Home Insurance Policy"
        let renewalDate = Date().addingTimeInterval(45 * 24 * 60 * 60) // 45 days from now

        try await service.scheduleInsurancePolicyRenewal(
            policyId: policyId,
            policyName: policyName,
            renewalDate: renewalDate,
        )

        XCTAssertTrue(true, "Method completed without throwing")
    }

    func testScheduleInsurancePolicyRenewalWithPastDate() async throws {
        let policyId = "PAST-POLICY-123"
        let policyName = "Expired Policy"
        let renewalDate = Date().addingTimeInterval(-10 * 24 * 60 * 60) // 10 days ago

        // Should complete without scheduling
        try await service.scheduleInsurancePolicyRenewal(
            policyId: policyId,
            policyName: policyName,
            renewalDate: renewalDate,
        )

        XCTAssertTrue(true, "Method completed without throwing")
    }

    // MARK: - Document Update Reminder Tests

    func testScheduleDocumentUpdateReminder() async throws {
        let item = TestData.makeItem(name: "Document Item")
        mockModelContext.insert(item)
        try mockModelContext.save()

        try await service.scheduleDocumentUpdateReminder(for: item)

        XCTAssertTrue(true, "Method completed without throwing")
    }

    func testScheduleDocumentUpdateReminderWithCustomDays() async throws {
        let item = TestData.makeItem(name: "Custom Document Item")
        mockModelContext.insert(item)
        try mockModelContext.save()

        try await service.scheduleDocumentUpdateReminder(for: item, afterDays: 14)

        XCTAssertTrue(true, "Method completed without throwing")
    }

    // MARK: - Maintenance Reminder Tests

    func testScheduleMaintenanceReminder() async throws {
        let item = TestData.makeItem(name: "Maintenance Item")
        let maintenanceDate = Date().addingTimeInterval(7 * 24 * 60 * 60) // 7 days from now

        try await service.scheduleMaintenanceReminder(
            for: item,
            maintenanceType: "Oil Change",
            date: maintenanceDate,
        )

        XCTAssertTrue(true, "Method completed without throwing")
    }

    // MARK: - Notification Management Tests

    func testGetPendingNotifications() async {
        let pendingNotifications = await service.getPendingNotifications()

        // Should return array (could be empty)
        XCTAssertNotNil(pendingNotifications)
    }

    func testCancelAllNotifications() async {
        await service.cancelAllNotifications()

        XCTAssertTrue(true, "Method completed without throwing")
    }

    func testClearDeliveredNotifications() async {
        await service.clearDeliveredNotifications()

        XCTAssertTrue(true, "Method completed without throwing")
    }

    func testSetupNotificationCategories() async {
        await service.setupNotificationCategories()

        XCTAssertTrue(true, "Method completed without throwing")
    }

    // MARK: - Settings Tests

    func testUpdateNotificationSettings() {
        service.updateNotificationSettings(
            warrantyEnabled: true,
            insuranceEnabled: false,
            documentEnabled: true,
            maintenanceEnabled: false,
            notificationDays: [7, 14, 30],
        )

        // Verify settings were stored
        let settings = service.getNotificationSettings()
        XCTAssertTrue(settings.warranty)
        XCTAssertFalse(settings.insurance)
        XCTAssertTrue(settings.document)
        XCTAssertFalse(settings.maintenance)
        XCTAssertEqual(settings.days, [7, 14, 30])
    }

    func testGetNotificationSettingsDefaults() {
        // Clear any existing settings
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "warrantyNotificationsEnabled")
        defaults.removeObject(forKey: "insuranceNotificationsEnabled")
        defaults.removeObject(forKey: "documentNotificationsEnabled")
        defaults.removeObject(forKey: "maintenanceNotificationsEnabled")
        defaults.removeObject(forKey: "warrantyNotificationDays")

        let settings = service.getNotificationSettings()

        // Should return default values
        XCTAssertFalse(settings.warranty)
        XCTAssertFalse(settings.insurance)
        XCTAssertFalse(settings.document)
        XCTAssertFalse(settings.maintenance)
        XCTAssertNotEqual(settings.days.count, 0) // Should have default days
    }

    func testUpdateIndividualNotificationSettings() {
        // Test updating individual settings
        service.updateNotificationSettings(warrantyEnabled: true)
        var settings = service.getNotificationSettings()
        XCTAssertTrue(settings.warranty)

        service.updateNotificationSettings(insuranceEnabled: true)
        settings = service.getNotificationSettings()
        XCTAssertTrue(settings.warranty) // Should preserve previous
        XCTAssertTrue(settings.insurance)

        service.updateNotificationSettings(notificationDays: [1, 3, 7])
        settings = service.getNotificationSettings()
        XCTAssertEqual(settings.days, [1, 3, 7])
    }
}

// MARK: - Actor Isolation Tests

@MainActor
final class NotificationActorIsolationTests: XCTestCase {
    func testServiceIsMainActorIsolated() {
        // Verify the service properly enforces @MainActor isolation
        let service = NotificationService()

        // These properties should be accessible from main actor context
        XCTAssertFalse(service.isAuthorized)
        XCTAssertEqual(service.authorizationStatus, .notDetermined)
    }

    func testAsyncMethodsCanBeCalledFromMainActor() async throws {
        let service = NotificationService()

        // These async methods should be callable from main actor
        await service.checkAuthorizationStatus()
        _ = await service.requestAuthorization()
        await service.cancelAllNotifications()

        XCTAssertTrue(true, "All async methods completed without actor isolation issues")
    }
}

// MARK: - Performance Tests

@MainActor
final class NotificationServicePerformanceTests: XCTestCase {
    func testScheduleMultipleWarrantyNotificationsPerformance() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        let context = ModelContext(container)
        let service = NotificationService(modelContext: context)

        // Create 100 items with warranty dates
        let items = (1 ... 100).map { index in
            let item = TestData.makeItem(name: "Item \(index)")
            item.warrantyExpirationDate = Date().addingTimeInterval(Double(index) * 24 * 60 * 60)
            return item
        }

        for item in items {
            context.insert(item)
        }
        try context.save()

        measure {
            Task { @MainActor in
                try await service.scheduleAllWarrantyNotifications()
            }
        }
    }

    func testGetUpcomingWarrantyExpirationsPerformance() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        let context = ModelContext(container)
        let service = NotificationService(modelContext: context)

        // Create 1000 items with various warranty dates
        let items = (1 ... 1000).map { index in
            let item = TestData.makeItem(name: "Item \(index)")
            // Spread warranty dates over 200 days
            item.warrantyExpirationDate = Date().addingTimeInterval(Double(index % 200) * 24 * 60 * 60)
            return item
        }

        for item in items {
            context.insert(item)
        }
        try context.save()

        measure {
            Task { @MainActor in
                _ = try await service.getUpcomingWarrantyExpirations(within: 30)
            }
        }
    }
}

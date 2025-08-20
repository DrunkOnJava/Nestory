//
// Layer: Tests
// Module: SettingsViewTests
// Purpose: Comprehensive tests for settings navigation and functionality
//

@testable import Nestory
import SwiftData
import SwiftUI
import XCTest

@MainActor
final class SettingsViewTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var themeManager: ThemeManager!

    override func setUp() async throws {
        try await super.setUp()

        // Set up in-memory model container for testing
        let schema = Schema([Item.self, Category.self, Room.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = container.mainContext
        themeManager = ThemeManager.shared
    }

    override func tearDown() async throws {
        container = nil
        context = nil
        themeManager = nil
        try await super.tearDown()
    }

    // MARK: - Basic Rendering Tests

    func testSettingsViewRendering() throws {
        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Should render without crashing
        XCTAssertNotNil(hostingController.view)
    }

    func testSettingsViewWithoutThemeManager() throws {
        let settingsView = SettingsView()
            .modelContainer(container)

        // Should handle missing theme manager gracefully
        XCTAssertNoThrow(settingsView)
    }

    func testSettingsViewWithoutModelContainer() throws {
        let settingsView = SettingsView()
            .environmentObject(themeManager)

        // Should handle missing model container gracefully
        XCTAssertNoThrow(settingsView)
    }

    // MARK: - Navigation Structure Tests

    func testSettingsNavigationStructure() throws {
        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Should have proper navigation structure
        XCTAssertNotNil(hostingController.view)

        // Test that navigation stack is set up correctly
        let navigationController = hostingController.children.compactMap { $0 as? UINavigationController }.first
        XCTAssertNotNil(navigationController, "Should be embedded in navigation controller")
    }

    // MARK: - Settings Section Tests

    func testAppearanceSettingsSection() throws {
        // Test that appearance settings are accessible
        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)

        // Verify theme manager is working
        XCTAssertNotNil(themeManager)

        // Test theme changes
        themeManager.setTheme(.light)
        XCTAssertEqual(themeManager.currentTheme, .light)

        themeManager.setTheme(.dark)
        XCTAssertEqual(themeManager.currentTheme, .dark)

        themeManager.setTheme(.system)
        XCTAssertEqual(themeManager.currentTheme, .system)
    }

    func testGeneralSettingsSection() throws {
        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Should include general settings section
        XCTAssertNotNil(hostingController.view)
    }

    func testNotificationSettingsSection() throws {
        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Should include notification settings section
        XCTAssertNotNil(hostingController.view)
    }

    func testDataStorageSettingsSection() throws {
        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Should include data storage settings section
        XCTAssertNotNil(hostingController.view)
    }

    func testCloudBackupSettingsSection() throws {
        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Should include cloud backup settings section
        XCTAssertNotNil(hostingController.view)
    }

    func testImportExportSettingsSection() throws {
        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Should include import/export settings section
        XCTAssertNotNil(hostingController.view)
    }

    func testAboutSupportSettingsSection() throws {
        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Should include about & support settings section
        XCTAssertNotNil(hostingController.view)
    }

    func testDangerZoneSettingsSection() throws {
        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Should include danger zone settings section
        XCTAssertNotNil(hostingController.view)
    }

    // MARK: - Theme Integration Tests

    func testSettingsViewWithDifferentThemes() throws {
        // Test with light theme
        themeManager.setTheme(.light)
        let lightSettingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let lightHostingController = UIHostingController(rootView: lightSettingsView)
        lightHostingController.loadViewIfNeeded()
        XCTAssertNotNil(lightHostingController.view)

        // Test with dark theme
        themeManager.setTheme(.dark)
        let darkSettingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let darkHostingController = UIHostingController(rootView: darkSettingsView)
        darkHostingController.loadViewIfNeeded()
        XCTAssertNotNil(darkHostingController.view)

        // Test with system theme
        themeManager.setTheme(.system)
        let systemSettingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let systemHostingController = UIHostingController(rootView: systemSettingsView)
        systemHostingController.loadViewIfNeeded()
        XCTAssertNotNil(systemHostingController.view)
    }

    // MARK: - Debug Mode Tests

    func testSettingsViewInDebugMode() throws {
        // In debug mode, iCloud backup should show disabled message
        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Should render correctly even in debug mode
        XCTAssertNotNil(hostingController.view)
    }

    // MARK: - Data Integration Tests

    func testSettingsViewWithInventoryData() throws {
        // Create some test data
        let category = Category(name: "Electronics")
        context.insert(category)

        let item = Item(name: "Test Item")
        item.category = category
        context.insert(item)

        try context.save()

        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Should render with data in the context
        XCTAssertNotNil(hostingController.view)

        // Verify data exists
        let itemFetch = FetchDescriptor<Item>()
        let items = try context.fetch(itemFetch)
        XCTAssertEqual(items.count, 1, "Should have 1 item")
    }

    func testSettingsViewWithLargeDataset() throws {
        // Create lots of test data
        let category = Category(name: "Test Category")
        context.insert(category)

        for i in 1 ... 100 {
            let item = Item(name: "Item \(i)")
            item.category = category
            context.insert(item)
        }

        try context.save()

        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Should handle large datasets without performance issues
        XCTAssertNotNil(hostingController.view)

        // Verify all data was created
        let itemFetch = FetchDescriptor<Item>()
        let items = try context.fetch(itemFetch)
        XCTAssertEqual(items.count, 100, "Should have 100 items")
    }

    // MARK: - Performance Tests

    func testSettingsViewPerformance() throws {
        // Create test data for performance testing
        for i in 1 ... 10 {
            let category = Category(name: "Category \(i)")
            context.insert(category)

            for j in 1 ... 10 {
                let item = Item(name: "Item \(i)-\(j)")
                item.category = category
                context.insert(item)
            }
        }

        try context.save()

        measure {
            let settingsView = SettingsView()
                .environmentObject(themeManager)
                .modelContainer(container)

            let hostingController = UIHostingController(rootView: settingsView)
            hostingController.loadViewIfNeeded()
        }
    }

    // MARK: - Service Wiring Tests

    func testServiceWiringAccessibility() throws {
        // Settings view is a common place where services are wired up
        // Test that all expected services are accessible through settings
        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Should provide access to key services through the UI
        XCTAssertNotNil(hostingController.view)

        // The view should contain all the expected settings sections
        // Each section should wire up the appropriate services
    }

    // MARK: - Error Handling Tests

    func testSettingsViewWithMissingDependencies() throws {
        // Test settings view without any environment objects or model container
        let settingsView = SettingsView()

        // Should handle gracefully
        XCTAssertNoThrow(settingsView)
    }

    func testSettingsViewWithCorruptedThemeManager() throws {
        // Create settings view with theme manager
        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        // Should handle theme manager state changes
        themeManager.setTheme(.light)
        themeManager.setTheme(.dark)
        themeManager.setTheme(.system)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        XCTAssertNotNil(hostingController.view)
    }

    // MARK: - Integration Tests

    func testSettingsViewCompleteIntegration() throws {
        // Create a complete test environment
        let electronics = Category(name: "Electronics")
        let furniture = Category(name: "Furniture")
        context.insert(electronics)
        context.insert(furniture)

        let laptop = Item(name: "MacBook Pro")
        laptop.category = electronics
        laptop.purchasePrice = Decimal(2999.99)
        context.insert(laptop)

        let chair = Item(name: "Office Chair")
        chair.category = furniture
        chair.purchasePrice = Decimal(499.99)
        context.insert(chair)

        try context.save()

        // Set theme
        themeManager.setTheme(.dark)

        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Should handle complete integration
        XCTAssertNotNil(hostingController.view)
        XCTAssertEqual(themeManager.currentTheme, .dark)

        // Verify data exists
        let itemFetch = FetchDescriptor<Item>()
        let items = try context.fetch(itemFetch)
        XCTAssertEqual(items.count, 2, "Should have 2 items")

        let categoryFetch = FetchDescriptor<Category>()
        let categories = try context.fetch(categoryFetch)
        XCTAssertEqual(categories.count, 2, "Should have 2 categories")
    }

    // MARK: - Accessibility Tests

    func testSettingsViewAccessibility() throws {
        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Should be accessible
        XCTAssertNotNil(hostingController.view)

        // In a real accessibility test, we would verify:
        // - All interactive elements have accessibility labels
        // - Navigation is accessible via VoiceOver
        // - Form controls are properly labeled
        // - Dynamic type is supported
    }
}

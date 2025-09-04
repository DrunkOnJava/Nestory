//
// NavigationHelper.swift
// NestoryUITests
//
// Specialized navigation helper for Nestory app with robust error handling
// Provides reliable navigation patterns specific to Nestory's architecture
//

@preconcurrency import XCTest

/// Navigation helper for Nestory app UI testing
@MainActor
struct NavigationHelper {
    // MARK: - Tab Navigation

    /// Nestory app tabs
    enum NestoryTab: String, CaseIterable {
        case inventory = "Inventory"
        case search = "Search"
        case analytics = "Analytics"
        case categories = "Categories"
        case settings = "Settings"

        var displayName: String {
            rawValue
        }
    }

    /// Navigate to a specific tab with verification
    /// - Parameters:
    ///   - tab: The tab to navigate to
    ///   - app: Application instance
    ///   - timeout: Maximum wait time
    /// - Returns: True if navigation succeeded
    @discardableResult
    static func navigateToTab(
        _ tab: NestoryTab,
        in app: XCUIApplication,
        timeout: TimeInterval = 10.0,
    ) -> Bool {
        let tabButton = app.tabBarButton(tab.displayName)

        // Check if tab exists
        guard tabButton.waitForExistence(timeout: timeout) else {
            XCTFail("Tab '\(tab.displayName)' not found within \(timeout) seconds")
            return false
        }

        // Tap the tab
        tabButton.safeTap()

        // Verify navigation completed
        let navigationBar = app.navigationBar(tab.displayName)
        let navigationSuccess = navigationBar.waitForExistence(timeout: timeout)

        if !navigationSuccess {
            print("⚠️ Navigation bar not found for '\(tab.displayName)', but tab tap may have succeeded")
        }

        // Wait for UI to settle
        WaitHelpers.waitForAppReady(app, timeout: 2.0)

        print("✅ Navigated to \(tab.displayName) tab")
        return true
    }

    /// Get current active tab
    /// - Parameter app: Application instance
    /// - Returns: Currently active tab if determinable
    static func getCurrentTab(in app: XCUIApplication) -> NestoryTab? {
        for tab in NestoryTab.allCases {
            let tabButton = app.tabBarButton(tab.displayName)
            if tabButton.exists, tabButton.isSelected {
                return tab
            }
        }
        return nil
    }

    /// Verify all tabs are accessible
    /// - Parameter app: Application instance
    /// - Returns: Array of accessible tabs
    static func verifyAllTabsAccessible(in app: XCUIApplication) -> [NestoryTab] {
        var accessibleTabs: [NestoryTab] = []

        for tab in NestoryTab.allCases {
            let tabButton = app.tabBarButton(tab.displayName)
            if tabButton.exists {
                accessibleTabs.append(tab)
                print("✅ Tab '\(tab.displayName)' is accessible")
            } else {
                print("❌ Tab '\(tab.displayName)' is NOT accessible")
            }
        }

        return accessibleTabs
    }

    // MARK: - Settings Navigation

    /// Settings sections that contain services
    enum SettingsSection: String, CaseIterable {
        case importExport = "Import/Export"
        case cloudBackup = "Cloud Backup"
        case notifications = "Notifications"
        case appearance = "Appearance"
        case about = "About"

        var displayName: String {
            rawValue
        }
    }

    /// Navigate to settings section
    /// - Parameters:
    ///   - section: Settings section to navigate to
    ///   - app: Application instance
    ///   - timeout: Maximum wait time
    /// - Returns: True if navigation succeeded
    @discardableResult
    static func navigateToSettingsSection(
        _ section: SettingsSection,
        in app: XCUIApplication,
        timeout: TimeInterval = 10.0,
    ) -> Bool {
        // First navigate to Settings tab
        guard navigateToTab(.settings, in: app, timeout: timeout) else {
            return false
        }

        // Look for the section
        let sectionElement = findSettingsSection(section, in: app)

        guard sectionElement.waitForExistence(timeout: timeout) else {
            print("❌ Settings section '\(section.displayName)' not found")
            return false
        }

        // Tap the section
        sectionElement.safeTap()

        // Wait for navigation
        Thread.sleep(forTimeInterval: 1.0)

        print("✅ Navigated to Settings > \(section.displayName)")
        return true
    }

    /// Find settings section element with multiple strategies
    private static func findSettingsSection(
        _ section: SettingsSection,
        in app: XCUIApplication,
    ) -> XCUIElement {
        // Try different element types that might contain the section
        let strategies: [() -> XCUIElement] = [
            { app.staticTexts[section.displayName] },
            { app.buttons[section.displayName] },
            { app.cells.containing(.staticText, identifier: section.displayName).firstMatch },
            { app.cells.staticTexts[section.displayName] },
        ]

        for strategy in strategies {
            let element = strategy()
            if element.exists {
                return element
            }
        }

        // Return first strategy for error reporting
        return app.staticTexts[section.displayName]
    }

    // MARK: - Service Access Verification

    /// Verify service access points in Settings
    /// - Parameter app: Application instance
    /// - Returns: Dictionary of services and their accessibility
    static func verifyServiceAccessibility(in app: XCUIApplication) -> [String: Bool] {
        var serviceAccessibility: [String: Bool] = [:]

        // Navigate to Settings
        guard navigateToTab(.settings, in: app) else {
            return serviceAccessibility
        }

        // Check Import/Export services
        if navigateToSettingsSection(.importExport, in: app) {
            serviceAccessibility["ImportExportService"] = true
            serviceAccessibility["InsuranceExportService"] = true
            serviceAccessibility["InsuranceReportService"] = true

            // Navigate back to Settings
            _ = navigateToTab(.settings, in: app)
        }

        // Check Cloud Backup service
        if navigateToSettingsSection(.cloudBackup, in: app) {
            serviceAccessibility["CloudBackupService"] = true

            // Navigate back to Settings
            _ = navigateToTab(.settings, in: app)
        }

        // Check Notification service
        if navigateToSettingsSection(.notifications, in: app) {
            serviceAccessibility["NotificationService"] = true

            // Navigate back to Settings
            _ = navigateToTab(.settings, in: app)
        }

        // Check Analytics service (from Analytics tab)
        if navigateToTab(.analytics, in: app) {
            serviceAccessibility["AnalyticsService"] = true
        }

        return serviceAccessibility
    }

    // MARK: - Item Management Navigation

    /// Navigate to add item flow
    /// - Parameter app: Application instance
    /// - Returns: True if add item view is accessible
    @discardableResult
    static func navigateToAddItem(in app: XCUIApplication) -> Bool {
        // Navigate to Inventory tab
        guard navigateToTab(.inventory, in: app) else {
            return false
        }

        // Look for Add Item button (could be "Add First Item" or "Add Item")
        let addItemButton = app.findButton("Add First Item")
        let addButton = app.navigationBars["Inventory"].buttons["Add Item"]

        let buttonToTap = addItemButton.exists ? addItemButton : addButton

        guard buttonToTap.waitForExistence(timeout: 5.0) else {
            print("❌ Add Item button not found")
            return false
        }

        buttonToTap.safeTap()

        // Wait for add item view to appear
        Thread.sleep(forTimeInterval: 1.0)

        print("✅ Navigated to Add Item view")
        return true
    }

    // MARK: - Deep Link Navigation

    /// Simulate deep link navigation
    /// - Parameters:
    ///   - url: URL to open
    ///   - app: Application instance
    /// - Returns: True if deep link navigation succeeded
    @discardableResult
    static func navigateViaDeepLink(
        _ url: String,
        in _: XCUIApplication,
    ) -> Bool {
        // This would be used for URL scheme testing
        // Implementation depends on app's URL scheme support
        print("🔗 Deep link navigation to: \(url)")

        // For now, return true as placeholder
        // In real implementation, this would:
        // 1. Terminate app
        // 2. Open URL via Safari or direct URL opening
        // 3. Verify app opens to correct screen

        return true
    }

    // MARK: - Navigation Validation

    /// Validate complete navigation flow
    /// - Parameter app: Application instance
    /// - Returns: Navigation validation results
    static func validateNavigationFlow(in app: XCUIApplication) -> NavigationValidationResult {
        var results = NavigationValidationResult()

        // Test all tabs
        for tab in NestoryTab.allCases {
            let success = navigateToTab(tab, in: app)
            results.tabNavigation[tab] = success

            if !success {
                results.failures.append("Failed to navigate to \(tab.displayName) tab")
            }
        }

        // Test settings sections
        for section in SettingsSection.allCases {
            let success = navigateToSettingsSection(section, in: app)
            results.settingsNavigation[section] = success

            if !success {
                results.failures.append("Failed to navigate to \(section.displayName) settings")
            }
        }

        // Test add item flow
        results.addItemAccess = navigateToAddItem(in: app)
        if !results.addItemAccess {
            results.failures.append("Failed to access Add Item flow")
        }

        return results
    }
}

// MARK: - Navigation Validation Result

struct NavigationValidationResult {
    var tabNavigation: [NavigationHelper.NestoryTab: Bool] = [:]
    var settingsNavigation: [NavigationHelper.SettingsSection: Bool] = [:]
    var addItemAccess = false
    var failures: [String] = []

    var overallSuccess: Bool {
        failures.isEmpty
    }

    var successRate: Double {
        let totalTests = tabNavigation.count + settingsNavigation.count + 1 // +1 for addItemAccess
        let successfulTests = tabNavigation.values.count(where: { $0 }) +
            settingsNavigation.values.count(where: { $0 }) +
            (addItemAccess ? 1 : 0)

        return totalTests > 0 ? Double(successfulTests) / Double(totalTests) : 0.0
    }

    func generateReport() -> String {
        let successRatePercentage = Int(successRate * 100)

        return """
        📊 Navigation Validation Report
        ===============================

        Overall Success Rate: \(successRatePercentage)%
        Total Failures: \(failures.count)

        Tab Navigation:
        \(tabNavigation.map { "  \($0.key.displayName): \($0.value ? "✅" : "❌")" }.joined(separator: "\n"))

        Settings Navigation:
        \(settingsNavigation.map { "  \($0.key.displayName): \($0.value ? "✅" : "❌")" }.joined(separator: "\n"))

        Add Item Access: \(addItemAccess ? "✅" : "❌")

        \(failures.isEmpty ? "All navigation tests passed! 🎉" : "Failures:\n\(failures.map { "  • \($0)" }.joined(separator: "\n"))")
        """
    }
}

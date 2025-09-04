//
// DeterministicScreenshotTest.swift
// NestoryUITests
//
// Deterministic screenshot capture using Screen Registry
//

@preconcurrency import XCTest

@MainActor
final class DeterministicScreenshotTest: XCTestCase {
    
    var app: XCUIApplication?
    
    /// Safe access to the app instance with proper error handling
    private var safeApp: XCUIApplication {
        guard let app = app else {
            XCTFail("XCUIApplication is nil. Ensure setUp() has been called and completed successfully.")
            // Return a new instance as fallback to prevent further crashes
            return XCUIApplication()
        }
        return app
    }
    
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        
        // Configure for deterministic testing
        safeApp.launchArguments = [
            "UITEST_MODE",
            "DISABLE_ANIMATIONS",
            "USE_TEST_FIXTURES",
            "BYPASS_AUTH",
            "FREEZE_TIME",
            "AUTO_ACCEPT_PERMISSIONS",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
        
        safeApp.launchEnvironment = [
            "UI_TESTING": "1",
            "VERBOSE_LOGGING": "1"
        ]
    }
    
    override func tearDown() async throws {
        app = nil
        try await super.tearDown()
    }
    
    // MARK: - Single Route Test
    
    func testSingleRouteSnapshot() async throws {
        // Launch with specific target route
        safeApp.launchEnvironment["UITEST_TARGET_ROUTE"] = "inventory"
        safeApp.launch()
        
        // Wait for app to stabilize
        let exists = safeApp.wait(for: .runningForeground, timeout: 10)
        XCTAssertTrue(exists, "App should be running")
        
        // Wait for the inventory screen
        let inventoryView = safeApp.otherElements["screen_inventory"]
        XCTAssertTrue(inventoryView.waitForExistence(timeout: 5), "Inventory screen should appear")
        
        // Wait for any loading to complete
        await waitForIdle()
        
        // Capture screenshot
        let screenshot = safeApp.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "inventory_base"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        print("✅ Captured: inventory_base")
    }
    
    // MARK: - Multi-Route Test
    
    func testMultiRouteSnapshots() async throws {
        // Define routes to capture
        let routes = [
            "inventory",
            "search",
            "capture",
            "analytics",
            "settings"
        ]
        
        for route in routes {
            await captureRoute(route)
        }
        
        print("✅ Captured \(routes.count) route screenshots")
    }
    
    // MARK: - Full Catalog Test
    
    func testCompleteScreenCatalog() async throws {
        safeApp.launch()
        
        // Wait for app
        XCTAssertTrue(safeApp.wait(for: .runningForeground, timeout: 10))
        
        // Capture main tabs
        let tabs = [
            (index: 0, route: "inventory"),
            (index: 1, route: "search"),
            (index: 2, route: "capture"),
            (index: 3, route: "analytics"),
            (index: 4, route: "settings")
        ]
        
        for tab in tabs {
            await navigateToTab(at: tab.index)
            await waitForIdle()
            captureScreenshot(name: "tab_\(tab.route)")
        }
        
        // Capture settings sub-screens
        await captureSettingsScreens()
        
        print("✅ Complete catalog captured")
    }
    
    // MARK: - Helper Methods
    
    private func captureRoute(_ route: String) async {
        // Relaunch with target route
        safeApp.terminate()
        safeApp.launchEnvironment["UITEST_TARGET_ROUTE"] = route
        safeApp.launch()
        
        // Wait for app
        XCTAssertTrue(safeApp.wait(for: .runningForeground, timeout: 10))
        
        // Wait for target screen
        let targetScreen = safeApp.otherElements["screen_\(route)"]
        XCTAssertTrue(targetScreen.waitForExistence(timeout: 5), "\(route) screen should appear")
        
        // Wait for idle
        await waitForIdle()
        
        // Capture
        captureScreenshot(name: route)
    }
    
    private func navigateToTab(at index: Int) async {
        let tabBar = safeApp.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        let button = tabBar.buttons.element(boundBy: index)
        XCTAssertTrue(button.exists && button.isHittable)
        
        button.tap()
        
        // Verify selection
        let isSelected = button.isSelected || button.value as? String == "1"
        XCTAssertTrue(isSelected, "Tab \(index) should be selected")
    }
    
    private func captureSettingsScreens() async {
        // Navigate to Settings tab
        await navigateToTab(at: 4)
        await waitForIdle()
        
        // Capture main settings
        captureScreenshot(name: "settings_main")
        
        // Navigate to Import/Export
        let importExportButton = safeApp.buttons["Import/Export"]
        if importExportButton.exists && importExportButton.isHittable {
            importExportButton.tap()
            await waitForIdle()
            captureScreenshot(name: "settings_import_export")
            
            // Go back
            safeApp.navigationBars.buttons.element(boundBy: 0).tap()
            await waitForIdle()
        }
        
        // Navigate to Appearance
        let appearanceButton = safeApp.buttons["Appearance"]
        if appearanceButton.exists && appearanceButton.isHittable {
            appearanceButton.tap()
            await waitForIdle()
            captureScreenshot(name: "settings_appearance")
            
            // Go back
            safeApp.navigationBars.buttons.element(boundBy: 0).tap()
            await waitForIdle()
        }
        
        // Navigate to About
        let aboutButton = safeApp.buttons["About"]
        if aboutButton.exists && aboutButton.isHittable {
            aboutButton.tap()
            await waitForIdle()
            captureScreenshot(name: "settings_about")
        }
    }
    
    private func waitForIdle() async {
        // Wait for any activity indicators to disappear
        let indicators = safeApp.activityIndicators
        let deadline = Date().addingTimeInterval(5)
        
        while Date() < deadline {
            var hasActivity = false
            for i in 0..<indicators.count {
                if indicators.element(boundBy: i).exists {
                    hasActivity = true
                    break
                }
            }
            
            if !hasActivity {
                break
            }
            
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        }
        
        // Additional stabilization time
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
    }
    
    @discardableResult
    private func captureScreenshot(name: String) -> XCTAttachment {
        let screenshot = safeApp.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        
        print("📸 Captured: \(name)")
        
        return attachment
    }
}
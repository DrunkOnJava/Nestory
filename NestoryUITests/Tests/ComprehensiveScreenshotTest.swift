//
// ComprehensiveScreenshotTest.swift
// NestoryUITests
//
// Deterministic screenshot capture with structured logging and robust assertions
//

import XCTest

final class ComprehensiveScreenshotTest: XCTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    @MainActor
    func testCompleteAppScreenshotCatalog() async throws {
        let app = XCUIApplication()
        app.launchArguments += [
            "UITEST_MODE",
            "UITEST_START_TAB=inventory",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launchEnvironment["DISABLE_ANIMATIONS"] = "1"
        
        app.launch()
        
        // Wait for app to stabilize
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "Tab bar should appear")

        let tabs = [
            (index: 0, name: "Inventory", identifier: "InventoryView"),
            (index: 1, name: "Search", identifier: "SearchView"),
            (index: 2, name: "Capture", identifier: "CaptureView"),
            (index: 3, name: "Analytics", identifier: "AnalyticsView"),
            (index: 4, name: "Settings", identifier: "SettingsView")
        ]

        var captured: [String] = []

        for tab in tabs {
            await step("Navigate → \(tab.name)") { 
                navigateToTab(app: app, at: tab.index) 
            }
            
            await step("Content ready → \(tab.name)") {
                let view = app.otherElements[tab.identifier]
                XCTAssertTrue(waitForElement(view), "\(tab.name) view not loaded")
            }
            
            await step("Screenshot → \(tab.name)") {
                let name = "Tab\(tab.index)_\(tab.name)_\(Int(Date().timeIntervalSince1970))"
                captureScreenshot(app: app, name: name)
                captured.append(name)
                print("📸 Captured: \(name)")
            }
        }
        
        // Test Settings subsections if needed
        await step("Settings integrations") {
            testSettingsIntegrations(app: app)
        }

        XCTAssertEqual(captured.count, 5, "Should have captured 5 tab screenshots")
        print("✅ All screenshots captured successfully")
    }

    // MARK: - Helpers

    @MainActor
    private func step(_ name: String, _ block: () -> Void) async {
        await XCTContext.runActivity(named: name) { _ in 
            block() 
        }
    }

    @MainActor
    private func navigateToTab(app: XCUIApplication, at index: Int) {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar must exist")

        let button = tabBar.buttons.element(boundBy: index)
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Tab button at index \(index) must exist")
        XCTAssertTrue(button.isHittable, "Tab button at index \(index) must be hittable")

        button.tap()
        XCTAssertTrue(button.waitUntilSelected(timeout: 4),
                      "Tab \(index) should be selected after tap")
    }

    @MainActor
    @discardableResult
    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5.0) -> Bool {
        let pred = NSPredicate(format: "exists == true AND isHittable == true")
        let exp = XCTNSPredicateExpectation(predicate: pred, object: element)
        let res = XCTWaiter().wait(for: [exp], timeout: timeout)
        if res != .completed { 
            XCTFail("Element not ready in \(timeout)s: \(element.debugDescription)") 
        }
        return res == .completed
    }

    @MainActor
    private func captureScreenshot(app: XCUIApplication, name: String,
                                   lifetime: XCTAttachment.Lifetime = .keepAlways) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = lifetime
        add(attachment)
    }
    
    @MainActor
    private func waitForLoadingToComplete(app: XCUIApplication) {
        // Check for specific loading indicator first
        if app.activityIndicators["LoadingIndicator"].exists {
            _ = app.activityIndicators["LoadingIndicator"].waitForNonExistence(timeout: 10)
        }
        
        // Global spinner fallback with run-loop poll
        let deadline = Date().addingTimeInterval(10)
        while Date() < deadline {
            // Exit when no activity indicators exist
            if app.activityIndicators.allElementsBoundByIndex.first(where: { $0.exists }) == nil { 
                return 
            }
            _ = RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.05))
        }
    }
    
    // MARK: - Settings Integration Testing
    
    @MainActor
    private func testSettingsIntegrations(app: XCUIApplication) {
        print("⚙️ Testing Settings integrations...")
        
        // Already on Settings tab from previous navigation
        
        // Look for Insurance & Claims sections
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp() // Scroll to see more options
            
            // Wait for scroll to settle
            Thread.sleep(forTimeInterval: 0.5)
            captureScreenshot(app: app, name: "Settings_Scrolled_\(Int(Date().timeIntervalSince1970))")
        }
        
        // Try to find and tap Insurance-related cells
        let cells = app.tables.cells
        var insuranceScreenshotCount = 0
        
        for i in 0..<min(cells.count, 10) {
            let cell = cells.element(boundBy: i)
            if cell.exists {
                // Get all static texts in the cell to check for keywords
                let texts = cell.staticTexts.allElementsBoundByIndex
                for text in texts {
                    if text.exists {
                        let label = text.label
                        if label.contains("Claims") || label.contains("Insurance") || label.contains("Warranty") {
                            print("Found insurance-related cell: \(label)")
                            cell.tap()
                            
                            // Wait for navigation
                            Thread.sleep(forTimeInterval: 1.0)
                            
                            let screenshotName = "Insurance_\(label.replacingOccurrences(of: " ", with: "_"))_\(Int(Date().timeIntervalSince1970))"
                            captureScreenshot(app: app, name: screenshotName)
                            insuranceScreenshotCount += 1
                            
                            // Navigate back
                            navigateBack(app: app)
                            Thread.sleep(forTimeInterval: 0.5)
                            break // Only process first matching text in cell
                        }
                    }
                }
            }
        }
        
        if insuranceScreenshotCount > 0 {
            print("📸 Captured \(insuranceScreenshotCount) insurance-related screenshots")
        }
    }
    
    @MainActor
    private func navigateBack(app: XCUIApplication) {
        // Try navigation bar first button (usually back)
        if app.navigationBars.firstMatch.buttons.firstMatch.exists {
            app.navigationBars.firstMatch.buttons.firstMatch.tap()
        } else {
            // Fallback to edge swipe for navigation
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.5))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.6, dy: 0.5))
            start.press(forDuration: 0.05, thenDragTo: end)
        }
    }
}

// MARK: - XCUIElement Extensions

// Extensions removed - using framework extensions instead
//
//  SimpleScreenshotTests.swift
//  NestoryUITests
//
//  Created by Assistant on 8/9/25.
//

import XCTest

@MainActor
final class SimpleScreenshotTests: XCTestCase {
    var app: XCUIApplication!
    var screenshotCount = 0

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testTakeAppScreenshots() throws {
        // 1. Inventory Tab (default)
        takeScreenshot("01_Inventory")

        // 2. Add Item Sheet
        app.navigationBars["Inventory"].buttons["Add Item"].tap()
        sleep(1)
        takeScreenshot("02_AddItem")

        // Cancel add item
        app.navigationBars.buttons["Cancel"].tap()
        sleep(1)

        // 3. Search Tab
        app.tabBars.buttons["Search"].tap()
        sleep(1)
        takeScreenshot("03_Search")

        // 4. Categories Tab
        app.tabBars.buttons["Categories"].tap()
        sleep(1)
        takeScreenshot("04_Categories")

        // 5. Settings Tab (Light Mode)
        app.tabBars.buttons["Settings"].tap()
        sleep(1)
        takeScreenshot("05_Settings_Light")

        // 6. Toggle Dark Mode
        // Disable system theme
        let systemToggle = app.switches.element(boundBy: 0)
        if systemToggle.exists {
            systemToggle.tap()
            sleep(1)
        }

        // Enable dark mode
        let darkToggle = app.switches.element(boundBy: 1)
        if darkToggle.exists {
            darkToggle.tap()
            sleep(2)
        }

        takeScreenshot("06_Settings_Dark")

        // 7. Inventory in Dark Mode
        app.tabBars.buttons["Inventory"].tap()
        sleep(1)
        takeScreenshot("07_Inventory_Dark")

        // 8. Categories in Dark Mode
        app.tabBars.buttons["Categories"].tap()
        sleep(1)
        takeScreenshot("08_Categories_Dark")

        print("✅ Screenshots captured successfully!")
    }

    private func takeScreenshot(_ name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        screenshotCount += 1
        print("📸 Screenshot \(screenshotCount): \(name)")
    }
}

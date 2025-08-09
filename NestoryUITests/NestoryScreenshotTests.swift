//
//  NestoryScreenshotTests.swift
//  NestoryUITests
//
//  Created by Assistant on 8/9/25.
//

import XCTest

final class NestoryScreenshotTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        setupSnapshot(app)
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testCaptureAllScreenshots() throws {
        // Wait for app to fully launch
        sleep(2)

        // Test 1: Inventory List View (Main Screen)
        captureScreenshot(name: "01_InventoryList")

        // Test 2: Add Item View
        let addButton = app.navigationBars["Inventory"].buttons["Add Item"]
        if addButton.waitForExistence(timeout: 5) {
            addButton.tap()
            sleep(1)
            captureScreenshot(name: "02_AddItem")

            // Fill in some sample data
            let itemNameField = app.textFields["Item Name"]
            if itemNameField.exists {
                itemNameField.tap()
                itemNameField.typeText("Sample Item")
            }

            let descriptionField = app.textViews.firstMatch
            if descriptionField.exists {
                descriptionField.tap()
                descriptionField.typeText("This is a sample item description")
            }

            captureScreenshot(name: "03_AddItemFilled")

            // Cancel to go back
            app.navigationBars.buttons["Cancel"].tap()
            sleep(1)
        }

        // Test 3: Search View
        app.tabBars.buttons["Search"].tap()
        sleep(1)
        captureScreenshot(name: "04_SearchView")

        // Test search functionality
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("Test Search")
            captureScreenshot(name: "05_SearchActive")

            // Clear search
            let clearButton = app.buttons["Clear text"].firstMatch
            if clearButton.exists {
                clearButton.tap()
            }
        }

        // Test 4: Categories View
        app.tabBars.buttons["Categories"].tap()
        sleep(1)
        captureScreenshot(name: "06_CategoriesGrid")

        // Test 5: Settings View
        app.tabBars.buttons["Settings"].tap()
        sleep(1)
        captureScreenshot(name: "07_Settings")

        // Test 6: Dark Mode Toggle
        let darkModeSection = app.tables.cells.containing(.staticText, identifier: "Use System Theme").firstMatch
        if darkModeSection.exists {
            // Disable system theme
            let systemThemeToggle = app.switches["Use System Theme"].firstMatch
            if systemThemeToggle.exists, systemThemeToggle.value as? String == "1" {
                systemThemeToggle.tap()
                sleep(1)
            }

            // Enable dark mode
            let darkModeToggle = app.switches["Dark Mode"].firstMatch
            if darkModeToggle.exists {
                darkModeToggle.tap()
                sleep(2)
                captureScreenshot(name: "08_SettingsDarkMode")
            }
        }

        // Test 7: Export View
        let exportButton = app.tables.cells.containing(.staticText, identifier: "Export Data").firstMatch
        if exportButton.exists {
            exportButton.tap()
            sleep(1)
            captureScreenshot(name: "09_ExportOptions")
            app.navigationBars.buttons["Done"].tap()
            sleep(1)
        }

        // Test 8: About View
        let aboutButton = app.tables.cells.containing(.staticText, identifier: "About Nestory").firstMatch
        if aboutButton.exists {
            aboutButton.tap()
            sleep(1)
            captureScreenshot(name: "10_AboutScreen")
            app.navigationBars.buttons["Done"].tap()
            sleep(1)
        }

        // Test 9: Categories in Dark Mode
        app.tabBars.buttons["Categories"].tap()
        sleep(1)
        captureScreenshot(name: "11_CategoriesDarkMode")

        // Test 10: Inventory in Dark Mode
        app.tabBars.buttons["Inventory"].tap()
        sleep(1)
        captureScreenshot(name: "12_InventoryDarkMode")
    }

    func testLightModeScreenshots() throws {
        // Ensure light mode
        app.tabBars.buttons["Settings"].tap()
        sleep(1)

        let systemThemeToggle = app.switches["Use System Theme"].firstMatch
        if systemThemeToggle.exists, systemThemeToggle.value as? String == "1" {
            systemThemeToggle.tap()
            sleep(1)
        }

        let darkModeToggle = app.switches["Dark Mode"].firstMatch
        if darkModeToggle.exists, darkModeToggle.value as? String == "1" {
            darkModeToggle.tap()
            sleep(2)
        }

        // Capture light mode screenshots
        app.tabBars.buttons["Inventory"].tap()
        captureScreenshot(name: "Light_01_Inventory")

        app.tabBars.buttons["Search"].tap()
        captureScreenshot(name: "Light_02_Search")

        app.tabBars.buttons["Categories"].tap()
        captureScreenshot(name: "Light_03_Categories")

        app.tabBars.buttons["Settings"].tap()
        captureScreenshot(name: "Light_04_Settings")
    }

    func testDarkModeScreenshots() throws {
        // Ensure dark mode
        app.tabBars.buttons["Settings"].tap()
        sleep(1)

        let systemThemeToggle = app.switches["Use System Theme"].firstMatch
        if systemThemeToggle.exists, systemThemeToggle.value as? String == "1" {
            systemThemeToggle.tap()
            sleep(1)
        }

        let darkModeToggle = app.switches["Dark Mode"].firstMatch
        if darkModeToggle.exists, darkModeToggle.value as? String == "0" {
            darkModeToggle.tap()
            sleep(2)
        }

        // Capture dark mode screenshots
        app.tabBars.buttons["Inventory"].tap()
        captureScreenshot(name: "Dark_01_Inventory")

        app.tabBars.buttons["Search"].tap()
        captureScreenshot(name: "Dark_02_Search")

        app.tabBars.buttons["Categories"].tap()
        captureScreenshot(name: "Dark_03_Categories")

        app.tabBars.buttons["Settings"].tap()
        captureScreenshot(name: "Dark_04_Settings")
    }

    // MARK: - Helper Methods

    private func captureScreenshot(name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        // Also save to disk if needed
        saveScreenshotToDisk(screenshot: screenshot, name: name)
    }

    private func saveScreenshotToDisk(screenshot: XCUIScreenshot, name: String) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let screenshotPath = documentsPath.appendingPathComponent("Screenshots")

        // Create Screenshots directory if it doesn't exist
        try? FileManager.default.createDirectory(at: screenshotPath, withIntermediateDirectories: true)

        let fileName = "\(name)_\(Date().timeIntervalSince1970).png"
        let fileURL = screenshotPath.appendingPathComponent(fileName)

        try? screenshot.pngRepresentation.write(to: fileURL)
        print("Screenshot saved to: \(fileURL.path)")
    }

    private func setupSnapshot(_ app: XCUIApplication) {
        // Setup for Fastlane snapshot if available
        if CommandLine.arguments.contains("SNAPSHOT") {
            app.launchArguments.append("SNAPSHOT")
        }
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    func clearAndTypeText(_ text: String) {
        guard let stringValue = value as? String else {
            XCTFail("Tried to clear and type text into a non string value")
            return
        }

        tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
        typeText(text)
    }
}

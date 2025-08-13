//
//  NestoryDeviceScreenshotTests.swift
//  NestoryUITests
//
//  Created by Assistant on 8/9/25.
//

import XCTest

@MainActor
final class NestoryDeviceScreenshotTests: XCTestCase {
    var app: XCUIApplication!
    let helper = ScreenshotHelper.shared

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING_MODE", "SCREENSHOTS"]

        // Detect device and set appropriate launch arguments
        let device = XCUIDevice.shared
        if device.orientation != .portrait {
            device.orientation = .portrait
        }

        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Main Test Flow

    func testCaptureAllScreensForCurrentDevice() throws {
        let deviceName = UIDevice.current.name.replacingOccurrences(of: " ", with: "_")

        // Capture in Light Mode
        captureAllScreens(prefix: "\(deviceName)_Light")

        // Switch to Dark Mode
        switchToDarkMode()

        // Capture in Dark Mode
        captureAllScreens(prefix: "\(deviceName)_Dark")
    }

    // MARK: - Screenshot Capture Methods

    private func captureAllScreens(prefix: String) {
        // 1. Inventory Tab
        app.tabBars.buttons["Inventory"].tap()
        wait(1)
        helper.takeScreenshot(app: app, name: "\(prefix)_01_Inventory", testCase: self)

        // 2. Add Item
        if app.navigationBars["Inventory"].buttons["Add Item"].exists {
            app.navigationBars["Inventory"].buttons["Add Item"].tap()
            wait(1)
            helper.takeScreenshot(app: app, name: "\(prefix)_02_AddItem", testCase: self)

            // Fill form and capture
            fillSampleItemForm()
            helper.takeScreenshot(app: app, name: "\(prefix)_03_AddItemFilled", testCase: self)

            // Save item
            app.navigationBars.buttons["Save"].tap()
            wait(1)
        }

        // 3. Search Tab
        app.tabBars.buttons["Search"].tap()
        wait(1)
        helper.takeScreenshot(app: app, name: "\(prefix)_04_Search", testCase: self)

        // 4. Categories Tab
        app.tabBars.buttons["Categories"].tap()
        wait(1)
        helper.takeScreenshot(app: app, name: "\(prefix)_05_Categories", testCase: self)

        // 5. Settings Tab
        app.tabBars.buttons["Settings"].tap()
        wait(1)
        helper.takeScreenshot(app: app, name: "\(prefix)_06_Settings", testCase: self)

        // 6. Export Sheet
        let exportButton = app.tables.cells.staticTexts["Export Data"].firstMatch
        if exportButton.exists {
            exportButton.tap()
            wait(1)
            helper.takeScreenshot(app: app, name: "\(prefix)_07_Export", testCase: self)
            app.buttons["Done"].tap()
            wait(1)
        }

        // 7. About Screen
        let aboutButton = app.tables.cells.staticTexts["About Nestory"].firstMatch
        if aboutButton.exists {
            aboutButton.tap()
            wait(1)
            helper.takeScreenshot(app: app, name: "\(prefix)_08_About", testCase: self)
            app.buttons["Done"].tap()
            wait(1)
        }
    }

    private func fillSampleItemForm() {
        // Item Name
        let itemNameField = app.textFields["Item Name"]
        if itemNameField.exists {
            itemNameField.tap()
            itemNameField.typeText("Sample Product")
        }

        // Description
        let descriptionField = app.textViews.firstMatch
        if descriptionField.exists {
            descriptionField.tap()
            descriptionField.typeText("This is a detailed description of the sample product")
        }

        // Quantity
        if app.steppers.buttons["Increment"].exists {
            app.steppers.buttons["Increment"].tap()
            app.steppers.buttons["Increment"].tap()
        }

        // Location
        let locationField = app.textFields.element(matching: NSPredicate(format: "placeholderValue CONTAINS 'Location'"))
        if locationField.exists {
            locationField.tap()
            locationField.typeText("Living Room")
        }

        // Price
        let priceField = app.textFields["Purchase Price"]
        if priceField.exists {
            priceField.tap()
            priceField.typeText("99.99")
        }
    }

    private func switchToDarkMode() {
        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()
        wait(1)

        // Disable system theme
        let systemThemeSwitch = app.tables.switches.element(boundBy: 0)
        if systemThemeSwitch.exists, systemThemeSwitch.value as? String == "1" {
            systemThemeSwitch.tap()
            wait(1)
        }

        // Enable dark mode
        let darkModeSwitch = app.tables.switches.element(boundBy: 1)
        if darkModeSwitch.exists, darkModeSwitch.value as? String == "0" {
            darkModeSwitch.tap()
            wait(2)
        }
    }

    private func wait(_ seconds: Int) {
        sleep(UInt32(seconds))
    }
}

// MARK: - Multiple Device Tests

final class NestoryMultiDeviceScreenshotTests: XCTestCase {
    func testGenerateScreenshotsForAllDevices() throws {
        // This test is designed to be run multiple times with different simulators
        // Use Xcode's Test Plans or command line to run on different devices

        let test = NestoryDeviceScreenshotTests()
        try test.setUpWithError()
        try test.testCaptureAllScreensForCurrentDevice()
        try test.tearDownWithError()
    }
}

// MARK: - Screenshot Test Plan

class ScreenshotTestPlan {
    static let devices = [
        "iPhone 16 Pro Max",
        "iPhone 16 Pro",
        "iPhone 16",
        "iPhone 15 Pro Max",
        "iPhone 15 Pro",
        "iPhone SE (3rd generation)",
        "iPad Pro (13-inch)",
        "iPad Pro (11-inch)",
        "iPad Air",
        "iPad mini",
    ]

    static func printTestInstructions() {
        print("""

        ====================================
        SCREENSHOT TEST INSTRUCTIONS
        ====================================

        To capture screenshots for all devices, run the following commands:

        """)

        for device in devices {
            let escapedDevice = device.replacingOccurrences(of: " ", with: "\\ ").replacingOccurrences(of: "(", with: "\\(").replacingOccurrences(of: ")", with: "\\)")
            print("""
            xcodebuild test \\
                -project Nestory.xcodeproj \\
                -scheme Nestory \\
                -destination "platform=iOS Simulator,name=\(escapedDevice)" \\
                -only-testing:NestoryUITests/NestoryDeviceScreenshotTests/testCaptureAllScreensForCurrentDevice

            """)
        }

        print("""

        Screenshots will be saved to:
        ~/Documents/NestoryScreenshots/

        ====================================

        """)
    }
}

//
//  NestoryUIScreenshotFlow.swift
//  NestoryUITests
//
//  Created by Assistant on 8/9/25.
//

import XCTest

final class NestoryUIScreenshotFlow: XCTestCase {
    let app = XCUIApplication()
    let screenshotCounter = ScreenshotCounter()

    override func setUpWithError() throws {
        continueAfterFailure = false

        // Setup app for UI testing
        app.launchArguments = ["UI_TESTING_MODE", "CLEAR_DATA"]
        app.launchEnvironment = ["SCREENSHOTS": "YES"]

        // Launch the app
        app.launch()
    }

    override func tearDownWithError() throws {
        // Clean up
    }

    func testCompleteAppFlow() throws {
        // Wait for app to stabilize
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))

        // 1. Inventory List (Empty State)
        takeScreenshot("01_Inventory_Empty")

        // 2. Add First Item
        tapAddButton()
        takeScreenshot("02_Add_Item_Form")

        fillAddItemForm(
            name: "MacBook Pro",
            description: "16-inch M3 Max laptop for development work",
            quantity: 1,
            location: "Home Office",
            category: "Electronics",
            price: "3499.00",
            notes: "AppleCare+ until 2026"
        )
        takeScreenshot("03_Add_Item_Filled")

        saveItem()

        // 3. Inventory with Items
        addSampleItems()
        takeScreenshot("04_Inventory_With_Items")

        // 4. Item Detail View
        let firstItem = app.tables.cells.firstMatch
        if firstItem.exists {
            firstItem.tap()
            sleep(1)
            takeScreenshot("05_Item_Detail")
            app.navigationBars.buttons.element(boundBy: 0).tap() // Back button
        }

        // 5. Search Tab
        navigateToTab("Search")
        takeScreenshot("06_Search_Empty")

        performSearch("MacBook")
        takeScreenshot("07_Search_Results")

        // 6. Categories Tab
        navigateToTab("Categories")
        takeScreenshot("08_Categories_Grid")

        // Tap on Electronics category
        let electronicsCard = app.scrollViews.otherElements.buttons["Electronics"]
        if electronicsCard.exists {
            electronicsCard.tap()
            sleep(1)
            takeScreenshot("09_Category_Items")
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }

        // 7. Settings Tab
        navigateToTab("Settings")
        takeScreenshot("10_Settings_Light")

        // 8. Toggle Dark Mode
        toggleDarkMode()
        takeScreenshot("11_Settings_Dark")

        // 9. Dark Mode Screenshots
        navigateToTab("Inventory")
        takeScreenshot("12_Inventory_Dark")

        navigateToTab("Search")
        takeScreenshot("13_Search_Dark")

        navigateToTab("Categories")
        takeScreenshot("14_Categories_Dark")

        // 10. Export Options
        navigateToTab("Settings")
        tapExportData()
        takeScreenshot("15_Export_Options")
        dismissModal()

        // 11. About Screen
        tapAbout()
        takeScreenshot("16_About_Screen")
        dismissModal()
    }

    // MARK: - Helper Methods

    private func takeScreenshot(_ name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func navigateToTab(_ tabName: String) {
        app.tabBars.buttons[tabName].tap()
        sleep(1)
    }

    private func tapAddButton() {
        let addButton = app.navigationBars["Inventory"].buttons["Add Item"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        sleep(1)
    }

    private func fillAddItemForm(name: String, description: String, quantity: Int,
                                 location: String, category: String, price: String, notes: String)
    {
        // Fill in item name
        let nameField = app.textFields["Item Name"]
        if nameField.exists {
            nameField.tap()
            nameField.typeText(name)
        }

        // Fill in description
        let descField = app.textViews.element(boundBy: 0)
        if descField.exists {
            descField.tap()
            descField.typeText(description)
        }

        // Set quantity (stepper)
        for _ in 1 ..< quantity {
            app.steppers.buttons["Increment"].tap()
        }

        // Fill in location
        let locationField = app.textFields.containing(NSPredicate(format: "placeholderValue CONTAINS 'Location'")).firstMatch
        if locationField.exists {
            locationField.tap()
            locationField.typeText(location)
        }

        // Select category
        app.buttons[category].tap()

        // Fill in price
        let priceField = app.textFields["Purchase Price"]
        if priceField.exists {
            priceField.tap()
            priceField.typeText(price)
        }

        // Fill in notes
        let notesField = app.textViews.element(boundBy: 1)
        if notesField.exists {
            notesField.tap()
            notesField.typeText(notes)
        }
    }

    private func saveItem() {
        app.navigationBars.buttons["Save"].tap()
        sleep(1)
    }

    private func addSampleItems() {
        // Add more sample items for better screenshots
        let items = [
            ("iPhone 15 Pro", "Personal smartphone", "Bedroom", "Electronics"),
            ("Standing Desk", "Adjustable height desk", "Home Office", "Furniture"),
            ("Coffee Maker", "Espresso machine", "Kitchen", "Kitchen"),
            ("Running Shoes", "Nike Air Zoom", "Closet", "Clothing"),
            ("Tool Set", "120-piece mechanics tool set", "Garage", "Tools"),
        ]

        for item in items {
            tapAddButton()

            let nameField = app.textFields["Item Name"]
            if nameField.exists {
                nameField.tap()
                nameField.typeText(item.0)
            }

            let descField = app.textViews.element(boundBy: 0)
            if descField.exists {
                descField.tap()
                descField.typeText(item.1)
            }

            saveItem()
        }
    }

    private func performSearch(_ query: String) {
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText(query)
        }
    }

    private func toggleDarkMode() {
        // Disable system theme
        let systemToggle = app.tables.switches.element(boundBy: 0)
        if systemToggle.exists, systemToggle.value as? String == "1" {
            systemToggle.tap()
            sleep(1)
        }

        // Enable dark mode
        let darkToggle = app.tables.switches.element(boundBy: 1)
        if darkToggle.exists, darkToggle.value as? String == "0" {
            darkToggle.tap()
            sleep(2)
        }
    }

    private func tapExportData() {
        let exportCell = app.tables.cells.containing(.staticText, identifier: "Export Data").firstMatch
        if exportCell.exists {
            exportCell.tap()
            sleep(1)
        }
    }

    private func tapAbout() {
        let aboutCell = app.tables.cells.containing(.staticText, identifier: "About Nestory").firstMatch
        if aboutCell.exists {
            aboutCell.tap()
            sleep(1)
        }
    }

    private func dismissModal() {
        if app.navigationBars.buttons["Done"].exists {
            app.navigationBars.buttons["Done"].tap()
        } else if app.buttons["Done"].exists {
            app.buttons["Done"].tap()
        }
        sleep(1)
    }
}

// MARK: - Screenshot Counter

class ScreenshotCounter {
    private var counter = 0

    func next() -> String {
        counter += 1
        return String(format: "%02d", counter)
    }
}

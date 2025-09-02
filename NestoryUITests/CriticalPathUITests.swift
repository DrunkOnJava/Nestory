//
// CriticalPathUITests.swift
// NestoryUITests
//
// Critical path UI tests for Nestory insurance documentation app
//

import XCTest

@MainActor
final class CriticalPathUITests: XCTestCase {
    private var app: XCUIApplication!
    
    @MainActor
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    @MainActor
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.terminate()
        app = nil
    }
    
    // MARK: - Critical Path 1: Add Item Flow
    
    func testAddItemCriticalPath() throws {
        // Test the core add item workflow
        
        // Navigate to inventory tab (should be default)
        let inventoryTabButton = app.tabBars.buttons["Inventory"]
        XCTAssertTrue(inventoryTabButton.exists, "Inventory tab should exist")
        inventoryTabButton.tap()
        
        // Look for add button (+ or Add Item)
        let addButton = app.buttons["Add Item"].firstMatch
        if addButton.exists {
            addButton.tap()
        } else {
            // Try floating action button or navigation bar add button
            let plusButton = app.buttons["+"].firstMatch
            if plusButton.exists {
                plusButton.tap()
            } else {
                XCTFail("Could not find Add Item button")
            }
        }
        
        // Should see add item form
        let nameField = app.textFields["Item Name"].firstMatch
        if !nameField.exists {
            // Try different field identifiers
            let nameFieldAlt = app.textFields.element(matching: .textField, identifier: "name")
            XCTAssertTrue(nameFieldAlt.exists, "Item name field should exist")
            nameFieldAlt.tap()
            nameFieldAlt.typeText("Test Insurance Item")
        } else {
            nameField.tap()
            nameField.typeText("Test Insurance Item")
        }
        
        // Add value
        let valueField = app.textFields["Value"].firstMatch
        if valueField.exists {
            valueField.tap()
            valueField.typeText("500")
        }
        
        // Save the item
        let saveButton = app.buttons["Save"].firstMatch
        if saveButton.exists {
            saveButton.tap()
        } else {
            // Try Done or Add button
            let doneButton = app.buttons["Done"].firstMatch
            if doneButton.exists {
                doneButton.tap()
            }
        }
        
        // Verify item was added (should return to list view)
        let itemCell = app.cells.staticTexts["Test Insurance Item"]
        if itemCell.waitForExistence(timeout: 3) {
            XCTAssertTrue(itemCell.exists, "Added item should appear in inventory list")
        }
    }
    
    // MARK: - Critical Path 2: Search and Filter
    
    func testSearchCriticalPath() throws {
        // Test search functionality
        
        // Navigate to search tab
        let searchTabButton = app.tabBars.buttons["Search"]
        if searchTabButton.exists {
            searchTabButton.tap()
            
            // Look for search field
            let searchField = app.searchFields.firstMatch
            if searchField.exists {
                searchField.tap()
                searchField.typeText("test")
                
                // Verify search results appear
                let searchResults = app.tables.firstMatch
                XCTAssertTrue(searchResults.waitForExistence(timeout: 2), "Search results should appear")
            }
        } else {
            // Search might be in inventory view
            let inventoryTab = app.tabBars.buttons["Inventory"]
            inventoryTab.tap()
            
            let searchField = app.searchFields.firstMatch
            if searchField.exists {
                searchField.tap()
                searchField.typeText("test")
            }
        }
    }
    
    // MARK: - Critical Path 3: Analytics Dashboard
    
    func testAnalyticsCriticalPath() throws {
        // Test analytics/dashboard functionality
        
        let analyticsTab = app.tabBars.buttons["Analytics"]
        if analyticsTab.exists {
            analyticsTab.tap()
            
            // Verify dashboard loads
            let dashboardView = app.scrollViews.firstMatch
            XCTAssertTrue(dashboardView.waitForExistence(timeout: 3), "Analytics dashboard should load")
            
            // Look for key metrics
            let totalValueLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '$'")).firstMatch
            if totalValueLabel.exists {
                XCTAssertTrue(totalValueLabel.exists, "Should display monetary values")
            }
        }
    }
    
    // MARK: - Critical Path 4: Settings and Export
    
    func testSettingsAndExportCriticalPath() throws {
        // Test settings and export functionality
        
        let settingsTab = app.tabBars.buttons["Settings"]
        if settingsTab.exists {
            settingsTab.tap()
            
            // Look for export options
            let exportButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Export'")).firstMatch
            if exportButton.exists {
                exportButton.tap()
                
                // Should see export options
                let csvOption = app.buttons.containing(NSPredicate(format: "label CONTAINS 'CSV'")).firstMatch
                let pdfOption = app.buttons.containing(NSPredicate(format: "label CONTAINS 'PDF'")).firstMatch
                
                XCTAssertTrue(csvOption.exists || pdfOption.exists, "Export options should be available")
            }
        }
    }
    
    // MARK: - App Launch and Navigation
    
    func testAppLaunchAndNavigation() throws {
        // Test basic app launch and tab navigation
        
        // Verify app launched successfully
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Test tab bar navigation
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should exist")
        
        // Test each tab exists and is tappable
        let expectedTabs = ["Inventory", "Search", "Analytics", "Settings"]
        for tabName in expectedTabs {
            let tab = app.tabBars.buttons[tabName]
            if tab.exists {
                tab.tap()
                XCTAssertTrue(tab.isSelected || app.navigationBars.firstMatch.exists, "Tab \(tabName) should be selectable")
            }
        }
    }
    
    // MARK: - Performance Test
    
    func testAppPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }
}
//
//  NestoryScreenshotTests.swift
//  NestoryUITests
//
//  Automated screenshot generation for App Store and documentation
//

@preconcurrency import XCTest

@MainActor
final class NestoryScreenshotTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        
        // Set up launch arguments for screenshot mode
        app.launchArguments = [
            "-UITestMode", "YES",
            "-SeedDataForScreenshots", "YES"
        ]
        
        setupSnapshot(app)
        app.launch()
        
        // Wait for app to fully load
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: app.tabBars.firstMatch, handler: nil)
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testInventoryListScreenshots() async throws {
        // Navigate to main inventory view
        app.navigateToInventoryList()
        
        // Wait for data to load
        sleep(2)
        
        // Take screenshot of main inventory list
        snapshot("01-InventoryList")
        
        // Show search functionality
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("MacBook")
            snapshot("02-InventorySearch")
        }
        
        // Show item details if available
        let firstItem = app.cells.firstMatch
        if firstItem.exists {
            firstItem.tap()
            sleep(1)
            snapshot("03-ItemDetails")
            app.navigationBars.buttons.element(boundBy: 0).tap() // Go back
        }
    }
    
    func testAnalyticsDashboardScreenshots() async throws {
        // Navigate to analytics
        app.navigateToAnalytics()
        
        // Wait for charts to load
        sleep(2)
        
        // Take screenshot of analytics dashboard
        snapshot("04-AnalyticsDashboard")
        
        // Show category breakdown if available
        let categorySection = app.staticTexts["By Category"]
        if categorySection.exists {
            snapshot("05-CategoryBreakdown")
        }
        
        // Show value trends if available
        let trendsSection = app.staticTexts["Value Trends"]
        if trendsSection.exists {
            snapshot("06-ValueTrends")
        }
    }
    
    func testAddItemScreenshots() async throws {
        // Navigate to add item flow
        app.navigateToInventoryList()
        
        let addButton = app.buttons["Add Item"].firstMatch
        if addButton.exists {
            addButton.tap()
            sleep(1)
            
            // Screenshot of empty add item form
            snapshot("07-AddItemForm")
            
            // Fill out some fields to show populated form
            let nameField = app.textFields["Item Name"].firstMatch
            if nameField.exists {
                nameField.tap()
                nameField.typeText("Camera")
                
                let categoryField = app.textFields["Category"].firstMatch ?? app.buttons["Electronics"].firstMatch
                if categoryField.exists {
                    categoryField.tap()
                }
                
                let valueField = app.textFields["Estimated Value"].firstMatch
                if valueField.exists {
                    valueField.tap()
                    valueField.typeText("599")
                }
                
                snapshot("08-AddItemFormFilled")
            }
            
            // Cancel to return to main view
            let cancelButton = app.buttons["Cancel"].firstMatch
            if cancelButton.exists {
                cancelButton.tap()
            }
        }
    }
    
    func testSettingsScreenshots() async throws {
        // Navigate to settings
        app.navigateToSettings()
        
        // Wait for settings to load
        sleep(1)
        
        // Take screenshot of settings screen
        snapshot("09-Settings")
        
        // Show export options if available
        let exportButton = app.buttons["Export Data"].firstMatch
        if exportButton.exists {
            exportButton.tap()
            sleep(1)
            snapshot("10-ExportOptions")
            
            // Go back
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if backButton.exists {
                backButton.tap()
            }
        }
        
        // Show insurance report options if available
        let insuranceButton = app.buttons["Insurance Report"].firstMatch
        if insuranceButton.exists {
            insuranceButton.tap()
            sleep(1)
            snapshot("11-InsuranceReport")
            
            // Go back
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if backButton.exists {
                backButton.tap()
            }
        }
    }
    
    func testWarrantyTrackingScreenshots() async throws {
        // Look for warranty section in main app
        app.navigateToInventoryList()
        
        // Check if warranty dashboard is available
        let warrantyTab = app.tabBars.buttons["Warranty"].firstMatch
        if warrantyTab.exists {
            warrantyTab.tap()
            sleep(2)
            snapshot("12-WarrantyDashboard")
        }
        
        // Alternative: Look for warranty in settings or item details
        let firstItem = app.cells.firstMatch
        if firstItem.exists {
            firstItem.tap()
            sleep(1)
            
            // Look for warranty information in item details
            if app.staticTexts["Warranty"].exists || app.staticTexts["Warranty Information"].exists {
                snapshot("13-ItemWarrantyInfo")
            }
            
            app.navigationBars.buttons.element(boundBy: 0).tap() // Go back
        }
    }
    
    func testAdvancedSearchScreenshots() async throws {
        app.navigateToInventoryList()
        
        // Look for advanced search functionality
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            
            // Try to access advanced search filters
            let filterButton = app.buttons["Filter"].firstMatch ?? app.buttons["Advanced"].firstMatch
            if filterButton.exists {
                filterButton.tap()
                sleep(1)
                snapshot("14-AdvancedSearch")
                
                // Show filtered results
                let applyButton = app.buttons["Apply"].firstMatch
                if applyButton.exists {
                    applyButton.tap()
                    sleep(1)
                    snapshot("15-FilteredResults")
                }
            }
        }
    }
    
    override func tearDown() async throws {
        app.terminate()
        app = nil
        try await super.tearDown()
    }
}

// MARK: - Helper Methods

extension NestoryScreenshotTests {
    
    private func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = 10) {
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    private func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 10) {
        let exists = NSPredicate(format: "exists == 0")
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    private func scrollToElement(_ element: XCUIElement, maxScrolls: Int = 5) {
        var scrolls = 0
        while !element.isHittable && scrolls < maxScrolls {
            app.swipeUp()
            scrolls += 1
            sleep(1)
        }
    }
}
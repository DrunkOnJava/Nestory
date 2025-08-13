//
//  NestorySnapshotTests.swift
//  NestoryUITests
//
//  Comprehensive UI tests for generating screenshots of all app screens
//

import XCTest

@MainActor
final class NestorySnapshotTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = true
        
        // Create and configure app on MainActor
        app = XCUIApplication()
        
        // Set up Snapshot
        setupSnapshot(app)
        
        // Launch arguments for testing
        app.launchArguments += ["-UITestMode", "YES"]
        app.launchArguments += ["-DisableAnimations", "YES"]
        
        app.launch()
        
        // Handle any permission alerts
        NavigationHelpers.handlePermissionAlerts()
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Main Test Flow
    
    func testGenerateAllScreenshots() throws {
        XCTContext.runActivity(named: "Generate All Screenshots") { _ in
            // 1. Capture Home/Inventory screen
            captureInventoryScreenshots()
            
            // 2. Add Item Flow
            captureAddItemFlow()
            
            // 3. Item Detail View
            captureItemDetailScreenshots()
            
            // 4. Search Functionality
            captureSearchScreenshots()
            
            // 5. Categories
            captureCategoriesScreenshots()
            
            // 6. Analytics Dashboard
            captureAnalyticsScreenshots()
            
            // 7. Settings and Themes
            captureSettingsScreenshots()
            
            // 8. Special Features
            captureSpecialFeatures()
        }
    }
    
    // MARK: - Screen Capture Functions
    
    func captureInventoryScreenshots() {
        XCTContext.runActivity(named: "Capture Inventory Screenshots") { _ in
            NavigationHelpers.navigateToTab(named: "Inventory", in: app)
            NavigationHelpers.waitForLoadingToComplete(in: app)
            
            // Capture empty state if no items
            if app.staticTexts["No items yet"].exists {
                snapshot("01_Inventory_Empty")
            } else {
                // Capture populated inventory
                snapshot("01_Inventory_List")
                
                // Scroll to show more items if available
                if app.cells.count > 5 {
                    app.swipeUp()
                    Thread.sleep(forTimeInterval: 0.5)
                    snapshot("02_Inventory_Scrolled")
                }
            }
        }
    }
    
    func captureAddItemFlow() {
        XCTContext.runActivity(named: "Capture Add Item Flow") { _ in
            NavigationHelpers.navigateToTab(named: "Inventory", in: app)
            
            // Tap Add button
            let addButton = app.buttons["plus"].firstMatch
            if !addButton.exists {
                // Alternative: look for floating action button
                let fabButton = app.buttons.matching(identifier: "Add").firstMatch
                if fabButton.exists {
                    fabButton.tap()
                } else {
                    // Try navigation bar button
                    app.navigationBars.buttons["plus"].tapIfExists()
                }
            } else {
                addButton.tap()
            }
            
            Thread.sleep(forTimeInterval: 1)
            
            // Capture empty add item form
            snapshot("03_AddItem_Empty")
            
            // Fill in the form
            fillAddItemForm()
            
            // Capture filled form
            app.dismissKeyboard()
            snapshot("04_AddItem_Filled")
            
            // Add photo option
            capturePhotoOptions()
            
            // Save the item
            let saveButton = app.buttons["Save"].firstMatch
            if saveButton.exists {
                saveButton.tap()
                Thread.sleep(forTimeInterval: 1)
                snapshot("05_AddItem_Saved")
            } else {
                // Cancel if save not available
                NavigationHelpers.dismissSheet(in: app)
            }
        }
    }
    
    func captureItemDetailScreenshots() {
        XCTContext.runActivity(named: "Capture Item Detail Screenshots") { _ in
            NavigationHelpers.navigateToTab(named: "Inventory", in: app)
            NavigationHelpers.waitForLoadingToComplete(in: app)
            
            // Tap on first item if exists
            let firstItem = app.cells.firstMatch
            if firstItem.waitForExistence(timeout: 3) {
                firstItem.tap()
                Thread.sleep(forTimeInterval: 1)
                
                snapshot("06_ItemDetail_Top")
                
                // Scroll to show more details
                app.swipeUp()
                Thread.sleep(forTimeInterval: 0.5)
                snapshot("07_ItemDetail_Bottom")
                
                // Check for Edit button
                if app.buttons["Edit"].exists {
                    app.buttons["Edit"].tap()
                    Thread.sleep(forTimeInterval: 1)
                    snapshot("08_ItemDetail_Edit")
                    NavigationHelpers.dismissSheet(in: app)
                }
                
                NavigationHelpers.navigateBack(in: app)
            }
        }
    }
    
    func captureSearchScreenshots() {
        XCTContext.runActivity(named: "Capture Search Screenshots") { _ in
            NavigationHelpers.navigateToTab(named: "Search", in: app)
            Thread.sleep(forTimeInterval: 1)
            
            // Capture empty search
            snapshot("09_Search_Empty")
            
            // Enter search query
            let searchField = app.searchFields.firstMatch
            if searchField.waitForExistence(timeout: 3) {
                searchField.tap()
                searchField.typeText("test")
                Thread.sleep(forTimeInterval: 1)
                
                app.dismissKeyboard()
                snapshot("10_Search_Results")
            }
            
            // Clear search
            if app.buttons["Clear text"].exists {
                app.buttons["Clear text"].tap()
            }
        }
    }
    
    func captureCategoriesScreenshots() {
        XCTContext.runActivity(named: "Capture Categories Screenshots") { _ in
            NavigationHelpers.navigateToTab(named: "Categories", in: app)
            Thread.sleep(forTimeInterval: 1)
            
            snapshot("11_Categories_List")
            
            // Tap on first category if exists
            let firstCategory = app.cells.firstMatch
            if firstCategory.waitForExistence(timeout: 3) {
                firstCategory.tap()
                Thread.sleep(forTimeInterval: 1)
                snapshot("12_Category_Items")
                NavigationHelpers.navigateBack(in: app)
            }
            
            // Try to add new category
            if app.buttons["plus"].exists {
                app.buttons["plus"].tap()
                Thread.sleep(forTimeInterval: 1)
                snapshot("13_Category_Add")
                NavigationHelpers.dismissSheet(in: app)
            }
        }
    }
    
    func captureAnalyticsScreenshots() {
        XCTContext.runActivity(named: "Capture Analytics Screenshots") { _ in
            NavigationHelpers.navigateToTab(named: "Analytics", in: app)
            Thread.sleep(forTimeInterval: 1)
            
            snapshot("14_Analytics_Dashboard")
            
            // Scroll to show more charts if available
            if app.scrollViews.count > 0 {
                app.swipeUp()
                Thread.sleep(forTimeInterval: 0.5)
                snapshot("15_Analytics_Charts")
            }
        }
    }
    
    func captureSettingsScreenshots() {
        XCTContext.runActivity(named: "Capture Settings Screenshots") { _ in
            NavigationHelpers.navigateToTab(named: "Settings", in: app)
            Thread.sleep(forTimeInterval: 1)
            
            // Capture main settings
            snapshot("16_Settings_Main")
            
            // Capture appearance settings
            let appearanceCell = app.cells.containing(.staticText, identifier: "Appearance").firstMatch
            if appearanceCell.waitForExistence(timeout: 2) {
                appearanceCell.tap()
                Thread.sleep(forTimeInterval: 0.5)
                snapshot("17_Settings_Appearance")
                
                // Switch to dark mode
                if app.buttons["Dark"].exists {
                    app.buttons["Dark"].tap()
                    Thread.sleep(forTimeInterval: 1)
                    snapshot("18_Settings_DarkMode")
                    
                    // Switch back to light mode
                    app.buttons["Light"].tap()
                    Thread.sleep(forTimeInterval: 0.5)
                }
                
                NavigationHelpers.navigateBack(in: app)
            }
            
            // Scroll to show more settings
            app.swipeUp()
            Thread.sleep(forTimeInterval: 0.5)
            snapshot("19_Settings_More")
            
            // Check for About section
            let aboutCell = app.cells.containing(.staticText, identifier: "About").firstMatch
            if aboutCell.exists {
                aboutCell.tap()
                Thread.sleep(forTimeInterval: 0.5)
                snapshot("20_Settings_About")
                NavigationHelpers.navigateBack(in: app)
            }
        }
    }
    
    func captureSpecialFeatures() {
        XCTContext.runActivity(named: "Capture Special Features") { _ in
            // Barcode Scanner
            captureBarcodeScanner()
            
            // Export/Import features
            captureExportImport()
            
            // Insurance Report
            captureInsuranceReport()
        }
    }
    
    // MARK: - Helper Functions
    
    func fillAddItemForm() {
        // Name field
        let nameField = app.textFields["Item Name"].firstMatch
        if !nameField.exists {
            // Try alternative identifiers
            let altNameField = app.textFields.firstMatch
            if altNameField.exists {
                altNameField.tap()
                altNameField.typeText("MacBook Pro 16\"")
            }
        } else {
            nameField.tap()
            nameField.typeText("MacBook Pro 16\"")
        }
        
        // Description field
        let descField = app.textViews.firstMatch
        if descField.exists {
            descField.tap()
            descField.typeText("2023 M3 Max, 64GB RAM, 2TB SSD")
        }
        
        // Category selection
        let categoryButton = app.buttons.containing(.staticText, identifier: "Category").firstMatch
        if categoryButton.exists {
            categoryButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
            
            // Select first available category
            let firstCategory = app.cells.firstMatch
            if firstCategory.exists {
                firstCategory.tap()
            } else {
                NavigationHelpers.dismissSheet(in: app)
            }
        }
        
        // Quantity
        let quantityField = app.textFields.containing(.staticText, identifier: "Quantity").firstMatch
        if quantityField.exists {
            quantityField.tap()
            quantityField.typeText("1")
        }
        
        // Purchase Price
        let priceField = app.textFields.containing(.staticText, identifier: "Price").firstMatch
        if priceField.exists {
            priceField.tap()
            priceField.typeText("3999.99")
        }
        
        app.dismissKeyboard()
    }
    
    func capturePhotoOptions() {
        // Look for photo button
        let photoButton = app.buttons.containing(.staticText, identifier: "Photo").firstMatch
        if photoButton.exists {
            photoButton.tap()
            Thread.sleep(forTimeInterval: 1)
            
            // Capture photo options sheet
            snapshot("21_Photo_Options")
            
            // Dismiss sheet
            NavigationHelpers.dismissSheet(in: app)
        }
    }
    
    func captureBarcodeScanner() {
        NavigationHelpers.navigateToTab(named: "Inventory", in: app)
        
        // Look for barcode scanner button
        let scanButton = app.buttons["barcode.viewfinder"].firstMatch
        if !scanButton.exists {
            // Try alternative
            let altScanButton = app.buttons.containing(.staticText, identifier: "Scan").firstMatch
            if altScanButton.exists {
                altScanButton.tap()
                Thread.sleep(forTimeInterval: 1)
                snapshot("22_Barcode_Scanner")
                NavigationHelpers.dismissSheet(in: app)
            }
        } else {
            scanButton.tap()
            Thread.sleep(forTimeInterval: 1)
            snapshot("22_Barcode_Scanner")
            NavigationHelpers.dismissSheet(in: app)
        }
    }
    
    func captureExportImport() {
        NavigationHelpers.navigateToTab(named: "Settings", in: app)
        
        // Look for Import/Export section
        let exportCell = app.cells.containing(.staticText, identifier: "Export").firstMatch
        if exportCell.waitForExistence(timeout: 2) {
            exportCell.tap()
            Thread.sleep(forTimeInterval: 1)
            snapshot("23_Export_Options")
            NavigationHelpers.navigateBack(in: app)
        }
    }
    
    func captureInsuranceReport() {
        NavigationHelpers.navigateToTab(named: "Settings", in: app)
        
        // Look for Insurance Report
        let insuranceCell = app.cells.containing(.staticText, identifier: "Insurance").firstMatch
        if insuranceCell.waitForExistence(timeout: 2) {
            insuranceCell.tap()
            Thread.sleep(forTimeInterval: 1)
            snapshot("24_Insurance_Report")
            NavigationHelpers.navigateBack(in: app)
        }
    }
}
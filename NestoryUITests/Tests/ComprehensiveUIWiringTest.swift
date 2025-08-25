//
// ComprehensiveUIWiringTest.swift
// NestoryUITests
//
// Systematic UI wiring validation test for complete feature coverage
// Captures every screen to identify broken navigation and missing integrations
//

import XCTest

/// Comprehensive UI wiring test that systematically captures every app screen
final class ComprehensiveUIWiringTest: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    /// Comprehensive test that captures every major UI component to identify wiring issues
    @MainActor
    func testCompleteUIWiring() async throws {
        app = XCUIApplication()
        app.launchArguments = [
            "--ui-testing",
            "--demo-data",
            "--comprehensive-testing"
        ]
        app.launch()
        
        // Wait for app to stabilize
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Phase 1: Test all main tabs
        await testMainTabNavigation()
        
        // Phase 2: Test deep navigation flows
        await testDeepNavigationFlows()
        
        // Phase 3: Test feature-specific integrations
        await testFeatureIntegrations()
        
        // Phase 4: Test settings and configuration screens
        await testSettingsScreens()
        
        print("✅ Comprehensive UI wiring test completed!")
        
        app.terminate()
    }
    
    // MARK: - Main Tab Navigation Testing
    
    @MainActor
    private func testMainTabNavigation() async {
        print("🔍 Phase 1: Testing main tab navigation...")
        
        // Test Inventory Tab
        await captureTabScreen("Inventory", expectedContent: "inventory")
        
        // Test Capture Tab  
        await captureTabScreen("Capture", expectedContent: "camera")
        
        // Test Analytics Tab
        await captureTabScreen("Analytics", expectedContent: "analytics")
        
        // Test Settings Tab - This is where we found the bug
        await captureTabScreen("Settings", expectedContent: "settings")
    }
    
    @MainActor
    private func captureTabScreen(_ tabName: String, expectedContent: String) async {
        print("📱 Testing \(tabName) tab...")
        
        if app.tabBars.buttons[tabName].exists {
            app.tabBars.buttons[tabName].tap()
            
            // Wait for navigation
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            // Capture screenshot
            let screenshot = app.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = "\(tabName.lowercased())_tab_wiring_test"
            attachment.lifetime = .keepAlways
            add(attachment)
            
            // Analyze the screen content to detect issues
            analyzeScreenContent(tabName: tabName, expectedContent: expectedContent)
            
            print("📸 Captured: \(tabName) tab")
        } else {
            print("❌ \(tabName) tab button not found!")
            XCTFail("\(tabName) tab should be accessible")
        }
    }
    
    @MainActor
    private func analyzeScreenContent(tabName: String, expectedContent: String) {
        // Check for specific expected elements based on tab
        switch expectedContent {
        case "inventory":
            if !app.staticTexts["Inventory"].exists && !app.navigationBars["Inventory"].exists {
                print("⚠️  \(tabName) tab may not be showing inventory content")
            }
        case "settings":
            // Look for settings-specific elements
            let hasSettingsContent = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Settings' OR label CONTAINS 'Preferences' OR label CONTAINS 'Configuration'")).firstMatch.exists
            if !hasSettingsContent {
                print("🐛 WIRING ISSUE DETECTED: \(tabName) tab is not showing settings content!")
                print("   Expected: Settings interface")
                print("   Actual: Appears to be showing different content")
            }
        case "analytics":
            let hasAnalyticsContent = app.staticTexts["Analytics"].exists || 
                                    app.staticTexts["Total Items"].exists ||
                                    app.staticTexts["Total Value"].exists
            if !hasAnalyticsContent {
                print("🐛 WIRING ISSUE DETECTED: \(tabName) tab missing analytics content!")
            }
        case "camera":
            // Look for camera/capture related elements
            let hasCameraContent = app.buttons.matching(NSPredicate(format: "label CONTAINS 'camera' OR label CONTAINS 'capture' OR label CONTAINS 'photo'")).firstMatch.exists
            if !hasCameraContent {
                print("🐛 WIRING ISSUE DETECTED: \(tabName) tab missing camera functionality!")
            }
        default:
            break
        }
    }
    
    // MARK: - Deep Navigation Testing
    
    @MainActor
    private func testDeepNavigationFlows() async {
        print("🔍 Phase 2: Testing deep navigation flows...")
        
        // Test item detail navigation
        await testItemDetailNavigation()
        
        // Test add item flow
        await testAddItemFlow()
        
        // Test search functionality
        await testSearchFunctionality()
    }
    
    @MainActor
    private func testItemDetailNavigation() async {
        print("📱 Testing item detail navigation...")
        
        // Navigate to inventory first
        if app.tabBars.buttons["Inventory"].exists {
            app.tabBars.buttons["Inventory"].tap()
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Try to tap the first item
            let firstItem = app.cells.firstMatch
            if firstItem.exists {
                firstItem.tap()
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                
                // Capture item detail screen
                let screenshot = app.screenshot()
                let attachment = XCTAttachment(screenshot: screenshot)
                attachment.name = "item_detail_wiring_test"
                attachment.lifetime = .keepAlways
                add(attachment)
                
                print("📸 Captured: Item detail screen")
                
                // Check for item detail specific elements
                let hasItemDetailContent = app.navigationBars.firstMatch.exists ||
                                         app.staticTexts.matching(NSPredicate(format: "label CONTAINS '$'")).count > 0
                
                if !hasItemDetailContent {
                    print("🐛 WIRING ISSUE DETECTED: Item detail navigation may be broken!")
                }
                
                // Navigate back
                if app.navigationBars.buttons.firstMatch.exists {
                    app.navigationBars.buttons.firstMatch.tap()
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }
            } else {
                print("ℹ️  No items available for detail navigation test")
            }
        }
    }
    
    @MainActor
    private func testAddItemFlow() async {
        print("📱 Testing add item flow...")
        
        // Navigate to inventory
        if app.tabBars.buttons["Inventory"].exists {
            app.tabBars.buttons["Inventory"].tap()
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Look for add item button
            let addButton = app.buttons["Add Item"]
            if addButton.exists {
                addButton.tap()
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                
                // Capture add item screen
                let screenshot = app.screenshot()
                let attachment = XCTAttachment(screenshot: screenshot)
                attachment.name = "add_item_flow_wiring_test"
                attachment.lifetime = .keepAlways
                add(attachment)
                
                print("📸 Captured: Add item screen")
                
                // Check for form elements
                let hasFormElements = app.textFields.count > 0 || app.buttons["Save"].exists
                if !hasFormElements {
                    print("🐛 WIRING ISSUE DETECTED: Add item form may not be properly implemented!")
                }
                
                // Try to cancel/back out
                if app.buttons["Cancel"].exists {
                    app.buttons["Cancel"].tap()
                } else if app.navigationBars.buttons.firstMatch.exists {
                    app.navigationBars.buttons.firstMatch.tap()
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                
            } else {
                print("🐛 WIRING ISSUE DETECTED: Add Item button not found!")
            }
        }
    }
    
    @MainActor
    private func testSearchFunctionality() async {
        print("📱 Testing search functionality...")
        
        // Navigate to inventory
        if app.tabBars.buttons["Inventory"].exists {
            app.tabBars.buttons["Inventory"].tap()
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Try to interact with search bar
            let searchField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS 'Search'")).firstMatch
            if searchField.exists {
                searchField.tap()
                searchField.typeText("MacBook")
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                
                // Capture search results
                let screenshot = app.screenshot()
                let attachment = XCTAttachment(screenshot: screenshot)
                attachment.name = "search_functionality_wiring_test"
                attachment.lifetime = .keepAlways
                add(attachment)
                
                print("📸 Captured: Search functionality")
                
                // Clear search
                searchField.clearText()
                
            } else {
                print("🐛 WIRING ISSUE DETECTED: Search field not interactive!")
            }
        }
    }
    
    // MARK: - Feature Integration Testing
    
    @MainActor
    private func testFeatureIntegrations() async {
        print("🔍 Phase 3: Testing feature integrations...")
        
        // Test analytics data integration
        await testAnalyticsDataIntegration()
        
        // Test category system integration
        await testCategoryIntegration()
    }
    
    @MainActor
    private func testAnalyticsDataIntegration() async {
        print("📊 Testing analytics data integration...")
        
        if app.tabBars.buttons["Analytics"].exists {
            app.tabBars.buttons["Analytics"].tap()
            try? await Task.sleep(nanoseconds: 2_000_000_000) // Give time for calculations
            
            // Check for data inconsistencies
            let totalItemsText = app.staticTexts["5"].exists // Based on our demo data
            let totalValueExists = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '$'")).firstMatch.exists
            let categoriesText = app.staticTexts["3"].exists
            
            if !totalItemsText {
                print("🐛 DATA INTEGRATION ISSUE: Total items count not displaying correctly")
            }
            
            if !totalValueExists {
                print("🐛 DATA INTEGRATION ISSUE: Total value not calculating/displaying")
            }
            
            if !categoriesText {
                print("🐛 DATA INTEGRATION ISSUE: Category count not reflecting inventory")
            }
            
            // Check for the "No category data available" issue we found
            if app.staticTexts["No category data available"].exists {
                print("🐛 CONFIRMED BUG: Analytics showing 'No category data available' despite having categories")
            }
            
            // Capture detailed analytics screen
            let screenshot = app.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = "analytics_data_integration_test"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }
    
    @MainActor
    private func testCategoryIntegration() async {
        print("🏷️  Testing category system integration...")
        
        // Test if categories are properly integrated across different screens
        if app.tabBars.buttons["Inventory"].exists {
            app.tabBars.buttons["Inventory"].tap()
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Check for visible categories in inventory  
            let electronicsItems = app.staticTexts.matching(NSPredicate(format: "label == 'Electronics'")).count
            let furnitureItems = app.staticTexts.matching(NSPredicate(format: "label == 'Furniture'")).count
            let kitchenItems = app.staticTexts.matching(NSPredicate(format: "label == 'Kitchen'")).count
            
            print("📊 Found categories - Electronics: \(electronicsItems), Furniture: \(furnitureItems), Kitchen: \(kitchenItems)")
            
            // Now check if analytics reflects the same categories
            if app.tabBars.buttons["Analytics"].exists {
                app.tabBars.buttons["Analytics"].tap()
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                
                // This should show category distribution but we found it's empty
                if app.staticTexts["No category data available"].exists {
                    print("🐛 CATEGORY INTEGRATION BUG: Analytics not receiving category data from inventory")
                }
            }
        }
    }
    
    // MARK: - Settings Screen Testing  
    
    @MainActor
    private func testSettingsScreens() async {
        print("🔍 Phase 4: Testing settings screens...")
        
        if app.tabBars.buttons["Settings"].exists {
            app.tabBars.buttons["Settings"].tap()
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            
            // Capture what actually appears when tapping Settings
            let screenshot = app.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = "settings_actual_screen_debug"
            attachment.lifetime = .keepAlways
            add(attachment)
            
            // Detailed analysis of what's actually showing
            let inventoryTitle = app.staticTexts["Inventory"].exists
            let settingsElements = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Settings' OR label CONTAINS 'Preferences'")).firstMatch.exists
            
            if inventoryTitle && !settingsElements {
                print("🐛 CONFIRMED CRITICAL BUG: Settings tab showing Inventory instead of Settings!")
                print("   This is a navigation routing issue that needs immediate attention")
            }
            
            // Try to find any settings-related UI elements
            let possibleSettingsElements = [
                "Import Data", "Export Data", "Cloud Backup", "Notifications",
                "Dark Mode", "Privacy", "About", "Version", "Reset"
            ]
            
            var foundSettingsElements: [String] = []
            for element in possibleSettingsElements {
                if app.staticTexts[element].exists || app.buttons[element].exists {
                    foundSettingsElements.append(element)
                }
            }
            
            if foundSettingsElements.isEmpty {
                print("🐛 CRITICAL: No settings UI elements found - Settings feature appears to be completely missing!")
            } else {
                print("✅ Found settings elements: \(foundSettingsElements)")
            }
        }
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    func clearText() {
        coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0)).tap()
        // For text fields, we can use the built-in clear behavior
        if let value = self.value as? String, !value.isEmpty {
            self.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count))
        }
    }
}
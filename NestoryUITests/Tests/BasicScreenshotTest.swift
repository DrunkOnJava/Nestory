//
// BasicScreenshotTest.swift
// NestoryUITests
//
// Simple screenshot capture test for immediate visual validation
// Demonstrates working UI automation framework
//

import XCTest

/// Basic screenshot test for immediate validation
@MainActor
final class BasicScreenshotTest: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }
    
    /// Simple test that captures key app screenshots
    func testBasicScreenshotCapture() async throws {
        // Configure and launch app
        app = XCUIApplication()
        app.launchArguments = [
            "--ui-testing",
            "--demo-data",
            "--light-mode"
        ]
        
        app.launch()
        
        // Wait for app to stabilize
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        
        // Capture app launch state
        let launchScreenshot = app.screenshot()
        let launchAttachment = XCTAttachment(screenshot: launchScreenshot)
        launchAttachment.name = "01_app_launch"
        launchAttachment.lifetime = .keepAlways
        add(launchAttachment)
        print("📸 Captured: App Launch")
        
        // Navigate to inventory tab
        if app.tabBars.buttons["Inventory"].exists {
            app.tabBars.buttons["Inventory"].tap()
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            let inventoryScreenshot = app.screenshot()
            let inventoryAttachment = XCTAttachment(screenshot: inventoryScreenshot)
            inventoryAttachment.name = "02_inventory_tab"
            inventoryAttachment.lifetime = .keepAlways
            add(inventoryAttachment)
            print("📸 Captured: Inventory Tab")
        }
        
        // Navigate to settings tab
        if app.tabBars.buttons["Settings"].exists {
            app.tabBars.buttons["Settings"].tap()
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            let settingsScreenshot = app.screenshot()
            let settingsAttachment = XCTAttachment(screenshot: settingsScreenshot)
            settingsAttachment.name = "03_settings_tab"
            settingsAttachment.lifetime = .keepAlways
            add(settingsAttachment)
            print("📸 Captured: Settings Tab")
        }
        
        // Navigate to analytics tab
        if app.tabBars.buttons["Analytics"].exists {
            app.tabBars.buttons["Analytics"].tap()
            try await Task.sleep(nanoseconds: 3_000_000_000) // Extra time for charts
            
            let analyticsScreenshot = app.screenshot()
            let analyticsAttachment = XCTAttachment(screenshot: analyticsScreenshot)
            analyticsAttachment.name = "04_analytics_tab"
            analyticsAttachment.lifetime = .keepAlways
            add(analyticsAttachment)
            print("📸 Captured: Analytics Tab")
        }
        
        // Navigate to search tab
        if app.tabBars.buttons["Search"].exists {
            app.tabBars.buttons["Search"].tap()
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            let searchScreenshot = app.screenshot()
            let searchAttachment = XCTAttachment(screenshot: searchScreenshot)
            searchAttachment.name = "05_search_tab"
            searchAttachment.lifetime = .keepAlways
            add(searchAttachment)
            print("📸 Captured: Search Tab")
        }
        
        print("✅ Basic screenshot capture completed!")
        
        // Terminate app
        app.terminate()
    }
}
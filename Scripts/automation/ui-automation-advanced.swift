#!/usr/bin/env swift
//
// Advanced iOS Simulator UI Automation using XCTest and Accessibility
// Purpose: Programmatic navigation through Nestory app for documentation
// Usage: swift ui-automation-advanced.swift
//

import Foundation
import XCTest

class NestoryUIAutomation: XCTestCase {
    
    let app = XCUIApplication()
    let screenshotDir = "/Users/griffin/Projects/Nestory/Screenshots/"
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        // Set up the app
        app.launchEnvironment = [
            "AUTOMATION_MODE": "true",
            "DISABLE_ANIMATIONS": "true"
        ]
        
        // Create screenshots directory
        createScreenshotDirectory()
        
        app.launch()
        
        // Wait for app to be ready
        _ = app.wait(for: .runningForeground, timeout: 10)
    }
    
    func createScreenshotDirectory() {
        do {
            try FileManager.default.createDirectory(
                atPath: screenshotDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            print("❌ Failed to create screenshot directory: \\(error)")
        }
    }
    
    func takeScreenshot(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        
        let timestamp = DateFormatter().apply {
            $0.dateFormat = "yyyyMMdd-HHmmss"
        }.string(from: Date())
        
        let filename = "\\(name)-\\(timestamp).png"
        let filepath = screenshotDir + filename
        
        do {
            try screenshot.pngRepresentation.write(to: URL(fileURLWithPath: filepath))
            print("📸 Screenshot saved: \\(filename)")
        } catch {
            print("❌ Failed to save screenshot \\(name): \\(error)")
        }
    }
    
    func waitAndTap(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let exists = element.waitForExistence(timeout: timeout)
        if exists && element.isHittable {
            element.tap()
            return true
        }
        return false
    }
    
    func testFullAppNavigation() {
        print("🚀 Starting comprehensive app navigation...")
        
        // Main inventory view
        takeScreenshot("01-app-launch")
        sleep(2)
        
        // Navigate through tabs
        navigateInventorySection()
        navigateSearchSection() 
        navigateAnalyticsSection()
        navigateSettingsSection()
        
        print("✅ Full navigation completed!")
    }
    
    func navigateInventorySection() {
        print("📋 Navigating inventory section...")
        
        // Ensure we're on inventory tab
        let inventoryTab = app.tabBars.buttons["Inventory"]
        if inventoryTab.exists {
            inventoryTab.tap()
            sleep(1)
        }
        
        takeScreenshot("02-inventory-main")
        
        // Look for items in the list
        let itemCells = app.cells.matching(identifier: "ItemRow")
        if itemCells.count > 0 {
            print("📱 Found \\(itemCells.count) items, tapping first one")
            itemCells.element(boundBy: 0).tap()
            sleep(2)
            takeScreenshot("03-item-detail")
            
            // Go back
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if backButton.exists {
                backButton.tap()
                sleep(1)
            }
        }
        
        // Try add item button
        let addButton = app.navigationBars.buttons["Add"]
        if waitAndTap(addButton) {
            sleep(1)
            takeScreenshot("04-add-item")
            
            // Cancel/dismiss
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.exists {
                cancelButton.tap()
                sleep(1)
            }
        }
        
        // Test search functionality in inventory
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            sleep(0.5)
            takeScreenshot("05-search-active")
            
            searchField.typeText("MacBook")
            sleep(2)
            takeScreenshot("06-search-results")
            
            // Clear search
            if let clearButton = searchField.buttons["Clear text"].firstMatch {
                clearButton.tap()
            } else {
                // Alternative: select all and delete
                searchField.tap()
                searchField.typeText("")
            }
            sleep(1)
        }
    }
    
    func navigateSearchSection() {
        print("🔍 Navigating search section...")
        
        let searchTab = app.tabBars.buttons["Search"]
        if waitAndTap(searchTab) {
            sleep(1)
            takeScreenshot("07-search-tab")
            
            // Test advanced search features
            let filterButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'filter'"))
            if filterButtons.count > 0 {
                filterButtons.element(boundBy: 0).tap()
                sleep(1)
                takeScreenshot("08-search-filters")
                
                // Close filters
                let doneButton = app.buttons["Done"]
                if doneButton.exists {
                    doneButton.tap()
                    sleep(1)
                }
            }
        }
    }
    
    func navigateAnalyticsSection() {
        print("📊 Navigating analytics section...")
        
        let analyticsTab = app.tabBars.buttons["Analytics"]
        if waitAndTap(analyticsTab) {
            sleep(2) // Analytics might need more time to load
            takeScreenshot("09-analytics-main")
            
            // Scroll down to see more analytics
            app.scrollViews.firstMatch.swipeUp()
            sleep(1)
            takeScreenshot("10-analytics-scrolled")
            
            // Look for chart interactions
            let charts = app.otherElements.matching(NSPredicate(format: "label CONTAINS 'chart'"))
            if charts.count > 0 {
                charts.element(boundBy: 0).tap()
                sleep(1)
                takeScreenshot("11-analytics-detail")
            }
        }
    }
    
    func navigateSettingsSection() {
        print("⚙️ Navigating settings section...")
        
        let settingsTab = app.tabBars.buttons["Settings"]
        if waitAndTap(settingsTab) {
            sleep(1)
            takeScreenshot("12-settings-main")
            
            // Test scrolling through settings
            let settingsTable = app.tables.firstMatch
            if settingsTable.exists {
                settingsTable.swipeUp()
                sleep(1)
                takeScreenshot("13-settings-scrolled")
                
                // Try tapping on export settings
                let exportCell = settingsTable.cells.containing(.staticText, identifier: "Export").firstMatch
                if exportCell.exists {
                    exportCell.tap()
                    sleep(1)
                    takeScreenshot("14-export-options")
                    
                    // Go back
                    let backButton = app.navigationBars.buttons.element(boundBy: 0)
                    if backButton.exists {
                        backButton.tap()
                        sleep(1)
                    }
                }
            }
        }
    }
    
    // Utility function to test accessibility
    func testAccessibilityElements() {
        print("♿ Testing accessibility elements...")
        
        let allElements = app.descendants(matching: .any)
        var accessibleCount = 0
        
        for i in 0..<min(allElements.count, 50) { // Limit to first 50 elements
            let element = allElements.element(boundBy: i)
            if !element.label.isEmpty || !element.identifier.isEmpty {
                accessibleCount += 1
            }
        }
        
        print("📊 Found \\(accessibleCount) accessible elements out of \\(min(allElements.count, 50)) checked")
    }
    
    // Performance testing
    func measureAppLaunchTime() {
        measure {
            app.terminate()
            app.launch()
            _ = app.wait(for: .runningForeground, timeout: 10)
        }
    }
}

extension DateFormatter {
    func apply(_ configuration: (DateFormatter) -> Void) -> DateFormatter {
        configuration(self)
        return self
    }
}

// Command-line execution
class TestRunner {
    static func run() {
        let testCase = NestoryUIAutomation()
        testCase.setUp()
        
        do {
            // Run the full navigation test
            testCase.testFullAppNavigation()
            
            // Optional: Run accessibility test
            testCase.testAccessibilityElements()
            
            print("🎉 All automation tests completed successfully!")
        } catch {
            print("❌ Automation failed: \\(error)")
        }
    }
}

// Only run if this file is executed directly
if CommandLine.argc > 0 && CommandLine.arguments[0].contains("ui-automation-advanced") {
    TestRunner.run()
}
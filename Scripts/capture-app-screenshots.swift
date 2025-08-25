#!/usr/bin/env swift

//
// capture-app-screenshots.swift
// Comprehensive screenshot capture for Nestory app documentation
// Captures all major views, features, and user flows for visual catalog
//

import Foundation
import XCTest

/// Screenshot capture coordinator for comprehensive app documentation
@MainActor
class AppScreenshotCapture {
    private let app: XCUIApplication
    private let outputDirectory: String
    private var screenshotIndex = 1
    
    init(outputDirectory: String = "/tmp/nestory_screenshots") {
        self.app = XCUIApplication()
        self.outputDirectory = outputDirectory
        
        // Configure app for screenshot capture
        app.launchArguments = [
            "--ui-testing",
            "--demo-data", 
            "--light-mode", // Start with light mode
            "--disable-animations"
        ]
    }
    
    func captureFullAppCatalog() async throws {
        // Create output directory
        try createOutputDirectory()
        
        print("🚀 Starting comprehensive screenshot capture...")
        
        // Launch app and wait for stability
        app.launch()
        Thread.sleep(forTimeInterval: 3.0)
        
        // Capture app flow screenshots
        try await captureOnboarding()
        try await captureMainTabs()
        try await captureInventoryFlows()
        try await captureSearchAndFilter()
        try await captureAnalytics()
        try await captureSettings()
        try await captureInsuranceFlows()
        try await captureDarkModeViews()
        
        print("✅ Screenshot capture complete! \(screenshotIndex - 1) images saved to \(outputDirectory)")
    }
    
    // MARK: - Main App Flows
    
    private func captureOnboarding() async throws {
        print("📱 Capturing app launch and main interface...")
        
        // Main app launch state
        await captureScreenshot(name: "01_app_launch", description: "App launch screen")
        
        // Wait for content to load
        Thread.sleep(forTimeInterval: 2.0)
        
        // Main interface loaded
        await captureScreenshot(name: "02_main_interface", description: "Main app interface with tabs")
    }
    
    private func captureMainTabs() async throws {
        print("🏠 Capturing main tab navigation...")
        
        // Inventory Tab (default)
        if app.tabBars.buttons["Inventory"].exists {
            app.tabBars.buttons["Inventory"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            await captureScreenshot(name: "03_inventory_tab", description: "Inventory tab main view")
        }
        
        // Search Tab
        if app.tabBars.buttons["Search"].exists {
            app.tabBars.buttons["Search"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            await captureScreenshot(name: "04_search_tab", description: "Search tab main view")
        }
        
        // Analytics Tab
        if app.tabBars.buttons["Analytics"].exists {
            app.tabBars.buttons["Analytics"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            await captureScreenshot(name: "05_analytics_tab", description: "Analytics tab main view")
        }
        
        // Settings Tab
        if app.tabBars.buttons["Settings"].exists {
            app.tabBars.buttons["Settings"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            await captureScreenshot(name: "06_settings_tab", description: "Settings tab main view")
        }
        
        // Return to inventory for subsequent captures
        app.tabBars.buttons["Inventory"].tap()
        Thread.sleep(forTimeInterval: 1.0)
    }
    
    private func captureInventoryFlows() async throws {
        print("📦 Capturing inventory management flows...")
        
        // Navigate to inventory
        app.tabBars.buttons["Inventory"].tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        // Inventory list view (with items)
        await captureScreenshot(name: "07_inventory_list", description: "Inventory list with demo items")
        
        // Add new item flow
        if app.navigationBars.buttons["Add Item"].exists {
            app.navigationBars.buttons["Add Item"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            await captureScreenshot(name: "08_add_item_form", description: "Add new item form")
            
            // Fill out form partially for screenshot
            let nameField = app.textFields["itemNameField"]
            if nameField.exists {
                nameField.tap()
                nameField.typeText("Screenshot Demo Item")
                Thread.sleep(forTimeInterval: 0.5)
                await captureScreenshot(name: "09_add_item_filled", description: "Add item form with data")
            }
            
            // Cancel to avoid creating test data
            if app.buttons["Cancel"].exists {
                app.buttons["Cancel"].tap()
            } else if app.navigationBars.buttons.firstMatch.exists {
                app.navigationBars.buttons.firstMatch.tap()
            }
            Thread.sleep(forTimeInterval: 1.0)
        }
        
        // Item detail view (tap first item if exists)
        let firstItem = app.cells.firstMatch
        if firstItem.exists {
            firstItem.tap()
            Thread.sleep(forTimeInterval: 1.5)
            await captureScreenshot(name: "10_item_detail", description: "Item detail view")
            
            // Navigate back
            if app.navigationBars.buttons.firstMatch.exists {
                app.navigationBars.buttons.firstMatch.tap()
                Thread.sleep(forTimeInterval: 1.0)
            }
        }
    }
    
    private func captureSearchAndFilter() async throws {
        print("🔍 Capturing search and filtering features...")
        
        // Navigate to search tab
        app.tabBars.buttons["Search"].tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        // Search interface
        await captureScreenshot(name: "11_search_interface", description: "Search interface")
        
        // Enter search query if search field exists
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("laptop")
            Thread.sleep(forTimeInterval: 1.0)
            await captureScreenshot(name: "12_search_results", description: "Search results for 'laptop'")
            
            // Clear search
            if app.buttons["Clear text"].exists {
                app.buttons["Clear text"].tap()
            }
        }
        
        // Category filters (if available)
        let filterButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'filter' OR label CONTAINS 'category'")).firstMatch
        if filterButton.exists {
            filterButton.tap()
            Thread.sleep(forTimeInterval: 1.0)
            await captureScreenshot(name: "13_filter_options", description: "Filter and category options")
            
            // Dismiss filter
            if app.buttons["Done"].exists {
                app.buttons["Done"].tap()
            }
        }
    }
    
    private func captureAnalytics() async throws {
        print("📊 Capturing analytics and insights...")
        
        // Navigate to analytics tab
        app.tabBars.buttons["Analytics"].tap()
        Thread.sleep(forTimeInterval: 2.0) // Allow charts to render
        
        // Main analytics view
        await captureScreenshot(name: "14_analytics_overview", description: "Analytics overview dashboard")
        
        // Scroll to see more charts if scrollable
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
            Thread.sleep(forTimeInterval: 1.0)
            await captureScreenshot(name: "15_analytics_charts", description: "Analytics charts and insights")
        }
    }
    
    private func captureSettings() async throws {
        print("⚙️ Capturing settings and configuration...")
        
        // Navigate to settings tab
        app.tabBars.buttons["Settings"].tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        // Main settings view
        await captureScreenshot(name: "16_settings_main", description: "Main settings interface")
        
        // Theme selection (if available)
        let themeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'theme' OR label CONTAINS 'appearance'")).firstMatch
        if themeButton.exists {
            themeButton.tap()
            Thread.sleep(forTimeInterval: 1.0)
            await captureScreenshot(name: "17_theme_selection", description: "Theme selection interface")
            
            // Go back
            if app.navigationBars.buttons.firstMatch.exists {
                app.navigationBars.buttons.firstMatch.tap()
                Thread.sleep(forTimeInterval: 1.0)
            }
        }
        
        // Scroll through settings if scrollable
        let settingsScrollView = app.scrollViews.firstMatch
        if settingsScrollView.exists {
            settingsScrollView.swipeUp()
            Thread.sleep(forTimeInterval: 1.0)
            await captureScreenshot(name: "18_settings_extended", description: "Extended settings options")
        }
    }
    
    private func captureInsuranceFlows() async throws {
        print("🏠 Capturing insurance-specific features...")
        
        // Look for insurance report generation
        let insuranceButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'insurance' OR label CONTAINS 'report'")).firstMatch
        if insuranceButton.exists {
            insuranceButton.tap()
            Thread.sleep(forTimeInterval: 1.0)
            await captureScreenshot(name: "19_insurance_report", description: "Insurance report generation")
            
            // Navigate back
            if app.navigationBars.buttons.firstMatch.exists {
                app.navigationBars.buttons.firstMatch.tap()
            }
        }
        
        // Check for warranty tracking views
        let warrantyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'warranty'")).firstMatch
        if warrantyButton.exists {
            warrantyButton.tap()
            Thread.sleep(forTimeInterval: 1.0)
            await captureScreenshot(name: "20_warranty_tracking", description: "Warranty tracking interface")
            
            // Navigate back
            if app.navigationBars.buttons.firstMatch.exists {
                app.navigationBars.buttons.firstMatch.tap()
            }
        }
    }
    
    private func captureDarkModeViews() async throws {
        print("🌙 Capturing dark mode interface...")
        
        // Navigate to settings to change theme
        app.tabBars.buttons["Settings"].tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        // Look for dark mode toggle
        let darkModeToggle = app.switches.matching(NSPredicate(format: "identifier CONTAINS 'dark' OR identifier CONTAINS 'theme'")).firstMatch
        if darkModeToggle.exists && darkModeToggle.value as? String == "0" {
            darkModeToggle.tap()
            Thread.sleep(forTimeInterval: 2.0) // Allow theme transition
            
            // Capture key views in dark mode
            await captureScreenshot(name: "21_settings_dark", description: "Settings in dark mode")
            
            app.tabBars.buttons["Inventory"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            await captureScreenshot(name: "22_inventory_dark", description: "Inventory in dark mode")
            
            app.tabBars.buttons["Analytics"].tap()
            Thread.sleep(forTimeInterval: 1.5)
            await captureScreenshot(name: "23_analytics_dark", description: "Analytics in dark mode")
        }
    }
    
    // MARK: - Screenshot Utilities
    
    private func captureScreenshot(name: String, description: String) async {
        let screenshot = app.screenshot()
        let filename = "\(String(format: "%02d", screenshotIndex))_\(name).png"
        let filepath = "\(outputDirectory)/\(filename)"
        
        do {
            try screenshot.pngRepresentation.write(to: URL(fileURLWithPath: filepath))
            print("📸 \(filename): \(description)")
        } catch {
            print("❌ Failed to save \(filename): \(error.localizedDescription)")
        }
        
        screenshotIndex += 1
        
        // Small delay between screenshots
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    private func createOutputDirectory() throws {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: outputDirectory) {
            try fileManager.removeItem(atPath: outputDirectory)
        }
        
        try fileManager.createDirectory(atPath: outputDirectory, withIntermediateDirectories: true, attributes: nil)
        print("📁 Created output directory: \(outputDirectory)")
    }
}

// MARK: - Main Execution

@MainActor
func main() async {
    let capture = AppScreenshotCapture()
    
    do {
        try await capture.captureFullAppCatalog()
    } catch {
        print("❌ Screenshot capture failed: \(error.localizedDescription)")
        exit(1)
    }
}

await main()
//
// Helpers.swift
// NestoryUITests
//
// General UI test helper functions and utilities
//

@preconcurrency import XCTest

// MARK: - Test Data Helpers

struct TestDataHelper {
    
    /// Generate unique test item name
    static func uniqueItemName(prefix: String = "TestItem") -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        return "\(prefix)_\(timestamp)"
    }
    
    /// Generate test item data
    static func sampleItemData() -> [String: Any] {
        return [
            "name": uniqueItemName(),
            "category": "Electronics",
            "value": 299.99,
            "description": "Test item for UI testing"
        ]
    }
    
    /// Generate multiple test items
    static func multipleSampleItems(count: Int = 3) -> [[String: Any]] {
        return (1...count).map { index in
            return [
                "name": uniqueItemName(prefix: "TestItem\(index)"),
                "category": ["Electronics", "Furniture", "Clothing"][index % 3],
                "value": Double(100 + index * 50),
                "description": "Test item \(index) for UI testing"
            ]
        }
    }
}

// MARK: - Screenshot Helpers

struct BasicScreenshotHelper {
    
    /// Take screenshot with timestamp
    @MainActor
    static func takeScreenshot(
        of app: XCUIApplication,
        named name: String,
        in testCase: XCTestCase
    ) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        let timestamp = DateFormatter.timestamp.string(from: Date())
        attachment.name = "\(name)_\(timestamp)"
        attachment.lifetime = .keepAlways
        testCase.add(attachment)
    }
    
    /// Take screenshot of specific element
    @MainActor
    static func takeScreenshot(
        of element: XCUIElement,
        named name: String,
        in testCase: XCTestCase
    ) {
        let screenshot = element.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        let timestamp = DateFormatter.timestamp.string(from: Date())
        attachment.name = "\(name)_element_\(timestamp)"
        attachment.lifetime = .keepAlways
        testCase.add(attachment)
    }
}

// MARK: - Wait Helpers

struct WaitHelper {
    
    /// Default timeout values
    enum Timeout {
        static let short: TimeInterval = 3.0
        static let medium: TimeInterval = 10.0
        static let long: TimeInterval = 30.0
    }
    
    /// Wait for multiple elements to appear
    @MainActor
    static func waitForElements(
        _ elements: [XCUIElement],
        timeout: TimeInterval = Timeout.medium
    ) -> Bool {
        let endTime = Date().addingTimeInterval(timeout)
        
        while Date() < endTime {
            let allExist = elements.allSatisfy { $0.exists }
            if allExist {
                return true
            }
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.1))
        }
        
        return false
    }
    
    /// Wait for loading to complete
    @MainActor
    static func waitForLoadingToComplete(
        in app: XCUIApplication,
        timeout: TimeInterval = Timeout.medium
    ) {
        let endTime = Date().addingTimeInterval(timeout)
        
        while Date() < endTime {
            let loadingIndicators = app.activityIndicators.allElementsBoundByIndex
            let hasLoadingIndicators = loadingIndicators.contains { $0.exists }
            
            if !hasLoadingIndicators {
                return
            }
            
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.1))
        }
    }
}

// MARK: - Navigation Helpers

struct BasicNavigationHelper {
    
    /// Navigate to specific tab
    @MainActor
    static func navigateToTab(
        named tabName: String,
        in app: XCUIApplication,
        timeout: TimeInterval = WaitHelper.Timeout.medium
    ) -> Bool {
        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: timeout) else {
            return false
        }
        
        let tabButton = tabBar.buttons[tabName]
        guard tabButton.exists && tabButton.isHittable else {
            return false
        }
        
        tabButton.tap()
        return tabButton.waitUntilSelected(timeout: WaitHelper.Timeout.short)
    }
    
    /// Go back using navigation
    @MainActor
    static func goBack(in app: XCUIApplication) -> Bool {
        // Try navigation back button
        let backButton = app.navigationBars.buttons.firstMatch
        if backButton.exists && backButton.isHittable {
            backButton.tap()
            return true
        }
        
        // Try swipe back gesture
        app.swipeRight()
        return true
    }
}

// MARK: - Assertion Helpers

struct AssertionHelper {
    
    /// Assert element is visible and ready
    @MainActor
    static func assertElementReady(
        _ element: XCUIElement,
        timeout: TimeInterval = WaitHelper.Timeout.medium,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exists = element.waitForExistence(timeout: timeout)
        XCTAssertTrue(exists, "Element should exist", file: file, line: line)
        XCTAssertTrue(element.isHittable, "Element should be hittable", file: file, line: line)
    }
    
    /// Assert text appears somewhere in the app
    @MainActor
    static func assertTextVisible(
        _ text: String,
        in app: XCUIApplication,
        timeout: TimeInterval = WaitHelper.Timeout.medium,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
        let elements = app.descendants(matching: .any).matching(predicate)
        let exists = elements.firstMatch.waitForExistence(timeout: timeout)
        XCTAssertTrue(exists, "Text '\(text)' should be visible", file: file, line: line)
    }
}

// MARK: - DateFormatter Extension

private extension DateFormatter {
    static let timestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()
}
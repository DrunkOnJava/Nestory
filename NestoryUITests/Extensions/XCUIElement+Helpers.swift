//
//  XCUIElement+Helpers.swift
//  NestoryUITests
//
//  Helper extensions for UI testing
//

import XCTest

extension XCUIElement {
    
    /// Wait for element to exist with custom timeout
    func waitForExistence(timeout: TimeInterval = 5) -> Bool {
        return waitForExistence(timeout: timeout)
    }
    
    /// Tap element if it exists
    func tapIfExists() {
        if exists {
            tap()
        }
    }
    
    /// Scroll to element if needed
    func scrollToElement(in scrollView: XCUIElement? = nil) {
        let scrollElement = scrollView ?? XCUIApplication().scrollViews.firstMatch
        
        var attempts = 0
        while !isHittable && attempts < 5 {
            scrollElement.swipeUp()
            attempts += 1
        }
    }
    
    /// Type text with clearing existing content first
    func clearAndTypeText(_ text: String) {
        tap()
        
        // Select all text
        if let currentValue = value as? String, !currentValue.isEmpty {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
            typeText(deleteString)
        }
        
        typeText(text)
    }
    
    /// Wait for element to be hittable
    func waitToBeHittable(timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Force tap even if element is not hittable
    func forceTap() {
        coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }
    
    /// Check if element contains text
    func containsText(_ text: String) -> Bool {
        if label.contains(text) {
            return true
        }
        if let value = value as? String, value.contains(text) {
            return true
        }
        return false
    }
}

extension XCUIApplication {
    
    /// Dismiss keyboard if visible
    func dismissKeyboard() {
        if keyboards.element(boundBy: 0).exists {
            // Try tapping done button first
            keyboards.buttons["Done"].tapIfExists()
            
            // If still visible, tap outside
            if keyboards.element(boundBy: 0).exists {
                swipeDown()
            }
        }
    }
    
    /// Wait for app to be in foreground state
    func waitForAppToLoad(timeout: TimeInterval = 10) -> Bool {
        return wait(for: .runningForeground, timeout: timeout)
    }
    
    /// Take screenshot with descriptive name
    func takeScreenshot(name: String) {
        let screenshot = XCTAttachment(screenshot: self.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        XCTContext.runActivity(named: "Screenshot: \(name)") { activity in
            activity.add(screenshot)
        }
    }
    
    /// Handle system alerts
    func handleSystemAlert(action: String = "Allow") {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alertButton = springboard.buttons[action]
        if alertButton.waitForExistence(timeout: 2) {
            alertButton.tap()
        }
    }
}
//
// Extensions.swift
// NestoryUITests
//
// Common extensions for UI testing
//

@preconcurrency import XCTest

// MARK: - XCUIElement Extensions

extension XCUIElement {
    
    /// Check if element is ready for interaction
    var isReady: Bool {
        return exists && isHittable && !isLoadingIndicator
    }
    
    /// Check if element is a loading indicator
    private var isLoadingIndicator: Bool {
        return elementType == .activityIndicator
    }
    
    /// Tap element with retry logic
    func tapWithRetry(maxAttempts: Int = 3, delay: TimeInterval = 0.5) {
        for attempt in 1...maxAttempts {
            if exists && isHittable {
                tap()
                return
            }
            if attempt < maxAttempts {
                Thread.sleep(forTimeInterval: delay)
            }
        }
    }
}

// MARK: - XCTestCase Extensions

extension XCTestCase {
    
    /// Run test activity with proper error handling
    @MainActor
    func runTestActivity<T: Sendable>(named name: String, block: () throws -> T) rethrows -> T {
        return try XCTContext.runActivity(named: name) { _ in
            try block()
        }
    }
    
    /// Wait with custom timeout and better error messages
    func waitForCondition(
        timeout: TimeInterval = 10.0,
        description: String = "Condition",
        condition: () -> Bool
    ) -> Bool {
        let endTime = Date().addingTimeInterval(timeout)
        
        while Date() < endTime {
            if condition() {
                return true
            }
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.1))
        }
        
        XCTFail("Timeout waiting for: \(description)")
        return false
    }
}

// MARK: - XCUIApplication Extensions

extension XCUIApplication {
    
    /// Wait for app to be fully loaded
    func waitForAppToBeReady(timeout: TimeInterval = 15.0) -> Bool {
        // Wait for app state
        guard wait(for: .runningForeground, timeout: timeout) else {
            return false
        }
        
        // Wait for main window
        let mainWindow = windows.firstMatch
        return mainWindow.waitForExistence(timeout: 5.0)
    }
    
    /// Check if app is in a good state for testing
    var isReadyForTesting: Bool {
        return state == .runningForeground && windows.count > 0
    }
    
    // MARK: - Navigation Helper Methods
    
    /// Navigate to inventory list
    func navigateToInventoryList() {
        let inventoryTab = tabBars.buttons["Inventory"].firstMatch
        if inventoryTab.exists {
            inventoryTab.tap()
            _ = inventoryTab.waitUntilSelected(timeout: 3.0)
        }
    }
    
    /// Navigate to analytics dashboard
    func navigateToAnalytics() {
        let analyticsTab = tabBars.buttons["Analytics"].firstMatch
        if analyticsTab.exists {
            analyticsTab.tap()
            _ = analyticsTab.waitUntilSelected(timeout: 3.0)
        }
    }
    
    /// Navigate to settings
    func navigateToSettings() {
        let settingsTab = tabBars.buttons["Settings"].firstMatch
        if settingsTab.exists {
            settingsTab.tap()
            _ = settingsTab.waitUntilSelected(timeout: 3.0)
        }
    }
}

// MARK: - String Extensions

extension String {
    
    /// Generate accessibility identifier
    var accessibilityIdentifier: String {
        return self.lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
    }
    
    /// Truncate string for test names
    func truncated(to length: Int = 50) -> String {
        return self.count > length ? String(self.prefix(length)) + "..." : self
    }
}
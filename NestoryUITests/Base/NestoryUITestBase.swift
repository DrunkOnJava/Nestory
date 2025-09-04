//
// NestoryUITestBase.swift
// NestoryUITests
//
// Base class for all UI tests with common setup and utilities
//

@preconcurrency import XCTest

/// Base class providing common UI test functionality
@MainActor
class NestoryUITestBase: XCTestCase {
    
    // MARK: - Properties
    
    var app: XCUIApplication!
    
    /// Current device type for conditional testing
    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// Test environment configuration
    struct TestConfig {
        static let defaultTimeout: TimeInterval = 10.0
        static let shortTimeout: TimeInterval = 3.0
        static let longTimeout: TimeInterval = 30.0
        static let animationDelay: TimeInterval = 0.5
    }
    
    // MARK: - Setup & Teardown
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Continue testing after failures for comprehensive results
        continueAfterFailure = false
        
        // Initialize app with test configuration
        app = XCUIApplication()
        setupTestEnvironment()
    }
    
    override func tearDown() async throws {
        // Capture screenshot on failure
        if testRun?.hasBeenSkipped == false && testRun?.hasSucceeded == false {
            captureFailureScreenshot()
        }
        
        app = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Environment Setup
    
    /// Configure app for UI testing
    private func setupTestEnvironment() {
        // Standard test arguments
        app.launchArguments = [
            "UITEST_MODE",
            "DISABLE_ANIMATIONS",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
        
        // Test environment variables
        app.launchEnvironment = [
            "UI_TESTING": "1",
            "DISABLE_NETWORK": "0",
            "CLEAR_KEYCHAIN": "1",
            "RESET_USER_DEFAULTS": "1"
        ]
    }
    
    /// Launch app with optional additional configuration
    func launchApp(with additionalArgs: [String] = [], 
                   environment: [String: String] = [:]) {
        app.launchArguments.append(contentsOf: additionalArgs)
        app.launchEnvironment.merge(environment) { _, new in new }
        app.launch()
        
        // Wait for app to be ready
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: TestConfig.defaultTimeout))
    }
    
    // MARK: - Navigation Helpers
    
    /// Navigate to a specific tab by index
    func navigateToTab(at index: Int) {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: TestConfig.shortTimeout))
        
        let button = tabBar.buttons.element(boundBy: index)
        XCTAssertTrue(button.exists && button.isHittable)
        
        button.tap()
        
        // Verify selection
        XCTAssertTrue(button.waitUntilSelected(timeout: TestConfig.shortTimeout),
                      "Tab at index \(index) should be selected")
    }
    
    /// Navigate to a specific tab by label
    func navigateToTab(named label: String) {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: TestConfig.shortTimeout))
        
        let button = tabBar.buttons[label]
        XCTAssertTrue(button.exists && button.isHittable, "Tab '\(label)' should exist")
        
        button.tap()
        
        // Verify selection
        XCTAssertTrue(button.waitUntilSelected(timeout: TestConfig.shortTimeout),
                      "Tab '\(label)' should be selected")
    }
    
    // MARK: - Element Waiting
    
    /// Wait for element with predicate
    func waitForElement(_ element: XCUIElement,
                       predicate: String = "exists == true",
                       timeout: TimeInterval? = nil) -> Bool {
        let pred = NSPredicate(format: predicate)
        let expectation = XCTNSPredicateExpectation(predicate: pred, object: element)
        let result = XCTWaiter().wait(for: [expectation], 
                                      timeout: timeout ?? TestConfig.defaultTimeout)
        return result == .completed
    }
    
    /// Wait for loading indicators to disappear
    func waitForLoadingToComplete(timeout: TimeInterval? = nil) {
        let indicators = app.activityIndicators
        let deadline = Date().addingTimeInterval(timeout ?? TestConfig.defaultTimeout)
        
        while Date() < deadline {
            if !indicators.allElementsBoundByIndex.contains(where: { $0.exists }) {
                return
            }
            RunLoop.current.run(mode: .default, 
                               before: Date().addingTimeInterval(0.1))
        }
    }
    
    // MARK: - Screenshot Helpers
    
    /// Capture screenshot with metadata
    @discardableResult
    func captureScreenshot(name: String,
                          lifetime: XCTAttachment.Lifetime = .keepAlways) -> XCTAttachment {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = lifetime
        add(attachment)
        return attachment
    }
    
    /// Capture screenshot on test failure
    private func captureFailureScreenshot() {
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Failure_\(name)_\(Date().timeIntervalSince1970)"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
    
    // MARK: - Assertion Helpers
    
    /// Assert element is visible and interactable
    func assertElementReady(_ element: XCUIElement,
                           timeout: TimeInterval? = nil,
                           message: String? = nil) {
        let exists = waitForElement(element, 
                                   predicate: "exists == true AND isHittable == true",
                                   timeout: timeout)
        XCTAssertTrue(exists, message ?? "Element should be ready: \(element)")
    }
    
    /// Assert text exists anywhere in the view
    func assertTextExists(_ text: String, 
                         timeout: TimeInterval? = nil) {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
        let elements = app.descendants(matching: .any).matching(predicate)
        XCTAssertTrue(elements.firstMatch.waitForExistence(timeout: timeout ?? TestConfig.defaultTimeout),
                      "Text '\(text)' should exist")
    }
    
    // MARK: - Data Helpers
    
    /// Generate unique test data identifier
    func uniqueTestId(_ prefix: String = "Test") -> String {
        "\(prefix)_\(UUID().uuidString.prefix(8))"
    }
    
    /// Current timestamp for naming
    var timestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: Date())
    }
    
    // MARK: - Activity Helpers
    
    /// Run test step with activity logging
    func runActivity<T: Sendable>(named name: String, 
                        block: () throws -> T) rethrows -> T {
        try XCTContext.runActivity(named: name) { _ in
            try block()
        }
    }
    
    /// Run async test step with activity logging
    func runActivity<T: Sendable>(named name: String,
                        block: () async throws -> T) async rethrows -> T {
        let result = try await block()
        XCTContext.runActivity(named: name) { _ in
            // Activity completion logged
        }
        return result
    }
}
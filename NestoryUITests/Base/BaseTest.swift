//
// BaseTest.swift
// NestoryUITests
//
// Alternative base test class for specific testing patterns
//

@preconcurrency import XCTest

@MainActor
class BaseTest: XCTestCase {
    
    // MARK: - Properties
    
    var app: XCUIApplication!
    
    // MARK: - Constants
    
    struct TestConstants {
        static let defaultTimeout: TimeInterval = 10.0
        static let shortTimeout: TimeInterval = 3.0
        static let longTimeout: TimeInterval = 30.0
    }
    
    // MARK: - Setup
    
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        configureTestEnvironment()
    }
    
    override func tearDown() async throws {
        app = nil
        try await super.tearDown()
    }
    
    // MARK: - Configuration
    
    private func configureTestEnvironment() {
        app.launchArguments = [
            "UITEST_MODE",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
        
        app.launchEnvironment = [
            "UI_TESTING": "1",
            "RESET_USER_DEFAULTS": "1"
        ]
    }
    
    // MARK: - Helpers
    
    func launchAppAndWait() {
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: TestConstants.defaultTimeout))
    }
    
    func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = TestConstants.defaultTimeout) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
    
    func tapElementIfExists(_ element: XCUIElement) -> Bool {
        guard element.exists && element.isHittable else { return false }
        element.tap()
        return true
    }
}
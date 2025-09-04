//
// TestFramework.swift
// NestoryUITests
//
// Core testing framework and infrastructure
//

@preconcurrency import XCTest

// MARK: - Test Framework Configuration

struct TestFrameworkConfig {
    static let defaultTimeout: TimeInterval = 10.0
    static let longTimeout: TimeInterval = 30.0
    static let shortTimeout: TimeInterval = 3.0
    static let animationDelay: TimeInterval = 0.5
    
    static let supportedDevices = [
        "iPhone 16 Pro Max",
        "iPhone 16 Pro", 
        "iPad Pro 13-inch M4"
    ]
}

// MARK: - Test Framework Protocol

@MainActor
protocol TestFrameworkProtocol {
    var app: XCUIApplication! { get set }
    
    func setupTestEnvironment()
    func teardownTestEnvironment() 
    func launchAppForTesting()
    func captureTestArtifacts()
}

// MARK: - Base Test Framework

@MainActor
class TestFramework: NSObject, TestFrameworkProtocol {
    
    // MARK: - Properties
    
    var app: XCUIApplication!
    private let testCase: XCTestCase
    
    // MARK: - Initialization
    
    init(testCase: XCTestCase) {
        self.testCase = testCase
        super.init()
    }
    
    // MARK: - Framework Protocol Implementation
    
    func setupTestEnvironment() {
        app = XCUIApplication()
        configureAppForTesting()
    }
    
    func teardownTestEnvironment() {
        captureTestArtifacts()
        app = nil
    }
    
    func launchAppForTesting() {
        app.launch()
        
        // Verify app launched successfully
        guard app.wait(for: .runningForeground, timeout: TestFrameworkConfig.defaultTimeout) else {
            XCTFail("App failed to launch within timeout")
            return
        }
        
        // Wait for UI to be ready
        waitForUIToBeReady()
    }
    
    func captureTestArtifacts() {
        // Capture screenshot on test completion
        if let testRun = testCase.testRun,
           !testRun.hasSucceeded && !testRun.hasBeenSkipped {
            captureFailureScreenshot()
        }
    }
    
    // MARK: - Configuration
    
    private func configureAppForTesting() {
        // Standard test configuration
        app.launchArguments = [
            "UITEST_MODE",
            "DISABLE_ANIMATIONS",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
        
        app.launchEnvironment = [
            "UI_TESTING": "1",
            "RESET_USER_DEFAULTS": "1",
            "CLEAR_KEYCHAIN": "1",
            "DISABLE_NETWORK": "0"
        ]
    }
    
    private func waitForUIToBeReady() {
        // Wait for main UI elements to be ready
        let mainWindow = app.windows.firstMatch
        _ = mainWindow.waitForExistence(timeout: TestFrameworkConfig.defaultTimeout)
        
        // Wait for any loading indicators to disappear
        waitForLoadingToComplete()
    }
    
    private func waitForLoadingToComplete() {
        let deadline = Date().addingTimeInterval(TestFrameworkConfig.longTimeout)
        
        while Date() < deadline {
            let loadingIndicators = app.activityIndicators.allElementsBoundByIndex
            let hasActiveIndicators = loadingIndicators.contains { $0.exists }
            
            if !hasActiveIndicators {
                break
            }
            
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.1))
        }
    }
    
    // MARK: - Test Artifacts
    
    private func captureFailureScreenshot() {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        let timestamp = Int(Date().timeIntervalSince1970)
        attachment.name = "TestFailure_\(testCase.name)_\(timestamp)"
        attachment.lifetime = .keepAlways
        testCase.add(attachment)
    }
}

// MARK: - Test Framework Extensions

extension TestFramework {
    
    /// Wait for element with enhanced error messaging
    func waitForElement(
        _ element: XCUIElement,
        timeout: TimeInterval = TestFrameworkConfig.defaultTimeout,
        description: String = ""
    ) -> Bool {
        let exists = element.waitForExistence(timeout: timeout)
        if !exists {
            let message = description.isEmpty ? "Element" : description
            print("⚠️ Timeout waiting for: \(message)")
        }
        return exists
    }
    
    /// Execute test step with activity logging
    func executeTestStep<T>(
        named stepName: String,
        action: () throws -> T
    ) rethrows -> T {
        return try XCTContext.runActivity(named: stepName) { _ in
            print("🧪 Executing: \(stepName)")
            return try action()
        }
    }
    
    /// Navigate safely with error handling
    func navigateToScreen(
        identifier: String,
        timeout: TimeInterval = TestFrameworkConfig.defaultTimeout
    ) -> Bool {
        let element = app.buttons[identifier]
        guard waitForElement(element, timeout: timeout, description: "Navigation button '\(identifier)'") else {
            return false
        }
        
        element.tap()
        
        // Brief wait for navigation to complete
        Thread.sleep(forTimeInterval: TestFrameworkConfig.animationDelay)
        return true
    }
}
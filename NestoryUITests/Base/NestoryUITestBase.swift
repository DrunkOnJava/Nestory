//
// NestoryUITestBase.swift
// NestoryUITests
//
// Base class for all UI tests with Swift 6 concurrency compliance
// Provides thread-safe infrastructure and consistent test patterns
//

import XCTest

/// Base class for all Nestory UI tests with Swift 6 concurrency compliance
class NestoryUITestBase: XCTestCase {
    // MARK: - Properties

    /// The main application instance - accessed through MainActor isolation
    @MainActor private var _app: XCUIApplication?

    /// Screenshot manager for thread-safe screenshot operations
    @MainActor private var _screenshotManager: ScreenshotManager?

    /// Safe accessor for app instance
    @MainActor var app: XCUIApplication {
        guard let app = _app else {
            fatalError("App not initialized. Call setupApp() first.")
        }
        return app
    }

    /// Safe accessor for screenshot manager
    @MainActor var screenshotManager: ScreenshotManager {
        guard let manager = _screenshotManager else {
            fatalError("ScreenshotManager not initialized. Call setupApp() first.")
        }
        return manager
    }

    /// Test configuration settings
    enum TestConfig {
        static let defaultTimeout: TimeInterval = 10.0
        static let shortTimeout: TimeInterval = 3.0
        static let longTimeout: TimeInterval = 30.0
        static let animationDelay: TimeInterval = 0.5
    }

    // MARK: - Lifecycle

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Configure test execution
        continueAfterFailure = false

        // Setup app and dependencies using MainActor isolation
        Task { @MainActor in
            await setupApp()
        }

        print("🚀 Test setup completed for: \(name)")
    }

    /// Setup application and dependencies with proper MainActor isolation
    @MainActor
    private func setupApp() async {
        // Initialize application
        let application = XCUIApplication()

        // Configure launch arguments for UI testing
        application.launchArguments = [
            "--uitesting",
            "--disable-animations", // Reduce flakiness
            "--reset-state", // Start with clean state
        ]

        // Configure launch environment
        application.launchEnvironment = [
            "UITEST_MODE": "1",
            "ANIMATION_SPEED": "0.1",
        ]

        // Initialize screenshot manager
        _screenshotManager = ScreenshotManager()

        // Launch application
        application.launch()

        // Wait for app to be ready
        _ = application.wait(for: .runningForeground, timeout: TestConfig.defaultTimeout)

        // Assign after successful setup
        _app = application
    }

    override func tearDownWithError() throws {
        // Cleanup using MainActor isolation
        Task { @MainActor in
            await cleanupApp()
        }

        try super.tearDownWithError()

        print("🧹 Test teardown completed for: \(name)")
    }

    /// Cleanup application and dependencies with proper MainActor isolation
    @MainActor
    private func cleanupApp() async {
        // Capture final screenshot if test failed
        if let testRun, testRun.hasSucceeded == false {
            await captureFailureScreenshot()
        }

        // Cleanup
        _screenshotManager = nil
        _app?.terminate()
        _app = nil
    }

    // MARK: - Screenshot Management

    /// Capture a screenshot with the given name
    /// - Parameter name: The name for the screenshot
    @MainActor
    func captureScreenshot(_ name: String) async {
        await screenshotManager.captureScreenshot(
            from: app,
            name: name,
            testCase: self,
        )
    }

    /// Capture a screenshot when test fails
    @MainActor
    private func captureFailureScreenshot() async {
        let failureName = "FAILURE_\(name)_\(Date().timeIntervalSince1970)"
        await captureScreenshot(failureName)
    }

    // MARK: - Wait Helpers

    /// Wait for element to exist with timeout
    /// - Parameters:
    ///   - element: The element to wait for
    ///   - timeout: Maximum time to wait
    /// - Returns: True if element exists within timeout
    @MainActor
    func waitForElement(
        _ element: XCUIElement,
        timeout: TimeInterval = TestConfig.defaultTimeout,
    ) -> Bool {
        element.waitForExistence(timeout: timeout)
    }

    /// Wait for element to be hittable
    /// - Parameters:
    ///   - element: The element to wait for
    ///   - timeout: Maximum time to wait
    /// - Returns: True if element becomes hittable
    @MainActor
    func waitForElementHittable(
        _ element: XCUIElement,
        timeout: TimeInterval = TestConfig.defaultTimeout,
    ) -> Bool {
        let predicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }

    /// Safe tap with retry mechanism
    /// - Parameters:
    ///   - element: Element to tap
    ///   - retries: Number of retry attempts
    ///   - delay: Delay between retries
    @MainActor
    func safeTap(
        _ element: XCUIElement,
        retries: Int = 3,
        delay: TimeInterval = 0.5,
    ) {
        for attempt in 0 ..< retries {
            if element.exists, element.isHittable {
                element.tap()
                return
            }

            if attempt < retries - 1 {
                Thread.sleep(forTimeInterval: delay)
            }
        }

        XCTFail("Failed to tap element after \(retries) attempts: \(element)")
    }

    // MARK: - Navigation Helpers

    /// Navigate to a specific tab
    /// - Parameter tabName: Name of the tab to navigate to
    @MainActor
    func navigateToTab(_ tabName: String) {
        let tabButton = app.tabBars.buttons[tabName]
        XCTAssertTrue(waitForElement(tabButton), "Tab '\(tabName)' should exist")
        safeTap(tabButton)

        // Wait for navigation to complete
        Thread.sleep(forTimeInterval: TestConfig.animationDelay)
    }

    /// Verify navigation bar title
    /// - Parameter title: Expected navigation bar title
    @MainActor
    func verifyNavigationTitle(_ title: String) {
        let navigationBar = app.navigationBars[title]
        XCTAssertTrue(
            waitForElement(navigationBar),
            "Navigation bar with title '\(title)' should exist",
        )
    }

    // MARK: - Assertion Helpers

    /// Assert element exists with custom message
    /// - Parameters:
    ///   - element: Element to check
    ///   - message: Custom failure message
    func assertExists(
        _ element: XCUIElement,
        _ message: String = "",
    ) {
        XCTAssertTrue(
            element.exists,
            message.isEmpty ? "Element should exist" : message,
        )
    }

    /// Assert element is hittable
    /// - Parameters:
    ///   - element: Element to check
    ///   - message: Custom failure message
    func assertHittable(
        _ element: XCUIElement,
        _ message: String = "",
    ) {
        XCTAssertTrue(
            element.isHittable,
            message.isEmpty ? "Element should be hittable" : message,
        )
    }

    // MARK: - Debugging Helpers

    /// Print current UI hierarchy for debugging
    @MainActor
    func printUIHierarchy() {
        print("🔍 Current UI Hierarchy:")
        print(app.debugDescription)
    }

    /// Log test progress
    /// - Parameter message: Progress message
    func logProgress(_ message: String) {
        print("📋 [\(name)] \(message)")
    }
}

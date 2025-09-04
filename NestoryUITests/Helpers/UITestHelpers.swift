//
// UITestHelpers.swift
// NestoryUITests
//
// Comprehensive UI testing helpers with Swift 6 concurrency compliance
// Provides reliable element queries, timeouts, and interaction patterns
//

@preconcurrency import XCTest

// MARK: - Element Query Extensions

@MainActor
extension XCUIApplication {
    /// Find tab bar button with enhanced error handling
    /// - Parameter name: Tab name to find
    /// - Returns: The tab bar button element
    func tabBarButton(_ name: String) -> XCUIElement {
        tabBars.buttons[name]
    }

    /// Find navigation bar with title
    /// - Parameter title: Navigation bar title
    /// - Returns: The navigation bar element
    func navigationBar(_ title: String) -> XCUIElement {
        navigationBars[title]
    }

    /// Find button with enhanced accessibility
    /// - Parameter identifier: Button identifier or label
    /// - Returns: The button element
    func findButton(_ identifier: String) -> XCUIElement {
        // Try accessibility identifier first
        let byIdentifier = buttons[identifier]
        if byIdentifier.exists {
            return byIdentifier
        }

        // Try by label
        let byLabel = buttons.matching(identifier: identifier).firstMatch
        if byLabel.exists {
            return byLabel
        }

        // Return the first match for error reporting
        return byIdentifier
    }

    /// Find text field with fallback strategies
    /// - Parameter identifier: Text field identifier
    /// - Returns: The text field element
    func findTextField(_ identifier: String) -> XCUIElement {
        let byIdentifier = textFields[identifier]
        if byIdentifier.exists {
            return byIdentifier
        }

        let byPlaceholder = textFields.matching(
            NSPredicate(format: "placeholderValue CONTAINS %@", identifier),
        ).firstMatch
        if byPlaceholder.exists {
            return byPlaceholder
        }

        return byIdentifier
    }
}

// MARK: - Element Interaction Extensions

@MainActor
extension XCUIElement {
    /// Enhanced tap with retry and validation
    /// - Parameters:
    ///   - retries: Number of retry attempts
    ///   - delay: Delay between retries
    func safeTap(retries: Int = 3, delay: TimeInterval = 0.5) {
        for attempt in 0 ..< retries {
            if exists, isHittable {
                tap()
                return
            }

            if attempt < retries - 1 {
                Thread.sleep(forTimeInterval: delay)
            }
        }

        XCTFail("Failed to tap element after \(retries) attempts. Element exists: \(exists), isHittable: \(isHittable)")
    }

    /// Type text with clearing existing content (alternate implementation)
    /// - Parameter text: Text to type
    func clearTextAndType(_ text: String) {
        tap()

        // Select all and delete
        if value != nil {
            let selectAllMenuItem = XCUIApplication().menuItems["Select All"]
            if selectAllMenuItem.exists {
                selectAllMenuItem.tap()
            } else {
                // Fallback: use keyboard shortcut
                typeText(XCUIKeyboardKey.command.rawValue + "a")
            }
        }

        typeText(text)
    }

    /// Wait for element with multiple conditions
    /// - Parameters:
    ///   - timeout: Maximum wait time
    ///   - conditions: Additional conditions to check
    /// - Returns: True if all conditions are met
    func waitForConditions(
        timeout: TimeInterval = 10.0,
        conditions: [(XCUIElement) -> Bool] = [],
    ) -> Bool {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            if exists, conditions.allSatisfy({ $0(self) }) {
                return true
            }
            Thread.sleep(forTimeInterval: 0.1)
        }

        return false
    }

    /// Scroll to make element visible
    /// - Parameter direction: Scroll direction
    func scrollToVisible(direction: ScrollDirection = .down) {
        guard !isHittable else { return }

        let app = XCUIApplication()
        let scrollView = app.scrollViews.firstMatch

        if scrollView.exists {
            var attempts = 0
            let maxAttempts = 10

            while !isHittable, attempts < maxAttempts {
                switch direction {
                case .up:
                    scrollView.swipeDown()
                case .down:
                    scrollView.swipeUp()
                case .left:
                    scrollView.swipeRight()
                case .right:
                    scrollView.swipeLeft()
                }

                attempts += 1
                Thread.sleep(forTimeInterval: 0.3)
            }
        }
    }
}

// MARK: - Scroll Direction

enum ScrollDirection {
    case up, down, left, right
}

// MARK: - Wait Helpers

@MainActor
struct WaitHelpers {
    /// Wait for multiple elements to exist
    /// - Parameters:
    ///   - elements: Array of elements to wait for
    ///   - timeout: Maximum wait time
    /// - Returns: True if all elements exist within timeout
    static func waitForElements(
        _ elements: [XCUIElement],
        timeout: TimeInterval = 10.0,
    ) -> Bool {
        let start = Date()
        repeat {
            if elements.allSatisfy({ $0.exists }) {
                return true
            }
            Thread.sleep(forTimeInterval: 0.1)
        } while Date().timeIntervalSince(start) < timeout
        return false
    }

    /// Wait for element to disappear
    /// - Parameters:
    ///   - element: Element to wait for disappearance
    ///   - timeout: Maximum wait time
    /// - Returns: True if element disappears within timeout
    static func waitForElementToDisappear(
        _ element: XCUIElement,
        timeout: TimeInterval = 10.0,
    ) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }

    /// Wait for app to be ready after navigation
    /// - Parameters:
    ///   - app: The application instance
    ///   - timeout: Maximum wait time
    static func waitForAppReady(
        _ app: XCUIApplication,
        timeout: TimeInterval = 5.0,
    ) {
        // Wait for app to be in foreground
        _ = app.wait(for: .runningForeground, timeout: timeout)

        // Additional settling time for animations
        Thread.sleep(forTimeInterval: 0.5)
    }
}

// MARK: - Assertion Helpers

@MainActor
struct AssertionHelpers {
    /// Assert element exists with enhanced error reporting
    /// - Parameters:
    ///   - element: Element to check
    ///   - message: Custom message
    ///   - file: Source file
    ///   - line: Source line
    static func assertExists(
        _ element: XCUIElement,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line,
    ) {
        let elementDescription = """
        Element: \(element)
        Exists: \(element.exists)
        Frame: \(element.frame)
        """

        let fullMessage = message.isEmpty
            ? "Element should exist\n\(elementDescription)"
            : "\(message)\n\(elementDescription)"

        XCTAssertTrue(element.exists, fullMessage, file: file, line: line)
    }

    /// Assert element is hittable with context
    /// - Parameters:
    ///   - element: Element to check
    ///   - message: Custom message
    ///   - file: Source file
    ///   - line: Source line
    static func assertHittable(
        _ element: XCUIElement,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line,
    ) {
        let elementDescription = """
        Element: \(element)
        Exists: \(element.exists)
        IsHittable: \(element.isHittable)
        IsEnabled: \(element.isEnabled)
        Frame: \(element.frame)
        """

        let fullMessage = message.isEmpty
            ? "Element should be hittable\n\(elementDescription)"
            : "\(message)\n\(elementDescription)"

        XCTAssertTrue(element.isHittable, fullMessage, file: file, line: line)
    }

    /// Assert navigation completed successfully
    /// - Parameters:
    ///   - expectedTitle: Expected navigation title
    ///   - app: Application instance
    ///   - timeout: Wait timeout
    static func assertNavigationCompleted(
        expectedTitle: String,
        app: XCUIApplication,
        timeout: TimeInterval = 5.0,
    ) {
        let navigationBar = app.navigationBars[expectedTitle]

        XCTAssertTrue(
            navigationBar.waitForExistence(timeout: timeout),
            "Navigation to '\(expectedTitle)' should complete within \(timeout) seconds",
        )
    }
}

// MARK: - Debug Helpers

@MainActor
struct DebugHelpers {
    /// Print detailed element information
    /// - Parameter element: Element to inspect
    static func inspectElement(_ element: XCUIElement) {
        print("""
        🔍 Element Inspection:
        - Description: \(element)
        - Exists: \(element.exists)
        - IsHittable: \(element.isHittable)
        - IsEnabled: \(element.isEnabled)
        - Frame: \(element.frame)
        - Value: \(element.value ?? "nil")
        - Label: \(element.label)
        - Identifier: \(element.identifier)
        """)
    }

    /// Print application state
    /// - Parameter app: Application to inspect
    static func inspectAppState(_ app: XCUIApplication) {
        print("""
        📱 App State:
        - State: \(app.state.rawValue)
        - Launch Arguments: \(app.launchArguments)
        - Launch Environment: \(app.launchEnvironment)
        """)
    }

    /// Dump UI hierarchy to console
    /// - Parameter app: Application instance
    static func dumpUIHierarchy(_ app: XCUIApplication) {
        print("🌳 UI Hierarchy:")
        print(app.debugDescription)
    }
}

// Convenience global wrappers expected by tests
@MainActor
func measureTime<T: Sendable>(_ operation: () throws -> T) rethrows -> (result: T, time: TimeInterval) {
    try PerformanceHelpers.measureTime(operation)
}

@MainActor
func measureAsyncTime<T: Sendable>(_ operation: () async throws -> T) async rethrows -> (result: T, time: TimeInterval) {
    try await PerformanceHelpers.measureAsyncTime(operation)
}

@MainActor
struct PerformanceHelpers {
    /// Measure time for UI operation
    /// - Parameter operation: Operation to measure
    /// - Returns: Time taken in seconds
    static func measureTime<T: Sendable>(_ operation: () throws -> T) rethrows -> (result: T, time: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return (result, timeElapsed)
    }

    /// Measure async operation time
    /// - Parameter operation: Async operation to measure
    /// - Returns: Time taken in seconds
    static func measureAsyncTime<T: Sendable>(_ operation: () async throws -> T) async rethrows -> (result: T, time: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return (result, timeElapsed)
    }
}

//
//  NavigationHelpers.swift
//  NestoryUITests
//
//  Navigation helper functions for UI testing
//

import XCTest

enum NavigationHelpers {
    /// Navigate to a specific tab
    static func navigateToTab(named tabName: String, in app: XCUIApplication) {
        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: 5) else {
            XCTFail("Tab bar not found")
            return
        }

        let tab = tabBar.buttons[tabName]
        if tab.exists {
            tab.tap()
            // Wait for navigation to complete
            Thread.sleep(forTimeInterval: 0.5)
        }
    }

    /// Navigate back using navigation bar
    static func navigateBack(in app: XCUIApplication) {
        let navBar = app.navigationBars.firstMatch
        if navBar.exists {
            // Try back button with various possible labels
            let backButton = navBar.buttons.element(boundBy: 0)
            if backButton.exists, backButton.label != "Cancel" {
                backButton.tap()
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
    }

    /// Dismiss sheet or modal
    static func dismissSheet(in app: XCUIApplication) {
        // Try Cancel button first
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        }
        // Try Close button
        else if app.buttons["Close"].exists {
            app.buttons["Close"].tap()
        }
        // Try Done button
        else if app.buttons["Done"].exists {
            app.buttons["Done"].tap()
        }
        // Try swiping down as last resort
        else {
            app.swipeDown(velocity: .fast)
        }
        Thread.sleep(forTimeInterval: 0.5)
    }

    /// Swipe to delete in a list
    static func swipeToDelete(element: XCUIElement, in app: XCUIApplication) {
        element.swipeLeft()
        let deleteButton = app.buttons["Delete"]
        if deleteButton.waitForExistence(timeout: 2) {
            deleteButton.tap()
        }
    }

    /// Pull to refresh
    static func pullToRefresh(in app: XCUIApplication) {
        let firstCell = app.cells.firstMatch
        if firstCell.exists {
            firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.0))
                .press(forDuration: 0, thenDragTo: firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 3.0)))
        }
    }

    /// Check if we're on a specific screen by looking for navigation title
    static func isOnScreen(titled title: String, in app: XCUIApplication) -> Bool {
        app.navigationBars[title].exists ||
            app.staticTexts[title].exists
    }

    /// Wait for loading to complete
    static func waitForLoadingToComplete(in app: XCUIApplication, timeout: TimeInterval = 10) {
        let progressIndicators = app.progressIndicators
        if progressIndicators.count > 0 {
            let predicate = NSPredicate(format: "exists == false")
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: progressIndicators.firstMatch)
            _ = XCTWaiter.wait(for: [expectation], timeout: timeout)
        }
    }

    /// Switch app theme
    static func switchTheme(to theme: String, in app: XCUIApplication) {
        navigateToTab(named: "Settings", in: app)

        // Look for Appearance section
        let appearanceCell = app.cells.containing(.staticText, identifier: "Appearance").firstMatch
        if appearanceCell.waitForExistence(timeout: 3) {
            appearanceCell.tap()

            // Select theme
            let themeOption = app.buttons[theme]
            if themeOption.waitForExistence(timeout: 2) {
                themeOption.tap()
            }

            navigateBack(in: app)
        }
    }

    /// Handle permission alerts
    static func handlePermissionAlerts() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        // Camera permission
        let cameraAlert = springboard.alerts.containing(.staticText, identifier: "Would Like to Access the Camera").firstMatch
        if cameraAlert.exists {
            cameraAlert.buttons["OK"].tap()
        }

        // Photo library permission
        let photoAlert = springboard.alerts.containing(.staticText, identifier: "Would Like to Access Your Photos").firstMatch
        if photoAlert.exists {
            photoAlert.buttons["Allow Access to All Photos"].tapIfExists()
        }

        // Notification permission
        let notificationAlert = springboard.alerts.containing(.staticText, identifier: "Would Like to Send You Notifications").firstMatch
        if notificationAlert.exists {
            notificationAlert.buttons["Allow"].tap()
        }
    }
}

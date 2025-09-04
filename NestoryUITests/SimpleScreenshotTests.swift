//
//  SimpleScreenshotTests.swift
//  NestoryUITests
//
//  Basic screenshot tests for Nestory app
//

@preconcurrency import XCTest

@MainActor
final class SimpleScreenshotTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    func testLaunchScreen() async throws {
        // Wait for the app to fully launch
        sleep(3)
        
        // Take a screenshot of the main screen
        snapshot("MainScreen")
    }
    
    override func tearDown() async throws {
        app.terminate()
        try await super.tearDown()
    }
}
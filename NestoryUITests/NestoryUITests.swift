//
//  NestoryUITests.swift
//  NestoryUITests
//
//  Created by Griffin on 8/9/25.
//

import XCTest

@MainActor
final class NestoryUITests: XCTestCase {
    private var app: XCUIApplication!
    
    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
    }

    @MainActor
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

//
// Layer: Tests
// Module: UITests
// Purpose: UI automation tests for Nestory app
//

import XCTest

@MainActor
final class NestoryUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testAppLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Basic smoke test - app should launch without crashing
        XCTAssertTrue(app.exists)
    }
}
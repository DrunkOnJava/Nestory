//
//  XCTestCase+Helpers.swift
//  NestoryUITests
//
//  Deterministic UI testing helpers
//

import XCTest

@MainActor
extension XCTestCase {
    /// Deterministic tap with wait and hittable check
    func tap(_ element: XCUIElement, timeout: TimeInterval = 5,
             file: StaticString = #file, line: UInt = #line)
    {
        XCTAssertTrue(element.waitForExistence(timeout: timeout),
                      "Element not found: \(element)", file: file, line: line)
        XCTAssertTrue(element.isHittable, "Element not hittable: \(element)",
                      file: file, line: line)
        element.tap()
    }

    /// Wait for element to exist
    func waitFor(_ element: XCUIElement, timeout: TimeInterval = 5,
                 file _: StaticString = #file, line _: UInt = #line) -> Bool
    {
        element.waitForExistence(timeout: timeout)
    }
}

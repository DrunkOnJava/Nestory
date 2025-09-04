//
//  NestoryTests.swift
//  NestoryTests
//
//  Created by Griffin on 8/9/25.
//

@testable import Nestory
import XCTest

// Shared typealias to resolve Category ambiguity between CloudKit.Category and Nestory.Category
typealias NestoryCategory = Nestory.Category

@MainActor
final class NestoryTests: XCTestCase {
    func testExample() async throws {
        // Write your test here and use APIs like `XCTAssert(...)` to check expected conditions.
        XCTAssertTrue(true)
    }
}

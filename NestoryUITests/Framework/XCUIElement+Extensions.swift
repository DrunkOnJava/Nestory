//
// XCUIElement+Extensions.swift
// NestoryUITests
//
// Extensions for deterministic UI testing
//

@preconcurrency import XCTest

extension XCUIElement {
    /// Wait for element to be selected with configurable timeout
    func waitUntilSelected(timeout: TimeInterval = 5.0) -> Bool {
        let predicate = NSPredicate { element, _ in
            guard let button = element as? XCUIElement else { return false }
            // Check both selection states for compatibility
            return button.isSelected || button.value as? String == "1"
        }
        
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Wait for element to stop existing
    func waitForNonExistence(timeout: TimeInterval = 5.0) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Safe tap that waits for element to be hittable
    func safeTap(timeout: TimeInterval = 5.0) {
        guard waitForExistence(timeout: timeout) else {
            XCTFail("Element doesn't exist: \(self.debugDescription)")
            return
        }
        
        guard isHittable else {
            XCTFail("Element not hittable: \(self.debugDescription)")
            return
        }
        
        tap()
    }
    
    /// Type text with clearing existing content first
    func clearAndType(_ text: String) {
        guard self.exists else { return }
        
        tap()
        
        // Clear existing text if any
        if let existingText = self.value as? String, !existingText.isEmpty {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: existingText.count)
            typeText(deleteString)
        }
        
        typeText(text)
    }
    
    /// Force tap at element center (for stubborn elements)
    func forceTap() {
        coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }
}
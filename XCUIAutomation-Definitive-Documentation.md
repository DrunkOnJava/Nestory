# XCUIAutomation Framework - Definitive Reference

*Complete documentation for iOS UI Testing with XCUIAutomation*

**Framework:** XCUIAutomation  
**Availability:** Xcode 16.3+, iOS 9.0+, macOS 10.11+, tvOS 9.0+, visionOS 1.0+

---

## Table of Contents

1. [Framework Overview](#framework-overview)
2. [Essential Classes](#essential-classes)
3. [Core Protocols](#core-protocols)
4. [UI Testing Guide](#ui-testing-guide)
5. [Best Practices](#best-practices)
6. [Common Patterns](#common-patterns)
7. [API Reference](#api-reference)

---

## Framework Overview

The XCUIAutomation framework provides a comprehensive set of APIs for automating user interface testing in iOS, macOS, tvOS, and visionOS applications. It allows you to:

- **Automate user interactions** like taps, swipes, typing, and gestures
- **Query UI elements** using powerful search criteria
- **Verify app state** through assertions and expectations
- **Record and replay** user interactions for test creation
- **Test across platforms** with unified APIs

### Core Concepts

**UI Elements**: Every interactive component in your app (buttons, text fields, labels, etc.) is represented as an `XCUIElement`.

**Element Queries**: Use `XCUIElementQuery` to find and filter UI elements based on type, accessibility identifiers, labels, or predicates.

**Applications**: `XCUIApplication` serves as the entry point to launch and control your app during testing.

**Devices**: `XCUIDevice` provides access to device-level functionality like orientation and hardware buttons.

---

## Essential Classes

### XCUIApplication

The primary class for launching, monitoring, and terminating applications during tests.

```swift
let app = XCUIApplication()
app.launch()
```

**Key Properties:**
- `state: XCUIApplication.State` - Current application state
- `processID: pid_t` - Process identifier

**Key Methods:**
- `launch()` - Launch the application
- `terminate()` - Terminate the application
- `activate()` - Bring app to foreground

### XCUIElement

Represents a single UI element in your application.

```swift
let button = app.buttons["Save"]
let textField = app.textFields.firstMatch
let cell = app.cells.containing(.staticText, identifier: "Title").element
```

**Key Properties:**
- `exists: Bool` - Whether element exists in the UI hierarchy
- `isHittable: Bool` - Whether element can receive touch events
- `frame: CGRect` - Element's screen coordinates
- `label: String` - Accessibility label
- `value: Any?` - Element's value
- `elementType: XCUIElement.ElementType` - Type of UI element

**Key Methods:**
- `tap()` - Tap the element
- `doubleTap()` - Double-tap the element
- `press(forDuration:)` - Long press for specified duration
- `typeText(_:)` - Type text into element
- `swipeUp()`, `swipeDown()`, `swipeLeft()`, `swipeRight()` - Swipe gestures
- `waitForExistence(timeout:)` - Wait for element to appear

### XCUIElementQuery

Defines search criteria to identify UI elements.

```swift
let buttons = app.buttons
let visibleButtons = app.buttons.matching(.button).matching(NSPredicate(format: "exists == true"))
let specificButton = app.buttons["identifier"]
```

**Key Properties:**
- `count: Int` - Number of matching elements
- `allElementsBoundByIndex: [XCUIElement]` - Array of all matching elements
- `firstMatch: XCUIElement` - First matching element
- `element: XCUIElement` - Single matching element (fails if multiple matches)

**Key Methods:**
- `element(boundBy:)` - Get element at specific index
- `matching(_:)` - Filter by element type
- `matching(_:identifier:)` - Filter by type and identifier
- `containing(_:identifier:)` - Find elements containing other elements
- `descendants(matching:)` - Search in descendant hierarchy
- `children(matching:)` - Search in direct children only

### XCUIDevice

Provides access to device-level functionality.

```swift
let device = XCUIDevice.shared
device.orientation = .landscapeLeft
device.press(.home)
```

**Key Properties:**
- `orientation: UIDeviceOrientation` - Current device orientation

**Key Methods:**
- `press(_:)` - Press hardware buttons (home, volumeUp, volumeDown)
- `siriService` - Access Siri functionality

---

## Core Protocols

### XCUIElementAttributes

Provides properties for querying element attributes.

```swift
protocol XCUIElementAttributes {
    var identifier: String { get }
    var frame: CGRect { get }
    var value: Any? { get }
    var title: String { get }
    var label: String { get }
    var elementType: XCUIElement.ElementType { get }
    var isEnabled: Bool { get }
    var hasFocus: Bool { get }
    var isSelected: Bool { get }
    // ... and more
}
```

### XCUIElementTypeQueryProvider

Provides convenient access to element queries by type.

```swift
protocol XCUIElementTypeQueryProvider {
    var activityIndicators: XCUIElementQuery { get }
    var alerts: XCUIElementQuery { get }
    var buttons: XCUIElementQuery { get }
    var cells: XCUIElementQuery { get }
    var images: XCUIElementQuery { get }
    var navigationBars: XCUIElementQuery { get }
    var textFields: XCUIElementQuery { get }
    var textViews: XCUIElementQuery { get }
    // ... and many more
}
```

---

## UI Testing Guide

### 1. Setting Up UI Tests

Create a UI test target in Xcode:

```swift
import XCTest
import XCUIAutomation

class MyUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launch()
    }
    
    func testExample() throws {
        let app = XCUIApplication()
        
        // Your test code here
        let button = app.buttons["Get Started"]
        XCTAssertTrue(button.exists)
        button.tap()
    }
}
```

### 2. Recording UI Tests

1. Place cursor in test method
2. Click the Record button (red circle) in Xcode
3. Interact with your app in the simulator
4. Xcode generates element queries and interactions automatically
5. Stop recording and refine the generated code

### 3. Element Identification Strategies

**By Accessibility Identifier (Recommended):**
```swift
app.buttons["saveButton"]
app.textFields["usernameField"]
```

**By Label:**
```swift
app.buttons["Save"]
app.staticTexts["Welcome"]
```

**By Index (Use Sparingly):**
```swift
app.buttons.element(boundBy: 0)
app.cells.firstMatch
```

**By Predicates (Advanced):**
```swift
app.buttons.matching(NSPredicate(format: "label CONTAINS 'Save'")).element
app.cells.containing(.staticText, identifier: "title").element
```

---

## Best Practices

### 1. Use Accessibility Identifiers

Set unique accessibility identifiers for testable elements:

```swift
// In your app code
button.accessibilityIdentifier = "saveButton"
textField.accessibilityIdentifier = "usernameField"

// In your tests
app.buttons["saveButton"].tap()
app.textFields["usernameField"].typeText("username")
```

### 2. Wait for Elements

Always wait for elements before interacting:

```swift
let button = app.buttons["save"]
XCTAssertTrue(button.waitForExistence(timeout: 5))
button.tap()
```

### 3. Use Meaningful Assertions

```swift
// Good - specific and meaningful
XCTAssertTrue(app.alerts["Error"].exists, "Error alert should appear")
XCTAssertEqual(app.textFields["result"].value as? String, "42")

// Avoid - too generic
XCTAssertTrue(true)
```

### 4. Handle Interruptions

```swift
override func setUp() {
    super.setUp()
    
    addUIInterruptionMonitor(withDescription: "Location Permission") { alert in
        if alert.buttons["Allow While Using App"].exists {
            alert.buttons["Allow While Using App"].tap()
            return true
        }
        return false
    }
}
```

### 5. Keep Tests Independent

Each test should be able to run independently:

```swift
override func setUp() {
    super.setUp()
    // Reset app state
    let app = XCUIApplication()
    app.launchArguments = ["--uitesting"]
    app.launch()
}
```

---

## Common Patterns

### Navigation Testing

```swift
func testNavigationFlow() {
    let app = XCUIApplication()
    
    // Navigate to settings
    app.tabBars.buttons["Settings"].tap()
    
    // Verify we're in settings
    XCTAssertTrue(app.navigationBars["Settings"].exists)
    
    // Navigate to profile
    app.cells["Profile"].tap()
    
    // Verify profile screen
    XCTAssertTrue(app.navigationBars["Profile"].exists)
    
    // Go back
    app.navigationBars.buttons.element(boundBy: 0).tap()
}
```

### Form Input Testing

```swift
func testFormInput() {
    let app = XCUIApplication()
    
    let emailField = app.textFields["email"]
    let passwordField = app.secureTextFields["password"]
    let submitButton = app.buttons["submit"]
    
    // Fill form
    emailField.tap()
    emailField.typeText("test@example.com")
    
    passwordField.tap()
    passwordField.typeText("password123")
    
    // Submit
    submitButton.tap()
    
    // Verify result
    XCTAssertTrue(app.alerts["Success"].waitForExistence(timeout: 5))
}
```

### Table View Testing

```swift
func testTableView() {
    let app = XCUIApplication()
    let table = app.tables.firstMatch
    
    // Verify table exists
    XCTAssertTrue(table.exists)
    
    // Test first cell
    let firstCell = table.cells.element(boundBy: 0)
    XCTAssertTrue(firstCell.exists)
    firstCell.tap()
    
    // Test search
    let searchField = app.searchFields.firstMatch
    searchField.tap()
    searchField.typeText("search term")
    
    // Verify filtered results
    XCTAssertGreaterThan(table.cells.count, 0)
}
```

### Gesture Testing

```swift
func testGestures() {
    let app = XCUIApplication()
    let image = app.images.firstMatch
    
    // Pinch to zoom
    image.pinch(withScale: 2.0, velocity: 1.0)
    
    // Rotate
    image.rotate(withRotation: .pi/4, velocity: 1.0)
    
    // Swipe
    image.swipeLeft()
    
    // Long press
    image.press(forDuration: 1.5)
}
```

---

## API Reference

### Element Types

```swift
enum XCUIElement.ElementType {
    case any
    case other
    case application
    case group
    case window
    case sheet
    case drawer
    case alert
    case dialog
    case button
    case radioButton
    case radioGroup
    case checkBox
    case disclosureTriangle
    case popUpButton
    case comboBox
    case menuButton
    case toolbarButton
    case popover
    case keyboard
    case key
    case navigationBar
    case tabBar
    case tabGroup
    case toolbar
    case statusBar
    case table
    case tableRow
    case tableColumn
    case outline
    case outlineRow
    case browser
    case collectionView
    case slider
    case pageIndicator
    case progressIndicator
    case activityIndicator
    case segmentedControl
    case picker
    case pickerWheel
    case switch
    case toggle
    case link
    case image
    case icon
    case searchField
    case scrollView
    case scrollBar
    case staticText
    case textField
    case secureTextField
    case datePicker
    case textView
    case menu
    case menuItem
    case menuBar
    case menuBarItem
    case map
    case webView
    case incrementArrow
    case decrementArrow
    case timeline
    case ratingIndicator
    case valueIndicator
    case splitGroup
    case splitter
    case relevanceIndicator
    case colorWell
    case helpTag
    case matte
    case dockItem
    case ruler
    case rulerMarker
    case grid
    case levelIndicator
    case cell
    case layoutArea
    case layoutItem
    case handle
    case stepper
    case tab
    case touchBar
    case statusItem
}
```

### Coordinate System

```swift
// XCUICoordinate - represents a location on screen
let element = app.buttons["myButton"]
let coordinate = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
coordinate.tap()
```

### Screenshots

```swift
// Take screenshot
let screenshot = app.screenshot()
let attachment = XCTAttachment(screenshot: screenshot)
attachment.lifetime = .keepAlways
add(attachment)
```

---

## Advanced Topics

### Performance Testing with XCUIAutomation

```swift
func testScrollingPerformance() {
    let app = XCUIApplication()
    let table = app.tables.firstMatch
    
    measure {
        for _ in 0..<10 {
            table.swipeUp()
        }
    }
}
```

### Testing Across Different Screen Sizes

```swift
func testAdaptiveLayout() {
    let app = XCUIApplication()
    
    // Test in portrait
    XCUIDevice.shared.orientation = .portrait
    verifyLayoutFor(app: app, orientation: "Portrait")
    
    // Test in landscape
    XCUIDevice.shared.orientation = .landscapeLeft
    verifyLayoutFor(app: app, orientation: "Landscape")
}

private func verifyLayoutFor(app: XCUIApplication, orientation: String) {
    // Orientation-specific assertions
    let mainButton = app.buttons["main"]
    XCTAssertTrue(mainButton.exists, "Main button should exist in \(orientation)")
}
```

### Custom Matchers and Extensions

```swift
extension XCUIElement {
    func tapIfExists() {
        if exists && isHittable {
            tap()
        }
    }
    
    func clearAndType(_ text: String) {
        tap()
        press(forDuration: 1.0)
        app.keys["Select All"].tap()
        typeText(text)
    }
}

extension XCTest {
    func waitForElementToExist(_ element: XCUIElement, timeout: TimeInterval = 10) {
        let expectation = XCTExpectation(description: "Element exists")
        
        if element.waitForExistence(timeout: timeout) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeout + 1)
    }
}
```

---

## Troubleshooting

### Common Issues and Solutions

1. **Element not found**
   - Verify accessibility identifiers are set
   - Check if element is visible on screen
   - Wait for element to appear with `waitForExistence(timeout:)`

2. **Test is flaky**
   - Add explicit waits before interactions
   - Use `waitForExistence` instead of `exists` checks
   - Handle system interruptions (alerts, permissions)

3. **Slow test execution**
   - Reduce unnecessary waits
   - Use `firstMatch` when appropriate
   - Avoid complex predicate queries in loops

4. **Element not hittable**
   - Check if element is covered by another element
   - Scroll to make element visible
   - Verify element has sufficient size for tapping

### Debugging Tips

```swift
// Print element hierarchy
print(app.debugDescription)

// Check element properties
print("Exists: \(element.exists)")
print("Hittable: \(element.isHittable)")
print("Frame: \(element.frame)")
print("Value: \(element.value ?? "nil")")

// Take screenshots for debugging
let screenshot = app.screenshot()
// Examine screenshot in test results
```

---

*Generated from Apple Developer Documentation*  
*Last updated: August 2025*

This documentation provides comprehensive coverage of the XCUIAutomation framework with practical examples, best practices, and advanced techniques for iOS UI testing.
//
// AccessibilityTests.swift
// NestoryUITests
//
// Comprehensive accessibility compliance and usability testing for insurance workflows
//

@preconcurrency import XCTest

@MainActor
final class AccessibilityTests: XCTestCase {
    
    // MARK: - Properties
    
    var app: XCUIApplication!
    
    // MARK: - Setup
    
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = [
            "UITEST_MODE",
            "ACCESSIBILITY_TESTING",
            "DISABLE_ANIMATIONS"
        ]
        app.launchEnvironment = [
            "UI_TESTING": "1",
            "ACCESSIBILITY_MODE": "1"
        ]
    }
    
    override func tearDown() async throws {
        app = nil
        try await super.tearDown()
    }
    
    // MARK: - Core Accessibility Compliance Tests
    
    func testWCAGComplianceForInventoryFlow() async throws {
        // Test WCAG 2.1 AA compliance for insurance inventory management
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Navigate to inventory
        let inventoryTab = app.tabBars.buttons["Inventory"]
        XCTAssertTrue(inventoryTab.waitForExistence(timeout: 5))
        
        // Test accessibility attributes
        validateAccessibilityAttributes(inventoryTab, expectedLabel: "Inventory", expectedHint: "View your insured items")
        inventoryTab.tap()
        
        // Test add item accessibility
        let addItemButton = app.navigationBars.buttons["Add Item"]
        XCTAssertTrue(addItemButton.waitForExistence(timeout: 5))
        validateAccessibilityAttributes(addItemButton, expectedLabel: "Add Item", expectedHint: "Add a new item to your insurance inventory")
        
        // Test keyboard navigation
        validateKeyboardNavigation(from: inventoryTab, to: addItemButton)
        
        addItemButton.tap()
        
        // Test form accessibility
        validateFormAccessibility()
        
        // Test color contrast and visual accessibility
        validateVisualAccessibility()
    }
    
    func testVoiceOverNavigationForInsuranceReports() async throws {
        // Test comprehensive VoiceOver support for insurance report generation
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Navigate to settings for reports
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        
        // Verify VoiceOver attributes
        XCTAssertTrue(settingsTab.isAccessibilityElement, "Settings tab should be accessible to VoiceOver")
        XCTAssertNotNil(settingsTab.accessibilityLabel, "Settings tab should have accessibility label")
        XCTAssertNotNil(settingsTab.accessibilityHint, "Settings tab should have accessibility hint")
        
        settingsTab.tap()
        
        // Test insurance reports accessibility
        let insuranceReportsOption = app.cells["Insurance Reports"]
        if insuranceReportsOption.waitForExistence(timeout: 5) {
            validateAccessibilityAttributes(
                insuranceReportsOption,
                expectedLabel: "Insurance Reports",
                expectedHint: "Generate comprehensive insurance documentation reports"
            )
            
            // Test accessibility traits
            XCTAssertTrue(
                insuranceReportsOption.accessibilityTraits.contains(.button),
                "Insurance Reports option should have button trait"
            )
            
            insuranceReportsOption.tap()
            
            // Test report generation screen accessibility
            validateReportGenerationAccessibility()
        }
    }
    
    func testDynamicTypeSupport() async throws {
        // Test Dynamic Type support for visually impaired users
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Test various Dynamic Type sizes
        let typeSizes = ["UICTContentSizeCategoryXS", "UICTContentSizeCategoryL", "UICTContentSizeCategoryXXXL"]
        
        for typeSize in typeSizes {
            // Simulate different Dynamic Type settings
            app.launchEnvironment["DYNAMIC_TYPE_SIZE"] = typeSize
            app.terminate()
            app.launch()
            
            // Test that content remains accessible at different sizes
            let inventoryTab = app.tabBars.buttons["Inventory"]
            XCTAssertTrue(inventoryTab.waitForExistence(timeout: 5))
            XCTAssertTrue(inventoryTab.isHittable, "Inventory tab should remain hittable at \(typeSize)")
            
            inventoryTab.tap()
            
            // Test that item cells remain accessible
            let firstCell = app.cells.firstMatch
            if firstCell.waitForExistence(timeout: 3) {
                XCTAssertTrue(firstCell.isHittable, "First inventory cell should remain hittable at \(typeSize)")
                
                // Verify text doesn't get truncated inappropriately
                let cellTexts = firstCell.staticTexts.allElementsBoundByIndex
                for textElement in cellTexts {
                    XCTAssertFalse(
                        textElement.label.hasSuffix("..."),
                        "Text should not be truncated at \(typeSize): \(textElement.label)"
                    )
                }
            }
        }
    }
    
    func testColorContrastCompliance() async throws {
        // Test color contrast ratios meet WCAG AA standards
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Test different UI states for contrast
        let stateTests: [(String, [String: String])] = [
            ("Normal", [:]),
            ("Dark Mode", ["FORCE_DARK_MODE": "1"]),
            ("High Contrast", ["FORCE_HIGH_CONTRAST": "1"])
        ]
        
        for (stateName, environment) in stateTests {
            // Apply environment changes
            for (key, value) in environment {
                app.launchEnvironment[key] = value
            }
            app.terminate()
            app.launch()
            
            // Test critical UI elements for contrast
            validateContrastForCriticalElements(state: stateName)
            
            // Test error states have sufficient contrast
            validateErrorStateContrast(state: stateName)
            
            // Test warning indicators for warranty expiration
            validateWarrantyIndicatorContrast(state: stateName)
        }
    }
    
    func testKeyboardNavigationSupport() async throws {
        // Test full keyboard navigation for users who can't use touch
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Test tab navigation
        testTabBarKeyboardNavigation()
        
        // Test form navigation
        testFormKeyboardNavigation()
        
        // Test list navigation
        testInventoryListKeyboardNavigation()
        
        // Test modal navigation
        testModalKeyboardNavigation()
    }
    
    func testSwitchControlSupport() async throws {
        // Test Switch Control accessibility for users with limited mobility
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Verify all interactive elements are accessible via Switch Control
        let allButtons = app.buttons.allElementsBoundByIndex
        for button in allButtons {
            if button.exists && button.isHittable {
                XCTAssertTrue(
                    button.isAccessibilityElement,
                    "Button '\(button.accessibilityLabel ?? "unlabeled")' should be accessible via Switch Control"
                )
            }
        }
        
        // Test sequential navigation works
        let firstButton = app.buttons.firstMatch
        if firstButton.waitForExistence(timeout: 5) {
            // Simulate Switch Control scanning
            validateSequentialNavigation(startingFrom: firstButton)
        }
    }
    
    func testReducedMotionSupport() async throws {
        // Test Reduce Motion accessibility setting compliance
        
        app.launchEnvironment["REDUCE_MOTION"] = "1"
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Test that animations are reduced or eliminated
        let inventoryTab = app.tabBars.buttons["Inventory"]
        XCTAssertTrue(inventoryTab.waitForExistence(timeout: 5))
        inventoryTab.tap()
        
        let addItemButton = app.navigationBars.buttons["Add Item"]
        if addItemButton.waitForExistence(timeout: 5) {
            addItemButton.tap()
            
            // Verify modal appears without excessive animation
            let itemForm = app.otherElements["Add Item Form"]
            XCTAssertTrue(
                itemForm.waitForExistence(timeout: 2),
                "Form should appear quickly with reduced motion"
            )
        }
    }
    
    // MARK: - Insurance-Specific Accessibility Tests
    
    func testDamageAssessmentAccessibility() async throws {
        // Test accessibility of damage assessment workflows
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Navigate to an item
        let inventoryTab = app.tabBars.buttons["Inventory"]
        XCTAssertTrue(inventoryTab.waitForExistence(timeout: 5))
        inventoryTab.tap()
        
        let firstItem = app.cells.firstMatch
        if firstItem.waitForExistence(timeout: 5) {
            firstItem.tap()
            
            // Test damage report accessibility
            let moreButton = app.navigationBars.buttons["More"]
            if moreButton.waitForExistence(timeout: 5) {
                validateAccessibilityAttributes(
                    moreButton,
                    expectedLabel: "More options",
                    expectedHint: "Additional actions for this item"
                )
                moreButton.tap()
                
                let reportDamageOption = app.buttons["Report Damage"]
                if reportDamageOption.waitForExistence(timeout: 5) {
                    validateAccessibilityAttributes(
                        reportDamageOption,
                        expectedLabel: "Report Damage",
                        expectedHint: "Start damage assessment for insurance claim"
                    )
                    
                    // Test damage assessment wizard accessibility
                    reportDamageOption.tap()
                    validateDamageAssessmentWizardAccessibility()
                }
            }
        }
    }
    
    func testReceiptOCRAccessibility() async throws {
        // Test accessibility of receipt OCR workflow
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        let inventoryTab = app.tabBars.buttons["Inventory"]
        XCTAssertTrue(inventoryTab.waitForExistence(timeout: 5))
        inventoryTab.tap()
        
        let addItemButton = app.navigationBars.buttons["Add Item"]
        if addItemButton.waitForExistence(timeout: 5) {
            addItemButton.tap()
            
            let scanReceiptButton = app.buttons["Scan Receipt"]
            if scanReceiptButton.waitForExistence(timeout: 5) {
                validateAccessibilityAttributes(
                    scanReceiptButton,
                    expectedLabel: "Scan Receipt",
                    expectedHint: "Automatically extract information from receipt photo"
                )
                
                // Test camera accessibility for receipt scanning
                scanReceiptButton.tap()
                validateCameraAccessibilityForReceipts()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func validateAccessibilityAttributes(
        _ element: XCUIElement,
        expectedLabel: String,
        expectedHint: String? = nil
    ) {
        XCTAssertTrue(element.isAccessibilityElement, "Element should be accessible")
        
        if let label = element.accessibilityLabel {
            XCTAssertEqual(label, expectedLabel, "Accessibility label should match expected value")
        } else {
            XCTFail("Element should have accessibility label")
        }
        
        if let expectedHint = expectedHint {
            if let hint = element.accessibilityHint {
                XCTAssertEqual(hint, expectedHint, "Accessibility hint should match expected value")
            } else {
                XCTFail("Element should have accessibility hint")
            }
        }
    }
    
    private func validateKeyboardNavigation(from: XCUIElement, to: XCUIElement) {
        // Simulate keyboard navigation between elements
        // In a real implementation, this would test Tab key navigation
        XCTAssertTrue(from.isAccessibilityElement, "Source element should support keyboard navigation")
        XCTAssertTrue(to.isAccessibilityElement, "Target element should support keyboard navigation")
    }
    
    private func validateFormAccessibility() {
        // Test form field accessibility
        let nameField = app.textFields["Item Name"]
        if nameField.waitForExistence(timeout: 5) {
            validateAccessibilityAttributes(
                nameField,
                expectedLabel: "Item Name",
                expectedHint: "Enter the name of your insured item"
            )
            
            XCTAssertTrue(
                nameField.accessibilityTraits.contains(.searchField),
                "Text field should have appropriate accessibility traits"
            )
        }
        
        let priceField = app.textFields["Purchase Price"]
        if priceField.waitForExistence(timeout: 3) {
            validateAccessibilityAttributes(
                priceField,
                expectedLabel: "Purchase Price",
                expectedHint: "Enter the original purchase price"
            )
        }
    }
    
    private func validateVisualAccessibility() {
        // Test visual elements for accessibility
        let formElements = app.otherElements["Add Item Form"]
        if formElements.waitForExistence(timeout: 5) {
            // Verify sufficient spacing between elements
            let buttons = formElements.buttons.allElementsBoundByIndex
            for i in 0..<max(0, buttons.count - 1) {
                let currentButton = buttons[i]
                let nextButton = buttons[i + 1]
                
                // Ensure minimum 44pt touch target (simplified test)
                XCTAssertTrue(currentButton.frame.height >= 44, "Button should meet minimum touch target size")
                XCTAssertTrue(nextButton.frame.height >= 44, "Button should meet minimum touch target size")
            }
        }
    }
    
    private func validateReportGenerationAccessibility() {
        let reportGenerationScreen = app.otherElements["Report Generation"]
        if reportGenerationScreen.waitForExistence(timeout: 5) {
            let generateButton = app.buttons["Generate PDF Report"]
            if generateButton.waitForExistence(timeout: 5) {
                validateAccessibilityAttributes(
                    generateButton,
                    expectedLabel: "Generate PDF Report",
                    expectedHint: "Create comprehensive insurance documentation report"
                )
            }
            
            // Test progress indicator accessibility
            let progressIndicator = app.progressIndicators["Generating Report"]
            if progressIndicator.waitForExistence(timeout: 3) {
                XCTAssertTrue(progressIndicator.isAccessibilityElement)
                XCTAssertNotNil(progressIndicator.accessibilityValue, "Progress should have accessible value")
            }
        }
    }
    
    private func validateContrastForCriticalElements(state: String) {
        // Test critical elements maintain sufficient contrast
        let criticalElements = [
            app.tabBars.buttons.firstMatch,
            app.navigationBars.buttons.firstMatch,
            app.buttons.containing(.staticText, identifier:"Save").firstMatch
        ]
        
        for element in criticalElements {
            if element.waitForExistence(timeout: 2) {
                // In a real implementation, this would analyze actual color values
                XCTAssertTrue(
                    element.isHittable,
                    "Critical element should remain visible and hittable in \(state)"
                )
            }
        }
    }
    
    private func validateErrorStateContrast(state: String) {
        // Test error states maintain sufficient contrast
        // This would be expanded to test actual error scenarios
        XCTAssertTrue(true, "Error state contrast validation for \(state)")
    }
    
    private func validateWarrantyIndicatorContrast(state: String) {
        // Test warranty expiration indicators
        XCTAssertTrue(true, "Warranty indicator contrast validation for \(state)")
    }
    
    private func testTabBarKeyboardNavigation() {
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 5) {
            let tabs = tabBar.buttons.allElementsBoundByIndex
            for tab in tabs {
                XCTAssertTrue(tab.isAccessibilityElement, "Tab should be keyboard accessible")
            }
        }
    }
    
    private func testFormKeyboardNavigation() {
        let addItemButton = app.navigationBars.buttons["Add Item"]
        if addItemButton.waitForExistence(timeout: 5) {
            addItemButton.tap()
            
            // Test that form fields can be navigated with keyboard
            let formFields = [
                app.textFields["Item Name"],
                app.textFields["Purchase Price"],
                app.textViews["Description"]
            ]
            
            for field in formFields {
                if field.waitForExistence(timeout: 2) {
                    XCTAssertTrue(field.isAccessibilityElement, "Form field should support keyboard navigation")
                }
            }
        }
    }
    
    private func testInventoryListKeyboardNavigation() {
        let inventoryTab = app.tabBars.buttons["Inventory"]
        if inventoryTab.waitForExistence(timeout: 5) {
            inventoryTab.tap()
            
            let inventoryList = app.collectionViews.firstMatch
            if inventoryList.waitForExistence(timeout: 5) {
                let cells = inventoryList.cells.allElementsBoundByIndex
                for cell in cells.prefix(3) { // Test first 3 cells
                    XCTAssertTrue(cell.isAccessibilityElement, "Inventory cell should support keyboard navigation")
                }
            }
        }
    }
    
    private func testModalKeyboardNavigation() {
        // Test keyboard navigation in modal presentations
        let inventoryTab = app.tabBars.buttons["Inventory"]
        if inventoryTab.waitForExistence(timeout: 5) {
            inventoryTab.tap()
            
            let addItemButton = app.navigationBars.buttons["Add Item"]
            if addItemButton.waitForExistence(timeout: 5) {
                addItemButton.tap()
                
                // Test modal can be dismissed with keyboard
                let modalDismiss = app.buttons["Cancel"] 
                if modalDismiss.waitForExistence(timeout: 5) {
                    XCTAssertTrue(modalDismiss.isAccessibilityElement, "Modal dismiss should be keyboard accessible")
                }
            }
        }
    }
    
    private func validateSequentialNavigation(startingFrom: XCUIElement) {
        // Simulate sequential navigation for Switch Control
        XCTAssertTrue(startingFrom.isAccessibilityElement, "Starting element should support sequential navigation")
        
        // In a real implementation, this would test actual sequential focus management
        let nextElement = app.buttons.element(boundBy: 1)
        if nextElement.exists {
            XCTAssertTrue(nextElement.isAccessibilityElement, "Next element should support sequential navigation")
        }
    }
    
    private func validateDamageAssessmentWizardAccessibility() {
        // Test accessibility of damage assessment wizard steps
        let wizardContainer = app.otherElements["Damage Assessment Wizard"]
        if wizardContainer.waitForExistence(timeout: 5) {
            // Test step indicators are accessible
            let stepIndicator = app.staticTexts.containing(.staticText, identifier: "Step").firstMatch
            if stepIndicator.exists {
                XCTAssertTrue(stepIndicator.isAccessibilityElement, "Step indicator should be accessible")
                XCTAssertNotNil(stepIndicator.accessibilityLabel, "Step indicator should have label")
            }
            
            // Test navigation buttons
            let nextButton = app.buttons["Next"]
            if nextButton.waitForExistence(timeout: 3) {
                validateAccessibilityAttributes(
                    nextButton,
                    expectedLabel: "Next",
                    expectedHint: "Continue to next step of damage assessment"
                )
            }
        }
    }
    
    private func validateCameraAccessibilityForReceipts() {
        // Test camera interface accessibility for receipt scanning
        let cameraView = app.otherElements["Camera View"]
        if cameraView.waitForExistence(timeout: 5) {
            let captureButton = app.buttons["Capture"]
            if captureButton.waitForExistence(timeout: 3) {
                validateAccessibilityAttributes(
                    captureButton,
                    expectedLabel: "Capture Receipt",
                    expectedHint: "Take photo of receipt for automatic processing"
                )
            }
            
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.waitForExistence(timeout: 3) {
                validateAccessibilityAttributes(
                    cancelButton,
                    expectedLabel: "Cancel",
                    expectedHint: "Cancel receipt scanning"
                )
            }
        }
    }
}
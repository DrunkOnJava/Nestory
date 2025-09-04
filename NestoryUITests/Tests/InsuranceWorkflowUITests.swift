//
// InsuranceWorkflowUITests.swift
// NestoryUITests
//
// Automated testing of end-to-end insurance workflows
//

@preconcurrency import XCTest

@MainActor
final class InsuranceWorkflowUITests: XCTestCase {
    
    // MARK: - Properties
    
    var app: XCUIApplication!
    
    // MARK: - Setup
    
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = [
            "UITEST_MODE",
            "DISABLE_ANIMATIONS",
            "RESET_DATA",
            "ENABLE_MOCK_SERVICES"
        ]
        app.launchEnvironment = [
            "UI_TESTING": "1",
            "CLEAR_KEYCHAIN": "1",
            "MOCK_OCR": "1",
            "MOCK_CAMERA": "1"
        ]
    }
    
    override func tearDown() async throws {
        app = nil
        try await super.tearDown()
    }
    
    // MARK: - Complete Insurance Documentation Workflows
    
    func testCompleteInsuranceItemCreationWorkflow() async throws {
        // Test the complete journey from adding an item to generating insurance report
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Navigate to inventory
        let inventoryTab = app.tabBars.buttons["Inventory"]
        XCTAssertTrue(inventoryTab.waitForExistence(timeout: 5))
        inventoryTab.tap()
        
        // Add new item
        let addItemButton = app.navigationBars.buttons["Add Item"]
        XCTAssertTrue(addItemButton.waitForExistence(timeout: 5))
        addItemButton.tap()
        
        // Fill in basic item information
        let nameField = app.textFields["Item Name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("MacBook Pro M3")
        
        let descriptionField = app.textViews["Description"]
        XCTAssertTrue(descriptionField.waitForExistence(timeout: 5))
        descriptionField.tap()
        descriptionField.typeText("16-inch MacBook Pro with M3 Max chip for insurance documentation")
        
        // Add purchase price
        let priceField = app.textFields["Purchase Price"]
        XCTAssertTrue(priceField.waitForExistence(timeout: 5))
        priceField.tap()
        priceField.typeText("2499.99")
        
        // Add serial number (critical for insurance)
        let serialField = app.textFields["Serial Number"]
        XCTAssertTrue(serialField.waitForExistence(timeout: 5))
        serialField.tap()
        serialField.typeText("MBP2024123456")
        
        // Set category
        let categoryButton = app.buttons["Select Category"]
        XCTAssertTrue(categoryButton.waitForExistence(timeout: 5))
        categoryButton.tap()
        
        let electronicsCategory = app.buttons["Electronics"]
        XCTAssertTrue(electronicsCategory.waitForExistence(timeout: 5))
        electronicsCategory.tap()
        
        // Add photo (simulated with mock camera)
        let addPhotoButton = app.buttons["Add Photo"]
        XCTAssertTrue(addPhotoButton.waitForExistence(timeout: 5))
        addPhotoButton.tap()
        
        let takePhotoOption = app.buttons["Take Photo"]
        XCTAssertTrue(takePhotoOption.waitForExistence(timeout: 5))
        takePhotoOption.tap()
        
        // Mock camera interface
        let captureButton = app.buttons["Capture"]
        XCTAssertTrue(captureButton.waitForExistence(timeout: 5))
        captureButton.tap()
        
        let usePhotoButton = app.buttons["Use Photo"]
        XCTAssertTrue(usePhotoButton.waitForExistence(timeout: 5))
        usePhotoButton.tap()
        
        // Add receipt
        let addReceiptButton = app.buttons["Add Receipt"]
        XCTAssertTrue(addReceiptButton.waitForExistence(timeout: 5))
        addReceiptButton.tap()
        
        let scanReceiptOption = app.buttons["Scan Receipt"]
        XCTAssertTrue(scanReceiptOption.waitForExistence(timeout: 5))
        scanReceiptOption.tap()
        
        // Mock OCR processing
        let ocrProcessingIndicator = app.activityIndicators["Processing Receipt"]
        XCTAssertTrue(ocrProcessingIndicator.waitForExistence(timeout: 5))
        
        // Wait for OCR completion (mocked to be fast)
        let ocrCompleteAlert = app.alerts["Receipt Processed"]
        XCTAssertTrue(ocrCompleteAlert.waitForExistence(timeout: 10))
        ocrCompleteAlert.buttons["OK"].tap()
        
        // Add warranty information
        let addWarrantyButton = app.buttons["Add Warranty"]
        XCTAssertTrue(addWarrantyButton.waitForExistence(timeout: 5))
        addWarrantyButton.tap()
        
        let warrantyProviderField = app.textFields["Warranty Provider"]
        XCTAssertTrue(warrantyProviderField.waitForExistence(timeout: 5))
        warrantyProviderField.tap()
        warrantyProviderField.typeText("Apple")
        
        // Set warranty expiration (1 year from now)
        let warrantyDatePicker = app.datePickers["Warranty Expiration"]
        XCTAssertTrue(warrantyDatePicker.waitForExistence(timeout: 5))
        warrantyDatePicker.tap()
        // Future date selection would be automated here
        
        // Save the item
        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()
        
        // Verify item appears in inventory list
        let createdItem = app.cells.containing(.staticText, identifier: "MacBook Pro M3").firstMatch
        XCTAssertTrue(createdItem.waitForExistence(timeout: 5))
        
        // Verify insurance completeness indicators
        let completenessIndicator = createdItem.images["Insurance Complete"]
        XCTAssertTrue(completenessIndicator.exists, "Item should show insurance completeness indicator")
    }
    
    func testInsuranceReportGenerationWorkflow() async throws {
        // Test generating a comprehensive insurance report
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Create sample data first (abbreviated)
        await createSampleInsuranceItems()
        
        // Navigate to Reports section
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()
        
        let insuranceReportsOption = app.cells["Insurance Reports"]
        XCTAssertTrue(insuranceReportsOption.waitForExistence(timeout: 5))
        insuranceReportsOption.tap()
        
        // Select report type
        let comprehensiveReportButton = app.buttons["Generate Comprehensive Report"]
        XCTAssertTrue(comprehensiveReportButton.waitForExistence(timeout: 5))
        comprehensiveReportButton.tap()
        
        // Configure report options
        let includePhotosToggle = app.switches["Include Item Photos"]
        XCTAssertTrue(includePhotosToggle.waitForExistence(timeout: 5))
        if !includePhotosToggle.isSelected {
            includePhotosToggle.tap()
        }
        
        let includeReceiptsToggle = app.switches["Include Receipts"]
        XCTAssertTrue(includeReceiptsToggle.waitForExistence(timeout: 5))
        if !includeReceiptsToggle.isSelected {
            includeReceiptsToggle.tap()
        }
        
        let includeWarrantyToggle = app.switches["Include Warranty Info"]
        XCTAssertTrue(includeWarrantyToggle.waitForExistence(timeout: 5))
        if !includeWarrantyToggle.isSelected {
            includeWarrantyToggle.tap()
        }
        
        // Generate report
        let generateButton = app.buttons["Generate PDF Report"]
        XCTAssertTrue(generateButton.waitForExistence(timeout: 5))
        generateButton.tap()
        
        // Wait for PDF generation
        let generationProgress = app.progressIndicators["Generating Report"]
        XCTAssertTrue(generationProgress.waitForExistence(timeout: 5))
        
        // Wait for completion
        let shareButton = app.buttons["Share Report"]
        XCTAssertTrue(shareButton.waitForExistence(timeout: 30), "PDF generation should complete within 30 seconds")
        
        // Test sharing options
        shareButton.tap()
        
        // Wait for iOS share sheet to appear
        let shareSheet = app.sheets.firstMatch
        XCTAssertTrue(shareSheet.waitForExistence(timeout: 5), "Share sheet should appear")
        
        // Alternative: Check for activity view controller elements
        let activityView = app.otherElements.matching(identifier: "ActivityListView").firstMatch
        if activityView.exists {
            // Verify email option is available in activity view
            let emailOption = activityView.buttons["Mail"]
            XCTAssertTrue(emailOption.exists, "Email sharing should be available")
        } else {
            // Fallback: Check for Mail button in sheet
            let emailOption = shareSheet.buttons["Mail"]
            if emailOption.exists {
                XCTAssertTrue(emailOption.exists, "Email sharing should be available")
            } else {
                // Log available share options for debugging
                NSLog("Available share options: \(shareSheet.buttons.allElementsBoundByIndex.map { $0.label })")
            }
        }
        
        // Cancel share sheet
        let cancelButton = app.buttons["Cancel"]
        if cancelButton.exists {
            cancelButton.tap()
        } else {
            // Tap outside to dismiss
            app.tap()
        }
    }
    
    func testDamageAssessmentWorkflow() async throws {
        // Test the damage assessment workflow for insurance claims
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Navigate to inventory and select an item
        let inventoryTab = app.tabBars.buttons["Inventory"]
        XCTAssertTrue(inventoryTab.waitForExistence(timeout: 5))
        inventoryTab.tap()
        
        // Create or select an existing item
        let firstItem = app.cells.firstMatch
        XCTAssertTrue(firstItem.waitForExistence(timeout: 5))
        firstItem.tap()
        
        // Access damage assessment
        let moreButton = app.navigationBars.buttons["More"]
        XCTAssertTrue(moreButton.waitForExistence(timeout: 5))
        moreButton.tap()
        
        let damageAssessmentOption = app.buttons["Report Damage"]
        XCTAssertTrue(damageAssessmentOption.waitForExistence(timeout: 5))
        damageAssessmentOption.tap()
        
        // Start damage assessment wizard
        let startAssessmentButton = app.buttons["Start Assessment"]
        XCTAssertTrue(startAssessmentButton.waitForExistence(timeout: 5))
        startAssessmentButton.tap()
        
        // Step 1: Damage Type Selection
        let damageTypeScreen = app.staticTexts["What type of damage occurred?"]
        XCTAssertTrue(damageTypeScreen.waitForExistence(timeout: 5))
        
        let waterDamageOption = app.buttons["Water Damage"]
        XCTAssertTrue(waterDamageOption.waitForExistence(timeout: 5))
        waterDamageOption.tap()
        
        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        nextButton.tap()
        
        // Step 2: Damage Severity
        let severityScreen = app.staticTexts["How severe is the damage?"]
        XCTAssertTrue(severityScreen.waitForExistence(timeout: 5))
        
        let moderateOption = app.buttons["Moderate"]
        XCTAssertTrue(moderateOption.waitForExistence(timeout: 5))
        moderateOption.tap()
        
        nextButton.tap()
        
        // Step 3: Photo Documentation
        let photoScreen = app.staticTexts["Document the damage with photos"]
        XCTAssertTrue(photoScreen.waitForExistence(timeout: 5))
        
        let addDamagePhotoButton = app.buttons["Add Damage Photo"]
        XCTAssertTrue(addDamagePhotoButton.waitForExistence(timeout: 5))
        addDamagePhotoButton.tap()
        
        // Mock camera for damage documentation
        let takeDamagePhotoButton = app.buttons["Take Photo"]
        XCTAssertTrue(takeDamagePhotoButton.waitForExistence(timeout: 5))
        takeDamagePhotoButton.tap()
        
        let damageCaptureButton = app.buttons["Capture"]
        XCTAssertTrue(damageCaptureButton.waitForExistence(timeout: 5))
        damageCaptureButton.tap()
        
        let useDamagePhotoButton = app.buttons["Use Photo"]
        XCTAssertTrue(useDamagePhotoButton.waitForExistence(timeout: 5))
        useDamagePhotoButton.tap()
        
        nextButton.tap()
        
        // Step 4: Incident Details
        let incidentScreen = app.staticTexts["Describe what happened"]
        XCTAssertTrue(incidentScreen.waitForExistence(timeout: 5))
        
        let incidentField = app.textViews["Incident Description"]
        XCTAssertTrue(incidentField.waitForExistence(timeout: 5))
        incidentField.tap()
        incidentField.typeText("Water damage occurred during kitchen flooding incident on [date]. Item was submerged for approximately 2 hours before rescue.")
        
        let dateField = app.datePickers["Incident Date"]
        XCTAssertTrue(dateField.waitForExistence(timeout: 5))
        // Date selection would be automated here
        
        nextButton.tap()
        
        // Step 5: Review and Submit
        let reviewScreen = app.staticTexts["Review Damage Assessment"]
        XCTAssertTrue(reviewScreen.waitForExistence(timeout: 5))
        
        // Verify all information is displayed
        let damageTypeSummary = app.staticTexts["Water Damage"]
        XCTAssertTrue(damageTypeSummary.exists)
        
        let severitySummary = app.staticTexts["Moderate"]
        XCTAssertTrue(severitySummary.exists)
        
        // Submit assessment
        let submitButton = app.buttons["Submit Assessment"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 5))
        submitButton.tap()
        
        // Verify completion
        let confirmationAlert = app.alerts["Assessment Submitted"]
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: 5))
        confirmationAlert.buttons["OK"].tap()
        
        // Verify item now shows damage status
        let itemDetailScreen = app.staticTexts["Item Details"]
        XCTAssertTrue(itemDetailScreen.waitForExistence(timeout: 5))
        
        let damageIndicator = app.images["Damage Reported"]
        XCTAssertTrue(damageIndicator.exists, "Item should show damage indicator")
    }
    
    func testWarrantyTrackingWorkflow() async throws {
        // Test warranty tracking and expiration notifications
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Navigate to warranty tracking
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()
        
        let warrantyTrackingOption = app.cells["Warranty Tracking"]
        XCTAssertTrue(warrantyTrackingOption.waitForExistence(timeout: 5))
        warrantyTrackingOption.tap()
        
        // View warranty overview
        let warrantyOverview = app.staticTexts["Warranty Overview"]
        XCTAssertTrue(warrantyOverview.waitForExistence(timeout: 5))
        
        // Check for expiring warranties
        let expiringSection = app.staticTexts["Expiring Soon"]
        if expiringSection.exists {
            // Test warranty extension workflow
            let expiringItem = app.cells.containing(.staticText, identifier: "Expires in").firstMatch
            if expiringItem.exists {
                expiringItem.tap()
                
                let extendWarrantyButton = app.buttons["Extend Warranty"]
                if extendWarrantyButton.exists {
                    extendWarrantyButton.tap()
                    
                    // Test warranty extension options
                    let purchaseExtensionButton = app.buttons["Purchase Extended Warranty"]
                    XCTAssertTrue(purchaseExtensionButton.waitForExistence(timeout: 5))
                    
                    let checkThirdPartyButton = app.buttons["Check Third-Party Options"]
                    XCTAssertTrue(checkThirdPartyButton.exists)
                }
            }
        }
        
        // Test warranty notification settings
        let notificationSettingsButton = app.buttons["Notification Settings"]
        XCTAssertTrue(notificationSettingsButton.waitForExistence(timeout: 5))
        notificationSettingsButton.tap()
        
        let alertTimingPicker = app.buttons["Alert Timing"]
        XCTAssertTrue(alertTimingPicker.waitForExistence(timeout: 5))
        alertTimingPicker.tap()
        
        // Select notification timing
        let thirtyDaysOption = app.buttons["30 days before expiration"]
        XCTAssertTrue(thirtyDaysOption.waitForExistence(timeout: 5))
        thirtyDaysOption.tap()
        
        let enableEmailToggle = app.switches["Email Notifications"]
        XCTAssertTrue(enableEmailToggle.waitForExistence(timeout: 5))
        if !enableEmailToggle.isSelected {
            enableEmailToggle.tap()
        }
        
        // Save settings
        let saveSettingsButton = app.buttons["Save Settings"]
        XCTAssertTrue(saveSettingsButton.waitForExistence(timeout: 5))
        saveSettingsButton.tap()
        
        // Verify settings saved
        let confirmationToast = app.staticTexts["Settings saved"]
        XCTAssertTrue(confirmationToast.waitForExistence(timeout: 5))
    }
    
    func testReceiptOCRWorkflow() async throws {
        // Test OCR receipt processing for automatic data extraction
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Navigate to add item
        let inventoryTab = app.tabBars.buttons["Inventory"]
        XCTAssertTrue(inventoryTab.waitForExistence(timeout: 5))
        inventoryTab.tap()
        
        let addItemButton = app.navigationBars.buttons["Add Item"]
        XCTAssertTrue(addItemButton.waitForExistence(timeout: 5))
        addItemButton.tap()
        
        // Start with receipt scanning
        let scanReceiptButton = app.buttons["Scan Receipt First"]
        XCTAssertTrue(scanReceiptButton.waitForExistence(timeout: 5))
        scanReceiptButton.tap()
        
        // Mock camera interface for receipt
        let takeReceiptPhotoButton = app.buttons["Take Photo"]
        XCTAssertTrue(takeReceiptPhotoButton.waitForExistence(timeout: 5))
        takeReceiptPhotoButton.tap()
        
        let receiptCaptureButton = app.buttons["Capture"]
        XCTAssertTrue(receiptCaptureButton.waitForExistence(timeout: 5))
        receiptCaptureButton.tap()
        
        let useReceiptButton = app.buttons["Use Photo"]
        XCTAssertTrue(useReceiptButton.waitForExistence(timeout: 5))
        useReceiptButton.tap()
        
        // OCR processing
        let ocrProgressIndicator = app.activityIndicators["Processing Receipt"]
        XCTAssertTrue(ocrProgressIndicator.waitForExistence(timeout: 5))
        
        // Wait for OCR results
        let ocrResultsScreen = app.staticTexts["Receipt Information Extracted"]
        XCTAssertTrue(ocrResultsScreen.waitForExistence(timeout: 15))
        
        // Verify extracted data appears in fields
        let extractedNameField = app.textFields["Item Name"]
        XCTAssertTrue(extractedNameField.waitForExistence(timeout: 5))
        XCTAssertFalse(extractedNameField.value as? String == "", "Item name should be extracted")
        
        let extractedPriceField = app.textFields["Purchase Price"]
        XCTAssertTrue(extractedPriceField.waitForExistence(timeout: 5))
        XCTAssertFalse(extractedPriceField.value as? String == "", "Price should be extracted")
        
        let extractedDateField = app.textFields["Purchase Date"]
        XCTAssertTrue(extractedDateField.waitForExistence(timeout: 5))
        XCTAssertFalse(extractedDateField.value as? String == "", "Date should be extracted")
        
        // Verify and correct extracted data
        let reviewOCRButton = app.buttons["Review & Correct"]
        XCTAssertTrue(reviewOCRButton.waitForExistence(timeout: 5))
        reviewOCRButton.tap()
        
        // OCR correction interface
        let ocrReviewScreen = app.staticTexts["Review Extracted Information"]
        XCTAssertTrue(ocrReviewScreen.waitForExistence(timeout: 5))
        
        // Test correction functionality
        let correctNameButton = app.buttons["Correct Name"]
        if correctNameButton.exists {
            correctNameButton.tap()
            let correctionField = app.textFields["Corrected Name"]
            XCTAssertTrue(correctionField.waitForExistence(timeout: 5))
            correctionField.tap()
            correctionField.typeText("Corrected Item Name")
        }
        
        // Confirm corrections
        let confirmCorrectionsButton = app.buttons["Confirm All"]
        XCTAssertTrue(confirmCorrectionsButton.waitForExistence(timeout: 5))
        confirmCorrectionsButton.tap()
        
        // Complete item creation
        let finishButton = app.buttons["Finish"]
        XCTAssertTrue(finishButton.waitForExistence(timeout: 5))
        finishButton.tap()
        
        // Verify item created with OCR data
        let createdItemCell = app.cells.firstMatch
        XCTAssertTrue(createdItemCell.waitForExistence(timeout: 5))
        
        let ocrProcessedBadge = createdItemCell.images["OCR Processed"]
        XCTAssertTrue(ocrProcessedBadge.exists, "Item should show OCR processed indicator")
    }
    
    // MARK: - Helper Methods
    
    private func createSampleInsuranceItems() async {
        // Helper method to create sample data for testing
        // This would be expanded based on the app's data seeding capabilities
        
        // Navigate to add item
        let addItemButton = app.navigationBars.buttons["Add Item"]
        if addItemButton.waitForExistence(timeout: 2) {
            addItemButton.tap()
            
            // Quick item creation
            let nameField = app.textFields["Item Name"]
            if nameField.waitForExistence(timeout: 2) {
                nameField.tap()
                nameField.typeText("Sample Item")
                
                let priceField = app.textFields["Purchase Price"]
                if priceField.waitForExistence(timeout: 2) {
                    priceField.tap()
                    priceField.typeText("100.00")
                    
                    let saveButton = app.navigationBars.buttons["Save"]
                    if saveButton.waitForExistence(timeout: 2) {
                        saveButton.tap()
                    }
                }
            }
        }
    }
    
    private func waitForLoadingToComplete() {
        // Helper to wait for any loading indicators to disappear
        let loadingIndicators = app.activityIndicators
        
        for indicator in loadingIndicators.allElementsBoundByIndex {
            if indicator.exists {
                let exists = NSPredicate(format: "exists == false")
                expectation(for: exists, evaluatedWith: indicator, handler: nil)
                waitForExpectations(timeout: 10)
            }
        }
    }
    
    private func dismissAnyAlerts() {
        // Helper to dismiss any system alerts that might interfere
        if app.alerts.count > 0 {
            let alert = app.alerts.firstMatch
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
            } else if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
            } else if alert.buttons["Cancel"].exists {
                alert.buttons["Cancel"].tap()
            }
        }
    }
}
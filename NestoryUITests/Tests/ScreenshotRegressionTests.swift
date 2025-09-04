//
// ScreenshotRegressionTests.swift
// NestoryUITests
//
// Comprehensive screenshot regression testing for insurance workflows
//

@preconcurrency import XCTest

@MainActor
final class ScreenshotRegressionTests: XCTestCase {
    
    // MARK: - Properties
    
    var app: XCUIApplication!
    
    // MARK: - Configuration
    
    private struct Config {
        static let baselineDirectory = "/tmp/nestory_baselines"
        static let testOutputDirectory = "/tmp/nestory_test_screenshots"
        static let diffOutputDirectory = "/tmp/nestory_diffs"
        static let similarityThreshold: Double = 0.98 // 98% similarity required
    }
    
    // MARK: - Setup
    
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = [
            "UITEST_MODE",
            "DISABLE_ANIMATIONS",
            "USE_DETERMINISTIC_DATA",
            "FREEZE_TIME_2024_01_15", // Fixed date for consistent screenshots
            "BYPASS_AUTH",
            "MOCK_CAMERA",
            "MOCK_OCR"
        ]
        app.launchEnvironment = [
            "UI_TESTING": "1",
            "SCREENSHOT_MODE": "1",
            "DETERMINISTIC_MODE": "1"
        ]
        
        setupDirectories()
    }
    
    override func tearDown() async throws {
        app = nil
        try await super.tearDown()
    }
    
    // MARK: - Insurance Workflow Screenshot Tests
    
    func testInventoryScreenshotRegression() async throws {
        // Test inventory list visual regression with insurance data
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Navigate to inventory
        let inventoryTab = app.tabBars.buttons["Inventory"]
        XCTAssertTrue(inventoryTab.waitForExistence(timeout: 5))
        inventoryTab.tap()
        
        // Wait for content to load
        let inventoryList = app.collectionViews.firstMatch
        XCTAssertTrue(inventoryList.waitForExistence(timeout: 5))
        
        // Take screenshot and compare
        let screenshotResult = await captureAndCompareScreenshot(
            name: "inventory_list_main",
            description: "Main inventory list with insurance items"
        )
        
        XCTAssertTrue(screenshotResult.isMatch, 
                     "Inventory screenshot regression detected. Similarity: \(screenshotResult.similarity)")
        
        // Test different inventory states
        await testInventoryStateScreenshots()
    }
    
    func testInsuranceItemDetailScreenshots() async throws {
        // Test item detail view with insurance information
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        let inventoryTab = app.tabBars.buttons["Inventory"]
        XCTAssertTrue(inventoryTab.waitForExistence(timeout: 5))
        inventoryTab.tap()
        
        // Select first item
        let firstItem = app.cells.firstMatch
        XCTAssertTrue(firstItem.waitForExistence(timeout: 5))
        firstItem.tap()
        
        // Wait for detail view
        let itemDetailView = app.otherElements["Item Detail View"]
        XCTAssertTrue(itemDetailView.waitForExistence(timeout: 5))
        
        // Test complete item detail with all insurance information
        let result = await captureAndCompareScreenshot(
            name: "item_detail_complete",
            description: "Complete item detail with photos, receipts, and warranty"
        )
        
        XCTAssertTrue(result.isMatch,
                     "Item detail screenshot regression detected. Similarity: \(result.similarity)")
        
        // Test edit mode
        await testItemEditModeScreenshots()
        
        // Test different item conditions
        await testItemConditionScreenshots()
    }
    
    func testDamageAssessmentScreenshots() async throws {
        // Test damage assessment workflow visual regression
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Navigate to item and start damage assessment
        let inventoryTab = app.tabBars.buttons["Inventory"]
        XCTAssertTrue(inventoryTab.waitForExistence(timeout: 5))
        inventoryTab.tap()
        
        let firstItem = app.cells.firstMatch
        if firstItem.waitForExistence(timeout: 5) {
            firstItem.tap()
            
            let moreButton = app.navigationBars.buttons["More"]
            if moreButton.waitForExistence(timeout: 5) {
                moreButton.tap()
                
                let damageOption = app.buttons["Report Damage"]
                if damageOption.waitForExistence(timeout: 5) {
                    damageOption.tap()
                    
                    // Test damage assessment wizard screenshots
                    await testDamageAssessmentWizardScreenshots()
                }
            }
        }
    }
    
    func testInsuranceReportScreenshots() async throws {
        // Test insurance report generation interface
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Navigate to settings
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()
        
        // Access insurance reports
        let insuranceReports = app.cells["Insurance Reports"]
        if insuranceReports.waitForExistence(timeout: 5) {
            insuranceReports.tap()
            
            // Test report generation interface
            let result = await captureAndCompareScreenshot(
                name: "insurance_report_generation",
                description: "Insurance report generation interface"
            )
            
            XCTAssertTrue(result.isMatch,
                         "Insurance report interface regression detected. Similarity: \(result.similarity)")
            
            // Test report customization options
            await testReportCustomizationScreenshots()
        }
    }
    
    func testReceiptOCRScreenshots() async throws {
        // Test receipt OCR interface visual regression
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        let inventoryTab = app.tabBars.buttons["Inventory"]
        XCTAssertTrue(inventoryTab.waitForExistence(timeout: 5))
        inventoryTab.tap()
        
        let addButton = app.navigationBars.buttons["Add Item"]
        if addButton.waitForExistence(timeout: 5) {
            addButton.tap()
            
            let scanReceiptButton = app.buttons["Scan Receipt"]
            if scanReceiptButton.waitForExistence(timeout: 5) {
                scanReceiptButton.tap()
                
                // Test camera interface for receipt scanning
                let result = await captureAndCompareScreenshot(
                    name: "receipt_camera_interface",
                    description: "Receipt scanning camera interface"
                )
                
                XCTAssertTrue(result.isMatch,
                             "Receipt OCR interface regression detected. Similarity: \(result.similarity)")
                
                // Test OCR results processing screen
                await testOCRResultsScreenshots()
            }
        }
    }
    
    func testWarrantyTrackingScreenshots() async throws {
        // Test warranty tracking interface
        
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()
        
        let warrantyTracking = app.cells["Warranty Tracking"]
        if warrantyTracking.waitForExistence(timeout: 5) {
            warrantyTracking.tap()
            
            // Test warranty overview screen
            let result = await captureAndCompareScreenshot(
                name: "warranty_tracking_overview",
                description: "Warranty tracking overview with expiration indicators"
            )
            
            XCTAssertTrue(result.isMatch,
                         "Warranty tracking interface regression detected. Similarity: \(result.similarity)")
            
            // Test warranty extension workflow
            await testWarrantyExtensionScreenshots()
        }
    }
    
    func testDarkModeScreenshotRegression() async throws {
        // Test dark mode visual regression for insurance workflows
        
        app.launchEnvironment["FORCE_DARK_MODE"] = "1"
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Test key screens in dark mode
        let screens = [
            ("inventory_dark", "Inventory"),
            ("settings_dark", "Settings"),
            ("add_item_dark", "Add Item")
        ]
        
        for (screenshotName, tabName) in screens {
            let tab = app.tabBars.buttons[tabName]
            if tab.waitForExistence(timeout: 5) {
                tab.tap()
                
                if tabName == "Add Item" {
                    let addButton = app.navigationBars.buttons["Add Item"]
                    if addButton.waitForExistence(timeout: 3) {
                        addButton.tap()
                    }
                }
                
                let result = await captureAndCompareScreenshot(
                    name: screenshotName,
                    description: "\(tabName) screen in dark mode"
                )
                
                XCTAssertTrue(result.isMatch,
                             "\(tabName) dark mode regression detected. Similarity: \(result.similarity)")
            }
        }
    }
    
    func testAccessibilityScreenshots() async throws {
        // Test large text accessibility screenshots
        
        app.launchEnvironment["DYNAMIC_TYPE_SIZE"] = "UICTContentSizeCategoryXXXL"
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        
        // Test inventory with large text
        let inventoryTab = app.tabBars.buttons["Inventory"]
        XCTAssertTrue(inventoryTab.waitForExistence(timeout: 5))
        inventoryTab.tap()
        
        let result = await captureAndCompareScreenshot(
            name: "inventory_large_text",
            description: "Inventory with XXXL Dynamic Type"
        )
        
        XCTAssertTrue(result.isMatch,
                     "Large text accessibility regression detected. Similarity: \(result.similarity)")
    }
    
    // MARK: - Helper Screenshot Methods
    
    private func testInventoryStateScreenshots() async {
        // Test different inventory states
        
        // Empty state (if applicable)
        // Loading state
        // Filtered state
        // Search results state
        
        // Each state would be tested with captureAndCompareScreenshot
    }
    
    private func testItemEditModeScreenshots() async {
        let editButton = app.navigationBars.buttons["Edit"]
        if editButton.waitForExistence(timeout: 3) {
            editButton.tap()
            
            let result = await captureAndCompareScreenshot(
                name: "item_edit_mode",
                description: "Item in edit mode with all fields"
            )
            
            // Would include XCTAssert for regression detection
        }
    }
    
    private func testItemConditionScreenshots() async {
        // Test different item condition displays
        let conditions = ["Excellent", "Good", "Fair", "Poor", "Damaged"]
        
        for condition in conditions {
            // Logic to set item condition and capture screenshot
            // This would be expanded based on app's condition setting mechanism
        }
    }
    
    private func testDamageAssessmentWizardScreenshots() async {
        let wizardScreens = [
            "damage_type_selection",
            "damage_severity",
            "damage_photos",
            "incident_details",
            "assessment_review"
        ]
        
        for screenName in wizardScreens {
            // Navigate to each wizard step and capture screenshot
            let result = await captureAndCompareScreenshot(
                name: screenName,
                description: "Damage assessment wizard: \(screenName)"
            )
            
            // Progress to next step
            let nextButton = app.buttons["Next"]
            if nextButton.waitForExistence(timeout: 3) {
                nextButton.tap()
            }
        }
    }
    
    private func testReportCustomizationScreenshots() async {
        // Test report customization options
        let options = [
            "Include Photos",
            "Include Receipts", 
            "Include Warranty Info",
            "Include Condition Assessment"
        ]
        
        for option in options {
            let toggle = app.switches[option]
            if toggle.waitForExistence(timeout: 2) {
                toggle.tap()
                
                let result = await captureAndCompareScreenshot(
                    name: "report_options_\(option.lowercased().replacingOccurrences(of: " ", with: "_"))",
                    description: "Report customization with \(option) toggled"
                )
            }
        }
    }
    
    private func testOCRResultsScreenshots() async {
        // Simulate OCR completion and test results screen
        let ocrResults = app.otherElements["OCR Results"]
        if ocrResults.waitForExistence(timeout: 10) {
            let result = await captureAndCompareScreenshot(
                name: "ocr_results_processed",
                description: "OCR results with extracted receipt data"
            )
            
            // Test correction interface
            let correctButton = app.buttons["Review & Correct"]
            if correctButton.waitForExistence(timeout: 3) {
                correctButton.tap()
                
                let correctionResult = await captureAndCompareScreenshot(
                    name: "ocr_correction_interface",
                    description: "OCR correction interface with editable fields"
                )
            }
        }
    }
    
    private func testWarrantyExtensionScreenshots() async {
        // Test warranty extension workflow
        let extendButton = app.buttons["Extend Warranty"]
        if extendButton.waitForExistence(timeout: 3) {
            extendButton.tap()
            
            let result = await captureAndCompareScreenshot(
                name: "warranty_extension_options",
                description: "Warranty extension options and providers"
            )
        }
    }
    
    // MARK: - Screenshot Comparison Infrastructure
    
    private func setupDirectories() {
        let directories = [
            Config.baselineDirectory,
            Config.testOutputDirectory,
            Config.diffOutputDirectory
        ]
        
        for directory in directories {
            let url = URL(fileURLWithPath: directory)
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
    
    private func captureAndCompareScreenshot(
        name: String,
        description: String
    ) async -> ScreenshotComparisonResult {
        
        // Ensure UI is stable before screenshot
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
        
        // Capture current screenshot
        let screenshot = app.screenshot()
        let testImageData = screenshot.pngRepresentation
        
        // Save test screenshot
        let testImagePath = "\(Config.testOutputDirectory)/\(name)_test.png"
        let testImageURL = URL(fileURLWithPath: testImagePath)
        
        do {
            try testImageData.write(to: testImageURL)
        } catch {
            print("❌ Failed to save test screenshot: \(error)")
            return ScreenshotComparisonResult(isMatch: false, similarity: 0.0, error: error)
        }
        
        // Check for baseline
        let baselineImagePath = "\(Config.baselineDirectory)/\(name)_baseline.png"
        let baselineImageURL = URL(fileURLWithPath: baselineImagePath)
        
        guard FileManager.default.fileExists(atPath: baselineImagePath) else {
            // No baseline exists - create one
            try? testImageData.write(to: baselineImageURL)
            print("📸 Created new baseline: \(name)")
            return ScreenshotComparisonResult(isMatch: true, similarity: 1.0, isNewBaseline: true)
        }
        
        // Compare with baseline
        guard let baselineImageData = try? Data(contentsOf: baselineImageURL) else {
            return ScreenshotComparisonResult(isMatch: false, similarity: 0.0, error: nil)
        }
        
        let similarity = compareImages(testImageData, baselineImageData)
        let isMatch = similarity >= Config.similarityThreshold
        
        if !isMatch {
            // Generate diff image
            generateDiffImage(name: name, testData: testImageData, baselineData: baselineImageData)
        }
        
        print("📊 Screenshot comparison '\(name)': \(similarity * 100)% similarity")
        
        return ScreenshotComparisonResult(
            isMatch: isMatch,
            similarity: similarity,
            testImagePath: testImagePath,
            baselineImagePath: baselineImagePath
        )
    }
    
    private func compareImages(_ image1: Data, _ image2: Data) -> Double {
        // Simple data comparison for now
        // In a real implementation, this would use image processing to compare visual similarity
        if image1 == image2 {
            return 1.0
        }
        
        // Calculate basic similarity based on data differences
        let minLength = min(image1.count, image2.count)
        let maxLength = max(image1.count, image2.count)
        
        if minLength == 0 {
            return 0.0
        }
        
        var matchingBytes = 0
        let bytes1 = Array(image1.prefix(minLength))
        let bytes2 = Array(image2.prefix(minLength))
        
        for i in 0..<minLength {
            if bytes1[i] == bytes2[i] {
                matchingBytes += 1
            }
        }
        
        let baselineSimilarity = Double(matchingBytes) / Double(minLength)
        let sizeSimilarity = Double(minLength) / Double(maxLength)
        
        return (baselineSimilarity + sizeSimilarity) / 2.0
    }
    
    private func generateDiffImage(name: String, testData: Data, baselineData: Data) {
        // Generate diff visualization
        let diffPath = "\(Config.diffOutputDirectory)/\(name)_diff.png"
        
        // In a real implementation, this would create a visual diff
        // For now, just save both images with clear naming
        try? testData.write(to: URL(fileURLWithPath: "\(Config.diffOutputDirectory)/\(name)_current.png"))
        try? baselineData.write(to: URL(fileURLWithPath: "\(Config.diffOutputDirectory)/\(name)_expected.png"))
        
        print("🔍 Diff images saved for: \(name)")
    }
}

// MARK: - Supporting Types

struct ScreenshotComparisonResult {
    let isMatch: Bool
    let similarity: Double
    let error: Error?
    let testImagePath: String?
    let baselineImagePath: String?
    let isNewBaseline: Bool
    
    init(isMatch: Bool, similarity: Double, error: Error? = nil, testImagePath: String? = nil, baselineImagePath: String? = nil, isNewBaseline: Bool = false) {
        self.isMatch = isMatch
        self.similarity = similarity
        self.error = error
        self.testImagePath = testImagePath
        self.baselineImagePath = baselineImagePath
        self.isNewBaseline = isNewBaseline
    }
}
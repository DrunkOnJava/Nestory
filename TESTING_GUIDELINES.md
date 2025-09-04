# Testing Guidelines for Nestory

## Overview

This document outlines comprehensive testing guidelines for Nestory, a personal home inventory app for insurance documentation. Our testing strategy ensures reliability, performance, and quality across all critical insurance workflows.

## Testing Philosophy

### Core Principles
- **Insurance-First Testing**: All tests prioritize insurance documentation scenarios
- **TCA Pattern Compliance**: Follow The Composable Architecture testing patterns with TestStore
- **Crash-Free Operation**: Zero tolerance for force unwraps or unhandled errors
- **Realistic Data**: Use insurance-relevant test data and scenarios
- **Performance-Aware**: Every test considers real-world usage patterns

### Quality Targets
- **Critical Insurance Workflows**: 95% test coverage minimum
- **TCA Features**: 90% test coverage minimum
- **Test Suite Performance**: Complete execution in under 5 minutes
- **Crash-Free Rate**: 99.8% minimum in production
- **Build Health**: All tests must pass 3 consecutive runs

## Test Architecture

### Directory Structure
```
NestoryTests/
├── Unit/
│   ├── Models/           # SwiftData model tests
│   ├── Services/         # Service layer unit tests
│   └── Utilities/        # Helper and utility tests
├── Integration/
│   ├── Insurance/        # End-to-end insurance workflows
│   ├── CloudKit/         # Sync and conflict resolution
│   └── DataMigration/    # Schema migration testing
├── Features/
│   ├── SearchFeatureTests.swift
│   ├── ItemDetailFeatureTests.swift
│   ├── ItemEditFeatureTests.swift
│   └── DamageAssessmentFeatureTests.swift
├── Performance/
│   ├── PerformanceTests.swift
│   ├── InsuranceReportPerformanceTests.swift
│   ├── OCRPerformanceTests.swift
│   └── UIResponsivenessTests.swift
└── Mocks/
    ├── EnhancedMockServices.swift
    └── TestDataFactory.swift

NestoryUITests/
├── Tests/
│   ├── InsuranceWorkflowUITests.swift
│   ├── ScreenshotRegressionTests.swift
│   └── UserJourneyTests.swift
├── AccessibilityTests/
│   └── AccessibilityTests.swift
├── Performance/
│   └── UIPerformanceTests.swift
└── Framework/
    ├── ScreenshotHelper.swift
    └── InteractionSampler.swift
```

## TCA Testing Patterns

### TestStore Setup Pattern
```swift
@MainActor
func testInsuranceItemCreation() async {
    let store = TestStore(
        initialState: InventoryFeature.State(),
        reducer: { InventoryFeature() }
    ) {
        // Mock dependencies for insurance-specific testing
        $0.inventoryService = MockInventoryService()
        $0.insuranceReportService = MockInsuranceReportService()
        $0.receiptOCRService = MockReceiptOCRService()
    }
    
    // Test insurance item creation workflow
    await store.send(.createInsuranceItem("Laptop")) {
        $0.isCreatingItem = true
    }
    
    await store.receive(.itemCreated(.success(item))) {
        $0.isCreatingItem = false
        $0.items.append(item)
    }
}
```

### Action Testing Pattern
```swift
// ✅ Test complete action flows
await store.send(.generateInsuranceReport) {
    $0.isGeneratingReport = true
}

await store.receive(.reportGenerated(.success(pdf))) {
    $0.isGeneratingReport = false
    $0.lastGeneratedReport = pdf
}

// ✅ Test error scenarios
await store.receive(.reportGenerated(.failure(error))) {
    $0.isGeneratingReport = false
    $0.errorMessage = "Failed to generate insurance report"
}
```

## Model Testing Guidelines

### SwiftData Model Tests
```swift
final class ItemModelTests: XCTestCase {
    var container: ModelContainer!
    
    override func setUp() async throws {
        // Create in-memory container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Item.self, configurations: config)
    }
    
    @MainActor
    func testInsuranceItemCreation() throws {
        let context = container.mainContext
        
        // Create item with insurance-relevant data
        let item = Item(
            name: "MacBook Pro",
            purchasePrice: Decimal(2499.00),
            room: "Home Office",
            category: "Electronics"
        )
        
        context.insert(item)
        try context.save()
        
        // Verify insurance-critical properties
        XCTAssertEqual(item.name, "MacBook Pro")
        XCTAssertEqual(item.purchasePrice, Decimal(2499.00))
        XCTAssertEqual(item.room, "Home Office")
        
        // Verify CloudKit compatibility
        XCTAssertNotNil(item.id)
        XCTAssertNotNil(item.dateCreated)
    }
}
```

### Property Validation
```swift
func testInsuranceRequiredFields() {
    // Test that items can be created without optional insurance fields
    let minimalItem = Item(name: "Basic Item")
    XCTAssertNotNil(minimalItem)
    
    // Test insurance-complete item
    let completeItem = Item(
        name: "Expensive Jewelry",
        purchasePrice: Decimal(5000.00),
        serialNumber: "SN123456789",
        room: "Master Bedroom"
    )
    
    XCTAssertTrue(completeItem.isInsuranceReady)
}
```

## Service Testing Patterns

### Service Dependency Testing
```swift
final class InsuranceReportServiceTests: XCTestCase {
    var service: InsuranceReportService!
    var mockInventoryService: MockInventoryService!
    
    override func setUp() {
        mockInventoryService = MockInventoryService()
        service = LiveInsuranceReportService(
            inventoryService: mockInventoryService
        )
    }
    
    func testPDFGenerationForInsuranceClaim() async throws {
        // Setup test data with realistic insurance values
        let highValueItems = [
            Item(name: "Rolex Watch", purchasePrice: Decimal(8000)),
            Item(name: "MacBook Pro", purchasePrice: Decimal(2500)),
            Item(name: "Diamond Ring", purchasePrice: Decimal(12000))
        ]
        
        mockInventoryService.items = highValueItems
        
        // Generate insurance report
        let pdfData = try await service.generateInsuranceReport(
            for: highValueItems,
            claimType: .theft
        )
        
        // Verify PDF contains expected insurance information
        XCTAssertGreaterThan(pdfData.count, 50000) // Reasonable PDF size
        
        // Parse PDF content to verify insurance details
        let pdfContent = try extractPDFText(from: pdfData)
        XCTAssertTrue(pdfContent.contains("Total Claimed Value: $22,500.00"))
        XCTAssertTrue(pdfContent.contains("Theft Claim"))
    }
}
```

### Mock Service Implementation
```swift
class MockInsuranceReportService: InsuranceReportService {
    var generateReportResult: Result<Data, Error> = .success(Data())
    var generateReportCallCount = 0
    
    func generateInsuranceReport(
        for items: [Item],
        claimType: ClaimType
    ) async throws -> Data {
        generateReportCallCount += 1
        
        switch generateReportResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
}
```

## Performance Testing Guidelines

### Performance Test Setup
```swift
final class InsuranceReportPerformanceTests: XCTestCase {
    var service: InsuranceReportService!
    
    func testLargeInsuranceReportGeneration() throws {
        // Test with realistic large inventory (1000+ items)
        let largeInventory = createLargeInsuranceDataset(count: 1000)
        
        let options = XCTMeasureOptions()
        options.iterationCount = 5
        
        measure(options: options) {
            let expectation = expectation(description: "PDF Generation")
            
            Task {
                do {
                    let pdfData = try await service.generateInsuranceReport(
                        for: largeInventory,
                        claimType: .total_loss
                    )
                    XCTAssertGreaterThan(pdfData.count, 100000)
                    expectation.fulfill()
                } catch {
                    XCTFail("PDF generation failed: \(error)")
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
}
```

### Performance Benchmarks
- **Insurance Report Generation** (1000 items): < 3.0 seconds
- **Receipt OCR Processing**: < 2.0 seconds per receipt
- **Large Inventory Loading** (5000 items): < 1.5 seconds
- **Search Response Time**: < 0.3 seconds
- **CloudKit Sync** (100 items): < 5.0 seconds

## UI Testing Patterns

### Insurance Workflow UI Tests
```swift
@MainActor
final class InsuranceWorkflowUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() async throws {
        app = XCUIApplication()
        app.launchArguments = [
            "UITEST_MODE",
            "DISABLE_ANIMATIONS", 
            "USE_TEST_FIXTURES",
            "BYPASS_AUTH"
        ]
        app.launch()
    }
    
    func testCompleteInsuranceDocumentationFlow() async throws {
        // Navigate to inventory
        let inventoryTab = app.tabBars.buttons["Inventory"]
        XCTAssertTrue(inventoryTab.waitForExistence(timeout: 5))
        inventoryTab.tap()
        
        // Add new insurance item
        let addButton = app.buttons["Add Item"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        
        // Fill insurance-relevant details
        let nameField = app.textFields["Item Name"]
        nameField.tap()
        nameField.typeText("MacBook Pro 16-inch")
        
        let priceField = app.textFields["Purchase Price"]
        priceField.tap()
        priceField.typeText("2499.00")
        
        let roomField = app.textFields["Room"]
        roomField.tap()
        roomField.typeText("Home Office")
        
        // Save item
        app.buttons["Save"].tap()
        
        // Verify item appears in inventory
        XCTAssertTrue(app.staticTexts["MacBook Pro 16-inch"].waitForExistence(timeout: 5))
        
        // Test insurance report generation
        let itemRow = app.staticTexts["MacBook Pro 16-inch"]
        itemRow.tap()
        
        app.buttons["Generate Insurance Report"].tap()
        
        // Verify report generation success
        XCTAssertTrue(app.alerts["Report Generated"].waitForExistence(timeout: 10))
        app.buttons["OK"].tap()
    }
}
```

### Screenshot Testing
```swift
func testInsuranceReportScreenshots() async throws {
    // Navigate to report generation
    navigateToInsuranceReports()
    
    // Capture baseline screenshot
    let screenshot = app.screenshot()
    let attachment = XCTAttachment(screenshot: screenshot)
    attachment.name = "insurance_report_generation"
    attachment.lifetime = .keepAlways
    add(attachment)
    
    // Use ScreenshotHelper for advanced comparison
    let screenshotURL = ScreenshotHelper.captureAndSave(
        app: app,
        name: "insurance_report_\(Date().timeIntervalSince1970)"
    )
    
    XCTAssertNotNil(screenshotURL, "Screenshot should be saved successfully")
}
```

## Accessibility Testing

### WCAG Compliance Testing
```swift
func testInsuranceFormAccessibility() async throws {
    // Navigate to item creation form
    navigateToItemCreation()
    
    // Test VoiceOver labels
    let nameField = app.textFields["Item Name"]
    XCTAssertTrue(nameField.exists)
    XCTAssertNotEqual(nameField.label, "")
    
    let priceField = app.textFields["Purchase Price"]
    XCTAssertTrue(priceField.exists)
    XCTAssertTrue(priceField.label.contains("price") || priceField.label.contains("cost"))
    
    // Test keyboard navigation
    nameField.tap()
    app.keyboards.buttons["Next"].tap()
    XCTAssertTrue(priceField.hasKeyboardFocus)
    
    // Test dynamic type support
    app.activate()
    
    // Simulate larger text size
    XCUIDevice.shared.systemAccessibilityFeatures.increaseButtonShapes = true
    
    // Verify UI adapts to larger text
    XCTAssertTrue(nameField.exists)
    XCTAssertTrue(priceField.exists)
}
```

## Error Handling Testing

### Graceful Degradation Tests
```swift
func testNetworkErrorRecovery() async throws {
    // Simulate network failure
    let mockService = EnhancedMockReceiptOCRService()
    mockService.simulateNetworkCondition(.offline)
    
    // Attempt OCR operation
    do {
        _ = try await mockService.processReceipt(image: testImage)
        XCTFail("Should have thrown network error")
    } catch {
        // Verify graceful error handling
        XCTAssertTrue(error is NetworkError)
        
        // Verify app remains functional
        let store = TestStore(
            initialState: ReceiptScannerFeature.State(),
            reducer: { ReceiptScannerFeature() }
        ) {
            $0.receiptOCRService = mockService
        }
        
        await store.send(.processReceipt(testImage)) {
            $0.isProcessing = true
        }
        
        await store.receive(.receiptProcessed(.failure(error))) {
            $0.isProcessing = false
            $0.errorMessage = "Network unavailable. Please try again later."
        }
    }
}
```

## Test Data Guidelines

### Insurance-Relevant Test Data
```swift
extension Item {
    static func createInsuranceTestItem() -> Item {
        Item(
            name: "MacBook Pro 16-inch",
            purchasePrice: Decimal(2499.00),
            serialNumber: "C02ABC123DEF",
            room: "Home Office",
            category: "Electronics"
        )
    }
    
    static func createHighValueTestItems() -> [Item] {
        [
            Item(name: "Rolex Submariner", purchasePrice: Decimal(8000), room: "Master Bedroom"),
            Item(name: "Canon EOS R5", purchasePrice: Decimal(3900), room: "Living Room"),
            Item(name: "KitchenAid Mixer", purchasePrice: Decimal(450), room: "Kitchen")
        ]
    }
}
```

### Test Categories
- **Electronics**: Laptops, phones, cameras, TVs
- **Jewelry**: Watches, rings, necklaces  
- **Appliances**: Kitchen equipment, HVAC, tools
- **Furniture**: Sofas, tables, beds, cabinets
- **Collectibles**: Art, antiques, memorabilia
- **Sporting Goods**: Equipment, bikes, outdoor gear

## Continuous Integration

### Pre-commit Testing
```bash
# Run before every commit
make test           # All tests
make verify-arch    # Architecture compliance
make lint          # Code quality
make typecheck     # Swift type checking
```

### Build Pipeline Requirements
1. **Unit Tests**: Must pass all model and service tests
2. **Integration Tests**: Insurance workflows must complete successfully
3. **Performance Tests**: Must meet benchmark requirements
4. **UI Tests**: Critical user journeys must pass
5. **Accessibility Tests**: WCAG compliance validation
6. **Architecture Tests**: Layer compliance verification

### Test Execution Strategy
- **Parallel Execution**: Run independent test suites in parallel
- **Selective Testing**: Run only affected tests for incremental changes
- **Smoke Tests**: Quick validation subset for rapid feedback
- **Full Suite**: Complete test execution for release builds

## Documentation Requirements

### Test Documentation Standards
- Every test class must have class-level documentation explaining its purpose
- Complex test methods must include inline comments explaining the insurance scenario
- Mock services must document their simulation capabilities
- Performance tests must document their benchmark expectations

### Example Test Documentation
```swift
/// Tests the complete insurance documentation workflow from item creation
/// to report generation. This covers the primary user journey for documenting
/// belongings for insurance purposes.
///
/// Key scenarios tested:
/// - Creating items with insurance-relevant details
/// - Adding photos and receipts for documentation
/// - Generating PDF reports for insurance claims
/// - Error handling for network failures
final class InsuranceWorkflowIntegrationTests: XCTestCase {
    
    /// Tests the happy path for documenting a high-value item for insurance.
    /// This simulates a user adding an expensive electronic device with all
    /// recommended documentation for insurance claims.
    func testHighValueItemDocumentation() async throws {
        // Test implementation...
    }
}
```

## Best Practices Summary

### DO
- ✅ Use realistic insurance-relevant test data
- ✅ Test complete user workflows, not just individual functions
- ✅ Include error scenarios and edge cases
- ✅ Mock external dependencies (CloudKit, OCR services)
- ✅ Use @MainActor for SwiftData operations
- ✅ Validate insurance-specific requirements (coverage, documentation completeness)
- ✅ Test accessibility and WCAG compliance
- ✅ Measure and validate performance benchmarks

### DON'T  
- ❌ Use `try!` or force unwraps in tests
- ❌ Create tests that depend on external services
- ❌ Skip testing error conditions
- ❌ Use generic "test data" - make it insurance-relevant
- ❌ Ignore performance implications of test operations
- ❌ Test implementation details instead of behavior
- ❌ Create flaky tests that intermittently fail
- ❌ Skip cleanup in test tearDown methods

## Monitoring and Maintenance

### Test Health Metrics
- **Pass Rate**: 100% for release builds
- **Execution Time**: Track test suite duration trends
- **Flakiness**: Monitor and fix intermittently failing tests
- **Coverage**: Maintain coverage targets for critical paths

### Regular Maintenance Tasks
- Review and update test data quarterly
- Validate performance benchmarks monthly
- Update mock services when APIs change
- Refresh screenshot baselines for UI changes
- Archive obsolete tests when features are removed

This comprehensive testing strategy ensures Nestory maintains the highest quality standards for insurance documentation workflows while providing fast feedback during development.
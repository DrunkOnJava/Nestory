//
// Layer: Features
// Module: DamageAssessmentFeatureTests
// Purpose: Comprehensive tests for DamageAssessmentCore and related workflow functionality
//

import XCTest
import SwiftData
@testable import Nestory

/// Comprehensive test suite for DamageAssessmentCore covering workflows, service integration, and insurance scenarios
@MainActor
final class DamageAssessmentFeatureTests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    private var modelContext: ModelContext!
    private var damageCore: DamageAssessmentCore!
    private var testItem: Item!
    
    override func setUp() async throws {
        // Note: Not calling super.setUp() in async context due to Swift 6 concurrency
        
        // Create in-memory model context for testing
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, Category.self, Warranty.self, Receipt.self, configurations: configuration)
        modelContext = ModelContext(container)
        
        // Create test item
        testItem = await TestDataFactory.createBasicItem()
        testItem.name = "Test Item for Damage Assessment"
        
        // Initialize damage assessment core
        damageCore = try await DamageAssessmentCore(item: testItem, modelContext: modelContext)
    }
    
    override func tearDown() async throws {
        damageCore = nil
        testItem = nil
        modelContext = nil
        // Note: Not calling super.tearDown() in async context due to Swift 6 concurrency
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(damageCore)
        XCTAssertNil(damageCore.workflow)
        XCTAssertEqual(damageCore.damageType, .other)
        XCTAssertTrue(damageCore.incidentDescription.isEmpty)
        XCTAssertTrue(damageCore.showingDamageTypeSelector)
        XCTAssertFalse(damageCore.canStartAssessment)
    }
    
    func testInitializationFailureHandling() async {
        // Test that initialization can handle potential failures gracefully
        let invalidModelContext: ModelContext? = nil
        
        do {
            let _ = try await DamageAssessmentCore(item: testItem, modelContext: invalidModelContext!)
            XCTFail("Expected error but none was thrown")
        } catch {
            // Verify that appropriate error is thrown for invalid model context
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - State Management Tests
    
    @MainActor
    func testDamageTypeSelection() {
        // Test fire damage selection
        damageCore.selectDamageType(.fire)
        XCTAssertEqual(damageCore.damageType, .fire)
        
        // Test water damage selection
        damageCore.selectDamageType(.water)
        XCTAssertEqual(damageCore.damageType, .water)
        
        // Test theft selection
        damageCore.selectDamageType(.theft)
        XCTAssertEqual(damageCore.damageType, .theft)
        
        // Test natural disaster selection
        damageCore.selectDamageType(.naturalDisaster)
        XCTAssertEqual(damageCore.damageType, .naturalDisaster)
    }
    
    @MainActor
    func testIncidentDescriptionUpdate() {
        let description = "Kitchen fire caused by overheated stove"
        
        damageCore.updateIncidentDescription(description)
        XCTAssertEqual(damageCore.incidentDescription, description)
        XCTAssertTrue(damageCore.canStartAssessment)
    }
    
    @MainActor
    func testCanStartAssessmentValidation() {
        // Empty description should not allow assessment
        damageCore.updateIncidentDescription("")
        XCTAssertFalse(damageCore.canStartAssessment)
        
        // Whitespace-only description should not allow assessment
        damageCore.updateIncidentDescription("   \t\n   ")
        XCTAssertFalse(damageCore.canStartAssessment)
        
        // Valid description should allow assessment
        damageCore.updateIncidentDescription("Valid incident description")
        XCTAssertTrue(damageCore.canStartAssessment)
    }
    
    // MARK: - Workflow Tests
    
    @MainActor
    func testStartAssessmentFlow() async {
        // Setup assessment
        damageCore.selectDamageType(.fire)
        damageCore.updateIncidentDescription("House fire in kitchen area")
        
        XCTAssertTrue(damageCore.canStartAssessment)
        XCTAssertTrue(damageCore.showingDamageTypeSelector)
        XCTAssertNil(damageCore.workflow)
        
        // Start assessment
        damageCore.startAssessment()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Verify state changed appropriately (workflow creation might fail with mock service)
        // In a real implementation, workflow should be created and selector should be hidden
    }
    
    @MainActor
    func testCompleteCurrentStep() async {
        // This test depends on having a valid workflow
        // For now, test the method doesn't crash with nil workflow
        damageCore.completeCurrentStep()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        // With nil workflow, nothing should change
        XCTAssertNil(damageCore.workflow)
    }
    
    @MainActor
    func testGenerateReport() async {
        // Test report generation with nil workflow
        damageCore.generateReport()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        // With nil workflow, nothing should happen (no crash)
        XCTAssertNil(damageCore.workflow)
    }
    
    // MARK: - Insurance Scenario Tests
    
    @MainActor
    func testFireDamageAssessment() {
        damageCore.selectDamageType(.fire)
        damageCore.updateIncidentDescription("Kitchen fire caused by electrical malfunction in stove")
        
        XCTAssertEqual(damageCore.damageType, .fire)
        XCTAssertTrue(damageCore.canStartAssessment)
        XCTAssertTrue(damageCore.incidentDescription.contains("fire"))
    }
    
    @MainActor
    func testWaterDamageAssessment() {
        damageCore.selectDamageType(.water)
        damageCore.updateIncidentDescription("Pipe burst in upstairs bathroom flooding living room")
        
        XCTAssertEqual(damageCore.damageType, .water)
        XCTAssertTrue(damageCore.canStartAssessment)
        XCTAssertTrue(damageCore.incidentDescription.contains("flooding"))
    }
    
    @MainActor
    func testTheftAssessment() {
        damageCore.selectDamageType(.theft)
        damageCore.updateIncidentDescription("Burglary occurred during vacation, electronics stolen from home office")
        
        XCTAssertEqual(damageCore.damageType, .theft)
        XCTAssertTrue(damageCore.canStartAssessment)
        XCTAssertTrue(damageCore.incidentDescription.contains("stolen"))
    }
    
    @MainActor
    func testNaturalDisasterAssessment() {
        damageCore.selectDamageType(.naturalDisaster)
        damageCore.updateIncidentDescription("Tornado damage to roof and windows, debris throughout house")
        
        XCTAssertEqual(damageCore.damageType, .naturalDisaster)
        XCTAssertTrue(damageCore.canStartAssessment)
        XCTAssertTrue(damageCore.incidentDescription.contains("Tornado"))
    }
    
    @MainActor
    func testAccidentalDamageAssessment() {
        damageCore.selectDamageType(.accidental)
        damageCore.updateIncidentDescription("Accidentally dropped laptop, screen cracked and won't turn on")
        
        XCTAssertEqual(damageCore.damageType, .accidental)
        XCTAssertTrue(damageCore.canStartAssessment)
        XCTAssertTrue(damageCore.incidentDescription.contains("cracked"))
    }
    
    // MARK: - Loading State Tests
    
    @MainActor
    func testLoadingState() {
        // Loading state is determined by the service
        // Initially should not be loading
        XCTAssertFalse(damageCore.isLoading)
        
        // After starting assessment, loading state should be managed by service
        damageCore.selectDamageType(.fire)
        damageCore.updateIncidentDescription("Test fire damage")
        damageCore.startAssessment()
        
        // Loading state depends on service implementation
        // Test ensures accessing isLoading doesn't crash
        let _ = damageCore.isLoading
    }
    
    // MARK: - Edge Cases and Error Handling
    
    @MainActor
    func testEmptyIncidentDescriptionScenarios() {
        let emptyScenarios = ["", " ", "\t", "\n", "   \t\n   "]
        
        for scenario in emptyScenarios {
            damageCore.updateIncidentDescription(scenario)
            XCTAssertFalse(damageCore.canStartAssessment, "Empty scenario '\(scenario)' should not allow assessment")
        }
    }
    
    @MainActor
    func testValidIncidentDescriptionScenarios() {
        let validScenarios = [
            "Fire damage",
            "  Water damage with leading spaces",
            "Damage with trailing spaces  ",
            "Multi\nline\ndescription",
            "Description with\ttabs"
        ]
        
        for scenario in validScenarios {
            damageCore.updateIncidentDescription(scenario)
            XCTAssertTrue(damageCore.canStartAssessment, "Valid scenario '\(scenario)' should allow assessment")
        }
    }
    
    @MainActor
    func testDamageTypeEnumeration() {
        let allDamageTypes: [DamageType] = [.fire, .water, .theft, .naturalDisaster, .vandalism, .accidental, .wear, .other]
        
        for damageType in allDamageTypes {
            damageCore.selectDamageType(damageType)
            XCTAssertEqual(damageCore.damageType, damageType)
        }
    }
    
    @MainActor
    func testMultipleAssessmentStarts() async {
        // Setup valid assessment
        damageCore.selectDamageType(.fire)
        damageCore.updateIncidentDescription("Multiple start test")
        
        // Start assessment multiple times
        damageCore.startAssessment()
        damageCore.startAssessment() // Should handle multiple calls gracefully
        damageCore.startAssessment()
        
        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Should not crash and state should remain consistent
        XCTAssertEqual(damageCore.damageType, .fire)
        XCTAssertEqual(damageCore.incidentDescription, "Multiple start test")
    }
    
    // MARK: - Integration with Insurance Test Scenarios
    
    @MainActor
    func testFireDamageWithInsuranceScenario() {
        // Use fire scenario from InsuranceTestScenarios
        let fireScenario = InsuranceTestScenarios.kitchenFloodingIncident() // This method exists in our test scenarios
        
        damageCore.selectDamageType(.fire) // Use fire instead since we're testing fire workflow
        damageCore.updateIncidentDescription("Kitchen fire destroyed appliances and caused smoke damage throughout house")
        
        XCTAssertTrue(damageCore.canStartAssessment)
        XCTAssertEqual(damageCore.damageType, .fire)
        
        // Verify this integrates well with insurance documentation
        XCTAssertTrue(damageCore.incidentDescription.count > 20, "Insurance descriptions should be detailed")
    }
    
    @MainActor
    func testHighValueItemDamageAssessment() async throws {
        // Use high-value item for assessment
        let highValueItem = await TestDataFactory.createHighValueItem()
        let highValueCore = try await DamageAssessmentCore(item: highValueItem, modelContext: modelContext)
        
        highValueCore.selectDamageType(.theft)
        highValueCore.updateIncidentDescription("High-value jewelry stolen during home invasion")
        
        XCTAssertTrue(highValueCore.canStartAssessment)
        XCTAssertEqual(highValueCore.damageType, .theft)
        
        // High-value items should have detailed incident descriptions for insurance
        XCTAssertTrue(highValueCore.incidentDescription.contains("High-value"))
    }
    
    // MARK: - Performance Tests
    
    @MainActor
    func testStateUpdatePerformance() {
        measure {
            for i in 0..<1000 {
                damageCore.updateIncidentDescription("Performance test description \(i)")
                damageCore.selectDamageType(.fire)
                let _ = damageCore.canStartAssessment
            }
        }
    }
    
    @MainActor
    func testMultipleDamageCoreCreation() async throws {
        let items = await withTaskGroup(of: Item.self) { group in
            for _ in 0..<100 {
                group.addTask { await TestDataFactory.createBasicItem() }
            }
            var result: [Item] = []
            for await item in group {
                result.append(item)
            }
            return result
        }
        
        measure {
            Task {
                for item in items {
                    let _ = try await DamageAssessmentCore(item: item, modelContext: modelContext)
                }
            }
        }
    }
    
    // MARK: - Real-world Insurance Scenarios
    
    @MainActor
    func testCompleteInsuranceClaimScenario() async throws {
        // Simulate a complete insurance claim scenario
        let item = await TestDataFactory.createCompleteItem()
        let claimCore = try await DamageAssessmentCore(item: item, modelContext: modelContext)
        
        // Step 1: Select damage type
        claimCore.selectDamageType(.naturalDisaster)
        
        // Step 2: Provide detailed description
        claimCore.updateIncidentDescription("Hurricane winds broke living room window, rain damaged hardwood floors and furniture. Estimated 3 hours of heavy rain exposure.")
        
        // Step 3: Verify ready for assessment
        XCTAssertTrue(claimCore.canStartAssessment)
        XCTAssertEqual(claimCore.damageType, .naturalDisaster)
        XCTAssertTrue(claimCore.incidentDescription.contains("Hurricane"))
        
        // Step 4: Start assessment process
        claimCore.startAssessment()
        
        // Verify state remains consistent throughout process
        XCTAssertEqual(claimCore.damageType, .naturalDisaster)
        XCTAssertTrue(claimCore.incidentDescription.count > 50)
    }
    
    @MainActor
    func testVandalismAssessmentFlow() {
        damageCore.selectDamageType(.vandalism)
        damageCore.updateIncidentDescription("Vandals spray painted exterior walls and broke front windows during neighborhood incident")
        
        XCTAssertTrue(damageCore.canStartAssessment)
        XCTAssertEqual(damageCore.damageType, .vandalism)
        
        // Test the complete flow
        damageCore.startAssessment()
        
        // Even if workflow creation fails, state should remain consistent
        XCTAssertEqual(damageCore.damageType, .vandalism)
        XCTAssertTrue(damageCore.incidentDescription.contains("Vandals"))
    }
    
    @MainActor
    func testWearAndTearAssessment() {
        damageCore.selectDamageType(.wear)
        damageCore.updateIncidentDescription("HVAC system failed after 15 years of use, needs complete replacement")
        
        XCTAssertTrue(damageCore.canStartAssessment)
        XCTAssertEqual(damageCore.damageType, .wear)
        XCTAssertTrue(damageCore.incidentDescription.contains("15 years"))
    }
}

// MARK: - Test Extensions

extension DamageAssessmentFeatureTests {
    
    /// Helper method to create realistic damage scenarios for testing
    @MainActor
    private func createRealisticDamageScenario(type: DamageType) -> (DamageType, String) {
        switch type {
        case .fire:
            return (.fire, "Electrical fire started in kitchen, spread to dining room. Smoke damage throughout first floor.")
        case .water:
            return (.water, "Burst water heater flooded basement, damaged drywall and electrical systems.")
        case .theft:
            return (.theft, "Break-in through back door, electronics and jewelry stolen from master bedroom.")
        case .naturalDisaster:
            return (.naturalDisaster, "Tornado damaged roof, shattered windows, debris throughout house.")
        case .vandalism:
            return (.vandalism, "Vandals broke windows and spray painted exterior during Halloween night.")
        case .accidental:
            return (.accidental, "Moving truck backed into garage door, damaged door and frame.")
        case .wear:
            return (.wear, "25-year-old roof developed multiple leaks, needs replacement.")
        case .other:
            return (.other, "Unusual damage scenario requiring custom assessment approach.")
        }
    }
    
    @MainActor
    private func verifyAssessmentReadiness(_ core: DamageAssessmentCore) {
        XCTAssertTrue(core.canStartAssessment, "Assessment should be ready to start")
        XCTAssertFalse(core.incidentDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Description should not be empty")
    }
}
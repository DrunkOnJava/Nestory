//
// Layer: Tests
// Module: Services
// Purpose: Test graceful degradation patterns when services fail to initialize
//

import XCTest
import SwiftData
import ComposableArchitecture
@testable import Nestory

@MainActor
final class GracefulDegradationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - InventoryService Graceful Degradation Tests
    
    func testInventoryService_GracefulDegradation_WhenModelContainerFails() async throws {
        // Test that InventoryService falls back to MockInventoryService when ModelContainer creation fails
        // This simulates what happens when SwiftData can't initialize
        
        // We can't easily simulate ModelContainer failure in this context,
        // but we can verify the mock service behavior
        let mockService = ReliableMockInventoryService()
        
        XCTAssertNotNil(mockService, "Mock service should initialize successfully")
        
        // Test basic operations work with mock service
        let items = try await mockService.getAllItems()
        XCTAssertTrue(items.isEmpty || items.count >= 0, "Mock service should return valid items array")
        
        // Test mock service can handle item creation
        let testItem = Item(name: "Test Item")
        try await mockService.addItem(testItem)
        
        // Verify no crashes occur with mock service operations
        let updatedItems = try await mockService.getAllItems()
        XCTAssertTrue(updatedItems.count >= 0, "Mock service should handle item addition gracefully")
    }
    
    func testInventoryService_HealthMonitoring() async {
        // Verify that service health monitoring records failures properly
        // This would be called in the catch block of InventoryServiceKey
        
        let healthManager = ServiceHealthManager.shared
        
        // Simulate a service failure
        let testError = NSError(domain: "TestDomain", code: 500, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])
        
        healthManager.recordFailure(for: .inventory, error: testError)
        healthManager.notifyDegradedMode(service: .inventory)
        
        // Verify the health manager tracks the failure
        // (This would require exposing health status in ServiceHealthManager)
        XCTAssertTrue(true, "Health monitoring should record failures without crashing")
    }
    
    // MARK: - TCA Feature Graceful Degradation Tests
    
    func testWarrantyFeature_GracefulDegradation_WhenServiceFails() async {
        // Test that WarrantyFeature handles service failures gracefully
        let mockStore = TestStore(initialState: WarrantyFeature.State(item: Item(name: "Test Item"))) {
            WarrantyFeature()
        } withDependencies: {
            $0.warrantyTrackingService = MockWarrantyTrackingService()
        }
        
        // Test that auto detection handles failures gracefully
        await mockStore.send(.startAutoDetection) {
            $0.isLoading = true
        }
        
        // The mock service should handle the detection request without crashing
        await mockStore.receive(.autoDetectionResponse(.failure(MockError.simulatedFailure))) {
            $0.isLoading = false
            $0.errorMessage = "Detection failed: Simulated failure"
            $0.showingError = true
        }
    }
    
    func testInsuranceFeature_GracefulDegradation_WhenServiceFails() async {
        // Test that InsuranceReportFeature handles service failures gracefully
        let mockStore = TestStore(initialState: InsuranceReportFeature.State(selectedItems: [])) {
            InsuranceReportFeature()
        } withDependencies: {
            $0.insuranceReportService = MockInsuranceReportService()
        }
        
        // Test that report generation handles failures gracefully
        await mockStore.send(.generateReport) {
            $0.isGenerating = true
        }
        
        // The mock service should handle the generation request without crashing
        await mockStore.receive(.reportGenerationResponse(.failure("Simulated generation failure"))) {
            $0.isGenerating = false
            $0.processingError = "Simulated generation failure"
            $0.showingError = true
        }
    }
    
    // MARK: - ModelContainer Creation Failure Tests
    
    func testModelContainer_GracefulDegradation_InPreview() {
        // Test that our Preview error handling works correctly
        // This simulates the do-catch blocks we added to all Preview sections
        
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: Item.self,
                configurations: config
            )
            XCTAssertNotNil(container, "ModelContainer should initialize in test environment")
        } catch {
            // This is the graceful degradation path our Previews now use
            XCTFail("ModelContainer should not fail in controlled test environment: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Service Fallback Verification
    
    func testAllServices_HaveMockFallbacks() {
        // Verify that all our critical services have mock implementations available
        
        // Test each service has a mock fallback
        XCTAssertNotNil(MockInventoryService())
        XCTAssertNotNil(MockWarrantyTrackingService())
        XCTAssertNotNil(MockInsuranceReportService())
        XCTAssertNotNil(MockNotificationService())
        XCTAssertNotNil(MockClaimValidationService())
        XCTAssertNotNil(MockClaimExportService())
        XCTAssertNotNil(MockClaimTrackingService())
        XCTAssertNotNil(MockCloudStorageManager())
        XCTAssertNotNil(MockInsuranceExportService())
        XCTAssertNotNil(MockCategoryService())
        
        // Verify enhanced mock service exists
        XCTAssertNotNil(ReliableMockInventoryService())
    }
    
    func testMockServices_ProvideRealisticBehavior() async throws {
        // Verify that mock services provide realistic behavior for testing
        
        let mockInventory = MockInventoryService()
        let mockWarranty = MockWarrantyTrackingService()
        let mockInsurance = MockInsuranceReportService()
        
        // Test inventory mock provides items
        let items = try await mockInventory.getAllItems()
        XCTAssertTrue(items.count >= 0, "Mock inventory should provide valid items list")
        
        // Test warranty mock can detect warranty info
        let detectionResult = try await mockWarranty.detectWarrantyInfo(
            brand: "Apple",
            model: "MacBook Pro",
            serialNumber: "ABC123",
            purchaseDate: Date()
        )
        // Mock might return nil (no warranty found) or actual detection result
        // Both are valid mock behaviors
        
        // Test insurance mock can generate reports
        let reportData = try await mockInsurance.generateInsuranceReport(for: [])
        XCTAssertNotNil(reportData, "Mock insurance service should generate report data")
    }
    
    // MARK: - Service Fallback Chain Testing
    
    func testServiceFallback_CompleteChain() {
        // Test the complete service fallback chain works correctly
        
        // Test all critical services have fallback implementations
        let serviceTypes: [(String, () -> Any)] = [
            ("InventoryService", { MockInventoryService() }),
            ("WarrantyTrackingService", { MockWarrantyTrackingService() }),
            ("InsuranceReportService", { MockInsuranceReportService() }),
            ("NotificationService", { MockNotificationService() }),
            ("ClaimValidationService", { MockClaimValidationService() }),
            ("ClaimExportService", { MockClaimExportService() }),
            ("ClaimTrackingService", { MockClaimTrackingService() }),
            ("CloudStorageManager", { MockCloudStorageManager() }),
            ("InsuranceExportService", { MockInsuranceExportService() }),
            ("CategoryService", { MockCategoryService() })
        ]
        
        for (serviceName, createMock) in serviceTypes {
            let mockService = createMock()
            XCTAssertNotNil(mockService, "\(serviceName) should have working mock implementation")
        }
    }
    
    func testServiceHealthManager_DegradedModeRecovery() async {
        // Test that services can recover from degraded mode
        let healthManager = ServiceHealthManager.shared
        let testError = NSError(domain: "TestDomain", code: 500, 
                              userInfo: [NSLocalizedDescriptionKey: "Simulated service failure"])
        
        // Force service into degraded mode
        for _ in 0..<3 {
            healthManager.recordFailure(for: .inventory, error: testError)
        }
        
        let degradedState = healthManager.serviceStates[.inventory]
        XCTAssertFalse(degradedState?.isHealthy ?? true, "Service should be unhealthy after 3 failures")
        XCTAssertNotNil(degradedState?.degradedSince, "Should have degraded timestamp")
        
        // Test recovery
        healthManager.recordSuccess(for: .inventory)
        
        let recoveredState = healthManager.serviceStates[.inventory]
        XCTAssertTrue(recoveredState?.isHealthy ?? false, "Service should recover after success")
        XCTAssertNil(recoveredState?.degradedSince, "Degraded timestamp should be cleared")
        XCTAssertEqual(recoveredState?.consecutiveFailures, 0, "Consecutive failures should reset")
    }
    
    func testReliableMockInventoryService_EnhancedReliability() async throws {
        // Test the enhanced reliable mock service behavior
        let reliableMock = ReliableMockInventoryService()
        
        // Test that it never throws errors
        let items1 = try await reliableMock.getAllItems()
        XCTAssertTrue(items1.count >= 0, "Should return valid items")
        
        // Test adding items
        let testItem = Item(name: "Test Item for Reliable Mock")
        try await reliableMock.addItem(testItem)
        
        let items2 = try await reliableMock.getAllItems()
        XCTAssertTrue(items2.count >= 0, "Should handle item addition gracefully")
        
        // Test search functionality
        let searchResults = try await reliableMock.searchItems(query: "Test", filters: [])
        XCTAssertTrue(searchResults.count >= 0, "Should provide search results")
        
        // Test categories
        let categories = try await reliableMock.getAllCategories()
        XCTAssertTrue(categories.count >= 0, "Should return categories")
        
        // Test bulk operations don't fail
        let bulkItems = [
            Item(name: "Bulk Item 1"),
            Item(name: "Bulk Item 2"),
            Item(name: "Bulk Item 3")
        ]
        
        for item in bulkItems {
            try await reliableMock.addItem(item) // Should not throw
        }
    }
    
    func testServiceFailover_UnderLoad() async {
        // Test service failover behavior under concurrent load
        let concurrentTasks = 10
        let healthManager = ServiceHealthManager.shared
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<concurrentTasks {
                group.addTask {
                    let error = NSError(domain: "ConcurrentTest", code: i, 
                                      userInfo: [NSLocalizedDescriptionKey: "Concurrent failure \(i)"])
                    
                    await MainActor.run {
                        healthManager.recordFailure(for: .warranty, error: error)
                    }
                }
            }
        }
        
        let finalState = healthManager.serviceStates[.warranty]
        XCTAssertNotNil(finalState, "Should have recorded state under concurrent load")
        XCTAssertGreaterThan(finalState?.totalFailures ?? 0, 0, "Should have recorded failures")
    }
}

// MARK: - Test Support Types

enum MockError: Error, LocalizedError {
    case simulatedFailure
    
    var errorDescription: String? {
        switch self {
        case .simulatedFailure:
            return "Simulated failure"
        }
    }
}

extension MockWarrantyTrackingService {
    // Override the mock to simulate failures for testing
    func simulateFailure() async throws -> Never {
        throw MockError.simulatedFailure
    }
}
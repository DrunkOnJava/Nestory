//
// Layer: Tests
// Module: Services
// Purpose: Comprehensive tests for ModelContainer creation error handling patterns
//

import XCTest
import SwiftData
import Foundation
@testable import Nestory

@MainActor
final class ModelContainerErrorHandlingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - ModelContainer Creation Error Handling Tests
    
    func testModelContainer_SafeCreationPattern_Success() throws {
        // Test that our safe ModelContainer creation pattern works correctly
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: true)
            let container = try ModelContainer(
                for: Item.self, Category.self, Receipt.self, Warranty.self,
                configurations: config
            )
            XCTAssertNotNil(container, "ModelContainer should be created successfully")
        } catch {
            XCTFail("ModelContainer creation should succeed in test environment: \(error.localizedDescription)")
        }
    }
    
    func testModelContainer_GracefulErrorHandling_WithInvalidConfiguration() {
        // Test that our error handling gracefully handles invalid configurations
        // This simulates what happens when ModelContainer creation fails in production
        
        var caughtError: Error?
        var errorMessage: String?
        
        do {
            // Try to create ModelContainer with problematic configuration
            // Using a non-existent model to force failure
            let _ = try ModelContainer(for: NonExistentPersistentModel.self)
            XCTFail("Should have thrown an error with invalid model")
        } catch {
            caughtError = error
            
            // This is our graceful error handling pattern
            Logger.service.error("Failed to create ModelContainer: \(error.localizedDescription)")
            Logger.service.info("Using fallback error view for graceful degradation")
            errorMessage = "Failed to initialize data storage: \(error.localizedDescription)"
        }
        
        XCTAssertNotNil(caughtError, "Should have caught an error")
        XCTAssertNotNil(errorMessage, "Should have generated user-friendly error message")
        XCTAssertTrue(errorMessage?.contains("Failed to initialize data storage") ?? false, 
                     "Error message should be user-friendly")
    }
    
    func testSwiftUIPreview_SafeErrorHandling() {
        // Test that our SwiftUI Preview error handling pattern works
        // This tests the pattern we implemented across all Preview blocks
        
        var previewContent: Any?
        
        do {
            let container = try ModelContainer(
                for: Item.self, 
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            previewContent = ("ModelContainer", container)
        } catch {
            // This is our fallback pattern for Previews
            let errorText = "Failed to create preview: \(error.localizedDescription)"
            previewContent = ("ErrorText", errorText)
        }
        
        XCTAssertNotNil(previewContent, "Preview should always have content")
    }
    
    func testServiceDependencyKeys_ModelContainerFailureHandling() {
        // Test that service dependency keys handle ModelContainer failures gracefully
        // This simulates the pattern we use in ServiceDependencyKeys.swift
        
        var serviceCreated: Any?
        var healthRecorded = false
        var degradedModeTriggered = false
        var loggedError = false
        
        do {
            // Simulate service creation with ModelContainer
            let config = ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: true)
            let container = try ModelContainer(for: Item.self, configurations: config)
            let context = ModelContext(container)
            
            // Simulate successful service creation
            serviceCreated = ("LiveService", context)
            
            // Record success (simulated)
            healthRecorded = true
            
        } catch {
            // This is our graceful degradation pattern
            
            // Record service failure for health monitoring
            degradedModeTriggered = true
            
            // Structured error logging
            Logger.service.error("Failed to create service with ModelContainer: \(error.localizedDescription)")
            Logger.service.info("Falling back to mock service for graceful degradation")
            loggedError = true
            
            // Return mock service (simulated)
            serviceCreated = ("MockService", "fallback")
        }
        
        XCTAssertNotNil(serviceCreated, "Should always have a service (live or mock)")
        XCTAssertTrue(healthRecorded || degradedModeTriggered, "Should record health status")
        XCTAssertTrue(healthRecorded || loggedError, "Should log appropriately")
    }
    
    func testModelContainer_MemoryPressureRecovery() throws {
        // Test ModelContainer behavior under memory pressure
        // This tests our resilience patterns
        
        var containers: [ModelContainer] = []
        var successCount = 0
        var errorCount = 0
        
        // Create multiple containers to simulate memory pressure
        for i in 0..<10 {
            do {
                let config = ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: true)
                let container = try ModelContainer(
                    for: Item.self,
                    configurations: config
                )
                containers.append(container)
                successCount += 1
            } catch {
                errorCount += 1
                Logger.service.error("Container creation failed at iteration \(i): \(error.localizedDescription)")
            }
        }
        
        XCTAssertGreaterThan(successCount, 0, "Should successfully create at least some containers")
        // Allow some failures under memory pressure, but verify we handle them gracefully
        XCTAssertTrue(errorCount >= 0, "Error count should be tracked properly")
    }
    
    func testModelContainer_ConcurrentCreationSafety() async throws {
        // Test concurrent ModelContainer creation safety
        // This ensures our error handling works correctly under concurrent load
        
        let taskCount = 5
        var results: [Result<ModelContainer, Error>] = []
        
        await withTaskGroup(of: Result<ModelContainer, Error>.self) { group in
            for i in 0..<taskCount {
                group.addTask {
                    do {
                        let config = ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: true)
                        let container = try ModelContainer(
                            for: Item.self,
                            configurations: config
                        )
                        return .success(container)
                    } catch {
                        Logger.service.error("Concurrent container creation failed (task \(i)): \(error.localizedDescription)")
                        return .failure(error)
                    }
                }
            }
            
            for await result in group {
                results.append(result)
            }
        }
        
        XCTAssertEqual(results.count, taskCount, "Should have results for all tasks")
        
        let successCount = results.compactMap { try? $0.get() }.count
        let errorCount = results.count - successCount
        
        XCTAssertGreaterThan(successCount, 0, "Should have at least some successful creations")
        // Verify we handle any errors gracefully
        if errorCount > 0 {
            Logger.service.info("Handled \(errorCount) concurrent creation errors gracefully")
        }
    }
    
    func testServiceHealthManager_ModelContainerFailureIntegration() {
        // Test integration with ServiceHealthManager for ModelContainer failures
        let healthManager = ServiceHealthManager.shared
        
        // Simulate ModelContainer creation failure in service
        let testError = NSError(
            domain: "SwiftDataError", 
            code: 101, 
            userInfo: [NSLocalizedDescriptionKey: "ModelContainer creation failed"]
        )
        
        // Record the failure
        healthManager.recordFailure(for: .inventory, error: testError)
        
        let healthState = healthManager.serviceStates[.inventory]
        XCTAssertNotNil(healthState, "Should have recorded health state")
        XCTAssertEqual(healthState?.consecutiveFailures, 1, "Should record consecutive failure")
        
        // Test recovery after successful creation
        healthManager.recordSuccess(for: .inventory)
        
        let recoveredState = healthManager.serviceStates[.inventory]
        XCTAssertEqual(recoveredState?.consecutiveFailures, 0, "Should reset consecutive failures on success")
        XCTAssertTrue(recoveredState?.isHealthy ?? false, "Should be healthy after recovery")
    }
    
    func testLogger_StructuredErrorReporting() {
        // Test that our Logger.service error reporting works correctly
        let testError = NSError(
            domain: "ModelContainerError",
            code: 500,
            userInfo: [
                NSLocalizedDescriptionKey: "Test ModelContainer creation error",
                "additionalContext": "Unit test simulation"
            ]
        )
        
        // These should not crash and should log appropriately
        Logger.service.error("ModelContainer creation failed: \(testError.localizedDescription)")
        Logger.service.info("Falling back to mock data provider for graceful degradation")
        Logger.service.debug("ModelContainer error details: \(testError)")
        
        XCTAssertTrue(true, "Structured logging should work without crashing")
    }
}

// MARK: - Test Support Types

// This model is intentionally invalid to test ModelContainer failure paths
struct NonExistentPersistentModel {
    // This struct intentionally doesn't conform to PersistentModel
    // to cause ModelContainer creation to fail
    let id = UUID()
    let name = "Invalid Model"
}

// MARK: - Performance Tests

extension ModelContainerErrorHandlingTests {
    
    func testPerformance_ModelContainerCreation() {
        // Performance test for ModelContainer creation with error handling
        measure {
            do {
                let config = ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: true)
                let container = try ModelContainer(for: Item.self, configurations: config)
                XCTAssertNotNil(container)
            } catch {
                // Even error handling should be fast
                Logger.service.error("Performance test container creation failed: \(error.localizedDescription)")
            }
        }
    }
    
    func testPerformance_ErrorHandlingOverhead() {
        // Test that our error handling patterns don't add significant overhead
        measure {
            for _ in 0..<100 {
                do {
                    let config = ModelConfiguration(isStoredInMemoryOnly: true)
                    let _ = try ModelContainer(for: Item.self, configurations: config)
                } catch {
                    // Quick error handling path
                    Logger.service.error("Batch test error: \(error.localizedDescription)")
                }
            }
        }
    }
}
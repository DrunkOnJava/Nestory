//
// Layer: Tests
// Module: TestFactories
// Purpose: Specialized factory for mock service behaviors and network simulation
//

import Foundation
@testable import Nestory

/// Specialized factory for mock service testing and network simulation
@MainActor
struct MockServiceTestFactory {
    
    // MARK: - Network Simulation
    
    /// Generate realistic delay for network simulation (50-500ms)
    static func simulatedNetworkDelay() async {
        let delayMs = Int.random(in: 50...500)
        try? await Task.sleep(nanoseconds: UInt64(delayMs * 1_000_000))
    }
    
    /// Generate fast network delay for rapid testing (10-50ms)
    static func fastNetworkDelay() async {
        let delayMs = Int.random(in: 10...50)
        try? await Task.sleep(nanoseconds: UInt64(delayMs * 1_000_000))
    }
    
    /// Generate slow network delay for timeout testing (1-3 seconds)
    static func slowNetworkDelay() async {
        let delayMs = Int.random(in: 1000...3000)
        try? await Task.sleep(nanoseconds: UInt64(delayMs * 1_000_000))
    }
    
    // MARK: - Failure Simulation
    
    /// Generate realistic failure scenarios for error testing
    static func shouldSimulateFailure(failureRate: Double = 0.1) -> Bool {
        return Double.random(in: 0...1) < failureRate
    }
    
    /// Generate specific failure type for comprehensive error testing
    static func simulatedFailureType() -> MockFailureType {
        return MockFailureType.allCases.randomElement() ?? .networkTimeout
    }
    
    /// Generate failure with specific probability for different failure types
    static func shouldSimulateSpecificFailure(_ failureType: MockFailureType) -> Bool {
        switch failureType {
        case .networkTimeout:
            return shouldSimulateFailure(failureRate: 0.05) // 5% chance
        case .serverError:
            return shouldSimulateFailure(failureRate: 0.03) // 3% chance
        case .authenticationFailure:
            return shouldSimulateFailure(failureRate: 0.02) // 2% chance
        case .dataCorruption:
            return shouldSimulateFailure(failureRate: 0.01) // 1% chance
        case .diskFull:
            return shouldSimulateFailure(failureRate: 0.005) // 0.5% chance
        }
    }
    
    // MARK: - Service Health Simulation
    
    /// Simulate service health states
    static func simulatedServiceHealth() -> ServiceHealthState {
        let randomValue = Double.random(in: 0...1)
        switch randomValue {
        case 0...0.8: return .healthy
        case 0.8...0.95: return .degraded
        default: return .unhealthy
        }
    }
    
    /// Simulate network conditions for comprehensive testing
    static func simulatedNetworkCondition() -> NetworkCondition {
        return NetworkCondition.allCases.randomElement() ?? .good
    }
    
    // MARK: - Data Generation for Mocks
    
    /// Generate mock API response data
    static func createMockAPIResponse<T>(data: T, delay: Bool = true) async -> Result<T, Error> {
        if delay {
            await simulatedNetworkDelay()
        }
        
        if shouldSimulateFailure() {
            return .failure(MockError.networkFailure)
        }
        
        return .success(data)
    }
    
    /// Generate mock database operation result
    static func createMockDatabaseResult<T>(data: T) async -> Result<T, Error> {
        await fastNetworkDelay() // Database operations are typically faster
        
        if shouldSimulateFailure(failureRate: 0.02) { // Lower failure rate for local operations
            return .failure(MockError.databaseError)
        }
        
        return .success(data)
    }
    
    // MARK: - Batch Operation Simulation
    
    /// Simulate batch operation with partial failures
    static func simulateBatchOperation<T>(
        items: [T],
        successRate: Double = 0.95
    ) async -> [Result<T, Error>] {
        var results: [Result<T, Error>] = []
        
        for item in items {
            await fastNetworkDelay() // Small delay between operations
            
            if shouldSimulateFailure(failureRate: 1.0 - successRate) {
                results.append(.failure(MockError.batchOperationFailure))
            } else {
                results.append(.success(item))
            }
        }
        
        return results
    }
    
    // MARK: - Memory and Performance Simulation
    
    /// Simulate memory pressure scenarios
    static func simulateMemoryPressure() -> Bool {
        return shouldSimulateFailure(failureRate: 0.01) // 1% chance
    }
    
    /// Simulate CPU intensive operations
    static func simulateCPUIntensiveOperation() async {
        await slowNetworkDelay() // Simulate processing time
    }
}

// MARK: - Supporting Types

/// Types of failures that can be simulated
enum MockFailureType: String, CaseIterable {
    case networkTimeout = "network_timeout"
    case serverError = "server_error"
    case authenticationFailure = "auth_failure"
    case dataCorruption = "data_corruption"
    case diskFull = "disk_full"
    
    var displayName: String {
        switch self {
        case .networkTimeout: return "Network Timeout"
        case .serverError: return "Server Error"
        case .authenticationFailure: return "Authentication Failure"
        case .dataCorruption: return "Data Corruption"
        case .diskFull: return "Disk Full"
        }
    }
}

/// Service health states for testing
enum ServiceHealthState: String, CaseIterable {
    case healthy = "healthy"
    case degraded = "degraded"
    case unhealthy = "unhealthy"
    
    var displayName: String {
        switch self {
        case .healthy: return "Healthy"
        case .degraded: return "Degraded"
        case .unhealthy: return "Unhealthy"
        }
    }
}

/// Network conditions for simulation
enum NetworkCondition: String, CaseIterable {
    case excellent = "excellent"
    case good = "good"
    case poor = "poor"
    case offline = "offline"
    
    var displayName: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .poor: return "Poor"
        case .offline: return "Offline"
        }
    }
    
    var delayMultiplier: Double {
        switch self {
        case .excellent: return 0.5
        case .good: return 1.0
        case .poor: return 3.0
        case .offline: return 10.0
        }
    }
}

/// Mock error types
enum MockError: Error, LocalizedError {
    case networkFailure
    case databaseError
    case batchOperationFailure
    case memoryPressure
    case cpuOverload
    
    var errorDescription: String? {
        switch self {
        case .networkFailure: return "Network operation failed"
        case .databaseError: return "Database operation failed"
        case .batchOperationFailure: return "Batch operation failed"
        case .memoryPressure: return "Memory pressure detected"
        case .cpuOverload: return "CPU overload detected"
        }
    }
}
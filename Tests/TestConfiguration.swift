//
// TestConfiguration.swift
// Nestory Tests
//
// Global test configuration for optimized testing
//

import Foundation

enum TestConfiguration {
    // Test execution settings
    static let fastTestMode = ProcessInfo.processInfo.environment["FAST_TEST_MODE"] == "1"
    static let skipSlowTests = ProcessInfo.processInfo.environment["SKIP_SLOW_TESTS"] == "1"
    static let parallelTesting = ProcessInfo.processInfo.environment["PARALLEL_TESTING"] == "1"

    // Mock settings
    static let useMockServices = ProcessInfo.processInfo.environment["USE_MOCK_SERVICES"] == "1"
    static let mockNetworkDelay = Double(ProcessInfo.processInfo.environment["MOCK_NETWORK_DELAY"] ?? "0") ?? 0

    // Performance thresholds
    static let maxTestDuration: TimeInterval = 5.0
    static let maxUITestDuration: TimeInterval = 30.0

    // Test data settings
    static let useTestData = true
    static let cleanupAfterTests = true
}

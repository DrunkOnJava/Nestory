//
// Layer: Infrastructure
// Module: Performance
// Purpose: Advanced performance profiling with OSSignposter and automatic optimization recommendations
//

import Foundation
import os.log
import os.signpost

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with MetricKit - Use MXMetricKit for system-level performance metrics collection and crash diagnostics

/// Advanced performance profiling with automatic bottleneck detection
public actor PerformanceProfiler {
    public static let shared = PerformanceProfiler()

    private let signposter = OSSignposter()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "PerformanceProfiler")
    private let performanceMonitor = PerformanceMonitor.shared

    // Performance tracking state
    private var activeIntervals: [String: OSSignpostIntervalState] = [:]
    private var operationMetrics: [String: OperationMetrics] = [:]
    private var performanceBaselines: [String: PerformanceBaseline] = [:]

    // Performance thresholds (in milliseconds)
    private let criticalThresholds: [String: Double] = [
        "analytics_currency_conversion": 100,
        "analytics_total_value_calculation": 200,
        "analytics_depreciation_calculation": 150,
        "inventory_search": 200,
        "inventory_fetch": 100,
        "inventory_bulk_save": 500,
        "notification_batch_scheduling": 300,
        "cloudbackup_sync": 2000,
        "import_csv_processing": 1000,
        "ui_list_rendering": 16.67, // 60 FPS target
        "cache_lookup": 10,
        "database_query": 250,
    ]

    private init() {
        loadPerformanceBaselines()
    }

    // MARK: - Performance Measurement

    /// Start measuring a performance operation
    public func beginInterval(_ operationName: String, metadata: [String: Any] = [:]) -> String {
        let intervalId = UUID().uuidString
        let signpostId = signposter.makeSignpostID()

        let state = signposter.beginInterval(operationName, id: signpostId)
        activeIntervals[intervalId] = state

        // Track operation start
        if operationMetrics[operationName] == nil {
            operationMetrics[operationName] = OperationMetrics(name: operationName)
        }
        operationMetrics[operationName]?.recordStart(metadata: metadata)

        logger.debug("Started performance interval: \(operationName) [\(intervalId)]")
        return intervalId
    }

    /// End measuring a performance operation
    public func endInterval(_ intervalId: String, operationName: String, success: Bool = true, metadata: [String: Any] = [:]) {
        guard let state = activeIntervals.removeValue(forKey: intervalId) else {
            logger.warning("Attempted to end non-existent interval: \(intervalId)")
            return
        }

        signposter.endInterval(operationName, state)

        // Record operation completion
        let duration = Date().timeIntervalSince(state.signpostID.value as? Date ?? Date())
        operationMetrics[operationName]?.recordCompletion(duration: duration, success: success, metadata: metadata)

        // Check performance against baseline and thresholds
        checkPerformance(operationName: operationName, duration: duration)

        logger.debug("Ended performance interval: \(operationName) [\(intervalId)] - Duration: \(duration * 1000)ms")
    }

    /// Measure an async operation automatically
    public func measure<T>(_ operationName: String, metadata: [String: Any] = [:], operation: () async throws -> T) async rethrows -> T {
        let intervalId = beginInterval(operationName, metadata: metadata)

        do {
            let result = try await operation()
            endInterval(intervalId, operationName: operationName, success: true)
            return result
        } catch {
            endInterval(intervalId, operationName: operationName, success: false, metadata: ["error": error.localizedDescription])
            throw error
        }
    }

    /// Measure a synchronous operation
    public func measureSync<T>(_ operationName: String, metadata: [String: Any] = [:], operation: () throws -> T) rethrows -> T {
        let intervalId = beginInterval(operationName, metadata: metadata)

        do {
            let result = try operation()
            endInterval(intervalId, operationName: operationName, success: true)
            return result
        } catch {
            endInterval(intervalId, operationName: operationName, success: false, metadata: ["error": error.localizedDescription])
            throw error
        }
    }

    // MARK: - Performance Analysis

    /// Get performance metrics for an operation
    public func getMetrics(for operationName: String) -> OperationMetrics? {
        operationMetrics[operationName]
    }

    /// Get all performance metrics
    public func getAllMetrics() -> [String: OperationMetrics] {
        operationMetrics
    }

    /// Generate performance report
    public func generatePerformanceReport() -> PerformanceReport {
        let report = PerformanceReport(
            timestamp: Date(),
            operations: operationMetrics.values.map(\.self),
            baselines: performanceBaselines,
            recommendations: generateRecommendations(),
        )

        logger.info("Generated performance report with \(operationMetrics.count) operations")
        return report
    }

    /// Set performance baseline for an operation
    public func setBaseline(operationName: String, targetDuration: TimeInterval) {
        performanceBaselines[operationName] = PerformanceBaseline(
            operationName: operationName,
            targetDuration: targetDuration,
            createdAt: Date(),
        )
        savePerformanceBaselines()
        logger.info("Set performance baseline for \(operationName): \(targetDuration * 1000)ms")
    }

    /// Check if operation meets performance baseline
    public func meetsBaseline(operationName: String, duration: TimeInterval) -> Bool {
        guard let baseline = performanceBaselines[operationName] else { return true }
        return duration <= baseline.targetDuration
    }

    // MARK: - Performance Optimization Recommendations

    private func generateRecommendations() -> [PerformanceRecommendation] {
        var recommendations: [PerformanceRecommendation] = []

        for (operationName, metrics) in operationMetrics {
            // Check against critical thresholds
            if let threshold = criticalThresholds[operationName] {
                let avgDuration = metrics.averageDuration * 1000 // Convert to ms
                if avgDuration > threshold {
                    let severity: RecommendationSeverity = avgDuration > threshold * 2 ? .critical : .high
                    recommendations.append(PerformanceRecommendation(
                        operationName: operationName,
                        issue: "Operation exceeds performance threshold",
                        currentValue: avgDuration,
                        targetValue: threshold,
                        severity: severity,
                        suggestions: getOptimizationSuggestions(for: operationName),
                    ))
                }
            }

            // Check success rate
            let successRate = metrics.successRate * 100
            if successRate < 95.0 {
                recommendations.append(PerformanceRecommendation(
                    operationName: operationName,
                    issue: "Low success rate detected",
                    currentValue: successRate,
                    targetValue: 95.0,
                    severity: successRate < 80 ? .critical : .medium,
                    suggestions: getReliabilitySuggestions(for: operationName),
                ))
            }

            // Check operation frequency
            if metrics.executionCount > 1000, metrics.averageDuration > 0.05 { // 50ms
                recommendations.append(PerformanceRecommendation(
                    operationName: operationName,
                    issue: "Frequent slow operation detected",
                    currentValue: metrics.averageDuration * 1000,
                    targetValue: 25.0,
                    severity: .medium,
                    suggestions: getCachingSuggestions(for: operationName),
                ))
            }
        }

        return recommendations.sorted { $0.severity.rawValue > $1.severity.rawValue }
    }

    private func getOptimizationSuggestions(for operationName: String) -> [String] {
        switch operationName {
        case "analytics_currency_conversion":
            [
                "Implement currency conversion result caching",
                "Batch currency conversions to reduce API calls",
                "Use offline exchange rates as fallback",
            ]
        case "analytics_total_value_calculation":
            [
                "Cache calculated totals with item version tracking",
                "Implement incremental updates instead of full recalculation",
                "Pre-calculate common aggregations",
            ]
        case "inventory_search":
            [
                "Add database indexes for search fields",
                "Implement search result caching",
                "Use full-text search optimization",
            ]
        case "notification_batch_scheduling":
            [
                "Process notifications in smaller batches",
                "Implement background queue processing",
                "Cache notification templates",
            ]
        case "cloudbackup_sync":
            [
                "Implement incremental sync",
                "Compress data before upload",
                "Use parallel upload streams",
            ]
        default:
            [
                "Review algorithm complexity",
                "Implement result caching",
                "Optimize data access patterns",
            ]
        }
    }

    private func getReliabilitySuggestions(for _: String) -> [String] {
        [
            "Implement retry logic with exponential backoff",
            "Add circuit breaker pattern",
            "Improve error handling and recovery",
            "Add operation timeout guards",
        ]
    }

    private func getCachingSuggestions(for _: String) -> [String] {
        [
            "Implement result caching with appropriate TTL",
            "Add cache warming for frequently accessed data",
            "Use cache hierarchies (memory + disk)",
            "Implement cache invalidation strategies",
        ]
    }

    // MARK: - Private Methods

    private func checkPerformance(operationName: String, duration: TimeInterval) {
        let durationMs = duration * 1000

        // Check critical thresholds
        if let threshold = criticalThresholds[operationName], durationMs > threshold {
            let severity: String = durationMs > threshold * 2 ? "CRITICAL" : "WARNING"
            logger.warning("[\(severity)] Performance issue: \(operationName) took \(durationMs)ms (threshold: \(threshold)ms)")

            // Record performance violation
            Task {
                await performanceMonitor.recordMetric(
                    "performance_violation",
                    value: durationMs,
                    metadata: [
                        "operation": operationName,
                        "threshold": threshold,
                        "severity": severity,
                    ],
                )
            }
        }

        // Check baseline compliance
        if !meetsBaseline(operationName: operationName, duration: duration) {
            logger.info("Performance baseline exceeded for \(operationName): \(durationMs)ms")
        }
    }

    private func loadPerformanceBaselines() {
        // Load from UserDefaults or file system
        // Implementation would load saved baselines
        logger.debug("Loaded performance baselines")
    }

    private func savePerformanceBaselines() {
        // Save to UserDefaults or file system
        // Implementation would persist baselines
        logger.debug("Saved performance baselines")
    }
}

// MARK: - Supporting Types

/// Tracks metrics for a specific operation
public class OperationMetrics {
    public let name: String
    public private(set) var executionCount = 0
    public private(set) var successCount = 0
    public private(set) var totalDuration: TimeInterval = 0
    public private(set) var minDuration: TimeInterval = .infinity
    public private(set) var maxDuration: TimeInterval = 0
    public private(set) var lastExecuted: Date?

    public var averageDuration: TimeInterval {
        guard executionCount > 0 else { return 0 }
        return totalDuration / Double(executionCount)
    }

    public var successRate: Double {
        guard executionCount > 0 else { return 0 }
        return Double(successCount) / Double(executionCount)
    }

    init(name: String) {
        self.name = name
    }

    func recordStart(metadata _: [String: Any]) {
        lastExecuted = Date()
    }

    func recordCompletion(duration: TimeInterval, success: Bool, metadata _: [String: Any]) {
        executionCount += 1
        totalDuration += duration
        minDuration = min(minDuration, duration)
        maxDuration = max(maxDuration, duration)

        if success {
            successCount += 1
        }
    }
}

/// Performance baseline for an operation
public struct PerformanceBaseline {
    public let operationName: String
    public let targetDuration: TimeInterval
    public let createdAt: Date
}

/// Performance optimization recommendation
public struct PerformanceRecommendation {
    public let operationName: String
    public let issue: String
    public let currentValue: Double
    public let targetValue: Double
    public let severity: RecommendationSeverity
    public let suggestions: [String]
}

public enum RecommendationSeverity: Int, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
    case critical = 4

    public var description: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        case .critical: "Critical"
        }
    }
}

/// Comprehensive performance report
public struct PerformanceReport {
    public let timestamp: Date
    public let operations: [OperationMetrics]
    public let baselines: [String: PerformanceBaseline]
    public let recommendations: [PerformanceRecommendation]

    public var summary: String {
        let criticalIssues = recommendations.count(where: { $0.severity == .critical })
        let highIssues = recommendations.count(where: { $0.severity == .high })
        let totalOperations = operations.count

        return "Performance Report: \(totalOperations) operations analyzed, \(criticalIssues) critical issues, \(highIssues) high-priority optimizations available"
    }
}

// MARK: - Convenience Extensions

extension PerformanceProfiler {
    /// Quick method for measuring common operations
    public func measureAnalytics<T>(_ operation: String, _ block: () async throws -> T) async rethrows -> T {
        try await measure("analytics_\(operation)", operation: block)
    }

    public func measureInventory<T>(_ operation: String, _ block: () async throws -> T) async rethrows -> T {
        try await measure("inventory_\(operation)", operation: block)
    }

    public func measureNotification<T>(_ operation: String, _ block: () async throws -> T) async rethrows -> T {
        try await measure("notification_\(operation)", operation: block)
    }

    public func measureCloudBackup<T>(_ operation: String, _ block: () async throws -> T) async rethrows -> T {
        try await measure("cloudbackup_\(operation)", operation: block)
    }

    public func measureUI<T>(_ operation: String, _ block: () throws -> T) rethrows -> T {
        try measureSync("ui_\(operation)", operation: block)
    }
}

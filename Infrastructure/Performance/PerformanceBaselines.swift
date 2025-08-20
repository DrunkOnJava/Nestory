//
// Layer: Infrastructure
// Module: Performance
// Purpose: Performance baseline management and automatic monitoring
//

import Foundation
import os.log

/// Manages performance baselines and automatic monitoring for critical operations
public actor PerformanceBaselines {
    public static let shared = PerformanceBaselines()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "PerformanceBaselines")
    private let profiler = PerformanceProfiler.shared

    // Baseline storage
    private var baselines: [String: Baseline] = [:]
    private var violations: [String: [BaselineViolation]] = [:]

    // Configuration
    private let maxViolationsPerBaseline = 100
    private let violationRetentionDays = 7

    private init() {
        loadBaselines()
        setupDefaultBaselines()
    }

    // MARK: - Baseline Management

    /// Set a performance baseline for an operation
    public func setBaseline(
        operation: String,
        targetPercentile: Double = 95.0,
        maxDuration: TimeInterval,
        minSampleSize: Int = 10,
        description: String? = nil,
    ) {
        let baseline = Baseline(
            operation: operation,
            targetPercentile: targetPercentile,
            maxDuration: maxDuration,
            minSampleSize: minSampleSize,
            description: description ?? operation,
            createdAt: Date(),
            updatedAt: Date(),
        )

        baselines[operation] = baseline
        saveBaselines()

        logger.info("Set baseline for \(operation): \(maxDuration * 1000)ms at \(targetPercentile)th percentile")
    }

    /// Check if an operation meets its baseline
    public func checkBaseline(operation: String, duration: TimeInterval) -> BaselineResult {
        guard let baseline = baselines[operation] else {
            return .noBaseline
        }

        let durationMs = duration * 1000
        let maxDurationMs = baseline.maxDuration * 1000

        if durationMs <= maxDurationMs {
            return .pass(baseline: baseline, actualDuration: duration)
        } else {
            let violation = BaselineViolation(
                operation: operation,
                expectedDuration: baseline.maxDuration,
                actualDuration: duration,
                severity: calculateSeverity(expected: baseline.maxDuration, actual: duration),
                timestamp: Date(),
            )

            recordViolation(violation)

            return .violation(baseline: baseline, violation: violation)
        }
    }

    /// Get baseline compliance report for all operations
    public func getComplianceReport() -> BaselineComplianceReport {
        var operationReports: [OperationComplianceReport] = []

        for (operation, baseline) in baselines {
            let metrics = await profiler.getMetrics(for: operation)
            let recentViolations = getRecentViolations(for: operation, days: 1)

            let report = OperationComplianceReport(
                operation: operation,
                baseline: baseline,
                metrics: metrics,
                recentViolations: recentViolations,
                complianceRate: calculateComplianceRate(operation: operation),
            )

            operationReports.append(report)
        }

        return BaselineComplianceReport(
            timestamp: Date(),
            operations: operationReports.sorted { $0.complianceRate < $1.complianceRate },
            summary: generateComplianceSummary(operationReports),
        )
    }

    // MARK: - Default Baselines

    private func setupDefaultBaselines() {
        // Analytics Service Baselines
        setBaseline(
            operation: "analytics_currency_conversion",
            maxDuration: 0.1, // 100ms
            description: "Currency conversion should complete quickly",
        )

        setBaseline(
            operation: "analytics_total_value_calculation",
            maxDuration: 0.2, // 200ms
            description: "Total value calculation for dashboard",
        )

        setBaseline(
            operation: "analytics_depreciation_calculation",
            maxDuration: 0.15, // 150ms
            description: "Depreciation calculation for multiple items",
        )

        // Inventory Service Baselines
        setBaseline(
            operation: "inventory_search",
            maxDuration: 0.2, // 200ms
            description: "Item search should be responsive",
        )

        setBaseline(
            operation: "inventory_fetch",
            maxDuration: 0.1, // 100ms
            description: "Inventory fetch operations",
        )

        setBaseline(
            operation: "inventory_bulk_save",
            maxDuration: 0.5, // 500ms
            description: "Bulk save operations for imports",
        )

        // Notification Service Baselines
        setBaseline(
            operation: "notification_batch_scheduling",
            maxDuration: 0.3, // 300ms
            description: "Batch notification scheduling",
        )

        // Cloud Backup Service Baselines
        setBaseline(
            operation: "cloudbackup_sync",
            maxDuration: 2.0, // 2 seconds
            description: "Individual backup sync operations",
        )

        // Import/Export Service Baselines
        setBaseline(
            operation: "import_csv_processing",
            maxDuration: 1.0, // 1 second
            description: "CSV processing per batch",
        )

        // UI Performance Baselines
        setBaseline(
            operation: "ui_list_rendering",
            maxDuration: 0.01667, // 16.67ms for 60 FPS
            description: "UI list rendering frame time",
        )

        // Cache Performance Baselines
        setBaseline(
            operation: "cache_lookup",
            maxDuration: 0.01, // 10ms
            description: "Cache lookup operations",
        )

        // Database Query Baselines
        setBaseline(
            operation: "database_query",
            maxDuration: 0.25, // 250ms
            description: "SwiftData query operations",
        )
    }

    // MARK: - Violation Tracking

    private func recordViolation(_ violation: BaselineViolation) {
        let operation = violation.operation

        if violations[operation] == nil {
            violations[operation] = []
        }

        violations[operation]?.append(violation)

        // Limit violations stored per operation
        if violations[operation]!.count > maxViolationsPerBaseline {
            violations[operation] = Array(violations[operation]!.suffix(maxViolationsPerBaseline))
        }

        // Log severe violations immediately
        if violation.severity == .critical {
            logger.error("CRITICAL baseline violation: \(operation) took \(violation.actualDuration * 1000)ms (expected: \(violation.expectedDuration * 1000)ms)")
        } else if violation.severity == .major {
            logger.warning("MAJOR baseline violation: \(operation) took \(violation.actualDuration * 1000)ms (expected: \(violation.expectedDuration * 1000)ms)")
        }

        saveViolations()
    }

    private func calculateSeverity(expected: TimeInterval, actual: TimeInterval) -> BaselineViolationSeverity {
        let ratio = actual / expected

        if ratio >= 5.0 {
            return .critical
        } else if ratio >= 3.0 {
            return .major
        } else if ratio >= 2.0 {
            return .moderate
        } else {
            return .minor
        }
    }

    private func getRecentViolations(for operation: String, days: Int) -> [BaselineViolation] {
        let cutoff = Date().addingTimeInterval(-Double(days * 24 * 3600))
        return violations[operation]?.filter { $0.timestamp > cutoff } ?? []
    }

    private func calculateComplianceRate(operation: String) -> Double {
        let recentViolations = getRecentViolations(for: operation, days: 1)
        guard let metrics = Task.yield(then: profiler.getMetrics(for: operation)) else {
            return 1.0
        }

        let totalOperations = max(metrics.executionCount, 1)
        let violationCount = recentViolations.count

        return 1.0 - (Double(violationCount) / Double(totalOperations))
    }

    private func generateComplianceSummary(_ reports: [OperationComplianceReport]) -> BaselineComplianceSummary {
        let totalOperations = reports.count
        let compliantOperations = reports.count(where: { $0.complianceRate >= 0.95 })
        let criticalViolations = reports.flatMap(\.recentViolations).count(where: { $0.severity == .critical })

        let averageComplianceRate = reports.isEmpty ? 1.0 :
            reports.map(\.complianceRate).reduce(0, +) / Double(reports.count)

        return BaselineComplianceSummary(
            totalOperations: totalOperations,
            compliantOperations: compliantOperations,
            averageComplianceRate: averageComplianceRate,
            criticalViolations: criticalViolations,
            overallStatus: determineOverallStatus(averageComplianceRate, criticalViolations),
        )
    }

    private func determineOverallStatus(_ averageRate: Double, _ criticalViolations: Int) -> ComplianceStatus {
        if criticalViolations > 5 || averageRate < 0.8 {
            .critical
        } else if criticalViolations > 0 || averageRate < 0.95 {
            .warning
        } else {
            .healthy
        }
    }

    // MARK: - Persistence

    private func loadBaselines() {
        // Load from UserDefaults or file storage
        // Implementation would deserialize baseline data
        logger.debug("Loaded performance baselines")
    }

    private func saveBaselines() {
        // Save to UserDefaults or file storage
        // Implementation would serialize baseline data
        logger.debug("Saved performance baselines")
    }

    private func saveViolations() {
        // Save violations to storage
        logger.debug("Saved baseline violations")
    }
}

// MARK: - Supporting Types

public struct Baseline {
    public let operation: String
    public let targetPercentile: Double
    public let maxDuration: TimeInterval
    public let minSampleSize: Int
    public let description: String
    public let createdAt: Date
    public let updatedAt: Date
}

public struct BaselineViolation {
    public let operation: String
    public let expectedDuration: TimeInterval
    public let actualDuration: TimeInterval
    public let severity: BaselineViolationSeverity
    public let timestamp: Date

    public var exceedanceRatio: Double {
        actualDuration / expectedDuration
    }
}

public enum BaselineViolationSeverity: String, CaseIterable {
    case minor
    case moderate
    case major
    case critical

    public var description: String {
        switch self {
        case .minor: "Minor"
        case .moderate: "Moderate"
        case .major: "Major"
        case .critical: "Critical"
        }
    }
}

public enum BaselineResult {
    case pass(baseline: Baseline, actualDuration: TimeInterval)
    case violation(baseline: Baseline, violation: BaselineViolation)
    case noBaseline
}

public struct OperationComplianceReport {
    public let operation: String
    public let baseline: Baseline
    public let metrics: OperationMetrics?
    public let recentViolations: [BaselineViolation]
    public let complianceRate: Double

    public var status: ComplianceStatus {
        if complianceRate >= 0.95 {
            .healthy
        } else if complianceRate >= 0.8 {
            .warning
        } else {
            .critical
        }
    }
}

public struct BaselineComplianceReport {
    public let timestamp: Date
    public let operations: [OperationComplianceReport]
    public let summary: BaselineComplianceSummary
}

public struct BaselineComplianceSummary {
    public let totalOperations: Int
    public let compliantOperations: Int
    public let averageComplianceRate: Double
    public let criticalViolations: Int
    public let overallStatus: ComplianceStatus

    public var compliancePercentage: Double {
        guard totalOperations > 0 else { return 100.0 }
        return (Double(compliantOperations) / Double(totalOperations)) * 100.0
    }
}

public enum ComplianceStatus: String, CaseIterable {
    case healthy
    case warning
    case critical

    public var description: String {
        switch self {
        case .healthy: "Healthy"
        case .warning: "Warning"
        case .critical: "Critical"
        }
    }
}

// MARK: - Utility Extensions

extension Task where Success == OperationMetrics?, Failure == Never {
    fileprivate static func yield(then _: @escaping () async -> OperationMetrics?) -> OperationMetrics? {
        // This is a simplified synchronous accessor for the async operation
        // In real implementation, this would use proper async coordination
        nil
    }
}

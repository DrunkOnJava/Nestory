// Layer: Infrastructure
// Module: Infrastructure/Monitoring
// Purpose: Performance monitoring and metrics collection

import Foundation
import os.log

/// Performance monitoring and metrics collection
public actor PerformanceMonitor {
    // MARK: - Properties

    private var metrics: [MetricKey: [MetricValue]] = [:]
    private var activeTransactions: [String: Transaction] = [:]
    private let logger = Logger(subsystem: "com.nestory.app", category: "Performance")
    private let maxMetricsPerKey = 1000

    // MARK: - Singleton

    public static let shared = PerformanceMonitor()

    private init() {}

    // MARK: - Transaction Tracking

    /// Start a performance transaction
    @discardableResult
    public func startTransaction(_ name: String, metadata: [String: Any]? = nil) -> String {
        let id = UUID().uuidString
        let transaction = Transaction(
            id: id,
            name: name,
            startTime: Date(),
            metadata: metadata ?? [:],
        )

        activeTransactions[id] = transaction

        logger.debug("Started transaction: \(name) [\(id)]")

        return id
    }

    /// End a performance transaction
    public func endTransaction(_ id: String, success: Bool = true) {
        guard let transaction = activeTransactions.removeValue(forKey: id) else {
            logger.warning("Attempted to end non-existent transaction: \(id)")
            return
        }

        let duration = Date().timeIntervalSince(transaction.startTime)

        // Record metric
        let metric = MetricValue(
            value: duration,
            timestamp: Date(),
            metadata: transaction.metadata.merging(["success": success]) { _, new in new },
        )

        recordMetric(for: MetricKey.transaction(transaction.name), value: metric)

        logger.debug("Ended transaction: \(transaction.name) [\(id)] - Duration: \(duration)s")

        // Check SLO compliance
        checkSLO(for: transaction.name, duration: duration)
    }

    /// Measure async operation
    public func measure<T: Sendable>(_ name: String, operation: () async throws -> T) async rethrows -> T {
        let id = startTransaction(name)

        do {
            let result = try await operation()
            endTransaction(id, success: true)
            return result
        } catch {
            endTransaction(id, success: false)
            throw error
        }
    }

    // MARK: - Metric Recording

    /// Record a custom metric
    public func recordMetric(_ name: String, value: Double, metadata: [String: Any]? = nil) {
        let key = MetricKey.custom(name)
        let metric = MetricValue(
            value: value,
            timestamp: Date(),
            metadata: metadata ?? [:],
        )

        recordMetric(for: key, value: metric)
    }

    /// Record memory usage
    public func recordMemoryUsage() {
        let info = ProcessInfo.processInfo
        let physicalMemory = Double(info.physicalMemory)
        let usedMemory = Double(getMemoryUsage())
        let percentage = (usedMemory / physicalMemory) * 100

        let metric = MetricValue(
            value: percentage,
            timestamp: Date(),
            metadata: [
                "used_bytes": usedMemory,
                "total_bytes": physicalMemory,
            ],
        )

        recordMetric(for: .memory, value: metric)

        if percentage > 80 {
            logger.warning("High memory usage: \(String(format: "%.1f", percentage))%")
        }
    }

    /// Record network latency
    public func recordNetworkLatency(_ latency: TimeInterval, endpoint: String) {
        let metric = MetricValue(
            value: latency,
            timestamp: Date(),
            metadata: ["endpoint": endpoint],
        )

        recordMetric(for: .networkLatency, value: metric)
    }

    /// Record database operation
    public func recordDatabaseOperation(_ operation: String, duration: TimeInterval, success: Bool) {
        let metric = MetricValue(
            value: duration,
            timestamp: Date(),
            metadata: [
                "operation": operation,
                "success": success,
            ],
        )

        recordMetric(for: .database, value: metric)
    }

    /// Record UI responsiveness
    public func recordUIResponsiveness(_ duration: TimeInterval, screen: String) {
        let metric = MetricValue(
            value: duration,
            timestamp: Date(),
            metadata: ["screen": screen],
        )

        recordMetric(for: .uiResponsiveness, value: metric)
    }

    // MARK: - Metric Retrieval

    /// Get metrics for a specific key
    public func getMetrics(for key: MetricKey) -> [MetricValue] {
        metrics[key] ?? []
    }

    /// Get all metrics
    public func getAllMetrics() -> [MetricKey: [MetricValue]] {
        metrics
    }

    /// Get metrics summary
    public func getMetricsSummary(for key: MetricKey) -> MetricsSummary? {
        guard let values = metrics[key], !values.isEmpty else {
            return nil
        }

        let sortedValues = values.map(\.value).sorted()
        let count = Double(sortedValues.count)
        let sum = sortedValues.reduce(0, +)
        let mean = sum / count

        let p50 = percentile(sortedValues, 0.5)
        let p95 = percentile(sortedValues, 0.95)
        let p99 = percentile(sortedValues, 0.99)

        return MetricsSummary(
            count: Int(count),
            min: sortedValues.first ?? 0,
            max: sortedValues.last ?? 0,
            mean: mean,
            p50: p50,
            p95: p95,
            p99: p99,
        )
    }

    /// Clear metrics older than specified date
    public func clearMetrics(olderThan date: Date) {
        for key in metrics.keys {
            metrics[key] = metrics[key]?.filter { $0.timestamp > date }
        }
    }

    // MARK: - Private Methods

    private func recordMetric(for key: MetricKey, value: MetricValue) {
        var values = metrics[key] ?? []
        values.append(value)

        // Keep only recent metrics
        if values.count > maxMetricsPerKey {
            values = Array(values.suffix(maxMetricsPerKey))
        }

        metrics[key] = values
    }

    private func percentile(_ sortedValues: [Double], _ p: Double) -> Double {
        guard !sortedValues.isEmpty else { return 0 }

        let index = p * Double(sortedValues.count - 1)
        let lower = Int(index)
        let upper = min(lower + 1, sortedValues.count - 1)
        let weight = index - Double(lower)

        return sortedValues[lower] * (1 - weight) + sortedValues[upper] * weight
    }

    private func getMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0,
                          &count)
            }
        }

        return result == KERN_SUCCESS ? Int64(info.resident_size) : 0
    }

    private func checkSLO(for transactionName: String, duration: TimeInterval) {
        let durationMs = duration * 1000

        // Check against SLOs from SPEC.json
        switch transactionName {
        case "cold_start":
            if durationMs > 1800 {
                logger.warning("SLO violation: Cold start took \(Int(durationMs))ms (max: 1800ms)")
            }
        case "db_read":
            if durationMs > 250 {
                logger.warning("SLO violation: DB read took \(Int(durationMs))ms (max: 250ms)")
            }
        default:
            break
        }
    }
}

// MARK: - Supporting Types

/// Metric key types
public enum MetricKey: Hashable {
    case transaction(String)
    case custom(String)
    case memory
    case networkLatency
    case database
    case uiResponsiveness
    case coldStart
}

/// Metric value
public struct MetricValue {
    public let value: Double
    public let timestamp: Date
    public let metadata: [String: Any]

    public init(value: Double, timestamp: Date = Date(), metadata: [String: Any] = [:]) {
        self.value = value
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

/// Performance transaction
private struct Transaction {
    let id: String
    let name: String
    let startTime: Date
    let metadata: [String: Any]
}

/// Metrics summary
public struct MetricsSummary {
    public let count: Int
    public let min: Double
    public let max: Double
    public let mean: Double
    public let p50: Double
    public let p95: Double
    public let p99: Double
}

// MARK: - Convenience Extensions

extension MetricValue: Hashable {
    public static func == (lhs: MetricValue, rhs: MetricValue) -> Bool {
        lhs.value == rhs.value && lhs.timestamp == rhs.timestamp
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(timestamp)
    }
}

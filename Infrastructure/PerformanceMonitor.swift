//
// Layer: Infrastructure
// Module: Monitoring
// Purpose: Performance monitoring and metrics collection
//

import Foundation
import os.log
import UIKit

/// Performance monitoring system for tracking app metrics
public final class PerformanceMonitor {
    
    // MARK: - Singleton
    
    public static let shared = PerformanceMonitor()
    
    // MARK: - Properties
    
    private let logger = Logger(subsystem: "com.nestory", category: "Performance")
    private var metrics: [PerformanceMetric] = []
    private let metricsQueue = DispatchQueue(label: "com.nestory.performance", qos: .utility)
    
    private var sessionStartTime: Date
    private var coldStartTime: TimeInterval?
    private var memoryBaseline: Float = 0
    
    // Thresholds for performance
    private let performanceThresholds = PerformanceThresholds(
        coldStartTarget: 1.8,      // 1800ms target
        scrollJankTarget: 0.03,    // 3% jank rate
        memoryWarning: 100,        // 100MB warning
        responseTimeP95: 0.25      // 250ms P95
    )
    
    // MARK: - Initialization
    
    private init() {
        self.sessionStartTime = Date()
        setupNotifications()
        startMemoryMonitoring()
    }
    
    // MARK: - Public API
    
    /// Track app cold start time
    public func trackColdStart(completion: @escaping () -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        DispatchQueue.main.async { [weak self] in
            let endTime = CFAbsoluteTimeGetCurrent()
            let duration = endTime - startTime
            
            self?.coldStartTime = duration
            self?.recordMetric(
                PerformanceMetric(
                    type: .coldStart,
                    value: duration,
                    timestamp: Date(),
                    metadata: ["launchType": "cold"]
                )
            )
            
            if duration > self?.performanceThresholds.coldStartTarget ?? 1.8 {
                self?.logger.warning("⚠️ Cold start exceeded target: \(duration, format: .fixed(precision: 2))s")
            } else {
                self?.logger.info("✅ Cold start: \(duration, format: .fixed(precision: 2))s")
            }
            
            completion()
        }
    }
    
    /// Track scroll performance
    public func trackScrollPerformance(
        in scrollView: UIScrollView,
        identifier: String
    ) -> ScrollPerformanceTracker {
        ScrollPerformanceTracker(
            scrollView: scrollView,
            identifier: identifier,
            monitor: self
        )
    }
    
    /// Track database query performance
    public func trackDatabaseQuery<T>(
        operation: String,
        block: () async throws -> T
    ) async throws -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            let result = try await block()
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            
            recordMetric(
                PerformanceMetric(
                    type: .databaseQuery,
                    value: duration,
                    timestamp: Date(),
                    metadata: ["operation": operation]
                )
            )
            
            if duration > performanceThresholds.responseTimeP95 {
                logger.warning("⚠️ Slow DB query (\(operation)): \(duration, format: .fixed(precision: 3))s")
            }
            
            return result
        } catch {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            recordMetric(
                PerformanceMetric(
                    type: .databaseQuery,
                    value: duration,
                    timestamp: Date(),
                    metadata: [
                        "operation": operation,
                        "error": error.localizedDescription
                    ]
                )
            )
            throw error
        }
    }
    
    /// Track network request performance
    public func trackNetworkRequest(
        url: URL,
        method: String,
        startTime: Date = Date()
    ) -> NetworkRequestTracker {
        NetworkRequestTracker(
            url: url,
            method: method,
            startTime: startTime,
            monitor: self
        )
    }
    
    /// Track memory usage
    public func trackMemoryUsage() {
        let memoryUsage = getCurrentMemoryUsage()
        
        recordMetric(
            PerformanceMetric(
                type: .memory,
                value: Double(memoryUsage),
                timestamp: Date(),
                metadata: ["baseline": "\(memoryBaseline)"]
            )
        )
        
        if memoryUsage > performanceThresholds.memoryWarning {
            logger.warning("⚠️ High memory usage: \(memoryUsage)MB")
        }
    }
    
    /// Track custom metric
    public func trackCustomMetric(
        name: String,
        value: Double,
        metadata: [String: String] = [:]
    ) {
        recordMetric(
            PerformanceMetric(
                type: .custom(name),
                value: value,
                timestamp: Date(),
                metadata: metadata
            )
        )
    }
    
    // MARK: - Reporting
    
    /// Generate performance report
    public func generateReport() -> PerformanceReport {
        metricsQueue.sync {
            let grouped = Dictionary(grouping: metrics) { $0.type }
            
            return PerformanceReport(
                sessionDuration: Date().timeIntervalSince(sessionStartTime),
                coldStartTime: coldStartTime,
                metrics: grouped,
                summary: generateSummary(from: grouped)
            )
        }
    }
    
    /// Export metrics for analysis
    public func exportMetrics() -> Data? {
        let report = generateReport()
        return try? JSONEncoder().encode(report)
    }
    
    /// Clear all metrics
    public func clearMetrics() {
        metricsQueue.async { [weak self] in
            self?.metrics.removeAll()
            self?.logger.info("Performance metrics cleared")
        }
    }
    
    // MARK: - Private Methods
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    private func startMemoryMonitoring() {
        memoryBaseline = getCurrentMemoryUsage()
        
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.trackMemoryUsage()
        }
    }
    
    private func getCurrentMemoryUsage() -> Float {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    $0,
                    &count
                )
            }
        }
        
        return result == KERN_SUCCESS ? Float(info.resident_size) / 1024 / 1024 : 0
    }
    
    private func recordMetric(_ metric: PerformanceMetric) {
        metricsQueue.async { [weak self] in
            self?.metrics.append(metric)
            
            // Keep only last 1000 metrics to prevent memory growth
            if self?.metrics.count ?? 0 > 1000 {
                self?.metrics.removeFirst(100)
            }
        }
    }
    
    private func generateSummary(from grouped: [MetricType: [PerformanceMetric]]) -> PerformanceSummary {
        var summary = PerformanceSummary()
        
        // Calculate P50, P95, P99 for each metric type
        for (type, metrics) in grouped {
            let values = metrics.map { $0.value }.sorted()
            guard !values.isEmpty else { continue }
            
            let p50 = values[values.count / 2]
            let p95 = values[Int(Double(values.count) * 0.95)]
            let p99 = values[Int(Double(values.count) * 0.99)]
            
            summary.percentiles[type] = Percentiles(p50: p50, p95: p95, p99: p99)
        }
        
        return summary
    }
    
    @objc private func handleMemoryWarning() {
        logger.critical("🚨 Memory warning received!")
        trackMemoryUsage()
        
        // Notify app to clear caches
        NotificationCenter.default.post(
            name: .performanceMemoryWarning,
            object: nil
        )
    }
}

// MARK: - Supporting Types

public struct PerformanceMetric: Codable {
    let type: MetricType
    let value: Double
    let timestamp: Date
    let metadata: [String: String]
}

public enum MetricType: Codable, Hashable {
    case coldStart
    case scrollPerformance
    case databaseQuery
    case networkRequest
    case memory
    case custom(String)
}

public struct PerformanceThresholds {
    let coldStartTarget: TimeInterval
    let scrollJankTarget: Double
    let memoryWarning: Float
    let responseTimeP95: TimeInterval
}

public struct PerformanceReport: Codable {
    let sessionDuration: TimeInterval
    let coldStartTime: TimeInterval?
    let metrics: [MetricType: [PerformanceMetric]]
    let summary: PerformanceSummary
}

public struct PerformanceSummary: Codable {
    var percentiles: [MetricType: Percentiles] = [:]
}

public struct Percentiles: Codable {
    let p50: Double
    let p95: Double
    let p99: Double
}

// MARK: - Trackers

public class ScrollPerformanceTracker {
    private let scrollView: UIScrollView
    private let identifier: String
    private weak var monitor: PerformanceMonitor?
    private var frameDrops = 0
    private var totalFrames = 0
    
    init(scrollView: UIScrollView, identifier: String, monitor: PerformanceMonitor) {
        self.scrollView = scrollView
        self.identifier = identifier
        self.monitor = monitor
        setupTracking()
    }
    
    private func setupTracking() {
        // Track scroll performance using CADisplayLink
        let displayLink = CADisplayLink(target: self, selector: #selector(trackFrame))
        displayLink.add(to: .main, forMode: .common)
    }
    
    @objc private func trackFrame() {
        totalFrames += 1
        // Detect frame drops
        // Implementation details...
    }
    
    deinit {
        let jankRate = Double(frameDrops) / Double(totalFrames)
        monitor?.trackCustomMetric(
            name: "scroll_jank",
            value: jankRate,
            metadata: ["view": identifier]
        )
    }
}

public class NetworkRequestTracker {
    private let url: URL
    private let method: String
    private let startTime: Date
    private weak var monitor: PerformanceMonitor?
    
    init(url: URL, method: String, startTime: Date, monitor: PerformanceMonitor) {
        self.url = url
        self.method = method
        self.startTime = startTime
        self.monitor = monitor
    }
    
    public func complete(statusCode: Int, error: Error? = nil) {
        let duration = Date().timeIntervalSince(startTime)
        
        monitor?.trackCustomMetric(
            name: "network_request",
            value: duration,
            metadata: [
                "url": url.absoluteString,
                "method": method,
                "status": "\(statusCode)",
                "error": error?.localizedDescription ?? ""
            ]
        )
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let performanceMemoryWarning = Notification.Name("PerformanceMemoryWarning")
}
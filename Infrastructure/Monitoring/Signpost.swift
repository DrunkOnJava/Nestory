// Layer: Infrastructure

import Foundation
import os.signpost

public final class Signpost: @unchecked Sendable {
    private let subsystem: String
    private let signpostLogs: [SignpostCategory: OSLog]

    public enum SignpostCategory: String, CaseIterable, Sendable {
        case network = "Network"
        case database = "Database"
        case imageProcessing = "ImageProcessing"
        case sync = "Sync"
        case encryption = "Encryption"
        case fileIO = "FileIO"
        case ui = "UI"
        case startup = "Startup"
        case backgroundTask = "BackgroundTask"
        case general = "General"
    }

    @MainActor
    public static let shared = Signpost(subsystem: "com.nestory")

    public init(subsystem: String) {
        self.subsystem = subsystem

        var logs: [SignpostCategory: OSLog] = [:]
        for category in SignpostCategory.allCases {
            logs[category] = OSLog(subsystem: subsystem, category: category.rawValue)
        }
        signpostLogs = logs
    }

    public func begin(
        _ name: StaticString,
        category: SignpostCategory = .general,
        id: OSSignpostID = .exclusive,
        message: String? = nil
    ) {
        let log = signpostLogs[category] ?? OSLog.default

        if let message {
            os_signpost(.begin, log: log, name: name, signpostID: id, "%{public}s", message)
        } else {
            os_signpost(.begin, log: log, name: name, signpostID: id)
        }
    }

    public func end(
        _ name: StaticString,
        category: SignpostCategory = .general,
        id: OSSignpostID = .exclusive,
        message: String? = nil
    ) {
        let log = signpostLogs[category] ?? OSLog.default

        if let message {
            os_signpost(.end, log: log, name: name, signpostID: id, "%{public}s", message)
        } else {
            os_signpost(.end, log: log, name: name, signpostID: id)
        }
    }

    public func event(
        _ name: StaticString,
        category: SignpostCategory = .general,
        id: OSSignpostID = .exclusive,
        message: String? = nil
    ) {
        let log = signpostLogs[category] ?? OSLog.default

        if let message {
            os_signpost(.event, log: log, name: name, signpostID: id, "%{public}s", message)
        } else {
            os_signpost(.event, log: log, name: name, signpostID: id)
        }
    }

    public func measure<T>(
        _ name: StaticString,
        category: SignpostCategory = .general,
        message: String? = nil,
        operation: () throws -> T
    ) rethrows -> T {
        let id = OSSignpostID(log: signpostLogs[category] ?? OSLog.default)
        begin(name, category: category, id: id, message: message)
        defer { end(name, category: category, id: id) }
        return try operation()
    }

    public func measureAsync<T>(
        _ name: StaticString,
        category: SignpostCategory = .general,
        message: String? = nil,
        operation: () async throws -> T
    ) async rethrows -> T {
        let id = OSSignpostID(log: signpostLogs[category] ?? OSLog.default)
        begin(name, category: category, id: id, message: message)
        defer { end(name, category: category, id: id) }
        return try await operation()
    }

    public func networkRequest(url: String) -> SignpostInterval {
        let id = OSSignpostID(log: signpostLogs[.network] ?? OSLog.default)
        begin("NetworkRequest", category: .network, id: id, message: url)
        return SignpostInterval(name: "NetworkRequest", category: .network, id: id, signpost: self)
    }

    public func databaseQuery(operation: String) -> SignpostInterval {
        let id = OSSignpostID(log: signpostLogs[.database] ?? OSLog.default)
        begin("DatabaseQuery", category: .database, id: id, message: operation)
        return SignpostInterval(name: "DatabaseQuery", category: .database, id: id, signpost: self)
    }

    public func imageProcessing(operation: String) -> SignpostInterval {
        let id = OSSignpostID(log: signpostLogs[.imageProcessing] ?? OSLog.default)
        begin("ImageProcessing", category: .imageProcessing, id: id, message: operation)
        return SignpostInterval(name: "ImageProcessing", category: .imageProcessing, id: id, signpost: self)
    }

    public func syncOperation(type: String) -> SignpostInterval {
        let id = OSSignpostID(log: signpostLogs[.sync] ?? OSLog.default)
        begin("SyncOperation", category: .sync, id: id, message: type)
        return SignpostInterval(name: "SyncOperation", category: .sync, id: id, signpost: self)
    }

    public func encryptionOperation(type: String) -> SignpostInterval {
        let id = OSSignpostID(log: signpostLogs[.encryption] ?? OSLog.default)
        begin("Encryption", category: .encryption, id: id, message: type)
        return SignpostInterval(name: "Encryption", category: .encryption, id: id, signpost: self)
    }

    public func fileOperation(type: String, path: String) -> SignpostInterval {
        let id = OSSignpostID(log: signpostLogs[.fileIO] ?? OSLog.default)
        begin("FileOperation", category: .fileIO, id: id, message: "\(type): \(path)")
        return SignpostInterval(name: "FileOperation", category: .fileIO, id: id, signpost: self)
    }

    public func uiOperation(screen: String, action: String) -> SignpostInterval {
        let id = OSSignpostID(log: signpostLogs[.ui] ?? OSLog.default)
        begin("UIOperation", category: .ui, id: id, message: "\(screen).\(action)")
        return SignpostInterval(name: "UIOperation", category: .ui, id: id, signpost: self)
    }

    public func appLaunch() -> SignpostInterval {
        let id = OSSignpostID(log: signpostLogs[.startup] ?? OSLog.default)
        begin("AppLaunch", category: .startup, id: id)
        return SignpostInterval(name: "AppLaunch", category: .startup, id: id, signpost: self)
    }

    public func backgroundTask(name: String) -> SignpostInterval {
        let id = OSSignpostID(log: signpostLogs[.backgroundTask] ?? OSLog.default)
        begin("BackgroundTask", category: .backgroundTask, id: id, message: name)
        return SignpostInterval(name: "BackgroundTask", category: .backgroundTask, id: id, signpost: self)
    }
}

public final class SignpostInterval: @unchecked Sendable {
    private let name: StaticString
    private let category: Signpost.SignpostCategory
    private let id: OSSignpostID
    private weak var signpost: Signpost?
    private var isEnded = false

    init(name: StaticString, category: Signpost.SignpostCategory, id: OSSignpostID, signpost: Signpost) {
        self.name = name
        self.category = category
        self.id = id
        self.signpost = signpost
    }

    public func end(message: String? = nil) {
        guard !isEnded else { return }
        isEnded = true
        signpost?.end(name, category: category, id: id, message: message)
    }

    public func event(message: String) {
        signpost?.event(name, category: category, id: id, message: message)
    }

    deinit {
        if !isEnded {
            end()
        }
    }
}

public extension Signpost {
    struct Metrics: @unchecked Sendable {
        public let name: String
        public let category: SignpostCategory
        public let startTime: CFAbsoluteTime
        public let endTime: CFAbsoluteTime
        public let duration: TimeInterval
        public let metadata: [String: Any]?

        public init(
            name: String,
            category: SignpostCategory,
            startTime: CFAbsoluteTime,
            endTime: CFAbsoluteTime,
            metadata: [String: Any]? = nil
        ) {
            self.name = name
            self.category = category
            self.startTime = startTime
            self.endTime = endTime
            duration = endTime - startTime
            self.metadata = metadata
        }
    }

    final class MetricsCollector: @unchecked Sendable {
        private var metrics: [Metrics] = []
        private let queue = DispatchQueue(label: "com.nestory.signpost.metrics", attributes: .concurrent)

        public func record(_ metric: Metrics) {
            queue.async(flags: .barrier) {
                self.metrics.append(metric)
            }
        }

        public func getMetrics() -> [Metrics] {
            queue.sync {
                metrics
            }
        }

        public func clearMetrics() {
            queue.async(flags: .barrier) {
                self.metrics.removeAll()
            }
        }

        public func averageDuration(for name: String) -> TimeInterval? {
            let relevantMetrics = queue.sync {
                metrics.filter { $0.name == name }
            }

            guard !relevantMetrics.isEmpty else { return nil }

            let totalDuration = relevantMetrics.reduce(0) { $0 + $1.duration }
            return totalDuration / Double(relevantMetrics.count)
        }

        public func percentile(_ percentile: Double, for name: String) -> TimeInterval? {
            guard percentile >= 0, percentile <= 100 else { return nil }

            let relevantMetrics = queue.sync {
                metrics.filter { $0.name == name }.sorted { $0.duration < $1.duration }
            }

            guard !relevantMetrics.isEmpty else { return nil }

            let index = Int(Double(relevantMetrics.count - 1) * percentile / 100.0)
            return relevantMetrics[index].duration
        }
    }
}

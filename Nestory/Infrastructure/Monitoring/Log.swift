// Layer: Infrastructure

import Foundation
import os.log

public final class Log {
    private let subsystem: String
    private let loggers: [LogCategory: Logger]

    public enum LogCategory: String, CaseIterable {
        case app = "App"
        case network = "Network"
        case database = "Database"
        case security = "Security"
        case storage = "Storage"
        case sync = "Sync"
        case ui = "UI"
        case business = "Business"
        case performance = "Performance"
        case analytics = "Analytics"
    }

    public static let shared = Log(subsystem: "com.nestory")

    public init(subsystem: String) {
        self.subsystem = subsystem

        var loggers: [LogCategory: Logger] = [:]
        for category in LogCategory.allCases {
            loggers[category] = Logger(subsystem: subsystem, category: category.rawValue)
        }
        self.loggers = loggers
    }

    public func logger(for category: LogCategory) -> Logger {
        loggers[category] ?? Logger(subsystem: subsystem, category: "General")
    }

    public func debug(_ message: String, category: LogCategory = .app, metadata: [String: Any]? = nil) {
        let logger = logger(for: category)

        if let metadata {
            logger.debug("\(message) | \(formatMetadata(metadata))")
        } else {
            logger.debug("\(message)")
        }
    }

    public func info(_ message: String, category: LogCategory = .app, metadata: [String: Any]? = nil) {
        let logger = logger(for: category)

        if let metadata {
            logger.info("\(message) | \(formatMetadata(metadata))")
        } else {
            logger.info("\(message)")
        }
    }

    public func notice(_ message: String, category: LogCategory = .app, metadata: [String: Any]? = nil) {
        let logger = logger(for: category)

        if let metadata {
            logger.notice("\(message) | \(formatMetadata(metadata))")
        } else {
            logger.notice("\(message)")
        }
    }

    public func warning(_ message: String, category: LogCategory = .app, metadata: [String: Any]? = nil) {
        let logger = logger(for: category)

        if let metadata {
            logger.warning("\(message) | \(formatMetadata(metadata))")
        } else {
            logger.warning("\(message)")
        }
    }

    public func error(_ message: String, category: LogCategory = .app, error: Error? = nil, metadata: [String: Any]? = nil) {
        let logger = logger(for: category)

        var fullMessage = message

        if let error {
            fullMessage += " | Error: \(error.localizedDescription)"
        }

        if let metadata {
            fullMessage += " | \(formatMetadata(metadata))"
        }

        logger.error("\(fullMessage)")
    }

    public func critical(_ message: String, category: LogCategory = .app, error: Error? = nil, metadata: [String: Any]? = nil) {
        let logger = logger(for: category)

        var fullMessage = "CRITICAL: \(message)"

        if let error {
            fullMessage += " | Error: \(error.localizedDescription)"
        }

        if let metadata {
            fullMessage += " | \(formatMetadata(metadata))"
        }

        logger.critical("\(fullMessage)")
    }

    public func fault(_ message: String, category: LogCategory = .app, error: Error? = nil, metadata: [String: Any]? = nil) {
        let logger = logger(for: category)

        var fullMessage = "FAULT: \(message)"

        if let error {
            fullMessage += " | Error: \(error.localizedDescription)"
        }

        if let metadata {
            fullMessage += " | \(formatMetadata(metadata))"
        }

        logger.fault("\(fullMessage)")
    }

    public func performance(_ operation: String, category: LogCategory = .performance, block: () throws -> Void) rethrows {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            let logger = self.logger(for: category)
            logger.info("Performance: \(operation) completed in \(String(format: "%.3f", duration))s")
        }

        try block()
    }

    public func performanceAsync<T>(_ operation: String, category: LogCategory = .performance, block: () async throws -> T) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            let logger = self.logger(for: category)
            logger.info("Performance: \(operation) completed in \(String(format: "%.3f", duration))s")
        }

        return try await block()
    }

    public func breadcrumb(_ message: String, category: LogCategory = .app, level: OSLogType = .debug) {
        let logger = logger(for: category)
        logger.log(level: level, "Breadcrumb: \(message)")
    }

    public func networkRequest(url: String, method: String, statusCode: Int?, duration: TimeInterval, error: Error? = nil) {
        let logger = logger(for: .network)

        var message = "Network: \(method) \(url)"

        if let statusCode {
            message += " | Status: \(statusCode)"
        }

        message += " | Duration: \(String(format: "%.3f", duration))s"

        if let error {
            message += " | Error: \(error.localizedDescription)"
            logger.error("\(message)")
        } else {
            logger.info("\(message)")
        }
    }

    public func databaseOperation(_ operation: String, table: String? = nil, duration: TimeInterval, recordCount: Int? = nil, error: Error? = nil) {
        let logger = logger(for: .database)

        var message = "Database: \(operation)"

        if let table {
            message += " on \(table)"
        }

        if let recordCount {
            message += " | Records: \(recordCount)"
        }

        message += " | Duration: \(String(format: "%.3f", duration))s"

        if let error {
            message += " | Error: \(error.localizedDescription)"
            logger.error("\(message)")
        } else {
            logger.debug("\(message)")
        }
    }

    public func userAction(_ action: String, category: LogCategory = .ui, metadata: [String: Any]? = nil) {
        let logger = logger(for: category)

        var message = "User Action: \(action)"

        if let metadata {
            message += " | \(formatMetadata(metadata))"
        }

        logger.info("\(message)")
    }

    private func formatMetadata(_ metadata: [String: Any]) -> String {
        metadata
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
    }
}

public extension Log {
    struct Context {
        public let userId: String?
        public let sessionId: String?
        public let deviceId: String?
        public let appVersion: String?
        public let buildNumber: String?

        public init(
            userId: String? = nil,
            sessionId: String? = nil,
            deviceId: String? = nil,
            appVersion: String? = nil,
            buildNumber: String? = nil
        ) {
            self.userId = userId
            self.sessionId = sessionId
            self.deviceId = deviceId
            self.appVersion = appVersion
            self.buildNumber = buildNumber
        }

        public var metadata: [String: Any] {
            var dict: [String: Any] = [:]

            if let userId {
                dict["userId"] = userId
            }
            if let sessionId {
                dict["sessionId"] = sessionId
            }
            if let deviceId {
                dict["deviceId"] = deviceId
            }
            if let appVersion {
                dict["appVersion"] = appVersion
            }
            if let buildNumber {
                dict["buildNumber"] = buildNumber
            }

            return dict
        }
    }

    private static var currentContext: Context?

    static func setContext(_ context: Context) {
        currentContext = context
    }

    func logWithContext(_ message: String, category: LogCategory = .app, level: OSLogType = .info, additionalMetadata: [String: Any]? = nil) {
        var metadata = Log.currentContext?.metadata ?? [:]

        if let additionalMetadata {
            metadata.merge(additionalMetadata) { _, new in new }
        }

        switch level {
        case .debug:
            debug(message, category: category, metadata: metadata)
        case .info:
            info(message, category: category, metadata: metadata)
        case .error:
            error(message, category: category, metadata: metadata)
        case .fault:
            fault(message, category: category, metadata: metadata)
        default:
            info(message, category: category, metadata: metadata)
        }
    }
}

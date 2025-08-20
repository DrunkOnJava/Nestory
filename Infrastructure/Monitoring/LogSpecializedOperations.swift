//
// Layer: Infrastructure
// Module: Monitoring
// Purpose: Specialized logging operations for performance, network, database, and user actions
//

import Foundation
import os.log

// MARK: - Specialized Logging Operations

extension Log {
    /// Log a performance measurement with a closure that returns the measured value
    /// - Parameters:
    ///   - operation: Description of the operation being measured
    ///   - category: The log category (defaults to .performance)
    ///   - closure: The closure to measure
    /// - Returns: The value returned by the closure
    public func performance<T>(
        _ operation: String,
        category: LogCategory = .performance,
        closure: () throws -> T
    ) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            info("Performance: \(operation) took \(String(format: "%.3f", timeElapsed))s", category: category)
        }

        return try closure()
    }

    /// Log a performance measurement with an async closure
    /// - Parameters:
    ///   - operation: Description of the operation being measured
    ///   - category: The log category (defaults to .performance)
    ///   - closure: The async closure to measure
    /// - Returns: The value returned by the closure
    public func performanceAsync<T>(
        _ operation: String,
        category: LogCategory = .performance,
        closure: () async throws -> T
    ) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            info("Performance: \(operation) took \(String(format: "%.3f", timeElapsed))s", category: category)
        }

        return try await closure()
    }

    /// Log a breadcrumb message for debugging flow
    /// - Parameters:
    ///   - message: The breadcrumb message
    ///   - category: The log category (defaults to .app)
    ///   - level: The log level (defaults to .debug)
    public func breadcrumb(_ message: String, category: LogCategory = .app, level: OSLogType = .debug) {
        let logger = logger(for: category)
        let breadcrumbMessage = "🍞 \(message)"

        switch level {
        case .debug:
            logger.debug("\(breadcrumbMessage)")
        case .info:
            logger.info("\(breadcrumbMessage)")
        case .error:
            logger.error("\(breadcrumbMessage)")
        default:
            logger.debug("\(breadcrumbMessage)")
        }
    }

    /// Log a network request with standard information
    /// - Parameters:
    ///   - method: HTTP method
    ///   - url: Request URL
    ///   - statusCode: Response status code (optional)
    ///   - duration: Request duration in seconds (optional)
    ///   - responseSize: Response size in bytes (optional)
    ///   - error: Error if request failed (optional)
    public func networkRequest(
        method: String,
        url: String,
        statusCode: Int? = nil,
        duration: TimeInterval? = nil,
        responseSize: Int? = nil,
        error: Error? = nil,
    ) {
        let logger = logger(for: .network)

        var message = "🌐 \(method) \(url)"

        if let statusCode {
            message += " → \(statusCode)"
        }

        if let duration {
            message += " (\(String(format: "%.3f", duration))s)"
        }

        if let responseSize {
            message += " [\(responseSize) bytes]"
        }

        if let error {
            logger.error("\(message) | Error: \(error.localizedDescription)")
        } else {
            logger.info("\(message)")
        }
    }

    /// Log a database operation
    /// - Parameters:
    ///   - operation: Type of database operation (SELECT, INSERT, UPDATE, DELETE)
    ///   - table: Table or entity name (optional)
    ///   - duration: Operation duration in seconds (optional)
    ///   - rowsAffected: Number of rows affected (optional)
    ///   - error: Error if operation failed (optional)
    ///   - metadata: Additional metadata (optional)
    public func databaseOperation(
        _ operation: String,
        table: String? = nil,
        duration: TimeInterval? = nil,
        rowsAffected: Int? = nil,
        error: Error? = nil,
        metadata: [String: Any]? = nil,
    ) {
        let logger = logger(for: .database)

        var message = "💾 \(operation)"

        if let table {
            message += " on \(table)"
        }

        if let rowsAffected {
            message += " (\(rowsAffected) rows)"
        }

        if let duration {
            message += " in \(String(format: "%.3f", duration))s"
        }

        if let metadata {
            message += " | \(formatMetadata(metadata))"
        }

        if let error {
            logger.error("\(message) | Error: \(error.localizedDescription)")
        } else {
            logger.info("\(message)")
        }
    }

    /// Log a user action for analytics and debugging
    /// - Parameters:
    ///   - action: The action performed by the user
    ///   - category: The log category (defaults to .ui)
    ///   - metadata: Optional metadata about the action
    public func userAction(_ action: String, category: LogCategory = .ui, metadata: [String: Any]? = nil) {
        let logger = logger(for: category)

        var message = "User Action: \(action)"

        if let metadata {
            message += " | \(formatMetadata(metadata))"
        }

        logger.info("\(message)")
    }
}

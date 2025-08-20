// Layer: Infrastructure
// Module: Monitoring
// Purpose: Core centralized logging service with structured logging and categories

import Foundation
import os.log

// Bundle-based configuration access

/// A centralized logging service that provides structured logging with categories and metadata
/// support. This service uses os.log for performance and integrates with the system logging
/// infrastructure.
public final class Log {
    private let subsystem: String
    private let loggers: [LogCategory: Logger]

    /// Categories for organizing log messages by system component
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

    /// Shared instance of the logger for the main application subsystem
    @MainActor
    public static let shared = Log(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory")

    /// Initialize a new logger for the given subsystem
    /// - Parameter subsystem: The subsystem identifier (usually bundle identifier)
    public init(subsystem: String) {
        self.subsystem = subsystem

        var loggers: [LogCategory: Logger] = [:]
        for category in LogCategory.allCases {
            loggers[category] = Logger(subsystem: subsystem, category: category.rawValue)
        }
        self.loggers = loggers
    }

    /// Get the system logger for a specific category
    /// - Parameter category: The log category to get the logger for
    /// - Returns: The configured Logger instance for the category
    public func logger(for category: LogCategory) -> Logger {
        loggers[category] ?? Logger(subsystem: subsystem, category: "General")
    }

    /// Log a debug message
    /// - Parameters:
    ///   - message: The message to log
    ///   - category: The log category (defaults to .app)
    ///   - metadata: Optional metadata dictionary
    public func debug(_ message: String, category: LogCategory = .app, metadata: [String: Any]? = nil) {
        let logger = logger(for: category)

        if let metadata {
            logger.debug("\(message) | \(self.formatMetadata(metadata))")
        } else {
            logger.debug("\(message)")
        }
    }

    /// Log an informational message
    /// - Parameters:
    ///   - message: The message to log
    ///   - category: The log category (defaults to .app)
    ///   - metadata: Optional metadata dictionary
    public func info(_ message: String, category: LogCategory = .app, metadata: [String: Any]? = nil) {
        let logger = logger(for: category)

        if let metadata {
            logger.info("\(message) | \(self.formatMetadata(metadata))")
        } else {
            logger.info("\(message)")
        }
    }

    /// Log a notice message
    /// - Parameters:
    ///   - message: The message to log
    ///   - category: The log category (defaults to .app)
    ///   - metadata: Optional metadata dictionary
    public func notice(_ message: String, category: LogCategory = .app, metadata: [String: Any]? = nil) {
        let logger = logger(for: category)

        if let metadata {
            logger.notice("\(message) | \(self.formatMetadata(metadata))")
        } else {
            logger.notice("\(message)")
        }
    }

    /// Log a warning message
    /// - Parameters:
    ///   - message: The message to log
    ///   - category: The log category (defaults to .app)
    ///   - metadata: Optional metadata dictionary
    public func warning(_ message: String, category: LogCategory = .app, metadata: [String: Any]? = nil) {
        let logger = logger(for: category)

        if let metadata {
            logger.warning("\(message) | \(self.formatMetadata(metadata))")
        } else {
            logger.warning("\(message)")
        }
    }

    /// Log an error message
    /// - Parameters:
    ///   - message: The error message to log
    ///   - category: The log category (defaults to .app)
    ///   - error: Optional associated Error object
    ///   - metadata: Optional metadata dictionary
    public func error(
        _ message: String,
        category: LogCategory = .app,
        error: Error? = nil,
        metadata: [String: Any]? = nil,
    ) {
        let logger = logger(for: category)

        var logMessage = message
        if let error {
            logMessage += " | Error: \(error.localizedDescription)"
        }

        if let metadata {
            logMessage += " | \(formatMetadata(metadata))"
        }

        logger.error("\(logMessage)")
    }

    /// Log a critical error message
    /// - Parameters:
    ///   - message: The critical error message to log
    ///   - category: The log category (defaults to .app)
    ///   - error: Optional associated Error object
    ///   - metadata: Optional metadata dictionary
    public func critical(
        _ message: String,
        category: LogCategory = .app,
        error: Error? = nil,
        metadata: [String: Any]? = nil,
    ) {
        let logger = logger(for: category)

        var logMessage = message
        if let error {
            logMessage += " | Error: \(error.localizedDescription)"
        }

        if let metadata {
            logMessage += " | \(formatMetadata(metadata))"
        }

        logger.critical("\(logMessage)")
    }

    /// Log a fault message
    /// - Parameters:
    ///   - message: The fault message to log
    ///   - category: The log category (defaults to .app)
    ///   - error: Optional associated Error object
    ///   - metadata: Optional metadata dictionary
    public func fault(
        _ message: String,
        category: LogCategory = .app,
        error: Error? = nil,
        metadata: [String: Any]? = nil,
    ) {
        let logger = logger(for: category)

        var logMessage = message
        if let error {
            logMessage += " | Error: \(error.localizedDescription)"
        }

        if let metadata {
            logMessage += " | \(formatMetadata(metadata))"
        }

        logger.fault("\(logMessage)")
    }

    // MARK: - Helper Methods

    func formatMetadata(_ metadata: [String: Any]) -> String {
        metadata
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
    }

    // Specialized operations have been moved to extension files:
    // - LogSpecializedOperations.swift - performance, network, database, user actions
    // - LogContext.swift - context management and contextual logging
}

//
// Layer: Foundation
// Module: Foundation/Core  
// Purpose: Unified logging infrastructure using OSLog
//

import Foundation
import OSLog
import os.signpost

// MARK: - Logger Extensions

/// Centralized logging infrastructure following Apple's best practices
extension Logger {
    /// The app's bundle identifier used as the subsystem for all loggers
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.nestory.app"
    
    // MARK: - App Loggers
    
    /// General app lifecycle and flow logging
    static let app = Logger(subsystem: subsystem, category: "app")
    
    /// Database operations and SwiftData logging
    static let database = Logger(subsystem: subsystem, category: "database")
    
    /// Network requests and API communication
    static let network = Logger(subsystem: subsystem, category: "network")
    
    /// UI events and user interactions
    static let ui = Logger(subsystem: subsystem, category: "ui")
    
    /// Service layer operations
    static let service = Logger(subsystem: subsystem, category: "service")
    
    /// Analytics and metrics
    static let analytics = Logger(subsystem: subsystem, category: "analytics")
    
    /// Security and authentication
    static let security = Logger(subsystem: subsystem, category: "security")
    
    /// Performance monitoring
    static let performance = Logger(subsystem: subsystem, category: "performance")
    
    /// Error tracking
    static let error = Logger(subsystem: subsystem, category: "error")
}

// MARK: - Signpost Logger

/// Performance monitoring using signposts
public struct PerformanceLogger {
    private static let signpostLog = OSLog(
        subsystem: Bundle.main.bundleIdentifier ?? "com.nestory.app",
        category: .pointsOfInterest
    )
    
    /// Begin a performance measurement
    public static func begin(_ name: StaticString, id: OSSignpostID? = nil) -> OSSignpostID {
        let signpostID = id ?? OSSignpostID(log: signpostLog)
        os_signpost(.begin, log: signpostLog, name: name, signpostID: signpostID)
        return signpostID
    }
    
    /// End a performance measurement
    public static func end(_ name: StaticString, id: OSSignpostID) {
        os_signpost(.end, log: signpostLog, name: name, signpostID: id)
    }
    
    /// Measure the execution time of a block
    public static func measure<T>(_ name: StaticString, block: () throws -> T) rethrows -> T {
        let signpostID = begin(name)
        defer { end(name, id: signpostID) }
        return try block()
    }
    
    /// Measure the execution time of an async block
    public static func measure<T>(_ name: StaticString, block: () async throws -> T) async rethrows -> T {
        let signpostID = begin(name)
        defer { end(name, id: signpostID) }
        return try await block()
    }
}

// MARK: - Error Logging Extensions

extension Logger {
    /// Log an error with full context
    public func logError(_ error: Error, context: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        var message = "Error in \(fileName):\(line) \(function)"
        
        if let context = context {
            message += " - Context: \(context)"
        }
        
        message += " - Error: \(error.localizedDescription)"
        
        if let nsError = error as NSError? {
            message += " - Domain: \(nsError.domain), Code: \(nsError.code)"
            if !nsError.userInfo.isEmpty {
                message += " - UserInfo: \(nsError.userInfo)"
            }
        }
        
        self.error("\(message)")
    }
    
    /// Log a warning with context
    public func logWarning(_ message: String, context: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        var fullMessage = "Warning in \(fileName):\(line) \(function) - \(message)"
        
        if let context = context {
            fullMessage += " - Context: \(context)"
        }
        
        self.warning("\(fullMessage)")
    }
}

// MARK: - Debug Logging

#if DEBUG
extension Logger {
    /// Debug-only logging that compiles out in release builds
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        // Use os_log directly to avoid any potential method resolution issues
        os_log(.debug, log: OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.nestory.app", category: "debug"), "%{public}s", "[\(fileName):\(line)] \(function) - \(message)")
    }
}
#endif

// MARK: - Privacy-Aware Logging

extension Logger {
    /// Log sensitive information with appropriate privacy level
    public func logSensitive(_ message: String) {
        self.info("\(message, privacy: .private)")
    }
    
    /// Log user data with automatic privacy
    public func logUserData<T>(_ key: String, value: T) where T: CustomStringConvertible {
        self.info("User data - \(key): \(value.description, privacy: .private)")
    }
}

// MARK: - Structured Logging

/// A structured log entry for consistent logging format
public struct LogEntry {
    public let timestamp: Date
    public let category: String
    public let level: OSLogType
    public let message: String
    public let metadata: [String: Any]?
    
    public init(
        category: String,
        level: OSLogType = .default,
        message: String,
        metadata: [String: Any]? = nil
    ) {
        self.timestamp = Date()
        self.category = category
        self.level = level
        self.message = message
        self.metadata = metadata
    }
    
    /// Convert to a formatted log message
    public var formattedMessage: String {
        var result = "[\(category)] \(message)"
        
        if let metadata = metadata, !metadata.isEmpty {
            let metadataString = metadata
                .map { "\($0.key): \($0.value)" }
                .joined(separator: ", ")
            result += " | Metadata: {\(metadataString)}"
        }
        
        return result
    }
}

// MARK: - Logger Protocol

/// Protocol for mockable logging in tests
public protocol LoggerProtocol {
    func log(_ entry: LogEntry)
    func logError(_ error: Error, context: String?)
    func logPerformanceStart(_ operation: String) -> OSSignpostID
    func logPerformanceEnd(_ operation: String, id: OSSignpostID)
}

/// Default implementation using OSLog
public struct DefaultLogger: LoggerProtocol {
    private let logger: Logger
    
    public init(category: String) {
        self.logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "com.nestory.app",
            category: category
        )
    }
    
    public func log(_ entry: LogEntry) {
        logger.log(level: entry.level, "\(entry.formattedMessage)")
    }
    
    public func logError(_ error: Error, context: String?) {
        logger.logError(error, context: context)
    }
    
    public func logPerformanceStart(_ operation: String) -> OSSignpostID {
        // Use a generic static string for dynamic operations
        let signpostID = OSSignpostID(log: OSLog(
            subsystem: Bundle.main.bundleIdentifier ?? "com.nestory.app",
            category: .pointsOfInterest
        ))
        os_signpost(.begin, log: OSLog(
            subsystem: Bundle.main.bundleIdentifier ?? "com.nestory.app",
            category: .pointsOfInterest
        ), name: "DynamicOperation", signpostID: signpostID, "%{public}s", operation)
        return signpostID
    }
    
    public func logPerformanceEnd(_ operation: String, id: OSSignpostID) {
        os_signpost(.end, log: OSLog(
            subsystem: Bundle.main.bundleIdentifier ?? "com.nestory.app",
            category: .pointsOfInterest
        ), name: "DynamicOperation", signpostID: id, "%{public}s", operation)
    }
}
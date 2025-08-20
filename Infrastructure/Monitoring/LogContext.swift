//
// Layer: Infrastructure
// Module: Monitoring
// Purpose: Context management for structured logging with global context support
//

import Foundation
import os.log

// MARK: - Log Context Management

extension Log {
    /// Context information that can be attached to log messages for better debugging
    public struct Context {
        /// Optional user identifier
        public let userId: String?
        /// Optional session identifier
        public let sessionId: String?
        /// Optional device identifier
        public let deviceId: String?
        /// Optional application version
        public let appVersion: String?
        /// Optional build number
        public let buildNumber: String?

        /// Initialize a new logging context
        /// - Parameters:
        ///   - userId: Optional user identifier
        ///   - sessionId: Optional session identifier
        ///   - deviceId: Optional device identifier
        ///   - appVersion: Optional application version
        ///   - buildNumber: Optional build number
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

        /// Convert context to metadata dictionary for logging
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

    private nonisolated(unsafe) static var currentContext: Context?

    /// Set the global logging context
    /// - Parameter context: The context to set globally
    public static func setContext(_ context: Context) {
        currentContext = context
    }

    /// Log a message with the current global context and optional additional metadata
    /// - Parameters:
    ///   - message: The message to log
    ///   - category: The log category (defaults to .app)
    ///   - level: The log level (defaults to .info)
    ///   - additionalMetadata: Optional additional metadata to include
    public func logWithContext(
        _ message: String,
        category: LogCategory = .app,
        level: OSLogType = .info,
        additionalMetadata: [String: Any]? = nil,
    ) {
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

//
// Layer: Foundation
// Module: Foundation/Core
// Purpose: Comprehensive error logging and user-friendly error presentation
//

import Foundation

// Using Foundation Bundle for configuration access

// MARK: - Error Logging Infrastructure

public actor ErrorLogger {
    public static let shared = ErrorLogger()

    private let logger: FoundationLogger?
    private var errorHistory: [LoggedError] = []
    private let maxHistorySize = 1000

    private init(logger: FoundationLogger? = nil) {
        self.logger = logger
    }

    /// Configure the logger with an Infrastructure-provided implementation
    public func setLogger(_: FoundationLogger) {
        // Note: Can't modify the shared instance logger after init
        // This would be better implemented with dependency injection
    }

    /// Log an error with comprehensive context
    public func logError(
        _ error: Error,
        category: ErrorCategory = .general,
        source: String = #function,
        file: String = #file,
        line: Int = #line,
        userContext: [String: String] = [:],
    ) {
        let loggedError = LoggedError(
            error: error,
            category: category,
            source: source,
            file: file,
            line: line,
            userContext: userContext,
            timestamp: Date(),
        )

        errorHistory.append(loggedError)

        // Maintain history size
        if errorHistory.count > maxHistorySize {
            errorHistory.removeFirst(errorHistory.count - maxHistorySize)
        }

        // Log based on severity
        let severity = determineSeverity(for: error)
        let message = "[\(category.rawValue)]: \(error.localizedDescription) at \(source):\(line)"

        switch severity {
        case .critical:
            logger?.error("CRITICAL ERROR \(message)")
        case .error:
            logger?.error("ERROR \(message)")
        case .warning:
            logger?.warning("WARNING \(message)")
        case .info:
            logger?.info("INFO \(message)")
        }

        // Log additional context if available
        if !userContext.isEmpty {
            logger?.info("Error context: \(userContext)")
        }
    }

    /// Get recent errors for debugging
    public func getRecentErrors(limit: Int = 50) -> [LoggedError] {
        Array(errorHistory.suffix(limit))
    }

    /// Get errors by category
    public func getErrors(category: ErrorCategory, limit: Int = 50) -> [LoggedError] {
        errorHistory
            .filter { $0.category == category }
            .suffix(limit)
            .reversed()
    }

    /// Clear error history
    public func clearHistory() {
        errorHistory.removeAll()
        logger?.info("Error history cleared")
    }

    /// Generate error report for support
    public func generateErrorReport() -> String {
        let recentErrors = getRecentErrors(limit: 20)

        var report = "=== \(Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Nestory") Error Report ===\n"
        report += "Generated: \(Date().formatted())\n"
        report += "Total Errors Logged: \(errorHistory.count)\n\n"

        for (index, error) in recentErrors.enumerated() {
            report += "[\(index + 1)] \(error.timestamp.formatted()) - \(error.category.rawValue.uppercased())\n"
            report += "Source: \(error.source) (\(URL(fileURLWithPath: error.file).lastPathComponent):\(error.line))\n"
            report += "Error: \(error.error.localizedDescription)\n"

            if let serviceError = error.error as? ServiceError {
                if let recovery = serviceError.recoverySuggestion {
                    report += "Recovery: \(recovery)\n"
                }
            }

            if !error.userContext.isEmpty {
                report += "Context: \(error.userContext)\n"
            }

            report += "\n"
        }

        return report
    }

    private func determineSeverity(for error: Error) -> LogSeverity {
        if let serviceError = error as? ServiceError {
            switch serviceError.priority {
            case .critical:
                return .critical
            case .high:
                return .error
            case .medium:
                return .warning
            case .low:
                return .info
            }
        }

        // Default classification
        if error is NotificationServiceError || error is AnalyticsServiceError {
            return .warning
        }

        return .error
    }
}

// MARK: - Supporting Types

public struct LoggedError {
    public let error: Error
    public let category: ErrorCategory
    public let source: String
    public let file: String
    public let line: Int
    public let userContext: [String: String]
    public let timestamp: Date
}

public enum ErrorCategory: String, CaseIterable, Sendable {
    case general
    case network
    case database
    case cloudKit = "cloudkit"
    case notifications
    case analytics
    case importExport = "import-export"
    case authentication
    case fileSystem = "filesystem"
    case currency
    case ui
    case background
}

public enum LogSeverity: String, CaseIterable {
    case critical
    case error
    case warning
    case info
}

// MARK: - User-Friendly Error Presentation

@MainActor
public final class ErrorPresenter: ObservableObject {
    public static let shared = ErrorPresenter()

    @Published public var currentError: PresentableError?
    @Published public var isShowingError = false

    private init() {}

    /// Present an error to the user with appropriate messaging and recovery options
    public func presentError(
        _ error: Error,
        title: String? = nil,
        context: String? = nil,
        source: String = #function,
    ) {
        Task { @Sendable in
            let userContext: [String: String] = context.map { ["context": $0] } ?? [:]
            await ErrorLogger.shared.logError(
                error,
                category: .ui,
                source: source,
                userContext: userContext,
            )
        }

        let presentableError = createPresentableError(
            from: error,
            title: title,
            context: context,
        )

        currentError = presentableError
        isShowingError = true
    }

    /// Dismiss current error
    public func dismissError() {
        currentError = nil
        isShowingError = false
    }

    private func createPresentableError(
        from error: Error,
        title: String?,
        context: String?,
    ) -> PresentableError {
        // Use custom title or generate from error type
        let errorTitle = title ?? generateTitle(for: error)

        // Get user-friendly message
        let message = getUserFriendlyMessage(for: error, context: context)

        // Get recovery suggestions
        let recoverySuggestions = getRecoverySuggestions(for: error)

        // Determine severity for UI styling
        let severity = determineSeverity(for: error)

        return PresentableError(
            title: errorTitle,
            message: message,
            recoverySuggestions: recoverySuggestions,
            severity: severity,
            canRetry: canRetry(error),
            canReport: true,
        )
    }

    private func generateTitle(for error: Error) -> String {
        if error is NotificationServiceError {
            return "Notification Error"
        } else if error is AnalyticsServiceError {
            return "Analytics Error"
        } else if let serviceError = error as? ServiceError {
            switch serviceError {
            case .networkUnavailable, .timeout:
                return "Connection Problem"
            case .cloudKitUnavailable, .cloudKitQuotaExceeded:
                return "iCloud Error"
            case .unauthorized, .authenticationExpired:
                return "Authentication Required"
            case .diskFull, .fileAccessDenied:
                return "Storage Error"
            default:
                return "Service Error"
            }
        }

        return "Unexpected Error"
    }

    private func getUserFriendlyMessage(for error: Error, context: String?) -> String {
        var message = error.localizedDescription

        // Add context if available
        if let context {
            message = "\(message)\n\nContext: \(context)"
        }

        // Provide additional explanations for complex errors
        if let serviceError = error as? ServiceError {
            switch serviceError {
            case .networkUnavailable:
                message += "\n\nThis usually happens when your internet connection is unstable or unavailable."
            case .cloudKitQuotaExceeded:
                message += "\n\nYour iCloud storage is full. You may need to upgrade your iCloud plan or free up space."
            case .authenticationExpired:
                message += "\n\nYour session has expired. Please sign in again to continue."
            default:
                break
            }
        }

        return message
    }

    private func getRecoverySuggestions(for error: Error) -> [String] {
        var suggestions: [String] = []

        if let serviceError = error as? ServiceError {
            if let recoverySuggestion = serviceError.recoverySuggestion {
                suggestions.append(recoverySuggestion)
            }
        }

        if let localizedError = error as? LocalizedError {
            if let recoverySuggestion = localizedError.recoverySuggestion {
                suggestions.append(recoverySuggestion)
            }
        }

        // Add general suggestions based on error type
        if error is NotificationServiceError {
            suggestions.append("Check notification settings in Settings app")
        }

        if canRetry(error) {
            suggestions.append("Try the operation again")
        }

        return suggestions
    }

    private func canRetry(_ error: Error) -> Bool {
        if let serviceError = error as? ServiceError {
            return serviceError.isRetryable
        }

        return false
    }

    private func determineSeverity(for error: Error) -> ErrorSeverity {
        if let serviceError = error as? ServiceError {
            switch serviceError.priority {
            case .critical:
                return .critical
            case .high:
                return .error
            case .medium:
                return .warning
            case .low:
                return .info
            }
        }

        return .error
    }
}

// MARK: - Presentable Error Types

public struct PresentableError: Identifiable {
    public let id = UUID()
    public let title: String
    public let message: String
    public let recoverySuggestions: [String]
    public let severity: ErrorSeverity
    public let canRetry: Bool
    public let canReport: Bool
}

public enum ErrorSeverity {
    case critical
    case error
    case warning
    case info

    public var color: String {
        switch self {
        case .critical:
            "red"
        case .error:
            "red"
        case .warning:
            "orange"
        case .info:
            "blue"
        }
    }

    public var icon: String {
        switch self {
        case .critical:
            "exclamationmark.triangle.fill"
        case .error:
            "xmark.circle.fill"
        case .warning:
            "exclamationmark.triangle"
        case .info:
            "info.circle"
        }
    }
}

// MARK: - Convenience Extensions

extension Error {
    /// Log this error with optional context
    public func log(
        category: ErrorCategory = .general,
        source: String = #function,
        file: String = #file,
        line: Int = #line,
        context: [String: String] = [:],
    ) {
        let error = self
        let categoryValue = category
        let contextCopy = context
        Task { @Sendable in
            await ErrorLogger.shared.logError(
                error,
                category: categoryValue,
                source: source,
                file: file,
                line: line,
                userContext: contextCopy,
            )
        }
    }

    /// Present this error to the user
    @MainActor
    public func present(
        title: String? = nil,
        context: String? = nil,
        source: String = #function,
    ) {
        ErrorPresenter.shared.presentError(
            self,
            title: title,
            context: context,
            source: source,
        )
    }
}

//
// Layer: Features
// Module: Settings/Components/Types
// Purpose: Supporting types and enums for Settings Feature
//

import Foundation
import ComposableArchitecture

// MARK: - Settings Validation

public struct SettingsValidationStatus: Equatable, Sendable {
    public let issues: [SettingsIssue]

    public var isValid: Bool { issues.isEmpty }
    public var hasWarnings: Bool { !issues.filter { $0.severity == .warning }.isEmpty }
    public var hasErrors: Bool { !issues.filter { $0.severity == .error }.isEmpty }
    
    public init(issues: [SettingsIssue]) {
        self.issues = issues
    }
}

public struct SettingsIssue: Equatable, Sendable {
    public let type: IssueType
    public let severity: Severity
    public let message: String

    public enum IssueType: Equatable, Sendable {
        case notificationPermissionRequired
        case cloudBackupUnavailable
        case invalidCurrency
    }

    public enum Severity: Equatable, Sendable {
        case warning
        case error
    }
    
    public init(type: IssueType, severity: Severity, message: String) {
        self.type = type
        self.severity = severity
        self.message = message
    }
}

extension SettingsIssue {
    public static let notificationPermissionRequired = SettingsIssue(
        type: .notificationPermissionRequired,
        severity: .warning,
        message: "Notification permission required for alerts"
    )

    public static let cloudBackupUnavailable = SettingsIssue(
        type: .cloudBackupUnavailable,
        severity: .error,
        message: "iCloud backup is not available"
    )

    public static let invalidCurrency = SettingsIssue(
        type: .invalidCurrency,
        severity: .error,
        message: "Invalid currency selection"
    )
}

// MARK: - Constants

public enum CurrencyConstants {
    public static let supportedCurrencies = [
        "USD", "EUR", "GBP", "CAD", "AUD", "JPY", "CHF", "CNY", "INR", "KRW",
    ]
}

// MARK: - Enums

public enum AppTheme: String, CaseIterable, Equatable, Sendable {
    case light = "light"
    case dark = "dark" 
    case system = "system"
    
    public var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
}

// ExportFormat is imported from Foundation layer

public enum NotificationAuthStatus: Equatable, Sendable {
    case notDetermined
    case denied
    case authorized
}

public enum CloudBackupStatus: Equatable, Sendable {
    case notAvailable
    case available
    case syncing
    case error(String)
}
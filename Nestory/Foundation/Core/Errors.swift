// Layer: Foundation

import Foundation

public enum AppError: LocalizedError, Equatable {
    case validation(field: String, reason: String)
    case notFound(resource: String, id: String)
    case conflict(resource: String, reason: String)
    case unauthorized(reason: String)
    case networkError(underlying: String)
    case databaseError(operation: String, reason: String)
    case fileSystemError(path: String, reason: String)
    case parsingError(type: String, reason: String)
    case businessRule(rule: String, violation: String)
    case insufficientFunds(required: Money, available: Money)
    case invalidState(expected: String, actual: String)
    case migrationFailed(from: SchemaVersion, to: SchemaVersion, reason: String)

    public var errorDescription: String? {
        switch self {
        case let .validation(field, reason):
            "Validation failed for \(field): \(reason)"
        case let .notFound(resource, id):
            "\(resource) with ID \(id) not found"
        case let .conflict(resource, reason):
            "Conflict in \(resource): \(reason)"
        case let .unauthorized(reason):
            "Unauthorized: \(reason)"
        case let .networkError(underlying):
            "Network error: \(underlying)"
        case let .databaseError(operation, reason):
            "Database \(operation) failed: \(reason)"
        case let .fileSystemError(path, reason):
            "File system error at \(path): \(reason)"
        case let .parsingError(type, reason):
            "Failed to parse \(type): \(reason)"
        case let .businessRule(rule, violation):
            "Business rule '\(rule)' violated: \(violation)"
        case let .insufficientFunds(required, available):
            "Insufficient funds: required \(required), available \(available)"
        case let .invalidState(expected, actual):
            "Invalid state: expected \(expected), got \(actual)"
        case let .migrationFailed(from, to, reason):
            "Migration failed from \(from) to \(to): \(reason)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .validation:
            "Please check the input and try again"
        case .notFound:
            "Make sure the resource exists or create it first"
        case .conflict:
            "Resolve the conflict and retry the operation"
        case .unauthorized:
            "Please authenticate or check your permissions"
        case .networkError:
            "Check your internet connection and try again"
        case .databaseError:
            "Try again or contact support if the problem persists"
        case .fileSystemError:
            "Check file permissions and available storage"
        case .parsingError:
            "Verify the data format is correct"
        case .businessRule:
            "Review the business requirements and adjust accordingly"
        case .insufficientFunds:
            "Add more funds or reduce the amount"
        case .invalidState:
            "Reset to a valid state before proceeding"
        case .migrationFailed:
            "Restore from backup and contact support"
        }
    }
}

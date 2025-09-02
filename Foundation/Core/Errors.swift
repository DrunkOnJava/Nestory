// Layer: Foundation
// Module: Foundation/Core
// Purpose: Domain and infrastructure-neutral error enums

import Foundation

/// Core application errors that are domain-neutral
public enum AppError: Error, LocalizedError, Sendable {
    // MARK: - Validation Errors

    case validation(String)
    case invalidInput(String)
    case emptyField(String)
    case valueTooLarge(field: String, maxValue: String)
    case valueTooSmall(field: String, minValue: String)
    case invalidFormat(field: String, expectedFormat: String)

    // MARK: - Data Errors

    case notFound(String)
    case duplicateEntry(String)
    case dataCorruption(String)
    case migrationFailed(from: String, to: String)
    case parsingError(String)

    // MARK: - Business Logic Errors

    case businessRule(String)
    case insufficientFunds(required: Decimal, available: Decimal)
    case limitExceeded(limit: Int, attempted: Int)
    case operationNotAllowed(String)
    case invalidState(expected: String, actual: String)
    case conflict(String)

    // MARK: - System Errors

    case fileSystemError(String)
    case networkUnavailable
    case storageQuotaExceeded
    case memoryPressure

    // MARK: - Generic Errors

    case unknown(String)
    case wrapped(any Error, context: String)

    public var errorDescription: String? {
        switch self {
        case let .validation(message):
            "Validation error: \(message)"
        case let .invalidInput(message):
            "Invalid input: \(message)"
        case let .emptyField(field):
            "\(field) cannot be empty"
        case let .valueTooLarge(field, max):
            "\(field) exceeds maximum value of \(max)"
        case let .valueTooSmall(field, min):
            "\(field) is below minimum value of \(min)"
        case let .invalidFormat(field, format):
            "\(field) must be in format: \(format)"
        case let .notFound(resource):
            "\(resource) not found"
        case let .duplicateEntry(resource):
            "Duplicate \(resource) already exists"
        case let .dataCorruption(details):
            "Data corruption detected: \(details)"
        case let .migrationFailed(from, to):
            "Migration failed from \(from) to \(to)"
        case let .parsingError(message):
            "Parsing error: \(message)"
        case let .businessRule(message):
            "Business rule violation: \(message)"
        case let .insufficientFunds(required, available):
            "Insufficient funds: required \(required), available \(available)"
        case let .limitExceeded(limit, attempted):
            "Limit exceeded: max \(limit), attempted \(attempted)"
        case let .operationNotAllowed(reason):
            "Operation not allowed: \(reason)"
        case let .invalidState(expected, actual):
            "Invalid state: expected \(expected), got \(actual)"
        case let .conflict(message):
            "Conflict: \(message)"
        case let .fileSystemError(message):
            "File system error: \(message)"
        case .networkUnavailable:
            "Network connection unavailable"
        case .storageQuotaExceeded:
            "Storage quota exceeded"
        case .memoryPressure:
            "Memory pressure detected"
        case let .unknown(message):
            "Unknown error: \(message)"
        case let .wrapped(error, context):
            "\(context): \(error.localizedDescription)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .validation:
            "Please check your input and try again"
        case .invalidInput:
            "Please check your input and try again"
        case .emptyField:
            "Please fill in all required fields"
        case .valueTooLarge, .valueTooSmall:
            "Please enter a value within the allowed range"
        case .invalidFormat:
            "Please check the format and try again"
        case .notFound:
            "Please verify the item exists"
        case .duplicateEntry:
            "Please use a different identifier"
        case .dataCorruption:
            "Please restore from backup or contact support"
        case .migrationFailed:
            "Please restore from backup and try again"
        case .parsingError:
            "Please check the data format and try again"
        case .businessRule:
            "Please review the business rules and try again"
        case .insufficientFunds:
            "Please add funds or reduce the amount"
        case .limitExceeded:
            "Please reduce the quantity or upgrade your plan"
        case .operationNotAllowed:
            "Please check your permissions"
        case .invalidState:
            "Please refresh and try again"
        case .conflict:
            "Please resolve the conflict and try again"
        case .fileSystemError:
            "Please check available storage space"
        case .networkUnavailable:
            "Please check your internet connection"
        case .storageQuotaExceeded:
            "Please free up space or upgrade storage"
        case .memoryPressure:
            "Please close other apps and try again"
        case .unknown, .wrapped:
            "Please try again or contact support"
        }
    }
}

/// Result type alias for cleaner API signatures
public typealias AppResult<T> = Result<T, AppError>

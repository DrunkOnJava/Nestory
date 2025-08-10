// Layer: Foundation
// Module: Foundation/Core
// Purpose: Domain and infrastructure-neutral error enums

import Foundation

/// Core application errors that are domain-neutral
public enum AppError: LocalizedError {
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
        case .validation(let message):
            return "Validation error: \(message)"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .emptyField(let field):
            return "\(field) cannot be empty"
        case .valueTooLarge(let field, let max):
            return "\(field) exceeds maximum value of \(max)"
        case .valueTooSmall(let field, let min):
            return "\(field) is below minimum value of \(min)"
        case .invalidFormat(let field, let format):
            return "\(field) must be in format: \(format)"
            
        case .notFound(let resource):
            return "\(resource) not found"
        case .duplicateEntry(let resource):
            return "Duplicate \(resource) already exists"
        case .dataCorruption(let details):
            return "Data corruption detected: \(details)"
        case .migrationFailed(let from, let to):
            return "Migration failed from \(from) to \(to)"
        case .parsingError(let message):
            return "Parsing error: \(message)"
            
        case .businessRule(let message):
            return "Business rule violation: \(message)"
        case .insufficientFunds(let required, let available):
            return "Insufficient funds: required \(required), available \(available)"
        case .limitExceeded(let limit, let attempted):
            return "Limit exceeded: max \(limit), attempted \(attempted)"
        case .operationNotAllowed(let reason):
            return "Operation not allowed: \(reason)"
        case .invalidState(let expected, let actual):
            return "Invalid state: expected \(expected), got \(actual)"
        case .conflict(let message):
            return "Conflict: \(message)"
            
        case .fileSystemError(let message):
            return "File system error: \(message)"
        case .networkUnavailable:
            return "Network connection unavailable"
        case .storageQuotaExceeded:
            return "Storage quota exceeded"
        case .memoryPressure:
            return "Memory pressure detected"
            
        case .unknown(let message):
            return "Unknown error: \(message)"
        case .wrapped(let error, let context):
            return "\(context): \(error.localizedDescription)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .validation:
            return "Please check your input and try again"
        case .invalidInput:
            return "Please check your input and try again"
        case .emptyField:
            return "Please fill in all required fields"
        case .valueTooLarge, .valueTooSmall:
            return "Please enter a value within the allowed range"
        case .invalidFormat:
            return "Please check the format and try again"
            
        case .notFound:
            return "Please verify the item exists"
        case .duplicateEntry:
            return "Please use a different identifier"
        case .dataCorruption:
            return "Please restore from backup or contact support"
        case .migrationFailed:
            return "Please restore from backup and try again"
        case .parsingError:
            return "Please check the data format and try again"
            
        case .businessRule:
            return "Please review the business rules and try again"
        case .insufficientFunds:
            return "Please add funds or reduce the amount"
        case .limitExceeded:
            return "Please reduce the quantity or upgrade your plan"
        case .operationNotAllowed:
            return "Please check your permissions"
        case .invalidState:
            return "Please refresh and try again"
        case .conflict:
            return "Please resolve the conflict and try again"
            
        case .fileSystemError:
            return "Please check available storage space"
        case .networkUnavailable:
            return "Please check your internet connection"
        case .storageQuotaExceeded:
            return "Please free up space or upgrade storage"
        case .memoryPressure:
            return "Please close other apps and try again"
            
        case .unknown, .wrapped:
            return "Please try again or contact support"
        }
    }
}

/// Result type alias for cleaner API signatures
public typealias AppResult<T> = Result<T, AppError>

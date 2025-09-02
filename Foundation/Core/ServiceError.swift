//
// Layer: Foundation
// Module: Foundation/Core
// Purpose: Comprehensive service error types with recovery strategies
//

import Foundation

// Note: CloudKit-specific error handling moved to Infrastructure layer
// Foundation layer cannot import CloudKit

/// Comprehensive service errors with standardized recovery strategies
public enum ServiceError: Error, LocalizedError, Equatable, Sendable {
    // MARK: - Network Errors

    case networkUnavailable
    case timeout
    case rateLimited(retryAfter: TimeInterval)
    case serverError(statusCode: Int)
    case invalidResponse
    case requestCancelled

    // MARK: - Authentication/Authorization Errors

    case unauthorized
    case forbidden
    case authenticationExpired
    case permissionDenied(resource: String)

    // MARK: - Data Errors

    case notFound(resource: String)
    case dataCorruption(details: String)
    case validationFailed(field: String, reason: String)
    case duplicateEntry(resource: String)
    case conflictingData(details: String)

    // MARK: - Service-Specific Errors

    case serviceUnavailable(service: String)
    case quotaExceeded(service: String, limit: String)
    case featureNotSupported(feature: String)
    case configurationError(service: String, details: String)

    // MARK: - CloudKit Errors

    case cloudKitUnavailable
    case cloudKitQuotaExceeded
    case cloudKitSyncConflict(details: String)
    case cloudKitPartialFailure(successCount: Int, failures: [String])
    case cloudKitAccountChanged

    // MARK: - File System Errors

    case fileNotFound(path: String)
    case fileAccessDenied(path: String)
    case diskFull
    case fileCorrupted(path: String)

    // MARK: - Processing Errors

    case processingFailed(operation: String, reason: String)
    case invalidInput(field: String, value: String)
    case operationCancelled(operation: String)

    // MARK: - System Errors

    case insufficientMemory
    case systemResourceUnavailable(resource: String)
    case backgroundTaskExpired

    // MARK: - Unknown/Wrapped Errors

    case unknown(underlying: String)
    case wrapped(error: any Error, context: String)

    // MARK: - LocalizedError Implementation

    public var errorDescription: String? {
        switch self {
        // Network Errors
        case .networkUnavailable:
            "Network connection is not available"
        case .timeout:
            "Request timed out"
        case let .rateLimited(retryAfter):
            "Rate limit exceeded. Try again in \(Int(retryAfter)) seconds"
        case let .serverError(statusCode):
            "Server error occurred (Code: \(statusCode))"
        case .invalidResponse:
            "Received invalid response from server"
        case .requestCancelled:
            "Request was cancelled"
        // Authentication/Authorization Errors
        case .unauthorized:
            "Authentication required"
        case .forbidden:
            "Access denied"
        case .authenticationExpired:
            "Authentication has expired"
        case let .permissionDenied(resource):
            "Permission denied for \(resource)"
        // Data Errors
        case let .notFound(resource):
            "\(resource) not found"
        case let .dataCorruption(details):
            "Data corruption detected: \(details)"
        case let .validationFailed(field, reason):
            "\(field): \(reason)"
        case let .duplicateEntry(resource):
            "\(resource) already exists"
        case let .conflictingData(details):
            "Data conflict: \(details)"
        // Service-Specific Errors
        case let .serviceUnavailable(service):
            "\(service) is temporarily unavailable"
        case let .quotaExceeded(service, limit):
            "\(service) quota exceeded (\(limit))"
        case let .featureNotSupported(feature):
            "\(feature) is not supported on this device"
        case let .configurationError(service, details):
            "\(service) configuration error: \(details)"
        // CloudKit Errors
        case .cloudKitUnavailable:
            "iCloud is not available"
        case .cloudKitQuotaExceeded:
            "iCloud storage quota exceeded"
        case let .cloudKitSyncConflict(details):
            "iCloud sync conflict: \(details)"
        case let .cloudKitPartialFailure(successCount, failures):
            "Partially completed: \(successCount) succeeded, \(failures.count) failed"
        case .cloudKitAccountChanged:
            "iCloud account has changed"
        // File System Errors
        case let .fileNotFound(path):
            "File not found: \(path)"
        case let .fileAccessDenied(path):
            "Access denied to file: \(path)"
        case .diskFull:
            "Insufficient storage space"
        case let .fileCorrupted(path):
            "File is corrupted: \(path)"
        // Processing Errors
        case let .processingFailed(operation, reason):
            "\(operation) failed: \(reason)"
        case let .invalidInput(field, value):
            "Invalid \(field): \(value)"
        case let .operationCancelled(operation):
            "\(operation) was cancelled"
        // System Errors
        case .insufficientMemory:
            "Insufficient memory to complete operation"
        case let .systemResourceUnavailable(resource):
            "\(resource) is not available"
        case .backgroundTaskExpired:
            "Background task expired"
        // Unknown/Wrapped Errors
        case let .unknown(underlying):
            "Unknown error: \(underlying)"
        case let .wrapped(error, context):
            "\(context): \(error.localizedDescription)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        // Network Errors
        case .networkUnavailable:
            "Check your internet connection and try again"
        case .timeout:
            "Check your connection speed and try again"
        case .rateLimited:
            "Please wait before trying again"
        case .serverError:
            "Try again later. If the problem persists, contact support"
        case .invalidResponse:
            "Try again or contact support if the problem continues"
        case .requestCancelled:
            "Retry the operation if needed"
        // Authentication/Authorization Errors
        case .unauthorized:
            "Please sign in and try again"
        case .forbidden:
            "Contact an administrator for access"
        case .authenticationExpired:
            "Please sign in again"
        case .permissionDenied:
            "Check your permissions or contact support"
        // Data Errors
        case .notFound:
            "Refresh the list and try again"
        case .dataCorruption:
            "Restore from backup or contact support"
        case .validationFailed:
            "Please correct the input and try again"
        case .duplicateEntry:
            "Use a different name or identifier"
        case .conflictingData:
            "Refresh and resolve the conflict manually"
        // Service-Specific Errors
        case .serviceUnavailable:
            "Try again later"
        case .quotaExceeded:
            "Upgrade your plan or reduce usage"
        case .featureNotSupported:
            "Update your device or app to access this feature"
        case .configurationError:
            "Contact support for configuration assistance"
        // CloudKit Errors
        case .cloudKitUnavailable:
            "Check your iCloud settings and internet connection"
        case .cloudKitQuotaExceeded:
            "Free up iCloud storage or upgrade your plan"
        case .cloudKitSyncConflict:
            "The conflict will be resolved automatically on next sync"
        case .cloudKitPartialFailure:
            "Some items failed to sync. Try again to complete"
        case .cloudKitAccountChanged:
            "Sign in to iCloud and try again"
        // File System Errors
        case .fileNotFound:
            "Check if the file exists and try again"
        case .fileAccessDenied:
            "Check file permissions"
        case .diskFull:
            "Free up storage space and try again"
        case .fileCorrupted:
            "Restore from backup or recreate the file"
        // Processing Errors
        case .processingFailed:
            "Try again or contact support"
        case .invalidInput:
            "Check your input and try again"
        case .operationCancelled:
            "Restart the operation if needed"
        // System Errors
        case .insufficientMemory:
            "Close other apps and try again"
        case .systemResourceUnavailable:
            "Restart the app or device"
        case .backgroundTaskExpired:
            "Complete the operation while the app is active"
        // Unknown/Wrapped Errors
        case .unknown, .wrapped:
            "Try again or contact support"
        }
    }

    /// Indicates if this error is potentially recoverable through retry
    public var isRetryable: Bool {
        switch self {
        case .networkUnavailable, .timeout, .serverError, .serviceUnavailable, .cloudKitUnavailable:
            true
        case .rateLimited, .quotaExceeded, .cloudKitQuotaExceeded, .diskFull:
            false // Require user action
        case .unauthorized, .forbidden, .authenticationExpired, .permissionDenied:
            false // Require user intervention
        case .notFound, .validationFailed, .duplicateEntry, .invalidInput:
            false // Require data changes
        case .cloudKitSyncConflict, .cloudKitPartialFailure:
            true // Can retry after conflict resolution
        case .processingFailed, .systemResourceUnavailable:
            true
        case .requestCancelled, .operationCancelled:
            false // User-initiated cancellation
        case .insufficientMemory, .backgroundTaskExpired:
            true // May resolve automatically
        default:
            false
        }
    }

    /// Suggested retry delay in seconds
    public var retryDelay: TimeInterval {
        switch self {
        case let .rateLimited(retryAfter):
            retryAfter
        case .networkUnavailable, .timeout:
            2.0
        case .serverError, .serviceUnavailable:
            5.0
        case .cloudKitUnavailable, .systemResourceUnavailable:
            10.0
        case .cloudKitSyncConflict, .cloudKitPartialFailure:
            1.0
        case .processingFailed:
            3.0
        case .insufficientMemory:
            5.0
        default:
            0.0
        }
    }

    /// Priority level for error reporting and logging
    public var priority: ErrorPriority {
        switch self {
        case .dataCorruption, .fileCorrupted, .cloudKitAccountChanged:
            .critical
        case .unauthorized, .forbidden, .quotaExceeded, .cloudKitQuotaExceeded, .diskFull:
            .high
        case .networkUnavailable, .timeout, .serverError, .serviceUnavailable:
            .medium
        case .requestCancelled, .operationCancelled, .rateLimited:
            .low
        default:
            .medium
        }
    }
}

// MARK: - Supporting Types

public enum ErrorPriority: String, CaseIterable {
    case critical
    case high
    case medium
    case low
}

// MARK: - Equatable Implementation

extension ServiceError {
    public static func == (lhs: ServiceError, rhs: ServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.networkUnavailable, .networkUnavailable),
             (.timeout, .timeout),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.authenticationExpired, .authenticationExpired),
             (.invalidResponse, .invalidResponse),
             (.requestCancelled, .requestCancelled),
             (.cloudKitUnavailable, .cloudKitUnavailable),
             (.cloudKitQuotaExceeded, .cloudKitQuotaExceeded),
             (.cloudKitAccountChanged, .cloudKitAccountChanged),
             (.diskFull, .diskFull),
             (.insufficientMemory, .insufficientMemory),
             (.backgroundTaskExpired, .backgroundTaskExpired):
            true
        case let (.rateLimited(lhsDelay), .rateLimited(rhsDelay)):
            lhsDelay == rhsDelay
        case let (.serverError(lhsCode), .serverError(rhsCode)):
            lhsCode == rhsCode
        case let (.permissionDenied(lhsResource), .permissionDenied(rhsResource)):
            lhsResource == rhsResource
        case let (.notFound(lhsResource), .notFound(rhsResource)):
            lhsResource == rhsResource
        case let (.dataCorruption(lhsDetails), .dataCorruption(rhsDetails)):
            lhsDetails == rhsDetails
        case let (.validationFailed(lhsField, lhsReason), .validationFailed(rhsField, rhsReason)):
            lhsField == rhsField && lhsReason == rhsReason
        case let (.duplicateEntry(lhsResource), .duplicateEntry(rhsResource)):
            lhsResource == rhsResource
        case let (.conflictingData(lhsDetails), .conflictingData(rhsDetails)):
            lhsDetails == rhsDetails
        case let (.serviceUnavailable(lhsService), .serviceUnavailable(rhsService)):
            lhsService == rhsService
        case let (.quotaExceeded(lhsService, lhsLimit), .quotaExceeded(rhsService, rhsLimit)):
            lhsService == rhsService && lhsLimit == rhsLimit
        case let (.featureNotSupported(lhsFeature), .featureNotSupported(rhsFeature)):
            lhsFeature == rhsFeature
        case let (.configurationError(lhsService, lhsDetails), .configurationError(rhsService, rhsDetails)):
            lhsService == rhsService && lhsDetails == rhsDetails
        case let (.cloudKitSyncConflict(lhsDetails), .cloudKitSyncConflict(rhsDetails)):
            lhsDetails == rhsDetails
        case let (.cloudKitPartialFailure(lhsSuccess, lhsFailures), .cloudKitPartialFailure(rhsSuccess, rhsFailures)):
            lhsSuccess == rhsSuccess && lhsFailures == rhsFailures
        case let (.fileNotFound(lhsPath), .fileNotFound(rhsPath)):
            lhsPath == rhsPath
        case let (.fileAccessDenied(lhsPath), .fileAccessDenied(rhsPath)):
            lhsPath == rhsPath
        case let (.fileCorrupted(lhsPath), .fileCorrupted(rhsPath)):
            lhsPath == rhsPath
        case let (.processingFailed(lhsOp, lhsReason), .processingFailed(rhsOp, rhsReason)):
            lhsOp == rhsOp && lhsReason == rhsReason
        case let (.invalidInput(lhsField, lhsValue), .invalidInput(rhsField, rhsValue)):
            lhsField == rhsField && lhsValue == rhsValue
        case let (.operationCancelled(lhsOp), .operationCancelled(rhsOp)):
            lhsOp == rhsOp
        case let (.systemResourceUnavailable(lhsResource), .systemResourceUnavailable(rhsResource)):
            lhsResource == rhsResource
        case let (.unknown(lhsUnderlying), .unknown(rhsUnderlying)):
            lhsUnderlying == rhsUnderlying
        case let (.wrapped(_, lhsContext), .wrapped(_, rhsContext)):
            lhsContext == rhsContext
        default:
            false
        }
    }
}

// MARK: - Convenience Factory Methods

extension ServiceError {
    // Note: CloudKit-specific error conversion moved to Infrastructure layer

    /// Create a ServiceError from a URL/network error
    public static func fromNetworkError(_ error: any Error) -> ServiceError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkUnavailable
            case .timedOut:
                return .timeout
            case .cancelled:
                return .requestCancelled
            default:
                return .wrapped(error: urlError, context: "Network")
            }
        }
        return .wrapped(error: error, context: "Network")
    }

    /// Create a ServiceError from a file system error
    public static func fromFileSystemError(_ error: any Error, path: String = "") -> ServiceError {
        if let nsError = error as NSError? {
            switch nsError.code {
            case NSFileReadNoSuchFileError:
                return .fileNotFound(path: path)
            case NSFileReadNoPermissionError, NSFileWriteNoPermissionError:
                return .fileAccessDenied(path: path)
            case NSFileWriteOutOfSpaceError:
                return .diskFull
            default:
                return .wrapped(error: error, context: "FileSystem")
            }
        }
        return .wrapped(error: error, context: "FileSystem")
    }

    /// Create a ServiceError from a CloudKit error
    /// Since Foundation layer cannot import CloudKit, this accepts any Error and maps common patterns
    public static func fromCloudKitError(_ error: any Error) -> ServiceError {
        let nsError = error as NSError
        
        // Map common CloudKit error codes (without importing CloudKit)
        switch nsError.code {
        case 1: // CKErrorInternalError
            return .wrapped(error: error, context: "CloudKit")
        case 2: // CKErrorPartialFailure
            return .cloudKitPartialFailure(successCount: 0, failures: [nsError.localizedDescription])
        case 3: // CKErrorNetworkUnavailable
            return .cloudKitUnavailable
        case 4: // CKErrorNetworkFailure
            return .networkUnavailable
        case 6: // CKErrorUnknownItem
            return .notFound(resource: "CloudKit record")
        case 7: // CKErrorInvalidArguments
            return .invalidInput(field: "CloudKit parameter", value: nsError.localizedDescription)
        case 9: // CKErrorPermissionFailure
            return .permissionDenied(resource: "CloudKit")
        case 11: // CKErrorNotAuthenticated
            return .unauthorized
        case 25: // CKErrorQuotaExceeded
            return .cloudKitQuotaExceeded
        case 26: // CKErrorZoneBusy
            return .serviceUnavailable(service: "CloudKit")
        case 34: // CKErrorAccountTemporarilyUnavailable
            return .cloudKitUnavailable
        case 35: // CKErrorServiceUnavailable
            return .cloudKitUnavailable
        case 36: // CKErrorRequestRateLimited
            return .rateLimited(retryAfter: 60.0)
        case 14: // CKErrorServerRecordChanged - Key conflict resolution case
            // Extract conflict details from error userInfo if available
            let serverRecord = nsError.userInfo["CKRecordChangedErrorServerRecordKey"] as? String ?? "unknown"
            let clientRecord = nsError.userInfo["CKRecordChangedErrorClientRecordKey"] as? String ?? "unknown"
            let conflictDetails = "Server: \(serverRecord), Client: \(clientRecord)"
            return .cloudKitSyncConflict(details: conflictDetails)
        case 15: // CKErrorAssetFileNotFound
            return .notFound(resource: "CloudKit asset")
        case 16: // CKErrorAssetFileModified
            return .cloudKitSyncConflict(details: "Asset file modified during upload")
        case 21: // CKErrorChangeTokenExpired
            return .cloudKitSyncConflict(details: "Change token expired, full resync required")
        case 22: // CKErrorBatchRequestFailed
            return .cloudKitPartialFailure(successCount: 0, failures: ["Batch operation failed"])
        default:
            // Check for specific CloudKit error domain patterns
            if nsError.domain.contains("CKError") {
                if nsError.localizedDescription.lowercased().contains("quota") {
                    return .cloudKitQuotaExceeded
                } else if nsError.localizedDescription.lowercased().contains("network") {
                    return .cloudKitUnavailable
                } else if nsError.localizedDescription.lowercased().contains("account") {
                    return .cloudKitAccountChanged
                } else if nsError.localizedDescription.lowercased().contains("conflict") || 
                         nsError.localizedDescription.lowercased().contains("changed") {
                    return .cloudKitSyncConflict(details: nsError.localizedDescription)
                } else {
                    return .wrapped(error: error, context: "CloudKit")
                }
            }
            return .wrapped(error: error, context: "CloudKit")
        }
    }
}

/// Result type alias for service operations
public typealias ServiceResult<T> = Result<T, ServiceError>

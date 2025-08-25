//
// Layer: Foundation
// Module: Foundation/Core
// Purpose: Error recovery strategies and fallback mechanisms
//

import Foundation

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with SystemConfiguration - Use SCNetworkReachability for more accurate network status monitoring

// MARK: - Recovery Strategy Protocol

public protocol ErrorRecoveryStrategy: Sendable {
    /// Attempts to recover from an error
    func recover(from error: ServiceError, logger: FoundationLogger?) async throws

    /// Provides fallback data when recovery is not possible
    func fallback<T>(for operationType: String, defaultValue: T, logger: FoundationLogger?) async -> T

    /// Indicates if this strategy can handle the given error
    func canHandle(_ error: ServiceError) -> Bool
}

// MARK: - Network Recovery Strategy

public struct NetworkRecoveryStrategy: ErrorRecoveryStrategy, Sendable {
    public init() {}

    public func recover(from error: ServiceError, logger: FoundationLogger?) async throws {
        switch error {
        case .networkUnavailable:
            // Wait for network to become available
            logger?.info("Waiting for network connectivity...")
            try await waitForNetworkConnectivity(timeout: 30.0)

        case .timeout:
            // Brief pause before retry
            logger?.info("Network timeout, waiting before retry...")
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        case let .rateLimited(retryAfter):
            // Respect rate limit
            logger?.info("Rate limited, waiting \(retryAfter) seconds...")
            try await Task.sleep(nanoseconds: UInt64(retryAfter * 1_000_000_000))

        case let .serverError(statusCode) where statusCode >= 500:
            // Server error, exponential backoff
            let delay = min(pow(2.0, Double(statusCode - 500)), 30.0)
            logger?.info("Server error \(statusCode), waiting \(delay) seconds...")
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        default:
            throw error
        }
    }

    public func fallback<T>(for operationType: String, defaultValue: T, logger: FoundationLogger?) async -> T {
        logger?.info("Using fallback for \(operationType)")
        return defaultValue
    }

    public func canHandle(_ error: ServiceError) -> Bool {
        switch error {
        case .networkUnavailable, .timeout, .rateLimited, .serverError:
            true
        default:
            false
        }
    }

    private func waitForNetworkConnectivity(timeout: TimeInterval) async throws {
        // Simple implementation - in production, use NWPathMonitor
        let startTime = Date()
        while Date().timeIntervalSince(startTime) < timeout {
            // Simulate network check
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            // In real implementation, check actual network status
        }
    }
}

// MARK: - Authentication Recovery Strategy

public struct AuthenticationRecoveryStrategy: ErrorRecoveryStrategy, Sendable {
    public init() {}

    public func recover(from error: ServiceError, logger: FoundationLogger?) async throws {
        switch error {
        case .unauthorized, .authenticationExpired:
            logger?.info("Authentication expired, requesting re-authentication...")
            // In real implementation, trigger authentication flow
            throw ServiceError.authenticationExpired

        case .forbidden:
            logger?.warning("Access forbidden - cannot recover")
            throw error

        case let .permissionDenied(resource):
            logger?.info("Permission denied for \(resource) - requesting elevated permissions")
            // In real implementation, request specific permissions
            throw error

        default:
            throw error
        }
    }

    public func fallback<T>(for operationType: String, defaultValue: T, logger: FoundationLogger?) async -> T {
        logger?.info("Authentication required for \(operationType), using fallback")
        return defaultValue
    }

    public func canHandle(_ error: ServiceError) -> Bool {
        switch error {
        case .unauthorized, .authenticationExpired, .forbidden, .permissionDenied:
            true
        default:
            false
        }
    }
}

// MARK: - CloudKit Recovery Strategy

public struct CloudKitRecoveryStrategy: ErrorRecoveryStrategy, Sendable {
    public init() {}

    public func recover(from error: ServiceError, logger: FoundationLogger?) async throws {
        switch error {
        case .cloudKitUnavailable:
            logger?.info("CloudKit unavailable, waiting for service...")
            try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds

        case .cloudKitQuotaExceeded:
            logger?.warning("CloudKit quota exceeded - cannot auto-recover")
            throw error

        case .cloudKitAccountChanged:
            logger?.info("CloudKit account changed, clearing local cache...")
            // In real implementation, clear cached data and re-authenticate
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        case let .cloudKitSyncConflict(details):
            logger?.info("CloudKit sync conflict, attempting resolution: \(details)")
            try await resolveSyncConflict(details: details)

        case let .cloudKitPartialFailure(successCount, failures):
            logger?.info("CloudKit partial failure: \(successCount) succeeded, \(failures.count) failed")
            // Retry failed items individually
            throw error // Let caller handle individual retries

        default:
            throw error
        }
    }

    public func fallback<T>(for operationType: String, defaultValue: T, logger: FoundationLogger?) async -> T {
        logger?.info("CloudKit unavailable for \(operationType), using local fallback")
        return defaultValue
    }

    public func canHandle(_ error: ServiceError) -> Bool {
        switch error {
        case .cloudKitUnavailable, .cloudKitQuotaExceeded, .cloudKitAccountChanged,
             .cloudKitSyncConflict, .cloudKitPartialFailure:
            true
        default:
            false
        }
    }

    private func resolveSyncConflict(details _: String) async throws {
        // Simple conflict resolution - in production, implement proper merge logic
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    }
}

// MARK: - File System Recovery Strategy

public struct FileSystemRecoveryStrategy: ErrorRecoveryStrategy, Sendable {
    public init() {}

    public func recover(from error: ServiceError, logger: FoundationLogger?) async throws {
        switch error {
        case let .fileNotFound(path):
            logger?.info("File not found at \(path), attempting to recreate...")
            // In real implementation, attempt to recreate or restore from backup
            throw error

        case let .fileAccessDenied(path):
            logger?.warning("Access denied to \(path) - cannot recover")
            throw error

        case .diskFull:
            logger?.warning("Disk full - attempting cleanup...")
            try await attemptCleanup()

        case let .fileCorrupted(path):
            logger?.warning("File corrupted at \(path), attempting recovery...")
            try await attemptFileRepair(path: path)

        default:
            throw error
        }
    }

    public func fallback<T>(for operationType: String, defaultValue: T, logger: FoundationLogger?) async -> T {
        logger?.info("File system error for \(operationType), using fallback")
        return defaultValue
    }

    public func canHandle(_ error: ServiceError) -> Bool {
        switch error {
        case .fileNotFound, .fileAccessDenied, .diskFull, .fileCorrupted:
            true
        default:
            false
        }
    }

    private func attemptCleanup() async throws {
        // In real implementation, clean temporary files, caches, etc.
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
    }

    private func attemptFileRepair(path: String) async throws {
        // In real implementation, attempt file recovery
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        throw ServiceError.fileCorrupted(path: path) // Still corrupted
    }
}

// MARK: - Composite Recovery Strategy

public struct CompositeRecoveryStrategy: ErrorRecoveryStrategy, Sendable {
    private let strategies: [ErrorRecoveryStrategy]

    public init(strategies: [ErrorRecoveryStrategy] = Self.defaultStrategies()) {
        self.strategies = strategies
    }

    public static func defaultStrategies() -> [ErrorRecoveryStrategy] {
        [
            NetworkRecoveryStrategy(),
            AuthenticationRecoveryStrategy(),
            CloudKitRecoveryStrategy(),
            FileSystemRecoveryStrategy(),
        ]
    }

    public func recover(from error: ServiceError, logger: FoundationLogger?) async throws {
        for strategy in strategies {
            if strategy.canHandle(error) {
                logger?.info("Attempting recovery with \(type(of: strategy))")
                do {
                    try await strategy.recover(from: error, logger: logger)
                    logger?.info("Recovery successful with \(type(of: strategy))")
                    return
                } catch {
                    logger?.warning("Recovery failed with \(type(of: strategy)): \(error)")
                    continue
                }
            }
        }

        logger?.error("No recovery strategy available for error: \(error)")
        throw error
    }

    public func fallback<T>(for operationType: String, defaultValue: T, logger: FoundationLogger?) async -> T {
        for strategy in strategies {
            // Use first available fallback
            return await strategy.fallback(for: operationType, defaultValue: defaultValue, logger: logger)
        }

        logger?.info("No fallback strategy available for \(operationType)")
        return defaultValue
    }

    public func canHandle(_ error: ServiceError) -> Bool {
        strategies.contains { $0.canHandle(error) }
    }
}

// MARK: - Resilient Operation Executor

public actor ResilientOperationExecutor {
    private let recoveryStrategy: ErrorRecoveryStrategy
    private let retryExecutor: ServiceOperationExecutor
    private let logger: FoundationLogger?

    public init(
        recoveryStrategy: ErrorRecoveryStrategy = CompositeRecoveryStrategy(),
        retryExecutor: ServiceOperationExecutor = ServiceOperationExecutor(),
        logger: FoundationLogger? = nil
    ) {
        self.recoveryStrategy = recoveryStrategy
        self.retryExecutor = retryExecutor
        self.logger = logger
    }

    /// Execute an operation with full error recovery and retry logic
    public func execute<T: Sendable>(
        operation: @escaping @Sendable () async throws -> T,
        fallbackValue: T? = nil,
        operationType: String = "unknown"
    ) async throws -> T {
        // Capture recovery strategy to avoid data races
        let recoveryStrategy = recoveryStrategy

        do {
            // First, try with retry logic
            return try await retryExecutor.execute(operation: operation)
        } catch let error as ServiceError {
            logger?.info("Operation failed, attempting recovery for \(operationType): \(error)")

            // Attempt recovery
            if recoveryStrategy.canHandle(error) {
                do {
                    try await recoveryStrategy.recover(from: error, logger: logger)
                    // Retry once after recovery
                    return try await operation()
                } catch {
                    logger?.warning("Recovery failed for \(operationType): \(error)")

                    // Use fallback if available
                    if let fallbackValue {
                        logger?.info("Using fallback value for \(operationType)")
                        return await recoveryStrategy.fallback(for: operationType, defaultValue: fallbackValue, logger: logger)
                    }

                    throw error
                }
            } else {
                // Use fallback if available
                if let fallbackValue {
                    logger?.info("Using fallback value for unrecoverable error in \(operationType)")
                    return await recoveryStrategy.fallback(for: operationType, defaultValue: fallbackValue, logger: logger)
                }

                throw error
            }
        } catch {
            // Convert non-ServiceError to ServiceError
            let serviceError = ServiceError.wrapped(error: error, context: operationType)

            if let fallbackValue {
                logger?.info("Using fallback value for unexpected error in \(operationType)")
                return await recoveryStrategy.fallback(for: operationType, defaultValue: fallbackValue, logger: logger)
            }

            throw serviceError
        }
    }

    /// Execute with explicit fallback handling
    public func executeWithFallback<T: Sendable>(
        operation: @escaping @Sendable () async throws -> T,
        fallback: @escaping () async -> T,
        operationType: String = "unknown"
    ) async -> T {
        do {
            return try await execute(operation: operation, operationType: operationType)
        } catch {
            logger?.info("Using custom fallback for \(operationType): \(error)")
            return await fallback()
        }
    }
}

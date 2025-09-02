//
// Layer: Foundation
// Module: Foundation/Core
// Purpose: Retry mechanisms with exponential backoff and circuit breaker patterns
//

import Foundation

// MARK: - Retry Strategy Protocol

public protocol RetryStrategy: Sendable {
    /// Executes an operation with retry logic
    func execute<T: Sendable>(
        operation: @escaping @Sendable () async throws -> T,
        shouldRetry: @escaping @Sendable (any Error) -> Bool,
        logger: (any FoundationLogger)?
    ) async throws -> T

    /// Maximum number of retry attempts
    var maxRetries: Int { get }

    /// Base delay between retries
    var baseDelay: TimeInterval { get }
}

// MARK: - Exponential Backoff Retry Strategy

public struct ExponentialBackoffRetry: RetryStrategy, Sendable {
    public let maxRetries: Int
    public let baseDelay: TimeInterval
    public let maxDelay: TimeInterval
    public let jitterFactor: Double

    public init(
        maxRetries: Int = 3,
        baseDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 30.0,
        jitterFactor: Double = 0.1
    ) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.jitterFactor = jitterFactor
    }

    public func execute<T: Sendable>(
        operation: @escaping @Sendable () async throws -> T,
        shouldRetry: @escaping @Sendable (any Error) -> Bool = { _ in true },
        logger: (any FoundationLogger)? = nil
    ) async throws -> T {
        var lastError: (any Error)?

        for attempt in 0 ... maxRetries {
            do {
                let result = try await operation()
                if attempt > 0 {
                    logger?.info("Operation succeeded on attempt \(attempt + 1)")
                }
                return result
            } catch {
                lastError = error

                // Don't retry on the last attempt
                if attempt == maxRetries {
                    logger?.error("Operation failed after \(maxRetries + 1) attempts: \(error)")
                    break
                }

                // Check if we should retry this error
                if !shouldRetry(error) {
                    logger?.info("Error is not retryable: \(error)")
                    throw error
                }

                let delay = calculateDelay(for: attempt)
                logger?.info("Operation failed on attempt \(attempt + 1), retrying in \(delay)s: \(error)")

                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }

        throw lastError ?? ServiceError.unknown(underlying: "Retry strategy failed")
    }

    private func calculateDelay(for attempt: Int) -> TimeInterval {
        let exponentialDelay = baseDelay * pow(2.0, Double(attempt))
        let cappedDelay = min(exponentialDelay, maxDelay)

        // Add jitter to prevent thundering herd
        let jitter = Double.random(in: -jitterFactor ... jitterFactor) * cappedDelay
        return max(0, cappedDelay + jitter)
    }
}

// MARK: - Linear Backoff Retry Strategy

public struct LinearBackoffRetry: RetryStrategy, Sendable {
    public let maxRetries: Int
    public let baseDelay: TimeInterval

    public init(maxRetries: Int = 3, baseDelay: TimeInterval = 2.0) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
    }

    public func execute<T: Sendable>(
        operation: @escaping @Sendable () async throws -> T,
        shouldRetry: @escaping @Sendable (any Error) -> Bool = { _ in true },
        logger: (any FoundationLogger)? = nil
    ) async throws -> T {
        var lastError: (any Error)?

        for attempt in 0 ... maxRetries {
            do {
                let result = try await operation()
                if attempt > 0 {
                    logger?.info("Operation succeeded on attempt \(attempt + 1)")
                }
                return result
            } catch {
                lastError = error

                if attempt == maxRetries {
                    logger?.error("Operation failed after \(maxRetries + 1) attempts: \(error)")
                    break
                }

                if !shouldRetry(error) {
                    logger?.info("Error is not retryable: \(error)")
                    throw error
                }

                let delay = baseDelay * Double(attempt + 1)
                logger?.info("Operation failed on attempt \(attempt + 1), retrying in \(delay)s: \(error)")

                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }

        throw lastError ?? ServiceError.unknown(underlying: "Linear retry strategy failed")
    }
}

// MARK: - Circuit Breaker

public actor CircuitBreaker {
    public enum State: String, CaseIterable, Sendable {
        case closed
        case open
        case halfOpen = "half-open"
    }

    private let failureThreshold: Int
    private let recoveryTimeout: TimeInterval
    private let successThreshold: Int

    private var failureCount = 0
    private var successCount = 0
    private var lastFailureTime: Date?
    private var state: State = .closed
    private let logger: (any FoundationLogger)?

    public init(
        failureThreshold: Int = 5,
        recoveryTimeout: TimeInterval = 60.0,
        successThreshold: Int = 2,
        logger: (any FoundationLogger)? = nil
    ) {
        self.failureThreshold = failureThreshold
        self.recoveryTimeout = recoveryTimeout
        self.successThreshold = successThreshold
        self.logger = logger
    }

    public func execute<T: Sendable>(
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await checkState()

        do {
            let result = try await operation()
            recordSuccess()
            return result
        } catch {
            recordFailure()
            throw error
        }
    }

    public var currentState: State {
        state
    }

    public var metrics: CircuitBreakerMetrics {
        CircuitBreakerMetrics(
            state: state,
            failureCount: failureCount,
            successCount: successCount,
            lastFailureTime: lastFailureTime,
        )
    }

    private func checkState() async throws {
        switch state {
        case .closed:
            // Allow operation
            break

        case .open:
            // Check if recovery timeout has passed
            if let lastFailure = lastFailureTime,
               Date().timeIntervalSince(lastFailure) >= recoveryTimeout
            {
                logger?.info("Circuit breaker transitioning to half-open")
                state = .halfOpen
                successCount = 0
            } else {
                logger?.warning("Circuit breaker is open, rejecting request")
                throw ServiceError.serviceUnavailable(service: "CircuitBreaker")
            }

        case .halfOpen:
            // Allow limited operations
            break
        }
    }

    private func recordSuccess() {
        successCount += 1

        switch state {
        case .closed:
            // Reset failure count on success
            failureCount = 0

        case .halfOpen:
            if self.successCount >= successThreshold {
                logger?.info("Circuit breaker transitioning to closed after \(self.successCount) successes")
                state = .closed
                self.failureCount = 0
                self.successCount = 0
            }

        case .open:
            // Should not happen, but reset if it does
            state = .closed
            failureCount = 0
            successCount = 0
        }
    }

    private func recordFailure() {
        failureCount += 1
        lastFailureTime = Date()

        switch state {
        case .closed:
            if self.failureCount >= failureThreshold {
                logger?.warning("Circuit breaker opening after \(self.failureCount) failures")
                state = .open
            }

        case .halfOpen:
            logger?.warning("Circuit breaker reopening due to failure in half-open state")
            state = .open

        case .open:
            // Already open, just update timestamp
            break
        }
    }

    public func reset() {
        logger?.info("Circuit breaker manually reset")
        state = .closed
        failureCount = 0
        successCount = 0
        lastFailureTime = nil
    }
}

// MARK: - Circuit Breaker Metrics

public struct CircuitBreakerMetrics: Sendable {
    public let state: CircuitBreaker.State
    public let failureCount: Int
    public let successCount: Int
    public let lastFailureTime: Date?

    public init(
        state: CircuitBreaker.State,
        failureCount: Int,
        successCount: Int,
        lastFailureTime: Date?
    ) {
        self.state = state
        self.failureCount = failureCount
        self.successCount = successCount
        self.lastFailureTime = lastFailureTime
    }
}

// MARK: - Service Operation Executor

public actor ServiceOperationExecutor {
    private let retryStrategy: any RetryStrategy
    private let circuitBreaker: CircuitBreaker?
    private let logger: (any FoundationLogger)?

    public init(
        retryStrategy: any RetryStrategy = ExponentialBackoffRetry(),
        enableCircuitBreaker: Bool = true,
        logger: (any FoundationLogger)? = nil
    ) {
        self.retryStrategy = retryStrategy
        self.logger = logger
        circuitBreaker = enableCircuitBreaker ? CircuitBreaker(logger: logger) : nil
    }

    /// Execute an operation with retry and circuit breaker protection
    public func execute<T: Sendable>(
        operation: @escaping @Sendable () async throws -> T,
        shouldRetry: @escaping @Sendable (any Error) -> Bool = { error in
            if let serviceError = error as? ServiceError {
                return serviceError.isRetryable
            }
            return false
        }
    ) async throws -> T {
        // Capture retryStrategy to avoid data race in Sendable context
        let retryStrategyCapture = retryStrategy

        let wrappedOperation: @Sendable () async throws -> T = { [weak circuitBreaker] in
            if let circuitBreaker {
                return try await circuitBreaker.execute(operation: operation)
            } else {
                return try await operation()
            }
        }

        return try await retryStrategyCapture.execute(
            operation: wrappedOperation,
            shouldRetry: shouldRetry,
            logger: logger
        )
    }

    /// Execute an operation with custom retry logic
    public func execute<T: Sendable>(
        operation: @escaping @Sendable () async throws -> T,
        maxRetries: Int,
        shouldRetry: @escaping @Sendable (any Error) -> Bool = { error in
            if let serviceError = error as? ServiceError {
                return serviceError.isRetryable
            }
            return false
        }
    ) async throws -> T {
        let customRetry = ExponentialBackoffRetry(maxRetries: maxRetries)

        let wrappedOperation: @Sendable () async throws -> T = { [weak circuitBreaker] in
            if let circuitBreaker {
                return try await circuitBreaker.execute(operation: operation)
            } else {
                return try await operation()
            }
        }

        return try await customRetry.execute(
            operation: wrappedOperation,
            shouldRetry: shouldRetry,
            logger: logger
        )
    }

    /// Get circuit breaker metrics
    public var circuitBreakerMetrics: CircuitBreakerMetrics? {
        get async {
            await circuitBreaker?.metrics
        }
    }

    /// Reset circuit breaker
    public func resetCircuitBreaker() async {
        await circuitBreaker?.reset()
    }
}

// MARK: - Convenience Functions

/// Execute an operation with default retry strategy
public func performWithRetry<T: Sendable>(
    operation: @escaping @Sendable () async throws -> T,
    maxRetries: Int = 3,
    logger: (any FoundationLogger)? = nil,
    shouldRetry: @escaping @Sendable (any Error) -> Bool = { error in
        if let serviceError = error as? ServiceError {
            return serviceError.isRetryable
        }
        return false
    }
) async throws -> T {
    let retryStrategy = ExponentialBackoffRetry(maxRetries: maxRetries)
    return try await retryStrategy.execute(operation: operation, shouldRetry: shouldRetry, logger: logger)
}

/// Execute an operation with circuit breaker protection
public func performWithCircuitBreaker<T: Sendable>(
    operation: @escaping @Sendable () async throws -> T,
    circuitBreaker: CircuitBreaker
) async throws -> T {
    try await circuitBreaker.execute(operation: operation)
}

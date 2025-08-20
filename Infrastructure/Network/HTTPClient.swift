// Layer: Infrastructure

import Foundation
import Network
import os.log

public final class HTTPClient: @unchecked Sendable {
    private let session: URLSession
    private let baseURL: URL
    // Circuit breaker temporarily disabled for compilation - TODO: Integrate with actor-based CircuitBreaker
    // private let circuitBreaker: CircuitBreaker
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev").network.monitor")
    private var isNetworkAvailable = true
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "HTTPClient")

    public init(baseURL: URL, configuration: URLSessionConfiguration = .default) {
        self.baseURL = baseURL
        session = URLSession(configuration: configuration)
        // circuitBreaker = CircuitBreaker()

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            isNetworkAvailable = path.status == .satisfied
        }
        monitor.start(queue: monitorQueue)
    }

    deinit {
        monitor.cancel()
    }

    public func request<T: Decodable>(
        _ endpoint: Endpoint,
        responseType _: T.Type,
        retryConfig: RetryConfig = .default
    ) async throws -> T {
        let data = try await requestData(endpoint, retryConfig: retryConfig)

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }

    public func requestData(
        _ endpoint: Endpoint,
        retryConfig: RetryConfig = .default,
    ) async throws -> Data {
        guard isNetworkAvailable else {
            throw NetworkError.networkUnavailable
        }

        // Temporary: circuit breaker disabled for compilation
        // guard circuitBreaker.canExecute() else {
        //     throw NetworkError.circuitBreakerOpen
        // }

        let request = try endpoint.urlRequest(baseURL: baseURL)

        return try await withRetry(config: retryConfig) {
            try await self.performRequest(request)
        }
    }

    private func performRequest(_ request: URLRequest) async throws -> Data {
        let startTime = CFAbsoluteTimeGetCurrent()

        do {
            let (data, response) = try await session.data(for: request)
            let duration = CFAbsoluteTimeGetCurrent() - startTime

            logger.debug("Request completed in \(duration, format: .fixed(precision: 3))s")

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }

            if (200 ..< 300).contains(httpResponse.statusCode) {
                // circuitBreaker.recordSuccess()
                return data
            } else {
                // circuitBreaker.recordFailure()
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                // circuitBreaker.recordFailure()
                throw NetworkError.timeout
            } else if (error as NSError).code == NSURLErrorCancelled {
                throw NetworkError.cancelled
            } else {
                // circuitBreaker.recordFailure()
                throw NetworkError.underlying(error.localizedDescription)
            }
        }
    }

    private func withRetry<T>(
        config: RetryConfig,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        for attempt in 0 ..< config.maxAttempts {
            do {
                return try await operation()
            } catch let error as NetworkError {
                if !error.isRetryable || attempt == config.maxAttempts - 1 {
                    throw error
                }

                let delay = config.delay(for: attempt)
                logger.debug("Retry attempt \(attempt + 1) after \(delay)s")

                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            } catch {
                throw error
            }
        }

        throw NetworkError.tooManyRetries(attempts: config.maxAttempts)
    }
}

public struct RetryConfig: Sendable {
    public let maxAttempts: Int
    public let baseDelay: TimeInterval
    public let maxDelay: TimeInterval
    public let jitterRange: ClosedRange<Double>

    public init(
        maxAttempts: Int = 3,
        baseDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 30.0,
        jitterRange: ClosedRange<Double> = 0.8 ... 1.2
    ) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.jitterRange = jitterRange
    }

    public static let `default` = RetryConfig()

    public static let aggressive = RetryConfig(
        maxAttempts: 5,
        baseDelay: 0.5,
        maxDelay: 60.0,
    )

    public static let none = RetryConfig(maxAttempts: 1)

    func delay(for attempt: Int) -> TimeInterval {
        let exponentialDelay = baseDelay * pow(2.0, Double(attempt))
        let clampedDelay = min(exponentialDelay, maxDelay)
        let jitter = Double.random(in: jitterRange)
        return clampedDelay * jitter
    }
}

// CircuitBreaker functionality now uses the centralized implementation from RetryStrategy.swift

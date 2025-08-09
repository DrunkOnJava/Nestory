// Layer: Infrastructure

import Foundation
import Network
import os.log

public final class HTTPClient {
    private let session: URLSession
    private let baseURL: URL
    private let circuitBreaker: CircuitBreaker
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.nestory.network.monitor")
    private var isNetworkAvailable = true
    private let logger = Logger(subsystem: "com.nestory", category: "HTTPClient")

    public init(baseURL: URL, configuration: URLSessionConfiguration = .default) {
        self.baseURL = baseURL
        session = URLSession(configuration: configuration)
        circuitBreaker = CircuitBreaker()

        monitor.pathUpdateHandler = { [weak self] path in
            self?.isNetworkAvailable = path.status == .satisfied
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
        retryConfig: RetryConfig = .default
    ) async throws -> Data {
        guard isNetworkAvailable else {
            throw NetworkError.networkUnavailable
        }

        guard circuitBreaker.canExecute() else {
            throw NetworkError.circuitBreakerOpen
        }

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
                circuitBreaker.recordSuccess()
                return data
            } else {
                circuitBreaker.recordFailure()
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                circuitBreaker.recordFailure()
                throw NetworkError.timeout
            } else if (error as NSError).code == NSURLErrorCancelled {
                throw NetworkError.cancelled
            } else {
                circuitBreaker.recordFailure()
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

public struct RetryConfig {
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
        maxDelay: 60.0
    )

    public static let none = RetryConfig(maxAttempts: 1)

    func delay(for attempt: Int) -> TimeInterval {
        let exponentialDelay = baseDelay * pow(2.0, Double(attempt))
        let clampedDelay = min(exponentialDelay, maxDelay)
        let jitter = Double.random(in: jitterRange)
        return clampedDelay * jitter
    }
}

final class CircuitBreaker {
    private let queue = DispatchQueue(label: "com.nestory.circuit-breaker")
    private var state: State = .closed
    private var failureCount = 0
    private var lastFailureTime: Date?
    private var successCount = 0

    private let failureThreshold = 5
    private let successThreshold = 2
    private let timeout: TimeInterval = 60

    enum State {
        case closed
        case open
        case halfOpen
    }

    func canExecute() -> Bool {
        queue.sync {
            switch state {
            case .closed:
                return true
            case .open:
                if let lastFailure = lastFailureTime,
                   Date().timeIntervalSince(lastFailure) > timeout
                {
                    state = .halfOpen
                    return true
                }
                return false
            case .halfOpen:
                return true
            }
        }
    }

    func recordSuccess() {
        queue.sync {
            switch state {
            case .closed:
                failureCount = 0
            case .halfOpen:
                successCount += 1
                if successCount >= successThreshold {
                    state = .closed
                    failureCount = 0
                    successCount = 0
                }
            case .open:
                break
            }
        }
    }

    func recordFailure() {
        queue.sync {
            lastFailureTime = Date()

            switch state {
            case .closed:
                failureCount += 1
                if failureCount >= failureThreshold {
                    state = .open
                }
            case .halfOpen:
                state = .open
                successCount = 0
            case .open:
                break
            }
        }
    }
}

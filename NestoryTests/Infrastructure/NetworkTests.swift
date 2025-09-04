@testable import Nestory
import XCTest

enum NetworkTestError: Error {
    case networkFailure
    case timeout
    case invalidData
}

@MainActor
final class NetworkTests: XCTestCase {
    func testEndpointConstruction() {
        let endpoint = Endpoint(
            method: .get,
            path: "/api/items",
            query: ["page": "1", "limit": "10"],
            headers: ["Authorization": "Bearer token"],
        )

        XCTAssertEqual(endpoint.method, .get)
        XCTAssertEqual(endpoint.path, "/api/items")
        XCTAssertEqual(endpoint.query["page"], "1")
        XCTAssertEqual(endpoint.headers["Authorization"], "Bearer token")
    }

    func testEndpointURLRequestCreation() throws {
        let baseURL = URL(string: "https://api.example.com")!
        let endpoint = Endpoint(
            method: .post,
            path: "/items",
            query: ["category": "electronics"],
            headers: ["Content-Type": "application/json"],
            body: "test".data(using: .utf8),
        )

        let request = try endpoint.urlRequest(baseURL: baseURL)

        XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/items?category=electronics")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNotNil(request.httpBody)
    }

    func testNetworkErrorDescriptions() {
        let errors: [NetworkError] = [
            .invalidURL(path: "/test"),
            .noData,
            .networkUnavailable,
            .timeout,
            .circuitBreakerOpen,
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertNotNil(error.recoverySuggestion)
        }
    }

    func testNetworkErrorRetryability() {
        XCTAssertTrue(NetworkError.timeout.isRetryable)
        XCTAssertTrue(NetworkError.networkUnavailable.isRetryable)
        XCTAssertTrue(NetworkError.httpError(statusCode: 503, data: nil).isRetryable)
        XCTAssertFalse(NetworkError.httpError(statusCode: 400, data: nil).isRetryable)
        XCTAssertFalse(NetworkError.cancelled.isRetryable)
        XCTAssertFalse(NetworkError.circuitBreakerOpen.isRetryable)
    }

    func testRetryConfigDelayCalculation() {
        let config = RetryConfig(
            maxAttempts: 3,
            baseDelay: 1.0,
            maxDelay: 10.0,
            jitterRange: 1.0 ... 1.0,
        )

        XCTAssertEqual(config.delay(for: 0), 1.0)
        XCTAssertEqual(config.delay(for: 1), 2.0)
        XCTAssertEqual(config.delay(for: 2), 4.0)
        XCTAssertEqual(config.delay(for: 3), 8.0)
        XCTAssertEqual(config.delay(for: 10), 10.0)
    }

    func testCircuitBreakerStateTransitions() async {
        let circuitBreaker = CircuitBreaker(failureThreshold: 5, recoveryTimeout: 1.0)

        // Initial state should be closed
        let initialState = await circuitBreaker.currentState
        XCTAssertEqual(initialState, .closed)

        // Simulate failures to open the circuit
        for _ in 0 ..< 5 {
            do {
                _ = try await circuitBreaker.execute {
                    throw NetworkTestError.networkFailure
                }
            } catch {
                // Expected to fail
            }
        }

        // After 5 failures, circuit should be open
        let openState = await circuitBreaker.currentState
        XCTAssertEqual(openState, .open)

        // Wait for recovery timeout
        try? await Task.sleep(nanoseconds: 1_100_000_000) // 1.1 seconds

        // Circuit should transition to half-open on next attempt
        do {
            _ = try await circuitBreaker.execute {
                return "success"
            }
        } catch {
            XCTFail("Should not fail after recovery timeout")
        }

        // After successful execution, circuit should be closed again
        let finalState = await circuitBreaker.currentState
        XCTAssertEqual(finalState, .closed)
    }

    func testHTTPClientInitialization() {
        let baseURL = URL(string: "https://api.example.com")!
        let client = HTTPClient(baseURL: baseURL)

        XCTAssertNotNil(client)
    }

    func testEndpointConvenienceMethods() {
        let getEndpoint = Endpoint.get("/items", query: ["page": "1"])
        XCTAssertEqual(getEndpoint.method, .get)
        XCTAssertEqual(getEndpoint.path, "/items")

        let postEndpoint = Endpoint.post("/items", body: Data())
        XCTAssertEqual(postEndpoint.method, .post)

        let putEndpoint = Endpoint.put("/items/1", body: Data())
        XCTAssertEqual(putEndpoint.method, .put)

        let patchEndpoint = Endpoint.patch("/items/1", body: Data())
        XCTAssertEqual(patchEndpoint.method, .patch)

        let deleteEndpoint = Endpoint.delete("/items/1")
        XCTAssertEqual(deleteEndpoint.method, .delete)
    }
}

@MainActor
final class HTTPClientPerformanceTests: XCTestCase {
    func testRetryDelayPerformance() {
        let config = RetryConfig()

        measure {
            for i in 0 ..< 1000 {
                _ = config.delay(for: i % 10)
            }
        }
    }

    func testCircuitBreakerPerformance() async {
        let circuitBreaker = CircuitBreaker(failureThreshold: 10)

        measure {
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                for _ in 0 ..< 1000 { // Reduced count for async operations
                    do {
                        _ = try await circuitBreaker.execute {
                            if Bool.random() {
                                return "success"
                            } else {
                                throw NetworkTestError.networkFailure
                            }
                        }
                    } catch {
                        // Expected failures for performance testing
                    }
                }
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
}

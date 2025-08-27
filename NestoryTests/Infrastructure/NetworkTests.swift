@testable import Nestory
import XCTest

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

    func testCircuitBreakerStateTransitions() async throws {
        let circuitBreaker = CircuitBreaker()

        // Test initial closed state
        XCTAssertEqual(await circuitBreaker.currentState, .closed)

        // Test that successful operations work
        let result = try await circuitBreaker.execute {
            return "success"
        }
        XCTAssertEqual(result, "success")

        // Test circuit breaker metrics
        let metrics = await circuitBreaker.metrics
        XCTAssertEqual(metrics.state, .closed)
        XCTAssertEqual(metrics.failureCount, 0)
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

final class HTTPClientPerformanceTests: XCTestCase {
    func testRetryDelayPerformance() {
        let config = RetryConfig()

        measure {
            for i in 0 ..< 1000 {
                _ = config.delay(for: i % 10)
            }
        }
    }

    func testCircuitBreakerPerformance() {
        let circuitBreaker = CircuitBreaker()

        measure {
            for _ in 0 ..< 10000 {
                _ = circuitBreaker.canExecute()
                if Bool.random() {
                    circuitBreaker.recordSuccess()
                } else {
                    circuitBreaker.recordFailure()
                }
            }
        }
    }
}

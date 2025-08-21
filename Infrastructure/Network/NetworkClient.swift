// Layer: Infrastructure
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with URLSession - Use URLSessionDataTask and URLSessionDownloadTask for better HTTP/2, connection pooling, and background downloading
// Module: Infrastructure/Network
// Purpose: Generic network client with retry logic and error handling

import Foundation

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with URLSession - Already using URLSession but could leverage newer async/await APIs and URLSessionWebSocketTask

/// Network client for API communication
public actor NetworkClient {
    // MARK: - Properties

    private let session: URLSession
    private let baseURL: URL?
    private let defaultHeaders: [String: String]
    private let timeout: TimeInterval
    private let maxRetries: Int

    // MARK: - Initialization

    public init(
        baseURL: URL? = nil,
        headers: [String: String] = [:],
        timeout: TimeInterval = 30,
        maxRetries: Int = 3
    ) {
        self.baseURL = baseURL
        defaultHeaders = headers
        self.timeout = timeout
        self.maxRetries = maxRetries

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout * 2
        configuration.waitsForConnectivity = true
        configuration.httpAdditionalHeaders = headers

        session = URLSession(configuration: configuration)
        // APPLE_FRAMEWORK_OPPORTUNITY: Replace with URLSession - Consider using URLSessionDelegate for more advanced connection management
    }

    // MARK: - Public Methods

    /// Execute GET request
    public func get<T: Decodable>(
        _ path: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        let request = try buildRequest(
            path: path,
            method: .get,
            parameters: parameters,
            headers: headers,
        )
        return try await execute(request)
    }

    /// Execute POST request
    public func post<T: Decodable>(
        _ path: String,
        body: some Encodable,
        headers: [String: String]? = nil
    ) async throws -> T {
        let request = try buildRequest(
            path: path,
            method: .post,
            body: body,
            headers: headers,
        )
        return try await execute(request)
    }

    /// Execute PUT request
    public func put<T: Decodable>(
        _ path: String,
        body: some Encodable,
        headers: [String: String]? = nil
    ) async throws -> T {
        let request = try buildRequest(
            path: path,
            method: .put,
            body: body,
            headers: headers,
        )
        return try await execute(request)
    }

    /// Execute DELETE request
    public func delete(
        _ path: String,
        headers: [String: String]? = nil,
    ) async throws {
        let request = try buildRequest(
            path: path,
            method: .delete,
            headers: headers,
        )
        let _: EmptyResponse = try await execute(request)
    }

    /// Download file
    public func download(
        _ path: String,
        to destination: URL,
        headers: [String: String]? = nil,
        progress _: ((Double) -> Void)? = nil,
    ) async throws -> URL {
        let request = try buildRequest(
            path: path,
            method: .get,
            headers: headers,
        )

        let (tempURL, response) = try await session.download(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: nil)
        }

        // Move file to destination
        try FileManager.default.moveItem(at: tempURL, to: destination)

        return destination
    }

    /// Upload file
    public func upload<T: Decodable>(
        _ path: String,
        file: URL,
        headers: [String: String]? = nil,
        progress _: ((Double) -> Void)? = nil
    ) async throws -> T {
        let request = try buildRequest(
            path: path,
            method: .post,
            headers: headers,
        )

        let (data, response) = try await session.upload(for: request, fromFile: file)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - Private Methods

    private func buildRequest(
        path: String,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        body: (any Encodable)? = nil,
        headers: [String: String]? = nil,
    ) throws -> URLRequest {
        // Build URL
        let url: URL
        if let baseURL {
            url = baseURL.appendingPathComponent(path)
        } else if let pathURL = URL(string: path) {
            url = pathURL
        } else {
            throw NetworkError.invalidURL(path: path)
        }

        // Add query parameters for GET requests
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if method == .get, let parameters {
            urlComponents?.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }

        guard let finalURL = urlComponents?.url else {
            throw NetworkError.invalidURL(path: path)
        }

        // Create request
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue

        // Add headers
        var allHeaders = defaultHeaders
        if let headers {
            allHeaders.merge(headers) { _, new in new }
        }

        for (key, value) in allHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Add body
        if let body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } else if method == .post || method == .put, let parameters {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }

    private func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        var lastError: (any Error)?

        for attempt in 0 ..< maxRetries {
            do {
                // Add retry delay if not first attempt
                if attempt > 0 {
                    let delay = Double(attempt) * 2.0 // Exponential backoff
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }

                let (data, response) = try await session.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                // Check for rate limiting
                if httpResponse.statusCode == 429 {
                    if let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After"),
                       let seconds = Double(retryAfter)
                    {
                        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                        continue
                    }
                }

                guard (200 ... 299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode >= 500 {
                        // Server error, retry
                        lastError = NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
                        continue
                    }
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
                }

                // Decode response
                if T.self == EmptyResponse.self {
                    guard let emptyResponse = EmptyResponse() as? T else {
                        throw NetworkError.decodingError("Failed to cast EmptyResponse")
                    }
                    return emptyResponse
                }

                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    throw NetworkError.decodingError(error.localizedDescription)
                }
            } catch {
                lastError = error

                // Don't retry for client errors
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case let .httpError(statusCode, _) where statusCode < 500:
                        throw error
                    default:
                        break
                    }
                }
            }
        }

        throw lastError ?? NetworkError.unknown
    }
}

// MARK: - Supporting Types

// HTTPMethod is defined in Endpoint.swift

// NetworkError is defined in NetworkError.swift

/// Empty response for requests with no body
struct EmptyResponse: Codable {}

// MARK: - Request Builder

/// Fluent API for building requests
public struct RequestBuilder {
    private var path: String
    private var method: HTTPMethod = .get
    private var parameters: [String: Any]?
    private var headers: [String: String]?
    private var body: (any Encodable)?

    public init(_ path: String) {
        self.path = path
    }

    public func method(_ method: HTTPMethod) -> RequestBuilder {
        var builder = self
        builder.method = method
        return builder
    }

    public func parameters(_ parameters: [String: Any]) -> RequestBuilder {
        var builder = self
        builder.parameters = parameters
        return builder
    }

    public func headers(_ headers: [String: String]) -> RequestBuilder {
        var builder = self
        builder.headers = headers
        return builder
    }

    public func body(_ body: any Encodable) -> RequestBuilder {
        var builder = self
        builder.body = body
        return builder
    }

    public func build(baseURL: URL?) throws -> URLRequest {
        let url: URL
        if let baseURL {
            url = baseURL.appendingPathComponent(path)
        } else if let pathURL = URL(string: path) {
            url = pathURL
        } else {
            throw NetworkError.invalidURL(path: path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}

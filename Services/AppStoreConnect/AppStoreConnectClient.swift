//
// Layer: Services
// Module: AppStoreConnect
// Purpose: Main client for App Store Connect API interactions
//

import CryptoKit
import Foundation

/// App Store Connect API client with JWT authentication
@MainActor
public final class AppStoreConnectClient: ObservableObject {
    // MARK: - Types

    public struct Configuration {
        let keyID: String
        let issuerID: String
        let privateKey: String
        let baseURL: URL

        public init(
            keyID: String,
            issuerID: String,
            privateKey: String,
            baseURL: URL = URL(string: "https://api.appstoreconnect.apple.com")!
        ) {
            self.keyID = keyID
            self.issuerID = issuerID
            self.privateKey = privateKey
            self.baseURL = baseURL
        }
    }

    public enum APIError: LocalizedError {
        case invalidConfiguration
        case authenticationFailed(String)
        case networkError(Error)
        case decodingError(Error)
        case apiError(statusCode: Int, message: String)
        case rateLimitExceeded(retryAfter: TimeInterval?)
        case invalidResponse

        public var errorDescription: String? {
            switch self {
            case .invalidConfiguration:
                return "Invalid API configuration"
            case let .authenticationFailed(message):
                return "Authentication failed: \(message)"
            case let .networkError(error):
                return "Network error: \(error.localizedDescription)"
            case let .decodingError(error):
                return "Failed to decode response: \(error.localizedDescription)"
            case let .apiError(code, message):
                return "API error \(code): \(message)"
            case let .rateLimitExceeded(retryAfter):
                if let retryAfter {
                    return "Rate limit exceeded. Retry after \(Int(retryAfter)) seconds"
                }
                return "Rate limit exceeded"
            case .invalidResponse:
                return "Invalid API response"
            }
        }
    }

    // MARK: - Properties

    private let configuration: Configuration
    private let session: URLSession
    private var currentToken: String?
    private var tokenExpiration: Date?

    // MARK: - Initialization

    public init(configuration: Configuration) {
        self.configuration = configuration

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30
        sessionConfig.timeoutIntervalForResource = 60
        sessionConfig.requestCachePolicy = .reloadIgnoringLocalCacheData

        session = URLSession(configuration: sessionConfig)
    }

    // MARK: - Authentication

    /// Generate JWT token for API authentication
    private func generateToken() throws -> String {
        // Check if current token is still valid
        if let token = currentToken,
           let expiration = tokenExpiration,
           expiration > Date().addingTimeInterval(60)
        { // 1 minute buffer
            return token
        }

        // Create JWT header
        let header = [
            "alg": "ES256",
            "kid": configuration.keyID,
            "typ": "JWT",
        ]

        // Create JWT payload
        let now = Date()
        let expiration = now.addingTimeInterval(20 * 60) // 20 minutes (max allowed)
        let payload: [String: Any] = [
            "iss": configuration.issuerID,
            "iat": Int(now.timeIntervalSince1970),
            "exp": Int(expiration.timeIntervalSince1970),
            "aud": "appstoreconnect-v1",
        ]

        // Encode header and payload
        let headerData = try JSONSerialization.data(withJSONObject: header)
        let payloadData = try JSONSerialization.data(withJSONObject: payload)

        let headerBase64 = headerData.base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")

        let payloadBase64 = payloadData.base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")

        let message = "\(headerBase64).\(payloadBase64)"

        // Sign with private key
        guard let privateKeyData = Data(base64Encoded: configuration.privateKey) else {
            throw APIError.invalidConfiguration
        }

        let privateKey = try P256.Signing.PrivateKey(rawRepresentation: privateKeyData)
        let signature = try privateKey.signature(for: Data(message.utf8))

        let signatureBase64 = signature.rawRepresentation.base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")

        let token = "\(message).\(signatureBase64)"

        // Cache token
        currentToken = token
        tokenExpiration = expiration

        return token
    }

    // MARK: - Request Execution

    /// Execute an authenticated API request
    public func execute<T: Decodable>(
        _ request: APIRequest,
        responseType _: T.Type
    ) async throws -> T {
        let token = try generateToken()

        var urlRequest = URLRequest(url: configuration.baseURL.appendingPathComponent(request.path))
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add query parameters
        if !request.queryParameters.isEmpty {
            var components = URLComponents(url: urlRequest.url!, resolvingAgainstBaseURL: false)!
            components.queryItems = request.queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
            urlRequest.url = components.url
        }

        // Add body if present
        if let body = request.body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }

        // Execute request with retry logic
        let maxRetries = 3
        var lastError: Error?

        for attempt in 0 ..< maxRetries {
            do {
                let (data, response) = try await session.data(for: urlRequest)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }

                // Handle rate limiting
                if httpResponse.statusCode == 429 {
                    let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                        .flatMap { TimeInterval($0) }
                    throw APIError.rateLimitExceeded(retryAfter: retryAfter)
                }

                // Handle errors
                if httpResponse.statusCode >= 400 {
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        let message = errorResponse.errors.first?.detail ?? "Unknown error"
                        throw APIError.apiError(statusCode: httpResponse.statusCode, message: message)
                    } else {
                        throw APIError.apiError(statusCode: httpResponse.statusCode, message: "Request failed")
                    }
                }

                // Decode successful response
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }

            } catch let error as APIError {
                // Don't retry for certain errors
                if case .invalidConfiguration = error { throw error }
                if case .authenticationFailed = error { throw error }
                lastError = error

                // Exponential backoff for retries
                if attempt < maxRetries - 1 {
                    let delay = pow(2.0, Double(attempt)) * 1.0
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            } catch {
                lastError = APIError.networkError(error)

                // Exponential backoff for retries
                if attempt < maxRetries - 1 {
                    let delay = pow(2.0, Double(attempt)) * 1.0
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }

        throw lastError ?? APIError.invalidResponse
    }
}

// MARK: - Supporting Types

public struct APIRequest {
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    let path: String
    let method: Method
    let queryParameters: [String: String]
    let body: Encodable?

    public init(
        path: String,
        method: Method = .get,
        queryParameters: [String: String] = [:],
        body: Encodable? = nil
    ) {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.body = body
    }
}

struct ErrorResponse: Decodable {
    let errors: [APIErrorDetail]
}

struct APIErrorDetail: Decodable {
    let status: String
    let code: String
    let title: String
    let detail: String
}

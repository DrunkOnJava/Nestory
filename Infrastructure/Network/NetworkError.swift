// Layer: Infrastructure

import Foundation

public enum NetworkError: LocalizedError, Equatable, Sendable {
    case invalidURL(path: String)
    case noData
    case decodingError(String)
    case httpError(statusCode: Int, data: Data?)
    case networkUnavailable
    case timeout
    case cancelled
    case circuitBreakerOpen
    case tooManyRetries(attempts: Int)
    case underlying(String)
    case invalidResponse
    case unknown

    public var errorDescription: String? {
        switch self {
        case let .invalidURL(path):
            "Invalid URL for path: \(path)"
        case .noData:
            "No data received from server"
        case let .decodingError(message):
            "Failed to decode response: \(message)"
        case let .httpError(statusCode, _):
            "HTTP error with status code: \(statusCode)"
        case .networkUnavailable:
            "Network connection unavailable"
        case .timeout:
            "Request timed out"
        case .cancelled:
            "Request was cancelled"
        case .circuitBreakerOpen:
            "Circuit breaker is open, service temporarily unavailable"
        case let .tooManyRetries(attempts):
            "Request failed after \(attempts) retry attempts"
        case let .underlying(message):
            "Network error: \(message)"
        case .invalidResponse:
            "Invalid response from server"
        case .unknown:
            "An unknown error occurred"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .invalidURL:
            "Check the URL configuration"
        case .noData:
            "Try again later"
        case .decodingError:
            "Contact support if the problem persists"
        case let .httpError(statusCode, _):
            statusCode >= 500 ? "Server error, try again later" : "Check your request"
        case .networkUnavailable:
            "Check your internet connection"
        case .timeout:
            "Check your connection and try again"
        case .cancelled:
            "Request was cancelled by user"
        case .circuitBreakerOpen:
            "Service will be available again shortly"
        case .tooManyRetries:
            "Check your connection or try again later"
        case .underlying:
            "Try again or contact support"
        case .invalidResponse:
            "Try again later"
        case .unknown:
            "Try again or contact support"
        }
    }

    public var isRetryable: Bool {
        switch self {
        case let .httpError(statusCode, _):
            statusCode >= 500 || statusCode == 429
        case .networkUnavailable, .timeout:
            true
        case .circuitBreakerOpen, .tooManyRetries, .cancelled:
            false
        default:
            false
        }
    }
}

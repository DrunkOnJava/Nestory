// Layer: Services
// Module: Authentication
// Purpose: Authentication error types

import Foundation

public enum AuthError: LocalizedError, Equatable {
    case notAuthenticated
    case signInFailed(String)
    case biometricFailed(String)
    case invalidCredential
    case invalidToken
    case tokenExpired
    case networkError(String)
    case keychainError(String)

    public var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            "User is not authenticated"
        case let .signInFailed(reason):
            "Sign in failed: \(reason)"
        case let .biometricFailed(reason):
            "Biometric authentication failed: \(reason)"
        case .invalidCredential:
            "Invalid credentials provided"
        case .invalidToken:
            "Invalid authentication token"
        case .tokenExpired:
            "Authentication token has expired"
        case let .networkError(reason):
            "Network error: \(reason)"
        case let .keychainError(reason):
            "Keychain error: \(reason)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .notAuthenticated, .tokenExpired:
            "Please sign in again"
        case .signInFailed, .invalidCredential:
            "Please check your credentials and try again"
        case .biometricFailed:
            "Please try again or use an alternative authentication method"
        case .invalidToken:
            "Your session has become invalid. Please sign in again"
        case .networkError:
            "Please check your internet connection and try again"
        case .keychainError:
            "There was an issue accessing secure storage. Please try again"
        }
    }
}

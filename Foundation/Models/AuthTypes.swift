//
// Layer: Foundation
// Module: Models
// Purpose: Authentication types for identity and authorization
//

import Foundation

/// Authentication credentials returned from successful authentication
public struct AuthCredentials: Equatable, Sendable, Codable {
    public let userId: String
    public let accessToken: String
    public let refreshToken: String
    public let expiresAt: Date
    public let provider: AuthProvider
    
    public init(
        userId: String,
        accessToken: String,
        refreshToken: String,
        expiresAt: Date,
        provider: AuthProvider
    ) {
        self.userId = userId
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
        self.provider = provider
    }
    
    /// Check if the credentials are expired
    public var isExpired: Bool {
        Date() >= expiresAt
    }
}

/// Authentication provider types
public enum AuthProvider: String, CaseIterable, Equatable, Sendable, Codable {
    case demo = "demo"
    case biometric = "biometric"
    case faceID = "face_id"
    case touchID = "touch_id"
    case passcode = "passcode"
    
    public var displayName: String {
        switch self {
        case .demo:
            "Demo Mode"
        case .biometric:
            "Biometric"
        case .faceID:
            "Face ID"
        case .touchID:
            "Touch ID"
        case .passcode:
            "Passcode"
        }
    }
    
    public var requiresHardware: Bool {
        switch self {
        case .faceID, .touchID, .biometric:
            true
        case .demo, .passcode:
            false
        }
    }
}
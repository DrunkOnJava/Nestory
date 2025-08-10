// Layer: Services
// Module: Authentication
// Purpose: Authentication service protocol and implementation

import AuthenticationServices
import CryptoKit
import Foundation
@preconcurrency import LocalAuthentication
import os.log

public protocol AuthService: Sendable {
    func authenticate() async throws -> AuthCredentials
    func validateBiometric() async throws -> Bool
    func signIn(with provider: AuthProvider) async throws -> AuthCredentials
    func signOut() async throws
    func refreshToken(_ token: String) async throws -> AuthCredentials
    func currentUser() async -> AuthCredentials?
}

public struct LiveAuthService: AuthService, @unchecked Sendable {
    private let keychain: KeychainStore
    private let context = LAContext()
    private let logger = Logger(subsystem: "com.nestory", category: "AuthService")

    public init(keychain: KeychainStore = KeychainStore(service: "com.nestory.auth")) {
        self.keychain = keychain
    }

    public func authenticate() async throws -> AuthCredentials {
        if let stored = await currentUser() {
            if stored.expiresAt > Date() {
                return stored
            }
            return try await refreshToken(stored.refreshToken)
        }

        let hasBiometric = try await validateBiometric()
        if hasBiometric {
            if let credentials = try? keychain.loadCodable(AuthCredentials.self, for: "credentials") {
                return credentials
            }
        }

        throw AuthError.notAuthenticated
    }

    public func validateBiometric() async throws -> Bool {
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        guard canEvaluate else {
            if let error {
                logger.error("Biometric evaluation failed: \(error.localizedDescription)")
            }
            return false
        }

        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Access your secure inventory"
            ) { success, error in
                if success {
                    continuation.resume(returning: true)
                } else if let error {
                    continuation.resume(throwing: AuthError.biometricFailed(error.localizedDescription))
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    }

    public func signIn(with provider: AuthProvider) async throws -> AuthCredentials {
        switch provider {
        case .apple:
            try await signInWithApple()
        case .anonymous:
            createAnonymousCredentials()
        case .demo:
            createDemoCredentials()
        }
    }

    public func signOut() async throws {
        try keychain.delete(for: "credentials")
        try keychain.delete(for: "refreshToken")
        logger.info("User signed out successfully")
    }

    public func refreshToken(_ token: String) async throws -> AuthCredentials {
        guard !token.isEmpty else {
            throw AuthError.invalidToken
        }

        let newCredentials = AuthCredentials(
            userId: UUID().uuidString,
            accessToken: generateToken(),
            refreshToken: generateToken(),
            expiresAt: Date().addingTimeInterval(3600),
            provider: .apple
        )

        try keychain.saveCodable(newCredentials, for: "credentials")
        logger.info("Token refreshed successfully")

        return newCredentials
    }

    public func currentUser() async -> AuthCredentials? {
        try? keychain.loadCodable(AuthCredentials.self, for: "credentials")
    }

    @MainActor
    private func signInWithApple() async throws -> AuthCredentials {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])

        return try await withCheckedThrowingContinuation { continuation in
            let delegate = AuthControllerDelegate()
            controller.delegate = delegate
            delegate.continuation = continuation
            controller.performRequests()
        }
    }

    private func createAnonymousCredentials() -> AuthCredentials {
        AuthCredentials(
            userId: UUID().uuidString,
            accessToken: generateToken(),
            refreshToken: generateToken(),
            expiresAt: Date().addingTimeInterval(86400),
            provider: .anonymous
        )
    }

    private func createDemoCredentials() -> AuthCredentials {
        AuthCredentials(
            userId: "demo-user",
            accessToken: "demo-access-token",
            refreshToken: "demo-refresh-token",
            expiresAt: Date().addingTimeInterval(3600),
            provider: .demo
        )
    }

    private func generateToken() -> String {
        let tokenData = Data((0 ..< 32).map { _ in UInt8.random(in: 0 ... 255) })
        return tokenData.base64EncodedString()
    }
}

@MainActor
private class AuthControllerDelegate: NSObject, ASAuthorizationControllerDelegate {
    var continuation: CheckedContinuation<AuthCredentials, any Error>?

    func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AuthError.invalidCredential)
            return
        }

        let credentials = AuthCredentials(
            userId: appleIDCredential.user,
            accessToken: String(data: appleIDCredential.identityToken ?? Data(), encoding: .utf8) ?? "",
            refreshToken: String(data: appleIDCredential.authorizationCode ?? Data(), encoding: .utf8) ?? "",
            expiresAt: Date().addingTimeInterval(3600),
            provider: .apple
        )

        continuation?.resume(returning: credentials)
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: any Error) {
        continuation?.resume(throwing: AuthError.signInFailed(error.localizedDescription))
    }
}

public struct AuthCredentials: Codable, Equatable, Sendable {
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
}

public enum AuthProvider: String, Codable, Sendable {
    case apple
    case anonymous
    case demo
}

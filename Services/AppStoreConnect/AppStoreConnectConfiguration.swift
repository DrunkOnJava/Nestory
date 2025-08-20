//
// Layer: Services
// Module: AppStoreConnect
// Purpose: Secure configuration management for App Store Connect API
//

import Foundation
import Security

/// Manages App Store Connect API configuration securely
@MainActor
public final class AppStoreConnectConfiguration: ObservableObject {
    // MARK: - Types

    public enum ConfigurationError: LocalizedError {
        case missingCredentials
        case keychainError(OSStatus)
        case invalidPrivateKey
        case environmentNotConfigured
        case invalidConfiguration

        public var errorDescription: String? {
            switch self {
            case .missingCredentials:
                "App Store Connect API credentials are missing"
            case let .keychainError(status):
                "Keychain error: \(status)"
            case .invalidPrivateKey:
                "Invalid private key format"
            case .environmentNotConfigured:
                "Environment not properly configured for App Store Connect API"
            case .invalidConfiguration:
                "Invalid configuration data provided"
            }
        }
    }

    public struct Credentials {
        public let keyID: String
        public let issuerID: String
        public let privateKey: String

        public init(keyID: String, issuerID: String, privateKey: String) {
            self.keyID = keyID
            self.issuerID = issuerID
            self.privateKey = privateKey
        }
    }

    // MARK: - Properties

    private static let keychainService = "\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory").appstoreconnect"
    private static let keyIDKey = "ASC_KEY_ID"
    private static let issuerIDKey = "ASC_ISSUER_ID"
    private static let privateKeyKey = "ASC_PRIVATE_KEY"

    @Published public private(set) var isConfigured = false
    @Published public private(set) var currentEnvironment: Environment = .development

    public enum Environment: String, CaseIterable {
        case development = "Development"
        case staging = "Staging"
        case production = "Production"

        var bundleID: String {
            // Get bundle ID from environment configuration
            Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory"
        }
    }

    // MARK: - Initialization

    public init() {
        checkConfiguration()
    }

    // MARK: - Configuration Management

    /// Check if API is properly configured
    public func checkConfiguration() {
        do {
            _ = try loadCredentials()
            isConfigured = true
        } catch {
            isConfigured = false
        }
    }

    /// Load credentials from environment or Keychain
    public func loadCredentials() throws -> Credentials {
        // First try environment variables (for CI/CD)
        if let keyID = ProcessInfo.processInfo.environment["ASC_KEY_ID"],
           let issuerID = ProcessInfo.processInfo.environment["ASC_ISSUER_ID"],
           let privateKey = ProcessInfo.processInfo.environment["ASC_KEY_CONTENT"]
        {
            return Credentials(
                keyID: keyID,
                issuerID: issuerID,
                privateKey: privateKey,
            )
        }

        // Then try Keychain (for local development)
        let keyID = try loadFromKeychain(key: Self.keyIDKey)
        let issuerID = try loadFromKeychain(key: Self.issuerIDKey)
        let privateKey = try loadFromKeychain(key: Self.privateKeyKey)

        return Credentials(
            keyID: keyID,
            issuerID: issuerID,
            privateKey: privateKey,
        )
    }

    /// Save credentials to Keychain
    public func saveCredentials(_ credentials: Credentials) throws {
        try saveToKeychain(key: Self.keyIDKey, value: credentials.keyID)
        try saveToKeychain(key: Self.issuerIDKey, value: credentials.issuerID)
        try saveToKeychain(key: Self.privateKeyKey, value: credentials.privateKey)

        isConfigured = true
    }

    /// Clear stored credentials
    public func clearCredentials() throws {
        try deleteFromKeychain(key: Self.keyIDKey)
        try deleteFromKeychain(key: Self.issuerIDKey)
        try deleteFromKeychain(key: Self.privateKeyKey)

        isConfigured = false
    }

    /// Set current environment
    public func setEnvironment(_ environment: Environment) {
        currentEnvironment = environment
    }

    // MARK: - Keychain Operations

    private func saveToKeychain(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw ConfigurationError.invalidConfiguration
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]

        // Try to delete existing item first
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw ConfigurationError.keychainError(status)
        }
    }

    private func loadFromKeychain(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8)
        else {
            throw ConfigurationError.keychainError(status)
        }

        return value
    }

    private func deleteFromKeychain(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.keychainService,
            kSecAttrAccount as String: key,
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw ConfigurationError.keychainError(status)
        }
    }

    // MARK: - Validation

    /// Validate P8 private key format
    public func validatePrivateKey(_ key: String) -> Bool {
        // Check for PEM format
        let pemPattern = "-----BEGIN PRIVATE KEY-----.*-----END PRIVATE KEY-----"
        let pemRegex = try? NSRegularExpression(pattern: pemPattern, options: .dotMatchesLineSeparators)
        let pemMatches = pemRegex?.firstMatch(in: key, options: [], range: NSRange(location: 0, length: key.count))

        if pemMatches != nil {
            return true
        }

        // Check for base64 encoded key (raw P8)
        let base64Pattern = "^[A-Za-z0-9+/]*={0,2}$"
        let base64Regex = try? NSRegularExpression(pattern: base64Pattern)
        let cleanedKey = key.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
        let base64Matches = base64Regex?.firstMatch(in: cleanedKey, options: [], range: NSRange(location: 0, length: cleanedKey.count))

        return base64Matches != nil && cleanedKey.count > 100
    }

    // MARK: - Factory Method

    /// Create configured API client
    public func createClient() throws -> AppStoreConnectClient {
        let credentials = try loadCredentials()

        guard validatePrivateKey(credentials.privateKey) else {
            throw ConfigurationError.invalidPrivateKey
        }

        let configuration = AppStoreConnectClient.Configuration(
            keyID: credentials.keyID,
            issuerID: credentials.issuerID,
            privateKey: credentials.privateKey,
        )

        return AppStoreConnectClient(configuration: configuration)
    }
}

// MARK: - Environment Detection

extension AppStoreConnectConfiguration {
    /// Detect environment from bundle identifier
    public static func detectEnvironment() -> Environment {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            return .development
        }

        if bundleID.hasSuffix(".dev") {
            return .development
        } else if bundleID.hasSuffix(".staging") {
            return .staging
        } else {
            return .production
        }
    }
}

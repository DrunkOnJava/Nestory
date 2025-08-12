// Layer: Infrastructure

import CryptoKit
import Foundation
import os.log
import Security

public final class KeychainStore: @unchecked Sendable {
    private let service: String
    private let accessGroup: String?
    private let logger = Logger(subsystem: "com.nestory", category: "KeychainStore")

    public init(service: String = "com.nestory", accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }

    public func save(_ data: Data, for key: String, accessibility: KeychainAccessibility = .whenUnlocked) throws {
        let query = createQuery(for: key)

        var status = SecItemCopyMatching(query as CFDictionary, nil)

        if status == errSecSuccess {
            let updateQuery: [String: Any] = [
                kSecValueData as String: data,
            ]

            status = SecItemUpdate(query as CFDictionary, updateQuery as CFDictionary)

            if status != errSecSuccess {
                throw KeychainError.updateFailed(status)
            }

            logger.debug("Updated keychain item: \(key)")
        } else if status == errSecItemNotFound {
            var newQuery = query
            newQuery[kSecValueData as String] = data
            newQuery[kSecAttrAccessible as String] = accessibility.value

            status = SecItemAdd(newQuery as CFDictionary, nil)

            if status != errSecSuccess {
                throw KeychainError.saveFailed(status)
            }

            logger.debug("Saved new keychain item: \(key)")
        } else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    public func load(key: String) throws -> Data {
        try load(for: key)
    }

    public func load(for key: String) throws -> Data {
        var query = createQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            guard let data = result as? Data else {
                throw KeychainError.invalidData
            }
            logger.debug("Loaded keychain item: \(key)")
            return data
        } else if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        } else {
            throw KeychainError.loadFailed(status)
        }
    }

    public func delete(for key: String) throws {
        let query = createQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess, status != errSecItemNotFound {
            throw KeychainError.deleteFailed(status)
        }

        logger.debug("Deleted keychain item: \(key)")
    }

    public func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess, status != errSecItemNotFound {
            throw KeychainError.deleteAllFailed(status)
        }

        logger.debug("Deleted all keychain items for service: \(self.service)")
    }

    public func exists(for key: String) -> Bool {
        let query = createQuery(for: key)
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    public func saveString(_ string: String, for key: String, accessibility: KeychainAccessibility = .whenUnlocked) throws {
        guard let data = string.data(using: .utf8) else {
            throw KeychainError.invalidInput
        }
        try save(data, for: key, accessibility: accessibility)
    }

    public func loadString(key: String) throws -> String {
        try loadString(for: key)
    }

    public func loadString(for key: String) throws -> String {
        let data = try load(for: key)
        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        return string
    }

    public func saveCodable(_ object: some Codable, for key: String, accessibility: KeychainAccessibility = .whenUnlocked) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        try save(data, for: key, accessibility: accessibility)
    }

    public func load<T: Codable>(key: String, type: T.Type) throws -> T {
        try loadCodable(type, for: key)
    }

    public func save(key: String, value: some Codable, accessibility: KeychainAccessibility = .whenUnlocked) throws {
        try saveCodable(value, for: key, accessibility: accessibility)
    }

    public func delete(key: String) throws {
        try delete(for: key)
    }

    public func loadCodable<T: Codable>(_ type: T.Type, for key: String) throws -> T {
        let data = try load(for: key)
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }

    public func saveSymmetricKey(_ key: SymmetricKey, for identifier: String, accessibility: KeychainAccessibility = .whenUnlocked) throws {
        let keyData = key.withUnsafeBytes { Data($0) }
        try save(keyData, for: "key.\(identifier)", accessibility: accessibility)
    }

    public func loadSymmetricKey(for identifier: String) throws -> SymmetricKey {
        let keyData = try load(for: "key.\(identifier)")
        return SymmetricKey(data: keyData)
    }

    public func savePrivateKey(_ privateKey: Curve25519.Signing.PrivateKey, for identifier: String, accessibility: KeychainAccessibility = .whenUnlocked) throws {
        let keyData = privateKey.rawRepresentation
        try save(keyData, for: "signing.private.\(identifier)", accessibility: accessibility)
    }

    public func loadPrivateKey(for identifier: String) throws -> Curve25519.Signing.PrivateKey {
        let keyData = try load(for: "signing.private.\(identifier)")
        return try Curve25519.Signing.PrivateKey(rawRepresentation: keyData)
    }

    public func savePublicKey(_ publicKey: Curve25519.Signing.PublicKey, for identifier: String, accessibility: KeychainAccessibility = .whenUnlocked) throws {
        let keyData = publicKey.rawRepresentation
        try save(keyData, for: "signing.public.\(identifier)", accessibility: accessibility)
    }

    public func loadPublicKey(for identifier: String) throws -> Curve25519.Signing.PublicKey {
        let keyData = try load(for: "signing.public.\(identifier)")
        return try Curve25519.Signing.PublicKey(rawRepresentation: keyData)
    }

    private func createQuery(for key: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrSynchronizable as String: false,
        ]

        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        return query
    }
}

public enum KeychainAccessibility {
    case whenUnlocked
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlock
    case afterFirstUnlockThisDeviceOnly
    case whenPasscodeSetThisDeviceOnly

    var value: String {
        switch self {
        case .whenUnlocked:
            kSecAttrAccessibleWhenUnlocked as String
        case .whenUnlockedThisDeviceOnly:
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
        case .afterFirstUnlock:
            kSecAttrAccessibleAfterFirstUnlock as String
        case .afterFirstUnlockThisDeviceOnly:
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
        case .whenPasscodeSetThisDeviceOnly:
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly as String
        }
    }
}

public enum KeychainError: LocalizedError {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case updateFailed(OSStatus)
    case deleteFailed(OSStatus)
    case deleteAllFailed(OSStatus)
    case itemNotFound
    case invalidData
    case invalidInput
    case unexpectedStatus(OSStatus)

    public var errorDescription: String? {
        switch self {
        case let .saveFailed(status):
            "Failed to save to keychain: \(errorMessage(for: status))"
        case let .loadFailed(status):
            "Failed to load from keychain: \(errorMessage(for: status))"
        case let .updateFailed(status):
            "Failed to update keychain item: \(errorMessage(for: status))"
        case let .deleteFailed(status):
            "Failed to delete from keychain: \(errorMessage(for: status))"
        case let .deleteAllFailed(status):
            "Failed to delete all from keychain: \(errorMessage(for: status))"
        case .itemNotFound:
            "Keychain item not found"
        case .invalidData:
            "Invalid data in keychain"
        case .invalidInput:
            "Invalid input data"
        case let .unexpectedStatus(status):
            "Unexpected keychain status: \(errorMessage(for: status))"
        }
    }

    private func errorMessage(for status: OSStatus) -> String {
        if let error = SecCopyErrorMessageString(status, nil) {
            return String(error)
        }
        return "Unknown error (\(status))"
    }
}

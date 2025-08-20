// Layer: Infrastructure
// Module: Infrastructure/Storage
// Purpose: Secure storage wrapper with encryption support

import CryptoKit
import Foundation

/// Secure storage for sensitive data
public actor SecureStorage {
    // MARK: - Properties

    private let keychain: KeychainWrapper
    private let fileManager: FileManager
    private let documentsDirectory: URL
    private let encryptionKey: SymmetricKey

    // MARK: - Initialization

    public init() throws {
        keychain = KeychainWrapper()
        fileManager = FileManager.default

        // Get documents directory
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw StorageError.documentsDirectoryNotFound
        }
        documentsDirectory = documentsPath

        // Get or create encryption key
        if let keyData = keychain.getData(for: "\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev").encryptionKey") {
            encryptionKey = SymmetricKey(data: keyData)
        } else {
            // Generate new key
            let key = SymmetricKey(size: .bits256)
            let keyData = key.withUnsafeBytes { Data($0) }
            try keychain.setData(keyData, for: "\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev").encryptionKey")
            encryptionKey = key
        }
    }

    // MARK: - Public Methods

    /// Store sensitive data securely
    public func store(_ object: some Codable, for key: String) async throws {
        let data = try JSONEncoder().encode(object)
        let encrypted = try encrypt(data)

        // Store small data in keychain, large data in encrypted files
        if encrypted.count < 4096 { // 4KB threshold
            try keychain.setData(encrypted, for: key)
        } else {
            let fileURL = documentsDirectory.appendingPathComponent("\(key).encrypted")
            try encrypted.write(to: fileURL, options: [.atomic, .completeFileProtection])

            // Store reference in keychain
            let reference = FileReference(path: fileURL.lastPathComponent, size: encrypted.count)
            let refData = try JSONEncoder().encode(reference)
            try keychain.setData(refData, for: key)
        }
    }

    /// Retrieve sensitive data
    public func retrieve<T: Codable>(_ type: T.Type, for key: String) async throws -> T? {
        guard let storedData = keychain.getData(for: key) else {
            return nil
        }

        // Check if it's a file reference
        if let reference = try? JSONDecoder().decode(FileReference.self, from: storedData) {
            let fileURL = documentsDirectory.appendingPathComponent(reference.path)
            guard fileManager.fileExists(atPath: fileURL.path) else {
                return nil
            }

            let encryptedData = try Data(contentsOf: fileURL)
            let decrypted = try decrypt(encryptedData)
            return try JSONDecoder().decode(type, from: decrypted)
        } else {
            // Direct keychain storage
            let decrypted = try decrypt(storedData)
            return try JSONDecoder().decode(type, from: decrypted)
        }
    }

    /// Delete sensitive data
    public func delete(for key: String) async throws {
        // Check for file reference
        if let storedData = keychain.getData(for: key),
           let reference = try? JSONDecoder().decode(FileReference.self, from: storedData)
        {
            let fileURL = documentsDirectory.appendingPathComponent(reference.path)
            try? fileManager.removeItem(at: fileURL)
        }

        try keychain.delete(for: key)
    }

    /// Check if data exists for key
    public func exists(for key: String) async -> Bool {
        keychain.getData(for: key) != nil
    }

    /// Clear all secure storage
    public func clearAll() async throws {
        // Clear encrypted files
        let files = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
        for file in files where file.pathExtension == "encrypted" {
            try fileManager.removeItem(at: file)
        }

        // Clear keychain items (except encryption key)
        let allKeys = keychain.getAllKeys()
        for key in allKeys where key != "\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev").encryptionKey" {
            try keychain.delete(for: key)
        }
    }

    // MARK: - Private Methods

    private func encrypt(_ data: Data) throws -> Data {
        let sealed = try AES.GCM.seal(data, using: encryptionKey)
        guard let encrypted = sealed.combined else {
            throw StorageError.encryptionFailed
        }
        return encrypted
    }

    private func decrypt(_ data: Data) throws -> Data {
        let sealed = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealed, using: encryptionKey)
    }
}

// MARK: - Keychain Wrapper

/// Wrapper for keychain operations
public struct KeychainWrapper {
    private let service = Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev"

    public init() {}

    /// Store data in keychain
    public func setData(_ data: Data, for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
        ]

        // Delete existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw StorageError.keychainError(status)
        }
    }

    /// Retrieve data from keychain
    public func getData(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            return nil
        }

        return result as? Data
    }

    /// Delete item from keychain
    public func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw StorageError.keychainError(status)
        }
    }

    /// Get all keys
    public func getAllKeys() -> [String] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let items = result as? [[String: Any]]
        else {
            return []
        }

        return items.compactMap { $0[kSecAttrAccount as String] as? String }
    }
}

// MARK: - Supporting Types

/// Storage errors
public enum StorageError: LocalizedError {
    case documentsDirectoryNotFound
    case encryptionFailed
    case decryptionFailed
    case keychainError(OSStatus)
    case fileTooLarge
    case dataCorrupted

    public var errorDescription: String? {
        switch self {
        case .documentsDirectoryNotFound:
            "Documents directory not found"
        case .encryptionFailed:
            "Failed to encrypt data"
        case .decryptionFailed:
            "Failed to decrypt data"
        case let .keychainError(status):
            "Keychain error: \(status)"
        case .fileTooLarge:
            "File too large for secure storage"
        case .dataCorrupted:
            "Stored data is corrupted"
        }
    }
}

/// File reference for large encrypted files
private struct FileReference: Codable {
    let path: String
    let size: Int
}

// Layer: Infrastructure

import CryptoKit
import Foundation
import LocalAuthentication
import os.log
import Security

public final class SecureEnclaveHelper {
    private let logger = Logger(subsystem: "com.nestory", category: "SecureEnclaveHelper")
    private let keychain = KeychainStore()

    public var isAvailable: Bool {
        SecureEnclave.isAvailable
    }

    public init() {}

    public func generateKey(for identifier: String, requiresBiometry: Bool = true) throws -> SecureEnclave.P256.Signing.PrivateKey {
        guard isAvailable else {
            throw SecureEnclaveError.notAvailable
        }

        let accessControl = try createAccessControl(requiresBiometry: requiresBiometry)

        let privateKey = try SecureEnclave.P256.Signing.PrivateKey(
            compactRepresentable: true,
            accessControl: accessControl,
            authenticationContext: LAContext()
        )

        let keyData = privateKey.dataRepresentation
        try keychain.save(keyData, for: "secureenclave.\(identifier)")

        logger.debug("Generated Secure Enclave key: \(identifier)")

        return privateKey
    }

    public func loadKey(for identifier: String, context: LAContext? = nil) throws -> SecureEnclave.P256.Signing.PrivateKey {
        guard isAvailable else {
            throw SecureEnclaveError.notAvailable
        }

        let keyData = try keychain.load(for: "secureenclave.\(identifier)")

        let privateKey = try SecureEnclave.P256.Signing.PrivateKey(
            dataRepresentation: keyData,
            authenticationContext: context ?? LAContext()
        )

        logger.debug("Loaded Secure Enclave key: \(identifier)")

        return privateKey
    }

    public func deleteKey(for identifier: String) throws {
        try keychain.delete(for: "secureenclave.\(identifier)")
        logger.debug("Deleted Secure Enclave key: \(identifier)")
    }

    public func sign(_ data: Data, with privateKey: SecureEnclave.P256.Signing.PrivateKey) throws -> P256.Signing.ECDSASignature {
        let signature = try privateKey.signature(for: data)
        logger.debug("Signed \(data.count) bytes with Secure Enclave key")
        return signature
    }

    public func verify(_ signature: P256.Signing.ECDSASignature, for data: Data, using publicKey: P256.Signing.PublicKey) -> Bool {
        let isValid = publicKey.isValidSignature(signature, for: data)
        logger.debug("Signature verification: \(isValid)")
        return isValid
    }

    public func encrypt(_ data: Data, for identifier: String) throws -> EncryptedEnclaveData {
        guard isAvailable else {
            throw SecureEnclaveError.notAvailable
        }

        let ephemeralPrivateKey = P256.KeyAgreement.PrivateKey()
        let ephemeralPublicKey = ephemeralPrivateKey.publicKey

        let recipientPublicKey = try loadEncryptionPublicKey(for: identifier)

        let sharedSecret = try ephemeralPrivateKey.sharedSecretFromKeyAgreement(with: recipientPublicKey)

        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data("com.nestory.secureenclave".utf8),
            sharedInfo: Data(),
            outputByteCount: 32
        )

        let nonce = AES.GCM.Nonce()
        let sealedBox = try AES.GCM.seal(data, using: symmetricKey, nonce: nonce)

        guard let combined = sealedBox.combined else {
            throw SecureEnclaveError.encryptionFailed
        }

        logger.debug("Encrypted \(data.count) bytes with Secure Enclave")

        return EncryptedEnclaveData(
            ciphertext: combined,
            ephemeralPublicKey: ephemeralPublicKey.rawRepresentation
        )
    }

    public func decrypt(_ encryptedData: EncryptedEnclaveData, for identifier: String, context: LAContext? = nil) throws -> Data {
        guard isAvailable else {
            throw SecureEnclaveError.notAvailable
        }

        let ephemeralPublicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: encryptedData.ephemeralPublicKey)
        let privateKey = try loadEncryptionPrivateKey(for: identifier, context: context)

        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: ephemeralPublicKey)

        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data("com.nestory.secureenclave".utf8),
            sharedInfo: Data(),
            outputByteCount: 32
        )

        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData.ciphertext)
        let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)

        logger.debug("Decrypted \(decryptedData.count) bytes with Secure Enclave")

        return decryptedData
    }

    public func generateEncryptionKey(for identifier: String, requiresBiometry: Bool = true) throws -> SecureEnclave.P256.KeyAgreement.PrivateKey {
        guard isAvailable else {
            throw SecureEnclaveError.notAvailable
        }

        let accessControl = try createAccessControl(requiresBiometry: requiresBiometry)

        let privateKey = try SecureEnclave.P256.KeyAgreement.PrivateKey(
            compactRepresentable: true,
            accessControl: accessControl,
            authenticationContext: LAContext()
        )

        let keyData = privateKey.dataRepresentation
        try keychain.save(keyData, for: "secureenclave.encryption.\(identifier)")

        let publicKeyData = privateKey.publicKey.rawRepresentation
        try keychain.save(publicKeyData, for: "secureenclave.encryption.public.\(identifier)")

        logger.debug("Generated Secure Enclave encryption key: \(identifier)")

        return privateKey
    }

    private func loadEncryptionPrivateKey(for identifier: String, context: LAContext?) throws -> SecureEnclave.P256.KeyAgreement.PrivateKey {
        let keyData = try keychain.load(for: "secureenclave.encryption.\(identifier)")

        return try SecureEnclave.P256.KeyAgreement.PrivateKey(
            dataRepresentation: keyData,
            authenticationContext: context ?? LAContext()
        )
    }

    private func loadEncryptionPublicKey(for identifier: String) throws -> P256.KeyAgreement.PublicKey {
        let keyData = try keychain.load(for: "secureenclave.encryption.public.\(identifier)")
        return try P256.KeyAgreement.PublicKey(rawRepresentation: keyData)
    }

    private func createAccessControl(requiresBiometry: Bool) throws -> SecAccessControl {
        var flags: SecAccessControlCreateFlags = [.privateKeyUsage]

        if requiresBiometry {
            flags.insert(.biometryCurrentSet)
        }

        var error: Unmanaged<CFError>?
        guard let accessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            flags,
            &error
        ) else {
            if let error = error?.takeRetainedValue() {
                throw SecureEnclaveError.accessControlCreationFailed(error as Error)
            }
            throw SecureEnclaveError.accessControlCreationFailed(nil)
        }

        return accessControl
    }

    public func authenticateUser(reason: String) async throws -> LAContext {
        let context = LAContext()
        context.localizedReason = reason

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )

            guard success else {
                throw SecureEnclaveError.authenticationFailed
            }

            logger.debug("User authenticated successfully")
            return context
        } catch {
            logger.error("Authentication failed: \(error.localizedDescription)")
            throw SecureEnclaveError.authenticationFailed
        }
    }
}

public struct EncryptedEnclaveData: Codable {
    public let ciphertext: Data
    public let ephemeralPublicKey: Data
}

public enum SecureEnclaveError: LocalizedError {
    case notAvailable
    case keyGenerationFailed
    case keyLoadingFailed
    case signingFailed
    case encryptionFailed
    case decryptionFailed
    case authenticationFailed
    case accessControlCreationFailed(Error?)

    public var errorDescription: String? {
        switch self {
        case .notAvailable:
            "Secure Enclave is not available on this device"
        case .keyGenerationFailed:
            "Failed to generate key in Secure Enclave"
        case .keyLoadingFailed:
            "Failed to load key from Secure Enclave"
        case .signingFailed:
            "Failed to sign data with Secure Enclave"
        case .encryptionFailed:
            "Failed to encrypt data with Secure Enclave"
        case .decryptionFailed:
            "Failed to decrypt data with Secure Enclave"
        case .authenticationFailed:
            "User authentication failed"
        case let .accessControlCreationFailed(error):
            "Failed to create access control: \(error?.localizedDescription ?? "Unknown error")"
        }
    }
}

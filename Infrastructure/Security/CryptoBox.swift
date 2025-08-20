// Layer: Infrastructure

import CryptoKit
import Foundation
import os.log

public final class CryptoBox {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "CryptoBox")

    public init() {}

    public func encrypt(_ data: Data, using key: SymmetricKey) throws -> EncryptedData {
        let nonce = AES.GCM.Nonce()
        let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)

        guard let encryptedData = sealedBox.combined else {
            throw CryptoError.encryptionFailed
        }

        logger.debug("Encrypted \(data.count) bytes")

        return EncryptedData(
            ciphertext: encryptedData,
            nonce: nonce.withUnsafeBytes { Data($0) },
            tag: sealedBox.tag,
        )
    }

    public func decrypt(_ encryptedData: EncryptedData, using key: SymmetricKey) throws -> Data {
        guard let nonce = try? AES.GCM.Nonce(data: encryptedData.nonce) else {
            throw CryptoError.invalidNonce
        }

        let sealedBox = try AES.GCM.SealedBox(
            nonce: nonce,
            ciphertext: encryptedData.ciphertext,
            tag: encryptedData.tag,
        )

        let decryptedData = try AES.GCM.open(sealedBox, using: key)

        logger.debug("Decrypted \(decryptedData.count) bytes")

        return decryptedData
    }

    public func encrypt(_ string: String, using key: SymmetricKey) throws -> EncryptedData {
        guard let data = string.data(using: .utf8) else {
            throw CryptoError.invalidInput
        }
        return try encrypt(data, using: key)
    }

    public func decryptString(_ encryptedData: EncryptedData, using key: SymmetricKey) throws -> String {
        let data = try decrypt(encryptedData, using: key)
        guard let string = String(data: data, encoding: .utf8) else {
            throw CryptoError.decryptionFailed
        }
        return string
    }

    public func generateKey() -> SymmetricKey {
        SymmetricKey(size: .bits256)
    }

    public func generateKey(from password: String, salt: Data) throws -> SymmetricKey {
        guard let passwordData = password.data(using: .utf8) else {
            throw CryptoError.invalidInput
        }

        let derivedKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: passwordData),
            salt: salt,
            info: Data("\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory").encryption".utf8),
            outputByteCount: 32,
        )

        return derivedKey
    }

    public func generateSalt() -> Data {
        var salt = Data(count: 32)
        _ = salt.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 32, bytes.baseAddress!)
        }
        return salt
    }

    public func hash(_ data: Data) -> Data {
        let digest = SHA256.hash(data: data)
        return Data(digest)
    }

    public func hash(_ string: String) -> Data? {
        guard let data = string.data(using: .utf8) else { return nil }
        return hash(data)
    }

    public func verify(_ data: Data, matches hash: Data) -> Bool {
        let computedHash = self.hash(data)
        return computedHash == hash
    }

    public func sign(_ data: Data, with privateKey: Curve25519.Signing.PrivateKey) throws -> Data {
        let signature = try privateKey.signature(for: data)
        return signature
    }

    public func verify(_ signature: Data, for data: Data, using publicKey: Curve25519.Signing.PublicKey) -> Bool {
        publicKey.isValidSignature(signature, for: data)
    }

    public func generateSigningKeyPair() -> (privateKey: Curve25519.Signing.PrivateKey, publicKey: Curve25519.Signing.PublicKey) {
        let privateKey = Curve25519.Signing.PrivateKey()
        let publicKey = privateKey.publicKey
        return (privateKey, publicKey)
    }

    public func encryptWithPublicKey(_ data: Data, to publicKey: Curve25519.KeyAgreement.PublicKey, from privateKey: Curve25519.KeyAgreement.PrivateKey) throws -> EncryptedData {
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)

        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: Data("\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory").keyagreement".utf8),
            outputByteCount: 32,
        )

        return try encrypt(data, using: symmetricKey)
    }

    public func decryptWithPrivateKey(_ encryptedData: EncryptedData, from publicKey: Curve25519.KeyAgreement.PublicKey, using privateKey: Curve25519.KeyAgreement.PrivateKey) throws -> Data {
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)

        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: Data("\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory").keyagreement".utf8),
            outputByteCount: 32,
        )

        return try decrypt(encryptedData, using: symmetricKey)
    }

    public func generateKeyAgreementKeyPair() -> (privateKey: Curve25519.KeyAgreement.PrivateKey, publicKey: Curve25519.KeyAgreement.PublicKey) {
        let privateKey = Curve25519.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey
        return (privateKey, publicKey)
    }
}

public struct EncryptedData: Codable {
    public let ciphertext: Data
    public let nonce: Data
    public let tag: Data

    public var combined: Data {
        nonce + ciphertext + tag
    }

    public init(ciphertext: Data, nonce: Data, tag: Data) {
        self.ciphertext = ciphertext
        self.nonce = nonce
        self.tag = tag
    }

    public init(combined: Data) throws {
        guard combined.count >= 28 else {
            throw CryptoError.invalidData
        }

        nonce = combined.prefix(12)
        tag = combined.suffix(16)
        ciphertext = combined.dropFirst(12).dropLast(16)
    }
}

public enum CryptoError: LocalizedError {
    case encryptionFailed
    case decryptionFailed
    case invalidInput
    case invalidNonce
    case invalidData
    case keyGenerationFailed

    public var errorDescription: String? {
        switch self {
        case .encryptionFailed:
            "Failed to encrypt data"
        case .decryptionFailed:
            "Failed to decrypt data"
        case .invalidInput:
            "Invalid input data"
        case .invalidNonce:
            "Invalid nonce data"
        case .invalidData:
            "Invalid encrypted data format"
        case .keyGenerationFailed:
            "Failed to generate encryption key"
        }
    }
}

import CryptoKit
@testable import Nestory
import XCTest

final class CryptoBoxTests: XCTestCase {
    var cryptoBox: CryptoBox!

    override func setUp() {
        super.setUp()
        cryptoBox = CryptoBox()
    }

    func testSymmetricEncryption() throws {
        let key = cryptoBox.generateKey()
        let plaintext = "Hello, World!"
        let data = plaintext.data(using: .utf8)!

        let encrypted = try cryptoBox.encrypt(data, using: key)
        let decrypted = try cryptoBox.decrypt(encrypted, using: key)

        XCTAssertEqual(decrypted, data)
        XCTAssertNotEqual(encrypted.ciphertext, data)
    }

    func testStringEncryption() throws {
        let key = cryptoBox.generateKey()
        let plaintext = "Secret message"

        let encrypted = try cryptoBox.encrypt(plaintext, using: key)
        let decrypted = try cryptoBox.decryptString(encrypted, using: key)

        XCTAssertEqual(decrypted, plaintext)
    }

    func testPasswordDerivedKey() throws {
        let password = "SecurePassword123!"
        let salt = cryptoBox.generateSalt()

        let key1 = try cryptoBox.generateKey(from: password, salt: salt)
        let key2 = try cryptoBox.generateKey(from: password, salt: salt)

        let testData = "Test".data(using: .utf8)!
        let encrypted = try cryptoBox.encrypt(testData, using: key1)
        let decrypted = try cryptoBox.decrypt(encrypted, using: key2)

        XCTAssertEqual(decrypted, testData)
    }

    func testHashing() {
        let data = "Hash this".data(using: .utf8)!
        let hash1 = cryptoBox.hash(data)
        let hash2 = cryptoBox.hash(data)

        XCTAssertEqual(hash1, hash2)
        XCTAssertEqual(hash1.count, 32)
    }

    func testHashVerification() {
        let data = "Verify this".data(using: .utf8)!
        let hash = cryptoBox.hash(data)

        XCTAssertTrue(cryptoBox.verify(data, matches: hash))

        let differentData = "Different".data(using: .utf8)!
        XCTAssertFalse(cryptoBox.verify(differentData, matches: hash))
    }

    func testSigningAndVerification() throws {
        let (privateKey, publicKey) = cryptoBox.generateSigningKeyPair()
        let message = "Sign this message".data(using: .utf8)!

        let signature = try cryptoBox.sign(message, with: privateKey)

        XCTAssertTrue(cryptoBox.verify(signature, for: message, using: publicKey))

        let tamperedMessage = "Tampered message".data(using: .utf8)!
        XCTAssertFalse(cryptoBox.verify(signature, for: tamperedMessage, using: publicKey))
    }

    func testPublicKeyEncryption() throws {
        let (privateKey1, publicKey1) = cryptoBox.generateKeyAgreementKeyPair()
        let (privateKey2, publicKey2) = cryptoBox.generateKeyAgreementKeyPair()

        let message = "Secret message".data(using: .utf8)!

        let encrypted = try cryptoBox.encryptWithPublicKey(message, to: publicKey2, from: privateKey1)
        let decrypted = try cryptoBox.decryptWithPrivateKey(encrypted, from: publicKey1, using: privateKey2)

        XCTAssertEqual(decrypted, message)
    }

    func testEncryptedDataCombined() throws {
        let ciphertext = Data(repeating: 1, count: 100)
        let nonce = Data(repeating: 2, count: 12)
        let tag = Data(repeating: 3, count: 16)

        let encryptedData = EncryptedData(ciphertext: ciphertext, nonce: nonce, tag: tag)
        let combined = encryptedData.combined

        XCTAssertEqual(combined.count, 128)

        let reconstructed = try EncryptedData(combined: combined)

        XCTAssertEqual(reconstructed.nonce, nonce)
        XCTAssertEqual(reconstructed.ciphertext, ciphertext)
        XCTAssertEqual(reconstructed.tag, tag)
    }
}

final class KeychainStoreTests: XCTestCase {
    var keychain: KeychainStore!
    let testKey = "test-key-\(UUID().uuidString)"

    override func setUp() {
        super.setUp()
        keychain = KeychainStore(service: "com.nestory.test")
    }

    override func tearDown() {
        try? keychain.delete(for: testKey)
        super.tearDown()
    }

    func testSaveAndLoadData() throws {
        let data = "Test data".data(using: .utf8)!

        try keychain.save(data, for: testKey)
        let loaded = try keychain.load(for: testKey)

        XCTAssertEqual(loaded, data)
    }

    func testSaveAndLoadString() throws {
        let string = "Test string"

        try keychain.saveString(string, for: testKey)
        let loaded = try keychain.loadString(for: testKey)

        XCTAssertEqual(loaded, string)
    }

    func testSaveAndLoadCodable() throws {
        struct TestModel: Codable, Equatable {
            let id: String
            let value: Int
        }

        let model = TestModel(id: "123", value: 42)

        try keychain.saveCodable(model, for: testKey)
        let loaded = try keychain.loadCodable(TestModel.self, for: testKey)

        XCTAssertEqual(loaded, model)
    }

    func testUpdateExistingItem() throws {
        let data1 = "First".data(using: .utf8)!
        let data2 = "Second".data(using: .utf8)!

        try keychain.save(data1, for: testKey)
        try keychain.save(data2, for: testKey)

        let loaded = try keychain.load(for: testKey)

        XCTAssertEqual(loaded, data2)
    }

    func testDeleteItem() throws {
        let data = "Delete me".data(using: .utf8)!

        try keychain.save(data, for: testKey)
        XCTAssertTrue(keychain.exists(for: testKey))

        try keychain.delete(for: testKey)
        XCTAssertFalse(keychain.exists(for: testKey))
    }

    func testItemNotFound() {
        XCTAssertThrowsError(try keychain.load(for: "nonexistent")) { error in
            guard case KeychainError.itemNotFound = error else {
                XCTFail("Expected itemNotFound error")
                return
            }
        }
    }

    func testSymmetricKeyStorage() throws {
        let key = SymmetricKey(size: .bits256)

        try keychain.saveSymmetricKey(key, for: testKey)
        let loaded = try keychain.loadSymmetricKey(for: testKey)

        let testData = "Test".data(using: .utf8)!
        let box = CryptoBox()

        let encrypted = try box.encrypt(testData, using: key)
        let decrypted = try box.decrypt(encrypted, using: loaded)

        XCTAssertEqual(decrypted, testData)
    }

    func testSigningKeyStorage() throws {
        let privateKey = Curve25519.Signing.PrivateKey()
        let publicKey = privateKey.publicKey

        try keychain.savePrivateKey(privateKey, for: testKey)
        try keychain.savePublicKey(publicKey, for: testKey + "-public")

        let loadedPrivate = try keychain.loadPrivateKey(for: testKey)
        let loadedPublic = try keychain.loadPublicKey(for: testKey + "-public")

        let message = "Test message".data(using: .utf8)!
        let signature = try loadedPrivate.signature(for: message)

        XCTAssertTrue(loadedPublic.isValidSignature(signature, for: message))

        try? keychain.delete(for: testKey + "-public")
    }
}

final class SecureEnclaveHelperTests: XCTestCase {
    var secureEnclave: SecureEnclaveHelper!

    override func setUp() {
        super.setUp()
        secureEnclave = SecureEnclaveHelper()
    }

    func testAvailability() {
        #if targetEnvironment(simulator)
            XCTAssertFalse(secureEnclave.isAvailable)
        #else
            XCTAssertTrue(secureEnclave.isAvailable)
        #endif
    }

    func testSecureEnclaveOperationsOnSimulator() throws {
        guard !secureEnclave.isAvailable else {
            throw XCTSkip("Secure Enclave is available, skipping simulator test")
        }

        XCTAssertThrowsError(try secureEnclave.generateKey(for: "test-key")) { error in
            guard case SecureEnclaveError.notAvailable = error else {
                XCTFail("Expected notAvailable error")
                return
            }
        }
    }
}

final class CryptoPerformanceTests: XCTestCase {
    var cryptoBox: CryptoBox!

    override func setUp() {
        super.setUp()
        cryptoBox = CryptoBox()
    }

    func testSymmetricEncryptionPerformance() throws {
        let key = cryptoBox.generateKey()
        let data = Data(repeating: 0, count: 1024 * 1024)

        measure {
            _ = try? cryptoBox.encrypt(data, using: key)
        }
    }

    func testHashingPerformance() {
        let data = Data(repeating: 0, count: 1024 * 1024)

        measure {
            _ = cryptoBox.hash(data)
        }
    }

    func testKeyDerivationPerformance() throws {
        let password = "TestPassword123!"
        let salt = cryptoBox.generateSalt()

        measure {
            _ = try? cryptoBox.generateKey(from: password, salt: salt)
        }
    }
}

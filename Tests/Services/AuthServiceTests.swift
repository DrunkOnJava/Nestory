// Layer: Tests
// Module: Services
// Purpose: Authentication service tests

@testable import Nestory
import XCTest

final class AuthServiceTests: XCTestCase {
    var service: TestAuthService!

    override func setUp() {
        super.setUp()
        service = TestAuthService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    func testAuthenticate() async throws {
        service.authenticateResult = .success(TestData.authCredentials)

        let credentials = try await service.authenticate()

        XCTAssertTrue(service.authenticateCalled)
        XCTAssertEqual(credentials.userId, TestData.authCredentials.userId)
        XCTAssertEqual(credentials.provider, .demo)
    }

    func testAuthenticateFailure() async {
        service.authenticateResult = .failure(AuthError.notAuthenticated)

        do {
            _ = try await service.authenticate()
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertTrue(error is AuthError)
        }
    }

    func testValidateBiometric() async throws {
        service.validateBiometricResult = .success(true)

        let result = try await service.validateBiometric()

        XCTAssertTrue(service.validateBiometricCalled)
        XCTAssertTrue(result)
    }

    func testSignIn() async throws {
        service.signInResult = .success(TestData.authCredentials)

        let credentials = try await service.signIn(with: .apple)

        XCTAssertTrue(service.signInCalled)
        XCTAssertEqual(service.signInProvider, .apple)
        XCTAssertEqual(credentials.userId, TestData.authCredentials.userId)
    }

    func testSignOut() async throws {
        try await service.signOut()

        XCTAssertTrue(service.signOutCalled)
    }

    func testRefreshToken() async throws {
        service.refreshTokenResult = .success(TestData.authCredentials)

        let credentials = try await service.refreshToken("old-token")

        XCTAssertTrue(service.refreshTokenCalled)
        XCTAssertEqual(service.refreshTokenInput, "old-token")
        XCTAssertEqual(credentials.userId, TestData.authCredentials.userId)
    }

    func testCurrentUser() async {
        service.currentUserResult = TestData.authCredentials

        let user = await service.currentUser()

        XCTAssertTrue(service.currentUserCalled)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.userId, TestData.authCredentials.userId)
    }
}

final class AuthErrorTests: XCTestCase {
    func testErrorDescriptions() {
        let errors: [AuthError] = [
            .notAuthenticated,
            .signInFailed("test"),
            .biometricFailed("test"),
            .invalidCredential,
            .invalidToken,
            .tokenExpired,
            .networkError("test"),
            .keychainError("test"),
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertNotNil(error.recoverySuggestion)
        }
    }
}

final class AuthCredentialsTests: XCTestCase {
    func testCodable() throws {
        let credentials = TestData.authCredentials

        let encoder = JSONEncoder()
        let data = try encoder.encode(credentials)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AuthCredentials.self, from: data)

        XCTAssertEqual(decoded, credentials)
    }
}

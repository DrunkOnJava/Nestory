// Layer: Tests
// Module: Services
// Purpose: Currency service tests

@testable import Nestory
import XCTest

final class CurrencyServiceTests: XCTestCase {
    var service: TestCurrencyService!

    override func setUp() {
        super.setUp()
        service = TestCurrencyService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    func testConvert() async throws {
        service.convertResult = .success(150)

        let result = try await service.convert(amount: 100, from: "USD", to: "EUR")

        XCTAssertTrue(service.convertCalled)
        XCTAssertEqual(service.convertAmount, 100)
        XCTAssertEqual(service.convertFrom, "USD")
        XCTAssertEqual(service.convertTo, "EUR")
        XCTAssertEqual(result, 150)
    }

    func testConvertError() async {
        service.convertResult = .failure(CurrencyError.invalidAmount)

        do {
            _ = try await service.convert(amount: -10, from: "USD", to: "EUR")
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertTrue(error is CurrencyError)
        }
    }

    func testUpdateRates() async throws {
        service.updateRatesResult = .success(())

        try await service.updateRates()

        XCTAssertTrue(service.updateRatesCalled)
    }

    func testGetRate() async throws {
        let rate = try await service.getRate(from: "USD", to: "EUR")
        XCTAssertEqual(rate, 1.0)
    }

    func testGetSupportedCurrencies() async {
        let currencies = await service.getSupportedCurrencies()
        XCTAssertEqual(currencies.count, 0)
    }

    func testGetHistoricalRate() async throws {
        let rate = try await service.getHistoricalRate(from: "USD", to: "EUR", date: Date())
        XCTAssertEqual(rate, 1.0)
    }
}

final class CurrencyErrorTests: XCTestCase {
    func testErrorDescriptions() {
        let errors: [CurrencyError] = [
            .invalidAmount,
            .rateNotAvailable(from: "USD", to: "EUR"),
            .updateFailed("test"),
            .invalidCurrency("XXX"),
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
        }
    }
}

final class ExchangeRateTests: XCTestCase {
    func testCodable() throws {
        let rate = ExchangeRate(
            from: "USD",
            to: "EUR",
            rate: 0.92,
            timestamp: Date()
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(rate)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ExchangeRate.self, from: data)

        XCTAssertEqual(decoded.from, rate.from)
        XCTAssertEqual(decoded.to, rate.to)
        XCTAssertEqual(decoded.rate, rate.rate)
    }
}

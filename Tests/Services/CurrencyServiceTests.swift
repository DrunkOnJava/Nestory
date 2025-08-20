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

// MARK: - Performance Tests

@MainActor
final class CurrencyServicePerformanceTests: XCTestCase {
    func testMultipleCurrencyConversionsPerformance() async throws {
        let service = try LiveCurrencyService(httpClient: nil) // Offline only

        let conversions: [(amount: Decimal, from: String, to: String)] = [
            (100, "USD", "EUR"),
            (200, "EUR", "GBP"),
            (300, "GBP", "JPY"),
            (400, "JPY", "CAD"),
            (500, "CAD", "AUD"),
        ]

        measure {
            Task { @MainActor in
                for conversion in conversions {
                    do {
                        _ = try await service.convert(
                            amount: conversion.amount,
                            from: conversion.from,
                            to: conversion.to,
                        )
                    } catch {
                        // Ignore conversion errors in performance test
                    }
                }
            }
        }
    }

    func testGetSupportedCurrenciesPerformance() async throws {
        let service = try LiveCurrencyService(httpClient: nil)

        measure {
            Task { @MainActor in
                _ = await service.getSupportedCurrencies()
            }
        }
    }
}

// MARK: - Model Tests

final class ExchangeRateTests: XCTestCase {
    func testCodable() throws {
        let rate = ExchangeRate(
            from: "USD",
            to: "EUR",
            rate: 0.92,
            timestamp: Date(),
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

final class ExchangeRateResponseTests: XCTestCase {
    func testCodable() throws {
        let response = ExchangeRateResponse(
            base: "USD",
            rates: ["EUR": 0.85, "GBP": 0.75],
            timestamp: Date(),
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(response)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ExchangeRateResponse.self, from: data)

        XCTAssertEqual(decoded.base, response.base)
        XCTAssertEqual(decoded.rates.count, response.rates.count)
        XCTAssertEqual(decoded.rates["EUR"], 0.85)
        XCTAssertEqual(decoded.rates["GBP"], 0.75)
    }
}

final class CurrencyTests: XCTestCase {
    func testCurrencyInit() {
        let currency = Currency(
            code: "USD",
            name: "US Dollar",
            symbol: "$",
            decimals: 2,
        )

        XCTAssertEqual(currency.id, "USD") // Uses code as ID
        XCTAssertEqual(currency.code, "USD")
        XCTAssertEqual(currency.name, "US Dollar")
        XCTAssertEqual(currency.symbol, "$")
        XCTAssertEqual(currency.decimals, 2)
    }

    func testCurrencyCodable() throws {
        let currency = Currency(
            code: "EUR",
            name: "Euro",
            symbol: "€",
            decimals: 2,
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(currency)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Currency.self, from: data)

        XCTAssertEqual(decoded.code, currency.code)
        XCTAssertEqual(decoded.name, currency.name)
        XCTAssertEqual(decoded.symbol, currency.symbol)
        XCTAssertEqual(decoded.decimals, currency.decimals)
    }
}

// MARK: - Mock HTTP Client for Testing

class MockHTTPClient: HTTPClient {
    var requestCalled = false
    var mockResponse: ExchangeRateResponse?
    var shouldFail = false

    func request<T: Codable>(_: Endpoint, responseType _: T.Type) async throws -> T {
        requestCalled = true

        if shouldFail {
            throw URLError(.notConnectedToInternet)
        }

        if let response = mockResponse as? T {
            return response
        }

        throw URLError(.badServerResponse)
    }
}

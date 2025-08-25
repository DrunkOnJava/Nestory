// Layer: Services
// Module: CurrencyService
// Purpose: Offline currency conversion with cached rates

import Foundation
import os.log

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with URLSession - Use URLSessionDataTask with background configuration for currency rate updates

public protocol CurrencyService: Sendable {
    func convert(amount: Decimal, from: String, to: String) async throws -> Decimal
    func updateRates() async throws
    func getRate(from: String, to: String) async throws -> Decimal
    func getSupportedCurrencies() async -> [Currency]
    func getHistoricalRate(from: String, to: String, date: Date) async throws -> Decimal?
}

public struct LiveCurrencyService: CurrencyService, @unchecked Sendable {
    private let cache: Cache<String, ExchangeRate>
    private let fileStore: FileStore
    private let httpClient: HTTPClient?
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "CurrencyService")

    private let offlineRates: [String: Decimal] = [
        "USD": 1.0,
        "EUR": 0.92,
        "GBP": 0.79,
        "JPY": 149.50,
        "CAD": 1.36,
        "AUD": 1.53,
        "CHF": 0.88,
        "CNY": 7.24,
        "INR": 83.12,
        "MXN": 17.15,
        "BRL": 4.98,
        "ZAR": 18.75,
        "KRW": 1325.50,
        "SGD": 1.34,
        "HKD": 7.83,
        "NZD": 1.65,
        "SEK": 10.52,
        "NOK": 10.68,
        "DKK": 6.89,
        "PLN": 4.02,
    ]

    public init(httpClient: HTTPClient? = nil) throws {
        cache = try Cache(name: "currency", maxMemoryCount: 200, ttl: 3600)
        fileStore = try FileStore(directory: .applicationSupport, subdirectory: "currency")
        self.httpClient = httpClient
    }

    public func convert(amount: Decimal, from: String, to: String) async throws -> Decimal {
        guard amount > 0 else {
            throw CurrencyError.invalidAmount
        }

        let fromCurrency = from.uppercased()
        let toCurrency = to.uppercased()

        if fromCurrency == toCurrency {
            return amount
        }

        let rate = try await getRate(from: fromCurrency, to: toCurrency)
        let converted = amount * rate

        logger.debug("Converted \(amount) \(fromCurrency) to \(converted) \(toCurrency)")
        return converted
    }

    public func updateRates() async throws {
        guard let httpClient else {
            logger.info("Using offline rates - no HTTP client configured")
            return
        }

        let endpoint = Endpoint.get(
            "latest",
            query: ["base": "USD"],
        )

        do {
            let response: ExchangeRateResponse = try await httpClient.request(
                endpoint,
                responseType: ExchangeRateResponse.self,
            )

            for (currency, rate) in response.rates {
                let exchangeRate = ExchangeRate(
                    from: "USD",
                    to: currency,
                    rate: rate,
                    timestamp: response.timestamp,
                )

                let cacheKey = "USD_\(currency)"
                await cache.set(exchangeRate, for: cacheKey)

                let inverseRate = ExchangeRate(
                    from: currency,
                    to: "USD",
                    rate: 1 / rate,
                    timestamp: response.timestamp,
                )

                let inverseCacheKey = "\(currency)_USD"
                await cache.set(inverseRate, for: inverseCacheKey)
            }

            let data = try JSONEncoder().encode(response)
            try await fileStore.saveData(data, to: "latest_rates.json")

            logger.info("Updated exchange rates for \(response.rates.count) currencies")
        } catch {
            logger.error("Failed to update rates: \(error.localizedDescription)")
            throw CurrencyError.updateFailed(error.localizedDescription)
        }
    }

    public func getRate(from: String, to: String) async throws -> Decimal {
        let cacheKey = "\(from)_\(to)"

        if let cached = await cache.get(for: cacheKey) {
            if cached.timestamp.addingTimeInterval(86400) > Date() {
                return cached.rate
            }
        }

        if let onlineRate = await fetchOnlineRate(from: from, to: to) {
            return onlineRate
        }

        if let offlineRate = calculateOfflineRate(from: from, to: to) {
            let exchangeRate = ExchangeRate(
                from: from,
                to: to,
                rate: offlineRate,
                timestamp: Date(),
            )
            await cache.set(exchangeRate, for: cacheKey)
            return offlineRate
        }

        throw CurrencyError.rateNotAvailable(from: from, to: to)
    }

    public func getSupportedCurrencies() async -> [Currency] {
        var currencies: [Currency] = []

        for (code, _) in offlineRates {
            let currency = Currency(
                code: code,
                name: currencyName(for: code),
                symbol: currencySymbol(for: code),
                decimals: currencyDecimals(for: code),
            )
            currencies.append(currency)
        }

        return currencies.sorted { $0.code < $1.code }
    }

    public func getHistoricalRate(from: String, to: String, date: Date) async throws -> Decimal? {
        if let data = try? await fileStore.loadData(from: "historical_\(date.ISO8601Format()).json"),
           let response = try? JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        {
            if from == "USD", let rate = response.rates[to] {
                return rate
            } else if to == "USD", let rate = response.rates[from] {
                return 1 / rate
            } else if let fromRate = response.rates[from],
                      let toRate = response.rates[to]
            {
                return toRate / fromRate
            }
        }

        return nil
    }

    private func fetchOnlineRate(from: String, to: String) async -> Decimal? {
        guard httpClient != nil else { return nil }

        do {
            try await updateRates()

            if let cached = await cache.get(for: "\(from)_\(to)") {
                return cached.rate
            }
        } catch {
            logger.error("Failed to fetch online rate: \(error.localizedDescription)")
        }

        return nil
    }

    private func calculateOfflineRate(from: String, to: String) -> Decimal? {
        guard let fromRate = offlineRates[from],
              let toRate = offlineRates[to]
        else {
            return nil
        }

        return toRate / fromRate
    }

    private func currencyName(for code: String) -> String {
        switch code {
        case "USD": "US Dollar"
        case "EUR": "Euro"
        case "GBP": "British Pound"
        case "JPY": "Japanese Yen"
        case "CAD": "Canadian Dollar"
        case "AUD": "Australian Dollar"
        case "CHF": "Swiss Franc"
        case "CNY": "Chinese Yuan"
        case "INR": "Indian Rupee"
        case "MXN": "Mexican Peso"
        case "BRL": "Brazilian Real"
        case "ZAR": "South African Rand"
        case "KRW": "South Korean Won"
        case "SGD": "Singapore Dollar"
        case "HKD": "Hong Kong Dollar"
        case "NZD": "New Zealand Dollar"
        case "SEK": "Swedish Krona"
        case "NOK": "Norwegian Krone"
        case "DKK": "Danish Krone"
        case "PLN": "Polish Zloty"
        default: code
        }
    }

    private func currencySymbol(for code: String) -> String {
        switch code {
        case "USD": "$"
        case "EUR": "€"
        case "GBP": "£"
        case "JPY": "¥"
        case "CAD": "C$"
        case "AUD": "A$"
        case "CHF": "CHF"
        case "CNY": "¥"
        case "INR": "₹"
        case "MXN": "$"
        case "BRL": "R$"
        case "ZAR": "R"
        case "KRW": "₩"
        case "SGD": "S$"
        case "HKD": "HK$"
        case "NZD": "NZ$"
        case "SEK": "kr"
        case "NOK": "kr"
        case "DKK": "kr"
        case "PLN": "zł"
        default: code
        }
    }

    private func currencyDecimals(for code: String) -> Int {
        switch code {
        case "JPY", "KRW": 0
        default: 2
        }
    }
}

public struct ExchangeRate: Codable {
    public let from: String
    public let to: String
    public let rate: Decimal
    public let timestamp: Date
}

public struct ExchangeRateResponse: Codable {
    public let base: String
    public let rates: [String: Decimal]
    public let timestamp: Date
}

public struct Currency: Codable, Identifiable, Sendable {
    public let code: String
    public let name: String
    public let symbol: String
    public let decimals: Int

    public var id: String { code }
}

public enum CurrencyError: LocalizedError {
    case invalidAmount
    case rateNotAvailable(from: String, to: String)
    case updateFailed(String)
    case invalidCurrency(String)

    public var errorDescription: String? {
        switch self {
        case .invalidAmount:
            "Invalid amount for conversion"
        case let .rateNotAvailable(from, to):
            "Exchange rate not available for \(from) to \(to)"
        case let .updateFailed(reason):
            "Failed to update exchange rates: \(reason)"
        case let .invalidCurrency(code):
            "Invalid currency code: \(code)"
        }
    }
}

//
// Layer: Services
// Module: AnalyticsService
// Purpose: Currency conversion operations for analytics calculations
//

import Foundation
import os.log

// MARK: - Currency Operations Extension

extension LiveAnalyticsService {
    // MARK: - Currency Conversion Helper Methods

    /// Converts currency with comprehensive error handling, caching, and fallbacks
    nonisolated func convertCurrencyWithFallback(
        amount: Decimal,
        from: String,
        to: String,
        itemName: String,
    ) async throws -> Decimal {
        let cacheKey = "\(from)-\(to)-\(amount)"

        // Check cache first
        if let cachedValue = await conversionCache.get(for: cacheKey) {
            logger.debug("Using cached conversion for \(itemName): \(from) -> \(to)")
            return cachedValue
        }

        // Attempt conversion with retry logic
        do {
            let convertedValue = try await resilientExecutor.execute(
                operation: {
                    try await self.currencyService.convert(amount: amount, from: from, to: to)
                },
                fallbackValue: amount, // Use original amount as fallback
                operationType: "currencyConversion",
            )

            // Cache successful conversion
            await conversionCache.set(convertedValue, for: cacheKey)
            logger.debug("Converted \(amount) \(from) to \(convertedValue) \(to) for \(itemName)")

            return convertedValue
        } catch {
            logger.warning("Currency conversion failed for \(itemName) (\(from) -> \(to)): \(error)")

            // Check for historical/cached rate as fallback
            if let fallbackRate = await getCachedExchangeRate(from: from, to: to) {
                let fallbackValue = amount * fallbackRate
                logger.info("Using cached exchange rate for \(itemName): \(fallbackRate)")
                return fallbackValue
            }

            // Final fallback: throw detailed error
            throw AnalyticsServiceError.currencyConversionFailed(
                from: from,
                to: to,
                amount: amount,
            )
        }
    }

    /// Gets a cached exchange rate, if available
    private nonisolated func getCachedExchangeRate(from: String, to: String) async -> Decimal? {
        let rateCacheKey = "rate-\(from)-\(to)"
        return await conversionCache.get(for: rateCacheKey)
    }

    /// Enhanced currency conversion for category breakdown with better error reporting
    nonisolated func convertCurrencyForCategory(
        amount: Decimal,
        from: String,
        to: String,
        categoryName: String,
    ) async -> Decimal {
        do {
            return try await convertCurrencyWithFallback(
                amount: amount,
                from: from,
                to: to,
                itemName: "category \(categoryName)",
            )
        } catch {
            logger.warning("Currency conversion failed for category \(categoryName): \(error)")
            return amount // Return original value
        }
    }

    /// Validates analytics data before processing
    nonisolated func validateAnalyticsData(items: [Item], operation: String) throws {
        guard !items.isEmpty else {
            throw AnalyticsServiceError.invalidData(reason: "No items provided for \(operation)")
        }

        let itemsWithPrice = items.filter { $0.purchasePrice != nil }
        if itemsWithPrice.isEmpty {
            logger.warning("No items have purchase prices for \(operation)")
        }

        // Check for unusual currency codes
        let currencies = Set(items.map(\.currency))
        let unusualCurrencies = currencies.filter { $0.count != 3 || $0.isEmpty }
        if !unusualCurrencies.isEmpty {
            logger.warning("Found unusual currency codes in \(operation): \(unusualCurrencies)")
        }
    }
}

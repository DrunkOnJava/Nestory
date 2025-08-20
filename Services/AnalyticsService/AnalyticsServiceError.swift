//
// Layer: Services
// Module: AnalyticsService
// Purpose: Error types for AnalyticsService
//

import Foundation

// MARK: - Analytics Service Errors

public enum AnalyticsServiceError: LocalizedError {
    case currencyConversionFailed(from: String, to: String, amount: Decimal)
    case currencyServiceUnavailable
    case invalidData(reason: String)
    case calculationFailed(operation: String)
    case cacheError(String)

    public var errorDescription: String? {
        switch self {
        case let .currencyConversionFailed(from, to, amount):
            "Failed to convert \(amount) from \(from) to \(to)"
        case .currencyServiceUnavailable:
            "Currency conversion service is unavailable"
        case let .invalidData(reason):
            "Invalid data for analytics calculation: \(reason)"
        case let .calculationFailed(operation):
            "Analytics calculation failed: \(operation)"
        case let .cacheError(details):
            "Analytics cache error: \(details)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .currencyConversionFailed, .currencyServiceUnavailable:
            "Values will be displayed in their original currencies"
        case .invalidData:
            "Check your data and try again"
        case .calculationFailed:
            "Try refreshing the analytics data"
        case .cacheError:
            "Analytics cache will be rebuilt automatically"
        }
    }
}

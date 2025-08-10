// Layer: Foundation
// Module: Foundation/Utils
// Purpose: Currency formatting and parsing utilities

import Foundation

/// Currency utility functions
public enum CurrencyUtils {
    
    // MARK: - Currency Information
    
    /// Get currency symbol for code
    public static func symbol(for currencyCode: String) -> String {
        let locale = Locale.current
        return locale.currencySymbol(forCurrencyCode: currencyCode) ?? currencyCode
    }
    
    /// Get currency name for code
    public static func name(for currencyCode: String) -> String {
        let locale = Locale.current
        return locale.localizedString(forCurrencyCode: currencyCode) ?? currencyCode
    }
    
    /// Get all available currency codes
    public static var availableCurrencyCodes: [String] {
        if #available(iOS 16.0, *) {
            return Locale.Currency.isoCurrencies.map { $0.identifier }.sorted()
        } else {
            return Locale.isoCurrencyCodes.sorted()
        }
    }
    
    /// Common currency codes
    public static var commonCurrencyCodes: [String] {
        ["USD", "EUR", "GBP", "JPY", "CNY", "AUD", "CAD", "CHF", "HKD", "NZD", "SEK", "KRW", "SGD", "NOK", "MXN", "INR", "RUB", "ZAR", "TRY", "BRL"]
    }
    
    /// Get the scale (number of decimal places) for a currency
    public static func currencyScale(for currencyCode: String) -> Int {
        // Most currencies use 2 decimal places
        // Some like JPY, KRW use 0
        // Some like BHD, KWD, OMR use 3
        switch currencyCode.uppercased() {
        case "JPY", "KRW", "VND", "IDR", "CLP", "PYG", "UGX", "RWF":
            return 0
        case "BHD", "IQD", "JOD", "KWD", "LYD", "OMR", "TND":
            return 3
        default:
            return 2
        }
    }
    
    // MARK: - Formatting
    
    /// Create currency formatter for a specific currency
    public static func formatter(for currencyCode: String, locale: Locale = .current) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = locale
        formatter.minimumFractionDigits = currencyScale(for: currencyCode)
        formatter.maximumFractionDigits = currencyScale(for: currencyCode)
        return formatter
    }
    
    /// Format amount as currency string
    public static func format(_ amount: Decimal, currencyCode: String, locale: Locale = .current) -> String {
        let formatter = formatter(for: currencyCode, locale: locale)
        return formatter.string(from: amount as NSNumber) ?? "\(currencyCode) \(amount)"
    }
    
    /// Format amount with explicit symbol placement
    public static func format(_ amount: Decimal, currencyCode: String, symbolPosition: SymbolPosition) -> String {
        let formatter = formatter(for: currencyCode)
        
        switch symbolPosition {
        case .before:
            formatter.positivePrefix = formatter.currencySymbol + " "
            formatter.positiveSuffix = ""
        case .after:
            formatter.positivePrefix = ""
            formatter.positiveSuffix = " " + formatter.currencySymbol
        case .default:
            break // Use locale default
        }
        
        return formatter.string(from: amount as NSNumber) ?? "\(currencyCode) \(amount)"
    }
    
    /// Format amount without currency symbol
    public static func formatNumber(_ amount: Decimal, scale: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = scale
        formatter.maximumFractionDigits = scale
        return formatter.string(from: amount as NSNumber) ?? "\(amount)"
    }
    
    // MARK: - Parsing
    
    /// Parse currency string to decimal amount
    public static func parse(_ string: String, currencyCode: String? = nil) -> Decimal? {
        let cleanString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try with currency formatter first
        if let currencyCode = currencyCode {
            let formatter = formatter(for: currencyCode)
            if let number = formatter.number(from: cleanString) {
                return number.decimalValue
            }
        }
        
        // Try parsing as plain number
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        
        if let number = numberFormatter.number(from: cleanString) {
            return number.decimalValue
        }
        
        // Try removing common currency symbols and parsing
        let symbolsToRemove = CharacterSet(charactersIn: "$€£¥₹")
        let numericString = cleanString.trimmingCharacters(in: symbolsToRemove)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let number = numberFormatter.number(from: numericString) {
            return number.decimalValue
        }
        
        // Last resort: try to parse as Decimal directly
        return Decimal(string: numericString)
    }
    
    /// Extract currency code from string
    public static func extractCurrencyCode(from string: String) -> String? {
        let pattern = "\\b[A-Z]{3}\\b"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: string.utf16.count)
        
        if let match = regex?.firstMatch(in: string, options: [], range: range) {
            if let codeRange = Range(match.range, in: string) {
                let code = String(string[codeRange])
                if availableCurrencyCodes.contains(code) {
                    return code
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Conversion
    
    /// Round amount to currency precision
    public static func round(_ amount: Decimal, for currencyCode: String) -> Decimal {
        let scale = currencyScale(for: currencyCode)
        let multiplier = pow(Decimal(10), scale)
        var rounded = amount * multiplier
        var result = Decimal()
        NSDecimalRound(&result, &rounded, 0, .bankers)
        return result / multiplier
    }
    
    /// Convert between currencies
    public static func convert(_ amount: Decimal, from: String, to: String, rate: Decimal) -> Decimal {
        let converted = amount * rate
        return round(converted, for: to)
    }
    
    // MARK: - Validation
    
    /// Validate currency code
    public static func isValidCurrencyCode(_ code: String) -> Bool {
        availableCurrencyCodes.contains(code.uppercased())
    }
    
    /// Validate amount for currency
    public static func isValidAmount(_ amount: Decimal, for currencyCode: String) -> Bool {
        // Check for negative amounts (usually invalid for prices)
        guard amount >= 0 else { return false }
        
        // Check precision matches currency scale
        let scale = currencyScale(for: currencyCode)
        let multiplier = pow(Decimal(10), scale)
        var scaled = amount * multiplier
        var rounded = Decimal()
        NSDecimalRound(&rounded, &scaled, 0, .down)
        
        return scaled == rounded
    }
}

// MARK: - Supporting Types

/// Symbol position for currency formatting
public enum SymbolPosition {
    case before
    case after
    case `default`
}

// MARK: - Locale Extensions

private extension Locale {
    /// Get currency symbol for a currency code
    func currencySymbol(forCurrencyCode code: String) -> String? {
        let localeIdentifier = Locale.availableIdentifiers.first { identifier in
            let locale = Locale(identifier: identifier)
            return locale.currency?.identifier == code
        }
        
        if let identifier = localeIdentifier {
            let locale = Locale(identifier: identifier)
            return locale.currencySymbol
        }
        
        return nil
    }
}

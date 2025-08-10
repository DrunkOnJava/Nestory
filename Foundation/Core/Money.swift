// Layer: Foundation
// Module: Foundation/Core
// Purpose: Money value object with currency code and deterministic rounding

import Foundation

/// Value object representing monetary amounts with currency
public struct Money: Codable, Hashable, Sendable {
    /// Amount in minor units (e.g., cents for USD)
    public let minorUnits: Int64

    /// ISO 4217 currency code
    public let currencyCode: String

    /// Number of decimal places for this currency
    public var scale: Int {
        CurrencyHelper.scale(for: currencyCode)
    }

    // MARK: - Initialization

    /// Initialize with minor units
    public init(minorUnits: Int64, currencyCode: String) {
        self.minorUnits = minorUnits
        self.currencyCode = currencyCode.uppercased()
    }

    /// Initialize with major units (e.g., dollars)
    public init(amount: Decimal, currencyCode: String) {
        let scale = CurrencyHelper.scale(for: currencyCode)
        let multiplier = Decimal(pow(10.0, Double(scale)))
        let minorUnits = NSDecimalNumber(decimal: amount * multiplier).rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: .bankers, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false))
        self.minorUnits = Int64(truncating: minorUnits as NSNumber)
        self.currencyCode = currencyCode.uppercased()
    }

    /// Initialize with double (use carefully due to precision issues)
    public init(amount: Double, currencyCode: String) {
        self.init(amount: Decimal(amount), currencyCode: currencyCode)
    }

    // MARK: - Computed Properties

    /// Amount in major units (e.g., dollars)
    public var amount: Decimal {
        let divisor = Decimal(pow(10.0, Double(scale)))
        return Decimal(minorUnits) / divisor
    }

    /// Formatted string representation
    public var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.minimumFractionDigits = scale
        formatter.maximumFractionDigits = scale
        return formatter.string(from: amount as NSNumber) ?? "\(currencyCode) \(amount)"
    }

    /// Check if amount is zero
    public var isZero: Bool {
        minorUnits == 0
    }

    /// Check if amount is positive
    public var isPositive: Bool {
        minorUnits > 0
    }

    /// Check if amount is negative
    public var isNegative: Bool {
        minorUnits < 0
    }

    // MARK: - Arithmetic Operations

    /// Add two money values (must be same currency)
    public static func + (lhs: Money, rhs: Money) throws -> Money {
        guard lhs.currencyCode == rhs.currencyCode else {
            throw AppError.invalidInput("Cannot add different currencies: \(lhs.currencyCode) and \(rhs.currencyCode)")
        }
        return Money(minorUnits: lhs.minorUnits + rhs.minorUnits, currencyCode: lhs.currencyCode)
    }

    /// Subtract two money values (must be same currency)
    public static func - (lhs: Money, rhs: Money) throws -> Money {
        guard lhs.currencyCode == rhs.currencyCode else {
            throw AppError.invalidInput("Cannot subtract different currencies: \(lhs.currencyCode) and \(rhs.currencyCode)")
        }
        return Money(minorUnits: lhs.minorUnits - rhs.minorUnits, currencyCode: lhs.currencyCode)
    }

    /// Multiply money by a scalar
    public static func * (money: Money, multiplier: Decimal) -> Money {
        let result = Decimal(money.minorUnits) * multiplier
        let rounded = NSDecimalNumber(decimal: result).rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: .bankers, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false))
        return Money(minorUnits: Int64(truncating: rounded), currencyCode: money.currencyCode)
    }

    /// Divide money by a scalar
    public static func / (money: Money, divisor: Decimal) -> Money {
        let result = Decimal(money.minorUnits) / divisor
        let rounded = NSDecimalNumber(decimal: result).rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: .bankers, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false))
        return Money(minorUnits: Int64(truncating: rounded), currencyCode: money.currencyCode)
    }

    /// Negate the amount
    public static prefix func - (money: Money) -> Money {
        Money(minorUnits: -money.minorUnits, currencyCode: money.currencyCode)
    }

    /// Absolute value
    public var absolute: Money {
        Money(minorUnits: abs(minorUnits), currencyCode: currencyCode)
    }

    // MARK: - Rounding

    /// Round to nearest major unit
    public func roundedToMajorUnit() -> Money {
        let divisor = Int64(pow(10.0, Double(scale)))
        let rounded = (minorUnits + divisor / 2) / divisor * divisor
        return Money(minorUnits: rounded, currencyCode: currencyCode)
    }

    // MARK: - Static Factory Methods

    /// Zero money for a currency
    public static func zero(currencyCode: String) -> Money {
        Money(minorUnits: 0, currencyCode: currencyCode)
    }

    /// Parse from string (e.g., "100.50 USD")
    public static func parse(_ string: String) throws -> Money {
        let components = string.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")
        guard components.count == 2 else {
            throw AppError.invalidFormat(field: "Money", expectedFormat: "amount currency")
        }

        guard let amount = Decimal(string: String(components[0])) else {
            throw AppError.invalidFormat(field: "Amount", expectedFormat: "numeric")
        }

        let currencyCode = String(components[1])
        return Money(amount: amount, currencyCode: currencyCode)
    }
}

// MARK: - Comparable

extension Money: Comparable {
    public static func < (lhs: Money, rhs: Money) -> Bool {
        guard lhs.currencyCode == rhs.currencyCode else {
            return false // Different currencies are not comparable
        }
        return lhs.minorUnits < rhs.minorUnits
    }
}

// MARK: - CustomStringConvertible

extension Money: CustomStringConvertible {
    public var description: String {
        formatted
    }
}

// MARK: - Currency Helper

public enum CurrencyHelper {
    /// Get the scale (decimal places) for a currency code
    public static func scale(for currencyCode: String) -> Int {
        // Common currencies with their decimal places
        switch currencyCode.uppercased() {
        case "JPY", "KRW", "VND", "IDR", "CLP", "TWD", "ISK", "HUF":
            0 // No decimal places
        case "KWD", "OMR", "BHD", "JOD", "LYD", "TND":
            3 // Three decimal places
        default:
            2 // Most currencies use 2 decimal places
        }
    }

    /// Common currency codes
    public enum Code {
        public static let USD = "USD"
        public static let EUR = "EUR"
        public static let GBP = "GBP"
        public static let JPY = "JPY"
        public static let CNY = "CNY"
        public static let AUD = "AUD"
        public static let CAD = "CAD"
        public static let CHF = "CHF"
        public static let HKD = "HKD"
        public static let NZD = "NZD"
    }
}

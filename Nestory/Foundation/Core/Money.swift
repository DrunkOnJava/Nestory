// Layer: Foundation

import Foundation

public struct Money: Equatable, Hashable, Codable, Sendable {
    public let amountInMinorUnits: Int64
    public let currencyCode: String

    public init(amountInMinorUnits: Int64, currencyCode: String) throws {
        guard ISO4217.isValid(currencyCode) else {
            throw AppError.validation(field: "currencyCode", reason: "Invalid ISO 4217 currency code: \(currencyCode)")
        }
        self.amountInMinorUnits = amountInMinorUnits
        self.currencyCode = currencyCode.uppercased()
    }

    public init(amount: Decimal, currencyCode: String) throws {
        guard ISO4217.isValid(currencyCode) else {
            throw AppError.validation(field: "currencyCode", reason: "Invalid ISO 4217 currency code: \(currencyCode)")
        }
        let minorUnits = ISO4217.minorUnits(for: currencyCode)
        let multiplier = Decimal(sign: .plus, exponent: minorUnits, significand: 1)
        let scaledAmount = NSDecimalNumber(decimal: amount * multiplier).rounding(accordingToBehavior: nil).decimalValue

        guard let intValue = Int64(exactly: NSDecimalNumber(decimal: scaledAmount).doubleValue) else {
            throw AppError.validation(field: "amount", reason: "Amount too large to represent")
        }

        amountInMinorUnits = intValue
        self.currencyCode = currencyCode.uppercased()
    }

    public var amount: Decimal {
        let minorUnits = ISO4217.minorUnits(for: currencyCode)
        let divisor = Decimal(sign: .plus, exponent: minorUnits, significand: 1)
        return Decimal(amountInMinorUnits) / divisor
    }

    public func formatted(locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = locale
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "\(currencyCode) \(amount)"
    }

    public func adding(_ other: Money) throws -> Money {
        guard currencyCode == other.currencyCode else {
            throw AppError.businessRule(
                rule: "Currency matching",
                violation: "Cannot add \(currencyCode) and \(other.currencyCode)"
            )
        }
        return try Money(
            amountInMinorUnits: amountInMinorUnits + other.amountInMinorUnits,
            currencyCode: currencyCode
        )
    }

    public func subtracting(_ other: Money) throws -> Money {
        guard currencyCode == other.currencyCode else {
            throw AppError.businessRule(
                rule: "Currency matching",
                violation: "Cannot subtract \(other.currencyCode) from \(currencyCode)"
            )
        }
        return try Money(
            amountInMinorUnits: amountInMinorUnits - other.amountInMinorUnits,
            currencyCode: currencyCode
        )
    }

    public func multiplying(by factor: Decimal) throws -> Money {
        let scaledAmount = Decimal(amountInMinorUnits) * factor
        let rounded = NSDecimalNumber(decimal: scaledAmount).rounding(accordingToBehavior: nil).decimalValue
        guard let intValue = Int64(exactly: NSDecimalNumber(decimal: rounded).doubleValue) else {
            throw AppError.validation(field: "amount", reason: "Result too large to represent")
        }
        return try Money(amountInMinorUnits: intValue, currencyCode: currencyCode)
    }

    public var isPositive: Bool {
        amountInMinorUnits > 0
    }

    public var isNegative: Bool {
        amountInMinorUnits < 0
    }

    public var isZero: Bool {
        amountInMinorUnits == 0
    }

    public static func zero(currencyCode: String) throws -> Money {
        try Money(amountInMinorUnits: 0, currencyCode: currencyCode)
    }
}

extension Money: Comparable {
    public static func < (lhs: Money, rhs: Money) -> Bool {
        precondition(lhs.currencyCode == rhs.currencyCode, "Cannot compare different currencies")
        return lhs.amountInMinorUnits < rhs.amountInMinorUnits
    }
}

extension Money: CustomStringConvertible {
    public var description: String {
        formatted()
    }
}

private enum ISO4217 {
    private static let currencies: Set<String> = [
        "USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "NZD",
        "CNY", "INR", "KRW", "SGD", "HKD", "NOK", "SEK", "DKK",
        "PLN", "CZK", "HUF", "RON", "BGN", "HRK", "RUB", "TRY",
        "BRL", "MXN", "ARS", "CLP", "COP", "PEN", "UYU", "ZAR",
        "THB", "MYR", "IDR", "PHP", "VND",
    ]

    private static let minorUnitsMap: [String: Int] = [
        "JPY": 0, "KRW": 0, "CLP": 0, "VND": 0,
        "BHD": 3, "JOD": 3, "KWD": 3, "OMR": 3, "TND": 3,
    ]

    static func isValid(_ code: String) -> Bool {
        currencies.contains(code.uppercased())
    }

    static func minorUnits(for code: String) -> Int {
        minorUnitsMap[code.uppercased()] ?? 2
    }
}

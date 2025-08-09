// Layer: Foundation

import Foundation

public enum CurrencyUtils {
    public static func format(
        _ money: Money,
        locale: Locale = .current,
        showCurrencySymbol: Bool = true
    ) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = showCurrencySymbol ? .currency : .decimal
        formatter.currencyCode = money.currencyCode
        formatter.locale = locale
        formatter.minimumFractionDigits = fractionDigits(for: money.currencyCode)
        formatter.maximumFractionDigits = fractionDigits(for: money.currencyCode)

        return formatter.string(from: NSDecimalNumber(decimal: money.amount)) ?? "\(money.currencyCode) \(money.amount)"
    }

    public static func formatCompact(
        _ money: Money,
        locale: Locale = .current
    ) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = money.currencyCode
        formatter.locale = locale

        if money.amount >= 1_000_000 {
            formatter.maximumFractionDigits = 1
            let millions = money.amount / 1_000_000
            return formatter.string(from: NSDecimalNumber(decimal: millions))?.appending("M") ?? "\(money.currencyCode) \(millions)M"
        } else if money.amount >= 1000 {
            formatter.maximumFractionDigits = 1
            let thousands = money.amount / 1000
            return formatter.string(from: NSDecimalNumber(decimal: thousands))?.appending("K") ?? "\(money.currencyCode) \(thousands)K"
        } else {
            return format(money, locale: locale)
        }
    }

    public static func parse(
        _ string: String,
        currencyCode: String,
        locale: Locale = .current
    ) throws -> Money {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = locale

        let cleanedString = string
            .replacingOccurrences(of: formatter.currencySymbol ?? "", with: "")
            .replacingOccurrences(of: currencyCode, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        formatter.numberStyle = .decimal

        guard let number = formatter.number(from: cleanedString) else {
            throw AppError.parsingError(type: "Currency", reason: "Invalid number format: \(string)")
        }

        let decimal = Decimal(number.doubleValue)
        return try Money(amount: decimal, currencyCode: currencyCode)
    }

    public static func symbol(for currencyCode: String, locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = locale
        return formatter.currencySymbol ?? currencyCode
    }

    public static func fractionDigits(for currencyCode: String) -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.minimumFractionDigits
    }

    public static func isValidCurrencyCode(_ code: String) -> Bool {
        Locale.isoCurrencyCodes.contains(code.uppercased())
    }

    public static func currencyName(for code: String, locale: Locale = .current) -> String? {
        locale.localizedString(forCurrencyCode: code)
    }

    public static func commonCurrencies() -> [(code: String, name: String, symbol: String)] {
        let codes = ["USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "CNY"]
        return codes.compactMap { code in
            guard let name = currencyName(for: code) else { return nil }
            let symbol = symbol(for: code)
            return (code: code, name: name, symbol: symbol)
        }
    }

    public static func sum(_ moneys: [Money]) throws -> Money? {
        guard !moneys.isEmpty else { return nil }

        let firstCurrency = moneys[0].currencyCode
        guard moneys.allSatisfy({ $0.currencyCode == firstCurrency }) else {
            throw AppError.businessRule(
                rule: "Currency matching",
                violation: "Cannot sum different currencies"
            )
        }

        let total = moneys.reduce(Int64(0)) { $0 + $1.amountInMinorUnits }
        return try Money(amountInMinorUnits: total, currencyCode: firstCurrency)
    }

    public static func average(_ moneys: [Money]) throws -> Money? {
        guard !moneys.isEmpty else { return nil }

        guard let sum = try sum(moneys) else { return nil }
        let count = Decimal(moneys.count)
        return try sum.multiplying(by: 1 / count)
    }
}

// Layer: Foundation

import Foundation
import SwiftData

@Model
public final class CurrencyRate {
    @Attribute(.unique) public var code: String
    public var rateToBase: Decimal
    public var asOf: Date
    public var baseCurrency: String

    public init(
        code: String,
        rateToBase: Decimal,
        baseCurrency: String = "USD",
        asOf: Date = Date()
    ) throws {
        guard rateToBase > 0 else {
            throw AppError.validation(field: "rateToBase", reason: "Exchange rate must be positive")
        }

        self.code = code.uppercased()
        self.rateToBase = rateToBase
        self.baseCurrency = baseCurrency.uppercased()
        self.asOf = asOf
    }

    public func convert(_ money: Money, to targetCurrency: String) throws -> Money {
        guard money.currencyCode == code else {
            throw AppError.businessRule(
                rule: "Currency conversion",
                violation: "Source currency mismatch"
            )
        }

        let baseAmount = money.amount * rateToBase

        if targetCurrency == baseCurrency {
            return try Money(amount: baseAmount, currencyCode: baseCurrency)
        } else {
            throw AppError.businessRule(
                rule: "Currency conversion",
                violation: "Target currency rate not available"
            )
        }
    }

    public var isStale: Bool {
        let oneDayAgo = Date().addingTimeInterval(-24 * 60 * 60)
        return asOf < oneDayAgo
    }

    public var age: TimeInterval {
        Date().timeIntervalSince(asOf)
    }

    public var formattedAge: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter.string(from: age) ?? "Unknown"
    }
}

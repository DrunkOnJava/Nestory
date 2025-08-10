// Layer: Foundation
// Module: Foundation/Models
// Purpose: Currency rate model for exchange rates

import Foundation
import SwiftData

/// Currency exchange rate
@Model
public final class CurrencyRate {
    // MARK: - Properties
    
    @Attribute(.unique)
    public var id: UUID
    
    public var fromCode: String // Base currency code
    public var toCode: String // Target currency code
    public var rate: Decimal // Exchange rate
    public var source: String // "api", "manual", "cached"
    public var asOf: Date // When the rate was valid
    public var expiresAt: Date? // When to refresh
    
    // Timestamps
    public var createdAt: Date
    public var updatedAt: Date
    
    // MARK: - Initialization
    
    public init(
        from fromCode: String,
        to toCode: String,
        rate: Decimal,
        asOf: Date = Date()
    ) {
        self.id = UUID()
        self.fromCode = fromCode.uppercased()
        self.toCode = toCode.uppercased()
        self.rate = rate
        self.source = "api"
        self.asOf = asOf
        
        // Default expiration is 24 hours
        let calendar = Calendar.current
        self.expiresAt = calendar.date(byAdding: .hour, value: 24, to: asOf)
        
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Computed Properties
    
    /// Inverse rate (for reverse conversion)
    public var inverseRate: Decimal {
        guard rate != 0 else { return 0 }
        return 1 / rate
    }
    
    /// Check if rate is expired
    public var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
    
    /// Check if rate is stale (older than 7 days)
    public var isStale: Bool {
        let calendar = Calendar.current
        guard let daysSince = calendar.dateComponents([.day], from: asOf, to: Date()).day else {
            return true
        }
        return daysSince > 7
    }
    
    /// Age of the rate in hours
    public var ageInHours: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: asOf, to: Date())
        return components.hour ?? 0
    }
    
    /// Currency pair string (e.g., "USD/EUR")
    public var currencyPair: String {
        "\(fromCode)/\(toCode)"
    }
    
    // MARK: - Methods
    
    /// Convert an amount using this rate
    public func convert(_ amount: Decimal) -> Decimal {
        amount * rate
    }
    
    /// Convert a Money object using this rate
    public func convert(_ money: Money) throws -> Money {
        guard money.currencyCode == fromCode else {
            throw AppError.invalidInput("Currency mismatch: expected \(fromCode), got \(money.currencyCode)")
        }
        
        let convertedAmount = money.amount * rate
        return Money(amount: convertedAmount, currencyCode: toCode)
    }
    
    /// Update the rate
    public func update(rate: Decimal, asOf: Date = Date(), source: String? = nil) {
        self.rate = rate
        self.asOf = asOf
        
        if let source = source {
            self.source = source
        }
        
        // Reset expiration
        let calendar = Calendar.current
        self.expiresAt = calendar.date(byAdding: .hour, value: 24, to: asOf)
        
        self.updatedAt = Date()
    }
    
    /// Extend expiration
    public func extendExpiration(by hours: Int) {
        guard let currentExpiration = expiresAt else {
            let calendar = Calendar.current
            self.expiresAt = calendar.date(byAdding: .hour, value: hours, to: Date())
            return
        }
        
        let calendar = Calendar.current
        self.expiresAt = calendar.date(byAdding: .hour, value: hours, to: currentExpiration)
        self.updatedAt = Date()
    }
    
    /// Mark as manual entry
    public func markAsManual() {
        self.source = "manual"
        self.expiresAt = nil // Manual entries don't expire
        self.updatedAt = Date()
    }
    
    /// Create inverse rate
    public func createInverse() -> CurrencyRate {
        CurrencyRate(
            from: toCode,
            to: fromCode,
            rate: inverseRate,
            asOf: asOf
        )
    }
}

// MARK: - Static Methods

extension CurrencyRate {
    /// Find rate for currency pair
    public static func findRate(
        from: String,
        to: String,
        in context: ModelContext
    ) -> CurrencyRate? {
        let fromCode = from.uppercased()
        let toCode = to.uppercased()
        
        // Same currency
        if fromCode == toCode {
            return CurrencyRate(from: fromCode, to: toCode, rate: 1)
        }
        
        // Try to find direct rate
        let descriptor = FetchDescriptor<CurrencyRate>(
            predicate: #Predicate { rate in
                rate.fromCode == fromCode && rate.toCode == toCode && !rate.isExpired
            },
            sortBy: [SortDescriptor(\.asOf, order: .reverse)]
        )
        
        if let rates = try? context.fetch(descriptor),
           let directRate = rates.first {
            return directRate
        }
        
        // Try to find inverse rate
        let inverseDescriptor = FetchDescriptor<CurrencyRate>(
            predicate: #Predicate { rate in
                rate.fromCode == toCode && rate.toCode == fromCode && !rate.isExpired
            },
            sortBy: [SortDescriptor(\.asOf, order: .reverse)]
        )
        
        if let rates = try? context.fetch(inverseDescriptor),
           let inverseRate = rates.first {
            return inverseRate.createInverse()
        }
        
        return nil
    }
    
    /// Get all supported currencies
    public static func supportedCurrencies(in context: ModelContext) -> Set<String> {
        var currencies = Set<String>()
        
        let descriptor = FetchDescriptor<CurrencyRate>()
        if let rates = try? context.fetch(descriptor) {
            for rate in rates {
                currencies.insert(rate.fromCode)
                currencies.insert(rate.toCode)
            }
        }
        
        // Always include common currencies
        currencies.insert("USD")
        currencies.insert("EUR")
        currencies.insert("GBP")
        
        return currencies
    }
}

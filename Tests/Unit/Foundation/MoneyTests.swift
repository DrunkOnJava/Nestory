//
// MoneyTests.swift
// NestoryTests
//
// Comprehensive tests for Money value type
//

import Foundation
@testable import Nestory
import Testing

@Suite("Money Value Type Tests")
struct MoneyTests {
    // MARK: - Initialization Tests

    @Test("Money initialization with valid values")
    func validInitialization() {
        let money = Money(amount: 100.50, currencyCode: "USD")

        #expect(money.amount == 100.50)
        #expect(money.currencyCode == "USD")
    }

    @Test("Money initialization with zero amount")
    func zeroAmountInitialization() {
        let money = Money(amount: 0.0, currencyCode: "EUR")

        #expect(money.amount == 0.0)
        #expect(money.currencyCode == "EUR")
    }

    // MARK: - Equality Tests

    @Test("Money equality with same values")
    func equalityWithSameValues() {
        let money1 = Money(amount: 100.0, currencyCode: "USD")
        let money2 = Money(amount: 100.0, currencyCode: "USD")

        #expect(money1 == money2)
    }

    @Test("Money inequality with different amounts")
    func inequalityWithDifferentAmounts() {
        let money1 = Money(amount: 100.0, currencyCode: "USD")
        let money2 = Money(amount: 200.0, currencyCode: "USD")

        #expect(money1 != money2)
    }

    @Test("Money inequality with different currencies")
    func inequalityWithDifferentCurrencies() {
        let money1 = Money(amount: 100.0, currencyCode: "USD")
        let money2 = Money(amount: 100.0, currencyCode: "EUR")

        #expect(money1 != money2)
    }

    // MARK: - Performance Tests

    @Test("Money operations performance")
    func operationsPerformance() {
        let money1 = Money(amount: 100.0, currencyCode: "USD")
        let money2 = Money(amount: 50.0, currencyCode: "USD")

        let (_, time) = measureTime {
            for _ in 0 ..< 1000 {
                _ = Money(amount: money1.amount + money2.amount, currencyCode: "USD")
            }
        }

        // Should complete 1,000 operations in reasonable time
        #expect(time < 0.1, "Money operations should be fast")
    }
}

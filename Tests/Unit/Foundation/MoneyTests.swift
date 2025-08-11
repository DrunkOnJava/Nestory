// Layer: Foundation

@testable import Nestory
import XCTest

final class MoneyTests: XCTestCase {
    func testMoneyCreationWithMinorUnits() throws {
        let money = try Money(amountInMinorUnits: 1599, currencyCode: "USD")
        XCTAssertEqual(money.amountInMinorUnits, 1599)
        XCTAssertEqual(money.currencyCode, "USD")
        XCTAssertEqual(money.amount, Decimal(15.99))
    }

    func testMoneyCreationWithDecimal() throws {
        let money = try Money(amount: Decimal(15.99), currencyCode: "USD")
        XCTAssertEqual(money.amountInMinorUnits, 1599)
        XCTAssertEqual(money.currencyCode, "USD")
        XCTAssertEqual(money.amount, Decimal(15.99))
    }

    func testMoneyCreationWithInvalidCurrency() {
        XCTAssertThrows {
            _ = try Money(amountInMinorUnits: 100, currencyCode: "INVALID")
        }
    }

    func testMoneyFormatting() throws {
        let money = try Money(amount: Decimal(1234.56), currencyCode: "USD")
        let formatted = money.formatted(locale: Locale(identifier: "en_US"))
        XCTAssertTrue(formatted.contains("1,234.56"))
    }

    func testMoneyAddition() throws {
        let money1 = try Money(amount: Decimal(10.50), currencyCode: "USD")
        let money2 = try Money(amount: Decimal(5.25), currencyCode: "USD")
        let result = try money1.adding(money2)
        XCTAssertEqual(result.amount, Decimal(15.75))
        XCTAssertEqual(result.currencyCode, "USD")
    }

    func testMoneySubtraction() throws {
        let money1 = try Money(amount: Decimal(10.50), currencyCode: "USD")
        let money2 = try Money(amount: Decimal(5.25), currencyCode: "USD")
        let result = try money1.subtracting(money2)
        XCTAssertEqual(result.amount, Decimal(5.25))
        XCTAssertEqual(result.currencyCode, "USD")
    }

    func testMoneyMultiplication() throws {
        let money = try Money(amount: Decimal(10.00), currencyCode: "USD")
        let result = try money.multiplying(by: Decimal(2.5))
        XCTAssertEqual(result.amount, Decimal(25.00))
        XCTAssertEqual(result.currencyCode, "USD")
    }

    func testMoneyComparison() throws {
        let money1 = try Money(amount: Decimal(10.00), currencyCode: "USD")
        let money2 = try Money(amount: Decimal(20.00), currencyCode: "USD")
        let money3 = try Money(amount: Decimal(10.00), currencyCode: "USD")

        XCTAssertTrue(money1 < money2)
        XCTAssertTrue(money2 > money1)
        XCTAssertEqual(money1, money3)
    }

    func testMoneyDifferentCurrencyAddition() throws {
        let money1 = try Money(amount: Decimal(10.00), currencyCode: "USD")
        let money2 = try Money(amount: Decimal(10.00), currencyCode: "EUR")

        XCTAssertThrows {
            _ = try money1.adding(money2)
        }
    }

    func testMoneyZero() throws {
        let zero = try Money.zero(currencyCode: "USD")
        XCTAssertTrue(zero.isZero)
        XCTAssertFalse(zero.isPositive)
        XCTAssertFalse(zero.isNegative)
        XCTAssertEqual(zero.amountInMinorUnits, 0)
    }

    func testMoneyPositiveNegative() throws {
        let positive = try Money(amountInMinorUnits: 100, currencyCode: "USD")
        let negative = try Money(amountInMinorUnits: -100, currencyCode: "USD")
        let zero = try Money.zero(currencyCode: "USD")

        XCTAssertTrue(positive.isPositive)
        XCTAssertFalse(positive.isNegative)
        XCTAssertFalse(positive.isZero)

        XCTAssertFalse(negative.isPositive)
        XCTAssertTrue(negative.isNegative)
        XCTAssertFalse(negative.isZero)

        XCTAssertFalse(zero.isPositive)
        XCTAssertFalse(zero.isNegative)
        XCTAssertTrue(zero.isZero)
    }

    func testMoneyJPYNoFractionDigits() throws {
        let money = try Money(amount: Decimal(1000), currencyCode: "JPY")
        XCTAssertEqual(money.amountInMinorUnits, 1000)
        XCTAssertEqual(money.amount, Decimal(1000))
    }
}

extension XCTestCase {
    func XCTAssertThrows(
        _ expression: @autoclosure () throws -> some Any,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
    ) {
        XCTAssertThrowsError(try expression(), message(), file: file, line: line)
    }
}

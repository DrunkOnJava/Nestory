// Layer: Foundation

import Foundation
import SwiftData

@Model
public final class Receipt {
    @Attribute(.unique) public var id: UUID
    public var vendor: String
    public var vendorAddress: String?
    public var purchaseDate: Date
    public var receiptNumber: String?
    public var paymentMethod: String?

    public var totalAmount: Int64
    public var totalCurrency: String
    public var taxAmount: Int64?
    public var taxCurrency: String?

    public var rawText: String?
    public var ocrProcessed: Bool
    public var imageFileName: String?

    @Relationship(deleteRule: .nullify)
    public var item: Item?

    public var createdAt: Date
    public var updatedAt: Date

    public init(
        vendor: String,
        total: Money,
        purchaseDate: Date,
        rawText: String? = nil
    ) throws {
        id = UUID()
        self.vendor = vendor
        self.purchaseDate = purchaseDate
        totalAmount = total.amountInMinorUnits
        totalCurrency = total.currencyCode
        self.rawText = rawText
        ocrProcessed = false
        createdAt = Date()
        updatedAt = Date()
    }

    public var total: Money? {
        try? Money(amountInMinorUnits: totalAmount, currencyCode: totalCurrency)
    }

    public var tax: Money? {
        guard let amount = taxAmount,
              let currency = taxCurrency else { return nil }
        return try? Money(amountInMinorUnits: amount, currencyCode: currency)
    }

    public func setTotal(_ money: Money) {
        totalAmount = money.amountInMinorUnits
        totalCurrency = money.currencyCode
        updatedAt = Date()
    }

    public func setTax(_ money: Money?) {
        taxAmount = money?.amountInMinorUnits
        taxCurrency = money?.currencyCode
        updatedAt = Date()
    }

    public var subtotal: Money? {
        guard let total else { return nil }
        if let tax, tax.currencyCode == total.currencyCode {
            return try? total.subtracting(tax)
        }
        return total
    }

    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: purchaseDate)
    }
}

//
// Layer: Services
// Module: InsuranceReport
// Purpose: Format data for insurance reports
//

import Foundation

public struct ReportDataFormatter {
    private let currencyFormatter: NumberFormatter
    private let dateFormatter: DateFormatter

    public init() {
        currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = "USD"

        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
    }

    // MARK: - Summary Generation

    public func generateSummaryItems(items: [Item], categories: [Category]) -> [String] {
        let totalValue = calculateTotalValue(items: items)

        return [
            "Total Items: \(items.count)",
            "Total Categories: \(categories.count)",
            "Total Declared Value: \(formatCurrency(totalValue))",
            "Items with Photos: \(items.count { $0.imageData != nil })",
            "Items with Serial Numbers: \(items.count { $0.serialNumber != nil })",
            "Items with Receipts: \(items.count { $0.receiptImageData != nil })",
            "Items with Warranty: \(items.count { $0.warrantyExpirationDate != nil })",
        ]
    }

    // MARK: - Item Details Generation

    public func generateItemDetails(
        item: Item,
        options: ReportOptions,
    ) -> [String] {
        var details: [String] = []

        // Brand and model
        if let brand = item.brand {
            details.append("Brand: \(brand)")
        }

        if let model = item.modelNumber {
            details.append("Model: \(model)")
        }

        // Serial number if requested
        if options.includeSerialNumbers, let serial = item.serialNumber {
            details.append("Serial: \(serial)")
        }

        // Purchase information if requested
        if options.includePurchaseInfo {
            if let price = item.purchasePrice {
                let formatted = formatCurrency(price, currencyCode: item.currency)
                details.append("Value: \(formatted)")
            }

            if let date = item.purchaseDate {
                details.append("Purchased: \(dateFormatter.string(from: date))")
            }
        }

        // Quantity
        details.append("Quantity: \(item.quantity)")

        // Location (using notes as replacement for room)
        if let notes = item.notes, !notes.isEmpty {
            details.append("Notes: \(notes)")
        }

        // Warranty status
        if let warrantyDate = item.warrantyExpirationDate {
            let status = warrantyDate > Date() ? "Active" : "Expired"
            details.append("Warranty: \(status) until \(dateFormatter.string(from: warrantyDate))")
        }

        // Documentation status
        var docStatus: [String] = []
        if item.imageData != nil { docStatus.append("Photo") }
        if item.receiptImageData != nil { docStatus.append("Receipt") }
        if !item.documentNames.isEmpty { docStatus.append("\(item.documentNames.count) Docs") }

        if !docStatus.isEmpty {
            details.append("Documentation: \(docStatus.joined(separator: ", "))")
        }

        return details
    }

    // MARK: - Value Calculations

    public func calculateTotalValue(items: [Item]) -> Decimal {
        items.reduce(Decimal(0)) { total, item in
            let itemValue = (item.purchasePrice ?? 0) * Decimal(item.quantity)
            return total + itemValue
        }
    }

    public func calculateDepreciatedValue(
        originalValue: Decimal,
        purchaseDate: Date,
        depreciationRate: Double,
    ) -> Decimal {
        let years = Calendar.current.dateComponents([.year], from: purchaseDate, to: Date()).year ?? 0
        let depreciation = Decimal(1 - (depreciationRate * Double(years)))
        return max(originalValue * depreciation, 0)
    }

    // MARK: - Formatting Helpers

    public func formatCurrency(_ value: Decimal, currencyCode: String = "USD") -> String {
        currencyFormatter.currencyCode = currencyCode
        return currencyFormatter.string(from: value as NSNumber) ?? "$0"
    }

    public func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: date)
    }
}

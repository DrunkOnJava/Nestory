//
// Layer: Services
// Module: InsuranceClaim/ClaimDocumentGenerator
// Purpose: Shared helper utilities for claim document generation across all formats
//

import Foundation

public struct ClaimDocumentHelpers {
    // MARK: - Date Formatting

    public static func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Not specified" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    public static func formatDateDetailed(_ date: Date?) -> String {
        guard let date = date else { return "Not specified" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - Currency Formatting

    public static func formatCurrency(_ amount: Decimal?) -> String {
        guard let amount = amount else { return "$0.00" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }

    public static func formatCurrencyCompact(_ amount: Decimal?) -> String {
        guard let amount = amount else { return "$0" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = amount.isInteger ? 0 : 2
        
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }

    // MARK: - Value Calculations

    public static func calculateTotalValue(for items: [Item]) -> Decimal {
        return items.compactMap { $0.purchasePrice }.reduce(0, +)
    }

    public static func calculateAverageValue(for items: [Item]) -> Decimal {
        let prices = items.compactMap { $0.purchasePrice }
        guard !prices.isEmpty else { return 0 }
        
        let total = prices.reduce(0, +)
        return total / Decimal(prices.count)
    }

    public static func calculateCategoryTotals(for items: [Item]) -> [String: Decimal] {
        var categoryTotals: [String: Decimal] = [:]
        
        for item in items {
            let categoryName = item.category?.name ?? "Uncategorized"
            let price = item.purchasePrice ?? 0
            categoryTotals[categoryName, default: 0] += price
        }
        
        return categoryTotals
    }

    // MARK: - Text Processing

    public static func truncateText(_ text: String?, maxLength: Int) -> String {
        guard let text = text else { return "" }
        
        if text.count <= maxLength {
            return text
        }
        
        let truncated = String(text.prefix(maxLength - 3))
        return "\(truncated)..."
    }

    public static func sanitizeFilename(_ filename: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: "\\/:*?\"<>|")
        return filename.components(separatedBy: invalidCharacters).joined(separator: "_")
    }

    // MARK: - Validation

    public static func validateClaimRequest(_ request: ClaimRequest) -> [String] {
        var issues: [String] = []
        
        if request.items.isEmpty {
            issues.append("No items selected for claim")
        }
        
        if request.contactInfo.email.isEmpty && request.contactInfo.phone.isEmpty {
            issues.append("No contact information provided")
        }
        
        // incidentDate is non-optional, so no need to check for nil
        
        let itemsWithoutPrice = request.items.filter { $0.purchasePrice == nil }
        if !itemsWithoutPrice.isEmpty {
            issues.append("\(itemsWithoutPrice.count) items missing purchase price")
        }
        
        return issues
    }

    // MARK: - String Utilities

    public static func capitalizeFirstLetter(_ string: String) -> String {
        guard !string.isEmpty else { return string }
        return string.prefix(1).capitalized + string.dropFirst()
    }

    public static func formatMultilineText(_ text: String?, indentLevel: Int = 0) -> String {
        guard let text = text else { return "" }
        
        let indent = String(repeating: " ", count: indentLevel * 2)
        return text.components(separatedBy: .newlines)
            .map { "\(indent)\($0)" }
            .joined(separator: "\n")
    }

    // MARK: - Item Analysis

    public static func findHighestValueItems(_ items: [Item], count: Int = 5) -> [Item] {
        return items
            .filter { $0.purchasePrice != nil }
            .sorted { ($0.purchasePrice ?? 0) > ($1.purchasePrice ?? 0) }
            .prefix(count)
            .map { $0 }
    }

    public static func findItemsByCategory(_ items: [Item], category: String) -> [Item] {
        return items.filter { $0.category?.name == category }
    }

    public static func getItemStatistics(_ items: [Item]) -> ItemStatistics {
        let prices = items.compactMap { $0.purchasePrice }
        
        return ItemStatistics(
            totalItems: items.count,
            itemsWithPrices: prices.count,
            totalValue: prices.reduce(0, +),
            averageValue: prices.isEmpty ? 0 : prices.reduce(0, +) / Decimal(prices.count),
            minValue: prices.min() ?? 0,
            maxValue: prices.max() ?? 0,
            categoryCounts: calculateCategoryCounts(items),
            conditionCounts: calculateConditionCounts(items)
        )
    }

    // MARK: - Private Helpers

    private static func calculateCategoryCounts(_ items: [Item]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for item in items {
            let categoryName = item.category?.name ?? "Uncategorized"
            counts[categoryName, default: 0] += 1
        }
        return counts
    }

    private static func calculateConditionCounts(_ items: [Item]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for item in items {
            let conditionName = item.condition
            counts[conditionName, default: 0] += 1
        }
        return counts
    }
}

// MARK: - Supporting Types

public struct ItemStatistics {
    public let totalItems: Int
    public let itemsWithPrices: Int
    public let totalValue: Decimal
    public let averageValue: Decimal
    public let minValue: Decimal
    public let maxValue: Decimal
    public let categoryCounts: [String: Int]
    public let conditionCounts: [String: Int]
}

// MARK: - Extensions

private extension Decimal {
    var isInteger: Bool {
        return self.truncatingRemainder(dividingBy: 1) == 0
    }
}
//
// Layer: Services
// Module: ReceiptOCR
// Purpose: Extract and match items from receipt text
//

import Foundation

public struct ReceiptItemExtractor {
    private let parser = ReceiptDataParser()

    public init() {}

    public struct ExtractedItem {
        public let name: String
        public let price: Decimal?
        public let quantity: Int?

        public init(name: String, price: Decimal?, quantity: Int?) {
            self.name = name
            self.price = price
            self.quantity = quantity
        }
    }

    // MARK: - Item Extraction

    public func extractItems(from lines: [String]) -> [ExtractedItem] {
        var items: [ExtractedItem] = []

        for line in lines {
            // Skip lines that are likely headers or totals
            if shouldSkipLine(line) {
                continue
            }

            // Look for lines with prices
            if let price = parser.extractPrice(from: line) {
                if let itemName = extractItemName(from: line) {
                    // Try to extract quantity if present
                    let quantity = parser.extractQuantity(from: itemName)

                    items.append(ExtractedItem(
                        name: parser.cleanItemName(itemName),
                        price: price,
                        quantity: quantity,
                    ))
                }
            }
        }

        return items
    }

    private func shouldSkipLine(_ line: String) -> Bool {
        let lowercased = line.lowercased()
        let skipKeywords = [
            "total", "tax", "subtotal", "payment",
            "change", "balance", "amount due", "visa",
            "mastercard", "amex", "debit", "credit",
            "cash", "thank you", "receipt",
        ]

        return skipKeywords.contains { lowercased.contains($0) }
    }

    private func extractItemName(from line: String) -> String? {
        // Extract item name (everything before the price)
        let pricePattern = "\\$?\\s*\\d{1,5}[,.]?\\d{0,2}"

        guard let regex = try? NSRegularExpression(pattern: pricePattern, options: []) else {
            return nil
        }

        guard let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) else {
            return nil
        }

        guard let range = Range(match.range, in: line) else {
            return nil
        }

        let itemName = String(line[..<range.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return (!itemName.isEmpty && itemName.count > 2) ? itemName : nil
    }

    // MARK: - Item Matching

    public func findMatchingItem(_ itemName: String, in items: [ExtractedItem]) -> ExtractedItem? {
        let lowercasedName = itemName.lowercased()

        // Try exact match first
        if let exact = items.first(where: { $0.name.lowercased() == lowercasedName }) {
            return exact
        }

        // Try partial match
        return items.first { item in
            let itemNameLower = item.name.lowercased()
            return itemNameLower.contains(lowercasedName) ||
                lowercasedName.contains(itemNameLower)
        }
    }

    // MARK: - Smart Matching

    public func calculateSimilarity(between text1: String, and text2: String) -> Double {
        let s1 = text1.lowercased()
        let s2 = text2.lowercased()

        if s1 == s2 { return 1.0 }

        let longer = s1.count > s2.count ? s1 : s2
        let shorter = s1.count > s2.count ? s2 : s1

        if longer.isEmpty { return 0.0 }

        let editDistance = levenshteinDistance(shorter, longer)
        return Double(longer.count - editDistance) / Double(longer.count)
    }

    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let m = s1.count
        let n = s2.count

        if m == 0 { return n }
        if n == 0 { return m }

        var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        for i in 1 ... m {
            matrix[i][0] = i
        }

        for j in 1 ... n {
            matrix[0][j] = j
        }

        for i in 1 ... m {
            for j in 1 ... n {
                let cost = s1[s1.index(s1.startIndex, offsetBy: i - 1)] ==
                    s2[s2.index(s2.startIndex, offsetBy: j - 1)] ? 0 : 1

                matrix[i][j] = min(
                    matrix[i - 1][j] + 1, // deletion
                    matrix[i][j - 1] + 1, // insertion
                    matrix[i - 1][j - 1] + cost, // substitution
                )
            }
        }

        return matrix[m][n]
    }
}

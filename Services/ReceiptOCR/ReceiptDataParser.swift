//
// Layer: Services
// Module: ReceiptOCR
// Purpose: Parse receipt text data into structured format
//

import Foundation

public struct ReceiptDataParser {
    
    // MARK: - Store Name Extraction
    
    public func extractStoreName(from lines: [String]) -> String? {
        // Look for common patterns in first 5 lines
        let headerLines = Array(lines.prefix(5))
        
        for line in headerLines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            // Skip common receipt headers
            if !trimmed.isEmpty,
               !trimmed.lowercased().contains("receipt"),
               !trimmed.lowercased().contains("invoice"),
               !trimmed.contains(where: \.isNumber),
               trimmed.count > 3 {
                return trimmed
            }
        }
        
        return nil
    }
    
    // MARK: - Date Extraction
    
    public func extractDate(from text: String) -> Date? {
        // Common date patterns in receipts
        let datePatterns = [
            "\\d{1,2}/\\d{1,2}/\\d{2,4}",  // MM/DD/YYYY or M/D/YY
            "\\d{1,2}-\\d{1,2}-\\d{2,4}",   // MM-DD-YYYY
            "\\d{4}-\\d{1,2}-\\d{1,2}",     // YYYY-MM-DD
            "\\w{3} \\d{1,2}, \\d{4}",      // Jan 1, 2024
            "\\d{1,2} \\w{3} \\d{4}"        // 1 Jan 2024
        ]
        
        for pattern in datePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
                
                for match in matches {
                    if let range = Range(match.range, in: text) {
                        let dateString = String(text[range])
                        if let date = parseDate(dateString) {
                            return date
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatters = [
            "MM/dd/yyyy", "M/d/yyyy", "MM/dd/yy", "M/d/yy",
            "MM-dd-yyyy", "M-d-yyyy", "yyyy-MM-dd",
            "MMM d, yyyy", "d MMM yyyy"
        ]
        
        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US")
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
    
    // MARK: - Price Extraction
    
    public func extractTotalAmount(from lines: [String]) -> Decimal? {
        // Look for total indicators
        let totalIndicators = ["total", "amount due", "balance due", "grand total", "subtotal"]
        
        for line in lines {
            let lowercased = line.lowercased()
            
            for indicator in totalIndicators {
                if lowercased.contains(indicator) {
                    // Extract price from this line
                    if let amount = extractPrice(from: line) {
                        return amount
                    }
                }
            }
        }
        
        // Fallback: look for largest amount in receipt
        let allAmounts = lines.compactMap { extractPrice(from: $0) }
        return allAmounts.max()
    }
    
    public func extractPrice(from text: String) -> Decimal? {
        // Match common price patterns
        let pricePattern = "\\$?\\s*(\\d{1,5}[,.]?\\d{0,2})"
        
        if let regex = try? NSRegularExpression(pattern: pricePattern, options: []) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            for match in matches.reversed() { // Check from end of line first
                if let range = Range(match.range(at: 1), in: text) {
                    let priceString = String(text[range])
                        .replacingOccurrences(of: ",", with: "")
                        .replacingOccurrences(of: " ", with: "")
                    
                    if let decimal = Decimal(string: priceString) {
                        return decimal
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Quantity Extraction
    
    public func extractQuantity(from text: String) -> Int? {
        // Look for patterns like "2x", "x2", "qty 2", etc.
        let patterns = [
            "(\\d+)\\s*x",      // 2x
            "x\\s*(\\d+)",      // x2
            "qty\\s*(\\d+)",    // qty 2
            "^(\\d+)\\s+"       // 2 at start
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                if let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                    if let range = Range(match.range(at: 1), in: text) {
                        return Int(text[range])
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Item Name Cleaning
    
    public func cleanItemName(_ name: String) -> String {
        // Remove quantity indicators and clean up
        var cleaned = name
        let quantityPatterns = ["\\d+\\s*x", "x\\s*\\d+", "qty\\s*\\d+", "^\\d+\\s+"]
        
        for pattern in quantityPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                cleaned = regex.stringByReplacingMatches(
                    in: cleaned,
                    range: NSRange(cleaned.startIndex..., in: cleaned),
                    withTemplate: ""
                )
            }
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
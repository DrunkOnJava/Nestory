//
// Layer: Services
// Module: ReceiptOCR
// Purpose: Extract text from receipt images using Vision framework
//
// REMINDER: This service is WIRED UP in ItemDetailView via "Add Receipt" button
// The ReceiptCaptureView is presented as a sheet from ItemDetailView
// Always ensure new services are accessible from the UI!

import Foundation
import SwiftUI
import Vision
import VisionKit

@MainActor
public final class ReceiptOCRService: ObservableObject {
    
    public enum OCRError: LocalizedError {
        case imageProcessingFailed
        case textRecognitionFailed
        case noTextFound
        
        public var errorDescription: String? {
            switch self {
            case .imageProcessingFailed:
                return "Failed to process the image"
            case .textRecognitionFailed:
                return "Failed to recognize text in the image"
            case .noTextFound:
                return "No text found in the image"
            }
        }
    }
    
    public struct ReceiptData {
        public let fullText: String
        public let storeName: String?
        public let date: Date?
        public let totalAmount: Decimal?
        public let items: [ExtractedItem]
        
        public struct ExtractedItem {
            public let name: String
            public let price: Decimal?
            public let quantity: Int?
        }
    }
    
    @Published public var isProcessing = false
    @Published public var lastError: Error?
    
    public init() {}
    
    // MARK: - OCR Processing
    
    public func extractTextFromImage(_ imageData: Data) async throws -> String {
        guard let uiImage = UIImage(data: imageData) else {
            throw OCRError.imageProcessingFailed
        }
        
        guard let cgImage = uiImage.cgImage else {
            throw OCRError.imageProcessingFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: OCRError.textRecognitionFailed)
                    return
                }
                
                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                if recognizedStrings.isEmpty {
                    continuation.resume(throwing: OCRError.noTextFound)
                } else {
                    let fullText = recognizedStrings.joined(separator: "\n")
                    continuation.resume(returning: fullText)
                }
            }
            
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Receipt Parsing
    
    public func parseReceiptData(from text: String) -> ReceiptData {
        let lines = text.components(separatedBy: .newlines)
        
        // Extract store name (usually in first few lines)
        let storeName = extractStoreName(from: lines)
        
        // Extract date
        let date = extractDate(from: text)
        
        // Extract total amount
        let totalAmount = extractTotalAmount(from: lines)
        
        // Extract individual items
        let items = extractItems(from: lines)
        
        return ReceiptData(
            fullText: text,
            storeName: storeName,
            date: date,
            totalAmount: totalAmount,
            items: items
        )
    }
    
    private func extractStoreName(from lines: [String]) -> String? {
        // Look for common patterns in first 5 lines
        let headerLines = Array(lines.prefix(5))
        
        for line in headerLines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            // Skip common receipt headers
            if !trimmed.isEmpty &&
               !trimmed.lowercased().contains("receipt") &&
               !trimmed.lowercased().contains("invoice") &&
               !trimmed.contains(where: { $0.isNumber }) &&
               trimmed.count > 3 {
                return trimmed
            }
        }
        
        return nil
    }
    
    private func extractDate(from text: String) -> Date? {
        // Common date patterns in receipts
        let datePatterns = [
            "\\d{1,2}/\\d{1,2}/\\d{2,4}",  // MM/DD/YYYY or M/D/YY
            "\\d{1,2}-\\d{1,2}-\\d{2,4}",  // MM-DD-YYYY
            "\\d{4}-\\d{1,2}-\\d{1,2}",    // YYYY-MM-DD
            "\\w{3} \\d{1,2}, \\d{4}",     // Jan 1, 2024
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
    
    private func extractTotalAmount(from lines: [String]) -> Decimal? {
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
    
    private func extractPrice(from text: String) -> Decimal? {
        // Match common price patterns
        let pricePattern = "\\$?\\s*(\\d{1,5}[,.]?\\d{0,2})"
        
        if let regex = try? NSRegularExpression(pattern: pricePattern, options: []) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            for match in matches.reversed() {  // Check from end of line first
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
    
    private func extractItems(from lines: [String]) -> [ReceiptData.ExtractedItem] {
        var items: [ReceiptData.ExtractedItem] = []
        
        for line in lines {
            // Skip lines that are likely headers or totals
            let lowercased = line.lowercased()
            if lowercased.contains("total") ||
               lowercased.contains("tax") ||
               lowercased.contains("subtotal") ||
               lowercased.contains("payment") ||
               lowercased.contains("change") {
                continue
            }
            
            // Look for lines with prices
            if let price = extractPrice(from: line) {
                // Extract item name (everything before the price)
                let pricePattern = "\\$?\\s*\\d{1,5}[,.]?\\d{0,2}"
                if let regex = try? NSRegularExpression(pattern: pricePattern, options: []) {
                    if let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                        if let range = Range(match.range, in: line) {
                            let itemName = String(line[..<range.lowerBound])
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            if !itemName.isEmpty && itemName.count > 2 {
                                // Try to extract quantity if present
                                let quantity = extractQuantity(from: itemName)
                                
                                items.append(ReceiptData.ExtractedItem(
                                    name: cleanItemName(itemName),
                                    price: price,
                                    quantity: quantity
                                ))
                            }
                        }
                    }
                }
            }
        }
        
        return items
    }
    
    private func extractQuantity(from text: String) -> Int? {
        // Look for patterns like "2x", "x2", "qty 2", etc.
        let patterns = [
            "(\\d+)\\s*x",  // 2x
            "x\\s*(\\d+)",  // x2
            "qty\\s*(\\d+)", // qty 2
            "^(\\d+)\\s+"   // 2 at start
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
    
    private func cleanItemName(_ name: String) -> String {
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
    
    // MARK: - Smart Data Extraction
    
    public func autoFillItemFromReceipt(_ receiptData: ReceiptData, for item: Item) {
        // Update item with extracted data
        if let storeName = receiptData.storeName, item.brand == nil {
            item.brand = storeName
        }
        
        if let date = receiptData.date, item.purchaseDate == nil {
            item.purchaseDate = date
        }
        
        if let total = receiptData.totalAmount, item.purchasePrice == nil {
            // If single item, use total
            if receiptData.items.count == 1 {
                item.purchasePrice = total
            } else if let matchingItem = findMatchingItem(item.name, in: receiptData.items) {
                item.purchasePrice = matchingItem.price
            }
        }
        
        // Store the full text for reference
        item.extractedReceiptText = receiptData.fullText
        
        // Add receipt info to notes
        var notesAddition = "\n--- Receipt Data ---"
        if let storeName = receiptData.storeName {
            notesAddition += "\nStore: \(storeName)"
        }
        if let date = receiptData.date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            notesAddition += "\nPurchase Date: \(formatter.string(from: date))"
        }
        if let total = receiptData.totalAmount {
            notesAddition += "\nTotal: $\(total)"
        }
        
        item.notes = (item.notes ?? "") + notesAddition
    }
    
    private func findMatchingItem(_ itemName: String, in items: [ReceiptData.ExtractedItem]) -> ReceiptData.ExtractedItem? {
        let lowercasedName = itemName.lowercased()
        
        // Try exact match first
        if let exact = items.first(where: { $0.name.lowercased() == lowercasedName }) {
            return exact
        }
        
        // Try partial match
        return items.first { item in
            item.name.lowercased().contains(lowercasedName) ||
            lowercasedName.contains(item.name.lowercased())
        }
    }
}

// MARK: - Document Scanner View

@available(iOS 16.0, *)
public struct DocumentScannerView: UIViewControllerRepresentable {
    @Binding var scannedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    public func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    public func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate, @unchecked Sendable {
        let parent: DocumentScannerView
        
        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }
        
        @MainActor
        private func handleDismiss() {
            parent.dismiss()
        }
        
        @MainActor
        private func handleScan(_ image: UIImage) {
            parent.scannedImage = image
            parent.dismiss()
        }
        
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                Task { @MainActor in
                    self.handleDismiss()
                }
                return
            }
            
            let image = scan.imageOfPage(at: 0)
            Task { @MainActor in
                self.handleScan(image)
            }
        }
        
        public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            Task { @MainActor in
                self.handleDismiss()
            }
        }
        
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            Task { @MainActor in
                self.handleDismiss()
            }
        }
    }
}
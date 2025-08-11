//
// Layer: Services
// Module: ReceiptOCR
// Purpose: Main receipt OCR service coordinator
//
// REMINDER: This service is WIRED UP in ItemDetailView via "Add Receipt" button
// The ReceiptCaptureView is presented as a sheet from ItemDetailView
// Always ensure new services are accessible from the UI!

import Foundation
import SwiftUI

@MainActor
public final class ReceiptOCRService: ObservableObject {
    
    // MARK: - Types
    
    public struct ReceiptData {
        public let fullText: String
        public let storeName: String?
        public let date: Date?
        public let totalAmount: Decimal?
        public let items: [ReceiptItemExtractor.ExtractedItem]
        
        public init(
            fullText: String,
            storeName: String?,
            date: Date?,
            totalAmount: Decimal?,
            items: [ReceiptItemExtractor.ExtractedItem]
        ) {
            self.fullText = fullText
            self.storeName = storeName
            self.date = date
            self.totalAmount = totalAmount
            self.items = items
        }
    }
    
    // MARK: - Properties
    
    @Published public var isProcessing = false
    @Published public var lastError: Error?
    
    private let textExtractor = VisionTextExtractor()
    private let dataParser = ReceiptDataParser()
    private let itemExtractor = ReceiptItemExtractor()
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - OCR Processing
    
    public func extractTextFromImage(_ imageData: Data) async throws -> String {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            let text = try await textExtractor.extractText(from: imageData)
            lastError = nil
            return text
        } catch {
            lastError = error
            throw error
        }
    }
    
    // MARK: - Receipt Parsing
    
    public func parseReceiptData(from text: String) -> ReceiptData {
        let lines = text.components(separatedBy: .newlines)
        
        // Extract store name (usually in first few lines)
        let storeName = dataParser.extractStoreName(from: lines)
        
        // Extract date
        let date = dataParser.extractDate(from: text)
        
        // Extract total amount
        let totalAmount = dataParser.extractTotalAmount(from: lines)
        
        // Extract individual items
        let items = itemExtractor.extractItems(from: lines)
        
        return ReceiptData(
            fullText: text,
            storeName: storeName,
            date: date,
            totalAmount: totalAmount,
            items: items
        )
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
            } else if let matchingItem = itemExtractor.findMatchingItem(
                item.name,
                in: receiptData.items
            ) {
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
    
    // MARK: - Convenience Methods
    
    public func processReceiptImage(_ imageData: Data, for item: Item) async throws {
        let text = try await extractTextFromImage(imageData)
        let receiptData = parseReceiptData(from: text)
        autoFillItemFromReceipt(receiptData, for: item)
    }
}
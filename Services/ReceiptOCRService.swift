//
// Layer: Services
// Module: ReceiptOCR
// Purpose: Enhanced receipt OCR service with machine learning processing
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
    @Published public var processingStage: ProcessingStage = .idle
    @Published public var confidenceScore = 0.0

    // Legacy processors (kept for fallback)
    private let textExtractor = VisionTextExtractor()
    private let dataParser = ReceiptDataParser()
    private let itemExtractor = ReceiptItemExtractor()

    // Enhanced ML processors
    private let mlProcessor: MLReceiptProcessor?
    private let appleFrameworksProcessor: AppleFrameworksReceiptProcessor?

    // MARK: - Initialization

    public init() {
        // Initialize Apple frameworks processor (preferred)
        self.appleFrameworksProcessor = AppleFrameworksReceiptProcessor()

        // Initialize custom ML processor as fallback
        do {
            self.mlProcessor = try MLReceiptProcessor()
        } catch {
            print("Failed to initialize ML processor: \(error). Falling back to legacy processing.")
            self.mlProcessor = nil
        }
    }

    // MARK: - Processing Stages

    public enum ProcessingStage: String, CaseIterable, Sendable {
        case idle = "Ready"
        case documentDetection = "Detecting Document"
        case perspectiveCorrection = "Correcting Perspective"
        case ocrProcessing = "Extracting Text"
        case dataExtraction = "Parsing Data"
        case categoryClassification = "Classifying Categories"
        case confidenceCalculation = "Calculating Confidence"
        case completed = "Processing Complete"
        case failed = "Processing Failed"

        public var description: String {
            rawValue
        }
    }

    // MARK: - Enhanced OCR Processing

    /// Enhanced receipt processing using machine learning
    public func processReceiptImage(_ image: UIImage) async throws -> EnhancedReceiptData {
        isProcessing = true
        processingStage = .documentDetection
        defer {
            isProcessing = false
            processingStage = .idle
        }

        do {
            // Try Apple frameworks processor first (most advanced)
            if let appleProcessor = appleFrameworksProcessor {
                let result = try await appleProcessor.processReceiptImage(image)
                processingStage = .completed
                confidenceScore = result.confidence
                lastError = nil
                return result
            }
            // Fallback to custom ML processor
            else if let mlProcessor {
                let result = try await mlProcessor.processReceiptImage(image)
                processingStage = .completed
                confidenceScore = result.confidence
                lastError = nil
                return result
            }
            // Final fallback to legacy processing
            else {
                return try await processReceiptImageLegacy(image)
            }
        } catch {
            processingStage = .failed
            lastError = error
            throw error
        }
    }

    /// Legacy OCR processing for fallback
    private func processReceiptImageLegacy(_ image: UIImage) async throws -> EnhancedReceiptData {
        processingStage = .ocrProcessing

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ReceiptProcessingError.invalidImage
        }

        let text = try await extractTextFromImage(imageData)

        processingStage = .dataExtraction
        let receiptData = parseReceiptData(from: text)

        processingStage = .categoryClassification
        // Basic category classification for legacy mode
        let categories = classifyReceiptLegacy(vendor: receiptData.storeName, text: text)

        processingStage = .confidenceCalculation
        let confidence = calculateLegacyConfidence(receiptData)

        return EnhancedReceiptData(
            vendor: receiptData.storeName,
            total: receiptData.totalAmount,
            tax: nil, // Legacy doesn't extract tax
            date: receiptData.date,
            items: receiptData.items.map {
                ReceiptItem(name: $0.name, price: $0.price ?? 0, quantity: $0.quantity ?? 1)
            },
            categories: categories,
            confidence: confidence,
            rawText: text,
            boundingBoxes: [],
            processingMetadata: ReceiptProcessingMetadata(
                documentCorrectionApplied: false,
                patternsMatched: [:],
                mlClassifierUsed: false
            )
        )
    }

    // MARK: - Legacy OCR Processing

    public func extractTextFromImage(_ imageData: Data) async throws -> String {
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
            items: items,
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
                in: receiptData.items,
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

    // MARK: - Receipt Model Integration

    /// Create a Receipt model from extracted data
    public func createReceipt(from receiptData: ReceiptData, imageData: Data? = nil, for item: Item) -> Receipt? {
        guard let vendor = receiptData.storeName,
              let date = receiptData.date,
              let totalAmount = receiptData.totalAmount
        else {
            return nil
        }

        let money = Money(amount: totalAmount, currencyCode: "USD")
        let receipt = Receipt(vendor: vendor, total: money, purchaseDate: date, item: item)

        // Set additional data
        receipt.setOCRResults(
            text: receiptData.fullText,
            confidence: calculateConfidence(for: receiptData),
            categories: detectCategories(from: receiptData)
        )

        if let imageData {
            receipt.setImageData(imageData, fileName: "receipt_\(receipt.id.uuidString).jpg")
        }

        return receipt
    }

    /// Calculate confidence score based on extracted data completeness
    private func calculateConfidence(for receiptData: ReceiptData) -> Double {
        var score = 0.0

        // Base score for having text
        score += 0.2

        // Vendor name found
        if receiptData.storeName != nil { score += 0.3 }

        // Date found
        if receiptData.date != nil { score += 0.2 }

        // Total amount found
        if receiptData.totalAmount != nil { score += 0.2 }

        // Items found
        if !receiptData.items.isEmpty { score += 0.1 }

        return min(score, 1.0)
    }

    // MARK: - Legacy Helper Methods

    /// Legacy category classification for fallback mode
    private func classifyReceiptLegacy(vendor: String?, text: String) -> [String] {
        var categories: [String] = []

        // Simple vendor-based classification
        if let vendor = vendor?.lowercased() {
            if vendor.contains("walmart") || vendor.contains("kroger") || vendor.contains("safeway") {
                categories.append("Grocery")
            } else if vendor.contains("home depot") || vendor.contains("lowes") {
                categories.append("Home Improvement")
            } else if vendor.contains("best buy") || vendor.contains("apple") {
                categories.append("Electronics")
            } else if vendor.contains("cvs") || vendor.contains("walgreens") {
                categories.append("Health & Pharmacy")
            }
        }

        // Keyword-based classification
        let lowercaseText = text.lowercased()
        if lowercaseText.contains("grocery") || lowercaseText.contains("produce") {
            categories.append("Grocery")
        }
        if lowercaseText.contains("electronics") || lowercaseText.contains("computer") {
            categories.append("Electronics")
        }
        if lowercaseText.contains("pharmacy") || lowercaseText.contains("prescription") {
            categories.append("Health & Pharmacy")
        }

        return Array(Set(categories)) // Remove duplicates
    }

    /// Calculate confidence for legacy processing
    private func calculateLegacyConfidence(_ receiptData: ReceiptData) -> Double {
        var confidence = 0.4 // Base confidence for legacy processing

        if receiptData.storeName != nil { confidence += 0.2 }
        if receiptData.date != nil { confidence += 0.2 }
        if receiptData.totalAmount != nil { confidence += 0.15 }
        if !receiptData.items.isEmpty { confidence += 0.05 }

        return min(confidence, 1.0)
    }

    /// Detect receipt categories based on content
    private func detectCategories(from receiptData: ReceiptData) -> [String] {
        var categories: [String] = []
        let text = receiptData.fullText.lowercased()
        let storeName = receiptData.storeName?.lowercased() ?? ""

        // Grocery/Food
        if text.contains("grocery") || text.contains("food") || text.contains("market") ||
            storeName.contains("grocery") || storeName.contains("market") ||
            text.contains("produce") || text.contains("dairy")
        {
            categories.append("Grocery")
        }

        // Electronics
        if text.contains("electronics") || text.contains("computer") || text.contains("phone") ||
            storeName.contains("electronic") || storeName.contains("tech") ||
            text.contains("software") || text.contains("hardware")
        {
            categories.append("Electronics")
        }

        // Clothing
        if text.contains("clothing") || text.contains("apparel") || text.contains("shirt") ||
            storeName.contains("clothing") || storeName.contains("fashion") ||
            text.contains("pants") || text.contains("dress")
        {
            categories.append("Clothing")
        }

        // Home improvement
        if text.contains("hardware") || text.contains("tools") || text.contains("lumber") ||
            storeName.contains("hardware") || storeName.contains("depot")
        {
            categories.append("Home Improvement")
        }

        return categories
    }

    // MARK: - Convenience Methods

    public func processReceiptImage(_ imageData: Data, for item: Item) async throws {
        let text = try await extractTextFromImage(imageData)
        let receiptData = parseReceiptData(from: text)
        autoFillItemFromReceipt(receiptData, for: item)
    }

    /// Process receipt and create proper Receipt model
    public func processReceiptImageAndCreateModel(_ imageData: Data, for item: Item) async throws -> Receipt? {
        let text = try await extractTextFromImage(imageData)
        let receiptData = parseReceiptData(from: text)

        // Create receipt model if we have enough data
        if let receipt = createReceipt(from: receiptData, imageData: imageData, for: item) {
            // Also auto-fill the item if confidence is high
            if receipt.isReliable {
                autoFillItemFromReceipt(receiptData, for: item)
            }
            return receipt
        }

        // Fallback to old behavior if we can't create a proper receipt
        autoFillItemFromReceipt(receiptData, for: item)
        return nil
    }
}

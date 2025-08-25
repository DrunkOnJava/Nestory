//
// Layer: Services
// Module: ReceiptOCR
// Purpose: Apple frameworks-native receipt processing using VisionKit, Vision, and Natural Language
//

import Foundation
import UIKit
import Vision
import VisionKit
import NaturalLanguage
import CoreML

@MainActor
public final class AppleFrameworksReceiptProcessor: ObservableObject, @unchecked Sendable {
    // MARK: - Apple Framework Components

    private let nlTagger: NLTagger
    private let languageRecognizer: NLLanguageRecognizer
    private let tokenizer: NLTokenizer

    public init() {
        // Initialize Natural Language components
        self.nlTagger = NLTagger(tagSchemes: [.nameType, .lexicalClass, .tokenType])
        self.languageRecognizer = NLLanguageRecognizer()
        self.tokenizer = NLTokenizer(unit: .word)
    }

    // MARK: - Enhanced Receipt Processing

    public func processReceiptImage(_ image: UIImage) async throws -> EnhancedReceiptData {
        guard let cgImage = image.cgImage else {
            throw ReceiptProcessingError.invalidImage
        }

        // Step 1: Document detection and correction
        let processedImage = try await detectAndProcessDocument(cgImage)

        // Step 2: Enhanced OCR with Apple frameworks
        let recognizedText = try await performAdvancedTextRecognition(processedImage)

        // Step 3: Natural Language processing
        let structuredData = try await extractStructuredDataWithNL(recognizedText)

        // Step 4: Apple ML-based categorization
        let categories = try await classifyWithAppleML(recognizedText, structuredData: structuredData)

        // Step 5: Confidence calculation
        let confidence = calculateConfidenceScore(structuredData, recognizedText)

        return EnhancedReceiptData(
            vendor: structuredData.vendor,
            total: structuredData.total,
            tax: structuredData.tax,
            date: structuredData.date,
            items: structuredData.items,
            categories: categories,
            confidence: confidence,
            rawText: recognizedText.fullText,
            boundingBoxes: recognizedText.boundingBoxes,
            processingMetadata: ReceiptProcessingMetadata(
                documentCorrectionApplied: processedImage != cgImage,
                patternsMatched: structuredData.patternsMatched,
                mlClassifierUsed: true
            )
        )
    }

    // MARK: - Document Detection (iOS 16+)

    private func detectAndProcessDocument(_ image: CGImage) async throws -> CGImage {
        // For now, skip document correction and return the original image
        // Document segmentation APIs have complex iOS version dependencies
        image
    }

    // MARK: - Advanced Text Recognition

    private func performAdvancedTextRecognition(_ image: CGImage) async throws -> RecognizedText {
        try await withCheckedThrowingContinuation { continuation in
            let textRecognitionRequest = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                var fullText: [String] = []
                var boundingBoxes: [CGRect] = []
                var confidenceScores: [Float] = []

                for observation in observations {
                    if let candidate = observation.topCandidates(1).first,
                       candidate.confidence > 0.5
                    {
                        fullText.append(candidate.string)
                        boundingBoxes.append(observation.boundingBox)
                        confidenceScores.append(candidate.confidence)
                    }
                }

                let result = RecognizedText(
                    fullText: fullText.joined(separator: "\n"),
                    lines: fullText,
                    boundingBoxes: boundingBoxes,
                    confidenceScores: confidenceScores
                )

                continuation.resume(returning: result)
            }

            // Configure advanced text recognition
            textRecognitionRequest.recognitionLevel = .accurate
            textRecognitionRequest.usesLanguageCorrection = true
            textRecognitionRequest.minimumTextHeight = 0.015 // Optimize for receipt text
            textRecognitionRequest.customWords = Self.receiptVocabulary

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([textRecognitionRequest])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Natural Language Processing

    private func extractStructuredDataWithNL(_ recognizedText: RecognizedText) async throws -> StructuredReceiptData {
        let text = recognizedText.fullText

        // Set up Natural Language tagger
        nlTagger.string = text

        // Extract vendor using named entity recognition
        let vendor = extractVendorWithNL(text)

        // Extract monetary values using linguistic analysis
        let (total, tax) = extractMonetaryValuesWithNL(text)

        // Extract date using NL date detection
        let date = extractDateWithNL(text)

        // Extract items using tokenization and tagging
        let items = extractItemsWithNL(recognizedText)

        return StructuredReceiptData(
            vendor: vendor,
            total: total,
            tax: tax,
            date: date,
            items: items,
            patternsMatched: [
                "vendor": vendor != nil,
                "total": total != nil,
                "tax": tax != nil,
                "date": date != nil,
                "items": !items.isEmpty,
            ]
        )
    }

    private func extractVendorWithNL(_ text: String) -> String? {
        nlTagger.string = text

        // Look for organization names in the first few lines
        let lines = text.components(separatedBy: .newlines).prefix(5)

        for line in lines {
            nlTagger.string = line

            // Use named entity recognition to find organizations
            var organizationName: String?
            let stringRange = line.startIndex ..< line.endIndex
            nlTagger.enumerateTags(in: stringRange, unit: .word, scheme: .nameType) { tag, tokenRange in
                if tag == .organizationName {
                    let substring = String(line[tokenRange])
                    if substring.count > 2 {
                        organizationName = substring
                        return false // Stop enumeration
                    }
                }
                return true
            }

            if let name = organizationName {
                return name
            }
        }

        // Fallback to first substantial line
        for line in lines {
            let cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleaned.count > 3, !cleaned.isNumeric {
                return cleaned
            }
        }

        return nil
    }

    private func extractMonetaryValuesWithNL(_ text: String) -> (total: Decimal?, tax: Decimal?) {
        let lines = text.components(separatedBy: .newlines)
        var total: Decimal?
        var tax: Decimal?

        // Use Natural Language to identify currency mentions
        nlTagger.string = text
        let fullRange = NSRange(location: 0, length: text.count)

        // Enhanced pattern matching with NL context
        for line in lines.reversed() { // Start from bottom for totals
            let lowerLine = line.lowercased()

            // Total detection with linguistic context
            if lowerLine.contains("total") || lowerLine.contains("amount due") || lowerLine.contains("balance") {
                if let amount = extractDecimalFromLine(line) {
                    total = amount
                }
            }

            // Tax detection
            if lowerLine.contains("tax") || lowerLine.contains("hst") || lowerLine.contains("gst") {
                if let amount = extractDecimalFromLine(line) {
                    tax = amount
                }
            }
        }

        return (total, tax)
    }

    private func extractDateWithNL(_ text: String) -> Date? {
        // Use Natural Language to identify date-like tokens
        tokenizer.string = text
        let tokens = tokenizer.tokens(for: text.startIndex ..< text.endIndex)

        let dateFormatter = DateFormatter()
        let formats = [
            "MM/dd/yyyy", "MM/dd/yy", "M/d/yyyy", "M/d/yy",
            "yyyy-MM-dd", "dd/MM/yyyy", "dd.MM.yyyy",
            "MMM dd, yyyy", "MMMM dd, yyyy",
            "dd MMM yyyy", "dd MMMM yyyy",
        ]

        for tokenRange in tokens {
            let tokenText = String(text[tokenRange])

            // Check if token contains date-like patterns
            if tokenText.contains("/") || tokenText.contains("-") || tokenText.contains(".") {
                for format in formats {
                    dateFormatter.dateFormat = format
                    if let date = dateFormatter.date(from: tokenText) {
                        return date
                    }
                }
            }
        }

        return nil
    }

    private func extractItemsWithNL(_ recognizedText: RecognizedText) -> [ReceiptItem] {
        var items: [ReceiptItem] = []

        for (index, line) in recognizedText.lines.enumerated() {
            // Use NL tagging to identify product-like text
            nlTagger.string = line

            var hasProductName = false
            let stringRange = line.startIndex ..< line.endIndex
            nlTagger.enumerateTags(in: stringRange, unit: .word, scheme: .lexicalClass) { tag, _ in
                if tag == .noun || tag == .adjective {
                    hasProductName = true
                }
                return true
            }

            // Look for price pattern in lines with product names
            if hasProductName, let price = extractDecimalFromLine(line), price > 0 {
                // Extract product name (everything before the price)
                let components = line.components(separatedBy: .whitespaces)
                if let priceIndex = components.firstIndex(where: { $0.contains("$") || $0.isNumeric }) {
                    let nameComponents = Array(components[..<priceIndex])
                    let name = nameComponents.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)

                    if !name.isEmpty, name.count > 2 {
                        items.append(ReceiptItem(name: name, price: price, quantity: 1))
                    }
                }
            }
        }

        return items
    }

    // MARK: - Apple ML Classification

    private func classifyWithAppleML(_ recognizedText: RecognizedText, structuredData: StructuredReceiptData) async throws -> [String] {
        var categories: [String] = []

        // Use Natural Language for text classification
        let text = recognizedText.fullText

        // Language recognition
        languageRecognizer.processString(text)
        let dominantLanguage = languageRecognizer.dominantLanguage

        // Text classification using NL
        if dominantLanguage == .english {
            categories.append(contentsOf: classifyTextWithNaturalLanguage(text))
        }

        // Vendor-based classification
        if let vendor = structuredData.vendor {
            categories.append(contentsOf: classifyByVendor(vendor))
        }

        // Item-based classification
        for item in structuredData.items {
            categories.append(contentsOf: classifyItem(item.name))
        }

        return Array(Set(categories)) // Remove duplicates
    }

    private func classifyTextWithNaturalLanguage(_ text: String) -> [String] {
        var categories: [String] = []

        nlTagger.string = text

        // Use lexical analysis to identify content types
        let stringRange = text.startIndex ..< text.endIndex
        nlTagger.enumerateTags(in: stringRange, unit: .word, scheme: .lexicalClass) { _, tokenRange in
            let word = String(text[tokenRange]).lowercased()

            // Food/Grocery keywords
            if Self.groceryKeywords.contains(word) {
                categories.append("Grocery")
            }

            // Electronics keywords
            if Self.electronicsKeywords.contains(word) {
                categories.append("Electronics")
            }

            // Home improvement keywords
            if Self.homeImprovementKeywords.contains(word) {
                categories.append("Home Improvement")
            }

            return true
        }

        return categories
    }

    // MARK: - Helper Methods

    private func extractDecimalFromLine(_ line: String) -> Decimal? {
        // Enhanced decimal extraction with Natural Language context
        let numberPattern = #"\d+\.?\d*"#
        let regex = try? NSRegularExpression(pattern: numberPattern)
        let range = NSRange(location: 0, length: line.count)

        let matches = regex?.matches(in: line, range: range) ?? []

        for match in matches.reversed() { // Take the last number (usually the price)
            let numberString = String(line[Range(match.range, in: line)!])
            if let decimal = Decimal(string: numberString), decimal > 0 {
                return decimal
            }
        }

        return nil
    }

    private func classifyByVendor(_ vendor: String) -> [String] {
        let normalizedVendor = vendor.lowercased()

        if Self.groceryVendors.contains(where: { normalizedVendor.contains($0) }) {
            return ["Grocery"]
        }
        if Self.electronicsVendors.contains(where: { normalizedVendor.contains($0) }) {
            return ["Electronics"]
        }
        if Self.homeImprovementVendors.contains(where: { normalizedVendor.contains($0) }) {
            return ["Home Improvement"]
        }
        if Self.pharmacyVendors.contains(where: { normalizedVendor.contains($0) }) {
            return ["Health & Pharmacy"]
        }

        return []
    }

    private func classifyItem(_ itemName: String) -> [String] {
        let normalizedName = itemName.lowercased()

        if Self.groceryKeywords.contains(where: { normalizedName.contains($0) }) {
            return ["Grocery"]
        }
        if Self.electronicsKeywords.contains(where: { normalizedName.contains($0) }) {
            return ["Electronics"]
        }

        return []
    }

    private func calculateConfidenceScore(_ structuredData: StructuredReceiptData, _ recognizedText: RecognizedText) -> Double {
        let avgOCRConfidence = recognizedText.confidenceScores.reduce(0, +) / Float(max(recognizedText.confidenceScores.count, 1))

        var extractionScore = 0.0
        if structuredData.vendor != nil { extractionScore += 0.25 }
        if structuredData.total != nil { extractionScore += 0.30 }
        if structuredData.date != nil { extractionScore += 0.20 }
        if structuredData.tax != nil { extractionScore += 0.10 }
        if !structuredData.items.isEmpty { extractionScore += 0.15 }

        return (Double(avgOCRConfidence) * 0.4) + (extractionScore * 0.6)
    }
}

// MARK: - Supporting Types

struct RecognizedText: Sendable {
    let fullText: String
    let lines: [String]
    let boundingBoxes: [CGRect]
    let confidenceScores: [Float]
}

// MARK: - Static Data

extension AppleFrameworksReceiptProcessor {
    static let receiptVocabulary = [
        "TOTAL", "SUBTOTAL", "TAX", "CASH", "CREDIT", "DEBIT",
        "WALMART", "TARGET", "COSTCO", "KROGER", "SAFEWAY",
        "RECEIPT", "TRANSACTION", "PURCHASE", "SALE", "QTY",
    ]

    static let groceryKeywords = [
        "milk", "bread", "eggs", "cheese", "meat", "chicken", "produce",
        "organic", "fresh", "dairy", "frozen", "cereal", "pasta",
    ]

    static let electronicsKeywords = [
        "phone", "computer", "laptop", "cable", "charger", "battery",
        "speaker", "headphone", "tablet", "monitor", "keyboard",
    ]

    static let homeImprovementKeywords = [
        "hammer", "drill", "paint", "lumber", "nail", "screw",
        "tool", "hardware", "plumbing", "electrical",
    ]

    static let groceryVendors = [
        "walmart", "kroger", "safeway", "whole foods", "trader joe",
    ]

    static let electronicsVendors = [
        "best buy", "apple store", "microcenter",
    ]

    static let homeImprovementVendors = [
        "home depot", "lowes", "ace hardware", "menards",
    ]

    static let pharmacyVendors = [
        "cvs", "walgreens", "rite aid",
    ]
}

// MARK: - Extensions

extension String {
    fileprivate var isNumeric: Bool {
        Double(self) != nil
    }
}

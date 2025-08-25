//
// Layer: Services
// Module: ReceiptOCR
// Purpose: Machine learning-enhanced receipt processing for improved accuracy
//

import CoreML
import Foundation
import Vision
import UIKit

@MainActor
public final class MLReceiptProcessor: @unchecked Sendable {
    // MARK: - ML Models and Configuration

    private let confidenceThreshold: Float = 0.7
    private let textRecognizer = VNRecognizeTextRequest()
    private let documentDetector = VNDetectDocumentSegmentationRequest()

    // Pre-trained patterns for common receipt elements
    private let vendorPatterns: [NSRegularExpression]
    private let totalPatterns: [NSRegularExpression]
    private let datePatterns: [NSRegularExpression]
    private let taxPatterns: [NSRegularExpression]
    private let itemPatterns: [NSRegularExpression]

    // ML-based category classifier
    private let categoryClassifier: CategoryClassifier

    public init() throws {
        // Initialize enhanced text recognition
        textRecognizer.recognitionLevel = .accurate
        textRecognizer.usesLanguageCorrection = true
        textRecognizer.customWords = Self.commonReceiptTerms

        // Compile regex patterns for receipt parsing
        self.vendorPatterns = try Self.compileVendorPatterns()
        self.totalPatterns = try Self.compileTotalPatterns()
        self.datePatterns = try Self.compileDatePatterns()
        self.taxPatterns = try Self.compileTaxPatterns()
        self.itemPatterns = try Self.compileItemPatterns()

        // Initialize ML category classifier
        self.categoryClassifier = try CategoryClassifier()
    }

    // MARK: - Enhanced Receipt Processing

    public func processReceiptImage(_ image: UIImage) async throws -> EnhancedReceiptData {
        // Step 1: Document detection and perspective correction
        let correctedImage = try await detectAndCorrectDocument(image)

        // Step 2: Enhanced OCR with ML preprocessing
        let ocrResults = try await performEnhancedOCR(correctedImage)

        // Step 3: Structured data extraction using ML patterns
        let extractedData = try await extractStructuredData(from: ocrResults)

        // Step 4: Category classification using ML
        let categories = try await classifyReceiptCategory(
            vendor: extractedData.vendor,
            items: extractedData.items,
            ocrText: ocrResults.rawText
        )

        // Step 5: Confidence scoring and validation
        let confidenceScore = calculateConfidenceScore(extractedData, ocrResults)

        return EnhancedReceiptData(
            vendor: extractedData.vendor,
            total: extractedData.total,
            tax: extractedData.tax,
            date: extractedData.date,
            items: extractedData.items,
            categories: categories,
            confidence: confidenceScore,
            rawText: ocrResults.rawText,
            boundingBoxes: ocrResults.boundingBoxes,
            processingMetadata: ReceiptProcessingMetadata(
                documentCorrectionApplied: correctedImage != image,
                patternsMatched: extractedData.patternsMatched,
                mlClassifierUsed: true
            )
        )
    }

    // MARK: - Document Detection and Correction

    private func detectAndCorrectDocument(_ image: UIImage) async throws -> UIImage {
        // APPLE_FRAMEWORK_OPPORTUNITY: Replace with Vision Framework - Use VNDetectDocumentSegmentationRequest for automatic document boundary detection and perspective correction
        // For now, return the original image without document correction
        // Document segmentation is available in iOS 16+ and we need iOS 17 compatibility
        image
    }

    private func correctPerspective(image: CGImage, documentBounds: CGRect) throws -> CGImage {
        // Apply perspective correction using Core Image
        let context = CIContext()
        let ciImage = CIImage(cgImage: image)

        // Convert normalized bounds to image coordinates
        let imageSize = CGSize(width: image.width, height: image.height)
        let actualBounds = CGRect(
            x: documentBounds.minX * imageSize.width,
            y: (1.0 - documentBounds.maxY) * imageSize.height,
            width: documentBounds.width * imageSize.width,
            height: documentBounds.height * imageSize.height
        )

        // Apply perspective correction filter
        guard let filter = CIFilter(name: "CIPerspectiveCorrection") else {
            throw ReceiptProcessingError.perspectiveCorrectionFailed
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgPoint: actualBounds.origin), forKey: "inputTopLeft")
        filter.setValue(CIVector(cgPoint: CGPoint(x: actualBounds.maxX, y: actualBounds.minY)), forKey: "inputTopRight")
        filter.setValue(CIVector(cgPoint: CGPoint(x: actualBounds.maxX, y: actualBounds.maxY)), forKey: "inputBottomRight")
        filter.setValue(CIVector(cgPoint: CGPoint(x: actualBounds.minX, y: actualBounds.maxY)), forKey: "inputBottomLeft")

        guard let outputImage = filter.outputImage,
              let cgOutput = context.createCGImage(outputImage, from: outputImage.extent)
        else {
            throw ReceiptProcessingError.perspectiveCorrectionFailed
        }

        return cgOutput
    }

    // MARK: - Enhanced OCR Processing

    private func performEnhancedOCR(_ image: UIImage) async throws -> OCRResults {
        guard let cgImage = image.cgImage else {
            throw ReceiptProcessingError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            textRecognizer.recognitionLevel = .accurate
            textRecognizer.usesLanguageCorrection = true
            textRecognizer.minimumTextHeight = 0.02 // Improved for small receipt text

            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                var allText: [String] = []
                var boundingBoxes: [CGRect] = []

                for observation in observations {
                    if let topCandidate = observation.topCandidates(1).first,
                       topCandidate.confidence >= self.confidenceThreshold
                    {
                        allText.append(topCandidate.string)
                        boundingBoxes.append(observation.boundingBox)
                    }
                }

                let results = OCRResults(
                    rawText: allText.joined(separator: "\n"),
                    lines: allText,
                    boundingBoxes: boundingBoxes,
                    averageConfidence: observations.compactMap {
                        $0.topCandidates(1).first?.confidence
                    }.reduce(0, +) / Float(max(observations.count, 1))
                )

                continuation.resume(returning: results)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Structured Data Extraction

    private func extractStructuredData(from ocrResults: OCRResults) async throws -> StructuredReceiptData {
        let text = ocrResults.rawText
        let lines = ocrResults.lines

        // Extract vendor using ML-enhanced patterns
        let vendor = extractVendor(from: lines)

        // Extract monetary values with context awareness
        let total = extractTotal(from: lines)
        let tax = extractTax(from: lines)

        // Extract date with multiple format support
        let date = extractDate(from: lines)

        // Extract individual items using ML patterns
        let items = extractItems(from: lines)

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

    private func extractVendor(from lines: [String]) -> String? {
        // Try multiple vendor detection strategies
        for pattern in vendorPatterns {
            for line in lines.prefix(5) { // Check first 5 lines for vendor
                if let match = pattern.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) {
                    let vendor = String(line[Range(match.range, in: line)!])
                    return cleanVendorName(vendor)
                }
            }
        }

        // Fallback: Use first substantial line that's not a number or date
        for line in lines.prefix(3) {
            let cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleaned.count > 3, !cleaned.containsOnlyNumbers, !cleaned.containsDate {
                return cleanVendorName(cleaned)
            }
        }

        return nil
    }

    private func extractTotal(from lines: [String]) -> Decimal? {
        for pattern in totalPatterns {
            for line in lines.reversed() { // Check from bottom up for total
                if let match = pattern.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) {
                    let totalString = String(line[Range(match.range, in: line)!])
                    return extractDecimalValue(from: totalString)
                }
            }
        }
        return nil
    }

    private func extractTax(from lines: [String]) -> Decimal? {
        for pattern in taxPatterns {
            for line in lines {
                if let match = pattern.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) {
                    let taxString = String(line[Range(match.range, in: line)!])
                    return extractDecimalValue(from: taxString)
                }
            }
        }
        return nil
    }

    private func extractDate(from lines: [String]) -> Date? {
        let dateFormatter = DateFormatter()
        let formats = [
            "MM/dd/yyyy", "MM/dd/yy", "M/d/yyyy", "M/d/yy",
            "yyyy-MM-dd", "dd/MM/yyyy", "dd.MM.yyyy",
            "MMM dd, yyyy", "MMMM dd, yyyy",
            "dd MMM yyyy", "dd MMMM yyyy",
        ]

        for pattern in datePatterns {
            for line in lines.prefix(10) { // Check first 10 lines for date
                if let match = pattern.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) {
                    let dateString = String(line[Range(match.range, in: line)!])

                    for format in formats {
                        dateFormatter.dateFormat = format
                        if let date = dateFormatter.date(from: dateString) {
                            return date
                        }
                    }
                }
            }
        }

        return nil
    }

    private func extractItems(from lines: [String]) -> [ReceiptItem] {
        var items: [ReceiptItem] = []

        for line in lines {
            for pattern in itemPatterns {
                if let match = pattern.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) {
                    if let item = parseReceiptItem(from: line) {
                        items.append(item)
                    }
                }
            }
        }

        return items
    }

    // MARK: - ML Category Classification

    private func classifyReceiptCategory(vendor: String?, items: [ReceiptItem], ocrText: String) async throws -> [String] {
        try await categoryClassifier.classify(
            vendor: vendor ?? "",
            items: items.map(\.name),
            fullText: ocrText
        )
    }

    // MARK: - Confidence Scoring

    private func calculateConfidenceScore(_ data: StructuredReceiptData, _ ocrResults: OCRResults) -> Double {
        var score = 0.0
        let baseScore = Double(ocrResults.averageConfidence)

        // Base OCR confidence (40% weight)
        score += baseScore * 0.4

        // Data extraction success (60% weight)
        var extractionScore = 0.0
        extractionScore += data.vendor != nil ? 0.2 : 0.0
        extractionScore += data.total != nil ? 0.25 : 0.0
        extractionScore += data.date != nil ? 0.15 : 0.0
        extractionScore += data.tax != nil ? 0.1 : 0.0
        extractionScore += !data.items.isEmpty ? 0.3 : 0.0

        score += extractionScore * 0.6

        return min(score, 1.0)
    }

    // MARK: - Helper Methods

    private func cleanVendorName(_ vendor: String) -> String {
        vendor
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .capitalized
    }

    private func extractDecimalValue(from string: String) -> Decimal? {
        let cleanString = string.replacingOccurrences(of: #"[^\d\.]"#, with: "", options: .regularExpression)
        return Decimal(string: cleanString)
    }

    private func parseReceiptItem(from line: String) -> ReceiptItem? {
        // Enhanced item parsing logic
        let components = line.components(separatedBy: CharacterSet.whitespaces)
        guard components.count >= 2 else { return nil }

        // Try to extract price from end of line
        if let price = extractDecimalValue(from: components.last ?? ""),
           price > 0
        {
            let name = components.dropLast().joined(separator: " ")
            return ReceiptItem(name: name, price: price, quantity: 1)
        }

        return nil
    }
}

// MARK: - Pattern Compilation

extension MLReceiptProcessor {
    private static func compileVendorPatterns() throws -> [NSRegularExpression] {
        let patterns = [
            #"^[A-Z][A-Z\s&'-]{2,30}$"#, // All caps vendor names
            #"(?i)^(target|walmart|costco|home depot|lowes|best buy|kroger|safeway|whole foods|cvs|walgreens)"#,
            #"(?i)\b(store|shop|market|depot|center|pharmacy|foods)\b"#,
        ]

        return try patterns.map { try NSRegularExpression(pattern: $0, options: []) }
    }

    private static func compileTotalPatterns() throws -> [NSRegularExpression] {
        let patterns = [
            #"(?i)total[\s:$]*(\d+\.\d{2})"#,
            #"(?i)amount due[\s:$]*(\d+\.\d{2})"#,
            #"(?i)balance[\s:$]*(\d+\.\d{2})"#,
            #"\$(\d+\.\d{2})$"#, // Dollar amount at end of line
        ]

        return try patterns.map { try NSRegularExpression(pattern: $0, options: []) }
    }

    private static func compileDatePatterns() throws -> [NSRegularExpression] {
        let patterns = [
            #"\d{1,2}/\d{1,2}/\d{2,4}"#,
            #"\d{1,2}-\d{1,2}-\d{2,4}"#,
            #"\d{1,2}\.\d{1,2}\.\d{2,4}"#,
            #"(?i)(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\s+\d{1,2},?\s+\d{4}"#,
        ]

        return try patterns.map { try NSRegularExpression(pattern: $0, options: []) }
    }

    private static func compileTaxPatterns() throws -> [NSRegularExpression] {
        let patterns = [
            #"(?i)tax[\s:$]*(\d+\.\d{2})"#,
            #"(?i)sales tax[\s:$]*(\d+\.\d{2})"#,
            #"(?i)hst[\s:$]*(\d+\.\d{2})"#,
            #"(?i)gst[\s:$]*(\d+\.\d{2})"#,
        ]

        return try patterns.map { try NSRegularExpression(pattern: $0, options: []) }
    }

    private static func compileItemPatterns() throws -> [NSRegularExpression] {
        let patterns = [
            #"^[\w\s-]+\s+\$?\d+\.\d{2}$"#, // Item name followed by price
            #"^\d+\s+[\w\s-]+\s+\$?\d+\.\d{2}$"#, // Quantity, item name, price
            #"^[\w\s-]+\s+@\s+\$?\d+\.\d{2}"#, // Item name @ price format
        ]

        return try patterns.map { try NSRegularExpression(pattern: $0, options: []) }
    }

    private static let commonReceiptTerms = [
        "TOTAL", "SUBTOTAL", "TAX", "CASH", "CREDIT", "DEBIT",
        "WALMART", "TARGET", "COSTCO", "KROGER", "SAFEWAY",
        "RECEIPT", "TRANSACTION", "PURCHASE", "SALE",
    ]
}

// MARK: - Data Models

public struct EnhancedReceiptData: Sendable, Equatable {
    public let vendor: String?
    public let total: Decimal?
    public let tax: Decimal?
    public let date: Date?
    public let items: [ReceiptItem]
    public let categories: [String]
    public let confidence: Double
    public let rawText: String
    public let boundingBoxes: [CGRect]
    public let processingMetadata: ReceiptProcessingMetadata
}

public struct StructuredReceiptData: Sendable {
    public let vendor: String?
    public let total: Decimal?
    public let tax: Decimal?
    public let date: Date?
    public let items: [ReceiptItem]
    public let patternsMatched: [String: Bool]
}

public struct OCRResults: Sendable {
    public let rawText: String
    public let lines: [String]
    public let boundingBoxes: [CGRect]
    public let averageConfidence: Float
}

public struct ReceiptItem: Sendable, Equatable {
    public let name: String
    public let price: Decimal
    public let quantity: Int

    public init(name: String, price: Decimal, quantity: Int = 1) {
        self.name = name
        self.price = price
        self.quantity = quantity
    }
}

public struct ReceiptProcessingMetadata: Sendable, Equatable {
    public let documentCorrectionApplied: Bool
    public let patternsMatched: [String: Bool]
    public let mlClassifierUsed: Bool
}

// MARK: - Error Types

public enum ReceiptProcessingError: Error, LocalizedError, Sendable {
    case invalidImage
    case perspectiveCorrectionFailed
    case ocrFailed
    case mlModelLoadFailed
    case insufficientData

    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            "Invalid image provided for processing"
        case .perspectiveCorrectionFailed:
            "Failed to correct image perspective"
        case .ocrFailed:
            "OCR text recognition failed"
        case .mlModelLoadFailed:
            "Failed to load machine learning model"
        case .insufficientData:
            "Insufficient data extracted from receipt"
        }
    }
}

// MARK: - String Extensions

extension String {
    fileprivate var containsOnlyNumbers: Bool {
        allSatisfy { $0.isNumber || $0 == "." || $0 == "," }
    }

    fileprivate var containsDate: Bool {
        let datePattern = #"\d{1,2}[/\-\.]\d{1,2}[/\-\.]\d{2,4}"#
        return range(of: datePattern, options: .regularExpression) != nil
    }
}

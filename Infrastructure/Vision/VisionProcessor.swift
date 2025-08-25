//
// Layer: Infrastructure
// Module: Vision
// Purpose: Computer Vision abstraction for Services layer
//

import Foundation
import Vision
import VisionKit
import UIKit

// MARK: - Vision Processor Protocol

/// Abstract computer vision interface for Services layer
/// Abstracts Vision/VisionKit specifics to enable testing and alternative providers
public protocol VisionProcessor: Sendable {
    /// Extract text from image using OCR
    func extractText(from image: UIImage) async throws -> [TextRegion]
    
    /// Extract text from image with advanced options
    func extractText(from image: UIImage, options: TextExtractionOptions) async throws -> TextExtractionResult
    
    /// Detect barcodes in image
    func detectBarcodes(in image: UIImage) async throws -> [BarcodeResult]
    
    /// Scan document using device camera
    func scanDocument() async throws -> DocumentScanResult
}

// MARK: - Supporting Types

/// Represents a region of text found in an image
public struct TextRegion: Sendable, Equatable {
    public let text: String
    public let confidence: Float
    public let boundingBox: CGRect
    
    public init(text: String, confidence: Float, boundingBox: CGRect) {
        self.text = text
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

/// Options for text extraction
public struct TextExtractionOptions: Sendable {
    public let recognitionLevel: RecognitionLevel
    public let usesLanguageCorrection: Bool
    public let customWords: [String]
    public let minimumConfidence: Float
    
    public init(
        recognitionLevel: RecognitionLevel = .accurate,
        usesLanguageCorrection: Bool = true,
        customWords: [String] = [],
        minimumConfidence: Float = 0.5
    ) {
        self.recognitionLevel = recognitionLevel
        self.usesLanguageCorrection = usesLanguageCorrection
        self.customWords = customWords
        self.minimumConfidence = minimumConfidence
    }
    
    public enum RecognitionLevel: String, Sendable {
        case fast
        case accurate
    }
}

/// Result of text extraction with metadata
public struct TextExtractionResult: Sendable {
    public let regions: [TextRegion]
    public let fullText: String
    public let averageConfidence: Float
    public let processingTime: TimeInterval
    
    public init(regions: [TextRegion], fullText: String, averageConfidence: Float, processingTime: TimeInterval) {
        self.regions = regions
        self.fullText = fullText
        self.averageConfidence = averageConfidence
        self.processingTime = processingTime
    }
}

/// Result of barcode detection
public struct BarcodeResult: Sendable, Equatable {
    public let barcode: String
    public let format: BarcodeFormat
    public let confidence: Float
    public let boundingBox: CGRect
    
    public init(barcode: String, format: BarcodeFormat, confidence: Float, boundingBox: CGRect) {
        self.barcode = barcode
        self.format = format
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
    
    public enum BarcodeFormat: String, Sendable, CaseIterable {
        case qr = "QR"
        case ean13 = "EAN-13"
        case ean8 = "EAN-8"
        case upca = "UPC-A"
        case upce = "UPC-E"
        case code128 = "Code 128"
        case code39 = "Code 39"
        case pdf417 = "PDF417"
        case dataMatrix = "Data Matrix"
        case aztec = "Aztec"
    }
}

/// Result of document scanning
public struct DocumentScanResult: Sendable {
    public let images: [UIImage]
    public let pageCount: Int
    public let scanDate: Date
    
    public init(images: [UIImage], pageCount: Int, scanDate: Date) {
        self.images = images
        self.pageCount = pageCount
        self.scanDate = scanDate
    }
}

// MARK: - Vision Framework Implementation

/// Live implementation using Apple's Vision framework
@MainActor
public final class AppleVisionProcessor: VisionProcessor {
    
    public init() {}
    
    public func extractText(from image: UIImage) async throws -> [TextRegion] {
        let result = try await extractText(from: image, options: TextExtractionOptions())
        return result.regions
    }
    
    public func extractText(from image: UIImage, options: TextExtractionOptions) async throws -> TextExtractionResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = options.recognitionLevel == .accurate ? .accurate : .fast
        request.usesLanguageCorrection = options.usesLanguageCorrection
        request.customWords = options.customWords
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                    
                    let observations = request.results ?? []
                    let regions = observations.compactMap { observation -> TextRegion? in
                        guard let candidate = observation.topCandidates(1).first,
                              candidate.confidence >= options.minimumConfidence else {
                            return nil
                        }
                        
                        return TextRegion(
                            text: candidate.string,
                            confidence: candidate.confidence,
                            boundingBox: observation.boundingBox
                        )
                    }
                    
                    let fullText = regions.map(\.text).joined(separator: "\n")
                    let averageConfidence = regions.isEmpty ? 0 : regions.map(\.confidence).reduce(0, +) / Float(regions.count)
                    let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                    
                    let result = TextExtractionResult(
                        regions: regions,
                        fullText: fullText,
                        averageConfidence: averageConfidence,
                        processingTime: processingTime
                    )
                    
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: VisionError.textExtractionFailed(error.localizedDescription))
                }
            }
        }
    }
    
    public func detectBarcodes(in image: UIImage) async throws -> [BarcodeResult] {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        
        let request = VNDetectBarcodesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                    
                    let observations = request.results ?? []
                    let results = observations.compactMap { observation -> BarcodeResult? in
                        guard let payloadStringValue = observation.payloadStringValue,
                              let format = self.mapVisionBarcodeFormat(observation.symbology) else {
                            return nil
                        }
                        
                        return BarcodeResult(
                            barcode: payloadStringValue,
                            format: format,
                            confidence: observation.confidence,
                            boundingBox: observation.boundingBox
                        )
                    }
                    
                    continuation.resume(returning: results)
                } catch {
                    continuation.resume(throwing: VisionError.barcodeDetectionFailed(error.localizedDescription))
                }
            }
        }
    }
    
    public func scanDocument() async throws -> DocumentScanResult {
        // This would need to be called from a view controller context
        // For now, returning a placeholder implementation
        throw VisionError.documentScanningNotAvailable
    }
    
    private func mapVisionBarcodeFormat(_ symbology: VNBarcodeSymbology) -> BarcodeResult.BarcodeFormat? {
        switch symbology {
        case .qr: return .qr
        case .ean13: return .ean13
        case .ean8: return .ean8
        case .upce: return .upce
        case .code128: return .code128
        case .code39: return .code39
        case .pdf417: return .pdf417
        case .dataMatrix: return .dataMatrix
        case .aztec: return .aztec
        default: return nil
        }
    }
}

// MARK: - Mock Implementation

/// Mock implementation for testing
public final class MockVisionProcessor: VisionProcessor {
    public var mockTextRegions: [TextRegion] = []
    public var mockBarcodeResults: [BarcodeResult] = []
    public var shouldThrowError = false
    
    public init() {}
    
    public func extractText(from image: UIImage) async throws -> [TextRegion] {
        if shouldThrowError {
            throw VisionError.textExtractionFailed("Mock error")
        }
        return mockTextRegions
    }
    
    public func extractText(from image: UIImage, options: TextExtractionOptions) async throws -> TextExtractionResult {
        if shouldThrowError {
            throw VisionError.textExtractionFailed("Mock error")
        }
        
        let fullText = mockTextRegions.map(\.text).joined(separator: "\n")
        let averageConfidence = mockTextRegions.isEmpty ? 0 : mockTextRegions.map(\.confidence).reduce(0, +) / Float(mockTextRegions.count)
        
        return TextExtractionResult(
            regions: mockTextRegions,
            fullText: fullText,
            averageConfidence: averageConfidence,
            processingTime: 0.1
        )
    }
    
    public func detectBarcodes(in image: UIImage) async throws -> [BarcodeResult] {
        if shouldThrowError {
            throw VisionError.barcodeDetectionFailed("Mock error")
        }
        return mockBarcodeResults
    }
    
    public func scanDocument() async throws -> DocumentScanResult {
        if shouldThrowError {
            throw VisionError.documentScanningNotAvailable
        }
        return DocumentScanResult(images: [], pageCount: 0, scanDate: Date())
    }
}

// MARK: - Error Types

public enum VisionError: LocalizedError, Sendable {
    case invalidImage
    case textExtractionFailed(String)
    case barcodeDetectionFailed(String)
    case documentScanningNotAvailable
    
    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image provided"
        case let .textExtractionFailed(reason):
            return "Text extraction failed: \(reason)"
        case let .barcodeDetectionFailed(reason):
            return "Barcode detection failed: \(reason)"
        case .documentScanningNotAvailable:
            return "Document scanning is not available in this context"
        }
    }
}
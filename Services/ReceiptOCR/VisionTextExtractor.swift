//
// Layer: Services
// Module: ReceiptOCR
// Purpose: Extract text from images using Vision framework
//

import Foundation
import UIKit
import Vision

public struct VisionTextExtractor: @unchecked Sendable {
    public enum ExtractionError: LocalizedError {
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
    
    public init() {}
    
    public func extractText(from imageData: Data) async throws -> String {
        guard let uiImage = UIImage(data: imageData) else {
            throw ExtractionError.imageProcessingFailed
        }
        
        guard let cgImage = uiImage.cgImage else {
            throw ExtractionError.imageProcessingFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: ExtractionError.textRecognitionFailed)
                    return
                }
                
                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                if recognizedStrings.isEmpty {
                    continuation.resume(throwing: ExtractionError.noTextFound)
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
    
    public func extractTextWithBoundingBoxes(from imageData: Data) async throws -> [(text: String, boundingBox: CGRect)] {
        guard let uiImage = UIImage(data: imageData) else {
            throw ExtractionError.imageProcessingFailed
        }
        
        guard let cgImage = uiImage.cgImage else {
            throw ExtractionError.imageProcessingFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: ExtractionError.textRecognitionFailed)
                    return
                }
                
                let results = observations.compactMap { observation -> (text: String, boundingBox: CGRect)? in
                    guard let candidate = observation.topCandidates(1).first else { return nil }
                    return (text: candidate.string, boundingBox: observation.boundingBox)
                }
                
                continuation.resume(returning: results)
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
}
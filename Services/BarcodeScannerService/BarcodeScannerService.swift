//
// Layer: Services
// Module: BarcodeScanner
// Purpose: Protocol-first barcode and QR code scanning service
//

import Foundation

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with VisionKit - Use DataScannerViewController in VisionKit for built-in barcode scanning UI and enhanced recognition

/// Protocol defining barcode scanning capabilities for item identification
public protocol BarcodeScannerService: Sendable {
    /// Check if camera access is available for barcode scanning
    func checkCameraPermission() async -> Bool

    /// Detect barcodes from image data
    func detectBarcode(from imageData: Data) async throws -> BarcodeResult?

    /// Extract serial numbers from text using common patterns
    func extractSerialNumber(from text: String) -> String?

    /// Look up product information from barcode
    func lookupProduct(barcode: String, type: String) async -> ProductInfo?
}

// MARK: - Errors
// Note: BarcodeResult and ProductInfo are defined in Foundation/Models/BarcodeModels.swift

public enum BarcodeScanError: Error, LocalizedError, Sendable {
    case cameraAccessDenied
    case invalidImage
    case processingFailed
    case noBarcodesFound
    case networkError(String)
    case apiError(String)

    public var errorDescription: String? {
        switch self {
        case .cameraAccessDenied:
            "Camera access is required to scan barcodes. Please enable it in Settings."
        case .invalidImage:
            "The image could not be processed for barcode scanning."
        case .processingFailed:
            "Failed to process the image for barcodes."
        case .noBarcodesFound:
            "No barcodes were found in the image."
        case let .networkError(message):
            "Network error during product lookup: \(message)"
        case let .apiError(message):
            "Product lookup failed: \(message)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .cameraAccessDenied:
            "Go to Settings > Privacy & Security > Camera and enable access for Nestory."
        case .invalidImage:
            "Try taking a clearer photo with good lighting."
        case .processingFailed:
            "Ensure the barcode is clearly visible and try again."
        case .noBarcodesFound:
            "Make sure the barcode is fully visible in the image."
        case .networkError:
            "Check your internet connection and try again."
        case .apiError:
            "Try again later or enter product information manually."
        }
    }
}

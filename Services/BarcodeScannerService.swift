//
// Layer: Services
// Module: BarcodeScanner
// Purpose: Barcode and QR code scanning for item identification
//
// REMINDER: This service MUST be wired up in the UI where items are added/edited

import AVFoundation
import Foundation
import UIKit
import Vision

@MainActor
public final class BarcodeScannerService: ObservableObject {
    @Published public var isScanning = false
    @Published public var scannedCode: String?
    @Published public var errorMessage: String?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    public init() {}

    // MARK: - Camera Permission

    public func checkCameraPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            errorMessage = "Camera access is required to scan barcodes. Please enable it in Settings."
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - Barcode Detection from Image

    public func detectBarcode(from imageData: Data) async throws -> BarcodeResult? {
        guard let image = UIImage(data: imageData) else {
            throw BarcodeScanError.invalidImage
        }

        guard let ciImage = CIImage(image: image) else {
            throw BarcodeScanError.processingFailed
        }

        let request = VNDetectBarcodesRequest()
        request.symbologies = [
            .ean8, .ean13, .upce, .code39, .code128,
            .qr, .aztec, .pdf417, .dataMatrix,
        ]

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])

        return try await withCheckedThrowingContinuation { continuation in
            do {
                try handler.perform([request])

                guard let results = request.results else {
                    continuation.resume(returning: nil)
                    return
                }

                if let firstBarcode = results.first,
                   let payload = firstBarcode.payloadStringValue
                {
                    let result = BarcodeResult(
                        value: payload,
                        type: symbologyToString(firstBarcode.symbology),
                        confidence: firstBarcode.confidence,
                    )
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(returning: nil)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Serial Number Extraction

    public func extractSerialNumber(from text: String) -> String? {
        // Common serial number patterns
        let patterns = [
            "(?i)s/n[:.]?\\s*([A-Z0-9-]+)", // S/N: ABC123
            "(?i)serial[:.]?\\s*([A-Z0-9-]+)", // Serial: ABC123
            "(?i)ser\\.?\\s*no\\.?[:.]?\\s*([A-Z0-9-]+)", // Ser. No.: ABC123
            "([A-Z]{2,4}[0-9]{6,12})", // Common format: XX123456
            "([0-9]{4}-[0-9]{4}-[0-9]{4})", // Format: 1234-5678-9012
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text))
            {
                let range = match.numberOfRanges > 1 ? match.range(at: 1) : match.range(at: 0)
                if let swiftRange = Range(range, in: text) {
                    return String(text[swiftRange])
                }
            }
        }

        return nil
    }

    // MARK: - Product Lookup

    public func lookupProduct(barcode: String, type: String) async -> ProductInfo? {
        // Simulate product lookup - in production, this would call an API
        // For now, return sample data based on barcode type

        // REMINDER: In production, integrate with:
        // - UPC database API
        // - Manufacturer APIs
        // - Custom product database

        // Sample implementation
        if type == "EAN-13" || type == "UPC-A" {
            return ProductInfo(
                barcode: barcode,
                name: "Product Name (Lookup Not Implemented)",
                brand: nil,
                model: nil,
                category: "Electronics",
                estimatedValue: nil,
            )
        }

        return nil
    }

    // MARK: - Helper Methods

    private func symbologyToString(_ symbology: VNBarcodeSymbology) -> String {
        switch symbology {
        case .aztec: "Aztec"
        case .code39: "Code 39"
        case .code39Checksum: "Code 39 Checksum"
        case .code39FullASCII: "Code 39 Full ASCII"
        case .code39FullASCIIChecksum: "Code 39 Full ASCII Checksum"
        case .code93: "Code 93"
        case .code93i: "Code 93i"
        case .code128: "Code 128"
        case .dataMatrix: "Data Matrix"
        case .ean8: "EAN-8"
        case .ean13: "EAN-13"
        case .i2of5: "Interleaved 2 of 5"
        case .i2of5Checksum: "Interleaved 2 of 5 Checksum"
        case .itf14: "ITF-14"
        case .pdf417: "PDF417"
        case .qr: "QR Code"
        case .upce: "UPC-E"
        case .microPDF417: "Micro PDF417"
        case .microQR: "Micro QR"
        case .codabar: "Codabar"
        case .gs1DataBar: "GS1 DataBar"
        case .gs1DataBarExpanded: "GS1 DataBar Expanded"
        case .gs1DataBarLimited: "GS1 DataBar Limited"
        case .msiPlessey: "MSI Plessey"
        default: "Unknown"
        }
    }
}

// MARK: - Data Models

public struct BarcodeResult: Equatable {
    public let value: String
    public let type: String
    public let confidence: Float

    public var isSerialNumber: Bool {
        // Check if this looks like a serial number vs product barcode
        !type.contains("EAN") && !type.contains("UPC") && !type.contains("QR")
    }
}

public struct ProductInfo: Equatable {
    public let barcode: String
    public let name: String
    public let brand: String?
    public let model: String?
    public let category: String?
    public let estimatedValue: Decimal?
}

// MARK: - Errors

public enum BarcodeScanError: LocalizedError {
    case cameraAccessDenied
    case invalidImage
    case processingFailed
    case noBarcodesFound

    public var errorDescription: String? {
        switch self {
        case .cameraAccessDenied:
            "Camera access is required to scan barcodes"
        case .invalidImage:
            "The image could not be processed"
        case .processingFailed:
            "Failed to process the barcode"
        case .noBarcodesFound:
            "No barcodes found in the image"
        }
    }
}

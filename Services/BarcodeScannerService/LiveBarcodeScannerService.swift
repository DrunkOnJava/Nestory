//
// Layer: Services
// Module: BarcodeScanner
// Purpose: Live implementation of barcode scanning using AVFoundation and Vision
//

import AVFoundation
import Foundation
import os.log
import UIKit
import Vision

@MainActor
public final class LiveBarcodeScannerService: BarcodeScannerService, ObservableObject {
    @Published public var isScanning = false
    @Published public var scannedCode: String?
    @Published public var errorMessage: String?

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "BarcodeScannerService")
    private let productLookupService: ProductLookupService

    public init() {
        do {
            self.productLookupService = try LiveProductLookupService()
        } catch {
            // Fallback to mock service if initialization fails
            self.productLookupService = MockProductLookupService()
        }
    }

    // MARK: - BarcodeScannerService Protocol Implementation

    public nonisolated func checkCameraPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            await MainActor.run {
                errorMessage = "Camera access is required to scan barcodes. Please enable it in Settings."
            }
            return false
        @unknown default:
            return false
        }
    }

    public nonisolated func detectBarcode(from imageData: Data) async throws -> BarcodeResult? {
        guard let image = UIImage(data: imageData) else {
            throw BarcodeScanError.invalidImage
        }

        guard let ciImage = CIImage(image: image) else {
            throw BarcodeScanError.processingFailed
        }

        let request = VNDetectBarcodesRequest()
        request.symbologies = [
            // Standard retail barcodes
            .ean8, .ean13, .upce, .code39, .code128, .codabar,
            // 2D codes for complex data
            .qr, .aztec, .pdf417, .dataMatrix,
            // Additional supported formats
            .i2of5, .i2of5Checksum, .itf14, .code39Checksum, .code39FullASCII,
            .code39FullASCIIChecksum, .code93, .code93i, .gs1DataBar,
            .gs1DataBarExpanded, .gs1DataBarLimited, .microPDF417, .microQR,
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

    public nonisolated func extractSerialNumber(from text: String) -> String? {
        let patterns = [
            "(?i)s/n[:.]?\\s*([A-Z0-9-]+)",
            "(?i)serial[:.]?\\s*([A-Z0-9-]+)",
            "(?i)ser\\.?\\s*no\\.?[:.]?\\s*([A-Z0-9-]+)",
            "([A-Z]{2,4}[0-9]{6,12})",
            "([0-9]{4}-[0-9]{4}-[0-9]{4})",
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

    public nonisolated func lookupProduct(barcode: String, type: String) async -> ProductInfo? {
        // Use the enhanced product lookup service
        await productLookupService.lookupProduct(barcode: barcode, type: type)
    }
}

// MARK: - Private Helpers

private func symbologyToString(_ symbology: VNBarcodeSymbology) -> String {
    switch symbology {
    // Standard retail barcodes
    case .ean8: "EAN-8"
    case .ean13: "EAN-13"
    case .upce: "UPC-E"
    case .code39: "Code 39"
    case .code39Checksum: "Code 39 Checksum"
    case .code39FullASCII: "Code 39 Full ASCII"
    case .code39FullASCIIChecksum: "Code 39 Full ASCII Checksum"
    case .code128: "Code 128"
    case .code93: "Code 93"
    case .code93i: "Code 93i"
    case .codabar: "Codabar"
    case .i2of5: "Interleaved 2 of 5"
    case .i2of5Checksum: "Interleaved 2 of 5 Checksum"
    case .itf14: "ITF-14"
    // GS1 Standards
    case .gs1DataBar: "GS1 DataBar"
    case .gs1DataBarExpanded: "GS1 DataBar Expanded"
    case .gs1DataBarLimited: "GS1 DataBar Limited"
    // 2D codes
    case .qr: "QR Code"
    case .microQR: "Micro QR Code"
    case .aztec: "Aztec"
    case .pdf417: "PDF417"
    case .microPDF417: "Micro PDF417"
    case .dataMatrix: "Data Matrix"
    default: "Unknown"
    }
}

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

    public init() {}

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
        // Simulate product lookup - in production integrate with UPC database API
        if type.contains("EAN") || type.contains("UPC") {
            return ProductInfo(
                barcode: barcode,
                name: "Sample Product",
                brand: "Sample Brand",
                category: "Electronics",
            )
        }
        return nil
    }
}

// MARK: - Private Helpers

private func symbologyToString(_ symbology: VNBarcodeSymbology) -> String {
    switch symbology {
    case .ean8: "EAN-8"
    case .ean13: "EAN-13"
    case .upce: "UPC-E"
    case .code39: "Code 39"
    case .code128: "Code 128"
    case .qr: "QR Code"
    case .aztec: "Aztec"
    case .pdf417: "PDF417"
    case .dataMatrix: "Data Matrix"
    default: "Unknown"
    }
}

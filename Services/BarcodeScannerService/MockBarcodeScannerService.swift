//
// Layer: Services
// Module: BarcodeScanner
// Purpose: Mock implementation for testing
//

import Foundation

public struct MockBarcodeScannerService: BarcodeScannerService {
    public func checkCameraPermission() async -> Bool {
        true
    }

    public func detectBarcode(from _: Data) async throws -> BarcodeResult? {
        BarcodeResult(value: "123456789012", type: "EAN-13", confidence: 0.95)
    }

    public func extractSerialNumber(from _: String) -> String? {
        "MOCK123456"
    }

    public func lookupProduct(barcode: String, type _: String) async -> ProductInfo? {
        ProductInfo(barcode: barcode, name: "Mock Product", brand: "Mock Brand")
    }
}

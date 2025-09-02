//
// Layer: Foundation
// Module: Foundation/Models
// Purpose: Barcode and product identification domain models
//

import Foundation

// MARK: - Barcode Models

public struct BarcodeResult: Equatable, Sendable {
    public let value: String
    public let type: String
    public let confidence: Float
    public let boundingBox: CGRect?

    public init(value: String, type: String, confidence: Float, boundingBox: CGRect? = nil) {
        self.value = value
        self.type = type
        self.confidence = confidence
        self.boundingBox = boundingBox
    }

    public var isSerialNumber: Bool {
        // Check if this looks like a serial number vs product barcode
        !type.contains("EAN") && !type.contains("UPC") && !type.contains("QR")
    }
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

public struct ProductInfo: Equatable, Sendable {
    public let barcode: String
    public let name: String
    public let brand: String?
    public let model: String?
    public let category: String?
    public let estimatedValue: Decimal?

    public init(
        barcode: String,
        name: String,
        brand: String? = nil,
        model: String? = nil,
        category: String? = nil,
        estimatedValue: Decimal? = nil
    ) {
        self.barcode = barcode
        self.name = name
        self.brand = brand
        self.model = model
        self.category = category
        self.estimatedValue = estimatedValue
    }
}
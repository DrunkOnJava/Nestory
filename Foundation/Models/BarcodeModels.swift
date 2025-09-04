//
// Layer: Foundation
// Module: Models/BarcodeModels
// Purpose: Core barcode data models and types for product identification
//

import Foundation

// MARK: - Barcode Types

public enum BarcodeType: String, CaseIterable, Codable, Sendable {
    case upcA = "UPC-A"
    case upcE = "UPC-E"
    case ean13 = "EAN-13"
    case ean8 = "EAN-8"
    case code128 = "Code 128"
    case code39 = "Code 39"
    case code93 = "Code 93"
    case qrCode = "QR Code"
    case dataMatrix = "Data Matrix"
    case pdf417 = "PDF417"
    
    public var displayName: String {
        return self.rawValue
    }
    
    public var isProductBarcode: Bool {
        switch self {
        case .upcA, .upcE, .ean13, .ean8:
            return true
        default:
            return false
        }
    }
    
    public var expectedLength: Int? {
        switch self {
        case .upcA: return 12
        case .upcE: return 8
        case .ean13: return 13
        case .ean8: return 8
        default: return nil
        }
    }
}

// MARK: - Barcode Data

public struct BarcodeData: Codable, Sendable, Equatable {
    public let value: String
    public let type: BarcodeType
    public let scanDate: Date
    public let confidence: Float
    
    public init(value: String, type: BarcodeType, scanDate: Date = Date(), confidence: Float = 1.0) {
        self.value = value
        self.type = type
        self.scanDate = scanDate
        self.confidence = confidence
    }
    
    public var isValid: Bool {
        guard !value.isEmpty else { return false }
        
        if let expectedLength = type.expectedLength {
            return value.count == expectedLength
        }
        
        return true
    }
    
    public var formattedValue: String {
        switch type {
        case .upcA:
            return formatUPCA(value)
        case .ean13:
            return formatEAN13(value)
        case .ean8:
            return formatEAN8(value)
        default:
            return value
        }
    }
    
    private func formatUPCA(_ value: String) -> String {
        guard value.count == 12 else { return value }
        return "\(value.prefix(1)) \(value.dropFirst().prefix(5)) \(value.suffix(6).prefix(5)) \(value.suffix(1))"
    }
    
    private func formatEAN13(_ value: String) -> String {
        guard value.count == 13 else { return value }
        return "\(value.prefix(1)) \(value.dropFirst().prefix(6)) \(value.suffix(6))"
    }
    
    private func formatEAN8(_ value: String) -> String {
        guard value.count == 8 else { return value }
        return "\(value.prefix(4)) \(value.suffix(4))"
    }
}

// MARK: - Product Information

public struct ProductInfo: Codable, Sendable, Equatable {
    public let barcode: String
    public let title: String?
    public let brand: String?
    public let category: String?
    public let description: String?
    public let imageURL: String?
    public let price: Double?
    public let currency: String?
    public let availability: ProductAvailability
    public let lastUpdated: Date
    
    public init(
        barcode: String,
        title: String? = nil,
        brand: String? = nil,
        category: String? = nil,
        description: String? = nil,
        imageURL: String? = nil,
        price: Double? = nil,
        currency: String? = nil,
        availability: ProductAvailability = .unknown,
        lastUpdated: Date = Date()
    ) {
        self.barcode = barcode
        self.title = title
        self.brand = brand
        self.category = category
        self.description = description
        self.imageURL = imageURL
        self.price = price
        self.currency = currency
        self.availability = availability
        self.lastUpdated = lastUpdated
    }
    
    public var displayName: String {
        if let title = title, !title.isEmpty {
            return title
        }
        
        if let brand = brand, !brand.isEmpty {
            return brand
        }
        
        return "Unknown Product"
    }
    
    public var hasCompleteInfo: Bool {
        return title != nil && brand != nil && category != nil
    }
    
    // MARK: - Compatibility Properties for UI Layer
    
    /// Compatibility property: maps `title` to `name` for UI code
    public var name: String {
        return title ?? displayName
    }
    
    /// Compatibility property: maps `price` to `estimatedValue` for UI code  
    public var estimatedValue: Double? {
        return price
    }
    
    /// Compatibility property: model number (not available in external product info)
    public var model: String? {
        return nil
    }
}

public enum ProductAvailability: String, Codable, CaseIterable, Sendable {
    case available = "available"
    case outOfStock = "out_of_stock"
    case discontinued = "discontinued"
    case unknown = "unknown"
    
    public var displayName: String {
        switch self {
        case .available: return "Available"
        case .outOfStock: return "Out of Stock"
        case .discontinued: return "Discontinued"
        case .unknown: return "Unknown"
        }
    }
}

// MARK: - Barcode Scan Result

public struct BarcodeScanResult: Codable, Sendable {
    public let barcodeData: BarcodeData
    public let productInfo: ProductInfo?
    public let scanLocation: String?
    public let scanContext: ScanContext
    
    public init(
        barcodeData: BarcodeData,
        productInfo: ProductInfo? = nil,
        scanLocation: String? = nil,
        scanContext: ScanContext = .manual
    ) {
        self.barcodeData = barcodeData
        self.productInfo = productInfo
        self.scanLocation = scanLocation
        self.scanContext = scanContext
    }
}

public enum ScanContext: String, Codable, CaseIterable, Sendable {
    case manual = "manual"
    case inventory = "inventory"
    case receipt = "receipt"
    case warranty = "warranty"
    
    public var displayName: String {
        switch self {
        case .manual: return "Manual Scan"
        case .inventory: return "Adding to Inventory"
        case .receipt: return "Receipt Processing"
        case .warranty: return "Warranty Lookup"
        }
    }
}

// MARK: - Barcode Validation

public struct BarcodeValidator {
    
    public static func validate(_ barcode: BarcodeData) -> BarcodeValidationResult {
        var issues: [BarcodeValidationIssue] = []
        
        // Check if value is empty
        if barcode.value.isEmpty {
            issues.append(.emptyValue)
        }
        
        // Check length for specific types
        if let expectedLength = barcode.type.expectedLength {
            if barcode.value.count != expectedLength {
                issues.append(.incorrectLength(expected: expectedLength, actual: barcode.value.count))
            }
        }
        
        // Check for valid characters (numbers only for most product barcodes)
        if barcode.type.isProductBarcode {
            if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: barcode.value)) {
                issues.append(.invalidCharacters)
            }
        }
        
        // Check confidence threshold
        if barcode.confidence < 0.8 {
            issues.append(.lowConfidence(barcode.confidence))
        }
        
        return BarcodeValidationResult(
            isValid: issues.isEmpty,
            issues: issues
        )
    }
    
    public static func checksum(for barcode: String, type: BarcodeType) -> Bool {
        switch type {
        case .upcA, .ean13:
            return validateEAN13Checksum(barcode)
        case .ean8:
            return validateEAN8Checksum(barcode)
        default:
            return true // No checksum validation for other types
        }
    }
    
    private static func validateEAN13Checksum(_ barcode: String) -> Bool {
        guard barcode.count == 13, let digits = Int(barcode) else { return false }
        
        let digitArray = barcode.compactMap { Int(String($0)) }
        guard digitArray.count == 13 else { return false }
        
        let oddSum = digitArray.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }.prefix(12).reduce(0, +)
        let evenSum = digitArray.enumerated().filter { $0.offset % 2 == 1 }.map { $0.element }.prefix(12).reduce(0, +)
        
        let total = oddSum + (evenSum * 3)
        let checkDigit = (10 - (total % 10)) % 10
        
        return checkDigit == digitArray[12]
    }
    
    private static func validateEAN8Checksum(_ barcode: String) -> Bool {
        guard barcode.count == 8 else { return false }
        
        let digitArray = barcode.compactMap { Int(String($0)) }
        guard digitArray.count == 8 else { return false }
        
        let oddSum = digitArray.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }.prefix(7).reduce(0, +)
        let evenSum = digitArray.enumerated().filter { $0.offset % 2 == 1 }.map { $0.element }.prefix(7).reduce(0, +)
        
        let total = (oddSum * 3) + evenSum
        let checkDigit = (10 - (total % 10)) % 10
        
        return checkDigit == digitArray[7]
    }
}

public struct BarcodeValidationResult {
    public let isValid: Bool
    public let issues: [BarcodeValidationIssue]
    
    public var errorMessage: String? {
        guard !isValid else { return nil }
        return issues.first?.description
    }
}

public enum BarcodeValidationIssue: Equatable {
    case emptyValue
    case incorrectLength(expected: Int, actual: Int)
    case invalidCharacters
    case lowConfidence(Float)
    case checksumFailed
    
    public var description: String {
        switch self {
        case .emptyValue:
            return "Barcode value cannot be empty"
        case .incorrectLength(let expected, let actual):
            return "Expected \(expected) digits, got \(actual)"
        case .invalidCharacters:
            return "Barcode contains invalid characters"
        case .lowConfidence(let confidence):
            return "Low scan confidence: \(Int(confidence * 100))%"
        case .checksumFailed:
            return "Barcode checksum validation failed"
        }
    }
}

// MARK: - Mock Data for Testing

#if DEBUG
public extension BarcodeData {
    static let mockUPCA = BarcodeData(
        value: "012345678905",
        type: .upcA,
        confidence: 0.95
    )
    
    static let mockEAN13 = BarcodeData(
        value: "9780140449389",
        type: .ean13,
        confidence: 0.98
    )
    
    static let mockQRCode = BarcodeData(
        value: "https://example.com/product/123",
        type: .qrCode,
        confidence: 1.0
    )
}

public extension ProductInfo {
    static let mockProduct = ProductInfo(
        barcode: "012345678905",
        title: "Sample Product",
        brand: "Sample Brand",
        category: "Electronics",
        description: "A sample product for testing purposes",
        imageURL: "https://example.com/image.jpg",
        price: 29.99,
        currency: "USD",
        availability: .available
    )
}
#endif
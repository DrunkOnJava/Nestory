// Layer: Foundation
// Module: Foundation/Models
// Purpose: Receipt model for purchase documentation

import Foundation
import SwiftData

/// Receipt for item purchases
@Model
public final class Receipt: @unchecked Sendable {
    // MARK: - Properties

    // CloudKit compatible: removed .unique constraint
    public var id: UUID = UUID()

    public var vendor: String = ""
    public var total: Data? // Encoded Money
    public var tax: Data? // Encoded Money
    public var purchaseDate: Date = Date()
    public var receiptNumber: String?
    public var paymentMethod: String?
    public var rawText: String? // OCR extracted text
    public var fileName: String? // Scanned receipt image
    public var imageData: Data? // The actual receipt image data
    public var confidence = 0.0 // OCR confidence score (0.0 - 1.0)
    public var categories: [String] = [] // Auto-detected categories (grocery, electronics, etc.)

    // Timestamps
    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()

    // MARK: - Relationships

    @Relationship(inverse: \Item.receipts)
    public var item: Item? // CloudKit compatible optional relationship

    // MARK: - Initialization

    public init(
        vendor: String,
        total: Money,
        purchaseDate: Date,
        item: Item? = nil
    ) {
        // Override defaults with provided values
        self.id = UUID()
        self.vendor = vendor
        self.total = try? JSONEncoder().encode(total)
        self.purchaseDate = purchaseDate
        self.item = item
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// Get total as Money object
    public var totalMoney: Money? {
        get {
            guard let data = total else { return nil }
            return try? JSONDecoder().decode(Money.self, from: data)
        }
        set {
            total = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    /// Get tax as Money object
    public var taxMoney: Money? {
        get {
            guard let data = tax else { return nil }
            return try? JSONDecoder().decode(Money.self, from: data)
        }
        set {
            tax = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    /// Subtotal (total minus tax)
    public var subtotal: Money? {
        guard let total = totalMoney,
              let tax = taxMoney
        else {
            return totalMoney
        }
        return try? total - tax
    }

    /// Check if receipt has been OCR processed
    public var hasOCRData: Bool {
        guard let rawText else { return false }
        return !rawText.isEmpty
    }

    /// Check if receipt has image attached
    public var hasImage: Bool {
        imageData != nil || (fileName != nil && !fileName!.isEmpty)
    }

    /// Get confidence level description
    public var confidenceLevel: String {
        switch confidence {
        case 0.9 ... 1.0: "Excellent"
        case 0.7 ..< 0.9: "Good"
        case 0.5 ..< 0.7: "Fair"
        case 0.0 ..< 0.5: "Poor"
        default: "Unknown"
        }
    }

    /// Check if receipt data is reliable enough for auto-application
    public var isReliable: Bool {
        confidence >= 0.7 && hasOCRData
    }
    
    // MARK: - Compatibility Properties
    
    /// Alias for vendor property (for compatibility with validation code)
    public var merchantName: String {
        get { vendor }
        set { vendor = newValue; updatedAt = Date() }
    }
    
    /// Total amount as Decimal (for compatibility with validation code)
    public var totalAmount: Decimal? {
        get { totalMoney?.amount }
        set { 
            if let amount = newValue {
                totalMoney = Money(amount: amount, currencyCode: totalMoney?.currencyCode ?? "USD")
            } else {
                totalMoney = nil
            }
        }
    }

    // MARK: - Methods

    /// Update receipt properties
    public func update(
        vendor: String? = nil,
        total: Money? = nil,
        tax: Money? = nil,
        purchaseDate: Date? = nil,
        receiptNumber: String? = nil,
        paymentMethod: String? = nil,
    ) {
        if let vendor {
            self.vendor = vendor
        }
        if let total {
            totalMoney = total
        }
        if let tax {
            taxMoney = tax
        }
        if let purchaseDate {
            self.purchaseDate = purchaseDate
        }
        if let receiptNumber {
            self.receiptNumber = receiptNumber
        }
        if let paymentMethod {
            self.paymentMethod = paymentMethod
        }
        updatedAt = Date()
    }

    /// Set OCR extracted text
    public func setOCRText(_ text: String) {
        rawText = text
        updatedAt = Date()
    }

    /// Attach scanned image
    public func attachImage(fileName: String) {
        self.fileName = fileName
        updatedAt = Date()
    }

    /// Set receipt image data directly
    public func setImageData(_ data: Data, fileName: String? = nil) {
        self.imageData = data
        if let fileName {
            self.fileName = fileName
        }
        updatedAt = Date()
    }

    /// Set OCR results with confidence score
    public func setOCRResults(text: String, confidence: Double, categories: [String] = []) {
        self.rawText = text
        self.confidence = confidence
        self.categories = categories
        updatedAt = Date()
    }
}

// MARK: - TCA Compatibility

extension Receipt: Equatable {
    public static func == (lhs: Receipt, rhs: Receipt) -> Bool {
        lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }
}

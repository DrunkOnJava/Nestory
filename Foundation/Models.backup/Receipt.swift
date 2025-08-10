// Layer: Foundation
// Module: Foundation/Models
// Purpose: Receipt model for purchase documentation

import Foundation
import SwiftData

/// Receipt for item purchases
@Model
public final class Receipt {
    // MARK: - Properties
    
    @Attribute(.unique)
    public var id: UUID
    
    public var vendor: String
    public var total: Data? // Encoded Money
    public var tax: Data? // Encoded Money
    public var purchaseDate: Date
    public var receiptNumber: String?
    public var paymentMethod: String?
    public var rawText: String? // OCR extracted text
    public var fileName: String? // Scanned receipt image
    
    // Timestamps
    public var createdAt: Date
    public var updatedAt: Date
    
    // MARK: - Relationships
    
    @Relationship(inverse: \Item.receipts)
    public var item: Item?
    
    // MARK: - Initialization
    
    public init(
        vendor: String,
        total: Money,
        purchaseDate: Date,
        item: Item? = nil
    ) {
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
              let tax = taxMoney else {
            return totalMoney
        }
        return try? total - tax
    }
    
    /// Check if receipt has been OCR processed
    public var hasOCRData: Bool {
        rawText != nil && !rawText!.isEmpty
    }
    
    /// Check if receipt has image attached
    public var hasImage: Bool {
        fileName != nil && !fileName!.isEmpty
    }
    
    // MARK: - Methods
    
    /// Update receipt properties
    public func update(
        vendor: String? = nil,
        total: Money? = nil,
        tax: Money? = nil,
        purchaseDate: Date? = nil,
        receiptNumber: String? = nil,
        paymentMethod: String? = nil
    ) {
        if let vendor = vendor {
            self.vendor = vendor
        }
        if let total = total {
            self.totalMoney = total
        }
        if let tax = tax {
            self.taxMoney = tax
        }
        if let purchaseDate = purchaseDate {
            self.purchaseDate = purchaseDate
        }
        if let receiptNumber = receiptNumber {
            self.receiptNumber = receiptNumber
        }
        if let paymentMethod = paymentMethod {
            self.paymentMethod = paymentMethod
        }
        self.updatedAt = Date()
    }
    
    /// Set OCR extracted text
    public func setOCRText(_ text: String) {
        self.rawText = text
        self.updatedAt = Date()
    }
    
    /// Attach scanned image
    public func attachImage(fileName: String) {
        self.fileName = fileName
        self.updatedAt = Date()
    }
}

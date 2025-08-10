//
// Layer: Foundation
// Module: Models
// Purpose: Core Item model for inventory
//

import Foundation
import SwiftData

@Model
public final class Item {
    @Attribute(.unique)
    public var id: UUID

    public var name: String
    public var itemDescription: String?
    public var brand: String?
    public var modelNumber: String?
    public var serialNumber: String?
    public var notes: String?

    public var quantity: Int
    public var purchasePrice: Decimal?
    public var purchaseDate: Date?
    public var currency: String = "USD"

    public var tags: [String] = []
    public var imageData: Data?
    public var receiptImageData: Data?
    public var extractedReceiptText: String?

    // Warranty tracking
    public var warrantyExpirationDate: Date?
    public var warrantyProvider: String?
    public var warrantyNotes: String?

    // Location/Room assignment
    public var room: String?
    public var specificLocation: String?

    // Document attachments
    public var manualPDFData: Data?
    public var documentAttachments: [Data] = []
    public var documentNames: [String] = []

    // Condition documentation
    public var condition: String = "excellent" // SwiftData doesn't support enum defaults
    public var conditionNotes: String?
    public var conditionPhotos: [Data] = []
    public var conditionPhotoDescriptions: [String] = []
    public var lastConditionUpdate: Date?

    // Computed property for type-safe condition
    public var itemCondition: ItemCondition {
        get { ItemCondition(rawValue: condition) ?? .excellent }
        set { condition = newValue.rawValue }
    }

    public var createdAt: Date
    public var updatedAt: Date

    // Relationships
    public var category: Category?

    public init(
        name: String,
        itemDescription: String? = nil,
        quantity: Int = 1,
        category: Category? = nil
    ) {
        id = UUID()
        self.name = name
        self.itemDescription = itemDescription
        self.quantity = quantity
        self.category = category
        currency = "USD"
        tags = []
        createdAt = Date()
        updatedAt = Date()
    }
}

// MARK: - Item Condition Enum

public enum ItemCondition: String, CaseIterable, Codable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    case damaged = "Damaged"
    case new = "New"
    case likeNew = "Like New"
    case refurbished = "Refurbished"

    public var color: String {
        switch self {
        case .new, .excellent:
            "#34C759" // Green
        case .likeNew, .good:
            "#007AFF" // Blue
        case .fair, .refurbished:
            "#FF9500" // Orange
        case .poor, .damaged:
            "#FF3B30" // Red
        }
    }

    public var icon: String {
        switch self {
        case .new:
            "sparkles"
        case .excellent, .likeNew:
            "star.fill"
        case .good:
            "star.leadinghalf.filled"
        case .fair, .refurbished:
            "star"
        case .poor:
            "exclamationmark.triangle"
        case .damaged:
            "xmark.octagon"
        }
    }

    public var insuranceImpact: String {
        switch self {
        case .new:
            "100% replacement value"
        case .excellent, .likeNew:
            "90-95% replacement value"
        case .good:
            "75-85% replacement value"
        case .fair, .refurbished:
            "50-70% replacement value"
        case .poor:
            "25-45% replacement value"
        case .damaged:
            "Requires assessment"
        }
    }
}

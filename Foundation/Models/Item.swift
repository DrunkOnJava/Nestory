//
// Layer: Foundation
// Module: Models
// Purpose: Core Item model for inventory
//
// 🏗️ FOUNDATION LAYER PATTERN: Pure Domain Model
// - Contains ONLY domain data and invariants (NO business logic)
// - NO imports except Swift stdlib and SwiftData (architectural rule)
// - Represents core entities in our insurance documentation domain
// - Immutable value semantics where possible
//
// 🎯 INSURANCE DOCUMENTATION FOCUS: Personal belongings tracking
// - Comprehensive metadata for insurance claim preparation
// - Condition tracking for accurate valuation
// - Warranty integration for coverage planning
// - Receipt association for purchase verification
// - Document attachment for complete documentation
//
// 📊 DATA ARCHITECTURE: SwiftData persistent model
// - @Model for automatic persistence and relationships
// - @Attribute(.unique) for stable identity
// - Sendable compliance for Swift 6 concurrency
// - Computed properties for type-safe enum access
//
// 📋 FOUNDATION STANDARDS:
// - All properties have sensible defaults
// - Required initializer for essential properties only
// - Automatic timestamps (createdAt, updatedAt)
// - Clear property grouping with comments
//
// 🍎 APPLE FRAMEWORK OPPORTUNITIES (Phase 3):
// - Contacts: Vendor/store contact integration
// - SharedWithYou: System-level sharing support
// - JournalingSuggestions: Memory and journaling integration
//

import Foundation
import SwiftData

@Model
public final class Item: @unchecked Sendable {
    // 🆔 IDENTITY: Stable identifier across app lifecycle
    // CloudKit compatible: removed .unique constraint
    public var id: UUID = UUID()

    // 📝 BASIC INFORMATION: Core identification data
    public var name: String = "" // Required: Primary display name
    public var itemDescription: String? // Optional: Detailed description for insurance
    public var brand: String? // Optional: Manufacturer (Apple, Samsung, etc.)
    public var modelNumber: String? // Optional: Specific model for replacement value
    public var serialNumber: String? // Optional: Critical for insurance claims
    public var barcode: String? // Optional: For product lookup integration
    public var notes: String? // Optional: User notes and observations

    // 💰 FINANCIAL INFORMATION: Purchase and valuation data
    public var quantity: Int = 1 // Required: How many items (usually 1)
    public var purchasePrice: Decimal? // Optional: Original cost for insurance basis
    public var purchaseDate: Date? // Optional: Age affects replacement value
    public var currency = "USD" // Default: User's preferred currency

    // 🏷️ ORGANIZATION: Categorization and searchability
    public var tags: [String] = [] // User-defined tags for flexible organization
    public var locationName: String? // Room or location where item is kept
    public var imageData: Data? // Primary item photo for identification
    public var receiptImageData: Data? // Receipt photo for purchase verification
    public var extractedReceiptText: String? // OCR-extracted text from receipt

    // 🛡️ WARRANTY TRACKING: Protection planning
    public var warrantyExpirationDate: Date? // When warranty coverage ends
    public var warrantyProvider: String? // Who provides warranty service
    public var warrantyNotes: String? // Warranty terms and conditions


    // 📄 DOCUMENT ATTACHMENTS: Supporting documentation
    public var manualPDFData: Data? // Product manual for reference
    public var documentAttachments: [Data] = [] // Additional supporting documents
    public var documentNames: [String] = [] // Human-readable names for documents
// DEAD CODE: // DEAD CODE: 
    // 🔍 CONDITION DOCUMENTATION: Current state assessment
    public var condition = "excellent" // String storage (SwiftData enum limitation)
    public var conditionNotes: String? // Detailed condition description
    public var conditionPhotos: [Data] = [] // Photos showing current condition
    public var conditionPhotoDescriptions: [String] = [] // Captions for condition photos
    public var lastConditionUpdate: Date? // When condition was last assessed

    // 🔄 TYPE-SAFE CONDITION ACCESS: Computed property for enum safety
    public var itemCondition: ItemCondition {
        get { ItemCondition(rawValue: condition) ?? .excellent }
        set { condition = newValue.rawValue }
    }
    
    // 📸 COMPUTED PHOTO ACCESS: Compatibility with validation code
    public var photos: [Data] {
        var allPhotos: [Data] = []
        if let imageData = imageData {
            allPhotos.append(imageData)
        }
        if let receiptImageData = receiptImageData {
            allPhotos.append(receiptImageData)
        }
        allPhotos.append(contentsOf: conditionPhotos)
        return allPhotos
    }

    // ⏰ METADATA: Automatic lifecycle tracking
    public var createdAt: Date = Date() // When item was first added
    public var updatedAt: Date = Date() // Last modification timestamp

    // 🔗 RELATIONSHIPS: Connected entities (CloudKit compatible)
    public var category: Category? // Optional category classification
    public var warranty: Warranty? // Optional detailed warranty information
    @Relationship(deleteRule: .cascade)
    public var receipts: [Receipt]? // Associated purchase receipts (optional for CloudKit)

    public init(
        name: String,
        itemDescription: String? = nil,
        quantity: Int = 1,
        category: Category? = nil
    ) {
        // Override defaults with provided values
        self.id = UUID()
        self.name = name
        self.itemDescription = itemDescription
        self.quantity = quantity
        self.category = category
        self.currency = "USD"
        self.tags = []
        self.receipts = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Item Condition Enum

public enum ItemCondition: String, CaseIterable, Codable, Sendable {
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

// MARK: - TCA Compatibility

extension Item: Equatable {
    public static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }
}

// MARK: - Codable Conformance for Export Operations  
extension Item: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, name, itemDescription, brand, modelNumber, serialNumber, barcode, notes
        case quantity, purchasePrice, purchaseDate, currency, tags, locationName
        case warrantyExpirationDate, warrantyProvider, warrantyNotes
        case condition, conditionNotes, lastConditionUpdate
        case createdAt, updatedAt
        // Note: Data properties, relationships, and complex properties excluded for export simplicity
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(itemDescription, forKey: .itemDescription)
        try container.encodeIfPresent(brand, forKey: .brand)
        try container.encodeIfPresent(modelNumber, forKey: .modelNumber)
        try container.encodeIfPresent(serialNumber, forKey: .serialNumber)
        try container.encodeIfPresent(barcode, forKey: .barcode)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(quantity, forKey: .quantity)
        try container.encodeIfPresent(purchasePrice, forKey: .purchasePrice)
        try container.encodeIfPresent(purchaseDate, forKey: .purchaseDate)
        try container.encode(currency, forKey: .currency)
        try container.encode(tags, forKey: .tags)
        try container.encodeIfPresent(locationName, forKey: .locationName)
        try container.encodeIfPresent(warrantyExpirationDate, forKey: .warrantyExpirationDate)
        try container.encodeIfPresent(warrantyProvider, forKey: .warrantyProvider)
        try container.encodeIfPresent(warrantyNotes, forKey: .warrantyNotes)
        try container.encode(condition, forKey: .condition)
        try container.encodeIfPresent(conditionNotes, forKey: .conditionNotes)
        try container.encodeIfPresent(lastConditionUpdate, forKey: .lastConditionUpdate)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let itemDescription = try container.decodeIfPresent(String.self, forKey: .itemDescription)
        let quantity = try container.decode(Int.self, forKey: .quantity)
        
        self.init(name: name, itemDescription: itemDescription, quantity: quantity)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.brand = try container.decodeIfPresent(String.self, forKey: .brand)
        self.modelNumber = try container.decodeIfPresent(String.self, forKey: .modelNumber)
        self.serialNumber = try container.decodeIfPresent(String.self, forKey: .serialNumber)
        self.barcode = try container.decodeIfPresent(String.self, forKey: .barcode)
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
        self.purchasePrice = try container.decodeIfPresent(Decimal.self, forKey: .purchasePrice)
        self.purchaseDate = try container.decodeIfPresent(Date.self, forKey: .purchaseDate)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.locationName = try container.decodeIfPresent(String.self, forKey: .locationName)
        self.warrantyExpirationDate = try container.decodeIfPresent(Date.self, forKey: .warrantyExpirationDate)
        self.warrantyProvider = try container.decodeIfPresent(String.self, forKey: .warrantyProvider)
        self.warrantyNotes = try container.decodeIfPresent(String.self, forKey: .warrantyNotes)
        self.condition = try container.decode(String.self, forKey: .condition)
        self.conditionNotes = try container.decodeIfPresent(String.self, forKey: .conditionNotes)
        self.lastConditionUpdate = try container.decodeIfPresent(Date.self, forKey: .lastConditionUpdate)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

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
    @Attribute(.unique)
    public var id: UUID

    // 📝 BASIC INFORMATION: Core identification data
    public var name: String // Required: Primary display name
    public var itemDescription: String? // Optional: Detailed description for insurance
    public var brand: String? // Optional: Manufacturer (Apple, Samsung, etc.)
    public var modelNumber: String? // Optional: Specific model for replacement value
    public var serialNumber: String? // Optional: Critical for insurance claims
    public var barcode: String? // Optional: For product lookup integration
    public var notes: String? // Optional: User notes and observations

    // 💰 FINANCIAL INFORMATION: Purchase and valuation data
    public var quantity: Int // Required: How many items (usually 1)
    public var purchasePrice: Decimal? // Optional: Original cost for insurance basis
    public var purchaseDate: Date? // Optional: Age affects replacement value
    public var currency = "USD" // Default: User's preferred currency

    // 🏷️ ORGANIZATION: Categorization and searchability
    public var tags: [String] = [] // User-defined tags for flexible organization
    public var imageData: Data? // Primary item photo for identification
    public var receiptImageData: Data? // Receipt photo for purchase verification
    public var extractedReceiptText: String? // OCR-extracted text from receipt

    // 🛡️ WARRANTY TRACKING: Protection planning
    public var warrantyExpirationDate: Date? // When warranty coverage ends
    public var warrantyProvider: String? // Who provides warranty service
    public var warrantyNotes: String? // Warranty terms and conditions

    // 🏠 LOCATION TRACKING: Where items are stored
    public var room: String? // Room location (Living Room, Office, etc.)
    public var specificLocation: String? // Specific location within room

    // 📄 DOCUMENT ATTACHMENTS: Supporting documentation
    public var manualPDFData: Data? // Product manual for reference
    public var documentAttachments: [Data] = [] // Additional supporting documents
    public var documentNames: [String] = [] // Human-readable names for documents

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

    // ⏰ METADATA: Automatic lifecycle tracking
    public var createdAt: Date // When item was first added
    public var updatedAt: Date // Last modification timestamp

    // 🔗 RELATIONSHIPS: Connected entities
    public var category: Category? // Optional category classification
    public var warranty: Warranty? // Optional detailed warranty information
    public var receipts: [Receipt] = [] // Associated purchase receipts

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

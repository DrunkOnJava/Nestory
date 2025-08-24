//
// Layer: Foundation
// Module: Models
// Purpose: Category model for organizing items
//

import Foundation
import SwiftData

@Model
public final class Category: @unchecked Sendable {
    // CloudKit compatible: removed .unique constraint
    public var id: UUID = UUID()

    public var name: String = ""
    public var icon: String = "folder.fill"
    public var colorHex: String = "#007AFF"
    public var itemCount: Int = 0

    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()

    @Relationship(deleteRule: .nullify, inverse: \Item.category)
    public var items: [Item]? // CloudKit compatible optional relationship

    public init(
        name: String,
        icon: String = "folder.fill",
        colorHex: String = "#007AFF"
    ) {
        // Override defaults with provided values
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.itemCount = 0
        self.items = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

extension Category {
    public static func createDefaultCategories() -> [Category] {
        [
            Category(name: "Electronics", icon: "tv.fill", colorHex: "#FF6B6B"),
            Category(name: "Furniture", icon: "sofa.fill", colorHex: "#4ECDC4"),
            Category(name: "Clothing", icon: "tshirt.fill", colorHex: "#45B7D1"),
            Category(name: "Books", icon: "book.fill", colorHex: "#96CEB4"),
            Category(name: "Kitchen", icon: "fork.knife", colorHex: "#FFEAA7"),
            Category(name: "Tools", icon: "hammer.fill", colorHex: "#DDA0DD"),
            Category(name: "Sports", icon: "sportscourt.fill", colorHex: "#98D8C8"),
            Category(name: "Other", icon: "square.grid.2x2.fill", colorHex: "#B0B0B0"),
        ]
    }
}

// MARK: - TCA Compatibility

extension Category: Equatable {
    public static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }
}

// MARK: - Codable Conformance for Export Operations
extension Category: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, name, icon, colorHex, itemCount, createdAt, updatedAt
        // Note: Relationship properties excluded for export simplicity
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(colorHex, forKey: .colorHex)
        try container.encode(itemCount, forKey: .itemCount)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let icon = try container.decode(String.self, forKey: .icon)
        let colorHex = try container.decode(String.self, forKey: .colorHex)
        
        self.init(name: name, icon: icon, colorHex: colorHex)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.itemCount = try container.decode(Int.self, forKey: .itemCount)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

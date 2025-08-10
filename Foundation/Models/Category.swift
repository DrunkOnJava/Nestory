//
// Layer: Foundation
// Module: Models
// Purpose: Category model for organizing items
//

import Foundation
import SwiftData

@Model
public final class Category {
    @Attribute(.unique)
    public var id: UUID
    
    public var name: String
    public var icon: String
    public var colorHex: String
    public var itemCount: Int
    
    public var createdAt: Date
    public var updatedAt: Date
    
    @Relationship(deleteRule: .nullify, inverse: \Item.category)
    public var items: [Item]?
    
    public init(
        name: String,
        icon: String = "folder.fill",
        colorHex: String = "#007AFF"
    ) {
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
            Category(name: "Other", icon: "square.grid.2x2.fill", colorHex: "#B0B0B0")
        ]
    }
}
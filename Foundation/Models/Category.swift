//
// Layer: Foundation
// Module: Models
// Purpose: Category model for organizing items
//

import Foundation
import SwiftData

@Model
public final class Category: @unchecked Sendable {
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
        id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        itemCount = 0
        items = []
        createdAt = Date()
        updatedAt = Date()
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

// MARK: - Equatable Conformance for TCA State Management
extension Category: Equatable {
    public static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.updatedAt == rhs.updatedAt &&
               lhs.itemCount == rhs.itemCount
    }
}

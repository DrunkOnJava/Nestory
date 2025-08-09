// Layer: Foundation

import Foundation
import SwiftData

@Model
public final class Category {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var slug: String
    public var color: String
    public var iconName: String?
    public var sortOrder: Int

    @Relationship(deleteRule: .nullify, inverse: \Category.parent)
    public var children: [Category]?

    @Relationship(deleteRule: .nullify)
    public var parent: Category?

    @Relationship(deleteRule: .nullify, inverse: \Item.category)
    public var items: [Item]?

    public var createdAt: Date
    public var updatedAt: Date

    public init(
        name: String,
        color: String = "#808080",
        iconName: String? = nil,
        parent: Category? = nil,
        sortOrder: Int = 0
    ) throws {
        id = UUID()
        self.name = name
        slug = try Slug(name).value
        self.color = color
        self.iconName = iconName
        self.parent = parent
        self.sortOrder = sortOrder
        children = []
        items = []
        createdAt = Date()
        updatedAt = Date()
    }

    public var depth: Int {
        var count = 0
        var current = parent
        while current != nil {
            count += 1
            current = current?.parent
        }
        return count
    }

    public var rootCategory: Category {
        var current = self
        while let parent = current.parent {
            current = parent
        }
        return current
    }

    public var allSubcategories: [Category] {
        var result: [Category] = []
        var queue = children ?? []

        while !queue.isEmpty {
            let category = queue.removeFirst()
            result.append(category)
            if let children = category.children {
                queue.append(contentsOf: children)
            }
        }

        return result
    }

    public var itemCount: Int {
        (items?.count ?? 0) + allSubcategories.reduce(0) { $0 + ($1.items?.count ?? 0) }
    }
}

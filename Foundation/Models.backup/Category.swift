// Layer: Foundation
// Module: Foundation/Models
// Purpose: Category model for organizing items

import Foundation
import SwiftData

/// Category for organizing items hierarchically
@Model
public final class Category {
    // MARK: - Properties

    @Attribute(.unique)
    public var id: UUID

    public var name: String
    public var categoryDescription: String?
    public var color: String? // Hex color code
    public var icon: String? // SF Symbol name
    public var sortOrder: Int

    // Timestamps
    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Relationships

    @Relationship(deleteRule: .nullify)
    public var parent: Category?

    @Relationship(deleteRule: .cascade, inverse: \Category.parent)
    public var children: [Category]

    @Relationship(inverse: \Item.category)
    public var items: [Item]

    // MARK: - Initialization

    public init(
        name: String,
        description: String? = nil,
        parent: Category? = nil,
        color: String? = nil,
        icon: String? = nil
    ) {
        id = UUID()
        self.name = name
        categoryDescription = description
        self.parent = parent
        self.color = color
        self.icon = icon
        sortOrder = 0
        children = []
        items = []
        createdAt = Date()
        updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// Full path from root category
    public var path: String {
        if let parent {
            return "\(parent.path) → \(name)"
        }
        return name
    }

    /// Depth in hierarchy (0 for root)
    public var depth: Int {
        var count = 0
        var current = parent
        while current != nil {
            count += 1
            current = current?.parent
        }
        return count
    }

    /// Check if this is a root category
    public var isRoot: Bool {
        parent == nil
    }

    /// Check if this is a leaf category (no children)
    public var isLeaf: Bool {
        children.isEmpty
    }

    /// Total count of items including subcategories
    public var totalItemCount: Int {
        var count = items.count
        for child in children {
            count += child.totalItemCount
        }
        return count
    }

    /// All descendant categories (recursive)
    public var allDescendants: [Category] {
        var descendants: [Category] = []
        for child in children {
            descendants.append(child)
            descendants.append(contentsOf: child.allDescendants)
        }
        return descendants
    }

    /// All ancestor categories from parent to root
    public var ancestors: [Category] {
        var ancestors: [Category] = []
        var current = parent
        while let category = current {
            ancestors.append(category)
            current = category.parent
        }
        return ancestors
    }

    // MARK: - Methods

    /// Add a subcategory
    public func addChild(_ category: Category) {
        category.parent = self
        if !children.contains(where: { $0.id == category.id }) {
            children.append(category)
            children.sort { $0.sortOrder < $1.sortOrder }
            updatedAt = Date()
        }
    }

    /// Remove a subcategory
    public func removeChild(_ category: Category) {
        children.removeAll { $0.id == category.id }
        category.parent = nil
        updatedAt = Date()
    }

    /// Move to a different parent
    public func move(to newParent: Category?) {
        // Check for circular reference
        if let newParent {
            if newParent.id == id || newParent.ancestors.contains(where: { $0.id == id }) {
                return // Would create circular reference
            }
        }

        parent?.removeChild(self)
        parent = newParent
        newParent?.addChild(self)
        updatedAt = Date()
    }

    /// Check if this category is an ancestor of another
    public func isAncestor(of category: Category) -> Bool {
        category.ancestors.contains { $0.id == id }
    }

    /// Check if this category is a descendant of another
    public func isDescendant(of category: Category) -> Bool {
        ancestors.contains { $0.id == category.id }
    }

    /// Update category properties
    public func update(
        name: String? = nil,
        description: String? = nil,
        color: String? = nil,
        icon: String? = nil,
        sortOrder: Int? = nil,
    ) {
        if let name {
            self.name = name
        }
        if let description {
            categoryDescription = description
        }
        if let color {
            self.color = color
        }
        if let icon {
            self.icon = icon
        }
        if let sortOrder {
            self.sortOrder = sortOrder
        }
        updatedAt = Date()
    }
}

// MARK: - Comparable

extension Category: Comparable {
    public static func < (lhs: Category, rhs: Category) -> Bool {
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        return lhs.name < rhs.name
    }
}

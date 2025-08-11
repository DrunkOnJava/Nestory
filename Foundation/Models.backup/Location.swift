// Layer: Foundation
// Module: Foundation/Models
// Purpose: Location model for tracking item locations

import Foundation
import SwiftData

/// Physical location for items (hierarchical: Home → Room → Container)
@Model
public final class Location {
    // MARK: - Properties

    @Attribute(.unique)
    public var id: UUID

    public var name: String
    public var locationDescription: String?
    public var type: String // "home", "room", "container", "area", etc.
    public var address: String?
    public var notes: String?
    public var sortOrder: Int

    // Timestamps
    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Relationships

    @Relationship(deleteRule: .nullify)
    public var parent: Location?

    @Relationship(deleteRule: .cascade, inverse: \Location.parent)
    public var children: [Location]

    @Relationship(inverse: \Item.location)
    public var items: [Item]

    // MARK: - Initialization

    public init(
        name: String,
        type: LocationType = .container,
        description: String? = nil,
        parent: Location? = nil
    ) {
        id = UUID()
        self.name = name
        self.type = type.rawValue
        locationDescription = description
        self.parent = parent
        sortOrder = 0
        children = []
        items = []
        createdAt = Date()
        updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// Location type enum
    public var locationType: LocationType {
        get { LocationType(rawValue: type) ?? .container }
        set {
            type = newValue.rawValue
            updatedAt = Date()
        }
    }

    /// Full path from root location
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

    /// Check if this is a root location
    public var isRoot: Bool {
        parent == nil
    }

    /// Check if this is a leaf location (no children)
    public var isLeaf: Bool {
        children.isEmpty
    }

    /// Total count of items including sublocations
    public var totalItemCount: Int {
        var count = items.count
        for child in children {
            count += child.totalItemCount
        }
        return count
    }

    /// All descendant locations (recursive)
    public var allDescendants: [Location] {
        var descendants: [Location] = []
        for child in children {
            descendants.append(child)
            descendants.append(contentsOf: child.allDescendants)
        }
        return descendants
    }

    /// All ancestor locations from parent to root
    public var ancestors: [Location] {
        var ancestors: [Location] = []
        var current = parent
        while let location = current {
            ancestors.append(location)
            current = location.parent
        }
        return ancestors
    }

    /// Get the root location (home)
    public var rootLocation: Location {
        if let parent {
            return parent.rootLocation
        }
        return self
    }

    // MARK: - Methods

    /// Add a sublocation
    public func addChild(_ location: Location) {
        location.parent = self
        if !children.contains(where: { $0.id == location.id }) {
            children.append(location)
            children.sort { $0.sortOrder < $1.sortOrder }
            updatedAt = Date()
        }
    }

    /// Remove a sublocation
    public func removeChild(_ location: Location) {
        children.removeAll { $0.id == location.id }
        location.parent = nil
        updatedAt = Date()
    }

    /// Move to a different parent
    public func move(to newParent: Location?) {
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

    /// Check if this location is an ancestor of another
    public func isAncestor(of location: Location) -> Bool {
        location.ancestors.contains { $0.id == id }
    }

    /// Check if this location is a descendant of another
    public func isDescendant(of location: Location) -> Bool {
        ancestors.contains { $0.id == location.id }
    }

    /// Update location properties
    public func update(
        name: String? = nil,
        type: LocationType? = nil,
        description: String? = nil,
        address: String? = nil,
        notes: String? = nil,
        sortOrder: Int? = nil,
    ) {
        if let name {
            self.name = name
        }
        if let type {
            locationType = type
        }
        if let description {
            locationDescription = description
        }
        if let address {
            self.address = address
        }
        if let notes {
            self.notes = notes
        }
        if let sortOrder {
            self.sortOrder = sortOrder
        }
        updatedAt = Date()
    }
}

// MARK: - Location Type

public enum LocationType: String, CaseIterable, Codable {
    case home
    case room
    case container
    case area
    case storage
    case garage
    case attic
    case basement
    case closet
    case shelf
    case drawer
    case box
    case other

    public var displayName: String {
        switch self {
        case .home: "Home"
        case .room: "Room"
        case .container: "Container"
        case .area: "Area"
        case .storage: "Storage Unit"
        case .garage: "Garage"
        case .attic: "Attic"
        case .basement: "Basement"
        case .closet: "Closet"
        case .shelf: "Shelf"
        case .drawer: "Drawer"
        case .box: "Box"
        case .other: "Other"
        }
    }

    public var icon: String {
        switch self {
        case .home: "house.fill"
        case .room: "door.left.hand.open"
        case .container: "shippingbox.fill"
        case .area: "mappin.and.ellipse"
        case .storage: "archivebox.fill"
        case .garage: "car.fill"
        case .attic: "triangle.fill"
        case .basement: "stairs"
        case .closet: "door.sliding.left.hand.closed"
        case .shelf: "books.vertical.fill"
        case .drawer: "fibrechannel"
        case .box: "cube.box.fill"
        case .other: "questionmark.folder.fill"
        }
    }
}

// MARK: - Comparable

extension Location: Comparable {
    public static func < (lhs: Location, rhs: Location) -> Bool {
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        return lhs.name < rhs.name
    }
}

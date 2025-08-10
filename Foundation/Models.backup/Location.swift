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
        self.id = UUID()
        self.name = name
        self.type = type.rawValue
        self.locationDescription = description
        self.parent = parent
        self.sortOrder = 0
        self.children = []
        self.items = []
        self.createdAt = Date()
        self.updatedAt = Date()
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
        if let parent = parent {
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
        if let parent = parent {
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
        if let newParent = newParent {
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
        sortOrder: Int? = nil
    ) {
        if let name = name {
            self.name = name
        }
        if let type = type {
            self.locationType = type
        }
        if let description = description {
            self.locationDescription = description
        }
        if let address = address {
            self.address = address
        }
        if let notes = notes {
            self.notes = notes
        }
        if let sortOrder = sortOrder {
            self.sortOrder = sortOrder
        }
        self.updatedAt = Date()
    }
}

// MARK: - Location Type

public enum LocationType: String, CaseIterable, Codable {
    case home = "home"
    case room = "room"
    case container = "container"
    case area = "area"
    case storage = "storage"
    case garage = "garage"
    case attic = "attic"
    case basement = "basement"
    case closet = "closet"
    case shelf = "shelf"
    case drawer = "drawer"
    case box = "box"
    case other = "other"
    
    public var displayName: String {
        switch self {
        case .home: return "Home"
        case .room: return "Room"
        case .container: return "Container"
        case .area: return "Area"
        case .storage: return "Storage Unit"
        case .garage: return "Garage"
        case .attic: return "Attic"
        case .basement: return "Basement"
        case .closet: return "Closet"
        case .shelf: return "Shelf"
        case .drawer: return "Drawer"
        case .box: return "Box"
        case .other: return "Other"
        }
    }
    
    public var icon: String {
        switch self {
        case .home: return "house.fill"
        case .room: return "door.left.hand.open"
        case .container: return "shippingbox.fill"
        case .area: return "mappin.and.ellipse"
        case .storage: return "archivebox.fill"
        case .garage: return "car.fill"
        case .attic: return "triangle.fill"
        case .basement: return "stairs"
        case .closet: return "door.sliding.left.hand.closed"
        case .shelf: return "books.vertical.fill"
        case .drawer: return "fibrechannel"
        case .box: return "cube.box.fill"
        case .other: return "questionmark.folder.fill"
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

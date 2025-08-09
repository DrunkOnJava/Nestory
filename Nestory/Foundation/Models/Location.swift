// Layer: Foundation

import Foundation
import SwiftData

@Model
public final class Location {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var slug: String
    public var type: LocationType
    public var notes: String?
    public var sortOrder: Int

    @Relationship(deleteRule: .nullify, inverse: \Location.parent)
    public var children: [Location]?

    @Relationship(deleteRule: .nullify)
    public var parent: Location?

    @Relationship(deleteRule: .nullify, inverse: \Item.location)
    public var items: [Item]?

    public var createdAt: Date
    public var updatedAt: Date

    public init(
        name: String,
        type: LocationType = .room,
        notes: String? = nil,
        parent: Location? = nil,
        sortOrder: Int = 0
    ) throws {
        id = UUID()
        self.name = name
        slug = try Slug(name).value
        self.type = type
        self.notes = notes
        self.parent = parent
        self.sortOrder = sortOrder
        children = []
        items = []
        createdAt = Date()
        updatedAt = Date()
    }

    public var fullPath: String {
        var path = [name]
        var current = parent
        while let loc = current {
            path.insert(loc.name, at: 0)
            current = loc.parent
        }
        return path.joined(separator: " > ")
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

    public var rootLocation: Location {
        var current = self
        while let parent = current.parent {
            current = parent
        }
        return current
    }

    public var allSublocations: [Location] {
        var result: [Location] = []
        var queue = children ?? []

        while !queue.isEmpty {
            let location = queue.removeFirst()
            result.append(location)
            if let children = location.children {
                queue.append(contentsOf: children)
            }
        }

        return result
    }

    public var itemCount: Int {
        (items?.count ?? 0) + allSublocations.reduce(0) { $0 + ($1.items?.count ?? 0) }
    }
}

public enum LocationType: String, Codable, CaseIterable {
    case home
    case room
    case storage
    case garage
    case office
    case warehouse
    case container
    case shelf
    case drawer
    case closet
    case attic
    case basement
    case shed
    case other

    public var displayName: String {
        switch self {
        case .home: "Home"
        case .room: "Room"
        case .storage: "Storage Unit"
        case .garage: "Garage"
        case .office: "Office"
        case .warehouse: "Warehouse"
        case .container: "Container"
        case .shelf: "Shelf"
        case .drawer: "Drawer"
        case .closet: "Closet"
        case .attic: "Attic"
        case .basement: "Basement"
        case .shed: "Shed"
        case .other: "Other"
        }
    }

    public var iconName: String {
        switch self {
        case .home: "house.fill"
        case .room: "door.left.hand.open"
        case .storage: "shippingbox.fill"
        case .garage: "car.fill"
        case .office: "desktopcomputer"
        case .warehouse: "building.fill"
        case .container: "cube.box.fill"
        case .shelf: "square.stack.3d.up.fill"
        case .drawer: "tray.fill"
        case .closet: "door.sliding.right.hand.closed"
        case .attic: "triangle.fill"
        case .basement: "stairs"
        case .shed: "house.and.flag.fill"
        case .other: "questionmark.folder.fill"
        }
    }
}

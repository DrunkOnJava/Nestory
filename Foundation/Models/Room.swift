//
// Layer: Foundation
// Module: Models
// Purpose: Room model for item location tracking
//

import Foundation
import SwiftData

@Model
public final class Room: @unchecked Sendable {
    // CloudKit compatible: removed .unique constraint
    public var id: UUID

    public var name: String
    public var icon: String
    public var roomDescription: String?
    public var floor: String?

    // Computed property for item count will be handled via queries

    public init(
        name: String,
        icon: String = "door.left.hand.open",
        roomDescription: String? = nil,
        floor: String? = nil
    ) {
        id = UUID()
        self.name = name
        self.icon = icon
        self.roomDescription = roomDescription
        self.floor = floor
    }

    // Default rooms for initial setup
    public static func createDefaultRooms() -> [Room] {
        [
            Room(name: "Living Room", icon: "sofa"),
            Room(name: "Kitchen", icon: "refrigerator"),
            Room(name: "Master Bedroom", icon: "bed.double"),
            Room(name: "Guest Bedroom", icon: "bed.double"),
            Room(name: "Bathroom", icon: "shower"),
            Room(name: "Home Office", icon: "desktopcomputer"),
            Room(name: "Garage", icon: "car"),
            Room(name: "Basement", icon: "stairs"),
            Room(name: "Attic", icon: "house.lodge"),
            Room(name: "Dining Room", icon: "fork.knife"),
            Room(name: "Kids Room", icon: "figure.2.and.child.holdinghands"),
            Room(name: "Storage", icon: "shippingbox"),
        ]
    }
}

// MARK: - TCA Compatibility

extension Room: Equatable {
    public static func == (lhs: Room, rhs: Room) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Codable Conformance for Export Operations
extension Room: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, name, icon, roomDescription, floor
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encodeIfPresent(roomDescription, forKey: .roomDescription)
        try container.encodeIfPresent(floor, forKey: .floor)
    }
    
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let icon = try container.decode(String.self, forKey: .icon)
        let roomDescription = try container.decodeIfPresent(String.self, forKey: .roomDescription)
        let floor = try container.decodeIfPresent(String.self, forKey: .floor)
        
        self.init(name: name, icon: icon, roomDescription: roomDescription, floor: floor)
        
        self.id = try container.decode(UUID.self, forKey: .id)
    }
}

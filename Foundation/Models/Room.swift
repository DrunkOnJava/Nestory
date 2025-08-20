//
// Layer: Foundation
// Module: Models
// Purpose: Room model for item location tracking
//

import Foundation
import SwiftData

@Model
public final class Room: @unchecked Sendable {
    @Attribute(.unique)
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

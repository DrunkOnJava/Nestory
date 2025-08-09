// Layer: Foundation

import Foundation

public protocol Identifier: Hashable, Codable, Sendable {
    var value: UUID { get }
    init(value: UUID)
    init()
}

public extension Identifier {
    init() {
        self.init(value: UUID())
    }
}

public struct ItemID: Identifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

public struct CategoryID: Identifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

public struct LocationID: Identifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

public struct PhotoAssetID: Identifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

public struct ReceiptID: Identifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

public struct WarrantyID: Identifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

public struct MaintenanceTaskID: Identifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

public struct ShareGroupID: Identifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

public struct UserID: Identifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

extension ItemID: CustomStringConvertible {
    public var description: String {
        value.uuidString
    }
}

extension CategoryID: CustomStringConvertible {
    public var description: String {
        value.uuidString
    }
}

extension LocationID: CustomStringConvertible {
    public var description: String {
        value.uuidString
    }
}

extension PhotoAssetID: CustomStringConvertible {
    public var description: String {
        value.uuidString
    }
}

extension ReceiptID: CustomStringConvertible {
    public var description: String {
        value.uuidString
    }
}

extension WarrantyID: CustomStringConvertible {
    public var description: String {
        value.uuidString
    }
}

extension MaintenanceTaskID: CustomStringConvertible {
    public var description: String {
        value.uuidString
    }
}

extension ShareGroupID: CustomStringConvertible {
    public var description: String {
        value.uuidString
    }
}

extension UserID: CustomStringConvertible {
    public var description: String {
        value.uuidString
    }
}

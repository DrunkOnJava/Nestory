// Layer: Foundation
// Module: Foundation/Core
// Purpose: Type-safe identifiers for domain entities

import Foundation

/// Protocol for type-safe identifiers
public protocol Identifier: Codable, Hashable, Sendable {
    associatedtype Value: Codable & Hashable & Sendable
    var value: Value { get }
    init(value: Value)
}

/// Default implementations for Identifier protocol
public extension Identifier {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Value.self)
        self.init(value: value)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

/// Base implementation for UUID-based identifiers
public protocol UUIDIdentifier: Identifier where Value == UUID {
    init()
}

public extension UUIDIdentifier {
    init() {
        self.init(value: UUID())
    }

    init(_ string: String) throws {
        guard let uuid = UUID(uuidString: string) else {
            throw AppError.invalidFormat(field: "ID", expectedFormat: "UUID")
        }
        self.init(value: uuid)
    }

    var uuidString: String {
        value.uuidString
    }
}

// MARK: - Concrete Identifiers

/// Item identifier
public struct ItemID: UUIDIdentifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

/// Category identifier
public struct CategoryID: UUIDIdentifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

/// Location identifier
public struct LocationID: UUIDIdentifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

/// Photo asset identifier
public struct PhotoAssetID: UUIDIdentifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

/// Receipt identifier
public struct ReceiptID: UUIDIdentifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

/// Warranty identifier
public struct WarrantyID: UUIDIdentifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

/// Maintenance task identifier
public struct MaintenanceTaskID: UUIDIdentifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

/// Share group identifier
public struct ShareGroupID: UUIDIdentifier {
    public let value: UUID

    public init(value: UUID) {
        self.value = value
    }
}

/// User identifier
public struct UserID: Identifier {
    public let value: String

    public init(value: String) {
        self.value = value
    }
}

// MARK: - String Interpolation Support

extension ItemID: CustomStringConvertible {
    public var description: String { value.uuidString }
}

extension CategoryID: CustomStringConvertible {
    public var description: String { value.uuidString }
}

extension LocationID: CustomStringConvertible {
    public var description: String { value.uuidString }
}

extension PhotoAssetID: CustomStringConvertible {
    public var description: String { value.uuidString }
}

extension ReceiptID: CustomStringConvertible {
    public var description: String { value.uuidString }
}

extension WarrantyID: CustomStringConvertible {
    public var description: String { value.uuidString }
}

extension MaintenanceTaskID: CustomStringConvertible {
    public var description: String { value.uuidString }
}

extension ShareGroupID: CustomStringConvertible {
    public var description: String { value.uuidString }
}

extension UserID: CustomStringConvertible {
    public var description: String { value }
}

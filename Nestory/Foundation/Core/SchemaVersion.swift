// Layer: Foundation

import Foundation

public enum SchemaVersion: Int, Codable, CaseIterable {
    case v1 = 1
    case v2 = 2

    public static var current: SchemaVersion {
        .v2
    }

    public var next: SchemaVersion? {
        switch self {
        case .v1: .v2
        case .v2: nil
        }
    }

    public var migrationDescription: String {
        switch self {
        case .v1:
            "Initial schema"
        case .v2:
            "Added warranty and maintenance tracking"
        }
    }
}

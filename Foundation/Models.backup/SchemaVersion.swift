// Layer: Foundation
// Module: Foundation/Models
// Purpose: Schema version tracking for migrations

import Foundation

/// Schema version for tracking database migrations
public enum SchemaVersion: Int, CaseIterable, Sendable {
    case v1 = 1  // Initial release: Core models (Item, Category, Location, Photo)
    case v2 = 2  // Added: Receipt scanning, OCR, Warranties, Maintenance
    case v3 = 3  // Added: Sharing, Multi-currency support
    
    /// Current schema version
    public static let current = SchemaVersion.v3
    
    /// Display name for version
    public var displayName: String {
        switch self {
        case .v1: return "1.0 - Initial Release"
        case .v2: return "2.0 - Receipts & Maintenance"
        case .v3: return "3.0 - Sharing & Multi-currency"
        }
    }
    
    /// Release date for version
    public var releaseDate: Date {
        switch self {
        case .v1:
            return Date(timeIntervalSince1970: 1704067200) // Jan 1, 2024
        case .v2:
            return Date(timeIntervalSince1970: 1709251200) // Mar 1, 2024
        case .v3:
            return Date(timeIntervalSince1970: 1714521600) // May 1, 2024
        }
    }
    
    /// Models introduced in this version
    public var introducedModels: [String] {
        switch self {
        case .v1:
            return ["Item", "Category", "Location", "PhotoAsset"]
        case .v2:
            return ["Receipt", "Warranty", "MaintenanceTask"]
        case .v3:
            return ["ShareGroup", "CurrencyRate"]
        }
    }
    
    /// Changes from previous version
    public var migrationNotes: String {
        switch self {
        case .v1:
            return "Initial database schema"
        case .v2:
            return """
            - Added Receipt model for purchase documentation
            - Added Warranty model for coverage tracking
            - Added MaintenanceTask model for scheduled maintenance
            - Enhanced Item with serial/model numbers
            """
        case .v3:
            return """
            - Added ShareGroup model for family sharing
            - Added CurrencyRate model for multi-currency support
            - Enhanced Money value object with better rounding
            - Added custom attributes to Item model
            """
        }
    }
    
    /// Check if migration is needed
    public static func needsMigration(from oldVersion: SchemaVersion, to newVersion: SchemaVersion) -> Bool {
        oldVersion.rawValue < newVersion.rawValue
    }
    
    /// Get migration path from one version to another
    public static func migrationPath(from oldVersion: SchemaVersion, to newVersion: SchemaVersion) -> [SchemaVersion] {
        guard needsMigration(from: oldVersion, to: newVersion) else { return [] }
        
        var path: [SchemaVersion] = []
        var current = oldVersion.rawValue + 1
        
        while current <= newVersion.rawValue {
            if let version = SchemaVersion(rawValue: current) {
                path.append(version)
            }
            current += 1
        }
        
        return path
    }
}

/// Protocol for versioned schema migrations
public protocol SchemaMigrationPlan: Sendable {
    static var fromVersion: SchemaVersion { get }
    static var toVersion: SchemaVersion { get }
    
    init()
    func migrate() async throws
}

/// V1 to V2 migration plan
public struct MigrationV1toV2: SchemaMigrationPlan {
    public static let fromVersion = SchemaVersion.v1
    public static let toVersion = SchemaVersion.v2
    
    public init() {}
    
    public func migrate() async throws {
        // Migration logic would go here
        // This would be implemented when actually performing migrations
    }
}

/// V2 to V3 migration plan
public struct MigrationV2toV3: SchemaMigrationPlan {
    public static let fromVersion = SchemaVersion.v2
    public static let toVersion = SchemaVersion.v3
    
    public init() {}
    
    public func migrate() async throws {
        // Migration logic would go here
        // This would be implemented when actually performing migrations
    }
}

/// Schema migration coordinator
public struct SchemaMigrator: Sendable {
    /// Available migration plans
    private static let migrationPlans: [any SchemaMigrationPlan.Type] = [
        MigrationV1toV2.self,
        MigrationV2toV3.self
    ]
    
    /// Perform migration from one version to another
    public static func migrate(from oldVersion: SchemaVersion, to newVersion: SchemaVersion) async throws {
        let path = SchemaVersion.migrationPath(from: oldVersion, to: newVersion)
        
        for targetVersion in path {
            // Find the appropriate migration plan
            guard let planType = migrationPlans.first(where: { $0.toVersion == targetVersion }) else {
                throw AppError.migrationFailed(
                    from: oldVersion.displayName,
                    to: targetVersion.displayName
                )
            }
            
            // Execute the migration
            let plan = planType.init()
            try await plan.migrate()
        }
    }
}

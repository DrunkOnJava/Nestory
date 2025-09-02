//
// Layer: Foundation
// Module: Models
// Purpose: Export and backup data structures
//

import Foundation

/// Data structure for exported inventory information
public struct ExportData: Equatable, Sendable, Codable, Identifiable {
    public let id: UUID
    public let items: [Item]
    public let categories: [Category]
    public let rooms: [Room]
    public let metadata: BackupMetadata
    public let exportFormat: ExportFormat
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        items: [Item],
        categories: [Category],
        rooms: [Room],
        metadata: BackupMetadata,
        exportFormat: ExportFormat
    ) {
        self.id = id
        self.items = items
        self.categories = categories
        self.rooms = rooms
        self.metadata = metadata
        self.exportFormat = exportFormat
        self.createdAt = Date()
    }
    
    /// Total value of all items in the export
    public var totalValue: Decimal {
        items.compactMap(\.purchasePrice).reduce(0, +)
    }
    
    /// Number of items in the export
    public var itemCount: Int {
        items.count
    }
}

/// Package containing backup data and associated metadata
public struct BackupPackage: Equatable, Sendable, Codable, Identifiable {
    public let id: UUID
    public let data: ExportData
    public let encryptionKey: String?
    public let compressionLevel: CompressionLevel
    public let packageVersion: String
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        data: ExportData,
        encryptionKey: String? = nil,
        compressionLevel: CompressionLevel = .standard,
        packageVersion: String = "1.0"
    ) {
        self.id = id
        self.data = data
        self.encryptionKey = encryptionKey
        self.compressionLevel = compressionLevel
        self.packageVersion = packageVersion
        self.createdAt = Date()
    }
    
    /// Whether the backup package is encrypted
    public var isEncrypted: Bool {
        encryptionKey != nil
    }
}

/// Compression level for backup packages
public enum CompressionLevel: String, CaseIterable, Equatable, Sendable, Codable {
    case none = "none"
    case low = "low"
    case standard = "standard"
    case high = "high"
    case maximum = "maximum"
    
    public var displayName: String {
        switch self {
        case .none:
            "No Compression"
        case .low:
            "Low Compression"
        case .standard:
            "Standard Compression"
        case .high:
            "High Compression"
        case .maximum:
            "Maximum Compression"
        }
    }
    
    /// Approximate compression ratio (for UI display)
    public var compressionRatio: Double {
        switch self {
        case .none: 1.0
        case .low: 0.9
        case .standard: 0.7
        case .high: 0.5
        case .maximum: 0.3
        }
    }
}
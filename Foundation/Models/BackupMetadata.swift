//
// Layer: Foundation
// Module: Models
// Purpose: Backup metadata for export and cloud backup operations
//

import Foundation

public struct BackupMetadata: Equatable, Sendable, Codable, Identifiable {
    public let id: UUID
    
    // Export metadata fields
    public let version: String
    public let exportDate: Date
    public let appVersion: String
    
    // Cloud backup metadata fields
    public let deviceName: String
    
    // Common fields
    public let itemCount: Int
    public let totalValue: Decimal
    
    public init(
        id: UUID = UUID(),
        version: String = "1.0",
        exportDate: Date = Date(),
        appVersion: String = "1.0.0",
        deviceName: String = "Unknown",
        itemCount: Int,
        totalValue: Decimal = 0
    ) {
        self.id = id
        self.version = version
        self.exportDate = exportDate
        self.appVersion = appVersion
        self.deviceName = deviceName
        self.itemCount = itemCount
        self.totalValue = totalValue
    }
    
    // Convenience initializers for specific use cases
    public static func forExport(
        itemCount: Int, 
        totalValue: Decimal, 
        appVersion: String = "1.0.0",
        deviceName: String = "Unknown Device"
    ) -> BackupMetadata {
        return BackupMetadata(
            version: "1.0",
            exportDate: Date(),
            appVersion: appVersion,
            deviceName: deviceName,
            itemCount: itemCount,
            totalValue: totalValue
        )
    }
    
    public init(forCloudBackup: Date, itemCount: Int, deviceName: String) {
        self.init(
            version: "1.0",
            exportDate: forCloudBackup,
            appVersion: "1.0.0",
            deviceName: deviceName,
            itemCount: itemCount,
            totalValue: 0
        )
    }
}
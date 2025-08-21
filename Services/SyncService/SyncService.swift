//
// Layer: Services
// Module: SyncService
// Purpose: Cloud synchronization for cross-device inventory management
//

import Foundation

// MARK: - SyncService Protocol

/// Cloud synchronization service for inventory data
public protocol SyncService: Sendable {
    /// Current sync status
    var syncStatus: SyncStatus { get async }
    
    /// Last successful sync date
    var lastSyncDate: Date? { get async }
    
    /// Start manual sync operation
    func startSync() async throws -> SyncResult
    
    /// Enable automatic sync
    func enableAutoSync(interval: TimeInterval) async throws
    
    /// Disable automatic sync
    func disableAutoSync() async
    
    /// Sync specific data type
    func syncDataType(_ dataType: SyncDataType) async throws -> SyncResult
    
    /// Resolve sync conflicts
    func resolveConflicts(_ conflicts: [SyncConflict], resolution: ConflictResolution) async throws
    
    /// Get pending sync operations
    func getPendingSyncOperations() async -> [SyncOperation]
    
    /// Cancel pending sync operations
    func cancelSync() async
    
    /// Reset sync state (force full sync on next operation)
    func resetSyncState() async throws
    
    /// Get sync statistics
    func getSyncStatistics() async -> SyncStatistics
}

// MARK: - Supporting Types

/// Current synchronization status
public enum SyncStatus: String, Sendable, Equatable {
    case idle = "idle"
    case syncing = "syncing"
    case paused = "paused"
    case error = "error"
    case conflictResolutionRequired = "conflict_resolution_required"
    
    public var displayName: String {
        switch self {
        case .idle: return "Up to date"
        case .syncing: return "Syncing..."
        case .paused: return "Sync paused"
        case .error: return "Sync error"
        case .conflictResolutionRequired: return "Conflicts need resolution"
        }
    }
    
    public var isActive: Bool {
        return self == .syncing
    }
}

/// Result of sync operation
public struct SyncResult: Sendable {
    public let success: Bool
    public let syncedItems: Int
    public let conflicts: [SyncConflict]
    public let errors: [SyncError]
    public let duration: TimeInterval
    public let syncDate: Date
    
    public init(
        success: Bool,
        syncedItems: Int,
        conflicts: [SyncConflict] = [],
        errors: [SyncError] = [],
        duration: TimeInterval,
        syncDate: Date = Date()
    ) {
        self.success = success
        self.syncedItems = syncedItems
        self.conflicts = conflicts
        self.errors = errors
        self.duration = duration
        self.syncDate = syncDate
    }
}

/// Types of data that can be synced
public enum SyncDataType: String, Sendable, CaseIterable {
    case items = "items"
    case categories = "categories"
    case warranties = "warranties"
    case receipts = "receipts"
    case settings = "settings"
    case all = "all"
    
    public var displayName: String {
        switch self {
        case .items: return "Items"
        case .categories: return "Categories"
        case .warranties: return "Warranties"
        case .receipts: return "Receipts"
        case .settings: return "Settings"
        case .all: return "All Data"
        }
    }
}

/// Sync conflict between local and remote data
public struct SyncConflict: Sendable, Identifiable {
    public let id: String
    public let dataType: SyncDataType
    public let localRecord: SyncRecord
    public let remoteRecord: SyncRecord
    public let conflictType: ConflictType
    
    public init(id: String, dataType: SyncDataType, localRecord: SyncRecord, remoteRecord: SyncRecord, conflictType: ConflictType) {
        self.id = id
        self.dataType = dataType
        self.localRecord = localRecord
        self.remoteRecord = remoteRecord
        self.conflictType = conflictType
    }
    
    public enum ConflictType: String, Sendable {
        case modification = "modification"
        case deletion = "deletion"
        case creation = "creation"
        
        public var displayName: String {
            switch self {
            case .modification: return "Modified in both places"
            case .deletion: return "Deleted on one device"
            case .creation: return "Created on both devices"
            }
        }
    }
}

/// Strategy for resolving conflicts
public enum ConflictResolution: String, Sendable {
    case useLocal = "use_local"
    case useRemote = "use_remote"
    case merge = "merge"
    case skipConflict = "skip"
    
    public var displayName: String {
        switch self {
        case .useLocal: return "Use Local Version"
        case .useRemote: return "Use Cloud Version"
        case .merge: return "Merge Changes"
        case .skipConflict: return "Skip This Item"
        }
    }
}

/// Individual sync operation
public struct SyncOperation: Sendable, Identifiable {
    public let id: String
    public let dataType: SyncDataType
    public let operation: OperationType
    public let recordId: String
    public let status: OperationStatus
    public let createdAt: Date
    
    public init(id: String, dataType: SyncDataType, operation: OperationType, recordId: String, status: OperationStatus, createdAt: Date = Date()) {
        self.id = id
        self.dataType = dataType
        self.operation = operation
        self.recordId = recordId
        self.status = status
        self.createdAt = createdAt
    }
    
    public enum OperationType: String, Sendable {
        case create = "create"
        case update = "update"
        case delete = "delete"
    }
    
    public enum OperationStatus: String, Sendable {
        case pending = "pending"
        case inProgress = "in_progress"
        case completed = "completed"
        case failed = "failed"
    }
}

/// Sync record with metadata
public struct SyncRecord: Sendable {
    public let id: String
    public let data: [String: Sendable]
    public let lastModified: Date
    public let version: Int
    public let checksum: String
    
    public init(id: String, data: [String: Sendable], lastModified: Date, version: Int, checksum: String) {
        self.id = id
        self.data = data
        self.lastModified = lastModified
        self.version = version
        self.checksum = checksum
    }
}

/// Sync statistics and metrics
public struct SyncStatistics: Sendable {
    public let totalSyncs: Int
    public let successfulSyncs: Int
    public let failedSyncs: Int
    public let averageSyncDuration: TimeInterval
    public let lastSuccessfulSync: Date?
    public let lastFailedSync: Date?
    public let totalDataSynced: Int // in bytes
    public let conflictsResolved: Int
    
    public init(
        totalSyncs: Int,
        successfulSyncs: Int,
        failedSyncs: Int,
        averageSyncDuration: TimeInterval,
        lastSuccessfulSync: Date?,
        lastFailedSync: Date?,
        totalDataSynced: Int,
        conflictsResolved: Int
    ) {
        self.totalSyncs = totalSyncs
        self.successfulSyncs = successfulSyncs
        self.failedSyncs = failedSyncs
        self.averageSyncDuration = averageSyncDuration
        self.lastSuccessfulSync = lastSuccessfulSync
        self.lastFailedSync = lastFailedSync
        self.totalDataSynced = totalDataSynced
        self.conflictsResolved = conflictsResolved
    }
    
    public var successRate: Double {
        guard totalSyncs > 0 else { return 0 }
        return Double(successfulSyncs) / Double(totalSyncs)
    }
}

// MARK: - Error Types

public enum SyncError: LocalizedError, Sendable {
    case networkUnavailable
    case authenticationRequired
    case serverError(String)
    case conflictResolutionRequired
    case dataCorruption(String)
    case quotaExceeded
    case syncInProgress
    case invalidSyncState
    case deviceStorageFull
    case unsupportedDataType(SyncDataType)
    
    public var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network connection required for sync"
        case .authenticationRequired:
            return "Please sign in to sync your data"
        case .serverError(let message):
            return "Server error: \(message)"
        case .conflictResolutionRequired:
            return "Some items have conflicts that need to be resolved"
        case .dataCorruption(let details):
            return "Data corruption detected: \(details)"
        case .quotaExceeded:
            return "Cloud storage quota exceeded"
        case .syncInProgress:
            return "Sync operation already in progress"
        case .invalidSyncState:
            return "Invalid sync state - please reset sync"
        case .deviceStorageFull:
            return "Device storage full - cannot sync"
        case .unsupportedDataType(let type):
            return "Data type '\(type.displayName)' is not supported for sync"
        }
    }
}

// MARK: - Live Implementation Placeholder

/// Live implementation of SyncService
public struct LiveSyncService: SyncService {
    
    public init() {}
    
    public var syncStatus: SyncStatus {
        get async {
            // TODO: Return actual sync status
            return .idle
        }
    }
    
    public var lastSyncDate: Date? {
        get async {
            // TODO: Return actual last sync date
            return nil
        }
    }
    
    public func startSync() async throws -> SyncResult {
        // TODO: Implement actual sync
        throw SyncError.serverError("Not yet implemented")
    }
    
    public func enableAutoSync(interval: TimeInterval) async throws {
        // TODO: Implement auto sync
        throw SyncError.serverError("Not yet implemented")
    }
    
    public func disableAutoSync() async {
        // TODO: Implement disable auto sync
    }
    
    public func syncDataType(_ dataType: SyncDataType) async throws -> SyncResult {
        // TODO: Implement data type specific sync
        throw SyncError.serverError("Not yet implemented")
    }
    
    public func resolveConflicts(_ conflicts: [SyncConflict], resolution: ConflictResolution) async throws {
        // TODO: Implement conflict resolution
        throw SyncError.serverError("Not yet implemented")
    }
    
    public func getPendingSyncOperations() async -> [SyncOperation] {
        // TODO: Return actual pending operations
        return []
    }
    
    public func cancelSync() async {
        // TODO: Implement sync cancellation
    }
    
    public func resetSyncState() async throws {
        // TODO: Implement sync state reset
        throw SyncError.serverError("Not yet implemented")
    }
    
    public func getSyncStatistics() async -> SyncStatistics {
        // TODO: Return actual sync statistics
        return SyncStatistics(
            totalSyncs: 0,
            successfulSyncs: 0,
            failedSyncs: 0,
            averageSyncDuration: 0,
            lastSuccessfulSync: nil,
            lastFailedSync: nil,
            totalDataSynced: 0,
            conflictsResolved: 0
        )
    }
}
//
// Layer: Services
// Module: CloudBackup
// Purpose: Intelligent CloudKit conflict resolution for multi-device sync scenarios
//

import CloudKit
import Foundation
import SwiftData
import os.log

/// Strategies for resolving CloudKit record conflicts
public enum ConflictResolutionStrategy {
    case serverWins           // Always use server version
    case clientWins          // Always use client version  
    case mostRecentWins      // Use record with latest modification date
    case intelligentMerge    // Merge compatible fields (recommended)
    case userChoice          // Present choice to user (future enhancement)
}

/// Result of conflict resolution operation
public enum ConflictResolutionResult {
    case resolved(record: CKRecord, strategy: ConflictResolutionStrategy)
    case failed(reason: String)
    case requiresUserInput(serverRecord: CKRecord, clientRecord: CKRecord)
}

/// Comprehensive CloudKit conflict resolution system
@MainActor
public final class CloudKitConflictResolver: Sendable {
    
    // Using Logger.service for consistent logging across the app
    
    // Default strategy for different record types
    private let defaultStrategies: [String: ConflictResolutionStrategy] = [
        "BackupItem": .intelligentMerge,
        "BackupCategory": .mostRecentWins,
        "BackupRoom": .mostRecentWins,
        "BackupMetadata": .serverWins
    ]
    
    public init() {}
    
    /// Resolves a CloudKit record conflict using intelligent strategies
    public func resolveConflict(
        serverRecord: CKRecord,
        clientRecord: CKRecord,
        preferredStrategy: ConflictResolutionStrategy? = nil
    ) -> ConflictResolutionResult {
        let recordType = serverRecord.recordType
        let strategy = preferredStrategy ?? defaultStrategies[recordType] ?? .intelligentMerge
        
        Logger.service.info("Resolving CloudKit conflict for \(recordType) using \(String(describing: strategy))")
        
        switch strategy {
        case .serverWins:
            return .resolved(record: serverRecord, strategy: .serverWins)
            
        case .clientWins:
            return .resolved(record: clientRecord, strategy: .clientWins)
            
        case .mostRecentWins:
            return resolveMostRecentWins(serverRecord: serverRecord, clientRecord: clientRecord)
            
        case .intelligentMerge:
            return resolveIntelligentMerge(serverRecord: serverRecord, clientRecord: clientRecord)
            
        case .userChoice:
            return .requiresUserInput(serverRecord: serverRecord, clientRecord: clientRecord)
        }
    }
    
    /// Resolves conflict by choosing the record with the most recent modification date
    private func resolveMostRecentWins(
        serverRecord: CKRecord,
        clientRecord: CKRecord
    ) -> ConflictResolutionResult {
        let serverDate = serverRecord.modificationDate ?? Date.distantPast
        let clientDate = clientRecord.modificationDate ?? Date.distantPast
        
        if serverDate > clientDate {
            Logger.service.debug("Server record is more recent (\(serverDate) > \(clientDate))")
            return .resolved(record: serverRecord, strategy: .mostRecentWins)
        } else {
            Logger.service.debug("Client record is more recent (\(clientDate) > \(serverDate))")
            return .resolved(record: clientRecord, strategy: .mostRecentWins)
        }
    }
    
    /// Intelligently merges compatible fields from both records
    private func resolveIntelligentMerge(
        serverRecord: CKRecord,
        clientRecord: CKRecord
    ) -> ConflictResolutionResult {
        let recordType = serverRecord.recordType
        
        // Start with the server record as base (maintains CloudKit integrity)
        let mergedRecord = serverRecord.copy(with: nil) as! CKRecord
        
        switch recordType {
        case "BackupItem":
            return mergeItemRecords(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord)
            
        case "BackupCategory":
            return mergeCategoryRecords(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord)
            
        case "BackupRoom":
            return mergeRoomRecords(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord)
            
        default:
            Logger.service.warning("No specific merge strategy for \(recordType), falling back to mostRecentWins")
            return resolveMostRecentWins(serverRecord: serverRecord, clientRecord: clientRecord)
        }
    }
    
    /// Merges item records with intelligent field-by-field resolution
    private func mergeItemRecords(
        mergedRecord: CKRecord,
        serverRecord: CKRecord,
        clientRecord: CKRecord
    ) -> ConflictResolutionResult {
        // Core fields - use most recent non-nil values
        mergeStringField(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord, key: "name")
        mergeStringField(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord, key: "itemDescription")
        mergeStringField(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord, key: "brand")
        mergeStringField(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord, key: "model")
        mergeStringField(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord, key: "serialNumber")
        
        // Numeric fields - use higher values (assumes additions, not replacements)
        mergeNumericField(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord, key: "estimatedValue", preferHigher: true)
        mergeNumericField(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord, key: "quantity", preferHigher: true)
        
        // Dates - use most recent for purchase date, earliest for creation date
        mergeDateField(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord, key: "purchaseDate", preferMostRecent: true)
        mergeDateField(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord, key: "dateAdded", preferMostRecent: false)
        
        // Assets - prefer client record (local changes)
        if let clientPhotos = clientRecord["photos"] as? [CKAsset], !clientPhotos.isEmpty {
            mergedRecord["photos"] = clientPhotos
            Logger.service.debug("Using client photos (local changes preferred)")
        }
        
        // Boolean fields - prefer true values (additions over removals)
        mergeBooleanField(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord, key: "isFavorite", preferTrue: true)
        
        Logger.service.info("Successfully merged item record with intelligent field resolution")
        return .resolved(record: mergedRecord, strategy: .intelligentMerge)
    }
    
    /// Merges category records
    private func mergeCategoryRecords(
        mergedRecord: CKRecord,
        serverRecord: CKRecord,
        clientRecord: CKRecord
    ) -> ConflictResolutionResult {
        // Categories are simpler - mostly use most recent
        mergeStringField(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord, key: "name")
        mergeStringField(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord, key: "color")
        mergeStringField(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord, key: "iconName")
        
        Logger.service.info("Successfully merged category record")
        return .resolved(record: mergedRecord, strategy: .intelligentMerge)
    }
    
    /// Merges room records
    private func mergeRoomRecords(
        mergedRecord: CKRecord,
        serverRecord: CKRecord,
        clientRecord: CKRecord
    ) -> ConflictResolutionResult {
        // Rooms are also simple
        mergeStringField(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord, key: "name")
        mergeStringField(mergedRecord: mergedRecord, serverRecord: serverRecord, clientRecord: clientRecord, key: "roomDescription")
        
        Logger.service.info("Successfully merged room record")
        return .resolved(record: mergedRecord, strategy: .intelligentMerge)
    }
    
    // MARK: - Field-Specific Merge Helpers
    
    private func mergeStringField(
        mergedRecord: CKRecord,
        serverRecord: CKRecord,
        clientRecord: CKRecord,
        key: String
    ) {
        let serverValue = serverRecord[key] as? String
        let clientValue = clientRecord[key] as? String
        
        // Use non-empty values, prefer client for equivalent cases
        if let client = clientValue, !client.isEmpty {
            mergedRecord[key] = client
        } else if let server = serverValue, !server.isEmpty {
            mergedRecord[key] = server
        }
    }
    
    private func mergeNumericField(
        mergedRecord: CKRecord,
        serverRecord: CKRecord,
        clientRecord: CKRecord,
        key: String,
        preferHigher: Bool
    ) {
        let serverValue = serverRecord[key] as? Double ?? 0.0
        let clientValue = clientRecord[key] as? Double ?? 0.0
        
        if preferHigher {
            mergedRecord[key] = max(serverValue, clientValue)
        } else {
            mergedRecord[key] = min(serverValue, clientValue)
        }
    }
    
    private func mergeDateField(
        mergedRecord: CKRecord,
        serverRecord: CKRecord,
        clientRecord: CKRecord,
        key: String,
        preferMostRecent: Bool
    ) {
        let serverValue = serverRecord[key] as? Date
        let clientValue = clientRecord[key] as? Date
        
        switch (serverValue, clientValue) {
        case let (server?, client?):
            if preferMostRecent {
                mergedRecord[key] = server > client ? server : client
            } else {
                mergedRecord[key] = server < client ? server : client
            }
        case let (server?, nil):
            mergedRecord[key] = server
        case let (nil, client?):
            mergedRecord[key] = client
        case (nil, nil):
            break // Leave unchanged
        }
    }
    
    private func mergeBooleanField(
        mergedRecord: CKRecord,
        serverRecord: CKRecord,
        clientRecord: CKRecord,
        key: String,
        preferTrue: Bool
    ) {
        let serverValue = serverRecord[key] as? Bool ?? false
        let clientValue = clientRecord[key] as? Bool ?? false
        
        if preferTrue {
            mergedRecord[key] = serverValue || clientValue
        } else {
            mergedRecord[key] = serverValue && clientValue
        }
    }
}

// MARK: - Supporting Extensions

extension CKRecord {
    /// Creates a deep copy of the record for conflict resolution
    func copy() -> CKRecord {
        let copy = CKRecord(recordType: self.recordType, recordID: self.recordID)
        for key in self.allKeys() {
            copy[key] = self[key]
        }
        return copy
    }
}
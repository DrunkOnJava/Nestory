//
// Layer: Services
// Module: CloudBackupService/CloudKitConflictResolver
// Purpose: Resolves CloudKit sync conflicts using intelligent merging strategies
//

import Foundation
import CloudKit

public protocol CloudKitConflictResolver: Sendable {
    func resolveConflict<T: CKRecord>(_ conflict: CKRecordConflict<T>) async throws -> T
    func resolveConflicts<T: CKRecord>(_ conflicts: [CKRecordConflict<T>]) async throws -> [T]
}

public final class LiveCloudKitConflictResolver: CloudKitConflictResolver {
    
    public init() {}
    
    public func resolveConflict<T: CKRecord>(_ conflict: CKRecordConflict<T>) async throws -> T {
        let clientRecord = conflict.clientRecord
        let serverRecord = conflict.serverRecord
        
        // Use the most recently modified record as the base
        let baseRecord: T
        let otherRecord: T
        
        if let clientModified = clientRecord.modificationDate,
           let serverModified = serverRecord.modificationDate {
            if clientModified > serverModified {
                baseRecord = clientRecord
                otherRecord = serverRecord
            } else {
                baseRecord = serverRecord
                otherRecord = clientRecord
            }
        } else {
            // If modification dates are unavailable, prefer server record
            baseRecord = serverRecord
            otherRecord = clientRecord
        }
        
        // Apply intelligent merging based on record type
        let resolvedRecord = try mergeRecords(base: baseRecord, other: otherRecord)
        
        return resolvedRecord
    }
    
    public func resolveConflicts<T: CKRecord>(_ conflicts: [CKRecordConflict<T>]) async throws -> [T] {
        var resolvedRecords: [T] = []
        
        for conflict in conflicts {
            let resolved = try await resolveConflict(conflict)
            resolvedRecords.append(resolved)
        }
        
        return resolvedRecords
    }
    
    private func mergeRecords<T: CKRecord>(base: T, other: T) throws -> T {
        let merged = base.copy() as! T
        
        // Merge strategy based on field types and importance
        for key in other.allKeys() {
            guard let otherValue = other[key] else { continue }
            guard let baseValue = base[key] else {
                // Field exists in other but not in base - add it
                merged[key] = otherValue
                continue
            }
            
            // Apply field-specific merging logic
            let mergedValue = try mergeFieldValues(
                key: key,
                baseValue: baseValue,
                otherValue: otherValue,
                baseModified: base.modificationDate ?? Date.distantPast,
                otherModified: other.modificationDate ?? Date.distantPast
            )
            
            merged[key] = mergedValue as? CKRecordValue
        }
        
        return merged
    }
    
    private func mergeFieldValues(
        key: String,
        baseValue: Any,
        otherValue: Any,
        baseModified: Date,
        otherModified: Date
    ) throws -> Any {
        
        switch key {
        case "name", "title":
            // For names/titles, prefer non-empty values, then most recent
            return mergeStringFields(base: baseValue, other: otherValue, baseNewer: baseModified > otherModified)
            
        case "estimatedValue", "price", "value":
            // For values, prefer higher amounts (assuming inflation/appreciation)
            return mergeNumericFields(base: baseValue, other: otherValue, preferHigher: true)
            
        case "photos", "images":
            // For arrays, merge and deduplicate
            return try mergeArrayFields(base: baseValue, other: otherValue)
            
        case "notes", "description":
            // For text fields, prefer longer, more detailed content
            return mergeLongTextFields(base: baseValue, other: otherValue)
            
        case "purchaseDate":
            // For dates, prefer earlier dates (more accurate purchase info)
            return mergeDateFields(base: baseValue, other: otherValue, preferEarlier: true)
            
        case "createdAt":
            // Creation dates should not conflict, but prefer earlier if they do
            return mergeDateFields(base: baseValue, other: otherValue, preferEarlier: true)
            
        case "modifiedAt", "updatedAt":
            // Modification dates - prefer the later one
            return mergeDateFields(base: baseValue, other: otherValue, preferEarlier: false)
            
        default:
            // For other fields, prefer the most recently modified record's value
            return baseModified > otherModified ? baseValue : otherValue
        }
    }
    
    private func mergeStringFields(base: Any, other: Any, baseNewer: Bool) -> Any {
        guard let baseString = base as? String,
              let otherString = other as? String else {
            return baseNewer ? base : other
        }
        
        // Prefer non-empty strings
        if baseString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return otherString
        }
        if otherString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return baseString
        }
        
        // If both are non-empty, prefer the newer one
        return baseNewer ? baseString : otherString
    }
    
    private func mergeNumericFields(base: Any, other: Any, preferHigher: Bool) -> Any {
        guard let baseNumber = base as? NSNumber,
              let otherNumber = other as? NSNumber else {
            return base // Keep original if types don't match
        }
        
        let baseDouble = baseNumber.doubleValue
        let otherDouble = otherNumber.doubleValue
        
        // Handle zero values - prefer non-zero
        if baseDouble == 0 && otherDouble != 0 {
            return otherNumber
        }
        if otherDouble == 0 && baseDouble != 0 {
            return baseNumber
        }
        
        // Apply preference (higher or lower)
        if preferHigher {
            return baseDouble > otherDouble ? baseNumber : otherNumber
        } else {
            return baseDouble < otherDouble ? baseNumber : otherNumber
        }
    }
    
    private func mergeArrayFields(base: Any, other: Any) throws -> Any {
        guard let baseArray = base as? [Any],
              let otherArray = other as? [Any] else {
            throw ConflictResolutionError.incompatibleTypes
        }
        
        // Merge arrays and remove duplicates based on string representation
        var merged = baseArray
        let baseStringSet = Set(baseArray.map { String(describing: $0) })
        
        for item in otherArray {
            let itemString = String(describing: item)
            if !baseStringSet.contains(itemString) {
                merged.append(item)
            }
        }
        
        return merged
    }
    
    private func mergeLongTextFields(base: Any, other: Any) -> Any {
        guard let baseString = base as? String,
              let otherString = other as? String else {
            return base
        }
        
        // Prefer longer, more detailed content
        let baseLength = baseString.trimmingCharacters(in: .whitespacesAndNewlines).count
        let otherLength = otherString.trimmingCharacters(in: .whitespacesAndNewlines).count
        
        if baseLength == 0 {
            return otherString
        }
        if otherLength == 0 {
            return baseString
        }
        
        return baseLength >= otherLength ? baseString : otherString
    }
    
    private func mergeDateFields(base: Any, other: Any, preferEarlier: Bool) -> Any {
        guard let baseDate = base as? Date,
              let otherDate = other as? Date else {
            return base
        }
        
        if preferEarlier {
            return baseDate < otherDate ? baseDate : otherDate
        } else {
            return baseDate > otherDate ? baseDate : otherDate
        }
    }
}

public final class MockCloudKitConflictResolver: CloudKitConflictResolver {
    
    public init() {}
    
    public func resolveConflict<T: CKRecord>(_ conflict: CKRecordConflict<T>) async throws -> T {
        // Mock resolver always returns the client record
        return conflict.clientRecord
    }
    
    public func resolveConflicts<T: CKRecord>(_ conflicts: [CKRecordConflict<T>]) async throws -> [T] {
        return conflicts.map { $0.clientRecord }
    }
}

// MARK: - Conflict Resolution Strategies

public enum ConflictResolutionStrategy: Sendable {
    case preferClient
    case preferServer
    case preferMostRecent
    case intelligentMerge
    case manualReview
}

public struct ConflictResolutionPolicy: Sendable {
    public let defaultStrategy: ConflictResolutionStrategy
    public let fieldSpecificStrategies: [String: ConflictResolutionStrategy]
    public let requireManualReviewForFields: Set<String>
    
    public init(
        defaultStrategy: ConflictResolutionStrategy = .intelligentMerge,
        fieldSpecificStrategies: [String: ConflictResolutionStrategy] = [:],
        requireManualReviewForFields: Set<String> = []
    ) {
        self.defaultStrategy = defaultStrategy
        self.fieldSpecificStrategies = fieldSpecificStrategies
        self.requireManualReviewForFields = requireManualReviewForFields
    }
    
    public static let `default` = ConflictResolutionPolicy(
        defaultStrategy: .intelligentMerge,
        fieldSpecificStrategies: [
            "estimatedValue": .preferServer, // Server might have updated market values
            "photos": .intelligentMerge,     // Merge photo arrays
            "name": .preferClient,           // User probably knows the name better
            "notes": .intelligentMerge       // Merge detailed notes
        ]
    )
}

// MARK: - Conflict Types and Models

public struct CKRecordConflict<T: CKRecord> {
    public let clientRecord: T
    public let serverRecord: T
    public let conflictedKeys: [String]
    
    public init(clientRecord: T, serverRecord: T, conflictedKeys: [String]) {
        self.clientRecord = clientRecord
        self.serverRecord = serverRecord
        self.conflictedKeys = conflictedKeys
    }
}

public struct ConflictResolutionResult<T: CKRecord> {
    public let resolvedRecord: T
    public let strategy: ConflictResolutionStrategy
    public let conflictsResolved: Int
    public let requiresManualReview: Bool
    
    public init(
        resolvedRecord: T,
        strategy: ConflictResolutionStrategy,
        conflictsResolved: Int,
        requiresManualReview: Bool = false
    ) {
        self.resolvedRecord = resolvedRecord
        self.strategy = strategy
        self.conflictsResolved = conflictsResolved
        self.requiresManualReview = requiresManualReview
    }
}

// MARK: - Errors

public enum ConflictResolutionError: Error, LocalizedError {
    case incompatibleTypes
    case unsupportedFieldType(String)
    case resolutionFailed(String)
    case manualReviewRequired
    
    public var errorDescription: String? {
        switch self {
        case .incompatibleTypes:
            return "Cannot merge incompatible data types"
        case .unsupportedFieldType(let field):
            return "Unsupported field type for conflict resolution: \(field)"
        case .resolutionFailed(let reason):
            return "Conflict resolution failed: \(reason)"
        case .manualReviewRequired:
            return "This conflict requires manual review"
        }
    }
}

// MARK: - Conflict Detection Utilities

public extension CKRecord {
    
    func findConflicts(with other: CKRecord) -> [String] {
        guard recordID == other.recordID else {
            return [] // Different records, not a conflict
        }
        
        var conflictedKeys: [String] = []
        let allKeys = Set(self.allKeys()).union(Set(other.allKeys()))
        
        for key in allKeys {
            let selfValue = self[key]
            let otherValue = other[key]
            
            // Skip system fields that are expected to differ
            if key.hasPrefix("__") { continue }
            
            if !valuesAreEqual(selfValue, otherValue) {
                conflictedKeys.append(key)
            }
        }
        
        return conflictedKeys
    }
    
    private func valuesAreEqual(_ value1: Any?, _ value2: Any?) -> Bool {
        switch (value1, value2) {
        case (nil, nil):
            return true
        case (nil, _), (_, nil):
            return false
        case let (str1 as String, str2 as String):
            return str1 == str2
        case let (num1 as NSNumber, num2 as NSNumber):
            return num1 == num2
        case let (date1 as Date, date2 as Date):
            return date1 == date2
        case let (arr1 as [Any], arr2 as [Any]):
            return arr1.count == arr2.count // Simplified comparison
        default:
            return String(describing: value1) == String(describing: value2)
        }
    }
}
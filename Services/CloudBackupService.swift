//
// Layer: Services
// Module: CloudBackup
// Purpose: CloudKit backup for disaster recovery
//
// REMINDER: This service MUST be wired up in SettingsView for user access

import CloudKit
import Foundation
import SwiftData
import UIKit

@MainActor
public final class CloudBackupService: ObservableObject {
    @Published public var isBackingUp = false
    @Published public var isRestoring = false
    @Published public var lastBackupDate: Date?
    @Published public var backupStatus: BackupStatus = .idle
    @Published public var errorMessage: String?
    @Published public var progress: Double = 0.0

    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let backupZone = CKRecordZone(zoneName: "NestoryBackup")

    public init() {
        container = CKContainer.default()
        privateDatabase = container.privateCloudDatabase
    }

    // MARK: - Account Status

    public func checkCloudKitAvailability() async -> Bool {
        do {
            let status = try await container.accountStatus()
            switch status {
            case .available:
                return true
            case .noAccount:
                errorMessage = "No iCloud account. Please sign in to iCloud in Settings."
                return false
            case .restricted:
                errorMessage = "iCloud is restricted on this device."
                return false
            case .couldNotDetermine:
                errorMessage = "Could not determine iCloud status."
                return false
            case .temporarilyUnavailable:
                errorMessage = "iCloud is temporarily unavailable."
                return false
            @unknown default:
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Backup Operations

    public func performBackup(items: [Item], categories: [Category], rooms: [Room]) async throws {
        guard await checkCloudKitAvailability() else {
            throw BackupError.iCloudUnavailable
        }

        isBackingUp = true
        backupStatus = .backing(.preparing)
        progress = 0.0

        defer {
            isBackingUp = false
            if backupStatus != .failed {
                backupStatus = .idle
            }
        }

        // Create backup zone if needed
        try await createBackupZone()

        // Clear previous backup
        backupStatus = .backing(.clearing)
        progress = 0.1
        await clearPreviousBackup()

        // Backup categories
        backupStatus = .backing(.categories)
        progress = 0.2
        try await backupCategories(categories)

        // Backup rooms
        backupStatus = .backing(.rooms)
        progress = 0.3
        try await backupRooms(rooms)

        // Backup items with progress
        backupStatus = .backing(.items)
        let totalItems = items.count
        for (index, item) in items.enumerated() {
            try await backupItem(item)
            progress = 0.3 + (0.6 * Double(index + 1) / Double(totalItems))
        }

        // Save backup metadata
        backupStatus = .backing(.metadata)
        progress = 0.9
        try await saveBackupMetadata(itemCount: items.count)

        lastBackupDate = Date()
        backupStatus = .completed
        progress = 1.0
    }

    // MARK: - Restore Operations

    public func performRestore(modelContext: ModelContext) async throws -> RestoreResult {
        guard await checkCloudKitAvailability() else {
            throw BackupError.iCloudUnavailable
        }

        isRestoring = true
        backupStatus = .restoring(.preparing)
        progress = 0.0

        defer {
            isRestoring = false
            if backupStatus != .failed {
                backupStatus = .idle
            }
        }

        // Check for existing backup
        guard let metadata = try await fetchBackupMetadata() else {
            throw BackupError.noBackupFound
        }

        // Restore categories
        backupStatus = .restoring(.categories)
        progress = 0.2
        let categories = try await restoreCategories(modelContext: modelContext)

        // Restore rooms
        backupStatus = .restoring(.rooms)
        progress = 0.3
        let rooms = try await restoreRooms(modelContext: modelContext)

        // Restore items
        backupStatus = .restoring(.items)
        let items = try await restoreItems(
            modelContext: modelContext,
            categories: categories,
            expectedCount: metadata.itemCount
        )

        backupStatus = .completed
        progress = 1.0

        return RestoreResult(
            itemsRestored: items.count,
            categoriesRestored: categories.count,
            roomsRestored: rooms.count,
            backupDate: metadata.date
        )
    }

    // MARK: - Private Methods

    private func createBackupZone() async throws {
        do {
            _ = try await privateDatabase.save(backupZone)
        } catch {
            // Zone might already exist, which is fine
            if !error.localizedDescription.contains("Duplicate") {
                throw error
            }
        }
    }

    private func clearPreviousBackup() async {
        let query = CKQuery(recordType: "BackupItem", predicate: NSPredicate(value: true))

        do {
            let results = try await privateDatabase.records(matching: query, inZoneWith: backupZone.zoneID, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults)

            for (recordID, _) in results.matchResults {
                _ = try? await privateDatabase.deleteRecord(withID: recordID)
            }
        } catch {
            // Ignore errors during cleanup
        }
    }

    private func backupItem(_ item: Item) async throws {
        let recordID = CKRecord.ID(zoneID: backupZone.zoneID)
        let record = CKRecord(recordType: "BackupItem", recordID: recordID)

        // Basic properties
        record["itemID"] = item.id.uuidString
        record["name"] = item.name
        record["itemDescription"] = item.itemDescription
        record["quantity"] = item.quantity
        record["createdAt"] = item.createdAt
        record["updatedAt"] = item.updatedAt

        // Additional details
        record["brand"] = item.brand
        record["modelNumber"] = item.modelNumber
        record["serialNumber"] = item.serialNumber
        record["notes"] = item.notes

        // Financial info
        if let price = item.purchasePrice {
            record["purchasePrice"] = NSDecimalNumber(decimal: price)
        }
        record["purchaseDate"] = item.purchaseDate
        record["currency"] = item.currency

        // Warranty info
        record["warrantyExpirationDate"] = item.warrantyExpirationDate
        record["warrantyProvider"] = item.warrantyProvider
        record["warrantyNotes"] = item.warrantyNotes

        // Location
        record["room"] = item.room
        record["specificLocation"] = item.specificLocation

        // Tags
        record["tags"] = item.tags

        // Category reference
        if let category = item.category {
            record["categoryID"] = category.id.uuidString
        }

        // Images and documents (store as CKAsset for large data)
        if let imageData = item.imageData {
            record["imageData"] = try await createAsset(from: imageData, filename: "item_\(item.id).jpg")
        }

        if let receiptData = item.receiptImageData {
            record["receiptData"] = try await createAsset(from: receiptData, filename: "receipt_\(item.id).jpg")
        }

        record["extractedReceiptText"] = item.extractedReceiptText

        // Document names (actual data would need separate handling for size)
        record["documentNames"] = item.documentNames

        _ = try await privateDatabase.save(record)
    }

    private func backupCategories(_ categories: [Category]) async throws {
        for category in categories {
            let recordID = CKRecord.ID(zoneID: backupZone.zoneID)
            let record = CKRecord(recordType: "BackupCategory", recordID: recordID)
            record["categoryID"] = category.id.uuidString
            record["name"] = category.name
            record["icon"] = category.icon
            record["colorHex"] = category.colorHex
            _ = try await privateDatabase.save(record)
        }
    }

    private func backupRooms(_ rooms: [Room]) async throws {
        for room in rooms {
            let recordID = CKRecord.ID(zoneID: backupZone.zoneID)
            let record = CKRecord(recordType: "BackupRoom", recordID: recordID)
            record["roomID"] = room.id.uuidString
            record["name"] = room.name
            record["icon"] = room.icon
            record["roomDescription"] = room.roomDescription
            record["floor"] = room.floor
            _ = try await privateDatabase.save(record)
        }
    }

    private func saveBackupMetadata(itemCount: Int) async throws {
        let recordID = CKRecord.ID(zoneID: backupZone.zoneID)
        let record = CKRecord(recordType: "BackupMetadata", recordID: recordID)
        record["date"] = Date()
        record["itemCount"] = itemCount
        record["deviceName"] = UIDevice.current.name
        record["appVersion"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        _ = try await privateDatabase.save(record)
    }

    private func fetchBackupMetadata() async throws -> BackupMetadata? {
        let query = CKQuery(recordType: "BackupMetadata", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        let results = try await privateDatabase.records(matching: query, inZoneWith: backupZone.zoneID, desiredKeys: nil, resultsLimit: 1)

        guard let (_, result) = results.matchResults.first,
              case let .success(record) = result
        else {
            return nil
        }

        return BackupMetadata(
            date: record["date"] as? Date ?? Date(),
            itemCount: record["itemCount"] as? Int ?? 0,
            deviceName: record["deviceName"] as? String ?? "Unknown"
        )
    }

    private func restoreCategories(modelContext: ModelContext) async throws -> [Category] {
        let query = CKQuery(recordType: "BackupCategory", predicate: NSPredicate(value: true))
        let results = try await privateDatabase.records(matching: query, inZoneWith: backupZone.zoneID, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults)

        var categories: [Category] = []

        for (_, result) in results.matchResults {
            guard case let .success(record) = result else { continue }

            let category = Category(
                name: record["name"] as? String ?? "Unknown",
                icon: record["icon"] as? String ?? "folder",
                colorHex: record["colorHex"] as? String ?? "#007AFF"
            )

            modelContext.insert(category)
            categories.append(category)
        }

        return categories
    }

    private func restoreRooms(modelContext: ModelContext) async throws -> [Room] {
        let query = CKQuery(recordType: "BackupRoom", predicate: NSPredicate(value: true))
        let results = try await privateDatabase.records(matching: query, inZoneWith: backupZone.zoneID, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults)

        var rooms: [Room] = []

        for (_, result) in results.matchResults {
            guard case let .success(record) = result else { continue }

            let room = Room(
                name: record["name"] as? String ?? "Unknown",
                icon: record["icon"] as? String ?? "door.left.hand.open",
                roomDescription: record["roomDescription"] as? String,
                floor: record["floor"] as? String
            )

            modelContext.insert(room)
            rooms.append(room)
        }

        return rooms
    }

    private func restoreItems(modelContext: ModelContext, categories _: [Category], expectedCount: Int) async throws -> [Item] {
        let query = CKQuery(recordType: "BackupItem", predicate: NSPredicate(value: true))
        let results = try await privateDatabase.records(matching: query, inZoneWith: backupZone.zoneID, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults)

        var items: [Item] = []
        var processedCount = 0

        for (_, result) in results.matchResults {
            guard case let .success(record) = result else { continue }

            let item = Item(
                name: record["name"] as? String ?? "Unknown",
                itemDescription: record["itemDescription"] as? String,
                quantity: record["quantity"] as? Int ?? 1
            )

            // Restore all properties
            item.brand = record["brand"] as? String
            item.modelNumber = record["modelNumber"] as? String
            item.serialNumber = record["serialNumber"] as? String
            item.notes = record["notes"] as? String

            if let priceNumber = record["purchasePrice"] as? NSDecimalNumber {
                item.purchasePrice = priceNumber.decimalValue
            }
            item.purchaseDate = record["purchaseDate"] as? Date
            item.currency = record["currency"] as? String ?? "USD"

            item.warrantyExpirationDate = record["warrantyExpirationDate"] as? Date
            item.warrantyProvider = record["warrantyProvider"] as? String
            item.warrantyNotes = record["warrantyNotes"] as? String

            item.room = record["room"] as? String
            item.specificLocation = record["specificLocation"] as? String

            item.tags = record["tags"] as? [String] ?? []
            item.extractedReceiptText = record["extractedReceiptText"] as? String
            item.documentNames = record["documentNames"] as? [String] ?? []

            // Restore images from CKAsset
            if let imageAsset = record["imageData"] as? CKAsset,
               let data = try? Data(contentsOf: imageAsset.fileURL!)
            {
                item.imageData = data
            }

            if let receiptAsset = record["receiptData"] as? CKAsset,
               let data = try? Data(contentsOf: receiptAsset.fileURL!)
            {
                item.receiptImageData = data
            }

            modelContext.insert(item)
            items.append(item)

            processedCount += 1
            progress = 0.3 + (0.6 * Double(processedCount) / Double(expectedCount))
        }

        return items
    }

    private func createAsset(from data: Data, filename: String) async throws -> CKAsset {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)

        try data.write(to: fileURL)
        return CKAsset(fileURL: fileURL)
    }
}

// MARK: - Data Models

public enum BackupStatus: Equatable {
    case idle
    case backing(BackupPhase)
    case restoring(RestorePhase)
    case completed
    case failed

    public enum BackupPhase: String {
        case preparing = "Preparing backup..."
        case clearing = "Clearing previous backup..."
        case categories = "Backing up categories..."
        case rooms = "Backing up rooms..."
        case items = "Backing up items..."
        case metadata = "Saving metadata..."
    }

    public enum RestorePhase: String {
        case preparing = "Preparing restore..."
        case categories = "Restoring categories..."
        case rooms = "Restoring rooms..."
        case items = "Restoring items..."
    }
}

public struct BackupMetadata {
    let date: Date
    let itemCount: Int
    let deviceName: String
}

public struct RestoreResult {
    public let itemsRestored: Int
    public let categoriesRestored: Int
    public let roomsRestored: Int
    public let backupDate: Date
}

// MARK: - Errors

public enum BackupError: LocalizedError {
    case iCloudUnavailable
    case noBackupFound
    case backupFailed(String)
    case restoreFailed(String)

    public var errorDescription: String? {
        switch self {
        case .iCloudUnavailable:
            "iCloud is not available. Please check your iCloud settings."
        case .noBackupFound:
            "No backup found in iCloud."
        case let .backupFailed(reason):
            "Backup failed: \(reason)"
        case let .restoreFailed(reason):
            "Restore failed: \(reason)"
        }
    }
}

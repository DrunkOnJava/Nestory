//
// Layer: Services
// Module: CloudBackup
// Purpose: Transform SwiftData models to CloudKit records for backup
//

import CloudKit
import Foundation

public struct BackupDataTransformer: @unchecked Sendable {
    private let backupZone: CKRecordZone
    private let assetManager: CloudKitAssetManager

    public init(zone: CKRecordZone, assetManager: CloudKitAssetManager) {
        backupZone = zone
        self.assetManager = assetManager
    }

    // MARK: - Item Transformation

    @MainActor
    public func transformItem(_ item: Item) async throws -> CKRecord {
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

        // Location functionality removed

        // Tags
        record["tags"] = item.tags

        // Category reference
        if let category = item.category {
            record["categoryID"] = category.id.uuidString
        }

        // Images and documents
        if let imageData = item.imageData {
            record["imageData"] = try await assetManager.createAsset(
                from: imageData,
                filename: "item_\(item.id).jpg",
            )
        }

        if let receiptData = item.receiptImageData {
            record["receiptData"] = try await assetManager.createAsset(
                from: receiptData,
                filename: "receipt_\(item.id).jpg",
            )
        }

        record["extractedReceiptText"] = item.extractedReceiptText
        record["documentNames"] = item.documentNames

        return record
    }

    // MARK: - Category Transformation

    public func transformCategory(_ category: Category) -> CKRecord {
        let recordID = CKRecord.ID(zoneID: backupZone.zoneID)
        let record = CKRecord(recordType: "BackupCategory", recordID: recordID)

        record["categoryID"] = category.id.uuidString
        record["name"] = category.name
        record["icon"] = category.icon
        record["colorHex"] = category.colorHex

        return record
    }


    // MARK: - Batch Transformations

    public func transformCategories(_ categories: [Category]) -> [CKRecord] {
        categories.map { transformCategory($0) }
    }

}

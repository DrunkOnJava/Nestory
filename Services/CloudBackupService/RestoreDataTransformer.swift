//
// Layer: Services
// Module: CloudBackup
// Purpose: Transform CloudKit records back to SwiftData models during restore
//

import CloudKit
import Foundation
import SwiftData

public struct RestoreDataTransformer: @unchecked Sendable {
    private let assetManager: CloudKitAssetManager

    public init(assetManager: CloudKitAssetManager) {
        self.assetManager = assetManager
    }

    // MARK: - Category Restoration

    public func restoreCategory(from record: CKRecord) -> Category {
        let category = Category(
            name: record["name"] as? String ?? "Unknown",
            icon: record["icon"] as? String ?? "folder",
            colorHex: record["colorHex"] as? String ?? "#007AFF",
        )

        return category
    }


    // MARK: - Item Restoration

    @MainActor
    public func restoreItem(from record: CKRecord) async throws -> Item {
        let item = Item(
            name: record["name"] as? String ?? "Unknown",
            itemDescription: record["itemDescription"] as? String,
            quantity: record["quantity"] as? Int ?? 1,
        )

        // Restore all properties
        item.brand = record["brand"] as? String
        item.modelNumber = record["modelNumber"] as? String
        item.serialNumber = record["serialNumber"] as? String
        item.notes = record["notes"] as? String

        // Financial info
        if let priceNumber = record["purchasePrice"] as? NSDecimalNumber {
            item.purchasePrice = priceNumber.decimalValue
        }
        item.purchaseDate = record["purchaseDate"] as? Date
        item.currency = record["currency"] as? String ?? "USD"

        // Warranty info
        item.warrantyExpirationDate = record["warrantyExpirationDate"] as? Date
        item.warrantyProvider = record["warrantyProvider"] as? String
        item.warrantyNotes = record["warrantyNotes"] as? String

        // Location functionality removed

        // Tags and documents
        item.tags = record["tags"] as? [String] ?? []
        item.extractedReceiptText = record["extractedReceiptText"] as? String
        item.documentNames = record["documentNames"] as? [String] ?? []

        // Restore images from CKAsset
        if let imageAsset = record["imageData"] as? CKAsset {
            item.imageData = try await assetManager.loadData(from: imageAsset)
        }

        if let receiptAsset = record["receiptData"] as? CKAsset {
            item.receiptImageData = try await assetManager.loadData(from: receiptAsset)
        }

        return item
    }

    // MARK: - Batch Restoration

    public func restoreCategories(
        from records: [(CKRecord.ID, Result<CKRecord, Error>)],
        modelContext: ModelContext,
    ) -> [Category] {
        var categories: [Category] = []

        for (_, result) in records {
            guard case let .success(record) = result else { continue }

            let category = restoreCategory(from: record)
            modelContext.insert(category)
            categories.append(category)
        }

        return categories
    }


    @MainActor
    public func restoreItems(
        from records: [(CKRecord.ID, Result<CKRecord, Error>)],
        modelContext: ModelContext,
        progressHandler: ((Double) -> Void)? = nil,
    ) async throws -> [Item] {
        var items: [Item] = []
        let totalCount = records.count

        for (index, (_, result)) in records.enumerated() {
            guard case let .success(record) = result else { continue }

            let item = try await restoreItem(from: record)
            modelContext.insert(item)
            items.append(item)

            progressHandler?(Double(index + 1) / Double(totalCount))
        }

        return items
    }
}

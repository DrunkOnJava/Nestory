//
// Layer: Services
// Module: ImportExport
// Purpose: JSON import and export operations for ImportExportService
//

import Foundation
import os.log
import SwiftData

// MARK: - JSON Operations Extension

extension LiveImportExportService {
    // MARK: - JSON Import

    public func importJSON(from url: URL, modelContext: ModelContext) async throws -> ImportResult {
        let startTime = Date()

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = self.parseDate(dateString) {
                return date
            }

            // Try ISO8601
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string \(dateString)",
            )
        }

        var itemsImported = 0
        let itemsSkipped = 0
        var errors: [String] = []

        // Try to decode as array of items
        if let jsonItems = try? decoder.decode([ImportableItem].self, from: data) {
            for (_, jsonItem) in jsonItems.enumerated() {
                let item = jsonItem.toItem()
                modelContext.insert(item)
                itemsImported += 1
            }
        } else if let jsonItem = try? decoder.decode(ImportableItem.self, from: data) {
            // Try single item
            let item = jsonItem.toItem()
            modelContext.insert(item)
            itemsImported += 1
        } else {
            throw ImportError.invalidFormat("Cannot parse JSON data as ImportableItem(s)")
        }

        try modelContext.save()

        let processingTime = Date().timeIntervalSince(startTime)
        let fileSize = data.count

        return ImportResult(
            itemsImported: itemsImported,
            itemsSkipped: itemsSkipped,
            errors: errors,
            warnings: [],
            fileSize: fileSize,
            processingTime: processingTime,
        )
    }

    // MARK: - JSON Export

    public func exportToJSON(items: [Item]) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let exportableItems = items.map { ImportableItem(from: $0) }
        return try? encoder.encode(exportableItems)
    }
}

// MARK: - ImportableItem Extensions

extension ImportableItem {
    init(from item: Item) {
        name = item.name
        description = item.itemDescription
        category = item.category?.name
        purchasePrice = item.purchasePrice
        currency = item.currency
        purchaseDate = item.purchaseDate
        warrantyExpirationDate = item.warrantyExpirationDate
        serialNumber = item.serialNumber
        modelNumber = item.modelNumber
        brand = item.brand
        location = nil // Location not stored in Item model
        tags = item.tags
        notes = item.notes
    }

    func toItem() -> Item {
        let item = Item(name: name)
        item.itemDescription = description
        item.brand = brand
        item.modelNumber = modelNumber
        item.serialNumber = serialNumber
        item.purchasePrice = purchasePrice
        item.currency = currency ?? "USD"
        item.purchaseDate = purchaseDate
        item.warrantyExpirationDate = warrantyExpirationDate
        item.tags = tags ?? []
        item.notes = notes

        // Handle location by appending to notes if provided
        if let location {
            let locationNote = "Location: \(location)"
            if let existingNotes = item.notes {
                item.notes = "\(existingNotes)\n\(locationNote)"
            } else {
                item.notes = locationNote
            }
        }

        return item
    }
}

// Layer: Services
// Module: InventoryService
// Purpose: SwiftData inventory operations service

import Foundation
import os.log
import SwiftData

public protocol InventoryService: Sendable {
    func fetchItems() async throws -> [Item]
    func fetchItem(id: UUID) async throws -> Item?
    func saveItem(_ item: Item) async throws
    func updateItem(_ item: Item) async throws
    func deleteItem(id: UUID) async throws
    func searchItems(query: String) async throws -> [Item]
    func fetchCategories() async throws -> [Category]
    func saveCategory(_ category: Category) async throws
    func assignItemToCategory(itemId: UUID, categoryId: UUID) async throws
    func fetchItemsByCategory(categoryId: UUID) async throws -> [Item]
    func bulkImport(items: [Item]) async throws
    func exportInventory(format: ExportFormat) async throws -> Data
}

public struct LiveInventoryService: InventoryService, @unchecked Sendable {
    private let modelContext: ModelContext
    private let cache: Cache<UUID, Item>
    private let logger = Logger(subsystem: "com.nestory", category: "InventoryService")

    public init(modelContext: ModelContext) throws {
        self.modelContext = modelContext
        cache = try Cache(name: "inventory", maxMemoryCount: 100)
    }

    public func fetchItems() async throws -> [Item] {
        let descriptor = FetchDescriptor<Item>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        do {
            let items = try modelContext.fetch(descriptor)
            logger.debug("Fetched \(items.count) items")

            for item in items {
                await cache.set(item, for: item.id)
            }

            return items
        } catch {
            logger.error("Failed to fetch items: \(error.localizedDescription)")
            throw InventoryError.fetchFailed(error.localizedDescription)
        }
    }

    public func fetchItem(id: UUID) async throws -> Item? {
        if let cached = await cache.get(for: id) {
            logger.debug("Retrieved item from cache: \(id)")
            return cached
        }

        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            let items = try modelContext.fetch(descriptor)
            if let item = items.first {
                await cache.set(item, for: id)
                return item
            }
            return nil
        } catch {
            logger.error("Failed to fetch item \(id): \(error.localizedDescription)")
            throw InventoryError.fetchFailed(error.localizedDescription)
        }
    }

    public func saveItem(_ item: Item) async throws {
        modelContext.insert(item)

        do {
            try modelContext.save()
            await cache.set(item, for: item.id)
            logger.info("Saved item: \(item.name)")
        } catch {
            logger.error("Failed to save item: \(error.localizedDescription)")
            throw InventoryError.saveFailed(error.localizedDescription)
        }
    }

    public func updateItem(_ item: Item) async throws {
        item.updatedAt = Date()

        do {
            try modelContext.save()
            await cache.set(item, for: item.id)
            logger.info("Updated item: \(item.name)")
        } catch {
            logger.error("Failed to update item: \(error.localizedDescription)")
            throw InventoryError.updateFailed(error.localizedDescription)
        }
    }

    public func deleteItem(id: UUID) async throws {
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            let items = try modelContext.fetch(descriptor)
            if let item = items.first {
                modelContext.delete(item)
                try modelContext.save()
                await cache.remove(for: id)
                logger.info("Deleted item: \(id)")
            }
        } catch {
            logger.error("Failed to delete item \(id): \(error.localizedDescription)")
            throw InventoryError.deleteFailed(error.localizedDescription)
        }
    }

    public func searchItems(query: String) async throws -> [Item] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !trimmedQuery.isEmpty else {
            return try await fetchItems()
        }

        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { item in
                item.name.localizedStandardContains(trimmedQuery) ||
                    item.itemDescription?.localizedStandardContains(trimmedQuery) ?? false ||
                    item.brand?.localizedStandardContains(trimmedQuery) ?? false ||
                    item.serialNumber?.localizedStandardContains(trimmedQuery) ?? false
            },
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            let items = try modelContext.fetch(descriptor)
            logger.debug("Search found \(items.count) items for query: \(query)")
            return items
        } catch {
            logger.error("Search failed: \(error.localizedDescription)")
            throw InventoryError.searchFailed(error.localizedDescription)
        }
    }

    public func fetchCategories() async throws -> [Category] {
        let descriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            let categories = try modelContext.fetch(descriptor)
            logger.debug("Fetched \(categories.count) categories")
            return categories
        } catch {
            logger.error("Failed to fetch categories: \(error.localizedDescription)")
            throw InventoryError.fetchFailed(error.localizedDescription)
        }
    }

    public func saveCategory(_ category: Category) async throws {
        modelContext.insert(category)

        do {
            try modelContext.save()
            logger.info("Saved category: \(category.name)")
        } catch {
            logger.error("Failed to save category: \(error.localizedDescription)")
            throw InventoryError.saveFailed(error.localizedDescription)
        }
    }

    public func assignItemToCategory(itemId: UUID, categoryId: UUID) async throws {
        let itemDescriptor = FetchDescriptor<Item>(
            predicate: #Predicate { $0.id == itemId }
        )

        let categoryDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.id == categoryId }
        )

        do {
            let items = try modelContext.fetch(itemDescriptor)
            let categories = try modelContext.fetch(categoryDescriptor)

            guard let item = items.first,
                  let category = categories.first
            else {
                throw InventoryError.notFound
            }

            item.category = category
            item.updatedAt = Date()

            try modelContext.save()
            await cache.set(item, for: itemId)

            logger.info("Assigned item \(itemId) to category \(categoryId)")
        } catch {
            logger.error("Failed to assign category: \(error.localizedDescription)")
            throw InventoryError.updateFailed(error.localizedDescription)
        }
    }

    public func fetchItemsByCategory(categoryId: UUID) async throws -> [Item] {
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate { $0.category?.id == categoryId },
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            let items = try modelContext.fetch(descriptor)
            logger.debug("Fetched \(items.count) items for category \(categoryId)")
            return items
        } catch {
            logger.error("Failed to fetch items by category: \(error.localizedDescription)")
            throw InventoryError.fetchFailed(error.localizedDescription)
        }
    }

    public func bulkImport(items: [Item]) async throws {
        let signpost = OSSignposter()
        let state = signpost.beginInterval("bulk_import", id: signpost.makeSignpostID())
        defer { signpost.endInterval("bulk_import", state) }

        for item in items {
            modelContext.insert(item)
        }

        do {
            try modelContext.save()
            logger.info("Bulk imported \(items.count) items")

            for item in items {
                await cache.set(item, for: item.id)
            }
        } catch {
            logger.error("Bulk import failed: \(error.localizedDescription)")
            throw InventoryError.bulkOperationFailed(error.localizedDescription)
        }
    }

    public func exportInventory(format: ExportFormat) async throws -> Data {
        let items = try await fetchItems()

        switch format {
        case .json:
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return try encoder.encode(items)

        case .csv:
            var csv = "ID,Name,Description,Brand,Model,Serial Number,Purchase Date,Purchase Price,Currency,Quantity,Location,Condition,Category,Created,Updated\n"

            for item in items {
                let idString = item.id.uuidString
                let nameString = item.name
                let descString = item.itemDescription ?? ""
                let brandString = item.brand ?? ""
                let modelString = item.modelNumber ?? ""
                let serialString = item.serialNumber ?? ""
                let purchaseDateString = item.purchaseDate?.ISO8601Format() ?? ""
                let priceString = item.purchasePrice?.description ?? ""
                let currencyString = item.currency
                let quantityString = item.quantity.description
                let locationString = item.location?.name ?? ""
                let conditionString = ""
                let categoryString = item.category?.name ?? ""
                let createdString = item.createdAt.ISO8601Format()
                let updatedString = item.updatedAt.ISO8601Format()
                
                let fields = [
                    idString,
                    nameString,
                    descString,
                    brandString,
                    modelString,
                    serialString,
                    purchaseDateString,
                    priceString,
                    currencyString,
                    quantityString,
                    locationString,
                    conditionString,
                    categoryString,
                    createdString,
                    updatedString
                ]
                
                let row = fields.map { field in
                    if field.contains(",") || field.contains("\"") || field.contains("\n") {
                        return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
                    }
                    return field
                }.joined(separator: ",")

                csv += row + "\n"
            }

            guard let data = csv.data(using: .utf8) else {
                throw InventoryError.exportFailed("Failed to encode CSV")
            }

            return data

        case .pdf:
            throw InventoryError.exportFailed("PDF export not implemented")
        }
    }
}

public enum ExportFormat {
    case json
    case csv
    case pdf
}

public enum InventoryError: LocalizedError {
    case fetchFailed(String)
    case saveFailed(String)
    case updateFailed(String)
    case deleteFailed(String)
    case searchFailed(String)
    case notFound
    case bulkOperationFailed(String)
    case exportFailed(String)

    public var errorDescription: String? {
        switch self {
        case let .fetchFailed(reason):
            "Failed to fetch items: \(reason)"
        case let .saveFailed(reason):
            "Failed to save item: \(reason)"
        case let .updateFailed(reason):
            "Failed to update item: \(reason)"
        case let .deleteFailed(reason):
            "Failed to delete item: \(reason)"
        case let .searchFailed(reason):
            "Search failed: \(reason)"
        case .notFound:
            "Item not found"
        case let .bulkOperationFailed(reason):
            "Bulk operation failed: \(reason)"
        case let .exportFailed(reason):
            "Export failed: \(reason)"
        }
    }
}

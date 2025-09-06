// Layer: Services
// Module: InventoryService
// Purpose: SwiftData inventory operations service
//
// 🏗️ SERVICE LAYER PATTERN: Protocol-first design for TCA dependency injection
// - Protocol defines service contract for Features layer consumption
// - Live implementation handles SwiftData persistence operations
// - Follows 6-layer architecture: can import Infrastructure, Foundation only
//
// 🎯 BUSINESS FOCUS: Personal inventory for insurance documentation
// - CRUD operations for personal belongings (NOT business stock management)
// - Search and filtering for insurance claim preparation
// - Category management for insurance coverage organization
//
// 📋 SERVICE STANDARDS:
// - All services must be Sendable for Swift 6 concurrency
// - Use Result types for error handling where appropriate
// - Include performance logging for database operations
// - Validate data integrity before persistence
//

import Foundation
import os.log
import SwiftData

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with SwiftData - Already using SwiftData but could leverage CloudKit integration for sync

// 🏗️ TCA SERVICE PROTOCOL: Contract for dependency injection
// - Sendable for Swift 6 concurrency compliance
// - Async/throws pattern for proper error handling
// - Intent-based method names (fetch, save, not get/set)
public protocol InventoryService: Sendable {
    // 📊 CORE OPERATIONS: Primary inventory management
    func fetchItems() async throws -> [Item] // Load all items
    func fetchItem(id: UUID) async throws -> Item? // Load specific item
    func saveItem(_ item: Item) async throws // Create new item
    func updateItem(_ item: Item) async throws // Update existing item
    func deleteItem(id: UUID) async throws // Remove item

    // 🔍 SEARCH OPERATIONS: Insurance claim preparation support
    func searchItems(query: String) async throws -> [Item] // Multi-field search

    // 📂 CATEGORY OPERATIONS: Insurance coverage organization
    func fetchCategories() async throws -> [Category] // Load all categories
    func saveCategory(_ category: Category) async throws // Create category
    func assignItemToCategory(itemId: UUID, categoryId: UUID) async throws // Link item to category
    func fetchItemsByCategory(categoryId: UUID) async throws -> [Item] // Filter by category
    

    // Batch Operations for Performance
    func bulkImport(items: [Item]) async throws
    func bulkUpdate(items: [Item]) async throws
    func bulkDelete(itemIds: [UUID]) async throws
    func bulkSave(items: [Item]) async throws
    func bulkAssignCategory(itemIds: [UUID], categoryId: UUID) async throws

    func exportInventory(format: ExportFormat) async throws -> Data
}

public struct LiveInventoryService: InventoryService, @unchecked Sendable {
    private let modelContext: ModelContext
    private let cache: Cache<UUID, Item>
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "InventoryService")

    public init(modelContext: ModelContext) throws {
        self.modelContext = modelContext
        cache = try Cache(name: "inventory", maxMemoryCount: CacheConstants.Memory.defaultCountLimit)
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

        // SwiftData Predicate macro requires single expressions
        // Using filter instead of complex predicate
        let descriptor = FetchDescriptor<Item>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            let allItems = try modelContext.fetch(descriptor)
            // Filter in memory for complex conditions
            let items = allItems.filter { item in
                item.name.localizedStandardContains(trimmedQuery) ||
                    item.itemDescription?.localizedStandardContains(trimmedQuery) ?? false ||
                    item.brand?.localizedStandardContains(trimmedQuery) ?? false ||
                    item.serialNumber?.localizedStandardContains(trimmedQuery) ?? false
            }
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

    public func bulkUpdate(items: [Item]) async throws {
        let signpost = OSSignposter()
        let state = signpost.beginInterval("bulk_update", id: signpost.makeSignpostID())
        defer { signpost.endInterval("bulk_update", state) }

        let now = Date()
        for item in items {
            item.updatedAt = now
        }

        do {
            try modelContext.save()
            logger.info("Bulk updated \(items.count) items")

            // Update cache for all modified items
            for item in items {
                await cache.set(item, for: item.id)
            }
        } catch {
            logger.error("Bulk update failed: \(error.localizedDescription)")
            throw InventoryError.bulkOperationFailed(error.localizedDescription)
        }
    }

    public func bulkDelete(itemIds: [UUID]) async throws {
        let signpost = OSSignposter()
        let state = signpost.beginInterval("bulk_delete", id: signpost.makeSignpostID())
        defer { signpost.endInterval("bulk_delete", state) }

        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate { itemIds.contains($0.id) }
        )

        do {
            let itemsToDelete = try modelContext.fetch(descriptor)

            for item in itemsToDelete {
                modelContext.delete(item)
            }

            try modelContext.save()
            logger.info("Bulk deleted \(itemsToDelete.count) items")

            // Remove from cache
            for id in itemIds {
                await cache.remove(for: id)
            }
        } catch {
            logger.error("Bulk delete failed: \(error.localizedDescription)")
            throw InventoryError.bulkOperationFailed(error.localizedDescription)
        }
    }

    public func bulkSave(items: [Item]) async throws {
        let signpost = OSSignposter()
        let state = signpost.beginInterval("bulk_save", id: signpost.makeSignpostID())
        defer { signpost.endInterval("bulk_save", state) }

        for item in items {
            modelContext.insert(item)
        }

        do {
            try modelContext.save()
            logger.info("Bulk saved \(items.count) items")

            // Update cache for all new items
            for item in items {
                await cache.set(item, for: item.id)
            }
        } catch {
            logger.error("Bulk save failed: \(error.localizedDescription)")
            throw InventoryError.bulkOperationFailed(error.localizedDescription)
        }
    }

    public func bulkAssignCategory(itemIds: [UUID], categoryId: UUID) async throws {
        let signpost = OSSignposter()
        let state = signpost.beginInterval("bulk_assign_category", id: signpost.makeSignpostID())
        defer { signpost.endInterval("bulk_assign_category", state) }

        let itemDescriptor = FetchDescriptor<Item>(
            predicate: #Predicate { itemIds.contains($0.id) }
        )

        let categoryDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.id == categoryId }
        )

        do {
            let items = try modelContext.fetch(itemDescriptor)
            let categories = try modelContext.fetch(categoryDescriptor)

            guard let category = categories.first else {
                throw InventoryError.notFound
            }

            let now = Date()
            for item in items {
                item.category = category
                item.updatedAt = now
            }

            try modelContext.save()
            logger.info("Bulk assigned category \(categoryId) to \(items.count) items")

            // Update cache for all modified items
            for item in items {
                await cache.set(item, for: item.id)
            }
        } catch {
            logger.error("Bulk category assignment failed: \(error.localizedDescription)")
            throw InventoryError.bulkOperationFailed(error.localizedDescription)
        }
    }

    public func exportInventory(format: ExportFormat) async throws -> Data {
        let items = try await fetchItems()

        switch format {
        case .json:
            // Convert SwiftData models to Codable transfer objects
            let transferObjects = items.map { item in
                ItemTransferObject(
                    id: item.id,
                    name: item.name,
                    itemDescription: item.itemDescription,
                    brand: item.brand,
                    modelNumber: item.modelNumber,
                    serialNumber: item.serialNumber,
                    quantity: item.quantity,
                    purchasePrice: item.purchasePrice,
                    purchaseDate: item.purchaseDate,
                    currency: item.currency,
                    condition: item.condition,
                    categoryName: item.category?.name,
                    createdAt: item.createdAt,
                    updatedAt: item.updatedAt,
                )
            }

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return try encoder.encode(transferObjects)

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
                let locationString = ""
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
                    updatedString,
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
            
        case .xml:
            throw InventoryError.exportFailed("XML export not implemented")
            
        case .txt:
            throw InventoryError.exportFailed("TXT export not implemented")
            
        case .excel, .spreadsheet:
            throw InventoryError.exportFailed("Excel/Spreadsheet export not implemented")
            
        case .html:
            throw InventoryError.exportFailed("HTML export not implemented")
        }
    }
}

// Note: ExportFormat is now defined in Foundation/Models/ExportFormat.swift

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

// MARK: - Transfer Objects

/// Codable transfer object for JSON export of Item data
public struct ItemTransferObject: Codable {
    public let id: UUID
    public let name: String
    public let itemDescription: String?
    public let brand: String?
    public let modelNumber: String?
    public let serialNumber: String?
    public let quantity: Int
    public let purchasePrice: Decimal?
    public let purchaseDate: Date?
    public let currency: String
    public let condition: String
    public let categoryName: String?
    public let createdAt: Date
    public let updatedAt: Date
}

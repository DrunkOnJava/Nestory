//
// Layer: App
// Module: ViewModels
// Purpose: ViewModel for inventory list using service layer
//

import Foundation
import SwiftData
import SwiftUI
import os.log

@MainActor
@Observable
public final class InventoryListViewModel {
    // Published state
    public private(set) var items: [Item] = []
    public private(set) var categories: [Category] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    // Search and filtering
    public var searchText = "" {
        didSet {
            Task {
                await performSearch()
            }
        }
    }

    public var selectedCategory: Category? {
        didSet {
            Task {
                await loadItems()
            }
        }
    }

    // Dependencies
    private let inventoryService: InventoryService
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev", category: "InventoryListViewModel")

    public init(inventoryService: InventoryService) {
        self.inventoryService = inventoryService
    }

    // MARK: - Public Interface

    public func loadItems() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedItems: [Item]
            if let selectedCategory {
                fetchedItems = try await inventoryService.fetchItemsByCategory(categoryId: selectedCategory.id)
                logger.info("Loaded \(fetchedItems.count) items for category: \(selectedCategory.name)")
            } else {
                fetchedItems = try await inventoryService.fetchItems()
                logger.info("Loaded \(fetchedItems.count) total items")
            }
            items = fetchedItems
        } catch {
            logger.error("Failed to load items: \(error)")
            errorMessage = "Failed to load items: \(error.localizedDescription)"
            items = []
        }

        isLoading = false
    }

    public func loadCategories() async {
        do {
            let fetchedCategories = try await inventoryService.fetchCategories()
            categories = fetchedCategories
            logger.info("Loaded \(fetchedCategories.count) categories")
        } catch {
            logger.error("Failed to load categories: \(error)")
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
        }
    }

    public func deleteItem(_ item: Item) async {
        do {
            try await inventoryService.deleteItem(id: item.id)

            // Remove from local state
            items.removeAll { $0.id == item.id }

            logger.info("Deleted item: \(item.name)")
        } catch {
            logger.error("Failed to delete item: \(error)")
            errorMessage = "Failed to delete item: \(error.localizedDescription)"
        }
    }

    public func deleteItems(at indexSet: IndexSet) async {
        let itemsToDelete = indexSet.map { filteredItems[$0] }
        let itemIds = itemsToDelete.map(\.id)

        do {
            // Use batch delete for better performance
            try await inventoryService.bulkDelete(itemIds: itemIds)

            // Remove from local state
            items.removeAll { item in itemIds.contains(item.id) }

            logger.info("Batch deleted \(itemsToDelete.count) items")
        } catch {
            logger.error("Failed to batch delete items: \(error)")
            errorMessage = "Failed to delete items: \(error.localizedDescription)"
        }
    }

    // MARK: - Batch Operations

    public func bulkAssignCategory(_ category: Category, to itemIds: [UUID]) async {
        do {
            try await inventoryService.bulkAssignCategory(itemIds: itemIds, categoryId: category.id)

            // Update local state
            for i in items.indices {
                if itemIds.contains(items[i].id) {
                    items[i].category = category
                    items[i].updatedAt = Date()
                }
            }

            logger.info("Bulk assigned category '\(category.name)' to \(itemIds.count) items")
        } catch {
            logger.error("Failed to bulk assign category: \(error)")
            errorMessage = "Failed to assign category: \(error.localizedDescription)"
        }
    }

    public func bulkUpdateItems(_ itemsToUpdate: [Item]) async {
        do {
            try await inventoryService.bulkUpdate(items: itemsToUpdate)

            // Update local state by replacing items with the same IDs
            for updatedItem in itemsToUpdate {
                if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
                    items[index] = updatedItem
                }
            }

            logger.info("Bulk updated \(itemsToUpdate.count) items")
        } catch {
            logger.error("Failed to bulk update items: \(error)")
            errorMessage = "Failed to update items: \(error.localizedDescription)"
        }
    }

    public func importItems(_ newItems: [Item]) async {
        do {
            try await inventoryService.bulkImport(items: newItems)

            // Add to local state
            items.append(contentsOf: newItems)

            logger.info("Imported \(newItems.count) new items")
        } catch {
            logger.error("Failed to import items: \(error)")
            errorMessage = "Failed to import items: \(error.localizedDescription)"
        }
    }

    public func performSearch() async {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await loadItems()
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let searchResults = try await inventoryService.searchItems(query: searchText)
            items = searchResults
            logger.info("Search found \(searchResults.count) items for query: '\(self.searchText)'")
        } catch {
            logger.error("Search failed: \(error)")
            errorMessage = "Search failed: \(error.localizedDescription)"
            items = []
        }

        isLoading = false
    }

    public func refreshData() async {
        await loadItems()
        await loadCategories()
    }

    // MARK: - Computed Properties

    public var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        }

        let query = searchText.lowercased()
        return items.filter { item in
            item.name.lowercased().contains(query) ||
                item.brand?.lowercased().contains(query) == true ||
                item.itemDescription?.lowercased().contains(query) == true ||
                item.serialNumber?.lowercased().contains(query) == true
        }
    }

    public var hasItems: Bool {
        !items.isEmpty
    }

    public var isEmpty: Bool {
        items.isEmpty && !isLoading
    }

    public var showingError: Bool {
        errorMessage != nil
    }

    // MARK: - Error Handling

    public func clearError() {
        errorMessage = nil
    }
}

// MARK: - InventoryService Factory

extension InventoryListViewModel {
    @MainActor
    public static func create(from modelContext: ModelContext) -> InventoryListViewModel {
        do {
            let service = try LiveInventoryService(modelContext: modelContext)
            return InventoryListViewModel(inventoryService: service)
        } catch {
            // For now, create a minimal fallback service
            // The actual MockInventoryService is defined in Services/DependencyKeys.swift
            fatalError("Failed to create InventoryService: \(error)")
        }
    }
}

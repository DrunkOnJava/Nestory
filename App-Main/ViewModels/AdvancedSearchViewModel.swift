//
// Layer: App
// Module: ViewModels
// Purpose: Advanced search and filtering for inventory
//

import Foundation

// App layer - no direct logging imports
import SwiftUI

@MainActor
@Observable
public final class AdvancedSearchViewModel {
    // Search criteria
    public var searchText = ""
    public var selectedCategory: Category?
    public var minPrice = ""
    public var maxPrice = ""
    public var condition = ""
    public var hasWarranty: Bool?
    public var hasReceipt: Bool?
    public var hasPhoto: Bool?
    public var location = ""
    public var purchaseDateRange: ClosedRange<Date>?

    // Results and state
    public private(set) var searchResults: [Item] = []
    public private(set) var isSearching = false
    public private(set) var searchError: String?

    // Categories for filtering
    public private(set) var availableCategories: [Category] = []

    // Sort options
    public var sortOption: SortOption = .nameAsc {
        didSet {
            sortResults()
        }
    }

    // Dependencies
    private let inventoryService: InventoryService
    // ViewModels should delegate logging to services

    public init(inventoryService: InventoryService) {
        self.inventoryService = inventoryService
    }

    // MARK: - Public Interface

    public func loadCategories() async {
        do {
            availableCategories = try await inventoryService.fetchCategories()
            // Loaded categories for filtering
        } catch {
            // Error handling delegated to service
            searchError = "Failed to load categories: \(error.localizedDescription)"
        }
    }

    public func performAdvancedSearch() async {
        isSearching = true
        searchError = nil

        do {
            // Start with basic text search
            var results: [Item] = if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                try await inventoryService.searchItems(query: searchText)
            } else {
                try await inventoryService.fetchItems()
            }

            // Apply advanced filters
            results = applyFilters(to: results)

            searchResults = results
            sortResults()

            // Search completed
        } catch {
            // Error handling delegated to service
            searchError = "Search failed: \(error.localizedDescription)"
            searchResults = []
        }

        isSearching = false
    }

    public func clearFilters() {
        searchText = ""
        selectedCategory = nil
        minPrice = ""
        maxPrice = ""
        condition = ""
        hasWarranty = nil
        hasReceipt = nil
        hasPhoto = nil
        location = ""
        purchaseDateRange = nil
        searchResults = []
        searchError = nil
    }

    public func clearError() {
        searchError = nil
    }

    // MARK: - Private Implementation

    private func applyFilters(to items: [Item]) -> [Item] {
        var filteredItems = items

        // Category filter
        if let selectedCategory {
            filteredItems = filteredItems.filter { $0.category?.id == selectedCategory.id }
        }

        // Price range filter
        if let minPriceDecimal = Decimal(string: minPrice), !minPrice.isEmpty {
            filteredItems = filteredItems.filter {
                guard let price = $0.purchasePrice else { return false }
                return price >= minPriceDecimal
            }
        }

        if let maxPriceDecimal = Decimal(string: maxPrice), !maxPrice.isEmpty {
            filteredItems = filteredItems.filter {
                guard let price = $0.purchasePrice else { return false }
                return price <= maxPriceDecimal
            }
        }

        // Condition filter
        if !condition.isEmpty {
            filteredItems = filteredItems.filter { $0.condition == condition }
        }

        // Boolean filters
        if let hasWarranty {
            filteredItems = filteredItems.filter {
                hasWarranty ? $0.warrantyExpirationDate != nil : $0.warrantyExpirationDate == nil
            }
        }

        if let hasReceipt {
            filteredItems = filteredItems.filter {
                hasReceipt ? $0.receiptImageData != nil : $0.receiptImageData == nil
            }
        }

        if let hasPhoto {
            filteredItems = filteredItems.filter {
                hasPhoto ? $0.imageData != nil : $0.imageData == nil
            }
        }

        // Location filter - removed room functionality
        if !location.isEmpty {
            let locationQuery = location.lowercased()
            filteredItems = filteredItems.filter {
                $0.notes?.lowercased().contains(locationQuery) == true
            }
        }

        // Date range filter
        if let dateRange = purchaseDateRange {
            filteredItems = filteredItems.filter {
                guard let purchaseDate = $0.purchaseDate else { return false }
                return dateRange.contains(purchaseDate)
            }
        }

        return filteredItems
    }

    private func sortResults() {
        // APPLE_FRAMEWORK_OPPORTUNITY: Replace with Natural Language Framework - Use NLStringTokenizer for linguistic-aware sorting and search ranking
        switch sortOption {
        case .nameAsc:
            searchResults.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .nameDesc:
            searchResults.sort { $0.name.localizedCompare($1.name) == .orderedDescending }
        case .priceAsc:
            searchResults.sort {
                let price1 = $0.purchasePrice ?? 0
                let price2 = $1.purchasePrice ?? 0
                return price1 < price2
            }
        case .priceDesc:
            searchResults.sort {
                let price1 = $0.purchasePrice ?? 0
                let price2 = $1.purchasePrice ?? 0
                return price1 > price2
            }
        case .dateAsc:
            searchResults.sort { $0.createdAt < $1.createdAt }
        case .dateDesc:
            searchResults.sort { $0.createdAt > $1.createdAt }
        case .categoryName:
            searchResults.sort {
                let cat1 = $0.category?.name ?? ""
                let cat2 = $1.category?.name ?? ""
                return cat1.localizedCompare(cat2) == .orderedAscending
            }
        }
    }

    // MARK: - Computed Properties

    public var hasActiveFilters: Bool {
        !searchText.isEmpty ||
            selectedCategory != nil ||
            !minPrice.isEmpty ||
            !maxPrice.isEmpty ||
            !condition.isEmpty ||
            hasWarranty != nil ||
            hasReceipt != nil ||
            hasPhoto != nil ||
            !location.isEmpty ||
            purchaseDateRange != nil
    }

    public var filterSummary: String {
        var summary: [String] = []

        if !searchText.isEmpty {
            summary.append("Text: \"\(searchText)\"")
        }

        if let category = selectedCategory {
            summary.append("Category: \(category.name)")
        }

        if !minPrice.isEmpty || !maxPrice.isEmpty {
            let priceRange = "Price: \(minPrice.isEmpty ? "0" : minPrice) - \(maxPrice.isEmpty ? "∞" : maxPrice)"
            summary.append(priceRange)
        }

        if !condition.isEmpty {
            summary.append("Condition: \(condition)")
        }

        if hasWarranty == true {
            summary.append("Has warranty")
        }

        if hasReceipt == true {
            summary.append("Has receipt")
        }

        if hasPhoto == true {
            summary.append("Has photo")
        }

        if !location.isEmpty {
            summary.append("Location: \(location)")
        }

        return summary.isEmpty ? "No filters" : summary.joined(separator: ", ")
    }
}

// MARK: - Sort Options

public enum SortOption: String, CaseIterable {
    case nameAsc = "Name A-Z"
    case nameDesc = "Name Z-A"
    case priceAsc = "Price: Low to High"
    case priceDesc = "Price: High to Low"
    case dateAsc = "Oldest First"
    case dateDesc = "Newest First"
    case categoryName = "Category"
}

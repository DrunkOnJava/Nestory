//
//  SearchModels.swift
//  Nestory
//
//  Search-related models and enums
//

import Foundation
import SwiftUI

// MARK: - Sort Options

public enum SearchSortOption: String, CaseIterable {
    case nameAscending = "Name (A-Z)"
    case nameDescending = "Name (Z-A)"
    case priceAscending = "Price (Low to High)"
    case priceDescending = "Price (High to Low)"
    case dateAdded = "Recently Added"
    case quantity = "Quantity"

    var icon: String {
        switch self {
        case .nameAscending, .nameDescending: "textformat"
        case .priceAscending, .priceDescending: "dollarsign.circle"
        case .dateAdded: "calendar"
        case .quantity: "number"
        }
    }
}

// MARK: - Search Filters

public struct SearchFilters {
    var selectedCategories: Set<UUID> = []
    var priceRange: ClosedRange<Double> = 0 ... 10000
    var hasPhoto: Bool = false
    var hasReceipt: Bool = false
    var hasWarranty: Bool = false
    var hasSerialNumber: Bool = false
    var minQuantity: Int = 0
    var maxQuantity: Int = 100
    var rooms: Set<String> = []

    var isActive: Bool {
        !selectedCategories.isEmpty ||
            priceRange != 0 ... 10000 ||
            hasPhoto || hasReceipt || hasWarranty || hasSerialNumber ||
            minQuantity > 0 || maxQuantity < 100 ||
            !rooms.isEmpty
    }

    mutating func reset() {
        selectedCategories = []
        priceRange = 0 ... 10000
        hasPhoto = false
        hasReceipt = false
        hasWarranty = false
        hasSerialNumber = false
        minQuantity = 0
        maxQuantity = 100
        rooms = []
    }
}

// MARK: - Search History

public struct SearchHistory: Codable, Equatable {
    var recentSearches: [String] = []
    var popularSearches: [String] = []

    mutating func addSearch(_ term: String) {
        // Remove if already exists
        recentSearches.removeAll { $0 == term }
        // Add to beginning
        recentSearches.insert(term, at: 0)
        // Keep only last 10
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
    }

    mutating func removeSearch(_ term: String) {
        recentSearches.removeAll { $0 == term }
    }

    mutating func clearAll() {
        recentSearches.removeAll()
    }
}

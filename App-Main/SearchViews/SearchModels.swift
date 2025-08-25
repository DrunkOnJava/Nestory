//
// Layer: App-Main
// Module: SearchViews
// Purpose: Search-related models and enums
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

// NOTE: SearchFilters is now defined in Features/Search/SearchFeature.swift
// to avoid duplication and ensure proper TCA integration

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

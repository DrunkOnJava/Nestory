//
// Layer: Features/Search
// Module: Search/Components/State
// Purpose: Comprehensive search state management for TCA reducer
//

import ComposableArchitecture
import SwiftData
import SwiftUI
import Foundation

@ObservableState
public struct SearchState: Equatable {
    // 🔍 SEARCH STATE: Core search functionality
    public var searchText = "" // Current search query
    public var isSearching = false // Active search indicator
    public var searchResults: [Item] = [] // Filtered search results
    public var totalResultsCount = 0 // Total available results
    public var isLoadingResults = false // Loading state for async search

    // 🎯 FILTER STATE: Multi-dimensional filtering
    public var filters = SearchFilters() // Active filter configuration
    public var availableCategories: [Category] = [] // Categories for filtering
    public var availableRooms: [String] = [] // Room options for filtering
    public var sortOption: SortOption = .nameAscending // Current sort configuration
    public var showFiltersSheet = false // Filter sheet presentation state
    public var showAdvancedSearchSheet = false // Advanced search sheet presentation state

    // 📚 SEARCH HISTORY: User search patterns
    public var searchHistory: [SearchHistoryItem] = [] // Recent searches
    public var savedSearches: [SavedSearch] = [] // User-saved search queries
    public var showHistorySheet = false // History sheet presentation state
    public var maxHistoryItems = 20 // History item limit

    // 🎨 UI STATE: Interface and interaction state
    public var selectedItem: Item? = nil // Currently selected item
    public var showItemDetail = false // Item detail presentation
    public var searchMode: SearchMode = .quick // Search interface mode
    public var error: SearchError? = nil // Error state
    @Presents public var alert: AlertState<SearchAction.Alert>? = nil

    // 📊 SEARCH ANALYTICS: Performance and usage tracking
    public var searchMetrics = SearchMetrics()

    public init() {}

    // 🔍 COMPUTED PROPERTIES: Derived search state
    public var hasActiveFilters: Bool {
        filters.hasActiveFilters
    }

    public var hasSearchQuery: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var displayedResults: [Item] {
        SearchUtils.sortResults(searchResults, by: sortOption)
    }

    public var hasResults: Bool {
        !searchResults.isEmpty
    }

    public var searchSummary: String {
        if isLoadingResults {
            "Searching..."
        } else if hasSearchQuery || hasActiveFilters {
            "\(totalResultsCount) item(s) found"
        } else {
            "Enter search terms or apply filters"
        }
    }

    public var canSaveSearch: Bool {
        hasSearchQuery || hasActiveFilters
    }

    public enum SearchMode: String, CaseIterable, Equatable, Sendable {
        case quick = "Quick"
        case advanced = "Advanced"
        case visual = "Visual"
    }

    public enum SortOption: String, CaseIterable, Equatable, Sendable {
        case nameAscending = "Name A-Z"
        case nameDescending = "Name Z-A"
        case priceAscending = "Price Low-High"
        case priceDescending = "Price High-Low"
        case dateAdded = "Recently Added"
        case dateModified = "Recently Modified"
        case relevance = "Best Match"
    }
}

// MARK: - Supporting Types

public enum SearchError: Error, LocalizedError, Equatable, Sendable {
    case searchExecutionFailed(String)
    case invalidQuery(String)
    case invalidFilters([String])
    case networkError(String)
    case dataCorruption(String)
    
    public var errorDescription: String? {
        switch self {
        case .searchExecutionFailed(let message):
            return "Search failed: \(message)"
        case .invalidQuery(let query):
            return "Invalid search query: \(query)"
        case .invalidFilters(let issues):
            return "Invalid filters: \(issues.joined(separator: ", "))"
        case .networkError(let message):
            return "Network error: \(message)"
        case .dataCorruption(let message):
            return "Data corruption: \(message)"
        }
    }
}

public struct SearchMetrics: Equatable, Sendable {
    public var totalSearches = 0
    public var averageResultCount = 0.0
    public var averageSearchTime = 0.0
    public var mostUsedFilters: [String] = []
    public var searchPatterns: [String] = []
    
    public init() {}
    
    public mutating func recordSearch(query: String, resultCount: Int, executionTime: TimeInterval) {
        totalSearches += 1
        
        // Update running averages
        let alpha = 0.1 // Learning rate for exponential moving average
        averageResultCount = averageResultCount * (1 - alpha) + Double(resultCount) * alpha
        averageSearchTime = averageSearchTime * (1 - alpha) + executionTime * alpha
        
        // Track search patterns (simplified)
        if !query.isEmpty && !searchPatterns.contains(query) {
            searchPatterns.append(query)
            // Keep only recent patterns
            if searchPatterns.count > 10 {
                searchPatterns.removeFirst()
            }
        }
    }
}
//
// Layer: Features
// Module: Search
// Purpose: Search Feature TCA Reducer
//
// 🏗️ TCA FEATURE PATTERN: Advanced Search and Filtering
// - Manages sophisticated search state and filtering logic using TCA patterns
// - Coordinates multi-dimensional filtering and sorting operations
// - Handles search history and saved searches
// - FOLLOWS 6-layer architecture: can import UI, Services, Foundation, ComposableArchitecture
//
// 🎯 BUSINESS FOCUS: Insurance-focused search and discovery
// - Multi-field search across items, categories, and documentation
// - Documentation completeness filtering for claim preparation
// - Advanced filtering for insurance category analysis
// - Search history for efficient claim research workflows
// - Real-time search with debouncing for performance
//
// 📋 TCA STANDARDS:
// - State must be Equatable for TCA diffing
// - Actions should be intent-based (performSearch, not setResults)
// - Effects return to drive async operations
// - Use @Dependency for service injection
//

import ComposableArchitecture
import SwiftData
import SwiftUI
import Foundation

@Reducer
struct SearchFeature {
    @ObservableState
    struct State: Equatable {
        // 🔍 SEARCH STATE: Core search functionality
        var searchText = "" // Current search query
        var isSearching = false // Active search indicator
        var searchResults: [Item] = [] // Filtered search results
        var totalResultsCount = 0 // Total available results
        var isLoadingResults = false // Loading state for async search

        // 🎯 FILTER STATE: Multi-dimensional filtering
        var filters = SearchFilters() // Active filter configuration
        var availableCategories: [Category] = [] // Categories for filtering
        var availableRooms: [String] = [] // Room options for filtering
        var sortOption: SortOption = .nameAscending // Current sort configuration
        var showFiltersSheet = false // Filter sheet presentation state

        // 📚 SEARCH HISTORY: User search patterns
        var searchHistory: [SearchHistoryItem] = [] // Recent searches
        var savedSearches: [SavedSearch] = [] // User-saved search queries
        var showHistorySheet = false // History sheet presentation state
        var maxHistoryItems = 20 // History item limit

        // 🎨 UI STATE: Interface and interaction state
        var selectedItem: Item? = nil // Currently selected item
        var showItemDetail = false // Item detail presentation
        var searchMode: SearchMode = .quick // Search interface mode
        var error: SearchError? = nil // Error state
        @Presents var alert: AlertState<Alert>? = nil

        // 🔍 COMPUTED PROPERTIES: Derived search state
        var hasActiveFilters: Bool {
            filters.isActive
        }

        var hasSearchQuery: Bool {
            !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        var displayedResults: [Item] {
            sortResults(searchResults, by: sortOption)
        }

        var hasResults: Bool {
            !searchResults.isEmpty
        }

        var searchSummary: String {
            if isLoadingResults {
                "Searching..."
            } else if hasSearchQuery || hasActiveFilters {
                "\(totalResultsCount) item(s) found"
            } else {
                "Enter search terms or apply filters"
            }
        }

        var canSaveSearch: Bool {
            hasSearchQuery || hasActiveFilters
        }

        // 📊 SEARCH ANALYTICS: Performance and usage tracking
        var searchMetrics = SearchMetrics()

        enum SearchMode: String, CaseIterable, Equatable {
            case quick = "Quick"
            case advanced = "Advanced"
            case visual = "Visual"
        }

        enum SortOption: String, CaseIterable, Equatable {
            case nameAscending = "Name A-Z"
            case nameDescending = "Name Z-A"
            case priceAscending = "Price Low-High"
            case priceDescending = "Price High-Low"
            case dateAdded = "Recently Added"
            case dateModified = "Recently Modified"
            case relevance = "Best Match"
        }
    }

    enum Action {
        case onAppear
        case loadSearchData

        // Search actions
        case searchTextChanged(String)
        case performSearch
        case searchCompleted([Item], Int)
        case searchFailed(SearchError)
        case clearSearch
        case selectSearchMode(State.SearchMode)

        // Filter actions
        case showFilters
        case hideFilters
        case updateFilters(SearchFilters)
        case clearFilters
        case clearSpecificFilter(FilterType)

        // Sort actions
        case sortOptionChanged(State.SortOption)

        // History actions
        case showHistory
        case hideHistory
        case selectHistoryItem(SearchHistoryItem)
        case deleteHistoryItem(UUID)
        case clearHistory
        case saveCurrentSearch(String)
        case deleteSavedSearch(UUID)

        // Item selection actions
        case itemTapped(Item)
        case showItemDetail(Item)
        case hideItemDetail

        // Data loading actions
        case categoriesLoaded([Category])
        case roomsLoaded([String])
        case historyLoaded([SearchHistoryItem])
        case savedSearchesLoaded([SavedSearch])

        // Analytics actions
        case trackSearchPerformed(String, SearchFilters)
        case trackFilterApplied(FilterType)
        case trackItemSelected(UUID)

        // Alert actions
        case alert(PresentationAction<Alert>)

        enum Alert: Equatable {
            case saveSearchConfirmation
            case clearHistoryConfirmation
        }
    }

    @Dependency(\.inventoryService) var inventoryService
    // @Dependency(\.searchHistoryService) var searchHistoryService
    // TODO: P0.1.4 - Add searchHistoryService to DependencyKeys.swift

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.loadSearchData),
                    .run { send in
                        // Load categories for filtering
                        let categories = try await inventoryService.fetchCategories()
                        await send(.categoriesLoaded(categories))

                        // Load search history
                        let history = await searchHistoryService.loadHistory()
                        await send(.historyLoaded(history))

                        // Load saved searches
                        let saved = await searchHistoryService.loadSavedSearches()
                        await send(.savedSearchesLoaded(saved))
                    }
                )

            case .loadSearchData:
                return .run { send in
                    // Load available rooms for filtering
                    let rooms = try await inventoryService.fetchAvailableRooms()
                    await send(.roomsLoaded(rooms))
                }

            case let .searchTextChanged(text):
                state.searchText = text

                // Debounced search - trigger search after brief delay
                return .run { send in
                    try await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
                    await send(.performSearch)
                }
                .cancellable(id: "search", cancelInFlight: true)

            case .performSearch:
                guard state.hasSearchQuery || state.hasActiveFilters else {
                    state.searchResults = []
                    state.totalResultsCount = 0
                    return .none
                }

                state.isLoadingResults = true

                return .run { [searchText = state.searchText, filters = state.filters] send in
                    do {
                        let results = try await performAdvancedSearch(
                            query: searchText,
                            filters: filters
                        )
                        await send(.searchCompleted(results.items, results.totalCount))

                        // Track search analytics
                        await send(.trackSearchPerformed(searchText, filters))

                        // Save to history if meaningful search
                        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            await searchHistoryService.addToHistory(searchText, filters)
                        }

                    } catch {
                        await send(.searchFailed(.searchExecutionFailed(error.localizedDescription)))
                    }
                }

            case let .searchCompleted(items, totalCount):
                state.isLoadingResults = false
                state.searchResults = items
                state.totalResultsCount = totalCount
                state.error = nil

                // Update search metrics
                state.searchMetrics.recordSearch(
                    query: state.searchText,
                    resultCount: totalCount,
                    executionTime: 0.3 // Would be measured in real implementation
                )

                return .none

            case let .searchFailed(error):
                state.isLoadingResults = false
                state.error = error
                state.searchResults = []
                state.totalResultsCount = 0
                return .none

            case .clearSearch:
                state.searchText = ""
                state.searchResults = []
                state.totalResultsCount = 0
                state.error = nil
                return .none

            case let .selectSearchMode(mode):
                state.searchMode = mode
                return .send(.performSearch)

            case .showFilters:
                state.showFiltersSheet = true
                return .none

            case .hideFilters:
                state.showFiltersSheet = false
                return .none

            case let .updateFilters(newFilters):
                state.filters = newFilters
                return .send(.performSearch)

            case .clearFilters:
                state.filters = SearchFilters()
                return .send(.performSearch)

            case let .clearSpecificFilter(filterType):
                state.filters.clearFilter(filterType)
                return .send(.performSearch)

            case let .sortOptionChanged(option):
                state.sortOption = option
                return .none

            case .showHistory:
                state.showHistorySheet = true
                return .none

            case .hideHistory:
                state.showHistorySheet = false
                return .none

            case let .selectHistoryItem(item):
                state.searchText = item.query
                state.filters = item.filters
                state.showHistorySheet = false
                return .send(.performSearch)

            case let .deleteHistoryItem(id):
                state.searchHistory.removeAll { $0.id == id }
                return .run { _ in
                    await searchHistoryService.removeFromHistory(id)
                }

            case .clearHistory:
                state.searchHistory = []
                return .run { _ in
                    await searchHistoryService.clearHistory()
                }

            case let .saveCurrentSearch(name):
                let savedSearch = SavedSearch(
                    id: UUID(),
                    name: name,
                    query: state.searchText,
                    filters: state.filters,
                    createdAt: Date()
                )
                state.savedSearches.append(savedSearch)
                return .run { _ in
                    await searchHistoryService.saveFavoriteSearch(savedSearch)
                }

            case let .deleteSavedSearch(id):
                state.savedSearches.removeAll { $0.id == id }
                return .run { _ in
                    await searchHistoryService.deleteSavedSearch(id)
                }

            case let .itemTapped(item):
                return .send(.showItemDetail(item))

            case let .showItemDetail(item):
                state.selectedItem = item
                state.showItemDetail = true
                return .send(.trackItemSelected(item.id))

            case .hideItemDetail:
                state.selectedItem = nil
                state.showItemDetail = false
                return .none

            case let .categoriesLoaded(categories):
                state.availableCategories = categories
                return .none

            case let .roomsLoaded(rooms):
                state.availableRooms = rooms
                return .none

            case let .historyLoaded(history):
                state.searchHistory = history
                return .none

            case let .savedSearchesLoaded(saved):
                state.savedSearches = saved
                return .none

            case let .trackSearchPerformed(query, filters):
                // Analytics tracking would be implemented here
                return .none

            case let .trackFilterApplied(filterType):
                // Analytics tracking would be implemented here
                return .none

            case let .trackItemSelected(itemId):
                // Analytics tracking would be implemented here
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Supporting Types

struct SearchFilters: Equatable {
    var selectedCategories: Set<UUID> = []
    var priceRange: ClosedRange<Double> = 0 ... 10000
    var hasPhoto = false
    var hasReceipt = false
    var hasWarranty = false
    var hasSerialNumber = false
    var minQuantity = 0
    var maxQuantity = 100
    var rooms: Set<String> = []
    var dateRange: DateRange? = nil
    var documentationCompleteOnly = false

    var isActive: Bool {
        !selectedCategories.isEmpty ||
            priceRange != (0 ... 10000) ||
            hasPhoto || hasReceipt || hasWarranty || hasSerialNumber ||
            minQuantity > 0 || maxQuantity < 100 ||
            !rooms.isEmpty ||
            dateRange != nil ||
            documentationCompleteOnly
    }

    mutating func clearFilter(_ type: FilterType) {
        switch type {
        case .categories:
            selectedCategories = []
        case .priceRange:
            priceRange = 0 ... 10000
        case .documentation:
            hasPhoto = false
            hasReceipt = false
            hasWarranty = false
            hasSerialNumber = false
            documentationCompleteOnly = false
        case .quantity:
            minQuantity = 0
            maxQuantity = 100
        case .rooms:
            rooms = []
        case .dateRange:
            dateRange = nil
        }
    }
}

enum FilterType: CaseIterable {
    case categories
    case priceRange
    case documentation
    case quantity
    case rooms
    case dateRange
}

struct DateRange: Equatable {
    let start: Date
    let end: Date
}

struct SearchHistoryItem: Equatable, Identifiable {
    let id = UUID()
    let query: String
    let filters: SearchFilters
    let timestamp: Date
    let resultCount: Int
}

struct SavedSearch: Equatable, Identifiable {
    let id: UUID
    let name: String
    let query: String
    let filters: SearchFilters
    let createdAt: Date
}

struct SearchMetrics: Equatable {
    var totalSearches = 0
    var averageResultCount: Double = 0
    var averageExecutionTime: Double = 0
    var popularQueries: [String: Int] = [:]

    mutating func recordSearch(query: String, resultCount: Int, executionTime: Double) {
        totalSearches += 1

        // Update running average
        averageResultCount = (averageResultCount * Double(totalSearches - 1) + Double(resultCount)) / Double(totalSearches)
        averageExecutionTime = (averageExecutionTime * Double(totalSearches - 1) + executionTime) / Double(totalSearches)

        // Track popular queries
        popularQueries[query, default: 0] += 1
    }
}

struct SearchResults {
    let items: [Item]
    let totalCount: Int
}

enum SearchError: Error, Equatable {
    case searchExecutionFailed(String)
    case invalidSearchQuery
    case serviceUnavailable

    var localizedDescription: String {
        switch self {
        case let .searchExecutionFailed(message):
            "Search failed: \(message)"
        case .invalidSearchQuery:
            "Invalid search query"
        case .serviceUnavailable:
            "Search service is currently unavailable"
        }
    }
}

// MARK: - Helper Functions

private func sortResults(_ items: [Item], by option: SearchFeature.State.SortOption) -> [Item] {
    switch option {
    case .nameAscending:
        items.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    case .nameDescending:
        items.sorted { $0.name.localizedCompare($1.name) == .orderedDescending }
    case .priceAscending:
        items.sorted { ($0.purchasePrice ?? 0) < ($1.purchasePrice ?? 0) }
    case .priceDescending:
        items.sorted { ($0.purchasePrice ?? 0) > ($1.purchasePrice ?? 0) }
    case .dateAdded:
        items.sorted { $0.createdAt > $1.createdAt }
    case .dateModified:
        items.sorted { $0.updatedAt > $1.updatedAt }
    case .relevance:
        // Would implement relevance scoring in real implementation
        items
    }
}

private func performAdvancedSearch(query _: String, filters _: SearchFilters) async throws -> SearchResults {
    // This would integrate with the actual search service
    // For now, return placeholder results
    let items: [Item] = [] // Would be actual search results
    return SearchResults(items: items, totalCount: items.count)
}

// MARK: - TCA Integration Notes

//
// 🔗 SERVICE INTEGRATION: Uses protocol-based search services
// - InventoryService: Item and category data access
// - SearchHistoryService: Search history and saved searches management
// - Advanced search with multi-field indexing and filtering
// - Debounced search for performance optimization
//
// 🎯 STATE MANAGEMENT: Sophisticated search experience
// - Real-time search with debouncing for performance
// - Multi-dimensional filtering with complex state validation
// - Search history and saved searches for user convenience
// - Analytics tracking for search performance optimization
//

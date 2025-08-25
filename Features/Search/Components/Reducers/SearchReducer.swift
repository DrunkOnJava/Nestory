//
// Layer: Features/Search
// Module: Search/Components/Reducers
// Purpose: Main TCA reducer logic for search feature
//

import ComposableArchitecture
import Foundation

public struct SearchReducer: Reducer {
    
    // MARK: - Dependencies
    
    @Dependency(\.inventoryService) var inventoryService
    @Dependency(\.searchHistoryService) var searchHistoryService
    
    private var searchEffects: SearchEffects {
        SearchEffects(
            inventoryService: inventoryService,
            searchHistoryService: searchHistoryService
        )
    }
    
    public var body: some ReducerOf<SearchFeature> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.loadSearchData),
                    searchEffects.loadInitialData()
                )
                
            case .loadSearchData:
                return searchEffects.loadInitialData()
                
            case let .searchTextChanged(text):
                state.searchText = text
                return searchEffects.performDebouncedSearch(
                    query: text,
                    filters: state.filters
                )
                
            case .performSearch:
                guard state.hasSearchQuery || state.hasActiveFilters else {
                    state.searchResults = []
                    state.totalResultsCount = 0
                    return .none
                }
                
                state.isLoadingResults = true
                return searchEffects.performDebouncedSearch(
                    query: state.searchText,
                    filters: state.filters
                )
                
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
                
            // Filter Actions
            case .showFilters:
                state.showFiltersSheet = true
                return .none
                
            case .hideFilters:
                state.showFiltersSheet = false
                return .none
                
            // Advanced Search Actions
            case .showAdvancedSearch:
                state.showAdvancedSearchSheet = true
                return .none
                
            case .hideAdvancedSearch:
                state.showAdvancedSearchSheet = false
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
                
            // Sort Actions
            case let .sortOptionChanged(option):
                state.sortOption = option
                return .none
                
            // History Actions
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
                return searchEffects.deleteHistoryItem(id)
                
            case .clearHistory:
                state.searchHistory.removeAll()
                return searchEffects.clearAllHistory()
                
            case let .saveCurrentSearch(name):
                return searchEffects.saveSearch(name, query: state.searchText, filters: state.filters)
                
            case let .deleteSavedSearch(id):
                state.savedSearches.removeAll { $0.id == id }
                return searchEffects.deleteSavedSearch(id)
                
            // Item Selection Actions
            case let .itemTapped(item):
                return .send(.showItemDetail(item))
                
            case let .showItemDetail(item):
                state.selectedItem = item
                state.showItemDetail = true
                return .none
                
            case .hideItemDetail:
                state.selectedItem = nil
                state.showItemDetail = false
                return .none
                
            // Data Loading Actions
            case let .categoriesLoaded(categories):
                state.availableCategories = categories
                return .none
                
            case let .roomsLoaded(rooms):
                state.availableRooms = rooms
                return .none
                
            case let .historyLoaded(history):
                state.searchHistory = Array(history.prefix(state.maxHistoryItems))
                return .none
                
            case let .savedSearchesLoaded(saved):
                state.savedSearches = saved
                return .none
                
            // Analytics Actions
            case let .trackSearchPerformed(query, filters):
                // Analytics tracking would be implemented here
                return .none
                
            case let .trackFilterApplied(filterType):
                // Filter analytics would be tracked here
                return .none
                
            case let .trackItemSelected(itemId):
                // Item selection analytics would be tracked here
                return .none
                
            // Alert Actions
            case .alert(.presented(.saveSearchConfirmation)):
                // Handle save search confirmation
                return .none
                
            case .alert(.presented(.clearHistoryConfirmation)):
                return .send(.clearHistory)
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: /SearchAction.alert)
    }
}
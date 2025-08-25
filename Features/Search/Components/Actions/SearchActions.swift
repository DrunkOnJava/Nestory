//
// Layer: Features/Search
// Module: Search/Components/Actions
// Purpose: Comprehensive action definitions for search TCA reducer
//

import ComposableArchitecture
import Foundation

@CasePathable
public enum SearchAction: Sendable {
    case onAppear
    case loadSearchData

    // Search actions
    case searchTextChanged(String)
    case performSearch
    case searchCompleted([Item], Int)
    case searchFailed(SearchError)
    case clearSearch
    case selectSearchMode(SearchState.SearchMode)

    // Filter actions
    case showFilters
    case hideFilters
    case updateFilters(SearchFilters)
    case clearFilters
    case clearSpecificFilter(FilterType)

    // Sort actions
    case sortOptionChanged(SearchState.SortOption)

    // History actions
    case showHistory
    case hideHistory
    case selectHistoryItem(SearchHistoryItem)
    case deleteHistoryItem(UUID)
    case clearHistory
    case saveCurrentSearch(String)
    case deleteSavedSearch(UUID)

    // Advanced search actions
    case showAdvancedSearch
    case hideAdvancedSearch

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

    public enum Alert: Equatable, Sendable {
        case saveSearchConfirmation
        case clearHistoryConfirmation
    }
}
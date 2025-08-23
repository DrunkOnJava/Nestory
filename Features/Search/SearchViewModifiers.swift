//
// Layer: Features
// Module: Search
// Purpose: View modifiers and extensions for search interface
//

import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - View Modifiers for Sheets

public extension View {
    /// Applies search-related sheet presentations to a view
    func searchSheets(_ store: StoreOf<SearchFeature>) -> some View {
        self
            .sheet(
                isPresented: Binding(
                    get: { store.showFiltersSheet },
                    set: { _ in store.send(.hideFilters) }
                )
            ) {
                TCASearchFilterView(
                    filters: store.filters,
                    availableCategories: store.availableCategories,
                    availableRooms: store.availableRooms,
                    onFiltersUpdated: { filters in
                        store.send(.updateFilters(filters))
                    },
                    onDismiss: {
                        store.send(.hideFilters)
                    }
                )
            }
            .sheet(
                isPresented: Binding(
                    get: { store.showHistorySheet },
                    set: { _ in store.send(.hideHistory) }
                )
            ) {
                TCASearchHistorySheet(
                    searchHistory: store.searchHistory,
                    savedSearches: store.savedSearches,
                    canSaveSearch: store.canSaveSearch,
                    onHistoryItemSelected: { item in
                        store.send(.selectHistoryItem(item))
                    },
                    onHistoryItemDeleted: { id in
                        store.send(.deleteHistoryItem(id))
                    },
                    onSaveCurrentSearch: { name in
                        store.send(.saveCurrentSearch(name))
                    },
                    onSavedSearchDeleted: { id in
                        store.send(.deleteSavedSearch(id))
                    },
                    onDismiss: {
                        store.send(.hideHistory)
                    }
                )
            }
            .sheet(
                isPresented: Binding(
                    get: { store.showAdvancedSearchSheet },
                    set: { _ in store.send(.hideAdvancedSearch) }
                )
            ) {
                AdvancedSearchView()
            }
            .sheet(
                isPresented: Binding(
                    get: { store.showItemDetail },
                    set: { _ in store.send(.hideItemDetail) }
                )
            ) {
                if let item = store.selectedItem {
                    ItemDetailSheet(item: item)
                }
            }
    }
}

// MARK: - Item Detail Sheet

private struct ItemDetailSheet: View {
    let item: Item

    var body: some View {
        NavigationStack {
            VStack {
                Text("Item Detail")
                    .font(.title)
                Text(item.name)
                    .font(.headline)
                // Add more item detail content here
            }
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss handled by parent
                    }
                }
            }
        }
    }
}

// MARK: - Search Result Formatting

public extension SearchResultRow {
    /// Formats currency values for display
    static func formatCurrency(_ amount: Decimal, code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}
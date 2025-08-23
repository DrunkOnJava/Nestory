//
// Layer: Features
// Module: Search
// Purpose: Toolbar menu components for search interface
//

import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - Search Toolbar Menu

public struct SearchToolbarMenu: View {
    @Bindable var store: StoreOf<SearchFeature>

    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }

    public var body: some View {
        Menu(content: {
            toolbarMenuContent
        }, label: {
            Image(systemName: "ellipsis.circle")
                .accessibilityLabel("Search options")
        })
    }

    @ViewBuilder
    private var toolbarMenuContent: some View {
        advancedSearchButton
        Divider()
        sortOptionsSection
        Divider()
        filterButton
        historyButton
        searchModesSection
    }

    @ViewBuilder
    private var advancedSearchButton: some View {
        Button {
            store.send(.showAdvancedSearch)
        } label: {
            Label("Advanced Search", systemImage: "magnifyingglass.circle.fill")
        }
    }

    @ViewBuilder
    private var sortOptionsSection: some View {
        Section("Sort By") {
            ForEach(SearchFeature.State.SortOption.allCases, id: \.self) { option in
                Button {
                    store.send(.sortOptionChanged(option))
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if store.sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var filterButton: some View {
        Button {
            store.send(.showFilters)
        } label: {
            Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
            if store.hasActiveFilters {
                Text("Active")
            }
        }
    }

    @ViewBuilder
    private var historyButton: some View {
        Button {
            store.send(.showHistory)
        } label: {
            Label("History", systemImage: "clock")
        }
    }

    @ViewBuilder
    private var searchModesSection: some View {
        Section("Search Mode") {
            ForEach(SearchFeature.State.SearchMode.allCases, id: \.self) { mode in
                Button {
                    store.send(.selectSearchMode(mode))
                } label: {
                    HStack {
                        Text(mode.rawValue)
                        if store.searchMode == mode {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Filter Pills Section

public struct FilterPillsSection: View {
    @Bindable var store: StoreOf<SearchFeature>

    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }

    public var body: some View {
        if store.hasActiveFilters || store.hasSearchQuery {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if store.hasSearchQuery {
                        FilterPill(
                            label: "Search: \(store.searchText)",
                            onRemove: { store.send(.clearSearch) }
                        )
                    }
                    
                    if !store.filters.selectedCategories.isEmpty {
                        FilterPill(
                            label: "\(store.filters.selectedCategories.count) Categories",
                            onRemove: { store.send(.clearSpecificFilter(.categories)) }
                        )
                    }
                    
                    if store.filters.priceRange != (0 ... 10000) {
                        FilterPill(
                            label: "$\(Int(store.filters.priceRange?.lowerBound ?? 0))-$\(Int(store.filters.priceRange?.upperBound ?? 10000))",
                            onRemove: { store.send(.clearSpecificFilter(.priceRange)) }
                        )
                    }
                    
                    if hasDocumentationFilters {
                        FilterPill(
                            label: "Documentation",
                            onRemove: { store.send(.clearSpecificFilter(.hasPhoto)) }
                        )
                    }
                    
                    if !store.filters.rooms.isEmpty {
                        FilterPill(
                            label: "\(store.filters.rooms.count) Rooms",
                            onRemove: { store.send(.clearSpecificFilter(.rooms)) }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 44)
            .background(Color(.systemGray6))
        }
    }

    private var hasDocumentationFilters: Bool {
        (store.filters.hasPhoto != nil) || (store.filters.hasReceipt != nil) || (store.filters.hasWarranty != nil) || (store.filters.serialNumberExists != nil)
    }
}
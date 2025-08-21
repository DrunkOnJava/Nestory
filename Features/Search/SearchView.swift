//
// Layer: Features
// Module: Search
// Purpose: TCA-driven Search interface with advanced filtering
//
// 🏗️ TCA SEARCH INTERFACE: Advanced search functionality
// - Sophisticated multi-dimensional filtering using TCA state management
// - Search history and saved searches management
// - Real-time search with debouncing for performance
// - Integration with SearchFeature for coordinated state management
//
// 🎯 INSURANCE FOCUS: Search optimized for insurance documentation
// - Documentation completeness filtering for claim preparation
// - Advanced filtering for insurance category analysis
// - Search history for efficient claim research workflows
//
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with Core Spotlight - Integrate NSUserActivity for search continuation and Handoff
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with SensitiveContentAnalysis - Analyze uploaded photos for potentially sensitive content

import ComposableArchitecture
import Foundation
import SwiftData
import SwiftUI

struct SearchView: View {
    @Bindable var store: StoreOf<SearchFeature>

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                filterPillsSection
                mainContentSection

                // Filter Pills showing active filters
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
                                    label: "$\(Int(store.filters.priceRange.lowerBound))-$\(Int(store.filters.priceRange.upperBound))",
                                    onRemove: { store.send(.clearSpecificFilter(.priceRange)) }
                                )
                            }

                            if store.filters.hasPhoto || store.filters.hasReceipt || store.filters.hasWarranty || store.filters.hasSerialNumber {
                                FilterPill(
                                    label: "Documentation",
                                    onRemove: { store.send(.clearSpecificFilter(.documentation)) }
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

                // Main Content based on search state
                Group {
                    if store.isLoadingResults {
                        ProgressView("Searching...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if !store.hasSearchQuery, !store.hasActiveFilters {
                        // Show search history when no query
                        TCASearchHistoryView(
                            searchHistory: store.searchHistory,
                            savedSearches: store.savedSearches,
                            onHistoryItemSelected: { item in
                                store.send(.selectHistoryItem(item))
                            },
                            onSavedSearchSelected: { saved in
                                store.send(.searchTextChanged(saved.query))
                                store.send(.updateFilters(saved.filters))
                            }
                        )
                    } else {
                        // Show search results
                        TCASearchResultsView(
                            items: store.displayedResults,
                            searchText: store.searchText,
                            totalCount: store.totalResultsCount,
                            hasResults: store.hasResults,
                            summary: store.searchSummary,
                            onItemTapped: { item in
                                store.send(.itemTapped(item))
                            }
                        )
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Sort options
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

                        Divider()

                        // Filter button
                        Button {
                            store.send(.showFilters)
                        } label: {
                            Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                            if store.hasActiveFilters {
                                Text("Active")
                            }
                        }

                        // Search history
                        Button {
                            store.send(.showHistory)
                        } label: {
                            Label("History", systemImage: "clock")
                        }

                        // Search modes
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
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .accessibilityLabel("Search options")
                    }
                }
            }
            .sheet(isPresented: $store.showFiltersSheet) {
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
            .sheet(isPresented: $store.showHistorySheet) {
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
            .sheet(isPresented: $store.showItemDetail) {
                if let item = store.selectedItem {
                    NavigationStack {
                        ItemDetailView(item: item)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("Done") {
                                        store.send(.hideItemDetail)
                                    }
                                }
                            }
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

// MARK: - TCA Search Components

struct TCASearchBarView: View {
    @Binding var text: String
    let isSearching: Bool
    let onCommit: () -> Void

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Search")

                TextField("Search items, categories, notes...", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit(onCommit)

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .accessibilityLabel("Clear search")
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSearching ? Color.accentColor : Color.clear, lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Filter Pill

struct FilterPill: View {
    let label: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .accessibilityLabel("Remove filter")
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.accentColor.opacity(0.1))
        .foregroundColor(.accentColor)
        .cornerRadius(15)
    }
}

// MARK: - TCA Search Results View

struct TCASearchResultsView: View {
    let items: [Item]
    let searchText: String
    let totalCount: Int
    let hasResults: Bool
    let summary: String
    let onItemTapped: (Item) -> Void

    var body: some View {
        VStack {
            // Results summary
            HStack {
                Text(summary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)

            if hasResults {
                List(items, id: \.id) { item in
                    SearchResultRow(item: item) {
                        onItemTapped(item)
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("No items found")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    if !searchText.isEmpty {
                        Text("Try adjusting your search terms or filters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
    }
}

struct SearchResultRow: View {
    let item: Item
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                // Item image or placeholder
                Group {
                    if let imageData = item.imageData,
                       let uiImage = UIImage(data: imageData)
                    {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 50, height: 50)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if let category = item.category {
                        Text(category.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let price = item.purchasePrice {
                        Text(CurrencyUtils.format(price))
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                Spacer()

                // Documentation status indicators
                HStack(spacing: 4) {
                    if item.imageData != nil {
                        Image(systemName: "photo.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    if item.receiptImageData != nil {
                        Image(systemName: "receipt.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                    if item.warrantyExpirationDate != nil {
                        Image(systemName: "shield.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - TCA Search History View

struct TCASearchHistoryView: View {
    let searchHistory: [SearchHistoryItem]
    let savedSearches: [SavedSearch]
    let onHistoryItemSelected: (SearchHistoryItem) -> Void
    let onSavedSearchSelected: (SavedSearch) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !savedSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Saved Searches")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(savedSearches) { saved in
                            Button {
                                onSavedSearchSelected(saved)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(saved.name)
                                            .font(.headline)
                                        Text(saved.query)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }
                    }
                }

                if !searchHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Searches")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(searchHistory.prefix(10)) { item in
                            Button {
                                onHistoryItemSelected(item)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.query)
                                            .font(.headline)
                                        HStack {
                                            Text("\(item.resultCount) results")
                                            Text("•")
                                            Text(item.timestamp.formatted(.relative(presentation: .named)))
                                        }
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.up.left")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }
                    }
                }

                if searchHistory.isEmpty, savedSearches.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)

                        Text("No search history")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("Your recent searches will appear here")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Placeholder TCA Components (to be implemented in separate files)

struct TCASearchFilterView: View {
    let filters: SearchFilters
    let availableCategories: [Category]
    let availableRooms: [String]
    let onFiltersUpdated: (SearchFilters) -> Void
    let onDismiss: () -> Void

    var body: some View {
        Text("TCA Search Filter View - Coming Soon")
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { onDismiss() }
                }
            }
    }
}

struct TCASearchHistorySheet: View {
    let searchHistory: [SearchHistoryItem]
    let savedSearches: [SavedSearch]
    let canSaveSearch: Bool
    let onHistoryItemSelected: (SearchHistoryItem) -> Void
    let onHistoryItemDeleted: (UUID) -> Void
    let onSaveCurrentSearch: (String) -> Void
    let onSavedSearchDeleted: (UUID) -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            Text("TCA Search History Sheet - Coming Soon")
                .navigationTitle("Search History")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Done") { onDismiss() }
                    }
                }
        }
    }
    
    // MARK: - Computed Properties
    
    private var searchBar: some View {
        TCASearchBarView(
            text: $store.searchText.sending(\.searchTextChanged),
            isSearching: store.isLoadingResults,
            onCommit: { store.send(.performSearch) }
        )
    }
    
    private var filterPillsSection: some View {
        Group {
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
                                label: "$\(Int(store.filters.priceRange.lowerBound))-$\(Int(store.filters.priceRange.upperBound))",
                                onRemove: { store.send(.clearSpecificFilter(.priceRange)) }
                            )
                        }
                        
                        if store.filters.hasPhoto || store.filters.hasReceipt || store.filters.hasWarranty || store.filters.hasSerialNumber {
                            FilterPill(
                                label: "Documentation",
                                onRemove: { store.send(.clearSpecificFilter(.documentation)) }
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
    }
    
    private var mainContentSection: some View {
        Group {
            if store.isLoadingResults {
                ProgressView("Searching...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !store.hasSearchQuery, !store.hasActiveFilters {
                TCASearchHistoryView(
                    searchHistory: store.searchHistory,
                    savedSearches: store.savedSearches,
                    onHistoryItemSelected: { item in
                        store.send(.selectHistoryItem(item))
                    },
                    onSavedSearchSelected: { saved in
                        store.send(.searchTextChanged(saved.query))
                        store.send(.updateFilters(saved.filters))
                    }
                )
            } else if store.searchResults.isEmpty {
                TCAEmptySearchView(
                    hasQuery: store.hasSearchQuery,
                    hasFilters: store.hasActiveFilters,
                    onClearAll: { store.send(.clearAllFilters) }
                )
            } else {
                searchResultsList
            }
        }
    }
    
    private var searchResultsList: some View {
        List {
            ForEach(store.searchResults) { item in
                SearchResultRow(item: item) {
                    store.send(.itemSelected(item))
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    SearchView(
        store: Store<SearchFeature.State, SearchFeature.Action>(initialState: SearchFeature.State()) {
            SearchFeature()
        }
    )
}

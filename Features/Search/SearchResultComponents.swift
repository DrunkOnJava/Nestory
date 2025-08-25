//
// Layer: Features
// Module: Search
// Purpose: Search results display components
//

import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - Search Results View

public struct TCASearchResultsView: View {
    let items: [Item]
    let hasResults: Bool
    let summary: String
    let onItemTapped: (Item) -> Void

    public init(
        items: [Item],
        hasResults: Bool,
        summary: String,
        onItemTapped: @escaping (Item) -> Void
    ) {
        self.items = items
        self.hasResults = hasResults
        self.summary = summary
        self.onItemTapped = onItemTapped
    }

    public var body: some View {
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
                .listStyle(.plain)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No Results Found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Try adjusting your search terms or filters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
    }
}

// MARK: - Search Result Row

public struct SearchResultRow: View {
    let item: Item
    let onTap: () -> Void

    public init(item: Item, onTap: @escaping () -> Void) {
        self.item = item
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack {
                // Item image or placeholder
                itemImageView
                
                itemDetailsView
                
                Spacer()
                
                // Documentation status indicators
                documentationIndicators
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var itemImageView: some View {
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
    }

    @ViewBuilder
    private var itemDetailsView: some View {
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
                Text(CurrencyUtils.format(price, currencyCode: item.currency))
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
    }

    @ViewBuilder
    private var documentationIndicators: some View {
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

// MARK: - Search Content Section

public struct SearchContentSection: View {
    @Bindable var store: StoreOf<SearchFeature>

    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }

    public var body: some View {
        if store.isLoadingResults {
            loadingView
        } else if !store.hasSearchQuery && !store.hasActiveFilters {
            historyView
        } else if store.searchResults.isEmpty {
            emptyResultsView
        } else {
            searchResultsList
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        ProgressView("Searching...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var historyView: some View {
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
    }

    @ViewBuilder
    private var emptyResultsView: some View {
        EmptySearchView(
            hasQuery: store.hasSearchQuery,
            hasFilters: store.hasActiveFilters,
            emptyMessage: store.hasSearchQuery ? "No results found" : "Start typing to search",
            onClearAll: { store.send(.clearFilters) }
        )
    }

    @ViewBuilder
    private var searchResultsList: some View {
        List {
            ForEach(store.searchResults) { item in
                SearchResultRow(item: item) {
                    store.send(.itemTapped(item))
                }
            }
        }
        .listStyle(.plain)
    }
}
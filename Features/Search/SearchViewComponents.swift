//
// Layer: Features
// Module: Search
// Purpose: Core UI components for search interface
//

import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - Search Bar Component

public struct TCASearchBarView: View {
    @Binding var text: String
    let isSearching: Bool
    let onCommit: () -> Void
    @FocusState private var isSearchFieldFocused: Bool

    public init(text: Binding<String>, isSearching: Bool, onCommit: @escaping () -> Void) {
        self._text = text
        self.isSearching = isSearching
        self.onCommit = onCommit
    }

    public var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Search")
                
                TextField("Search items, categories, notes...", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isSearchFieldFocused)
                    .onSubmit {
                        isSearchFieldFocused = false
                        onCommit()
                    }
                
                if !text.isEmpty {
                    Button {
                        text = ""
                        isSearchFieldFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .accessibilityLabel("Clear search")
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            if isSearchFieldFocused {
                Button("Cancel") {
                    text = ""
                    isSearchFieldFocused = false
                }
                .foregroundColor(.accentColor)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            
            if isSearching {
                ProgressView()
                    .scaleEffect(0.8)
                    .padding(.leading, 8)
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: isSearchFieldFocused)
        .animation(.easeInOut(duration: 0.2), value: isSearching)
        .onTapGesture {
            // Dismiss keyboard when tapping outside the search field
            if isSearchFieldFocused {
                isSearchFieldFocused = false
            }
        }
    }
}

// MARK: - Filter Pill Component

public struct FilterPill: View {
    let label: String
    let onRemove: () -> Void

    public init(label: String, onRemove: @escaping () -> Void) {
        self.label = label
        self.onRemove = onRemove
    }

    public var body: some View {
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

// MARK: - Empty Search State

public struct EmptySearchView: View {
    let hasQuery: Bool
    let hasFilters: Bool
    let emptyMessage: String
    let onClearAll: () -> Void

    public init(
        hasQuery: Bool,
        hasFilters: Bool,
        emptyMessage: String,
        onClearAll: @escaping () -> Void
    ) {
        self.hasQuery = hasQuery
        self.hasFilters = hasFilters
        self.emptyMessage = emptyMessage
        self.onClearAll = onClearAll
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(emptyMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            if hasFilters {
                Button("Clear All Filters", action: onClearAll)
                    .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Search History Component

public struct TCASearchHistoryView: View {
    let searchHistory: [SearchHistoryItem]
    let savedSearches: [SavedSearch]
    let onHistoryItemSelected: (SearchHistoryItem) -> Void
    let onSavedSearchSelected: (SavedSearch) -> Void

    public init(
        searchHistory: [SearchHistoryItem],
        savedSearches: [SavedSearch],
        onHistoryItemSelected: @escaping (SearchHistoryItem) -> Void,
        onSavedSearchSelected: @escaping (SavedSearch) -> Void
    ) {
        self.searchHistory = searchHistory
        self.savedSearches = savedSearches
        self.onHistoryItemSelected = onHistoryItemSelected
        self.onSavedSearchSelected = onSavedSearchSelected
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !savedSearches.isEmpty {
                    savedSearchSection
                }
                
                if !searchHistory.isEmpty {
                    recentSearchSection
                }
                
                if savedSearches.isEmpty && searchHistory.isEmpty {
                    emptyHistoryView
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private var savedSearchSection: some View {
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
                                .font(.subheadline)
                                .fontWeight(.medium)
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

    @ViewBuilder
    private var recentSearchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Searches")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(searchHistory) { history in
                Button {
                    onHistoryItemSelected(history)
                } label: {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text(history.query)
                            .font(.subheadline)
                        Spacer()
                        Text(history.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    private var emptyHistoryView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Search History")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Your recent searches and saved searches will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
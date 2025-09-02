//
// Layer: Features
// Module: Search
// Purpose: TCA-driven Search interface coordinator
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

// MARK: - Main Search View

public struct SearchView: View {
    @Bindable var store: StoreOf<SearchFeature>

    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }

    public var body: some View {
        navigationView
            .searchSheets(store)
    }

    @ViewBuilder
    private var navigationView: some View {
        NavigationStack {
            searchContentWithModifiers
        }
    }

    @ViewBuilder
    private var searchContentWithModifiers: some View {
        searchContentBase
            .onAppear {
                store.send(.onAppear)
            }
            .alert(store: store.scope(state: \.$alert, action: \.alert))
    }

    @ViewBuilder
    private var searchContentBase: some View {
        mainContent
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                searchToolbar
            }
    }

    private var searchToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            SearchToolbarMenu(store: store)
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            searchBar
            FilterPillsSection(store: store)
            SearchContentSection(store: store)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Dismiss keyboard when tapping anywhere in the search content area
            hideKeyboard()
        }
    }
    
    // Helper function to dismiss keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    @ViewBuilder
    private var searchBar: some View {
        TCASearchBarView(
            text: Binding(
                get: { store.searchText },
                set: { store.send(.searchTextChanged($0)) }
            ),
            isSearching: store.isLoadingResults,
            onCommit: { store.send(.performSearch) }
        )
    }
}

// MARK: - Preview

#Preview {
    SearchView(
        store: Store(initialState: SearchFeature.State()) {
            SearchFeature()
        }
    )
}
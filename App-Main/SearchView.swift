//
//  SearchView.swift
//  Nestory
//
//  Main search interface - modularized version
//

import SwiftData
import SwiftUI

struct SearchView: View {
    @Query private var items: [Item]
    @Query private var categories: [Category]

    @State private var searchText = ""
    @State private var isSearching = false
    @State private var filters = SearchFilters()
    @State private var sortOption: SearchSortOption = .nameAscending
    @State private var searchHistory = SearchHistory()
    @State private var showFilters = false
    @State private var selectedItem: Item?

    @AppStorage("searchHistoryData") private var searchHistoryData = Data()

    var filteredItems: [Item] {
        items.filter { item in
            // Text search
            let matchesSearch = searchText.isEmpty ||
                item.name.localizedCaseInsensitiveContains(searchText) ||
                (item.itemDescription?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (item.notes?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (item.category?.name.localizedCaseInsensitiveContains(searchText) ?? false)

            guard matchesSearch else { return false }

            // Category filter
            if !filters.selectedCategories.isEmpty {
                guard let category = item.category,
                      filters.selectedCategories.contains(category.id)
                else {
                    return false
                }
            }

            // Price filter
            if let price = item.purchasePrice {
                guard filters.priceRange.contains(Double(truncating: price as NSNumber)) else {
                    return false
                }
            }

            // Documentation filters
            if filters.hasPhoto && item.imageData == nil { return false }
            if filters.hasReceipt && item.receiptImageData == nil { return false }
            if filters.hasWarranty && item.warrantyExpirationDate == nil { return false }
            if filters.hasSerialNumber && item.serialNumber == nil { return false }

            // Quantity filter
            if item.quantity < filters.minQuantity || item.quantity > filters.maxQuantity {
                return false
            }

            // Room filter
            if !filters.rooms.isEmpty {
                guard let room = item.room,
                      filters.rooms.contains(room)
                else {
                    return false
                }
            }

            return true
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBarView(
                    text: $searchText,
                    isSearching: $isSearching,
                    onCommit: { performSearch() },
                )

                // Filter Pills
                if filters.isActive || !searchText.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            if !searchText.isEmpty {
                                FilterPill(
                                    label: "Search: \(searchText)",
                                    onRemove: { searchText = "" },
                                )
                            }

                            if !filters.selectedCategories.isEmpty {
                                FilterPill(
                                    label: "\(filters.selectedCategories.count) Categories",
                                    onRemove: { filters.selectedCategories = [] },
                                )
                            }

                            if filters.priceRange != 0 ... 10000 {
                                FilterPill(
                                    label: "$\(Int(filters.priceRange.lowerBound))-$\(Int(filters.priceRange.upperBound))",
                                    onRemove: { filters.priceRange = 0 ... 10000 },
                                )
                            }

                            if filters.hasPhoto || filters.hasReceipt || filters.hasWarranty || filters.hasSerialNumber {
                                FilterPill(
                                    label: "Documentation",
                                    onRemove: {
                                        filters.hasPhoto = false
                                        filters.hasReceipt = false
                                        filters.hasWarranty = false
                                        filters.hasSerialNumber = false
                                    },
                                )
                            }

                            if !filters.rooms.isEmpty {
                                FilterPill(
                                    label: "\(filters.rooms.count) Rooms",
                                    onRemove: { filters.rooms = [] },
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 44)
                    .background(Color(.systemGray6))
                }

                // Main Content
                if !isSearching, searchText.isEmpty, !filters.isActive {
                    // Show search history
                    SearchHistoryView(
                        searchHistory: $searchHistory,
                        searchText: $searchText,
                        onSearch: { term in
                            searchText = term
                            performSearch()
                        },
                    )
                } else {
                    // Show results
                    SearchResultsView(
                        items: filteredItems,
                        searchText: searchText,
                        sortOption: sortOption,
                        selectedItem: $selectedItem,
                    )
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Sort options
                        Section("Sort By") {
                            ForEach(SearchSortOption.allCases, id: \.self) { option in
                                Button(action: { sortOption = option }) {
                                    Label(option.rawValue, systemImage: option.icon)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }

                        Divider()

                        // Filter button
                        Button(action: { showFilters = true }) {
                            Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                            if filters.isActive {
                                Text("Active")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                SearchFilterView(filters: $filters)
            }
            .sheet(item: $selectedItem) { item in
                NavigationStack {
                    ItemDetailView(item: item)
                }
            }
            .onAppear {
                loadSearchHistory()
            }
            .onChange(of: searchHistory) { _, _ in
                saveSearchHistory()
            }
        }
    }

    // MARK: - Private Methods

    private func performSearch() {
        if !searchText.isEmpty {
            searchHistory.addSearch(searchText)
            saveSearchHistory()
        }
        isSearching = false
    }

    private func loadSearchHistory() {
        if let decoded = try? JSONDecoder().decode(SearchHistory.self, from: searchHistoryData) {
            searchHistory = decoded
        }
    }

    private func saveSearchHistory() {
        if let encoded = try? JSONEncoder().encode(searchHistory) {
            searchHistoryData = encoded
        }
    }
}

// MARK: - Search Bar Component

struct SearchBarView: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    let onCommit: () -> Void

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search items, categories, notes...", text: $text, onEditingChanged: { editing in
                    isSearching = editing
                }, onCommit: onCommit)
                    .textFieldStyle(PlainTextFieldStyle())

                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            if isSearching {
                Button("Cancel") {
                    text = ""
                    isSearching = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .transition(.move(edge: .trailing))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .animation(.default, value: isSearching)
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
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.accentColor.opacity(0.1))
        .foregroundColor(.accentColor)
        .cornerRadius(15)
    }
}

#Preview {
    SearchView()
        .modelContainer(for: [Item.self, Category.self], inMemory: true)
}

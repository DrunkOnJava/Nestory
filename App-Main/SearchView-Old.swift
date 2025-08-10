//
//  SearchView.swift
//  Nestory
//

import SwiftData
import SwiftUI

struct SearchView: View {
    @Query private var items: [Item]
    @Query private var categories: [Category]
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var selectedCategories: Set<UUID> = []
    @State private var priceRange: ClosedRange<Double> = 0...10000
    @State private var showFilters = false
    @State private var sortOption: SortOption = .nameAscending
    @State private var recentSearches: [String] = []
    
    @AppStorage("searchHistory") private var searchHistoryData = Data()
    
    enum SortOption: String, CaseIterable {
        case nameAscending = "Name (A-Z)"
        case nameDescending = "Name (Z-A)"
        case priceAscending = "Price (Low to High)"
        case priceDescending = "Price (High to Low)"
        case dateAdded = "Recently Added"
        case quantity = "Quantity"
        
        var icon: String {
            switch self {
            case .nameAscending, .nameDescending: return "textformat"
            case .priceAscending, .priceDescending: return "dollarsign.circle"
            case .dateAdded: return "calendar"
            case .quantity: return "number"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Search Bar
                VStack(spacing: 12) {
                    SearchBar(
                        text: $searchText,
                        isSearching: $isSearching,
                        placeholder: "Search items, categories, notes...",
                        onCommit: {
                            addToRecentSearches(searchText)
                        }
                    )
                    
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "Filters (\(activeFilterCount))",
                                isSelected: showFilters
                            ) {
                                showFilters.toggle()
                            }
                            
                            Divider()
                                .frame(height: 20)
                            
                            ForEach(categories) { category in
                                FilterChip(
                                    title: category.name,
                                    isSelected: selectedCategories.contains(category.id)
                                ) {
                                    toggleCategory(category.id)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Results or Suggestions
                if searchText.isEmpty && !isSearching {
                    // Recent Searches & Suggestions
                    List {
                        if !recentSearches.isEmpty {
                            Section("Recent Searches") {
                                ForEach(recentSearches.prefix(5), id: \.self) { search in
                                    SearchSuggestionRow(
                                        icon: "clock",
                                        title: search,
                                        subtitle: nil
                                    ) {
                                        searchText = search
                                    }
                                }
                            }
                        }
                        
                        Section("Smart Filters") {
                            SearchSuggestionRow(
                                icon: "doc.text.magnifyingglass",
                                title: "Items Missing Documentation",
                                subtitle: "\(itemsNeedingDocumentation.count) items"
                            ) {
                                searchText = "missing:documentation"
                            }
                            
                            SearchSuggestionRow(
                                icon: "dollarsign.circle",
                                title: "High Value Items",
                                subtitle: "Over $100"
                            ) {
                                searchText = "price:>100"
                            }
                            
                            SearchSuggestionRow(
                                icon: "calendar",
                                title: "Recently Added",
                                subtitle: "Last 7 days"
                            ) {
                                searchText = "added:week"
                            }
                            
                            if !itemsWithoutCategory.isEmpty {
                                SearchSuggestionRow(
                                    icon: "questionmark.folder",
                                    title: "Uncategorized",
                                    subtitle: "\(itemsWithoutCategory.count) items"
                                ) {
                                    searchText = "category:none"
                                }
                            }
                        }
                    }
                } else if searchResults.isEmpty {
                    // No Results
                    ContentUnavailableView.search(text: searchText)
                } else {
                    // Search Results
                    List {
                        Section {
                            Picker("Sort by", selection: $sortOption) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Label(option.rawValue, systemImage: option.icon)
                                        .tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        Section("Results (\(searchResults.count))") {
                            ForEach(sortedResults) { item in
                                NavigationLink(destination: ItemDetailView(item: item)) {
                                    SearchResultRow(item: item, searchText: searchText)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showFilters) {
                FilterSettingsView(
                    selectedCategories: $selectedCategories,
                    priceRange: $priceRange,
                    categories: categories
                )
            }
        }
        .onAppear {
            loadRecentSearches()
        }
    }
    
    // MARK: - Computed Properties
    
    private var searchResults: [Item] {
        guard !searchText.isEmpty else { return [] }
        
        // Handle special search syntax
        if searchText.hasPrefix("missing:") {
            return filterByMissingInfo(searchText)
        } else if searchText.hasPrefix("quantity:") {
            return filterByQuantity(searchText)
        } else if searchText.hasPrefix("price:") {
            return filterByPrice(searchText)
        } else if searchText.hasPrefix("category:") {
            return filterBySpecialCategory(searchText)
        } else if searchText.hasPrefix("added:") {
            return filterByDateAdded(searchText)
        }
        
        // Regular text search
        return items.filter { item in
            let matchesText = item.name.localizedCaseInsensitiveContains(searchText) ||
                             (item.itemDescription?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                             (item.notes?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                             (item.brand?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                             (item.category?.name.localizedCaseInsensitiveContains(searchText) ?? false)
            
            let matchesCategory = selectedCategories.isEmpty || 
                                 (item.category != nil && selectedCategories.contains(item.category!.id))
            
            return matchesText && matchesCategory
        }
    }
    
    private var sortedResults: [Item] {
        switch sortOption {
        case .nameAscending:
            return searchResults.sorted { $0.name < $1.name }
        case .nameDescending:
            return searchResults.sorted { $0.name > $1.name }
        case .priceAscending:
            return searchResults.sorted {
                ($0.purchasePrice ?? 0) < ($1.purchasePrice ?? 0)
            }
        case .priceDescending:
            return searchResults.sorted {
                ($0.purchasePrice ?? 0) > ($1.purchasePrice ?? 0)
            }
        case .dateAdded:
            return searchResults.sorted { $0.createdAt > $1.createdAt }
        case .quantity:
            return searchResults.sorted { $0.quantity > $1.quantity }
        }
    }
    
    private var activeFilterCount: Int {
        var count = 0
        if !selectedCategories.isEmpty { count += selectedCategories.count }
        if priceRange != 0...10000 { count += 1 }
        return count
    }
    
    private var itemsNeedingDocumentation: [Item] {
        items.filter { $0.serialNumber == nil || $0.purchasePrice == nil || $0.imageData == nil }
    }
    
    private var itemsWithoutCategory: [Item] {
        items.filter { $0.category == nil }
    }
    
    // MARK: - Helper Methods
    
    private func filterByMissingInfo(_ query: String) -> [Item] {
        let value = query.replacingOccurrences(of: "missing:", with: "")
        switch value {
        case "documentation":
            return items.filter { $0.serialNumber == nil || $0.purchasePrice == nil || $0.imageData == nil }
        case "photo":
            return items.filter { $0.imageData == nil }
        case "price":
            return items.filter { $0.purchasePrice == nil }
        case "serial":
            return items.filter { $0.serialNumber == nil }
        default:
            return []
        }
    }
    
    private func filterByQuantity(_ query: String) -> [Item] {
        let value = query.replacingOccurrences(of: "quantity:", with: "")
        if value.hasPrefix("=") {
            if let exactCount = Int(value.dropFirst()) {
                return items.filter { $0.quantity == exactCount }
            }
        } else if value.hasPrefix(">") {
            if let threshold = Int(value.dropFirst()) {
                return items.filter { $0.quantity > threshold }
            }
        }
        return []
    }
    
    private func filterByPrice(_ query: String) -> [Item] {
        let value = query.replacingOccurrences(of: "price:", with: "")
        if value.hasPrefix(">") {
            if let threshold = Decimal(string: String(value.dropFirst())) {
                return items.filter { ($0.purchasePrice ?? 0) > threshold }
            }
        } else if value.hasPrefix("<") {
            if let threshold = Decimal(string: String(value.dropFirst())) {
                return items.filter { ($0.purchasePrice ?? 0) < threshold }
            }
        }
        return []
    }
    
    private func filterBySpecialCategory(_ query: String) -> [Item] {
        let value = query.replacingOccurrences(of: "category:", with: "")
        if value == "none" {
            return itemsWithoutCategory
        }
        return []
    }
    
    private func filterByDateAdded(_ query: String) -> [Item] {
        let value = query.replacingOccurrences(of: "added:", with: "")
        let calendar = Calendar.current
        let now = Date()
        
        switch value {
        case "today":
            return items.filter { calendar.isDateInToday($0.createdAt) }
        case "week":
            if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) {
                return items.filter { $0.createdAt > weekAgo }
            }
        case "month":
            if let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) {
                return items.filter { $0.createdAt > monthAgo }
            }
        default:
            break
        }
        return []
    }
    
    private func toggleCategory(_ id: UUID) {
        if selectedCategories.contains(id) {
            selectedCategories.remove(id)
        } else {
            selectedCategories.insert(id)
        }
    }
    
    private func addToRecentSearches(_ search: String) {
        guard !search.isEmpty else { return }
        recentSearches.removeAll { $0 == search }
        recentSearches.insert(search, at: 0)
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        saveRecentSearches()
    }
    
    private func loadRecentSearches() {
        if let searches = try? JSONDecoder().decode([String].self, from: searchHistoryData) {
            recentSearches = searches
        }
    }
    
    private func saveRecentSearches() {
        if let data = try? JSONEncoder().encode(recentSearches) {
            searchHistoryData = data
        }
    }
}

// MARK: - Search Result Row
struct SearchResultRow: View {
    let item: Item
    let searchText: String
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageData = item.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    if let category = item.category {
                        Label(category.name, systemImage: category.icon)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let price = item.purchasePrice {
                        Text("$\(price)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Qty: \(item.quantity)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let match = highlightedMatch(for: item) {
                    Text(match)
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func highlightedMatch(for item: Item) -> String? {
        if item.itemDescription?.localizedCaseInsensitiveContains(searchText) ?? false {
            return "in description"
        } else if item.notes?.localizedCaseInsensitiveContains(searchText) ?? false {
            return "in notes"
        } else if item.brand?.localizedCaseInsensitiveContains(searchText) ?? false {
            return "in brand"
        }
        return nil
    }
}

// MARK: - Filter Settings View
struct FilterSettingsView: View {
    @Binding var selectedCategories: Set<UUID>
    @Binding var priceRange: ClosedRange<Double>
    let categories: [Category]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Categories") {
                    ForEach(categories) { category in
                        let isSelected = selectedCategories.contains(category.id)
                        let categoryColor = Color(hex: category.colorHex) ?? .accentColor
                        
                        HStack {
                            Label(category.name, systemImage: category.icon)
                                .foregroundColor(categoryColor)
                            
                            Spacer()
                            
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isSelected {
                                selectedCategories.remove(category.id)
                            } else {
                                selectedCategories.insert(category.id)
                            }
                        }
                    }
                }
                
                Section("Price Range") {
                    VStack {
                        HStack {
                            Text("$\(Int(priceRange.lowerBound))")
                            Spacer()
                            Text("$\(Int(priceRange.upperBound))")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        Text("Price filtering coming soon")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Clear All Filters") {
                        selectedCategories.removeAll()
                        priceRange = 0...10000
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            })
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(for: [Item.self, Category.self], inMemory: true)
}
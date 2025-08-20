//
// Layer: App
// Module: AdvancedSearchView
// Purpose: Advanced search and filtering interface
//

import SwiftUI
import SwiftData

struct AdvancedSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AdvancedSearchViewModel
    @State private var showingFilters = false
    
    init() {
        // Initialize with placeholder, will be updated in onAppear
        self._viewModel = State(initialValue: AdvancedSearchViewModel(inventoryService: MockInventoryService()))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search header
                searchHeader
                
                // Filter summary
                if viewModel.hasActiveFilters {
                    filterSummaryView
                }
                
                // Results
                searchResultsList
            }
            .navigationTitle("Advanced Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Filters") {
                        showingFilters = true
                    }
                    .overlay(
                        // Filter indicator badge
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(x: 8, y: -8)
                            .opacity(viewModel.hasActiveFilters ? 1 : 0)
                    )
                }
            }
            .sheet(isPresented: $showingFilters) {
                AdvancedFilterSheet(viewModel: viewModel)
            }
            .onAppear {
                setupViewModel()
            }
        }
    }
    
    // MARK: - Views
    
    private var searchHeader: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Search items...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        Task {
                            await viewModel.performAdvancedSearch()
                        }
                    }
                
                Button("Search") {
                    Task {
                        await viewModel.performAdvancedSearch()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isSearching)
            }
            
            // Sort picker
            Picker("Sort by", selection: $viewModel.sortOption) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
    
    private var filterSummaryView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Label("Active Filters:", systemImage: "line.3.horizontal.decrease.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(viewModel.filterSummary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Button("Clear") {
                    viewModel.clearFilters()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    private var searchResultsList: some View {
        Group {
            if viewModel.isSearching {
                ProgressView("Searching...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.searchResults.isEmpty && viewModel.hasActiveFilters {
                EmptyStateView(
                    title: "🔍 No Results",
                    message: "No items match your search criteria. Try adjusting your filters.",
                    systemImage: "magnifyingglass",
                    actionTitle: "Clear Filters"
                ) {
                    viewModel.clearFilters()
                }
            } else if viewModel.searchResults.isEmpty {
                EmptyStateView(
                    title: "🔍 Start Searching",
                    message: "Enter search terms or apply filters to find your items.",
                    systemImage: "magnifyingglass",
                    actionTitle: nil
                ) { }
            } else {
                List {
                    Section {
                        ForEach(viewModel.searchResults) { item in
                            NavigationLink(destination: ItemDetailView(item: item)) {
                                SearchResultRow(item: item)
                            }
                        }
                    } header: {
                        Text("\(viewModel.searchResults.count) Results")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .alert("Search Error", isPresented: .constant(viewModel.searchError != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.searchError ?? "")
        }
    }
    
    // MARK: - Helpers
    
    private func setupViewModel() {
        do {
            let service = try LiveInventoryService(modelContext: modelContext)
            viewModel = AdvancedSearchViewModel(inventoryService: service)
            
            Task {
                await viewModel.loadCategories()
            }
        } catch {
            // Keep the mock service if initialization fails
            print("Failed to initialize InventoryService: \(error)")
        }
    }
}

// MARK: - Search Result Row

struct SearchResultRow: View {
    let item: Item
    
    var body: some View {
        HStack(spacing: 12) {
            // Item image or placeholder
            Group {
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
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
                    
                    Spacer()
                    
                    if let price = item.purchasePrice {
                        Text(NumberFormatter.currency.string(from: NSDecimalNumber(decimal: price)) ?? "")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Spacer()
            
            // Documentation indicators
            VStack(spacing: 2) {
                if item.imageData != nil {
                    Image(systemName: "photo.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                
                if item.receiptImageData != nil {
                    Image(systemName: "receipt.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
                
                if item.warrantyExpirationDate != nil {
                    Image(systemName: "shield.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Advanced Filter Sheet

struct AdvancedFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: AdvancedSearchViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        Text("All Categories").tag(Category?.none)
                        ForEach(viewModel.availableCategories) { category in
                            Label(category.name, systemImage: category.icon)
                                .tag(Category?.some(category))
                        }
                    }
                }
                
                Section("Price Range") {
                    HStack {
                        TextField("Min Price", text: $viewModel.minPrice)
                            .keyboardType(.decimalPad)
                        Text("to")
                        TextField("Max Price", text: $viewModel.maxPrice)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section("Condition") {
                    Picker("Condition", selection: $viewModel.condition) {
                        Text("Any Condition").tag("")
                        Text("Excellent").tag("excellent")
                        Text("Good").tag("good")
                        Text("Fair").tag("fair")
                        Text("Poor").tag("poor")
                    }
                }
                
                Section("Documentation") {
                    HStack {
                        Text("Has Warranty")
                        Spacer()
                        Picker("Warranty", selection: $viewModel.hasWarranty) {
                            Text("Any").tag(Bool?.none)
                            Text("Yes").tag(Bool?.some(true))
                            Text("No").tag(Bool?.some(false))
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                    }
                    
                    HStack {
                        Text("Has Receipt")
                        Spacer()
                        Picker("Receipt", selection: $viewModel.hasReceipt) {
                            Text("Any").tag(Bool?.none)
                            Text("Yes").tag(Bool?.some(true))
                            Text("No").tag(Bool?.some(false))
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                    }
                    
                    HStack {
                        Text("Has Photo")
                        Spacer()
                        Picker("Photo", selection: $viewModel.hasPhoto) {
                            Text("Any").tag(Bool?.none)
                            Text("Yes").tag(Bool?.some(true))
                            Text("No").tag(Bool?.some(false))
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                    }
                }
                
                Section("Location") {
                    TextField("Room or Location", text: $viewModel.location)
                }
            }
            .navigationTitle("Search Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        viewModel.clearFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        Task {
                            await viewModel.performAdvancedSearch()
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Mock Service

private struct MockInventoryService: InventoryService {
    nonisolated func fetchItems() async throws -> [Item] { [] }
    nonisolated func fetchItem(id: UUID) async throws -> Item? { nil }
    nonisolated func saveItem(_ item: Item) async throws {}
    nonisolated func updateItem(_ item: Item) async throws {}
    nonisolated func deleteItem(id: UUID) async throws {}
    nonisolated func searchItems(query: String) async throws -> [Item] { [] }
    nonisolated func fetchCategories() async throws -> [Category] { [] }
    nonisolated func saveCategory(_ category: Category) async throws {}
    nonisolated func assignItemToCategory(itemId: UUID, categoryId: UUID) async throws {}
    nonisolated func fetchItemsByCategory(categoryId: UUID) async throws -> [Item] { [] }
    
    // Batch Operations
    nonisolated func bulkImport(items: [Item]) async throws {}
    nonisolated func bulkUpdate(items: [Item]) async throws {}
    nonisolated func bulkDelete(itemIds: [UUID]) async throws {}
    nonisolated func bulkSave(items: [Item]) async throws {}
    nonisolated func bulkAssignCategory(itemIds: [UUID], categoryId: UUID) async throws {}
    
    nonisolated func exportInventory(format: ExportFormat) async throws -> Data { Data() }
}

// MARK: - Extensions

extension NumberFormatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
}

#Preview {
    AdvancedSearchView()
        .modelContainer(for: Item.self, inMemory: true)
}
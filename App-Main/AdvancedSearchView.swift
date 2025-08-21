//
// Layer: App
// Module: AdvancedSearchView
// Purpose: Advanced search and filtering interface
//

import SwiftData
import SwiftUI

struct AdvancedSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AdvancedSearchViewModel
    @State private var showingFilters = false

    init() {
        // Initialize with placeholder, will be updated in onAppear
        _viewModel = State(initialValue: AdvancedSearchViewModel(inventoryService: MockInventoryService()))
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
                            .opacity(viewModel.hasActiveFilters ? 1 : 0),
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
            } else if viewModel.searchResults.isEmpty, viewModel.hasActiveFilters {
                EmptyStateView(
                    title: "🔍 No Results",
                    message: "No items match your search criteria. Try adjusting your filters.",
                    systemImage: "magnifyingglass",
                    actionTitle: "Clear Filters",
                ) {
                    viewModel.clearFilters()
                }
            } else if viewModel.searchResults.isEmpty {
                EmptyStateView(
                    title: "🔍 Start Searching",
                    message: "Enter search terms or apply filters to find your items.",
                    systemImage: "magnifyingglass",
                    actionTitle: nil,
                ) {}
            } else {
                List {
                    Section {
                        ForEach(viewModel.searchResults) { item in
                            NavigationLink(destination: ItemDetailView(item: item)) {
                                SearchResultRow(item: item) {
                                    // Navigation handled by NavigationLink wrapper
                                }
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

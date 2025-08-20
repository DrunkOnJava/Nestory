// Layer: App
// Module: InventoryListView
// Purpose: Main inventory list and item browsing

import SwiftData
import SwiftUI

// MARK: - Mock Service for Initialization

private struct MockInventoryService: InventoryService {
    nonisolated func fetchItems() async throws -> [Item] { [] }
    nonisolated func fetchItem(id _: UUID) async throws -> Item? { nil }
    nonisolated func saveItem(_: Item) async throws {}
    nonisolated func updateItem(_: Item) async throws {}
    nonisolated func deleteItem(id _: UUID) async throws {}
    nonisolated func searchItems(query _: String) async throws -> [Item] { [] }
    nonisolated func fetchCategories() async throws -> [Category] { [] }
    nonisolated func saveCategory(_: Category) async throws {}
    nonisolated func assignItemToCategory(itemId _: UUID, categoryId _: UUID) async throws {}
    nonisolated func fetchItemsByCategory(categoryId _: UUID) async throws -> [Item] { [] }

    // Batch Operations
    nonisolated func bulkImport(items _: [Item]) async throws {}
    nonisolated func bulkUpdate(items _: [Item]) async throws {}
    nonisolated func bulkDelete(itemIds _: [UUID]) async throws {}
    nonisolated func bulkSave(items _: [Item]) async throws {}
    nonisolated func bulkAssignCategory(itemIds _: [UUID], categoryId _: UUID) async throws {}

    nonisolated func exportInventory(format _: ExportFormat) async throws -> Data { Data() }
}

struct InventoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: InventoryListViewModel
    @State private var showingAddItem = false

    init() {
        // Initialize with placeholder, will be updated in onAppear
        _viewModel = State(initialValue: InventoryListViewModel(inventoryService: MockInventoryService()))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredItems) { item in
                    NavigationLink(destination: ItemDetailView(item: item)) {
                        ItemRowView(item: item)
                    }
                }
                .onDelete { indexSet in
                    Task {
                        await viewModel.deleteItems(at: indexSet)
                    }
                }
            }
            .navigationTitle("My Items")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search your stuff...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView()
            }
            .overlay {
                if viewModel.isEmpty {
                    EmptyStateView(
                        title: "📦 Empty Inventory",
                        message: "Add your first item to get started!",
                        systemImage: "shippingbox",
                        actionTitle: "Add First Item",
                    ) { showingAddItem = true }
                } else if viewModel.isLoading {
                    ProgressView("Loading items...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(UIColor.systemBackground))
                }
            }
            .alert("Error", isPresented: .constant(viewModel.showingError)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
            .refreshable {
                await viewModel.refreshData()
            }
            .onAppear {
                // Initialize viewModel with proper ModelContext
                viewModel = InventoryListViewModel.create(from: modelContext)
                Task {
                    await viewModel.refreshData()
                }
            }
        }
    }

    // Removed filteredItems and deleteItems - now handled by ViewModel
}

struct ItemRowView: View {
    let item: Item

    var body: some View {
        HStack(spacing: 12) {
            Text("🆕")
            // Category color indicator
            if let category = item.category {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: category.colorHex) ?? .gray)
                    .frame(width: 4)
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

                    Spacer()

                    Text("Qty: \(item.quantity)")
                        .font(.caption)
                        .foregroundColor(item.quantity > 5 ? .green : item.quantity > 0 ? .orange : .red)
                        .fontWeight(.medium)
                }
            }

            Spacer()

            // Documentation status badge
            if item.imageData != nil && item.purchasePrice != nil && item.serialNumber != nil {
                Image(systemName: "checkmark.shield.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            } else if item.imageData != nil || item.purchasePrice != nil || item.serialNumber != nil {
                Image(systemName: "doc.badge.ellipsis")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    InventoryListView()
        .modelContainer(for: Item.self, inMemory: true)
}

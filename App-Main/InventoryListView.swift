// Layer: App
// Module: InventoryListView
// Purpose: Main inventory list and item browsing
//
// 🏗️ TRANSITION VIEW: Current MVVM → Future TCA
// - Currently uses InventoryListViewModel (@StateObject pattern)
// - PLANNED: Will migrate to TCA InventoryFeature in Part 2
// - Should NOT add new business logic here - that belongs in Features layer
// - Focus on UI presentation and navigation coordination
//
// 🎯 INSURANCE FOCUS: Home inventory browsing and documentation
// - Comprehensive item listing with search and filtering
// - Documentation status indicators (missing photos, receipts, serials)
// - Bulk insurance claim generation workflows
// - Quick access to item detail documentation
//
// 📱 UI PATTERNS: Standard iOS list interface
// - NavigationStack for hierarchical navigation
// - SearchableModifier for real-time search
// - SwipeActions for item management
// - Sheet presentations for modal workflows
// - RefreshableModifier for pull-to-refresh
//
// 🔄 TCA MIGRATION STATUS:
// - Part 1: Keep current implementation working
// - Part 2: Replace InventoryListViewModel with InventoryFeature.State
// - Part 2: Replace @State with TCA Store
// - Part 2: Replace async Task calls with TCA Actions
//
// 🍎 APPLE FRAMEWORK OPPORTUNITIES (Phase 3):
// - Core Spotlight: System-wide item search integration
// - AppIntents: "Hey Siri, show my electronics" voice commands
// - WidgetKit: Home screen inventory summary widgets
//

import SwiftData
import SwiftUI
import ComposableArchitecture

// Note: MockInventoryService is now available from DependencyKeys

struct InventoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: InventoryListViewModel
    @State private var showingAddItem = false
    @State private var showingBulkClaim = false
    @State private var selectedItems: Set<Item> = []
    @State private var isSelectionMode = false

    init() {
        // Initialize with dependency-injected service
        @Dependency(\.inventoryService) var inventoryService
        _viewModel = State(initialValue: InventoryListViewModel(inventoryService: inventoryService))
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
                ToolbarItem(placement: .navigationBarLeading) {
                    if !viewModel.isEmpty {
                        Menu {
                            Button("Generate Bulk Insurance Claim") {
                                selectedItems = Set(viewModel.filteredItems)
                                showingBulkClaim = true
                            }

                            Button("Select Items for Claim") {
                                isSelectionMode = true
                            }
                        } label: {
                            Label("Bulk Actions", systemImage: "ellipsis.circle")
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView(store: Store(initialState: AddItemFeature.State()) {
                    AddItemFeature()
                })
            }
            .sheet(isPresented: $showingBulkClaim) {
                InsuranceClaimView(items: Array(selectedItems))
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

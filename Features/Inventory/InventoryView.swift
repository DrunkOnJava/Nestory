//
// Layer: Features
// Module: Inventory
// Purpose: Inventory List View
//

import ComposableArchitecture
import SwiftUI

struct InventoryView: View {
    @Bindable var store: StoreOf<InventoryFeature>

    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            Group {
                if store.isLoading, store.items.isEmpty {
                    InventoryLoadingView()
                } else if store.filteredItems.isEmpty {
                    if store.searchText.isEmpty, store.selectedCategory == nil {
                        EmptyInventoryView(
                            title: "No Items",
                            message: "Start by adding your first item to the inventory",
                            systemImage: "archivebox"
                        ) {
                            store.send(.addItemTapped)
                        }
                    } else {
                        EmptyInventoryView(
                            title: "No Results",
                            message: "Try adjusting your search or filters",
                            systemImage: "magnifyingglass"
                        )
                    }
                } else {
                    List {
                        ForEach(store.filteredItems) { item in
                            ItemRow(item: item) {
                                store.send(.itemTapped(item))
                            }
                            .listRowInsets(EdgeInsets(
                                top: 8,
                                leading: 16,
                                bottom: 8,
                                trailing: 16
                            ))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete { indexSet in
                            store.send(.deleteItems(indexSet))
                        }
                    }
                    .listStyle(.plain)
                    .searchable(
                        text: $store.searchText.sending(\.searchTextChanged),
                        prompt: "Search items, categories, or locations"
                    )
                }
            }
            .navigationTitle("Inventory")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.send(.addItemTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                if !store.items.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        } destination: { store in
            switch store.case {
            case let .itemDetail(store):
                ItemDetailView(store: store)
            case let .itemEdit(store):
                ItemEditView(store: store)
            }
        }
    }
}

// MARK: - Supporting Views

private struct InventoryLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading inventory...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct EmptyInventoryView: View {
    let title: String
    let message: String
    let systemImage: String
    var action: (() -> Void)? = nil

    init(title: String, message: String, systemImage: String, action: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }

            if let action {
                Button("Add Item", action: action)
                    .buttonStyle(.bordered)
                    .foregroundColor(.accentColor)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Placeholder Child Views

private struct ItemDetailView: View {
    let store: StoreOf<ItemDetailFeature>

    var body: some View {
        Text("Item Detail - Coming Soon")
            .navigationTitle("Item Details")
    }
}

private struct ItemEditView: View {
    let store: StoreOf<ItemEditFeature>

    var body: some View {
        Text("Item Edit - Coming Soon")
            .navigationTitle("Edit Item")
    }
}

// MARK: - Item Row

struct ItemRow: View {
    let item: Item
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon based on category
                Image(systemName: iconForCategory(item.category?.name))
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        if item.quantity > 1 {
                            Text("×\(item.quantity)")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }

                    HStack(spacing: 8) {
                        if let category = item.category {
                            Label(category.name, systemImage: "folder")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if let location = item.location {
                            Label(location, systemImage: "location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    // Price
                    if let price = item.purchasePrice {
                        Text(formatPrice(price))
                            .font(.headline)
                            .foregroundColor(.primary)
                    }

                    // Documentation status
                    HStack(spacing: 4) {
                        Circle()
                            .fill(item.hasCompleteDocumentation ? .green : .orange)
                            .frame(width: 8, height: 8)

                        Text(item.hasCompleteDocumentation ? "Complete" : "Incomplete")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.tertiary)
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private func iconForCategory(_ category: String?) -> String {
        switch category?.lowercased() {
        case "electronics": "desktopcomputer"
        case "furniture": "chair"
        case "clothing": "tshirt"
        case "books": "book"
        case "kitchen": "fork.knife"
        case "tools": "wrench.and.screwdriver"
        default: "shippingbox"
        }
    }

    private func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: price as NSNumber) ?? "$0.00"
    }
}

// MARK: - Item Extensions

extension Item {
    /// Computed property to check if item has complete documentation
    var hasCompleteDocumentation: Bool {
        // Check for essential documentation elements for insurance purposes
        let hasImage = imageData != nil
        let hasReceipt = receiptImageData != nil || !receipts.isEmpty
        let hasSerial = serialNumber != nil && !serialNumber!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasPurchaseInfo = purchasePrice != nil && purchaseDate != nil

        return hasImage && (hasReceipt || hasPurchaseInfo) && hasSerial
    }
}

#Preview {
    InventoryView(
        store: Store(initialState: InventoryFeature.State()) {
            InventoryFeature()
        },
    )
}

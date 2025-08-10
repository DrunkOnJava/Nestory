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
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            Group {
                if store.isLoading, store.items.isEmpty {
                    LoadingView(message: "Loading inventory...")
                } else if store.filteredItems.isEmpty {
                    if store.searchText.isEmpty, store.selectedCategory == nil {
                        EmptyStateView(
                            title: "No Items",
                            message: "Start by adding your first item to the inventory",
                            systemImage: "archivebox",
                            actionTitle: "Add Item"
                        ) {
                            store.send(.addItemTapped)
                        }
                    } else {
                        EmptyStateView(
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
                                top: Theme.Spacing.sm,
                                leading: Theme.Spacing.md,
                                bottom: Theme.Spacing.sm,
                                trailing: Theme.Spacing.md
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
            switch store.state {
            case .itemDetail:
                if let store = store.scope(state: \.itemDetail, action: \.itemDetail) {
                    ItemDetailView(store: store)
                }
            case .itemEdit:
                if let store = store.scope(state: \.itemEdit, action: \.itemEdit) {
                    ItemEditView(store: store)
                }
            }
        }
    }
}

// MARK: - Item Row

struct ItemRow: View {
    let item: InventoryItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                // Icon
                Image(systemName: iconForCategory(item.category))
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.md)

                // Content
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    HStack {
                        Text(item.name)
                            .font(Typography.headline())
                            .foregroundColor(.primaryText)
                            .lineLimit(1)

                        if item.quantity > 1 {
                            BadgeView(text: "×\(item.quantity)", style: .info)
                        }
                    }

                    HStack(spacing: Theme.Spacing.sm) {
                        if let category = item.category {
                            Label(category, systemImage: "folder")
                                .font(Typography.caption())
                                .foregroundColor(.secondaryText)
                        }

                        if let location = item.location {
                            Label(location, systemImage: "location")
                                .font(Typography.caption())
                                .foregroundColor(.secondaryText)
                        }
                    }
                }

                Spacer()

                // Price
                if let price = item.price {
                    Text(formatPrice(price))
                        .font(Typography.headline())
                        .foregroundColor(.primaryText)
                }

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.tertiaryText)
            }
            .padding(Theme.Spacing.md)
            .background(Color.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.lg)
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

#Preview {
    InventoryView(
        store: Store(initialState: InventoryFeature.State()) {
            InventoryFeature()
        }
    )
}

//
//  InventoryListView.swift
//  Nestory
//

import SwiftData
import SwiftUI

struct InventoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var showingAddItem = false
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredItems) { item in
                    NavigationLink(destination: ItemDetailView(item: item)) {
                        ItemRowView(item: item)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Inventory")
            .searchable(text: $searchText, prompt: "Search items")
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
                if items.isEmpty {
                    EmptyStateView(
                        title: "No Items Yet",
                        message: "Start organizing your belongings by adding your first item",
                        systemImage: "shippingbox",
                        actionTitle: "Add First Item",
                        action: { showingAddItem = true }
                    )
                }
            }
        }
    }

    private var filteredItems: [Item] {
        if searchText.isEmpty {
            items
        } else {
            items.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

struct ItemRowView: View {
    let item: Item

    var body: some View {
        HStack(spacing: 12) {
            // Category color indicator
            if let category = item.category {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(category.colorHex) ?? .gray)
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

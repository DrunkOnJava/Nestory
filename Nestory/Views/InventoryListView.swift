//
//  InventoryListView.swift
//  Nestory
//
//  Created by Assistant on 8/9/25.
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
            VStack {
                if items.isEmpty {
                    ContentUnavailableView(
                        "No Items",
                        systemImage: "shippingbox",
                        description: Text("Tap + to add your first item")
                    )
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: ItemDetailView(item: item)) {
                                ItemRowView(item: item)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .searchable(text: $searchText, prompt: "Search items")
                }
            }
            .navigationTitle("Inventory")
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
        }
    }

    private var filteredItems: [Item] {
        if searchText.isEmpty {
            items
        } else {
            items.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                    (item.itemDescription ?? "").localizedCaseInsensitiveContains(searchText)
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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(Color.theme.text)
                Text(item.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("\(item.quantity)")
                    .font(.headline)
                    .foregroundColor(Color.theme.text)
                Text("Quantity")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
            }
        }
        .padding()
        .background(Color.theme.itemRowBackground)
        .cornerRadius(10)
        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.05), radius: 2)
    }
}

#Preview {
    InventoryListView()
        .modelContainer(for: Item.self, inMemory: true)
}

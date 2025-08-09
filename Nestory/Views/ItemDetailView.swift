//
//  ItemDetailView.swift
//  Nestory
//
//  Created by Assistant on 8/9/25.
//

import SwiftData
import SwiftUI

struct ItemDetailView: View {
    @Bindable var item: Item
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .center, spacing: 12) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)

                    Text(item.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.text)

                    Text("Added \(item.createdAt, style: .date)")
                        .font(.caption)
                        .foregroundColor(Color.theme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.theme.secondaryBackground)
                .cornerRadius(12)

                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(label: "Description", value: "Item description goes here")
                    DetailRow(label: "Quantity", value: "1")
                    DetailRow(label: "Location", value: "Not specified")
                    DetailRow(label: "Category", value: "General")
                    DetailRow(label: "Purchase Price", value: "Not specified")
                }
                .padding()
                .background(Color.theme.cardBackground)
                .cornerRadius(12)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)
                        .foregroundColor(Color.theme.text)
                    Text("No notes added yet")
                        .foregroundColor(Color.theme.secondaryText)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.theme.cardBackground)
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditItemView(item: item)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.semibold)
                .foregroundColor(Color.theme.secondaryText)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
                .foregroundColor(Color.theme.text)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        let item = try Item(name: "Preview Item", description: "Sample description", quantity: 1)

        return NavigationStack {
            ItemDetailView(item: item)
        }
        .modelContainer(container)
    } catch {
        return Text("Error creating preview")
    }
}

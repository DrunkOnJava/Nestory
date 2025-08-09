//
//  EditItemView.swift
//  Nestory
//
//  Created by Assistant on 8/9/25.
//

import SwiftData
import SwiftUI

struct EditItemView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss

    @State private var itemName = "Item Name"
    @State private var itemDescription = ""
    @State private var quantity = 1
    @State private var location = ""
    @State private var category = "General"
    @State private var purchasePrice = ""
    @State private var notes = ""

    let categories = ["General", "Electronics", "Furniture", "Clothing", "Books", "Kitchen", "Tools", "Sports", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Item Name", text: $itemName)
                    TextField("Description", text: $itemDescription, axis: .vertical)
                        .lineLimit(3 ... 6)

                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1 ... 999)
                }

                Section("Location & Category") {
                    TextField("Location", text: $location)

                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                }

                Section("Additional Details") {
                    TextField("Purchase Price", text: $purchasePrice)
                        .keyboardType(.decimalPad)

                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3 ... 6)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
        }
    }

    private func saveChanges() {
        dismiss()
    }
}

#Preview {
    do {
        let item = try Item(name: "Preview Item", description: "Sample description", quantity: 1)
        return EditItemView(item: item)
            .modelContainer(for: Item.self, inMemory: true)
    } catch {
        return Text("Error creating preview item")
    }
}

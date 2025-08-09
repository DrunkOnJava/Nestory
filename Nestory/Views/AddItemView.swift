//
//  AddItemView.swift
//  Nestory
//
//  Created by Assistant on 8/9/25.
//

import SwiftData
import SwiftUI

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var itemName = ""
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
                    TextField("Location (e.g., Living Room, Garage)", text: $location)

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
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(itemName.isEmpty)
                }
            }
        }
    }

    private func saveItem() {
        do {
            let newItem = try Item(
                name: itemName,
                description: itemDescription.isEmpty ? nil : itemDescription,
                quantity: quantity
            )

            if !purchasePrice.isEmpty, let price = Double(purchasePrice) {
                newItem.purchasePrice = try? Money(amount: Decimal(price), currencyCode: "USD")
            }

            if !notes.isEmpty {
                newItem.notes = notes
            }

            modelContext.insert(newItem)
            dismiss()
        } catch {
            print("Error saving item: \(error)")
        }
    }
}

#Preview {
    AddItemView()
        .modelContainer(for: Item.self, inMemory: true)
}

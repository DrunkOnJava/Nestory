//
// Layer: Features
// Module: Inventory
// Purpose: Inventory List View
//

import ComposableArchitecture
import SwiftUI

// Import the actual ItemDetailView from App-Main layer
import SwiftData

public struct InventoryView: View {
    @Bindable var store: StoreOf<InventoryFeature>

    private var mainContent: some View {
        Group {
            if store.isLoading, store.items.isEmpty {
                InventoryLoadingView()
            } else if store.filteredItems.isEmpty {
                emptyStateView
            } else {
                inventoryList
            }
        }
    }
    
    private var emptyStateView: some View {
        Group {
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
        }
    }
    
    private var inventoryList: some View {
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
    }

    public var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            mainContent
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
        } destination: { store in
            switch store.state {
            case .itemDetail:
                ItemDetailView(item: store.state.itemDetail.item)
            case .itemEdit:
                ItemEditView(store: store.scope(state: \.itemEdit, action: \.itemEdit))
            }
        }
        .searchable(
            text: $store.searchText.sending(\.searchTextChanged),
            prompt: "Search items, categories, or locations"
        )
        .alert(store: store.scope(state: \.$alert, action: \.alert))
        .onAppear {
            store.send(.onAppear)
        }
        .refreshable {
            await store.send(.loadItems).finish()
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

// MARK: - Child Views

private struct ItemDetailPlaceholderView: View {
    let store: StoreOf<ItemDetailFeature>
    
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 20) {
                // Item Image
                if let imageData = store.item.imageData,
                   let uiImage = UIImage(data: imageData)
                {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .padding(.horizontal)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                Text("No Image")
                                    .foregroundColor(.secondary)
                            }
                        )
                        .padding(.horizontal)
                }

                // Item Information
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text(store.item.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        if let description = store.item.itemDescription, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Purchase Information
                    GroupBox("Purchase Details") {
                        VStack(alignment: .leading, spacing: 8) {
                            if let price = store.item.purchasePrice {
                                HStack {
                                    Text("Purchase Price")
                                    Spacer()
                                    Text(formatPrice(price))
                                        .fontWeight(.semibold)
                                }
                            }
                            
                            if let date = store.item.purchaseDate {
                                HStack {
                                    Text("Purchase Date")
                                    Spacer()
                                    Text(date.formatted(date: .abbreviated, time: .omitted))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if let brand = store.item.brand, !brand.isEmpty {
                                HStack {
                                    Text("Brand")
                                    Spacer()
                                    Text(brand)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    // Location Information
                    if let room = store.item.room, !room.isEmpty {
                        GroupBox("Location") {
                            HStack {
                                Image(systemName: "location")
                                    .foregroundColor(.secondary)
                                Text(room)
                                if let location = store.item.specificLocation, !location.isEmpty {
                                    Text(" - \(location)")
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }

                    // Documentation Status
                    GroupBox("Documentation") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Circle()
                                    .fill(store.item.hasCompleteDocumentation ? .green : .orange)
                                    .frame(width: 12, height: 12)
                                Text(store.item.hasCompleteDocumentation ? "Complete" : "Needs attention")
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            
                            if !store.item.hasCompleteDocumentation {
                                Text("Missing: Image, Receipt, or Serial Number")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    store.send(.editTapped)
                }
            }
        }
    }
    
    private func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: price as NSNumber) ?? "$0.00"
    }
}

private struct ItemEditView: View {
    @Bindable var store: StoreOf<ItemEditFeature>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Item Name", text: $store.item.name.sending(\.updateName), prompt: Text("Enter item name"))
                    
                    TextField("Description", text: Binding(
                        get: { store.item.itemDescription ?? "" },
                        set: { store.send(.updateDescription($0)) }
                    ), prompt: Text("Optional description"), axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Details") {
                    Stepper("Quantity: \(store.item.quantity)", value: Binding(
                        get: { store.item.quantity },
                        set: { newValue in 
                            store.item.quantity = newValue
                        }
                    ), in: 1...999)
                    
                    TextField("Brand", text: Binding(
                        get: { store.item.brand ?? "" },
                        set: { newValue in 
                            store.item.brand = newValue.isEmpty ? nil : newValue
                        }
                    ), prompt: Text("Optional brand"))
                    
                    TextField("Model Number", text: Binding(
                        get: { store.item.modelNumber ?? "" },
                        set: { newValue in 
                            store.item.modelNumber = newValue.isEmpty ? nil : newValue
                        }
                    ), prompt: Text("Optional model"))
                }
                
                if store.mode == .create {
                    Section("Quick Setup") {
                        Button("Add Basic Item") {
                            store.send(.saveTapped)
                        }
                        .disabled(!store.isValid)
                    }
                }
            }
            .navigationTitle(store.mode == .create ? "Add Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        store.send(.saveTapped)
                    }
                    .disabled(!store.isValid)
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
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
                    .foregroundColor(Color(UIColor.quaternaryLabel))
            }
            .padding(12)
            .background(Color(UIColor.systemGray6))
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
        let hasReceipt = receiptImageData != nil || !(receipts?.isEmpty ?? true)
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

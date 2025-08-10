//
// Layer: Features
// Module: Inventory
// Purpose: Item Edit/Create Feature
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ItemEditFeature {
    @ObservableState
    struct State: Equatable {
        enum Mode: Equatable {
            case create
            case edit(InventoryItem)
        }

        let mode: Mode
        var name = ""
        var category = ""
        var location = ""
        var price = ""
        var quantity = 1
        var notes = ""
        var isLoading = false

        init(mode: Mode) {
            self.mode = mode

            if case let .edit(item) = mode {
                name = item.name
                category = item.category ?? ""
                location = item.location ?? ""
                if let price = item.price {
                    self.price = "\(price)"
                }
                quantity = item.quantity
                notes = item.notes ?? ""
            }
        }

        var isValid: Bool {
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    enum Action {
        case nameChanged(String)
        case categoryChanged(String)
        case locationChanged(String)
        case priceChanged(String)
        case quantityChanged(Int)
        case notesChanged(String)
        case saveTapped
        case saved
        case cancelTapped
    }

    @Dependency(\.inventoryService) var inventoryService
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .nameChanged(name):
                state.name = name
                return .none

            case let .categoryChanged(category):
                state.category = category
                return .none

            case let .locationChanged(location):
                state.location = location
                return .none

            case let .priceChanged(price):
                state.price = price
                return .none

            case let .quantityChanged(quantity):
                state.quantity = max(1, quantity)
                return .none

            case let .notesChanged(notes):
                state.notes = notes
                return .none

            case .saveTapped:
                guard state.isValid else { return .none }

                state.isLoading = true

                let item = InventoryItem(
                    id: UUID(),
                    name: state.name,
                    category: state.category.isEmpty ? nil : state.category,
                    location: state.location.isEmpty ? nil : state.location,
                    price: Decimal(string: state.price),
                    quantity: state.quantity,
                    notes: state.notes.isEmpty ? nil : state.notes,
                    photoCount: 0,
                    createdAt: Date(),
                    updatedAt: Date()
                )

                return .run { send in
                    if case .create = state.mode {
                        await inventoryService.create(item)
                    } else {
                        await inventoryService.update(item)
                    }
                    await send(.saved)
                }

            case .saved:
                state.isLoading = false
                return .run { _ in
                    await dismiss()
                }

            case .cancelTapped:
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}

struct ItemEditView: View {
    @Bindable var store: StoreOf<ItemEditFeature>
    @FocusState private var focusedField: Field?

    enum Field {
        case name, category, location, price, notes
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Item Name", text: $store.name.sending(\.nameChanged))
                        .focused($focusedField, equals: .name)

                    TextField("Category", text: $store.category.sending(\.categoryChanged))
                        .focused($focusedField, equals: .category)

                    TextField("Location", text: $store.location.sending(\.locationChanged))
                        .focused($focusedField, equals: .location)
                }

                Section {
                    HStack {
                        Text("Price")
                        Spacer()
                        TextField("0.00", text: $store.price.sending(\.priceChanged))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .price)
                    }

                    Stepper("Quantity: \(store.quantity)", value: .init(
                        get: { store.quantity },
                        set: { store.send(.quantityChanged($0)) }
                    ), in: 1 ... 999)
                }

                Section {
                    TextField("Notes", text: $store.notes.sending(\.notesChanged), axis: .vertical)
                        .lineLimit(3 ... 6)
                        .focused($focusedField, equals: .notes)
                }
            }
            .navigationTitle(store.mode == .create ? "New Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        store.send(.cancelTapped)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        store.send(.saveTapped)
                    }
                    .disabled(!store.isValid || store.isLoading)
                }
            }
            .disabled(store.isLoading)
            .onAppear {
                focusedField = .name
            }
        }
    }
}

#Preview {
    NavigationStack {
        ItemEditView(
            store: Store(initialState: ItemEditFeature.State(mode: .create)) {
                ItemEditFeature()
            }
        )
    }
}

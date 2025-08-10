//
// Layer: Features
// Module: Inventory
// Purpose: Item Detail Feature
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ItemDetailFeature {
    @ObservableState
    struct State: Equatable {
        let item: InventoryItem
        var isEditing = false
    }
    
    enum Action {
        case editTapped
        case deleteTapped
        case shareItem
        case duplicateItem
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .editTapped:
                state.isEditing = true
                return .none
                
            case .deleteTapped:
                // Handle delete
                return .none
                
            case .shareItem:
                // Handle share
                return .none
                
            case .duplicateItem:
                // Handle duplicate
                return .none
            }
        }
    }
}

struct ItemDetailView: View {
    @Bindable var store: StoreOf<ItemDetailFeature>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text(store.item.name)
                        .font(Typography.largeTitle())
                        .foregroundColor(.primaryText)
                    
                    if let category = store.item.category {
                        Label(category, systemImage: "folder")
                            .font(Typography.subheadline())
                            .foregroundColor(.secondaryText)
                    }
                }
                .padding(.horizontal)
                
                // Details Section
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    DetailRow(label: "Quantity", value: "\(store.item.quantity)")
                    
                    if let location = store.item.location {
                        DetailRow(label: "Location", value: location)
                    }
                    
                    if let price = store.item.price {
                        DetailRow(label: "Value", value: formatPrice(price))
                    }
                    
                    if let notes = store.item.notes {
                        DetailRow(label: "Notes", value: notes)
                    }
                }
                .padding()
                .background(Color.secondaryBackground)
                .cornerRadius(Theme.CornerRadius.lg)
                .padding(.horizontal)
                
                // Actions
                VStack(spacing: Theme.Spacing.md) {
                    SecondaryButton(title: "Duplicate Item") {
                        store.send(.duplicateItem)
                    }
                    
                    DestructiveButton(title: "Delete Item") {
                        store.send(.deleteTapped)
                    }
                }
                .padding()
            }
            .padding(.vertical)
        }
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

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(Typography.subheadline())
                .foregroundColor(.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(Typography.body())
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}

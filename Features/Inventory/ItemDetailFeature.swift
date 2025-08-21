//
// Layer: Features
// Module: Inventory
// Purpose: Item Detail TCA Reducer
//
// 🏗️ TCA FEATURE PATTERN: Detail View State Management
// - Manages single item detailed view and editing workflows
// - Coordinates with InventoryService for item updates
// - Handles navigation to edit and related features
// - FOLLOWS 6-layer architecture: can import UI, Services, Foundation, ComposableArchitecture
//

import ComposableArchitecture
import SwiftData
import SwiftUI
import Foundation

@Reducer
struct ItemDetailFeature {
    @ObservableState
    struct State: Equatable {
        var item: Item
        var isEditing = false
        var isLoading = false

        // 🚨 ALERT STATE: Uses @Presents for proper TCA integration
        @Presents var alert: AlertState<Action>?

        var documentationScore: Double {
            var score = 0.0
            var maxScore = 4.0

            if item.imageData != nil { score += 1.0 }
            if item.purchasePrice != nil { score += 1.0 }
            if item.serialNumber != nil, !item.serialNumber!.isEmpty { score += 1.0 }
            if item.receiptImageData != nil { score += 1.0 }

            return score / maxScore
        }
    }

    enum Action {
        case onAppear
        case editTapped
        case deleteTapped
        case deleteConfirmed
        case alert(PresentationAction<Never>)
    }

    @Dependency(\.inventoryService) var inventoryService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .editTapped:
                state.isEditing = true
                return .none
            case .deleteTapped:
                state.alert = AlertState {
                    TextState("Delete Item")
                } actions: {
                    ButtonState(role: .destructive, action: .deleteConfirmed) {
                        TextState("Delete")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("Are you sure you want to delete \(state.item.name)?")
                }
                return .none
            case .deleteConfirmed:
                return .run { [item = state.item] _ in
                    try await inventoryService.deleteItem(id: item.id)
                }
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Equatable Conformance

extension ItemDetailFeature.State: Equatable {
    static func == (lhs: ItemDetailFeature.State, rhs: ItemDetailFeature.State) -> Bool {
        return lhs.item == rhs.item &&
               lhs.isEditing == rhs.isEditing &&
               lhs.isLoading == rhs.isLoading
        // Note: alert is excluded from comparison as @Presents creates PresentationState
        // which doesn't participate in meaningful state equality for TCA diffing
    }
}

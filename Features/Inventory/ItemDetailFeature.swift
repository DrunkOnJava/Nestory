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
public struct ItemDetailFeature: Sendable {
    @ObservableState
    public struct State: Sendable {
        var item: Item
        var isEditing = false
        var isLoading = false

        @Presents var alert: AlertState<Action.Alert>?

        public init(item: Item) {
            self.item = item
        }

        var documentationScore: Double {
            var score = 0.0
            let maxScore = 4.0

            if item.imageData != nil { score += 1.0 }
            if item.purchasePrice != nil { score += 1.0 }
            if let serialNumber = item.serialNumber, !serialNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { 
                score += 1.0 
            }
            if item.receiptImageData != nil { score += 1.0 }

            return score / maxScore
        }
    }

    public enum Action: Sendable {
        case onAppear
        case editTapped
        case deleteTapped
        case deleteConfirmed
        case alert(PresentationAction<Alert>)
        
        public enum Alert: Equatable, Sendable {
            case deleteConfirmation
        }
    }

    @Dependency(\.inventoryService) var inventoryService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .editTapped:
                state.isEditing = true
                return .none

            case .deleteTapped:
                let itemName = state.item.name
                state.alert = AlertState {
                    TextState("Delete Item")
                } actions: {
                    ButtonState(role: .destructive, action: .deleteConfirmation) {
                        TextState("Delete")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("Are you sure you want to delete '\(itemName)'?")
                }
                return .none

            case .deleteConfirmed:
                return .run { [item = state.item] _ in
                    try await inventoryService.deleteItem(id: item.id)
                }

            case .alert(.presented(.deleteConfirmation)):
                return .send(.deleteConfirmed)

            case .alert(.dismiss):
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Equatable Conformance

extension ItemDetailFeature.State: Equatable {
    public static func == (lhs: ItemDetailFeature.State, rhs: ItemDetailFeature.State) -> Bool {
        return lhs.item == rhs.item &&
               lhs.isEditing == rhs.isEditing &&
               lhs.isLoading == rhs.isLoading
        // Note: alert is excluded from comparison as @Presents creates PresentationState
        // which doesn't participate in meaningful state equality for TCA diffing
    }
}
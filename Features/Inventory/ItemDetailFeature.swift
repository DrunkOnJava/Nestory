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
        @Presents var alert: AlertState<Alert>?

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
        case alert(PresentationAction<Alert>)

        enum Alert: Equatable {
            case confirmDelete
        }
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
                return .none
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

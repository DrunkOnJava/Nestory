//
// Layer: Features
// Module: Inventory
// Purpose: Item Edit TCA Reducer
//

import ComposableArchitecture
import SwiftData
import SwiftUI
import Foundation

@Reducer
struct ItemEditFeature {
    @ObservableState
    struct State: Equatable {
        var mode: EditMode = .create
        var item: Item
        var isLoading = false
        var alert: AlertState<Action>? = nil

        enum EditMode {
            case create
            case edit
        }

        var isValid: Bool {
            !item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        init(mode: EditMode = .create, item: Item? = nil) {
            self.mode = mode
            self.item = item ?? Item(name: "")
        }
    }

    enum Action {
        case onAppear
        case saveTapped
        case cancelTapped
        case alert(PresentationAction<Alert>)

        case updateName(String)
        case updateDescription(String)

        enum Alert: Equatable {
            case saveError
        }
    }

    @Dependency(\.inventoryService) var inventoryService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .saveTapped:
                guard state.isValid else { return .none }
                state.isLoading = true
                return .none
            case .cancelTapped:
                return .none
            case let .updateName(name):
                state.item.name = name
                return .none
            case let .updateDescription(description):
                state.item.itemDescription = description
                return .none
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

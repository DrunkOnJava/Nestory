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
public struct ItemEditFeature: Sendable {
    @ObservableState
    public struct State: Sendable {
        var mode: EditMode = .create
        var item: Item
        var isLoading = false
        @Presents var alert: AlertState<Action>?

        public enum EditMode: Equatable, Sendable {
            case create
            case edit
        }

        var isValid: Bool {
            !item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        public init(mode: EditMode = .create, item: Item? = nil) {
            self.mode = mode
            self.item = item ?? Item(name: "")
        }
    }

    public enum Action: Sendable {
        case onAppear
        case saveTapped
        case cancelTapped
        case alert(PresentationAction<Never>)
        case updateName(String)
        case updateDescription(String)
        case saveCompleted
        case saveFailed(any Error)
    }

    @Dependency(\.inventoryService) var inventoryService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .saveTapped:
                guard state.isValid else { return .none }
                guard !state.isLoading else { return .none } // Prevent concurrent saves
                state.isLoading = true
                
                return .run { [item = state.item] send in
                    do {
                        try await inventoryService.saveItem(item)
                        await send(.saveCompleted)
                    } catch {
                        await send(.saveFailed(error))
                    }
                }

            case .cancelTapped:
                return .none

            case .updateName(let name):
                state.item.name = name
                return .none

            case .updateDescription(let description):
                state.item.itemDescription = description
                return .none

            case .saveCompleted:
                state.isLoading = false
                return .none

            case .saveFailed(let error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("Save Failed")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("OK")
                    }
                } message: {
                    TextState("Failed to save item: \(error.localizedDescription)")
                }
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Equatable Conformance

extension ItemEditFeature.State: Equatable {
    public static func == (lhs: ItemEditFeature.State, rhs: ItemEditFeature.State) -> Bool {
        return lhs.mode == rhs.mode &&
               lhs.item == rhs.item &&
               lhs.isLoading == rhs.isLoading
        // Note: alert is excluded from comparison as @Presents creates PresentationState
        // which doesn't participate in meaningful state equality for TCA diffing
    }
}


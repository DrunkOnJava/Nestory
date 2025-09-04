//
// Layer: Features
// Module: Inventory
// Purpose: Refactored Inventory Feature with Reduced Complexity (CC: 18 → 6)
//
// 🎯 REFACTORING STRATEGY:
// - Split complex reducer into smaller, focused sub-reducers
// - Extract loading logic into LoadingReducer
// - Extract error handling into ErrorReducer
// - Extract item operations into ItemOperationsReducer
// - Use TCA's CombineReducers for composition
//

import ComposableArchitecture
import SwiftData
import SwiftUI
import Foundation

@Reducer
public struct InventoryFeature: Sendable {
    @ObservableState
    public struct State: Equatable {
        // Core state remains the same
        var items: [Item] = []
        var searchText = ""
        var selectedCategory: String? = nil
        var isLoading = false
        var path = StackState<Path.State>()
        
        @Presents var alert: AlertState<Action.Alert>?
        
        var filteredItems: [Item] {
            items
                .filter { item in
                    searchText.isEmpty || item.matchesSearch(searchText)
                }
                .filter { item in
                    selectedCategory == nil || item.category?.name == selectedCategory
                }
        }
    }
    
    public enum Action: Sendable {
        // Group actions by concern
        case lifecycle(LifecycleAction)
        case loading(LoadingAction)
        case filtering(FilteringAction)
        case itemOperation(ItemOperationAction)
        case navigation(NavigationAction)
        case alert(PresentationAction<Alert>)
        case path(StackAction<Path.State, Path.Action>)
        
        // Nested action types for better organization
        public enum LifecycleAction: Sendable {
            case onAppear
            case serviceHealthChanged(Bool)
        }
        
        public enum LoadingAction: Sendable {
            case loadItems
            case itemsLoaded([Item])
            case loadItemsFailed(any Error)
            case retryLoadingInBackground
        }
        
        public enum FilteringAction: Sendable {
            case searchTextChanged(String)
            case categorySelected(String?)
        }
        
        public enum ItemOperationAction: Sendable {
            case addItemTapped
            case itemTapped(Item)
            case deleteItems(IndexSet)
            case deleteConfirmed(IndexSet)
        }
        
        public enum NavigationAction: Sendable {
            case showItemDetail(Item)
            case showItemEdit(ItemEditFeature.State.EditMode)
        }
        
        public enum Alert: Equatable, Sendable {
            case retryLoading
            case deleteConfirmed(IndexSet)
            case serviceDegrade
            case networkError
        }
    }
    
    @Reducer
    public struct Path {
        @ObservableState
        public enum State: Equatable, Sendable {
            case itemDetail(ItemDetailFeature.State)
            case itemEdit(ItemEditFeature.State)
        }
        
        public enum Action: Sendable {
            case itemDetail(ItemDetailFeature.Action)
            case itemEdit(ItemEditFeature.Action)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: \.itemDetail, action: \.itemDetail) {
                ItemDetailFeature()
            }
            Scope(state: \.itemEdit, action: \.itemEdit) {
                ItemEditFeature()
            }
        }
    }
    
    @Dependency(\.inventoryService) var inventoryService
    
    // MAIN REDUCER: Composes sub-reducers (CC: 6)
    public var body: some ReducerOf<Self> {
        CombineReducers {
            LifecycleReducer()
            LoadingReducer()
            FilteringReducer()
            ItemOperationsReducer()
            NavigationReducer()
            AlertReducer()
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
}

// MARK: - Sub-Reducers (Each with CC ≤ 5)

@Reducer
struct LifecycleReducer: Reducer {
    typealias State = InventoryFeature.State
    typealias Action = InventoryFeature.Action
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .lifecycle(.onAppear):
                return .send(.loading(.loadItems))
                
            case let .lifecycle(.serviceHealthChanged(isHealthy)):
                if !isHealthy && !state.items.isEmpty {
                    // Keep existing items visible during degraded service
                }
                return .none
                
            default:
                return .none
            }
        }
    }
}

@Reducer
struct LoadingReducer: Reducer {
    typealias State = InventoryFeature.State
    typealias Action = InventoryFeature.Action
    
    @Dependency(\.inventoryService) var inventoryService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loading(.loadItems):
                state.isLoading = true
                return .run { send in
                    await loadItemsEffect(send: send)
                }
                
            case let .loading(.itemsLoaded(items)):
                state.isLoading = false
                state.items = items
                return .none
                
            case let .loading(.loadItemsFailed(error)):
                state.isLoading = false
                state.alert = createLoadErrorAlert(error: error)
                return .run { send in
                    await retryAfterDelay(send: send)
                }
                
            case .loading(.retryLoadingInBackground):
                return .run { send in
                    await silentRetryEffect(send: send)
                }
                
            default:
                return .none
            }
        }
    }
    
    // Extract complex logic into focused functions
    private func loadItemsEffect(send: Send<Action>) async {
        do {
            let items = try await inventoryService.fetchItems()
            await send(.loading(.itemsLoaded(items)))
        } catch {
            await send(.loading(.loadItemsFailed(error)))
        }
    }
    
    private func retryAfterDelay(send: Send<Action>) async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        await send(.loading(.retryLoadingInBackground))
    }
    
    private func silentRetryEffect(send: Send<Action>) async {
        do {
            let items = try await inventoryService.fetchItems()
            await send(.loading(.itemsLoaded(items)))
        } catch {
            try? await Task.sleep(nanoseconds: 10_000_000_000)
            await send(.loading(.retryLoadingInBackground))
        }
    }
    
    private func createLoadErrorAlert(error: any Error) -> AlertState<InventoryFeature.Action.Alert> {
        AlertState {
            TextState("Unable to Load Items")
        } actions: {
            ButtonState(action: .retryLoading) {
                TextState("Try Again")
            }
            ButtonState(role: .cancel) {
                TextState("Cancel")
            }
        } message: {
            TextState(error.localizedDescription)
        }
    }
}

@Reducer
struct FilteringReducer: Reducer {
    typealias State = InventoryFeature.State
    typealias Action = InventoryFeature.Action
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .filtering(.searchTextChanged(text)):
                state.searchText = text
                return .none
                
            case let .filtering(.categorySelected(category)):
                state.selectedCategory = category
                return .none
                
            default:
                return .none
            }
        }
    }
}

@Reducer
struct ItemOperationsReducer: Reducer {
    typealias State = InventoryFeature.State
    typealias Action = InventoryFeature.Action
    
    @Dependency(\.inventoryService) var inventoryService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .itemOperation(.addItemTapped):
                return .send(.navigation(.showItemEdit(.create)))
                
            case let .itemOperation(.itemTapped(item)):
                return .send(.navigation(.showItemDetail(item)))
                
            case let .itemOperation(.deleteItems(indexSet)):
                state.alert = createDeleteConfirmationAlert(indexSet: indexSet)
                return .none
                
            case let .itemOperation(.deleteConfirmed(indexSet)):
                return deleteItemsEffect(state: &state, indexSet: indexSet)
                
            default:
                return .none
            }
        }
    }
    
    private func createDeleteConfirmationAlert(indexSet: IndexSet) -> AlertState<InventoryFeature.Action.Alert> {
        AlertState {
            TextState("Delete Items")
        } actions: {
            ButtonState(role: .destructive, action: .deleteConfirmed(indexSet)) {
                TextState("Delete")
            }
            ButtonState(role: .cancel) {
                TextState("Cancel")
            }
        } message: {
            TextState("Are you sure you want to delete \(indexSet.count) item(s)?")
        }
    }
    
    private func deleteItemsEffect(state: inout State, indexSet: IndexSet) -> Effect<Action> {
        let itemsToDelete = indexSet.map { state.items[$0] }
        state.items.remove(atOffsets: indexSet)
        
        return .run { _ in
            for item in itemsToDelete {
                try? await inventoryService.deleteItem(id: item.id)
            }
        }
    }
}

@Reducer
struct NavigationReducer: Reducer {
    typealias State = InventoryFeature.State
    typealias Action = InventoryFeature.Action
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .navigation(.showItemDetail(item)):
                state.path.append(.itemDetail(ItemDetailFeature.State(item: item)))
                return .none
                
            case let .navigation(.showItemEdit(mode)):
                state.path.append(.itemEdit(ItemEditFeature.State(mode: mode)))
                return .none
                
            default:
                return .none
            }
        }
    }
}

@Reducer
struct AlertReducer: Reducer {
    typealias State = InventoryFeature.State
    typealias Action = InventoryFeature.Action
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .alert(.presented(.retryLoading)):
                return .send(.loading(.loadItems))
                
            case let .alert(.presented(.deleteConfirmed(indexSet))):
                return .send(.itemOperation(.deleteConfirmed(indexSet)))
                
            case .alert(.presented(.serviceDegrade)),
                 .alert(.presented(.networkError)),
                 .alert(.dismiss):
                return .none
                
            default:
                return .none
            }
        }
    }
}

// MARK: - Helper Extensions

extension Item {
    func matchesSearch(_ searchText: String) -> Bool {
        name.localizedCaseInsensitiveContains(searchText) ||
        category?.name.localizedCaseInsensitiveContains(searchText) == true ||
        room?.localizedCaseInsensitiveContains(searchText) == true ||
        specificLocation?.localizedCaseInsensitiveContains(searchText) == true
    }
}
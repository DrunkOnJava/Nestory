//
// Layer: Features
// Module: Inventory
// Purpose: Inventory Feature TCA Reducer
//
// 🏗️ TCA FEATURE PATTERN: Business Logic Coordinator
// - Manages inventory-related state and actions using TCA patterns
// - Coordinates with InventoryService through dependency injection
// - Handles navigation within inventory workflows
// - FOLLOWS 6-layer architecture: can import UI, Services, Foundation, ComposableArchitecture
//
// 🎯 BUSINESS FOCUS: Personal belongings for insurance documentation
// - NOT business inventory or stock management
// - Focus on completeness indicators (missing photos, receipts, serial numbers)
// - Support insurance claim generation workflows
//
// 📋 TCA STANDARDS:
// - State must be Equatable for TCA diffing
// - Actions should be intent-based (loadItems, not setItems)
// - Effects return to drive async operations
// - Use @Dependency for service injection
//

import ComposableArchitecture
import SwiftData
import SwiftUI
import Foundation

@Reducer
public struct InventoryFeature: Sendable {
    @ObservableState
    public struct State: Equatable {
        // 📊 CORE STATE: Inventory management state
        var items: [Item] = [] // Primary data source
        var searchText = "" // Real-time search filtering
        var selectedCategory: String? = nil // Category-based filtering
        var isLoading = false // Loading state for UI feedback
        var path = StackState<Path.State>() // TCA navigation stack

        // 🚨 ALERT STATE: Uses @Presents for proper TCA integration
        @Presents var alert: AlertState<Action.Alert>?

        // 🔍 COMPUTED PROPERTIES: Derived state for UI consumption
        // Using computed properties keeps state minimal and derived values fresh

        var filteredItems: [Item] {
            var result = items

            // 🔍 SEARCH IMPLEMENTATION: Multi-field search for user convenience
            // Searches across name, category, and location for comprehensive results
            if !searchText.isEmpty {
                result = result.filter { item in
                    item.name.localizedCaseInsensitiveContains(searchText) ||
                        item.category?.name.localizedCaseInsensitiveContains(searchText) == true ||
                        item.room?.localizedCaseInsensitiveContains(searchText) == true ||
                        item.specificLocation?.localizedCaseInsensitiveContains(searchText) == true
                }
            }

            // 📂 CATEGORY FILTERING: Insurance-focused organization
            // Categories help users organize items for insurance coverage tiers
            if let category = selectedCategory {
                result = result.filter { $0.category?.name == category }
            }

            return result
        }
    }

    public enum Action: Sendable {
        case onAppear
        case loadItems
        case itemsLoaded([Item])
        case loadItemsFailed(any Error)
        case searchTextChanged(String)
        case categorySelected(String?)
        case addItemTapped
        case itemTapped(Item)
        case deleteItems(IndexSet)
        case deleteConfirmed(IndexSet)
        case retryLoadingInBackground
        case serviceHealthChanged(Bool)
        case alert(PresentationAction<Alert>)
        case path(StackAction<Path.State, Path.Action>)
        
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

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .send(.loadItems)

            case .loadItems:
                state.isLoading = true
                return .run { send in
                    do {
                        let items = try await inventoryService.fetchItems()
                        await send(.itemsLoaded(items))
                    } catch {
                        await send(.loadItemsFailed(error))
                    }
                }

            case let .itemsLoaded(items):
                state.isLoading = false
                state.items = items
                return .none

            case let .loadItemsFailed(error):
                state.isLoading = false
                
                // Show appropriate error alert based on error type
                state.alert = AlertState {
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
                
                // Start automatic retry in background after delay
                return .run { send in
                    try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                    await send(.retryLoadingInBackground)
                }
            
            case .retryLoadingInBackground:
                // Silent retry without showing loading state
                return .run { send in
                    do {
                        let items = try await inventoryService.fetchItems()
                        await send(.itemsLoaded(items))
                    } catch {
                        // Silent failure - will retry again later
                        try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
                        await send(.retryLoadingInBackground)
                    }
                }
            
            case let .serviceHealthChanged(isHealthy):
                if !isHealthy && !state.items.isEmpty {
                    // Show non-intrusive notification about degraded service
                    // Keep existing items visible
                }
                return .none

            case let .searchTextChanged(text):
                state.searchText = text
                return .none

            case let .categorySelected(category):
                state.selectedCategory = category
                return .none

            case .addItemTapped:
                state.path.append(.itemEdit(ItemEditFeature.State(mode: .create)))
                return .none

            case let .itemTapped(item):
                state.path.append(.itemDetail(ItemDetailFeature.State(item: item)))
                return .none

            case let .deleteItems(indexSet):
                state.alert = AlertState {
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
                return .none

            case let .deleteConfirmed(indexSet):
                // Handle actual deletion
                let itemsToDelete = indexSet.map { state.items[$0] }
                state.items.remove(atOffsets: indexSet)

                return .run { _ in
                    do {
                        for item in itemsToDelete {
                            try await inventoryService.deleteItem(id: item.id)
                        }
                    } catch {
                        // Handle delete error - could add alert here
                    }
                }

            case .alert(.presented(.retryLoading)):
                return .send(.loadItems)
                
            case .alert(.presented(.deleteConfirmed(let indexSet))):
                return .send(.deleteConfirmed(indexSet))
                
            case .alert(.presented(.serviceDegrade)):
                // Service degraded alert acknowledged
                return .none
                
            case .alert(.presented(.networkError)):
                // Network error alert acknowledged
                return .none
                
            case .alert(.dismiss):
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}


// MARK: - Models

// Using Foundation.Item model from current project

// MARK: - TCA Integration Notes

//
// 🔗 SERVICE INTEGRATION: Uses Services/InventoryService protocol
// - Dependency injection via @Dependency(\.inventoryService)
// - Protocol defined in Services layer with proper implementations
// - DependencyKeys.swift contains live and test value configurations
// - Follows async/throws patterns for robust error handling


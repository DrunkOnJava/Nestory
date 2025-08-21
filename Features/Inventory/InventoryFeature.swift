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
public struct InventoryFeature {
    @ObservableState
    public struct State: Equatable {
        // 📊 CORE STATE: Inventory management state
        var items: [Item] = [] // Primary data source
        var searchText = "" // Real-time search filtering
        var selectedCategory: String? = nil // Category-based filtering
        var isLoading = false // Loading state for UI feedback
        var path = StackState<Path.State>() // TCA navigation stack

        // 🚨 ALERT STATE: Uses @Presents for proper TCA integration
        @Presents var alert: AlertState<Action>?

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

    public enum Action {
        case onAppear
        case loadItems
        case itemsLoaded([Item])
        case loadItemsFailed(Error)
        case searchTextChanged(String)
        case categorySelected(String?)
        case addItemTapped
        case itemTapped(Item)
        case deleteItems(IndexSet)
        case deleteConfirmed(IndexSet)
        case alert(PresentationAction<Never>)
        case path(StackAction<Path.State, Path.Action>)
    }

    @Reducer
    struct Path {
        enum State: Equatable {
            case itemDetail(ItemDetailFeature.State)
            case itemEdit(ItemEditFeature.State)
        }

        enum Action {
            case itemDetail(ItemDetailFeature.Action)
            case itemEdit(ItemEditFeature.Action)
        }

        var body: some ReducerOf<Self> {
            Scope(state: \.itemDetail, action: \.itemDetail) {
                ItemDetailFeature()
            }
            Scope(state: \.itemEdit, action: \.itemEdit) {
                ItemEditFeature()
            }
        }
    }

    @Dependency(\.inventoryService) var inventoryService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
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
                state.alert = AlertState {
                    TextState("Error Loading Items")
                } actions: {
                    ButtonState(action: .send(.loadItems)) {
                        TextState("Retry")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("Failed to load inventory: \(error.localizedDescription)")
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

            case .alert:
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

// MARK: - Equatable Conformance

extension InventoryFeature.State: Equatable {
    static func == (lhs: InventoryFeature.State, rhs: InventoryFeature.State) -> Bool {
        return lhs.items == rhs.items &&
               lhs.searchText == rhs.searchText &&
               lhs.selectedCategory == rhs.selectedCategory &&
               lhs.isLoading == rhs.isLoading &&
               lhs.path == rhs.path
        // Note: alert is excluded from comparison as @Presents creates PresentationState
        // which doesn't participate in meaningful state equality for TCA diffing
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

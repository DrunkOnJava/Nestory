//
// Layer: Features
// Module: Inventory
// Purpose: Inventory Feature TCA Reducer
//

import ComposableArchitecture
import SwiftData
import SwiftUI

@Reducer
struct InventoryFeature {
    @ObservableState
    struct State: Equatable {
        var items: [InventoryItem] = []
        var searchText = ""
        var selectedCategory: String? = nil
        var isLoading = false
        var alert: AlertState<Action>? = nil
        var path = StackState<Path.State>()

        var filteredItems: [InventoryItem] {
            var result = items

            if !searchText.isEmpty {
                result = result.filter { item in
                    item.name.localizedCaseInsensitiveContains(searchText) ||
                        item.category?.localizedCaseInsensitiveContains(searchText) == true ||
                        item.location?.localizedCaseInsensitiveContains(searchText) == true
                }
            }

            if let category = selectedCategory {
                result = result.filter { $0.category == category }
            }

            return result
        }
    }

    enum Action {
        case onAppear
        case loadItems
        case itemsLoaded([InventoryItem])
        case searchTextChanged(String)
        case categorySelected(String?)
        case addItemTapped
        case itemTapped(InventoryItem)
        case deleteItems(IndexSet)
        case deleteConfirmed(IndexSet)
        case alert(PresentationAction<Alert>)
        case path(StackAction<Path.State, Path.Action>)

        enum Alert: Equatable {
            case confirmDelete
        }
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
                    let items = await inventoryService.fetchAll()
                    await send(.itemsLoaded(items))
                }

            case let .itemsLoaded(items):
                state.isLoading = false
                state.items = items
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
                    ButtonState(role: .destructive, action: .confirmDelete) {
                        TextState("Delete")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("Are you sure you want to delete \(indexSet.count) item(s)?")
                }
                return .none

            case .alert(.presented(.confirmDelete)):
                // Handle delete confirmation
                return .none

            case .alert:
                return .none

            case .path:
                return .none

            case let .deleteConfirmed(indexSet):
                let itemsToDelete = indexSet.map { state.items[$0] }
                state.items.remove(atOffsets: indexSet)

                return .run { _ in
                    for item in itemsToDelete {
                        await inventoryService.delete(item.id)
                    }
                }
            }
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Models

struct InventoryItem: Equatable, Identifiable {
    let id: UUID
    let name: String
    let category: String?
    let location: String?
    let price: Decimal?
    let quantity: Int
    let notes: String?
    let photoCount: Int
    let createdAt: Date
    let updatedAt: Date

    static func mock() -> InventoryItem {
        InventoryItem(
            id: UUID(),
            name: "Sample Item",
            category: "Electronics",
            location: "Office",
            price: 99.99,
            quantity: 1,
            notes: nil,
            photoCount: 0,
            createdAt: Date(),
            updatedAt: Date(),
        )
    }
}

// MARK: - Service Dependency

struct InventoryService {
    var fetchAll: @Sendable () async -> [InventoryItem]
    var fetch: @Sendable (UUID) async -> InventoryItem?
    var create: @Sendable (InventoryItem) async -> Void
    var update: @Sendable (InventoryItem) async -> Void
    var delete: @Sendable (UUID) async -> Void
}

extension InventoryService: DependencyKey {
    static let liveValue = InventoryService(
        fetchAll: {
            // TODO: Implement with SwiftData
            [
                InventoryItem.mock(),
                InventoryItem(
                    id: UUID(),
                    name: "MacBook Pro",
                    category: "Electronics",
                    location: "Office",
                    price: 2499.00,
                    quantity: 1,
                    notes: "16-inch, M3 Pro",
                    photoCount: 2,
                    createdAt: Date(),
                    updatedAt: Date(),
                ),
                InventoryItem(
                    id: UUID(),
                    name: "Office Chair",
                    category: "Furniture",
                    location: "Office",
                    price: 450.00,
                    quantity: 1,
                    notes: "Ergonomic design",
                    photoCount: 1,
                    createdAt: Date(),
                    updatedAt: Date(),
                ),
            ]
        },
        fetch: { _ in nil },
        create: { _ in },
        update: { _ in },
        delete: { _ in },
    )

    static let testValue = InventoryService(
        fetchAll: { [] },
        fetch: { _ in nil },
        create: { _ in },
        update: { _ in },
        delete: { _ in },
    )
}

extension DependencyValues {
    var inventoryService: InventoryService {
        get { self[InventoryService.self] }
        set { self[InventoryService.self] = newValue }
    }
}

//
// Layer: Features
// Module: Categories
// Purpose: TCA Feature for category management and navigation
//

import ComposableArchitecture
import Foundation
import SwiftData

@Reducer
struct CategoryFeature {
    @ObservableState
    struct State: Equatable {
        var categories: [Category] = []
        var showingAddCategory = false
        var selectedCategory: Category?
        var path = StackState<Path.State>()
        var isLoading = false
        var errorMessage: String?
    }
    
    enum Action: Equatable {
        case onAppear
        case categoriesLoaded([Category])
        case categorySelected(Category)
        case addCategoryButtonTapped
        case addCategoryDismissed
        case loadingFailed(String)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    @Reducer
    struct Path {
        @ObservableState
        enum State: Equatable {
            case detail(CategoryDetailFeature.State)
            case add(AddCategoryFeature.State)
        }
        
        enum Action: Equatable {
            case detail(CategoryDetailFeature.Action)
            case add(AddCategoryFeature.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: \.detail, action: \.detail) {
                CategoryDetailFeature()
            }
            Scope(state: \.add, action: \.add) {
                AddCategoryFeature()
            }
        }
    }
    
    @Dependency(\.categoryService) var categoryService
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    do {
                        let categories = try await categoryService.fetchCategories()
                        await send(.categoriesLoaded(categories))
                    } catch {
                        await send(.loadingFailed(error.localizedDescription))
                    }
                }
                
            case let .categoriesLoaded(categories):
                state.categories = categories
                state.isLoading = false
                state.errorMessage = nil
                return .none
                
            case let .categorySelected(category):
                state.path.append(.detail(CategoryDetailFeature.State(category: category)))
                return .none
                
            case .addCategoryButtonTapped:
                state.path.append(.add(AddCategoryFeature.State()))
                return .none
                
            case .addCategoryDismissed:
                state.showingAddCategory = false
                return .none
                
            case let .loadingFailed(error):
                state.isLoading = false
                state.errorMessage = error
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
}

// MARK: - Child Features

@Reducer
struct CategoryDetailFeature {
    @ObservableState
    struct State: Equatable {
        let category: Category
        var categoryItems: [Item] = []
        var isLoading = false
        
        init(category: Category) {
            self.category = category
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case itemsLoaded([Item])
        case dismissTapped
    }
    
    @Dependency(\.inventoryService) var inventoryService
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { [categoryId = state.category.id] send in
                    do {
                        let items = try await inventoryService.fetchItemsByCategory(categoryId: categoryId)
                        await send(.itemsLoaded(items))
                    } catch {
                        await send(.itemsLoaded([]))
                    }
                }
                
            case let .itemsLoaded(items):
                state.categoryItems = items
                state.isLoading = false
                return .none
                
            case .dismissTapped:
                return .run { _ in await dismiss() }
            }
        }
    }
}

@Reducer
struct AddCategoryFeature {
    @ObservableState
    struct State: Equatable {
        var name = ""
        var selectedIcon = "folder.fill"
        var selectedColor = "#007AFF"
        var isSaving = false
        var errorMessage: String?
        
        let availableIcons = [
            "folder.fill", "tv.fill", "sofa.fill", "tshirt.fill",
            "book.fill", "fork.knife", "hammer.fill", "sportscourt.fill",
            "house.fill", "car.fill", "airplane", "gamecontroller.fill"
        ]
        
        let availableColors = [
            "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4",
            "#FFEAA7", "#DDA0DD", "#98D8C8", "#B0B0B0",
            "#007AFF", "#34C759", "#FF9500", "#FF3B30"
        ]
        
        var canSave: Bool {
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    enum Action: Equatable {
        case nameChanged(String)
        case iconSelected(String)
        case colorSelected(String)
        case cancelTapped
        case saveTapped
        case categorySaved
        case savingFailed(String)
    }
    
    @Dependency(\.categoryService) var categoryService
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .nameChanged(name):
                state.name = name
                return .none
                
            case let .iconSelected(icon):
                state.selectedIcon = icon
                return .none
                
            case let .colorSelected(color):
                state.selectedColor = color
                return .none
                
            case .cancelTapped:
                return .run { _ in await dismiss() }
                
            case .saveTapped:
                guard state.canSave else { return .none }
                
                state.isSaving = true
                state.errorMessage = nil
                
                return .run { [name = state.name.trimmingCharacters(in: .whitespacesAndNewlines),
                              icon = state.selectedIcon,
                              color = state.selectedColor] send in
                    do {
                        try await categoryService.createCategory(name: name, icon: icon, colorHex: color)
                        await send(.categorySaved)
                    } catch {
                        await send(.savingFailed(error.localizedDescription))
                    }
                }
                
            case .categorySaved:
                return .run { _ in await dismiss() }
                
            case let .savingFailed(error):
                state.isSaving = false
                state.errorMessage = error
                return .none
            }
        }
    }
}
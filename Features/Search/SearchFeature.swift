//
// Layer: Features
// Module: Search
// Purpose: Search Feature TCA Reducer - now organized into modular components
//

import ComposableArchitecture
import SwiftData
import SwiftUI
import Foundation

// MARK: - Modular TCA Architecture
//
// This feature has been refactored from 581 lines into focused TCA components:
//
// • State/: State management (1 component)
//   - SearchState: Comprehensive state with computed properties and analytics
//
// • Actions/: Action definitions (1 component)
//   - SearchActions: Complete action catalog for all search operations
//
// • Reducers/: Business logic (1 component)
//   - SearchReducer: Main reducer with organized action handling
//
// • Effects/: Async operations (1 component)
//   - SearchEffects: Search execution, debouncing, and history management
//
// • Utils/: Helper functions (1 component)
//   - SearchUtils: Sort operations, query processing, and validation
//
// This modular TCA structure provides better maintainability, testability, and 
// separation of concerns while following TCA best practices and patterns.

@Reducer
public struct SearchFeature: Sendable {
    
    // MARK: - Type Aliases
    
    public typealias State = SearchState
    public typealias Action = SearchAction
    
    // MARK: - Dependencies
    
    @Dependency(\.inventoryService) var inventoryService
    @Dependency(\.searchHistoryService) var searchHistoryService
    
    // MARK: - Reducer
    
    public var body: some ReducerOf<Self> {
        SearchReducer()
    }
    
    public init() {}
}

// MARK: - TCA Integration Notes

//
// 🔗 SERVICE INTEGRATION: Uses multiple protocol-based services
// - InventoryService: Core search and data retrieval operations
// - SearchHistoryService: Search history and saved searches management
// - All services injected via @Dependency for testability and modularity
//
// 🎯 STATE MANAGEMENT: Comprehensive search coordination
// - Real-time debounced search with performance optimizations
// - Multi-dimensional filtering with validation
// - Search history and analytics tracking
// - Error handling for all potential failure scenarios
// - Loading states for smooth user experience
//
// 🏗️ MODULAR ARCHITECTURE: Components organized by TCA patterns
// - State: SearchState in Components/State/
// - Actions: SearchActions in Components/Actions/
// - Reducer Logic: SearchReducer in Components/Reducers/
// - Effects: SearchEffects in Components/Effects/
// - Utilities: SearchUtils in Components/Utils/
//
// 📊 PERFORMANCE FEATURES:
// - Debounced search to prevent excessive API calls
// - Result caching and relevance scoring
// - Efficient sorting and filtering operations
// - Search analytics for performance monitoring
//
// 🎨 USER EXPERIENCE:
// - Multiple search modes (Quick, Advanced, Visual)
// - Comprehensive filtering with validation
// - Search history and saved searches
// - Real-time result updates with loading states
// - Error handling with user-friendly messages
//
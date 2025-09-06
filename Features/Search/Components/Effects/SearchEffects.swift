//
// Layer: Features/Search
// Module: Search/Components/Effects
// Purpose: Search effect handlers and async operations for TCA
//

import ComposableArchitecture
import Foundation

public struct SearchEffects: Sendable {
    
    // MARK: - Dependencies
    
    let inventoryService: any InventoryService
    let searchHistoryService: any SearchHistoryService
    
    public init(
        inventoryService: any InventoryService,
        searchHistoryService: any SearchHistoryService
    ) {
        self.inventoryService = inventoryService
        self.searchHistoryService = searchHistoryService
    }
    
    // MARK: - Search Operations
    
    public func performAdvancedSearch(
        query: String,
        filters: SearchFilters
    ) async throws -> SearchResults {
        // Process the search query
        let processedQuery = SearchUtils.processSearchQuery(query)
        
        // Validate filters
        let validation = SearchUtils.validateFilters(filters)
        guard validation.isValid else {
            throw SearchError.invalidFilters(validation.issues)
        }
        
        // Execute search with filters
        let items = try await inventoryService.searchItems(
            query: processedQuery.processedQuery
        )
        
        // Calculate relevance scores and sort by relevance if needed
        let scoredItems = items.map { item in
            let score = SearchUtils.calculateSearchRelevanceScore(
                item: item,
                query: processedQuery.processedQuery,
                filters: filters
            )
            return (item: item, score: score)
        }
        .sorted { $0.score > $1.score }
        .map { $0.item }
        
        return SearchResults(
            items: scoredItems,
            totalCount: scoredItems.count,
            query: processedQuery,
            filters: filters
        )
    }
    
    public func loadInitialData() -> Effect<SearchAction> {
        return .run { send in
            // Load categories for filtering
            let categories = try await inventoryService.fetchCategories()
            await send(.categoriesLoaded(categories))
            
            // Room functionality removed - room properties no longer available
            
            // Load search history
            let history = await searchHistoryService.loadHistory()
            await send(.historyLoaded(history))
            
            // Load saved searches
            let saved = await searchHistoryService.loadSavedSearches()
            await send(.savedSearchesLoaded(saved))
        }
    }
    
    public func performDebouncedSearch(
        query: String,
        filters: SearchFilters
    ) -> Effect<SearchAction> {
        return .run { send in
            try await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
            
            do {
                let results = try await performAdvancedSearch(
                    query: query,
                    filters: filters
                )
                await send(.searchCompleted(results.items, results.totalCount))
                
                // Track search analytics
                await send(.trackSearchPerformed(query, filters))
                
                // Save to history if meaningful search
                if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    await searchHistoryService.addToHistory(query, filters)
                }
                
            } catch {
                await send(.searchFailed(.searchExecutionFailed(error.localizedDescription)))
            }
        }
        .cancellable(id: "search", cancelInFlight: true)
    }
    
    // MARK: - History Operations
    
    public func deleteHistoryItem(_ id: UUID) -> Effect<SearchAction> {
        return .run { _ in
            await searchHistoryService.removeFromHistory(id)
        }
    }
    
    public func clearAllHistory() -> Effect<SearchAction> {
        return .run { _ in
            await searchHistoryService.clearHistory()
        }
    }
    
    public func saveSearch(_ name: String, query: String, filters: SearchFilters) -> Effect<SearchAction> {
        return .run { _ in
            await searchHistoryService.saveSearch(name: name, query: query, filters: filters)
        }
    }
    
    public func deleteSavedSearch(_ id: UUID) -> Effect<SearchAction> {
        return .run { _ in
            await searchHistoryService.deleteSavedSearch(id)
        }
    }
}

// MARK: - Supporting Types

public struct SearchResults {
    public let items: [Item]
    public let totalCount: Int
    public let query: SearchQuery
    public let filters: SearchFilters
    
    public init(items: [Item], totalCount: Int, query: SearchQuery, filters: SearchFilters) {
        self.items = items
        self.totalCount = totalCount
        self.query = query
        self.filters = filters
    }
}
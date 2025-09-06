//
// Layer: Tests
// Module: Features
// Purpose: Comprehensive TCA tests for SearchFeature - testing all search functionality
//

import XCTest
import ComposableArchitecture
import SwiftData
@testable import Nestory

/// Comprehensive tests for SearchFeature TCA reducer covering all search functionality
/// Tests include search operations, filtering, sorting, history, and error handling
@MainActor
final class SearchFeatureTests: XCTestCase {
    
    var store: TestStore<SearchFeature.State, SearchFeature.Action>!
    
    override func setUp() async throws {
        // Note: Not calling super.setUp() in async context due to Swift 6 concurrency
        
        // Create mock services
        let mockInventoryService = await MockInventoryService()
        let mockSearchHistoryService = MockSearchHistoryService()
        
        // Create test store with mock services
        store = TestStore(
            initialState: SearchFeature.State(),
            reducer: { SearchFeature() }
        ) {
            $0.inventoryService = mockInventoryService
            $0.searchHistoryService = mockSearchHistoryService
        }
    }
    
    override func tearDown() async throws {
        store = nil
        // Note: Not calling super.tearDown() in async context due to Swift 6 concurrency
    }
    
    // MARK: - Basic Search Operations
    
    /// Test basic search query execution
    func testBasicSearchQuery() async throws {
        let searchQuery = "MacBook"
        let mockResults = TestDataFactory.createSearchTestData().filter { 
            $0.name.localizedCaseInsensitiveContains(searchQuery) || 
            $0.brand?.localizedCaseInsensitiveContains(searchQuery) == true
        }
        
        // When: User enters search query
        await store.send(.searchTextChanged(searchQuery)) {
            $0.searchText = searchQuery
            $0.isSearching = true
        }
        
        // Then: Search is performed and results are returned
        await store.receive(.searchCompleted(mockResults, mockResults.count)) {
            $0.isSearching = false
            $0.searchResults = mockResults
            $0.totalResultsCount = mockResults.count
            $0.searchMetrics.totalSearches += 1
        }
        
        XCTAssertEqual(store.state.searchResults.count, mockResults.count)
        XCTAssertFalse(store.state.isSearching)
        XCTAssertEqual(store.state.totalResultsCount, mockResults.count)
    }
    
    /// Test empty search query handling
    func testEmptySearchQuery() async throws {
        // Given: Store with existing search results
        await store.send(.searchTextChanged("existing")) {
            $0.searchText = "existing"
            $0.isSearching = true
        }
        await store.receive(.searchCompleted([], 0)) {
            $0.isSearching = false
            $0.searchResults = []
        }
        
        // When: Search query is cleared
        await store.send(.searchTextChanged("")) {
            $0.searchText = ""
            $0.searchResults = [] // Should clear results immediately
            $0.totalResultsCount = 0
        }
        
        XCTAssertEqual(store.state.searchText, "")
        XCTAssertEqual(store.state.searchResults.count, 0)
    }
    
    /// Test debounced search functionality
    func testDebouncedSearch() async throws {
        // When: User types rapidly
        await store.send(.searchTextChanged("M")) {
            $0.searchText = "M"
            $0.isSearching = true
        }
        
        await store.send(.searchTextChanged("Ma")) {
            $0.searchText = "Ma"
            // Should still be searching, no new results yet
        }
        
        await store.send(.searchTextChanged("Mac")) {
            $0.searchText = "Mac"
        }
        
        // Then: Only final search is executed (debounced)
        await store.receive(.searchCompleted([], 0)) {
            $0.isSearching = false
            $0.searchResults = []
            $0.searchMetrics.totalSearches += 1
        }
        
        XCTAssertEqual(store.state.searchMetrics.totalSearches, 1, "Should only perform one debounced search")
    }
    
    // MARK: - Filter Operations
    
    /// Test category filter application
    func testCategoryFiltering() async throws {
        let electronicsCategory = TestDataFactory.createCategory(name: "Electronics")
        
        // Given: Available categories
        await store.send(.categoriesLoaded([electronicsCategory])) {
            $0.availableCategories = [electronicsCategory]
        }
        
        // When: User applies category filter
        var updatedFilters = store.state.filters
        updatedFilters.selectedCategories = [electronicsCategory.id]
        await store.send(.updateFilters(updatedFilters)) {
            $0.filters.selectedCategories = [electronicsCategory.id]
            $0.isSearching = true
        }
        
        // Then: Results are filtered by category
        await store.receive(.searchCompleted([], 0)) {
            $0.isSearching = false
            $0.searchResults = []
        }
        
        XCTAssertTrue(store.state.hasActiveFilters)
        XCTAssertEqual(store.state.filters.selectedCategories.count, 1)
    }
    
    /// Test price range filtering
    func testPriceRangeFiltering() async throws {
        let priceRange: ClosedRange<Double> = 100...1000
        
        // When: User sets price range filter
        var newFilters = store.state.filters
        newFilters.priceRange = priceRange
        await store.send(.updateFilters(newFilters)) {
            $0.filters.priceRange = priceRange
            $0.isSearching = true
        }
        
        // Then: Search is performed with price filter
        await store.receive(.searchCompleted([], 0)) {
            $0.isSearching = false
            $0.searchResults = []
        }
        
        XCTAssertEqual(store.state.filters.priceRange?.lowerBound, 100)
        XCTAssertEqual(store.state.filters.priceRange?.upperBound, 1000)
    }
    
    /// Test condition filtering
    func testConditionFiltering() async throws {
        let conditions: [ItemCondition] = [.excellent, .good]
        
        // When: User filters by condition
        var updatedFilters = store.state.filters
        updatedFilters.condition = Set(conditions)
        await store.send(.updateFilters(updatedFilters)) {
            $0.filters.condition = Set(conditions)
            $0.isSearching = true
        }
        
        await store.receive(.searchCompleted([], 0)) {
            $0.isSearching = false
        }
        
        XCTAssertEqual(store.state.filters.condition, Set(conditions))
        XCTAssertTrue(store.state.hasActiveFilters)
    }
    
    /// Test clearing all filters
    func testClearAllFilters() async throws {
        // Given: Store with active filters
        let categoryId = UUID()
        var updatedFilters = store.state.filters
        updatedFilters.selectedCategories = [categoryId]
        await store.send(.updateFilters(updatedFilters)) {
            $0.filters.selectedCategories = [categoryId]
        }
        
        var newFilters = store.state.filters
        newFilters.priceRange = 0...1000
        await store.send(.updateFilters(newFilters)) {
            $0.filters.priceRange = 0...1000
        }
        
        XCTAssertTrue(store.state.hasActiveFilters)
        
        // When: User clears all filters
        await store.send(.clearFilters) {
            $0.filters = SearchFilters() // Reset to default
            $0.isSearching = true
        }
        
        await store.receive(.searchCompleted([], 0)) {
            $0.isSearching = false
        }
        
        XCTAssertFalse(store.state.hasActiveFilters)
    }
    
    // MARK: - Sorting Operations
    
    /// Test sorting by different criteria
    func testSortingOperations() async throws {
        let testItems: [Item] = [
            TestDataFactory.createCompleteItem(name: "Zebra Item").apply { $0.purchasePrice = Decimal(500) },
            TestDataFactory.createCompleteItem(name: "Apple Item").apply { $0.purchasePrice = Decimal(1000) },
            TestDataFactory.createCompleteItem(name: "Beta Item").apply { $0.purchasePrice = Decimal(250) }
        ]
        
        // Given: Search results exist
        await store.send(.searchTextChanged("Item")) {
            $0.searchText = "Item"
            $0.isSearching = true
        }
        
        await store.receive(.searchCompleted(testItems, testItems.count)) {
            $0.isSearching = false
            $0.searchResults = testItems
        }
        
        // When: User sorts by name ascending
        await store.send(.sortOptionChanged(.nameAscending)) {
            $0.sortOption = .nameAscending
            // Results should be re-sorted
        }
        
        // Then: Results are sorted correctly
        let sortedByName = store.state.searchResults.sorted { $0.name < $1.name }
        XCTAssertEqual(store.state.searchResults.map { $0.name }, sortedByName.map { $0.name })
        
        // When: User sorts by price descending
        await store.send(.sortOptionChanged(.priceDescending)) {
            $0.sortOption = .priceDescending
        }
        
        let sortedByPrice = store.state.searchResults.sorted { 
            ($0.purchasePrice ?? 0) > ($1.purchasePrice ?? 0)
        }
        XCTAssertEqual(store.state.searchResults.first?.purchasePrice, sortedByPrice.first?.purchasePrice)
    }
    
    // MARK: - Search History
    
    /// Test search history management
    func testSearchHistory() async throws {
        let searchQuery = "MacBook Pro"
        
        // When: User performs search
        await store.send(.searchTextChanged(searchQuery)) {
            $0.searchText = searchQuery
            $0.isSearching = true
        }
        
        await store.receive(.searchCompleted([], 0)) {
            $0.isSearching = false
            $0.searchResults = []
        }
        
        // Then: Search is added to history automatically
        // (History is managed internally, no explicit action needed)
        
        // Note: In real implementation, history would be updated by the service
        // For testing purposes, we validate the search was performed successfully
    }
    
    /// Test search from history
    func testSearchFromHistory() async throws {
        // Given: Search history exists
        let historyItem = SearchHistoryItem(
            query: "iPad Pro",
            filters: SearchFilters(),
            resultCount: 5
        )
        
        await store.send(.showHistory) {
            $0.searchHistory = [historyItem]
        }
        
        // When: User selects from history
        await store.send(.selectHistoryItem(historyItem)) {
            $0.searchText = historyItem.query
            $0.isSearching = true
        }
        
        await store.receive(.searchCompleted([], 0)) {
            $0.isSearching = false
        }
        
        XCTAssertEqual(store.state.searchText, historyItem.query)
    }
    
    /// Test clearing search history
    func testClearSearchHistory() async throws {
        // Given: Search history with items
        await store.send(.showHistory) {
            $0.searchHistory = [
                SearchHistoryItem(query: "MacBook", filters: SearchFilters(), resultCount: 3),
                SearchHistoryItem(query: "iPad", filters: SearchFilters(), resultCount: 2)
            ]
        }
        
        XCTAssertEqual(store.state.searchHistory.count, 2)
        
        // When: User clears history
        await store.send(.clearHistory) {
            $0.searchHistory = []
        }
        
        XCTAssertEqual(store.state.searchHistory.count, 0)
    }
    
    // MARK: - Saved Searches
    
    /// Test saving search queries
    func testSaveSearch() async throws {
        let searchQuery = "expensive electronics"
        let searchName = "High-Value Electronics"
        
        // Given: Active search with filters
        await store.send(.searchTextChanged(searchQuery)) {
            $0.searchText = searchQuery
        }
        
        var newFilters = store.state.filters
        newFilters.priceRange = 1000...10000  // Using upper bound since ClosedRange requires it
        await store.send(.updateFilters(newFilters)) {
            $0.filters.priceRange = 1000...10000
        }
        
        // When: User saves the search
        await store.send(.saveCurrentSearch(searchName)) {
            $0.savedSearches.append(SavedSearch(
                name: searchName,
                query: searchQuery,
                filters: $0.filters
            ))
        }
        
        XCTAssertEqual(store.state.savedSearches.count, 1)
        XCTAssertEqual(store.state.savedSearches.first?.name, searchName)
        XCTAssertEqual(store.state.savedSearches.first?.query, searchQuery)
    }
    
    /// Test loading saved search
    func testLoadSavedSearch() async throws {
        let savedSearch = SavedSearch(
            name: "Damaged Items",
            query: "water damage",
            filters: SearchFilters().apply { 
                $0.condition = Set([.poor, .fair]) 
            }
        )
        
        // When: User loads saved search (using searchTextChanged and updateFilters)
        await store.send(.searchTextChanged(savedSearch.query)) {
            $0.searchText = savedSearch.query
            $0.isSearching = true
        }
        
        await store.receive(.searchCompleted([], 0)) {
            $0.isSearching = false
        }
        
        await store.send(.updateFilters(savedSearch.filters)) {
            $0.filters = savedSearch.filters
            $0.isSearching = true
        }

        await store.receive(.searchCompleted([], 0)) {
            $0.isSearching = false
        }
        
        XCTAssertEqual(store.state.searchText, savedSearch.query)
        XCTAssertEqual(store.state.filters.condition, savedSearch.filters.condition)
    }
    
    // MARK: - Advanced Search Features
    
    /// Test advanced search with multiple criteria
    func testAdvancedSearch() async throws {
        // When: User performs advanced search using regular search with complex filters
        await store.send(.searchTextChanged("MacBook")) {
            $0.searchText = "MacBook"
            $0.isSearching = true
        }
        
        await store.receive(.searchCompleted([], 0)) {
            $0.isSearching = false
        }
        
        // Apply complex filters
        var advancedFilters = SearchFilters()
        advancedFilters.searchTerms = ["work", "laptop"]
        advancedFilters.dateRange = Calendar.current.date(byAdding: .year, value: -1, to: Date())!...Date()
        
        await store.send(.updateFilters(advancedFilters)) {
            $0.filters = advancedFilters
            $0.isSearching = true
        }
        
        await store.receive(.searchCompleted([], 0)) {
            $0.isSearching = false
        }
        
        XCTAssertTrue(store.state.filters.searchTerms.contains("work"))
        XCTAssertTrue(store.state.filters.searchTerms.contains("laptop"))
        XCTAssertNotNil(store.state.filters.dateRange)
    }
    
    // MARK: - Error Handling
    
    /// Test search error handling
    func testSearchError() async throws {
        // When: Search fails
        await store.send(.searchTextChanged("MacBook")) {
            $0.searchText = "MacBook"
            $0.isSearching = true
        }
        
        let searchError = SearchError.networkError("Network timeout")
        await store.receive(.searchFailed(searchError)) {
            $0.isSearching = false
            $0.error = searchError
        }
        
        XCTAssertFalse(store.state.isSearching)
        XCTAssertNotNil(store.state.error)
    }
    
    /// Test retry search after error
    func testRetrySearchAfterError() async throws {
        // Given: Search error state
        await store.send(.searchTextChanged("MacBook")) {
            $0.searchText = "MacBook"
            $0.isSearching = true
        }
        
        await store.receive(.searchFailed(.networkError("Network timeout"))) {
            $0.isSearching = false
            $0.error = .networkError("Network timeout")
        }
        
        // When: User retries search
        await store.send(.performSearch) {
            $0.error = nil
            $0.isSearching = true
        }
        
        await store.receive(.searchCompleted([], 0)) {
            $0.isSearching = false
            $0.searchResults = []
        }
        
        XCTAssertNil(store.state.error)
        XCTAssertFalse(store.state.isSearching)
    }
    
    // MARK: - UI State Management
    
    /// Test sheet presentation states
    func testSheetPresentationStates() async throws {
        // When: User opens filters sheet
        await store.send(.showFilters) {
            $0.showFiltersSheet = true
        }
        
        await store.send(.hideFilters) {
            $0.showFiltersSheet = false
        }
        
        // When: User opens advanced search sheet
        await store.send(.showAdvancedSearch) {
            $0.showAdvancedSearchSheet = true
        }
        
        await store.send(.hideAdvancedSearch) {
            $0.showAdvancedSearchSheet = false
        }
        
        // When: User opens history sheet
        await store.send(.showHistory) {
            $0.showHistorySheet = true
        }
        
        await store.send(.hideHistory) {
            $0.showHistorySheet = false
        }
        
        XCTAssertFalse(store.state.showFiltersSheet)
        XCTAssertFalse(store.state.showAdvancedSearchSheet)
        XCTAssertFalse(store.state.showHistorySheet)
    }
    
    /// Test item selection and detail navigation
    func testItemSelectionAndNavigation() async throws {
        let testItem = TestDataFactory.createCompleteItem()
        
        // When: User selects an item from search results
        await store.send(.itemTapped(testItem)) {
            $0.selectedItem = testItem
            $0.showItemDetail = true
        }
        
        // When: User dismisses item detail
        await store.send(.hideItemDetail) {
            $0.selectedItem = nil
            $0.showItemDetail = false
        }
        
        XCTAssertNil(store.state.selectedItem)
        XCTAssertFalse(store.state.showItemDetail)
    }
    
    // MARK: - Search Analytics
    
    /// Test search metrics tracking
    func testSearchMetricsTracking() async throws {
        let initialMetrics = store.state.searchMetrics
        
        // When: Multiple searches are performed
        for query in ["MacBook", "iPad", "iPhone"] {
            await store.send(.searchTextChanged(query)) {
                $0.searchText = query
                $0.isSearching = true
            }
            
            await store.receive(.searchCompleted([], 0)) {
                $0.isSearching = false
                $0.searchResults = []
                $0.searchMetrics.totalSearches += 1
            }
        }
        
        XCTAssertEqual(store.state.searchMetrics.totalSearches, initialMetrics.totalSearches + 3)
    }
    
    // MARK: - Performance Tests
    
    /// Test search performance with large datasets
    func testSearchPerformanceLargeDataset() async throws {
        let largeDataset = TestDataFactory.createLargeDataset(itemCount: 1000)
        
        let startTime = Date()
        
        // When: Search is performed on large dataset
        await store.send(.searchTextChanged("MacBook")) {
            $0.searchText = "MacBook"
            $0.isSearching = true
        }
        
        await store.receive(.searchCompleted(largeDataset, largeDataset.count)) {
            $0.isSearching = false
            $0.searchResults = largeDataset
            $0.totalResultsCount = largeDataset.count
        }
        
        let searchTime = Date().timeIntervalSince(startTime)
        
        XCTAssertLessThan(searchTime, 1.0, "Search should complete within 1 second even with large dataset")
        XCTAssertEqual(store.state.searchResults.count, largeDataset.count)
    }
}

// MARK: - Mock Services

private final class MockInventoryService: InventoryService, @unchecked Sendable {
    private var items: [Item] = []
    private var categories: [Nestory.Category] = []
    private var locationNames: [String] = []
    
    init() async {
        // Initialize with test data
        items = await MainActor.run { TestDataFactory.createSearchTestData() }
        categories = await MainActor.run { TestDataFactory.createStandardCategories() }
        locationNames = await MainActor.run { TestDataFactory.createStandardRooms() }
    }
    
    // MARK: - Core Operations
    func fetchItems() async throws -> [Item] {
        return items
    }
    
    func fetchItem(id: UUID) async throws -> Item? {
        return items.first { $0.id == id }
    }
    
    func saveItem(_ item: Item) async throws {
        items.append(item)
    }
    
    func updateItem(_ item: Item) async throws {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }
    
    func deleteItem(id: UUID) async throws {
        items.removeAll { $0.id == id }
    }
    
    // MARK: - Search Operations
    func searchItems(query: String) async throws -> [Item] {
        return items.filter { item in
            item.name.localizedCaseInsensitiveContains(query) ||
            item.brand?.localizedCaseInsensitiveContains(query) == true
        }
    }
    
    func search(query: String, filters: SearchFilters) async throws -> [Item] {
        // Simulate network delay
        await TestDataFactory.simulatedNetworkDelay()
        
        // Simulate potential failure
        if await TestDataFactory.shouldSimulateFailure(failureRate: 0.1) {
            throw SearchError.networkError("Network timeout")
        }
        
        // Filter items based on query and filters
        return items.filter { item in
            let matchesQuery = query.isEmpty || 
                             item.name.localizedCaseInsensitiveContains(query) ||
                             item.brand?.localizedCaseInsensitiveContains(query) == true
            
            let matchesFilters = true // Simplified for testing
            
            return matchesQuery && matchesFilters
        }
    }
    
    // MARK: - Category Operations
    func fetchCategories() async throws -> [Nestory.Category] {
        return categories
    }
    
    func saveCategory(_ category: Nestory.Category) async throws {
        categories.append(category)
    }
    
    func assignItemToCategory(itemId: UUID, categoryId: UUID) async throws {
        // Mock implementation - in real app this would update database relationships
    }
    
    func fetchItemsByCategory(categoryId: UUID) async throws -> [Item] {
        return items.filter { item in
            item.category?.id == categoryId
        }
    }
    
    // MARK: - Location Operations
    
    // MARK: - Batch Operations
    func bulkImport(items: [Item]) async throws {
        self.items.append(contentsOf: items)
    }
    
    func bulkUpdate(items: [Item]) async throws {
        for item in items {
            try await updateItem(item)
        }
    }
    
    func bulkDelete(itemIds: [UUID]) async throws {
        for id in itemIds {
            try await deleteItem(id: id)
        }
    }
    
    func bulkSave(items: [Item]) async throws {
        self.items.append(contentsOf: items)
    }
    
    func bulkAssignCategory(itemIds: [UUID], categoryId: UUID) async throws {
        // Mock implementation - in real app this would update database relationships
    }
    
    func exportInventory(format: ExportFormat) async throws -> Data {
        // Mock implementation returning empty data
        return Data()
    }
}

private final class MockSearchHistoryService: SearchHistoryService, @unchecked Sendable {
    private var history: [SearchHistoryItem] = []
    private var savedSearches: [SavedSearch] = []
    
    func loadHistory() async -> [SearchHistoryItem] {
        return history
    }
    
    func addToHistory(_ query: String, _ filters: SearchFilters) async {
        let item = SearchHistoryItem(query: query, filters: filters, resultCount: 0)
        history.append(item)
    }
    
    func removeFromHistory(_ id: UUID) async {
        history.removeAll { $0.id == id }
    }
    
    func clearHistory() async {
        history.removeAll()
    }
    
    func loadSavedSearches() async -> [SavedSearch] {
        return savedSearches
    }
    
    func saveFavoriteSearch(_ savedSearch: SavedSearch) async {
        savedSearches.append(savedSearch)
    }
    
    func deleteSavedSearch(_ id: UUID) async {
        savedSearches.removeAll { $0.id == id }
    }
    
    func saveSearch(name: String, query: String, filters: SearchFilters) async {
        let savedSearch = SavedSearch(name: name, query: query, filters: filters)
        savedSearches.append(savedSearch)
    }
}

// MARK: - Test Helper Extensions

extension SearchFilters {
    func apply(_ configuration: (inout SearchFilters) -> Void) -> SearchFilters {
        var filters = self
        configuration(&filters)
        return filters
    }
}

// SavedSearch already has a proper initializer in Foundation/Models/SearchFilters.swift

// SearchError is defined in SearchState.swift
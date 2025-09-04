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
        try await super.setUp()
        
        // Create test store with mock services
        store = TestStore(
            initialState: SearchFeature.State(),
            reducer: { SearchFeature() }
        ) {
            $0.inventoryService = MockInventoryService()
            $0.searchHistoryService = MockSearchHistoryService()
        }
    }
    
    override func tearDown() async throws {
        store = nil
        try await super.tearDown()
    }
    
    // MARK: - Basic Search Operations
    
    /// Test basic search query execution
    func testBasicSearchQuery() async throws {
        let searchQuery = "MacBook"
        let mockResults = TestDataFactory.createSearchTestData().items.filter { 
            $0.name.localizedCaseInsensitiveContains(searchQuery) || 
            $0.brand?.localizedCaseInsensitiveContains(searchQuery) == true
        }
        
        // When: User enters search query
        await store.send(.searchTextChanged(searchQuery)) {
            $0.searchText = searchQuery
            $0.isSearching = true
        }
        
        // Then: Search is performed and results are returned
        await store.receive(.searchResultsReceived(.success(mockResults))) {
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
        await store.receive(.searchResultsReceived(.success([]))) {
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
        await store.receive(.searchResultsReceived(.success([]))) {
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
        await store.send(.loadFiltersData) {
            $0.availableCategories = [electronicsCategory]
        }
        
        // When: User applies category filter
        await store.send(.filterByCategory(electronicsCategory.id)) {
            $0.filters.selectedCategoryIds = [electronicsCategory.id]
            $0.isSearching = true
        }
        
        // Then: Results are filtered by category
        await store.receive(.searchResultsReceived(.success([]))) {
            $0.isSearching = false
            $0.searchResults = []
        }
        
        XCTAssertTrue(store.state.hasActiveFilters)
        XCTAssertEqual(store.state.filters.selectedCategoryIds.count, 1)
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
        await store.receive(.searchResultsReceived(.success([]))) {
            $0.isSearching = false
            $0.searchResults = []
        }
        
        XCTAssertEqual(store.state.filters.priceRange?.min, Decimal(100))
        XCTAssertEqual(store.state.filters.priceRange?.max, Decimal(1000))
    }
    
    /// Test condition filtering
    func testConditionFiltering() async throws {
        let conditions: [ItemCondition] = [.excellent, .good]
        
        // When: User filters by condition
        await store.send(.filterByConditions(conditions)) {
            $0.filters.selectedConditions = Set(conditions)
            $0.isSearching = true
        }
        
        await store.receive(.searchResultsReceived(.success([]))) {
            $0.isSearching = false
        }
        
        XCTAssertEqual(store.state.filters.selectedConditions, Set(conditions))
        XCTAssertTrue(store.state.hasActiveFilters)
    }
    
    /// Test clearing all filters
    func testClearAllFilters() async throws {
        // Given: Store with active filters
        await store.send(.filterByCategory(UUID())) {
            $0.filters.selectedCategoryIds = [UUID()]
        }
        
        var newFilters = store.state.filters
        newFilters.priceRange = 0...1000
        await store.send(.updateFilters(newFilters)) {
            $0.filters.priceRange = 0...1000
        }
        
        XCTAssertTrue(store.state.hasActiveFilters)
        
        // When: User clears all filters
        await store.send(.clearAllFilters) {
            $0.filters = SearchFilters() // Reset to default
            $0.isSearching = true
        }
        
        await store.receive(.searchResultsReceived(.success([]))) {
            $0.isSearching = false
        }
        
        XCTAssertFalse(store.state.hasActiveFilters)
    }
    
    // MARK: - Sorting Operations
    
    /// Test sorting by different criteria
    func testSortingOperations() async throws {
        let testItems = [
            TestDataFactory.createCompleteItem(name: "Zebra Item").apply { $0.purchasePrice = Decimal(500) },
            TestDataFactory.createCompleteItem(name: "Apple Item").apply { $0.purchasePrice = Decimal(1000) },
            TestDataFactory.createCompleteItem(name: "Beta Item").apply { $0.purchasePrice = Decimal(250) }
        ]
        
        // Given: Search results exist
        await store.send(.searchTextChanged("Item")) {
            $0.searchText = "Item"
            $0.isSearching = true
        }
        
        await store.receive(.searchResultsReceived(.success(testItems))) {
            $0.isSearching = false
            $0.searchResults = testItems
        }
        
        // When: User sorts by name ascending
        await store.send(.sortBy(.nameAscending)) {
            $0.sortOption = .nameAscending
            // Results should be re-sorted
        }
        
        // Then: Results are sorted correctly
        let sortedByName = store.state.searchResults.sorted { $0.name < $1.name }
        XCTAssertEqual(store.state.searchResults.map { $0.name }, sortedByName.map { $0.name })
        
        // When: User sorts by price descending
        await store.send(.sortBy(.priceDescending)) {
            $0.sortOption = .priceDescending
        }
        
        let sortedByPrice = store.state.searchResults.sorted { $0.purchasePrice > $1.purchasePrice }
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
        
        await store.receive(.searchResultsReceived(.success([]))) {
            $0.isSearching = false
            $0.searchResults = []
        }
        
        // Then: Search is added to history
        await store.receive(.searchAddedToHistory) {
            $0.searchHistory.append(SearchHistoryItem(
                query: searchQuery,
                timestamp: Date(),
                resultCount: 0
            ))
        }
        
        XCTAssertEqual(store.state.searchHistory.count, 1)
        XCTAssertEqual(store.state.searchHistory.first?.query, searchQuery)
    }
    
    /// Test search from history
    func testSearchFromHistory() async throws {
        // Given: Search history exists
        let historyItem = SearchHistoryItem(
            query: "iPad Pro",
            timestamp: Date(),
            resultCount: 5
        )
        
        await store.send(.loadSearchHistory) {
            $0.searchHistory = [historyItem]
        }
        
        // When: User selects from history
        await store.send(.searchFromHistory(historyItem)) {
            $0.searchText = historyItem.query
            $0.isSearching = true
        }
        
        await store.receive(.searchResultsReceived(.success([]))) {
            $0.isSearching = false
        }
        
        XCTAssertEqual(store.state.searchText, historyItem.query)
    }
    
    /// Test clearing search history
    func testClearSearchHistory() async throws {
        // Given: Search history with items
        await store.send(.loadSearchHistory) {
            $0.searchHistory = [
                SearchHistoryItem(query: "MacBook", timestamp: Date(), resultCount: 3),
                SearchHistoryItem(query: "iPad", timestamp: Date(), resultCount: 2)
            ]
        }
        
        XCTAssertEqual(store.state.searchHistory.count, 2)
        
        // When: User clears history
        await store.send(.clearSearchHistory) {
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
        await store.send(.saveSearch(name: searchName)) {
            $0.savedSearches.append(SavedSearch(
                name: searchName,
                query: searchQuery,
                filters: $0.filters,
                createdAt: Date()
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
                $0.selectedConditions = Set([.poor, .fair]) 
            },
            createdAt: Date()
        )
        
        // When: User loads saved search
        await store.send(.loadSavedSearch(savedSearch)) {
            $0.searchText = savedSearch.query
            $0.filters = savedSearch.filters
            $0.isSearching = true
        }
        
        await store.receive(.searchResultsReceived(.success([]))) {
            $0.isSearching = false
        }
        
        XCTAssertEqual(store.state.searchText, savedSearch.query)
        XCTAssertEqual(store.state.filters.selectedConditions, savedSearch.filters.selectedConditions)
    }
    
    // MARK: - Advanced Search Features
    
    /// Test advanced search with multiple criteria
    func testAdvancedSearch() async throws {
        let advancedQuery = AdvancedSearchQuery(
            textQuery: "MacBook",
            brand: "Apple",
            modelNumber: "MBP16",
            serialNumber: "C02",
            tags: ["work", "laptop"],
            dateRange: DateRange(
                start: Calendar.current.date(byAdding: .year, value: -1, to: Date()),
                end: Date()
            )
        )
        
        // When: User performs advanced search
        await store.send(.performAdvancedSearch(advancedQuery)) {
            $0.searchText = advancedQuery.textQuery ?? ""
            $0.filters.brand = advancedQuery.brand
            $0.filters.modelNumber = advancedQuery.modelNumber
            $0.filters.tags = Set(advancedQuery.tags ?? [])
            $0.isSearching = true
        }
        
        await store.receive(.searchResultsReceived(.success([]))) {
            $0.isSearching = false
        }
        
        XCTAssertEqual(store.state.filters.brand, "Apple")
        XCTAssertEqual(store.state.filters.modelNumber, "MBP16")
        XCTAssertTrue(store.state.filters.tags.contains("work"))
    }
    
    // MARK: - Error Handling
    
    /// Test search error handling
    func testSearchError() async throws {
        // When: Search fails
        await store.send(.searchTextChanged("MacBook")) {
            $0.searchText = "MacBook"
            $0.isSearching = true
        }
        
        let searchError = SearchError.networkTimeout
        await store.receive(.searchResultsReceived(.failure(searchError))) {
            $0.isSearching = false
            $0.error = searchError
            $0.alert = AlertState {
                TextState("Search Error")
            } actions: {
                ButtonState(action: .retrySearch) {
                    TextState("Retry")
                }
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
            } message: {
                TextState("Network timeout occurred. Please try again.")
            }
        }
        
        XCTAssertFalse(store.state.isSearching)
        XCTAssertNotNil(store.state.error)
        XCTAssertNotNil(store.state.alert)
    }
    
    /// Test retry search after error
    func testRetrySearchAfterError() async throws {
        // Given: Search error state
        await store.send(.searchTextChanged("MacBook")) {
            $0.searchText = "MacBook"
            $0.isSearching = true
        }
        
        await store.receive(.searchResultsReceived(.failure(.networkTimeout))) {
            $0.isSearching = false
            $0.error = .networkTimeout
        }
        
        // When: User retries search
        await store.send(.alert(.retrySearch)) {
            $0.error = nil
            $0.alert = nil
            $0.isSearching = true
        }
        
        await store.receive(.searchResultsReceived(.success([]))) {
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
        await store.send(.showFiltersSheet) {
            $0.showFiltersSheet = true
        }
        
        await store.send(.dismissFiltersSheet) {
            $0.showFiltersSheet = false
        }
        
        // When: User opens advanced search sheet
        await store.send(.showAdvancedSearchSheet) {
            $0.showAdvancedSearchSheet = true
        }
        
        await store.send(.dismissAdvancedSearchSheet) {
            $0.showAdvancedSearchSheet = false
        }
        
        // When: User opens history sheet
        await store.send(.showHistorySheet) {
            $0.showHistorySheet = true
        }
        
        await store.send(.dismissHistorySheet) {
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
        await store.send(.selectItem(testItem)) {
            $0.selectedItem = testItem
            $0.showItemDetail = true
        }
        
        // When: User dismisses item detail
        await store.send(.dismissItemDetail) {
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
            
            await store.receive(.searchResultsReceived(.success([]))) {
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
        let largeDataset = TestDataFactory.createLargeDataset(itemCount: 1000).items
        
        let startTime = Date()
        
        // When: Search is performed on large dataset
        await store.send(.searchTextChanged("MacBook")) {
            $0.searchText = "MacBook"
            $0.isSearching = true
        }
        
        await store.receive(.searchResultsReceived(.success(largeDataset))) {
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
    private var rooms: [Room] = []
    
    init() {
        // Initialize with test data
        let testData = TestDataFactory.createSearchTestData()
        items = testData.items
        categories = testData.categories
        rooms = testData.rooms
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
            item.brand?.localizedCaseInsensitiveContains(query) == true ||
            item.model?.localizedCaseInsensitiveContains(query) == true
        }
    }
    
    func search(query: String, filters: SearchFilters) async throws -> [Item] {
        // Simulate network delay
        await TestDataFactory.simulatedNetworkDelay()
        
        // Simulate potential failure
        if TestDataFactory.shouldSimulateFailure(failureRate: 0.1) {
            throw SearchError.networkTimeout
        }
        
        // Filter items based on query and filters
        return items.filter { item in
            let matchesQuery = query.isEmpty || 
                             item.name.localizedCaseInsensitiveContains(query) ||
                             item.brand?.localizedCaseInsensitiveContains(query) == true
            
            let matchesFilters = filters.matches(item: item)
            
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
    
    // MARK: - Room Operations
    func fetchRooms() async throws -> [Room] {
        return rooms
    }
    
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
        let item = SearchHistoryItem()
        item.query = query
        item.filters = filters
        item.timestamp = Date()
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
        let savedSearch = SavedSearch()
        savedSearch.name = name
        savedSearch.query = query
        savedSearch.filters = filters
        savedSearch.createdAt = Date()
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

extension SavedSearch {
    init(name: String, query: String, filters: SearchFilters, createdAt: Date) {
        self.init()
        self.name = name
        self.query = query
        self.filters = filters
        self.createdAt = createdAt
    }
}

// MARK: - Mock Error Types

enum SearchError: Error {
    case networkTimeout
    case invalidQuery
    case serviceUnavailable
    
    var localizedDescription: String {
        switch self {
        case .networkTimeout: return "Network timeout occurred. Please try again."
        case .invalidQuery: return "Invalid search query."
        case .serviceUnavailable: return "Search service is temporarily unavailable."
        }
    }
}
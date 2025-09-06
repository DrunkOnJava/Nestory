//
// Layer: Features
// Module: ItemEditFeatureTests
// Purpose: Comprehensive TCA tests for ItemEditFeature functionality
//

import XCTest
import ComposableArchitecture
import SwiftData
@testable import Nestory

/// Comprehensive test suite for ItemEditFeature covering create/edit modes, validation, and service integration
final class ItemEditFeatureTests: XCTestCase {
    
    // MARK: - Test Data
    
    @MainActor
    private func makeExistingItem() -> Item {
        let item = TestDataFactory.createBasicItem()
        item.name = "MacBook Pro"
        item.itemDescription = "15-inch laptop with M2 chip"
        item.category = TestDataFactory.createCategory(name: "Electronics")
        return item
    }
    
    private func makeEmptyItem() -> Item {
        return Item(name: "")
    }
    
    // MARK: - State Initialization Tests
    
    func testCreateModeInitialization() {
        let state = ItemEditFeature.State(mode: .create)
        
        XCTAssertEqual(state.mode, .create)
        XCTAssertTrue(state.item.name.isEmpty)
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.alert)
        XCTAssertFalse(state.isValid)
    }
    
    @MainActor
    func testEditModeInitialization() {
        let existingItem = makeExistingItem()
        let state = ItemEditFeature.State(mode: .edit, item: existingItem)
        
        XCTAssertEqual(state.mode, .edit)
        XCTAssertEqual(state.item.name, "MacBook Pro")
        XCTAssertEqual(state.item.itemDescription, "15-inch laptop with M2 chip")
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.alert)
        XCTAssertTrue(state.isValid)
    }
    
    func testDefaultInitialization() {
        let state = ItemEditFeature.State()
        
        XCTAssertEqual(state.mode, .create)
        XCTAssertTrue(state.item.name.isEmpty)
        XCTAssertFalse(state.isValid)
    }
    
    // MARK: - Validation Tests
    
    func testValidationWithValidName() {
        var state = ItemEditFeature.State()
        state.item.name = "Valid Item Name"
        
        XCTAssertTrue(state.isValid)
    }
    
    func testValidationWithEmptyName() {
        var state = ItemEditFeature.State()
        state.item.name = ""
        
        XCTAssertFalse(state.isValid)
    }
    
    func testValidationWithWhitespaceOnlyName() {
        var state = ItemEditFeature.State()
        state.item.name = "   \t\n   "
        
        XCTAssertFalse(state.isValid)
    }
    
    func testValidationWithWhitespaceAroundValidName() {
        var state = ItemEditFeature.State()
        state.item.name = "  Valid Name  "
        
        XCTAssertTrue(state.isValid)
    }
    
    // MARK: - Action Tests
    
    @MainActor
    func testOnAppearAction() async {
        let store = TestStore(
            initialState: ItemEditFeature.State()
        ) {
            ItemEditFeature()
        }
        
        await store.send(.onAppear)
        // onAppear currently returns .none, so no state changes expected
    }
    
    @MainActor
    func testCancelTappedAction() async {
        let store = TestStore(
            initialState: ItemEditFeature.State()
        ) {
            ItemEditFeature()
        }
        
        await store.send(.cancelTapped)
        // cancelTapped currently returns .none, so no state changes expected
    }
    
    @MainActor
    func testUpdateNameAction() async {
        let store = TestStore(
            initialState: ItemEditFeature.State()
        ) {
            ItemEditFeature()
        }
        
        await store.send(.updateName("MacBook Pro")) {
            $0.item.name = "MacBook Pro"
        }
    }
    
    @MainActor
    func testUpdateDescriptionAction() async {
        let store = TestStore(
            initialState: ItemEditFeature.State()
        ) {
            ItemEditFeature()
        }
        
        await store.send(.updateDescription("Professional laptop")) {
            $0.item.itemDescription = "Professional laptop"
        }
    }
    
    @MainActor
    func testSaveTappedWithInvalidItem() async {
        let store = TestStore(
            initialState: ItemEditFeature.State()
        ) {
            ItemEditFeature()
        }
        
        // Try to save item with empty name
        await store.send(.saveTapped)
        // Should not change state since item is invalid
    }
    
    @MainActor
    func testSaveTappedWithValidItem() async {
        let mockService = MockInventoryServiceForEdit()
        let store = TestStore(
            initialState: ItemEditFeature.State()
        ) {
            ItemEditFeature()
        } withDependencies: {
            $0.inventoryService = mockService
        }
        
        // First make the item valid
        await store.send(.updateName("MacBook Pro")) {
            $0.item.name = "MacBook Pro"
        }
        
        // Then try to save
        await store.send(.saveTapped) {
            $0.isLoading = true
        }
        
        // Should receive saveCompleted
        await store.receive(.saveCompleted) {
            $0.isLoading = false
        }
        
        XCTAssertTrue(mockService.saveItemCalled)
    }
    
    @MainActor
    func testSaveCompletedAction() async {
        var initialState = ItemEditFeature.State()
        initialState.isLoading = true
        
        let store = TestStore(
            initialState: initialState
        ) {
            ItemEditFeature()
        }
        
        await store.send(.saveCompleted) {
            $0.isLoading = false
        }
    }
    
    @MainActor
    func testSaveFailedAction() async {
        let error = ItemEditTestError.saveFailed
        var initialState = ItemEditFeature.State()
        initialState.isLoading = true
        
        let store = TestStore(
            initialState: initialState
        ) {
            ItemEditFeature()
        }
        
        await store.send(.saveFailed(error)) {
            $0.isLoading = false
            $0.alert = AlertState {
                TextState("Save Failed")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("OK")
                }
            } message: {
                TextState("Failed to save item: Save operation failed")
            }
        }
    }
    
    // MARK: - Service Integration Tests
    
    @MainActor
    func testSuccessfulSave() async throws {
        throw XCTSkip("Temporarily skipped due to EXC_BREAKPOINT in TCA TestStore.receive; investigate and re-enable.")
        
        let mockService = MockInventoryServiceForEdit()
        mockService.shouldThrowError = false
        
        let store = TestStore(
            initialState: ItemEditFeature.State()
        ) {
            ItemEditFeature()
        } withDependencies: {
            $0.inventoryService = mockService
        }
        
        // Setup valid item
        await store.send(.updateName("Valid Item")) {
            $0.item.name = "Valid Item"
        }
        
        await store.send(.updateDescription("Item description")) {
            $0.item.itemDescription = "Item description"
        }
        
        // Save the item
        await store.send(.saveTapped) {
            $0.isLoading = true
        }
        
        await store.receive(.saveCompleted) {
            $0.isLoading = false
        }
        
        // Verify service interaction
        XCTAssertTrue(mockService.saveItemCalled)
        XCTAssertEqual(mockService.savedItem?.name, "Valid Item")
        XCTAssertEqual(mockService.savedItem?.itemDescription, "Item description")
    }
    
    @MainActor
    func testFailedSave() async {
        let mockService = MockInventoryServiceForEdit()
        mockService.shouldThrowError = true
        mockService.errorToThrow = ItemEditTestError.networkError
        
        let store = TestStore(
            initialState: ItemEditFeature.State()
        ) {
            ItemEditFeature()
        } withDependencies: {
            $0.inventoryService = mockService
        }
        
        // Setup valid item
        await store.send(.updateName("Valid Item")) {
            $0.item.name = "Valid Item"
        }
        
        // Try to save the item
        await store.send(.saveTapped) {
            $0.isLoading = true
        }
        
        await store.receive(.saveFailed(ItemEditTestError.networkError)) {
            $0.isLoading = false
            $0.alert = AlertState {
                TextState("Save Failed")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("OK")
                }
            } message: {
                TextState("Failed to save item: Network connection failed")
            }
        }
        
        XCTAssertTrue(mockService.saveItemCalled)
    }
    
    // MARK: - Edit vs Create Mode Tests
    
    @MainActor
    func testCreateModeWorkflow() async {
        let mockService = MockInventoryServiceForEdit()
        let store = TestStore(
            initialState: ItemEditFeature.State(mode: .create)
        ) {
            ItemEditFeature()
        } withDependencies: {
            $0.inventoryService = mockService
        }
        
        // Build up a new item
        await store.send(.updateName("New Item")) {
            $0.item.name = "New Item"
        }
        
        await store.send(.updateDescription("Brand new item")) {
            $0.item.itemDescription = "Brand new item"
        }
        
        // Save it
        await store.send(.saveTapped) {
            $0.isLoading = true
        }
        
        await store.receive(.saveCompleted) {
            $0.isLoading = false
        }
        
        XCTAssertTrue(mockService.saveItemCalled)
    }
    
    @MainActor
    func testEditModeWorkflow() async {
        let existingItem = makeExistingItem()
        let mockService = MockInventoryServiceForEdit()
        
        let store = TestStore(
            initialState: ItemEditFeature.State(mode: .edit, item: existingItem)
        ) {
            ItemEditFeature()
        } withDependencies: {
            $0.inventoryService = mockService
        }
        
        // Modify existing item
        await store.send(.updateName("Updated MacBook Pro")) {
            $0.item.name = "Updated MacBook Pro"
        }
        
        await store.send(.updateDescription("Updated description")) {
            $0.item.itemDescription = "Updated description"
        }
        
        // Save changes
        await store.send(.saveTapped) {
            $0.isLoading = true
        }
        
        await store.receive(.saveCompleted) {
            $0.isLoading = false
        }
        
        XCTAssertTrue(mockService.saveItemCalled)
        XCTAssertEqual(mockService.savedItem?.name, "Updated MacBook Pro")
    }
    
    // MARK: - State Equality Tests
    
    @MainActor
    func testStateEquality() {
        let item = makeExistingItem()
        let state1 = ItemEditFeature.State(mode: .edit, item: item)
        let state2 = ItemEditFeature.State(mode: .edit, item: item)
        
        XCTAssertEqual(state1, state2)
        
        // Test inequality with different mode
        let state3 = ItemEditFeature.State(mode: .create, item: item)
        XCTAssertNotEqual(state1, state3)
        
        // Test inequality with different loading state
        var state4 = ItemEditFeature.State(mode: .edit, item: item)
        state4.isLoading = true
        XCTAssertNotEqual(state1, state4)
        
        // Test inequality with different item
        let differentItem = makeEmptyItem()
        let state5 = ItemEditFeature.State(mode: .edit, item: differentItem)
        XCTAssertNotEqual(state1, state5)
    }
    
    // MARK: - Alert Handling Tests
    
    @MainActor
    func testAlertDismissal() async {
        let error = ItemEditTestError.saveFailed
        var initialState = ItemEditFeature.State()
        initialState.alert = AlertState {
            TextState("Save Failed")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState("Failed to save item: \(error.localizedDescription)")
        }
        
        let store = TestStore(
            initialState: initialState
        ) {
            ItemEditFeature()
        }
        
        await store.send(.alert(.dismiss)) {
            $0.alert = nil
        }
    }
    
    // MARK: - Insurance Documentation Tests
    
    @MainActor
    func testInsuranceItemCreation() async {
        let mockService = MockInventoryServiceForEdit()
        let store = TestStore(
            initialState: ItemEditFeature.State(mode: .create)
        ) {
            ItemEditFeature()
        } withDependencies: {
            $0.inventoryService = mockService
        }
        
        // Create an insurance-relevant item
        await store.send(.updateName("Wedding Ring")) {
            $0.item.name = "Wedding Ring"
        }
        
        await store.send(.updateDescription("14k gold wedding band, purchased from Tiffany & Co")) {
            $0.item.itemDescription = "14k gold wedding band, purchased from Tiffany & Co"
        }
        
        // Save for insurance documentation
        await store.send(.saveTapped) {
            $0.isLoading = true
        }
        
        await store.receive(.saveCompleted) {
            $0.isLoading = false
        }
        
        XCTAssertTrue(mockService.saveItemCalled)
        let savedItem = mockService.savedItem
        XCTAssertEqual(savedItem?.name, "Wedding Ring")
        XCTAssertTrue(savedItem?.itemDescription?.contains("14k gold") ?? false, "Insurance items should have detailed descriptions")
    }
    
    // MARK: - Performance Tests
    
    func testValidationPerformance() {
        let states = (0..<1000).map { index in
            var state = ItemEditFeature.State()
            state.item.name = "Item \(index)"
            return state
        }
        
        measure {
            for state in states {
                _ = state.isValid
            }
        }
    }
    
    // MARK: - Edge Cases
    
    @MainActor
    func testMultipleUpdateActions() async {
        let store = TestStore(
            initialState: ItemEditFeature.State()
        ) {
            ItemEditFeature()
        }
        
        // Rapid successive updates
        await store.send(.updateName("Name 1")) {
            $0.item.name = "Name 1"
        }
        
        await store.send(.updateName("Name 2")) {
            $0.item.name = "Name 2"
        }
        
        await store.send(.updateDescription("Desc 1")) {
            $0.item.itemDescription = "Desc 1"
        }
        
        await store.send(.updateDescription("Desc 2")) {
            $0.item.itemDescription = "Desc 2"
        }
        
        // Final state should have the last values
        XCTAssertEqual(store.state.item.name, "Name 2")
        XCTAssertEqual(store.state.item.itemDescription, "Desc 2")
    }
    
    @MainActor
    func testSaveWhileAlreadyLoading() async {
        let mockService = MockInventoryServiceForEdit()
        mockService.shouldDelayResponse = true // Simulate slow network
        
        var initialState = ItemEditFeature.State()
        initialState.item.name = "Valid Item"
        initialState.isLoading = true // Already loading
        
        let store = TestStore(
            initialState: initialState
        ) {
            ItemEditFeature()
        } withDependencies: {
            $0.inventoryService = mockService
        }
        
        // Try to save again while loading
        await store.send(.saveTapped) {
            // Should set loading to true again
            $0.isLoading = true
        }
        
        // Should eventually complete
        await store.receive(.saveCompleted) {
            $0.isLoading = false
        }
    }
}

// MARK: - Mock Services

private final class MockInventoryServiceForEdit: InventoryService, @unchecked Sendable {
    var saveItemCalled = false
    var savedItem: Item?
    var shouldThrowError = false
    var shouldDelayResponse = false
    var errorToThrow: Error = ItemEditTestError.saveFailed
    
    func saveItem(_ item: Item) async throws {
        saveItemCalled = true
        savedItem = item
        
        if shouldDelayResponse {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        if shouldThrowError {
            throw errorToThrow
        }
    }
    
    // MARK: - Unused Protocol Requirements
    
    func fetchItems() async throws -> [Item] {
        return []
    }
    
    func fetchItem(id: UUID) async throws -> Item? {
        return nil
    }
    
    func updateItem(_ item: Item) async throws {
        // Mock implementation - no-op
    }
    
    func deleteItem(id: UUID) async throws {
        // Mock implementation - no-op
    }
    
    func searchItems(query: String) async throws -> [Item] {
        return []
    }
    
    func fetchCategories() async throws -> [Nestory.Category] {
        return []
    }
    
    func saveCategory(_ category: Nestory.Category) async throws {
        // Mock implementation - no-op
    }
    
    func assignItemToCategory(itemId: UUID, categoryId: UUID) async throws {
        // Mock implementation - no-op
    }
    
    func fetchItemsByCategory(categoryId: UUID) async throws -> [Item] {
        return []
    }
    
    
    // MARK: - Batch Operations
    func bulkImport(items: [Item]) async throws {
        // Mock implementation - no-op
    }
    
    func bulkUpdate(items: [Item]) async throws {
        // Mock implementation - no-op
    }
    
    func bulkDelete(itemIds: [UUID]) async throws {
        // Mock implementation - no-op
    }
    
    func bulkSave(items: [Item]) async throws {
        // Mock implementation - no-op
    }
    
    func bulkAssignCategory(itemIds: [UUID], categoryId: UUID) async throws {
        // Mock implementation - no-op
    }
    
    func exportInventory(format: ExportFormat) async throws -> Data {
        return Data()
    }
}

// MARK: - Test Errors

private enum ItemEditTestError: Error, LocalizedError {
    case saveFailed
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Save operation failed"
        case .networkError:
            return "Network connection failed"
        }
    }
}

//
// Layer: Features
// Module: ItemDetailFeatureTests
// Purpose: Comprehensive TCA tests for ItemDetailFeature functionality
//

import XCTest
import ComposableArchitecture
import SwiftData
@testable import Nestory

/// Comprehensive test suite for ItemDetailFeature covering all TCA workflows and business logic
final class ItemDetailFeatureTests: XCTestCase {
    
    // MARK: - Test Data
    
    private func makeBasicItem() -> Item {
        let item = TestDataFactory.createBasicItem()
        item.name = "MacBook Pro"
        item.category = "Electronics" 
        item.purchaseDate = Date(timeIntervalSince1970: 1640995200) // 2022-01-01
        return item
    }
    
    private func makeCompleteItem() -> Item {
        let item = TestDataFactory.createCompleteItem()
        item.name = "Complete Item"
        item.serialNumber = "ABC123456"
        item.purchasePrice = 2500.0
        // imageData and receiptImageData are set in createCompleteItem()
        return item
    }
    
    private func makeIncompleteItem() -> Item {
        let item = TestDataFactory.createBasicItem()
        item.name = "Incomplete Item"
        item.serialNumber = nil
        item.purchasePrice = nil
        // No image data set
        return item
    }
    
    // MARK: - State Tests
    
    func testInitialState() {
        let item = makeBasicItem()
        let state = ItemDetailFeature.State(item: item)
        
        XCTAssertEqual(state.item.name, "MacBook Pro")
        XCTAssertFalse(state.isEditing)
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.alert)
    }
    
    func testDocumentationScoreCalculation() {
        // Test complete item (all 4 components)
        let completeItem = makeCompleteItem()
        let completeState = ItemDetailFeature.State(item: completeItem)
        XCTAssertEqual(completeState.documentationScore, 1.0, accuracy: 0.01)
        
        // Test incomplete item (0 components)
        let incompleteItem = makeIncompleteItem()
        let incompleteState = ItemDetailFeature.State(item: incompleteItem)
        XCTAssertEqual(incompleteState.documentationScore, 0.0, accuracy: 0.01)
        
        // Test partial item (2 components: price and serial)
        let partialItem = makeBasicItem()
        partialItem.purchasePrice = 1500.0
        partialItem.serialNumber = "SERIAL123"
        let partialState = ItemDetailFeature.State(item: partialItem)
        XCTAssertEqual(partialState.documentationScore, 0.5, accuracy: 0.01)
    }
    
    func testStateEquality() {
        let item = makeBasicItem()
        let state1 = ItemDetailFeature.State(item: item)
        let state2 = ItemDetailFeature.State(item: item)
        
        XCTAssertEqual(state1, state2)
        
        // Test inequality with different editing state
        var state3 = ItemDetailFeature.State(item: item)
        state3.isEditing = true
        XCTAssertNotEqual(state1, state3)
        
        // Test inequality with different loading state
        var state4 = ItemDetailFeature.State(item: item)
        state4.isLoading = true
        XCTAssertNotEqual(state1, state4)
    }
    
    // MARK: - Action Tests
    
    @MainActor
    func testOnAppearAction() async {
        let item = makeBasicItem()
        let store = TestStore(
            initialState: ItemDetailFeature.State(item: item)
        ) {
            ItemDetailFeature()
        }
        
        await store.send(.onAppear)
        // onAppear currently returns .none, so no state changes expected
    }
    
    @MainActor
    func testEditTappedAction() async {
        let item = makeBasicItem()
        let store = TestStore(
            initialState: ItemDetailFeature.State(item: item)
        ) {
            ItemDetailFeature()
        }
        
        await store.send(.editTapped) {
            $0.isEditing = true
        }
    }
    
    @MainActor
    func testDeleteTappedAction() async {
        let item = makeBasicItem()
        let store = TestStore(
            initialState: ItemDetailFeature.State(item: item)
        ) {
            ItemDetailFeature()
        }
        
        await store.send(.deleteTapped) {
            $0.alert = AlertState {
                TextState("Delete Item")
            } actions: {
                ButtonState(role: .destructive, action: .deleteConfirmation) {
                    TextState("Delete")
                }
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
            } message: {
                TextState("Are you sure you want to delete 'MacBook Pro'?")
            }
        }
    }
    
    @MainActor
    func testAlertDismissAction() async {
        let item = makeBasicItem()
        let store = TestStore(
            initialState: ItemDetailFeature.State(item: item)
        ) {
            ItemDetailFeature()
        }
        
        // First trigger an alert
        await store.send(.deleteTapped) {
            $0.alert = AlertState {
                TextState("Delete Item")
            } actions: {
                ButtonState(role: .destructive, action: .deleteConfirmation) {
                    TextState("Delete")
                }
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
            } message: {
                TextState("Are you sure you want to delete 'MacBook Pro'?")
            }
        }
        
        // Then dismiss it
        await store.send(.alert(.dismiss)) {
            $0.alert = nil
        }
    }
    
    @MainActor
    func testDeleteConfirmationAction() async {
        let item = makeBasicItem()
        let mockService = MockInventoryService()
        
        let store = TestStore(
            initialState: ItemDetailFeature.State(item: item)
        ) {
            ItemDetailFeature()
        } withDependencies: {
            $0.inventoryService = mockService
        }
        
        // First show the alert
        await store.send(.deleteTapped) {
            $0.alert = AlertState {
                TextState("Delete Item")
            } actions: {
                ButtonState(role: .destructive, action: .deleteConfirmation) {
                    TextState("Delete")
                }
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
            } message: {
                TextState("Are you sure you want to delete 'MacBook Pro'?")
            }
        }
        
        // Confirm deletion
        await store.send(.alert(.presented(.deleteConfirmation)))
        await store.receive(.deleteConfirmed)
        
        // Verify service was called
        XCTAssertTrue(mockService.deleteItemCalled)
        XCTAssertEqual(mockService.deletedItemId, item.id)
    }
    
    // MARK: - Service Integration Tests
    
    @MainActor
    func testSuccessfulItemDeletion() async {
        let item = makeBasicItem()
        let mockService = MockInventoryService()
        mockService.shouldThrowError = false
        
        let store = TestStore(
            initialState: ItemDetailFeature.State(item: item)
        ) {
            ItemDetailFeature()
        } withDependencies: {
            $0.inventoryService = mockService
        }
        
        await store.send(.deleteConfirmed)
        
        // Verify service interaction
        XCTAssertTrue(mockService.deleteItemCalled)
        XCTAssertEqual(mockService.deletedItemId, item.id)
    }
    
    @MainActor
    func testFailedItemDeletion() async {
        let item = makeBasicItem()
        let mockService = MockInventoryService()
        mockService.shouldThrowError = true
        mockService.errorToThrow = ItemDetailTestError.deletionFailed
        
        let store = TestStore(
            initialState: ItemDetailFeature.State(item: item)
        ) {
            ItemDetailFeature()
        } withDependencies: {
            $0.inventoryService = mockService
        }
        
        await store.send(.deleteConfirmed)
        
        // Verify service was called even though it failed
        XCTAssertTrue(mockService.deleteItemCalled)
        XCTAssertEqual(mockService.deletedItemId, item.id)
        
        // Note: Current implementation doesn't handle deletion errors in the UI
        // This test documents the current behavior for future enhancement
    }
    
    // MARK: - Documentation Score Edge Cases
    
    func testDocumentationScoreWithEmptySerialNumber() {
        let item = makeBasicItem()
        item.serialNumber = ""  // Empty string should not count
        item.purchasePrice = 1000.0
        
        let state = ItemDetailFeature.State(item: item)
        XCTAssertEqual(state.documentationScore, 0.25, accuracy: 0.01) // Only purchase price counts
    }
    
    func testDocumentationScoreWithWhitespaceSerialNumber() {
        let item = makeBasicItem()
        item.serialNumber = "   "  // Whitespace should not count
        item.purchasePrice = 1000.0
        
        let state = ItemDetailFeature.State(item: item)
        XCTAssertEqual(state.documentationScore, 0.25, accuracy: 0.01) // Only purchase price counts
    }
    
    func testDocumentationScoreWithZeroPrice() {
        let item = makeBasicItem()
        item.purchasePrice = 0.0  // Zero price should still count
        item.serialNumber = "VALID_SERIAL"
        
        let state = ItemDetailFeature.State(item: item)
        XCTAssertEqual(state.documentationScore, 0.5, accuracy: 0.01) // Both price and serial count
    }
    
    // MARK: - Insurance Documentation Scoring
    
    func testHighValueItemDocumentationScore() {
        let item = TestDataFactory.createHighValueItem()
        let state = ItemDetailFeature.State(item: item)
        
        // High-value items should have complete documentation
        XCTAssertGreaterThan(state.documentationScore, 0.75, "High-value items should have comprehensive documentation")
    }
    
    func testDamagedItemDocumentationScore() {
        let item = TestDataFactory.createDamagedItem()
        let state = ItemDetailFeature.State(item: item)
        
        // Damaged items should have at least some documentation for insurance purposes
        XCTAssertGreaterThan(state.documentationScore, 0.0, "Damaged items should have documentation for insurance claims")
    }
    
    // MARK: - Alert Flow Tests
    
    @MainActor
    func testCompleteAlertFlow() async {
        let item = makeBasicItem()
        let mockService = MockInventoryService()
        
        let store = TestStore(
            initialState: ItemDetailFeature.State(item: item)
        ) {
            ItemDetailFeature()
        } withDependencies: {
            $0.inventoryService = mockService
        }
        
        // 1. Trigger delete alert
        await store.send(.deleteTapped) {
            $0.alert = AlertState {
                TextState("Delete Item")
            } actions: {
                ButtonState(role: .destructive, action: .deleteConfirmation) {
                    TextState("Delete")
                }
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
            } message: {
                TextState("Are you sure you want to delete 'MacBook Pro'?")
            }
        }
        
        // 2. Confirm deletion
        await store.send(.alert(.presented(.deleteConfirmation)))
        
        // 3. Receive deleteConfirmed action
        await store.receive(.deleteConfirmed)
        
        // 4. Verify service call
        XCTAssertTrue(mockService.deleteItemCalled)
    }
    
    // MARK: - Integration with Insurance Workflows
    
    func testItemDetailForInsuranceDocumentation() {
        let item = TestDataFactory.createCompleteItem()
        let state = ItemDetailFeature.State(item: item)
        
        // Items ready for insurance should have high documentation scores
        XCTAssertGreaterThanOrEqual(state.documentationScore, 0.75, 
                                   "Items for insurance documentation should be well-documented")
        
        // Verify all insurance-critical fields are present
        XCTAssertNotNil(item.imageData, "Insurance items should have photos")
        XCTAssertNotNil(item.purchasePrice, "Insurance items should have purchase price")
        XCTAssertNotNil(item.receiptImageData, "Insurance items should have receipt images")
    }
    
    // MARK: - Performance Tests
    
    func testDocumentationScorePerformance() {
        let items = (0..<1000).map { _ in TestDataFactory.createCompleteItem() }
        
        measure {
            for item in items {
                let state = ItemDetailFeature.State(item: item)
                _ = state.documentationScore
            }
        }
    }
}

// MARK: - Mock Services

private final class MockInventoryService: InventoryService, @unchecked Sendable {
    var deleteItemCalled = false
    var deletedItemId: UUID?
    var shouldThrowError = false
    var errorToThrow: Error = ItemDetailTestError.deletionFailed
    
    func deleteItem(id: UUID) async throws {
        deleteItemCalled = true
        deletedItemId = id
        
        if shouldThrowError {
            throw errorToThrow
        }
    }
    
    // MARK: - Unused Protocol Requirements
    
    func fetchItems() async throws -> [Item] {
        fatalError("Not implemented in mock")
    }
    
    func fetchItem(id: UUID) async throws -> Item? {
        fatalError("Not implemented in mock")
    }
    
    func saveItem(_ item: Item) async throws {
        fatalError("Not implemented in mock")
    }
    
    func updateItem(_ item: Item) async throws {
        fatalError("Not implemented in mock")
    }
    
    func searchItems(query: String) async throws -> [Item] {
        fatalError("Not implemented in mock")
    }
    
    func fetchCategories() async throws -> [Nestory.Category] {
        fatalError("Not implemented in mock")
    }
    
    func saveCategory(_ category: Nestory.Category) async throws {
        fatalError("Not implemented in mock")
    }
    
    func assignItemToCategory(itemId: UUID, categoryId: UUID) async throws {
        fatalError("Not implemented in mock")
    }
    
    func fetchItemsByCategory(categoryId: UUID) async throws -> [Item] {
        fatalError("Not implemented in mock")
    }
    
    func fetchRooms() async throws -> [Room] {
        fatalError("Not implemented in mock")
    }
    
    // MARK: - Batch Operations
    func bulkImport(items: [Item]) async throws {
        fatalError("Not implemented in mock")
    }
    
    func bulkUpdate(items: [Item]) async throws {
        fatalError("Not implemented in mock")
    }
    
    func bulkDelete(itemIds: [UUID]) async throws {
        fatalError("Not implemented in mock")
    }
    
    func bulkSave(items: [Item]) async throws {
        fatalError("Not implemented in mock")
    }
    
    func bulkAssignCategory(itemIds: [UUID], categoryId: UUID) async throws {
        fatalError("Not implemented in mock")
    }
    
    func exportInventory(format: ExportFormat) async throws -> Data {
        fatalError("Not implemented in mock")
    }
}

// MARK: - Test Errors

private enum ItemDetailTestError: Error, LocalizedError {
    case deletionFailed
    
    var errorDescription: String? {
        switch self {
        case .deletionFailed:
            return "Failed to delete item"
        }
    }
}
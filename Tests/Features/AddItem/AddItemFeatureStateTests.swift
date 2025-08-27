//
// Layer: Tests
// Module: Features
// Purpose: State management and form action tests for AddItemFeature
//

@testable import Nestory
import ComposableArchitecture
import SwiftData
import XCTest
import Foundation

@MainActor
final class AddItemFeatureStateTests: XCTestCase {
    
    // MARK: - State Management Tests
    
    func testInitialState() {
        let state = AddItemFeature.State()
        
        XCTAssertEqual(state.name, "")
        XCTAssertEqual(state.itemDescription, "")
        XCTAssertEqual(state.quantity, 1)
        XCTAssertNil(state.selectedCategory)
        XCTAssertEqual(state.brand, "")
        XCTAssertEqual(state.modelNumber, "")
        XCTAssertEqual(state.serialNumber, "")
        XCTAssertEqual(state.notes, "")
        XCTAssertEqual(state.purchasePrice, "")
        XCTAssertFalse(state.showPurchaseDetails)
        XCTAssertFalse(state.showingPhotoCapture)
        XCTAssertFalse(state.showingBarcodeScanner)
        XCTAssertFalse(state.showingWarrantyDetection)
        XCTAssertFalse(state.isDetectingWarranty)
        XCTAssertFalse(state.isSaving)
        XCTAssertNil(state.errorMessage)
        XCTAssertEqual(state.categories, [])
        XCTAssertNil(state.detectedWarranty)
        XCTAssertNil(state.imageData)
    }
    
    func testCanSaveComputation() {
        var state = AddItemFeature.State()
        
        // Initially cannot save (empty name)
        XCTAssertFalse(state.canSave)
        
        // Can save with valid name
        state.name = "Test Item"
        XCTAssertTrue(state.canSave)
        
        // Cannot save with whitespace-only name
        state.name = "   "
        XCTAssertFalse(state.canSave)
        
        // Can save with name that has surrounding whitespace
        state.name = "  Valid Name  "
        XCTAssertTrue(state.canSave)
    }
    
    func testPurchasePriceDecimalComputation() {
        var state = AddItemFeature.State()
        
        // Empty price returns nil
        state.purchasePrice = ""
        XCTAssertNil(state.purchasePriceDecimal)
        
        // Valid price returns decimal
        state.purchasePrice = "123.45"
        XCTAssertEqual(state.purchasePriceDecimal, Decimal(string: "123.45"))
        
        // Price with commas is handled
        state.purchasePrice = "1,234.56"
        XCTAssertEqual(state.purchasePriceDecimal, Decimal(string: "1234.56"))
        
        // Invalid price returns nil
        state.purchasePrice = "invalid"
        XCTAssertNil(state.purchasePriceDecimal)
    }
    
    func testStateValidation() {
        var state = AddItemFeature.State()
        
        // Test various edge cases for name validation
        state.name = ""
        XCTAssertFalse(state.canSave)
        
        state.name = "\n\t  \n"
        XCTAssertFalse(state.canSave)
        
        state.name = "A"
        XCTAssertTrue(state.canSave)
        
        state.name = "   A   "
        XCTAssertTrue(state.canSave)
        
        // Test very long name
        state.name = String(repeating: "A", count: 1000)
        XCTAssertTrue(state.canSave)
    }
    
    func testQuantityValidation() {
        var state = AddItemFeature.State()
        
        // Default quantity
        XCTAssertEqual(state.quantity, 1)
        
        // Set various quantities
        state.quantity = 5
        XCTAssertEqual(state.quantity, 5)
        
        state.quantity = 100
        XCTAssertEqual(state.quantity, 100)
        
        // Negative values should be handled by the reducer
        state.quantity = -5
        XCTAssertEqual(state.quantity, -5) // State allows it, reducer should clamp
    }
    
    func testPurchasePriceFormatting() {
        var state = AddItemFeature.State()
        
        // Test various price formats
        let testCases = [
            ("123", Decimal(123)),
            ("123.45", Decimal(string: "123.45")),
            ("1,234.56", Decimal(string: "1234.56")),
            ("10,000.00", Decimal(string: "10000.00")),
            ("0", Decimal(0)),
            ("0.01", Decimal(string: "0.01")),
            ("999999.99", Decimal(string: "999999.99"))
        ]
        
        for (input, expected) in testCases {
            state.purchasePrice = input
            XCTAssertEqual(state.purchasePriceDecimal, expected, "Failed for input: \(input)")
        }
        
        // Test invalid formats
        let invalidCases = ["abc", "12.34.56", "", "   ", "$123", "123$", "12,34,56"]
        
        for invalidInput in invalidCases {
            state.purchasePrice = invalidInput
            XCTAssertNil(state.purchasePriceDecimal, "Should be nil for input: \(invalidInput)")
        }
    }
    
    // MARK: - Form Action Tests
    
    func testFormFieldActions() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // Test name change
        await store.send(.nameChanged("Test Item")) {
            $0.name = "Test Item"
        }
        
        // Test description change
        await store.send(.descriptionChanged("Test Description")) {
            $0.itemDescription = "Test Description"
        }
        
        // Test quantity change
        await store.send(.quantityChanged(5)) {
            $0.quantity = 5
        }
        
        // Test quantity minimum constraint
        await store.send(.quantityChanged(-1)) {
            $0.quantity = 1 // Should be clamped to minimum
        }
        
        // Test brand change
        await store.send(.brandChanged("Apple")) {
            $0.brand = "Apple"
        }
        
        // Test model number change
        await store.send(.modelNumberChanged("iPhone 15")) {
            $0.modelNumber = "iPhone 15"
        }
        
        // Test serial number change
        await store.send(.serialNumberChanged("ABC123")) {
            $0.serialNumber = "ABC123"
        }
        
        // Test notes change
        await store.send(.notesChanged("Test notes")) {
            $0.notes = "Test notes"
        }
        
        // Test purchase price change
        await store.send(.purchasePriceChanged("599.99")) {
            $0.purchasePrice = "599.99"
        }
        
        // Test purchase date change
        let testDate = Date()
        await store.send(.purchaseDateChanged(testDate)) {
            $0.purchaseDate = testDate
        }
    }
    
    func testFormFieldValidation() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // Test empty strings
        await store.send(.nameChanged("")) {
            $0.name = ""
        }
        
        await store.send(.descriptionChanged("")) {
            $0.itemDescription = ""
        }
        
        await store.send(.brandChanged("")) {
            $0.brand = ""
        }
        
        // Test whitespace handling
        await store.send(.nameChanged("   ")) {
            $0.name = "   "
        }
        
        // Test special characters
        await store.send(.nameChanged("Special Characters: !@#$%^&*()")) {
            $0.name = "Special Characters: !@#$%^&*()"
        }
        
        await store.send(.serialNumberChanged("123-ABC-456")) {
            $0.serialNumber = "123-ABC-456"
        }
        
        // Test unicode characters
        await store.send(.nameChanged("Test Item 测试 🏠")) {
            $0.name = "Test Item 测试 🏠"
        }
    }
    
    func testQuantityEdgeCases() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // Test zero quantity
        await store.send(.quantityChanged(0)) {
            $0.quantity = 1 // Should be clamped to minimum
        }
        
        // Test negative quantity
        await store.send(.quantityChanged(-10)) {
            $0.quantity = 1 // Should be clamped to minimum
        }
        
        // Test very large quantity
        await store.send(.quantityChanged(999999)) {
            $0.quantity = 999999
        }
        
        // Test valid quantities
        for validQuantity in [1, 2, 5, 10, 50, 100] {
            await store.send(.quantityChanged(validQuantity)) {
                $0.quantity = validQuantity
            }
        }
    }
    
    // MARK: - Category Loading Tests
    
    func testCategoriesLoaded() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        let testCategories = [
            Category(name: "Electronics"),
            Category(name: "Furniture")
        ]
        
        await store.send(.categoriesLoaded(testCategories)) {
            $0.categories = testCategories
        }
    }
    
    func testCategorySelection() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        let testCategory = Category(name: "Electronics")
        
        await store.send(.categorySelected(testCategory)) {
            $0.selectedCategory = testCategory
        }
        
        // Test deselection
        await store.send(.categorySelected(nil)) {
            $0.selectedCategory = nil
        }
    }
    
    func testCategoryLoadingWithEmptyList() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        await store.send(.categoriesLoaded([])) {
            $0.categories = []
        }
    }
    
    func testCategorySelectionWithMultipleCategories() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        let categories = [
            Category(name: "Electronics"),
            Category(name: "Furniture"),
            Category(name: "Clothing"),
            Category(name: "Books")
        ]
        
        await store.send(.categoriesLoaded(categories)) {
            $0.categories = categories
        }
        
        // Test selecting different categories
        for category in categories {
            await store.send(.categorySelected(category)) {
                $0.selectedCategory = category
            }
        }
        
        // Test final deselection
        await store.send(.categorySelected(nil)) {
            $0.selectedCategory = nil
        }
    }
    
    func testCategoryEquality() {
        let category1 = Category(name: "Electronics")
        let category2 = Category(name: "Electronics")
        let category3 = Category(name: "Furniture")
        
        // Categories with same name should be considered equal for our purposes
        // (Note: Actual equality depends on Category implementation)
        XCTAssertEqual(category1.name, category2.name)
        XCTAssertNotEqual(category1.name, category3.name)
    }
    
    // MARK: - Purchase Details Tests
    
    func testPurchaseDetailsState() {
        var state = AddItemFeature.State()
        
        // Initially purchase details are hidden
        XCTAssertFalse(state.showPurchaseDetails)
        
        // Toggle state
        state.showPurchaseDetails = true
        XCTAssertTrue(state.showPurchaseDetails)
        
        state.showPurchaseDetails = false
        XCTAssertFalse(state.showPurchaseDetails)
    }
    
    func testPurchaseDateHandling() {
        var state = AddItemFeature.State()
        
        // Initially no purchase date
        XCTAssertNil(state.purchaseDate)
        
        // Set purchase date
        let testDate = Date()
        state.purchaseDate = testDate
        XCTAssertEqual(state.purchaseDate, testDate)
        
        // Clear purchase date
        state.purchaseDate = nil
        XCTAssertNil(state.purchaseDate)
    }
}
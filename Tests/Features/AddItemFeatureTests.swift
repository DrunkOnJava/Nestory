//
// Layer: Tests
// Module: AddItemFeatureTests  
// Purpose: Comprehensive TCA tests for AddItemFeature state management and effects
//

@testable import Nestory
import ComposableArchitecture
import SwiftData
import XCTest
import Foundation

@MainActor
final class AddItemFeatureTests: XCTestCase {
    
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
    
    // MARK: - UI State Tests
    
    func testTogglePurchaseDetails() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        await store.send(.togglePurchaseDetails) {
            $0.showPurchaseDetails = true
        }
        
        await store.send(.togglePurchaseDetails) {
            $0.showPurchaseDetails = false
        }
    }
    
    func testPhotoCapture() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // Test photo capture button tap
        await store.send(.photoCaptureButtonTapped) {
            $0.showingPhotoCapture = true
        }
        
        // Test photo capture sheet dismissal
        await store.send(.photoCapturePresented(false)) {
            $0.showingPhotoCapture = false
        }
        
        // Test image data setting
        let testImageData = "test".data(using: .utf8)!
        await store.send(.imageDataSet(testImageData)) {
            $0.imageData = testImageData
        }
    }
    
    func testBarcodeScannerPresentation() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        await store.send(.barcodeScannerButtonTapped) {
            $0.showingBarcodeScanner = true
        }
        
        await store.send(.barcodeScannerPresented(false)) {
            $0.showingBarcodeScanner = false
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
    
    // MARK: - Save Operation Tests
    
    func testSaveButtonDisabledWithEmptyName() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.inventoryService = MockInventoryService()
        }
        
        // Should not trigger save with empty name
        await store.send(.saveButtonTapped)
        // No state changes expected since canSave is false
    }
    
    func testSuccessfulSave() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.inventoryService = MockInventoryService()
            $0.dismiss = DismissEffect { }
        }
        
        // Set up valid item data
        await store.send(.nameChanged("Test Item")) {
            $0.name = "Test Item"
        }
        
        await store.send(.brandChanged("Apple")) {
            $0.brand = "Apple"
        }
        
        await store.send(.saveButtonTapped) {
            $0.isSaving = true
            $0.errorMessage = nil
        }
        
        await store.receive(.itemSaved)
        // Dismiss effect would be called here
    }
    
    func testSaveFailure() async {
        let failingService = MockInventoryService()
        failingService.shouldFailSave = true
        
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.inventoryService = failingService
        }
        
        await store.send(.nameChanged("Test Item")) {
            $0.name = "Test Item"
        }
        
        await store.send(.saveButtonTapped) {
            $0.isSaving = true
            $0.errorMessage = nil
        }
        
        await store.receive(.saveFailed("Mock save error")) {
            $0.isSaving = false
            $0.errorMessage = "Mock save error"
        }
    }
    
    // MARK: - Warranty Detection Tests
    
    func testWarrantyDetectionStarted() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.warrantyTrackingService = MockWarrantyTrackingService()
        }
        
        // Set up some product info
        await store.send(.brandChanged("Apple")) {
            $0.brand = "Apple"
        }
        
        await store.send(.modelNumberChanged("iPhone 15")) {
            $0.modelNumber = "iPhone 15"
        }
        
        await store.send(.warrantyDetectionStarted) {
            $0.isDetectingWarranty = true
        }
        
        let mockResult = WarrantyDetectionResult.detected(
            provider: "Apple", 
            duration: 12, 
            confidence: 0.95
        )
        
        await store.receive(.warrantyDetected(mockResult)) {
            $0.isDetectingWarranty = false
            $0.detectedWarranty = mockResult
        }
    }
    
    func testWarrantyDetectionFailure() async {
        let failingService = MockWarrantyTrackingService()
        failingService.shouldFailDetection = true
        
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.warrantyTrackingService = failingService
        }
        
        await store.send(.brandChanged("TestBrand")) {
            $0.brand = "TestBrand"
        }
        
        await store.send(.warrantyDetectionStarted) {
            $0.isDetectingWarranty = true
        }
        
        await store.receive(.warrantyDetectionFailed("Mock detection error")) {
            $0.isDetectingWarranty = false
            $0.errorMessage = "Mock detection error"
        }
    }
    
    // MARK: - Barcode Scanning Tests
    
    func testBarcodeScanning() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.barcodeScannerService = MockBarcodeScannerService()
        }
        
        await store.send(.barcodeScanned("123456789")) {
            $0.tempItem.barcode = "123456789"
        }
        
        let mockProductInfo = ProductInfo(
            barcode: "123456789",
            name: "Test Product",
            brand: "Test Brand",
            model: "Test Model",
            category: "Electronics",
            description: "Test Description"
        )
        
        await store.receive(.barcodeDataLoaded(mockProductInfo)) {
            $0.name = "Test Product"
            $0.brand = "Test Brand"
            $0.showingBarcodeScanner = false
        }
    }
    
    func testBarcodeDataFromTempItem() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // Simulate temp item having data from barcode scan
        await store.send(.barcodeDataLoaded(nil)) {
            // Apply any temp item data to form fields
            if !$0.tempItem.name.isEmpty && $0.name.isEmpty {
                $0.name = $0.tempItem.name
            }
            if let scannedBrand = $0.tempItem.brand, !scannedBrand.isEmpty {
                $0.brand = scannedBrand
            }
            $0.showingBarcodeScanner = false
        }
    }
    
    // MARK: - Integration Tests
    
    func testCompleteItemCreationFlow() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.inventoryService = MockInventoryService()
            $0.categoryService = MockCategoryService()
            $0.warrantyTrackingService = MockWarrantyTrackingService()
            $0.barcodeScannerService = MockBarcodeScannerService()
            $0.dismiss = DismissEffect { }
        }
        
        // 1. Load categories
        await store.send(.onAppear)
        
        let testCategories = [Category(name: "Electronics")]
        await store.receive(.categoriesLoaded(testCategories)) {
            $0.categories = testCategories
        }
        
        // 2. Fill out form
        await store.send(.nameChanged("iPhone 15")) {
            $0.name = "iPhone 15"
        }
        
        await store.send(.brandChanged("Apple")) {
            $0.brand = "Apple"
        }
        
        await store.send(.categorySelected(testCategories[0])) {
            $0.selectedCategory = testCategories[0]
        }
        
        await store.send(.togglePurchaseDetails) {
            $0.showPurchaseDetails = true
        }
        
        await store.send(.purchasePriceChanged("999.00")) {
            $0.purchasePrice = "999.00"
        }
        
        // 3. Detect warranty
        await store.send(.warrantyDetectionStarted) {
            $0.isDetectingWarranty = true
        }
        
        let warrantyResult = WarrantyDetectionResult.detected(
            provider: "Apple",
            duration: 12,
            confidence: 0.95
        )
        
        await store.receive(.warrantyDetected(warrantyResult)) {
            $0.isDetectingWarranty = false
            $0.detectedWarranty = warrantyResult
        }
        
        // 4. Save item
        await store.send(.saveButtonTapped) {
            $0.isSaving = true
            $0.errorMessage = nil
        }
        
        await store.receive(.itemSaved)
        // Item should be saved and view dismissed
    }
}

// MARK: - Mock Services

private class MockInventoryService: InventoryService {
    var shouldFailSave = false
    var savedItems: [Item] = []
    
    func fetchItems() async throws -> [Item] {
        return []
    }
    
    func fetchItem(id: UUID) async throws -> Item? {
        return nil
    }
    
    func saveItem(_ item: Item) async throws {
        if shouldFailSave {
            throw MockError.saveError
        }
        savedItems.append(item)
    }
    
    func updateItem(_ item: Item) async throws {
        // Mock implementation
    }
    
    func deleteItem(id: UUID) async throws {
        // Mock implementation
    }
    
    func searchItems(query: String, filters: SearchFilters) async throws -> [Item] {
        return []
    }
    
    func getItemsCount() async throws -> Int {
        return 0
    }
    
    func getTotalValue() async throws -> Decimal {
        return 0
    }
    
    func getItemsByCategory() async throws -> [String: [Item]] {
        return [:]
    }
}

private class MockCategoryService: CategoryService {
    func fetchCategories() async throws -> [Category] {
        return [
            Category(name: "Electronics"),
            Category(name: "Furniture")
        ]
    }
    
    func saveCategory(_ category: Category) async throws {
        // Mock implementation
    }
    
    func updateCategory(_ category: Category) async throws {
        // Mock implementation
    }
    
    func deleteCategory(id: UUID) async throws {
        // Mock implementation
    }
}

private class MockWarrantyTrackingService: WarrantyTrackingService {
    var shouldFailDetection = false
    
    func fetchWarranties(includeExpired: Bool) async throws -> [Warranty] {
        return []
    }
    
    func fetchWarranty(for itemId: UUID) async throws -> Warranty? {
        return nil
    }
    
    func saveWarranty(_ warranty: Warranty, for itemId: UUID) async throws {
        // Mock implementation
    }
    
    func deleteWarranty(for itemId: UUID) async throws {
        // Mock implementation
    }
    
    func calculateWarrantyExpiration(for item: Item) async throws -> Date? {
        return nil
    }
    
    func suggestWarrantyProvider(for item: Item) async -> String? {
        return "Mock Provider"
    }
    
    func defaultWarrantyDuration(for category: Category?) async -> Int {
        return 12
    }
    
    func detectWarrantyFromReceipt(item: Item, receiptText: String?) async throws -> WarrantyDetectionResult? {
        return nil
    }
    
    func detectWarrantyInfo(brand: String?, model: String?, serialNumber: String?, purchaseDate: Date?) async throws -> WarrantyDetectionResult? {
        if shouldFailDetection {
            throw MockError.detectionError
        }
        
        return WarrantyDetectionResult.detected(
            provider: brand ?? "Generic",
            duration: 12,
            confidence: 0.8
        )
    }
    
    func getWarrantyStatus(for item: Item) async throws -> WarrantyStatus {
        return .noWarranty
    }
    
    func getExpiringWarranties(within days: Int) async throws -> [Item] {
        return []
    }
    
    func getExpiredWarranties() async throws -> [Item] {
        return []
    }
    
    func getItemsWithoutWarranty() async throws -> [Item] {
        return []
    }
    
    func getWarrantyStatistics() async throws -> WarrantyTrackingStatistics {
        return WarrantyTrackingStatistics(
            totalWarranties: 0,
            activeWarranties: 0,
            expiredWarranties: 0,
            expiringSoonCount: 0,
            noWarrantyCount: 0,
            averageDurationDays: 0,
            totalCoverageValue: 0
        )
    }
    
    func updateWarrantyStatistics() async throws {
        // Mock implementation
    }
    
    func scheduleExpirationReminders() async throws {
        // Mock implementation
    }
}

private class MockBarcodeScannerService: BarcodeScannerService {
    func checkCameraPermission() async -> Bool {
        return true
    }
    
    func detectBarcode(from imageData: Data) async throws -> BarcodeResult? {
        return BarcodeResult(value: "123456789", type: "EAN-13", confidence: 0.95)
    }
    
    func extractSerialNumber(from text: String) -> String? {
        return "SN123456"
    }
    
    func lookupProduct(barcode: String, type: String) async -> ProductInfo? {
        return ProductInfo(
            barcode: barcode,
            name: "Mock Product",
            brand: "Mock Brand",
            model: "Mock Model",
            category: "Electronics",
            description: "Mock Description"
        )
    }
}

private enum MockError: Error {
    case saveError
    case detectionError
    
    var localizedDescription: String {
        switch self {
        case .saveError:
            return "Mock save error"
        case .detectionError:
            return "Mock detection error"
        }
    }
}
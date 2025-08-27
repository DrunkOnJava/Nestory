//
// Layer: Tests
// Module: Features
// Purpose: End-to-end integration tests for AddItemFeature complete flows
//

@testable import Nestory
import ComposableArchitecture
import SwiftData
import XCTest
import Foundation

@MainActor
final class AddItemFeatureIntegrationTests: XCTestCase {
    
    // MARK: - Complete Integration Tests
    
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
    
    func testCompleteFlowWithBarcodeScanning() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.inventoryService = MockInventoryService()
            $0.categoryService = MockCategoryService()
            $0.barcodeScannerService = MockBarcodeScannerService()
            $0.warrantyTrackingService = MockWarrantyTrackingService()
            $0.dismiss = DismissEffect { }
        }
        
        // 1. Start with barcode scanning
        await store.send(.barcodeScannerButtonTapped) {
            $0.showingBarcodeScanner = true
        }
        
        await store.send(.barcodeScanned("123456789")) {
            $0.tempItem.barcode = "123456789"
        }
        
        let productInfo = ProductInfo(
            barcode: "123456789",
            name: "Barcode Product",
            brand: "Barcode Brand",
            model: "Barcode Model",
            category: "Electronics",
            description: "Barcode Description"
        )
        
        await store.receive(.barcodeDataLoaded(productInfo)) {
            $0.name = "Barcode Product"
            $0.brand = "Barcode Brand"
            $0.showingBarcodeScanner = false
        }
        
        // 2. Add additional details
        await store.send(.serialNumberChanged("SN123456")) {
            $0.serialNumber = "SN123456"
        }
        
        await store.send(.purchasePriceChanged("299.99")) {
            $0.purchasePrice = "299.99"
        }
        
        // 3. Detect warranty based on scanned data
        await store.send(.warrantyDetectionStarted) {
            $0.isDetectingWarranty = true
        }
        
        let warranty = WarrantyDetectionResult.detected(
            provider: "Barcode Brand",
            duration: 24,
            confidence: 0.9
        )
        
        await store.receive(.warrantyDetected(warranty)) {
            $0.isDetectingWarranty = false
            $0.detectedWarranty = warranty
        }
        
        // 4. Save complete item
        await store.send(.saveButtonTapped) {
            $0.isSaving = true
            $0.errorMessage = nil
        }
        
        await store.receive(.itemSaved)
    }
    
    func testCompleteFlowWithPhotoAndAllFeatures() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.inventoryService = MockInventoryService()
            $0.categoryService = MockCategoryService()
            $0.warrantyTrackingService = MockWarrantyTrackingService()
            $0.dismiss = DismissEffect { }
        }
        
        // 1. Load categories
        let categories = [Category(name: "Electronics"), Category(name: "Furniture")]
        await store.send(.categoriesLoaded(categories)) {
            $0.categories = categories
        }
        
        // 2. Fill comprehensive form data
        await store.send(.nameChanged("Premium Device")) {
            $0.name = "Premium Device"
        }
        
        await store.send(.descriptionChanged("High-end electronic device")) {
            $0.itemDescription = "High-end electronic device"
        }
        
        await store.send(.brandChanged("Premium Brand")) {
            $0.brand = "Premium Brand"
        }
        
        await store.send(.modelNumberChanged("PB-2024")) {
            $0.modelNumber = "PB-2024"
        }
        
        await store.send(.serialNumberChanged("PB123456789")) {
            $0.serialNumber = "PB123456789"
        }
        
        await store.send(.quantityChanged(1)) {
            $0.quantity = 1
        }
        
        await store.send(.categorySelected(categories[0])) {
            $0.selectedCategory = categories[0]
        }
        
        await store.send(.togglePurchaseDetails) {
            $0.showPurchaseDetails = true
        }
        
        await store.send(.purchasePriceChanged("1999.99")) {
            $0.purchasePrice = "1999.99"
        }
        
        let purchaseDate = Date()
        await store.send(.purchaseDateChanged(purchaseDate)) {
            $0.purchaseDate = purchaseDate
        }
        
        await store.send(.notesChanged("Premium device with extended warranty")) {
            $0.notes = "Premium device with extended warranty"
        }
        
        // 3. Add photo
        let imageData = "premium device photo".data(using: .utf8)!
        await store.send(.imageDataSet(imageData)) {
            $0.imageData = imageData
        }
        
        // 4. Detect warranty
        await store.send(.warrantyDetectionStarted) {
            $0.isDetectingWarranty = true
        }
        
        let premiumWarranty = WarrantyDetectionResult.detected(
            provider: "Premium Brand",
            duration: 36,
            confidence: 0.98
        )
        
        await store.receive(.warrantyDetected(premiumWarranty)) {
            $0.isDetectingWarranty = false
            $0.detectedWarranty = premiumWarranty
        }
        
        // 5. Save comprehensive item
        await store.send(.saveButtonTapped) {
            $0.isSaving = true
            $0.errorMessage = nil
        }
        
        await store.receive(.itemSaved)
    }
    
    func testCompleteFlowWithErrorRecovery() async {
        let mockInventoryService = MockInventoryService()
        mockInventoryService.shouldFailSave = true
        
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.inventoryService = mockInventoryService
            $0.categoryService = MockCategoryService()
            $0.warrantyTrackingService = MockWarrantyTrackingService()
            $0.dismiss = DismissEffect { }
        }
        
        // 1. Load categories
        let categories = [Category(name: "Test Category")]
        await store.send(.categoriesLoaded(categories)) {
            $0.categories = categories
        }
        
        // 2. Fill out form
        await store.send(.nameChanged("Error Recovery Test")) {
            $0.name = "Error Recovery Test"
        }
        
        await store.send(.brandChanged("Test Brand")) {
            $0.brand = "Test Brand"
        }
        
        await store.send(.categorySelected(categories[0])) {
            $0.selectedCategory = categories[0]
        }
        
        // 3. Attempt save (will fail)
        await store.send(.saveButtonTapped) {
            $0.isSaving = true
            $0.errorMessage = nil
        }
        
        await store.receive(.saveFailed("Mock save error")) {
            $0.isSaving = false
            $0.errorMessage = "Mock save error"
        }
        
        // 4. User adds more details and tries again
        await store.send(.notesChanged("Added more details after error")) {
            $0.notes = "Added more details after error"
        }
        
        // Fix the service
        mockInventoryService.shouldFailSave = false
        
        // 5. Retry save (will succeed)
        await store.send(.saveButtonTapped) {
            $0.isSaving = true
            $0.errorMessage = nil
        }
        
        await store.receive(.itemSaved)
    }
    
    func testCompleteFlowWithMultipleWarrantyDetections() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.inventoryService = MockInventoryService()
            $0.warrantyTrackingService = MockWarrantyTrackingService()
            $0.dismiss = DismissEffect { }
        }
        
        // 1. Start with basic product info
        await store.send(.nameChanged("Multi-Warranty Test")) {
            $0.name = "Multi-Warranty Test"
        }
        
        await store.send(.brandChanged("Apple")) {
            $0.brand = "Apple"
        }
        
        await store.send(.modelNumberChanged("iPhone 15")) {
            $0.modelNumber = "iPhone 15"
        }
        
        // 2. First warranty detection
        await store.send(.warrantyDetectionStarted) {
            $0.isDetectingWarranty = true
        }
        
        let firstWarranty = WarrantyDetectionResult.detected(
            provider: "Apple",
            duration: 12,
            confidence: 0.95
        )
        
        await store.receive(.warrantyDetected(firstWarranty)) {
            $0.isDetectingWarranty = false
            $0.detectedWarranty = firstWarranty
        }
        
        // 3. User changes brand and re-detects
        await store.send(.brandChanged("Samsung")) {
            $0.brand = "Samsung"
        }
        
        await store.send(.modelNumberChanged("Galaxy S24")) {
            $0.modelNumber = "Galaxy S24"
        }
        
        await store.send(.warrantyDetectionStarted) {
            $0.isDetectingWarranty = true
        }
        
        let secondWarranty = WarrantyDetectionResult.detected(
            provider: "Samsung",
            duration: 24,
            confidence: 0.88
        )
        
        await store.receive(.warrantyDetected(secondWarranty)) {
            $0.isDetectingWarranty = false
            $0.detectedWarranty = secondWarranty
        }
        
        // 4. Save with final warranty info
        await store.send(.saveButtonTapped) {
            $0.isSaving = true
            $0.errorMessage = nil
        }
        
        await store.receive(.itemSaved)
    }
    
    func testCompleteFlowWithUserCancellation() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.categoryService = MockCategoryService()
            $0.dismiss = DismissEffect { }
        }
        
        // 1. User starts filling form
        await store.send(.nameChanged("Cancelled Item")) {
            $0.name = "Cancelled Item"
        }
        
        await store.send(.brandChanged("Cancelled Brand")) {
            $0.brand = "Cancelled Brand"
        }
        
        // 2. User opens photo capture
        await store.send(.photoCaptureButtonTapped) {
            $0.showingPhotoCapture = true
        }
        
        // 3. User cancels photo capture
        await store.send(.photoCapturePresented(false)) {
            $0.showingPhotoCapture = false
        }
        
        // 4. User opens barcode scanner
        await store.send(.barcodeScannerButtonTapped) {
            $0.showingBarcodeScanner = true
        }
        
        // 5. User cancels barcode scanner
        await store.send(.barcodeScannerPresented(false)) {
            $0.showingBarcodeScanner = false
        }
        
        // 6. Form data should still be preserved
        XCTAssertEqual(store.state.name, "Cancelled Item")
        XCTAssertEqual(store.state.brand, "Cancelled Brand")
        XCTAssertFalse(store.state.showingPhotoCapture)
        XCTAssertFalse(store.state.showingBarcodeScanner)
        
        // 7. User can still save if they want
        XCTAssertTrue(store.state.canSave)
    }
}
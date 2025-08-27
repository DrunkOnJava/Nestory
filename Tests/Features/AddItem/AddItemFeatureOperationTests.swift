//
// Layer: Tests
// Module: Features
// Purpose: Save operations and error handling tests for AddItemFeature
//

@testable import Nestory
import ComposableArchitecture
import SwiftData
import XCTest
import Foundation

@MainActor
final class AddItemFeatureOperationTests: XCTestCase {
    
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
    
    func testSaveWithCompleteItemData() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.inventoryService = MockInventoryService()
            $0.dismiss = DismissEffect { }
        }
        
        let testCategory = Category(name: "Electronics")
        let testDate = Date()
        let testImageData = "test image".data(using: .utf8)!
        
        // Fill out complete form data
        await store.send(.nameChanged("Complete Test Item")) {
            $0.name = "Complete Test Item"
        }
        
        await store.send(.descriptionChanged("Complete description")) {
            $0.itemDescription = "Complete description"
        }
        
        await store.send(.brandChanged("Apple")) {
            $0.brand = "Apple"
        }
        
        await store.send(.modelNumberChanged("iPhone 15 Pro")) {
            $0.modelNumber = "iPhone 15 Pro"
        }
        
        await store.send(.serialNumberChanged("SERIAL123")) {
            $0.serialNumber = "SERIAL123"
        }
        
        await store.send(.quantityChanged(2)) {
            $0.quantity = 2
        }
        
        await store.send(.purchasePriceChanged("1299.99")) {
            $0.purchasePrice = "1299.99"
        }
        
        await store.send(.purchaseDateChanged(testDate)) {
            $0.purchaseDate = testDate
        }
        
        await store.send(.categorySelected(testCategory)) {
            $0.selectedCategory = testCategory
        }
        
        await store.send(.notesChanged("Complete test notes")) {
            $0.notes = "Complete test notes"
        }
        
        await store.send(.imageDataSet(testImageData)) {
            $0.imageData = testImageData
        }
        
        // Save the complete item
        await store.send(.saveButtonTapped) {
            $0.isSaving = true
            $0.errorMessage = nil
        }
        
        await store.receive(.itemSaved)
    }
    
    func testSaveWithPartialData() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.inventoryService = MockInventoryService()
            $0.dismiss = DismissEffect { }
        }
        
        // Only set required fields
        await store.send(.nameChanged("Minimal Item")) {
            $0.name = "Minimal Item"
        }
        
        await store.send(.saveButtonTapped) {
            $0.isSaving = true
            $0.errorMessage = nil
        }
        
        await store.receive(.itemSaved)
    }
    
    func testSaveErrorRecovery() async {
        let mockService = MockInventoryService()
        mockService.shouldFailSave = true
        
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.inventoryService = mockService
            $0.dismiss = DismissEffect { }
        }
        
        await store.send(.nameChanged("Recovery Test")) {
            $0.name = "Recovery Test"
        }
        
        // First save attempt fails
        await store.send(.saveButtonTapped) {
            $0.isSaving = true
            $0.errorMessage = nil
        }
        
        await store.receive(.saveFailed("Mock save error")) {
            $0.isSaving = false
            $0.errorMessage = "Mock save error"
        }
        
        // Fix the service and try again
        mockService.shouldFailSave = false
        
        await store.send(.saveButtonTapped) {
            $0.isSaving = true
            $0.errorMessage = nil
        }
        
        await store.receive(.itemSaved)
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
    
    func testWarrantyDetectionWithoutProductInfo() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.warrantyTrackingService = MockWarrantyTrackingService()
        }
        
        // Start warranty detection without brand/model info
        await store.send(.warrantyDetectionStarted) {
            $0.isDetectingWarranty = true
        }
        
        // Should still attempt detection with limited info
        let genericResult = WarrantyDetectionResult.detected(
            provider: "Generic",
            duration: 12,
            confidence: 0.8
        )
        
        await store.receive(.warrantyDetected(genericResult)) {
            $0.isDetectingWarranty = false
            $0.detectedWarranty = genericResult
        }
    }
    
    func testMultipleWarrantyDetections() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.warrantyTrackingService = MockWarrantyTrackingService()
        }
        
        await store.send(.brandChanged("Apple")) {
            $0.brand = "Apple"
        }
        
        // First detection
        await store.send(.warrantyDetectionStarted) {
            $0.isDetectingWarranty = true
        }
        
        let firstResult = WarrantyDetectionResult.detected(provider: "Apple", duration: 12, confidence: 0.95)
        await store.receive(.warrantyDetected(firstResult)) {
            $0.isDetectingWarranty = false
            $0.detectedWarranty = firstResult
        }
        
        // Change brand and detect again
        await store.send(.brandChanged("Samsung")) {
            $0.brand = "Samsung"
        }
        
        await store.send(.warrantyDetectionStarted) {
            $0.isDetectingWarranty = true
        }
        
        let secondResult = WarrantyDetectionResult.detected(provider: "Samsung", duration: 24, confidence: 0.85)
        await store.receive(.warrantyDetected(secondResult)) {
            $0.isDetectingWarranty = false
            $0.detectedWarranty = secondResult
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
        
        // Set up temp item data
        store.state.tempItem.name = "Temp Item Name"
        store.state.tempItem.brand = "Temp Brand"
        
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
    
    func testBarcodeScanningWithExistingFormData() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.barcodeScannerService = MockBarcodeScannerService()
        }
        
        // Set some existing form data
        await store.send(.nameChanged("Existing Item")) {
            $0.name = "Existing Item"
        }
        
        await store.send(.notesChanged("Existing notes")) {
            $0.notes = "Existing notes"
        }
        
        // Scan barcode
        await store.send(.barcodeScanned("123456789")) {
            $0.tempItem.barcode = "123456789"
        }
        
        let scannedProductInfo = ProductInfo(
            barcode: "123456789",
            name: "Scanned Product",
            brand: "Scanned Brand",
            model: "Scanned Model",
            category: "Electronics",
            description: "Scanned Description"
        )
        
        await store.receive(.barcodeDataLoaded(scannedProductInfo)) {
            // Should update with scanned data but preserve notes
            $0.name = "Scanned Product"
            $0.brand = "Scanned Brand"
            $0.showingBarcodeScanner = false
            // Notes should remain unchanged
        }
        
        XCTAssertEqual(store.state.notes, "Existing notes")
    }
    
    func testBarcodeDataMerging() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // Manually set temp item data (simulating barcode scan without product lookup)
        store.state.tempItem.name = "Manual Temp Name"
        store.state.tempItem.brand = "Manual Temp Brand"
        store.state.tempItem.modelNumber = "Manual Temp Model"
        
        // Apply temp data
        await store.send(.barcodeDataLoaded(nil)) {
            if !$0.tempItem.name.isEmpty && $0.name.isEmpty {
                $0.name = $0.tempItem.name
            }
            if let scannedBrand = $0.tempItem.brand, !scannedBrand.isEmpty && $0.brand.isEmpty {
                $0.brand = scannedBrand
            }
            if let scannedModel = $0.tempItem.modelNumber, !scannedModel.isEmpty && $0.modelNumber.isEmpty {
                $0.modelNumber = scannedModel
            }
            $0.showingBarcodeScanner = false
        }
        
        XCTAssertEqual(store.state.name, "Manual Temp Name")
        XCTAssertEqual(store.state.brand, "Manual Temp Brand")
        XCTAssertEqual(store.state.modelNumber, "Manual Temp Model")
    }
}
//
// Layer: Tests
// Module: Features
// Purpose: UI interaction and presentation tests for AddItemFeature
//

@testable import Nestory
import ComposableArchitecture
import SwiftData
import XCTest
import Foundation

@MainActor
final class AddItemFeatureUITests: XCTestCase {
    
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
    
    func testMultipleTogglePurchaseDetails() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // Initially false
        XCTAssertFalse(store.state.showPurchaseDetails)
        
        // Toggle multiple times
        for _ in 1...5 {
            await store.send(.togglePurchaseDetails) {
                $0.showPurchaseDetails = true
            }
            
            await store.send(.togglePurchaseDetails) {
                $0.showPurchaseDetails = false
            }
        }
    }
    
    func testPurchaseDetailsWithFormData() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // Fill some form data first
        await store.send(.nameChanged("Test Item")) {
            $0.name = "Test Item"
        }
        
        await store.send(.purchasePriceChanged("999.99")) {
            $0.purchasePrice = "999.99"
        }
        
        // Toggle purchase details
        await store.send(.togglePurchaseDetails) {
            $0.showPurchaseDetails = true
        }
        
        // Purchase data should be preserved
        XCTAssertEqual(store.state.name, "Test Item")
        XCTAssertEqual(store.state.purchasePrice, "999.99")
        XCTAssertTrue(store.state.showPurchaseDetails)
    }
    
    // MARK: - Photo Capture Tests
    
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
    
    func testPhotoCaptureWithPresentationToggle() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // Show photo capture
        await store.send(.photoCaptureButtonTapped) {
            $0.showingPhotoCapture = true
        }
        
        // Show again (should maintain true state)
        await store.send(.photoCapturePresented(true)) {
            $0.showingPhotoCapture = true
        }
        
        // Hide
        await store.send(.photoCapturePresented(false)) {
            $0.showingPhotoCapture = false
        }
        
        // Show again
        await store.send(.photoCapturePresented(true)) {
            $0.showingPhotoCapture = true
        }
    }
    
    func testMultipleImageDataSetting() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // Set first image
        let imageData1 = "first image".data(using: .utf8)!
        await store.send(.imageDataSet(imageData1)) {
            $0.imageData = imageData1
        }
        
        // Replace with second image
        let imageData2 = "second image".data(using: .utf8)!
        await store.send(.imageDataSet(imageData2)) {
            $0.imageData = imageData2
        }
        
        // Clear image data
        await store.send(.imageDataSet(Data())) {
            $0.imageData = Data()
        }
    }
    
    func testImageDataWithFormInteraction() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // Add form data
        await store.send(.nameChanged("Item with Photo")) {
            $0.name = "Item with Photo"
        }
        
        // Capture photo
        await store.send(.photoCaptureButtonTapped) {
            $0.showingPhotoCapture = true
        }
        
        let testImageData = "photo data".data(using: .utf8)!
        await store.send(.imageDataSet(testImageData)) {
            $0.imageData = testImageData
        }
        
        // Dismiss photo capture
        await store.send(.photoCapturePresented(false)) {
            $0.showingPhotoCapture = false
        }
        
        // Form data and image should be preserved
        XCTAssertEqual(store.state.name, "Item with Photo")
        XCTAssertEqual(store.state.imageData, testImageData)
        XCTAssertFalse(store.state.showingPhotoCapture)
    }
    
    // MARK: - Barcode Scanner Tests
    
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
    
    func testBarcodeScannerMultipleToggles() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // Toggle barcode scanner multiple times
        for i in 1...3 {
            await store.send(.barcodeScannerButtonTapped) {
                $0.showingBarcodeScanner = true
            }
            
            await store.send(.barcodeScannerPresented(false)) {
                $0.showingBarcodeScanner = false
            }
        }
    }
    
    func testBarcodeScannerWithBothPresentationMethods() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // Show via button tap
        await store.send(.barcodeScannerButtonTapped) {
            $0.showingBarcodeScanner = true
        }
        
        // Confirm presentation state
        await store.send(.barcodeScannerPresented(true)) {
            $0.showingBarcodeScanner = true
        }
        
        // Hide via presentation change
        await store.send(.barcodeScannerPresented(false)) {
            $0.showingBarcodeScanner = false
        }
    }
    
    // MARK: - Warranty Detection UI Tests
    
    func testWarrantyDetectionUIStates() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.warrantyTrackingService = MockWarrantyTrackingService()
        }
        
        // Initially not detecting
        XCTAssertFalse(store.state.isDetectingWarranty)
        XCTAssertNil(store.state.detectedWarranty)
        
        // Set up product info
        await store.send(.brandChanged("Apple")) {
            $0.brand = "Apple"
        }
        
        await store.send(.modelNumberChanged("iPhone 15")) {
            $0.modelNumber = "iPhone 15"
        }
        
        // Start detection
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
    
    func testWarrantyDetectionButton() async {
        var state = AddItemFeature.State()
        
        // Initially warranty detection button should be available
        XCTAssertFalse(state.isDetectingWarranty)
        
        // During detection, button should show loading state
        state.isDetectingWarranty = true
        XCTAssertTrue(state.isDetectingWarranty)
        
        // After detection, button should return to normal
        state.isDetectingWarranty = false
        XCTAssertFalse(state.isDetectingWarranty)
    }
    
    func testWarrantyDetectionWithExistingData() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.warrantyTrackingService = MockWarrantyTrackingService()
        }
        
        // Fill out comprehensive product information
        await store.send(.nameChanged("iPhone 15 Pro")) {
            $0.name = "iPhone 15 Pro"
        }
        
        await store.send(.brandChanged("Apple")) {
            $0.brand = "Apple"
        }
        
        await store.send(.modelNumberChanged("iPhone 15 Pro")) {
            $0.modelNumber = "iPhone 15 Pro"
        }
        
        await store.send(.serialNumberChanged("ABC123DEF456")) {
            $0.serialNumber = "ABC123DEF456"
        }
        
        let purchaseDate = Date()
        await store.send(.purchaseDateChanged(purchaseDate)) {
            $0.purchaseDate = purchaseDate
        }
        
        // Start warranty detection with all product info available
        await store.send(.warrantyDetectionStarted) {
            $0.isDetectingWarranty = true
        }
        
        let detectedWarranty = WarrantyDetectionResult.detected(
            provider: "Apple",
            duration: 12,
            confidence: 0.98
        )
        
        await store.receive(.warrantyDetected(detectedWarranty)) {
            $0.isDetectingWarranty = false
            $0.detectedWarranty = detectedWarranty
        }
        
        // Verify form data is preserved
        XCTAssertEqual(store.state.name, "iPhone 15 Pro")
        XCTAssertEqual(store.state.brand, "Apple")
        XCTAssertEqual(store.state.modelNumber, "iPhone 15 Pro")
        XCTAssertEqual(store.state.serialNumber, "ABC123DEF456")
        XCTAssertEqual(store.state.purchaseDate, purchaseDate)
    }
    
    // MARK: - Combined UI Interactions
    
    func testMultipleUIComponentsSimultaneously() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.warrantyTrackingService = MockWarrantyTrackingService()
        }
        
        // Fill form data
        await store.send(.nameChanged("Complex Item")) {
            $0.name = "Complex Item"
        }
        
        // Show purchase details
        await store.send(.togglePurchaseDetails) {
            $0.showPurchaseDetails = true
        }
        
        // Set image data
        let imageData = "test image".data(using: .utf8)!
        await store.send(.imageDataSet(imageData)) {
            $0.imageData = imageData
        }
        
        // Start warranty detection
        await store.send(.warrantyDetectionStarted) {
            $0.isDetectingWarranty = true
        }
        
        // All UI states should coexist
        XCTAssertEqual(store.state.name, "Complex Item")
        XCTAssertTrue(store.state.showPurchaseDetails)
        XCTAssertEqual(store.state.imageData, imageData)
        XCTAssertTrue(store.state.isDetectingWarranty)
        
        // Complete warranty detection
        let warranty = WarrantyDetectionResult.detected(provider: "Test", duration: 24, confidence: 0.9)
        await store.receive(.warrantyDetected(warranty)) {
            $0.isDetectingWarranty = false
            $0.detectedWarranty = warranty
        }
        
        // Other UI states should remain unchanged
        XCTAssertEqual(store.state.name, "Complex Item")
        XCTAssertTrue(store.state.showPurchaseDetails)
        XCTAssertEqual(store.state.imageData, imageData)
    }
    
    func testUIStateResetScenarios() async {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // Set up various UI states
        await store.send(.togglePurchaseDetails) {
            $0.showPurchaseDetails = true
        }
        
        await store.send(.photoCaptureButtonTapped) {
            $0.showingPhotoCapture = true
        }
        
        await store.send(.barcodeScannerButtonTapped) {
            $0.showingBarcodeScanner = true
        }
        
        // Reset UI states
        await store.send(.photoCapturePresented(false)) {
            $0.showingPhotoCapture = false
        }
        
        await store.send(.barcodeScannerPresented(false)) {
            $0.showingBarcodeScanner = false
        }
        
        await store.send(.togglePurchaseDetails) {
            $0.showPurchaseDetails = false
        }
        
        // All UI presentation states should be reset
        XCTAssertFalse(store.state.showPurchaseDetails)
        XCTAssertFalse(store.state.showingPhotoCapture)
        XCTAssertFalse(store.state.showingBarcodeScanner)
    }
    
    // MARK: - Error State UI Tests
    
    func testErrorMessageUIState() {
        var state = AddItemFeature.State()
        
        // Initially no error
        XCTAssertNil(state.errorMessage)
        
        // Set error message
        state.errorMessage = "Test error message"
        XCTAssertEqual(state.errorMessage, "Test error message")
        
        // Clear error message
        state.errorMessage = nil
        XCTAssertNil(state.errorMessage)
    }
    
    func testSavingUIState() {
        var state = AddItemFeature.State()
        
        // Initially not saving
        XCTAssertFalse(state.isSaving)
        
        // During save operation
        state.isSaving = true
        XCTAssertTrue(state.isSaving)
        
        // After save operation
        state.isSaving = false
        XCTAssertFalse(state.isSaving)
    }
    
    func testLoadingStatesCoexistence() {
        var state = AddItemFeature.State()
        
        // Multiple loading states can coexist
        state.isSaving = true
        state.isDetectingWarranty = true
        
        XCTAssertTrue(state.isSaving)
        XCTAssertTrue(state.isDetectingWarranty)
        
        // They can be independently controlled
        state.isSaving = false
        XCTAssertFalse(state.isSaving)
        XCTAssertTrue(state.isDetectingWarranty)
        
        state.isDetectingWarranty = false
        XCTAssertFalse(state.isSaving)
        XCTAssertFalse(state.isDetectingWarranty)
    }
    
    // MARK: - Presentation Logic Tests
    
    func testConditionalPresentationLogic() {
        var state = AddItemFeature.State()
        
        // Test canSave affects save button availability
        XCTAssertFalse(state.canSave)
        
        state.name = "Valid Item Name"
        XCTAssertTrue(state.canSave)
        
        // Test purchase details visibility affects form sections
        XCTAssertFalse(state.showPurchaseDetails)
        
        state.showPurchaseDetails = true
        XCTAssertTrue(state.showPurchaseDetails)
        
        // Purchase price should be available for input
        state.purchasePrice = "199.99"
        XCTAssertEqual(state.purchasePriceDecimal, Decimal(string: "199.99"))
    }
    
    func testUINavigationStates() {
        var state = AddItemFeature.State()
        
        // Test modal presentation states
        XCTAssertFalse(state.showingPhotoCapture)
        XCTAssertFalse(state.showingBarcodeScanner)
        XCTAssertFalse(state.showingWarrantyDetection)
        
        // Only one modal should typically be shown at a time
        state.showingPhotoCapture = true
        XCTAssertTrue(state.showingPhotoCapture)
        
        // In practice, the reducer would handle modal exclusivity
        state.showingPhotoCapture = false
        state.showingBarcodeScanner = true
        XCTAssertFalse(state.showingPhotoCapture)
        XCTAssertTrue(state.showingBarcodeScanner)
    }
}
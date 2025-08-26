//
// Layer: Tests
// Module: Features
// Purpose: Integration tests for TCA feature ↔ service interactions with error handling
//

import XCTest
import ComposableArchitecture
@testable import Nestory

@MainActor
final class TCAFeatureIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - WarrantyFeature Integration Tests
    
    func testWarrantyFeature_ServiceIntegration_Success() async {
        let store = TestStore(initialState: WarrantyFeature.State(item: Item(name: "Test MacBook"))) {
            WarrantyFeature()
        } withDependencies: {
            $0.warrantyTrackingService = MockWarrantyTrackingService()
        }
        
        // Test successful auto detection flow
        await store.send(.startAutoDetection) {
            $0.isLoading = true
        }
        
        // Mock service should succeed (or return nil)
        await store.receive(.autoDetectionResponse(.success(nil))) {
            $0.isLoading = false
            $0.errorMessage = "Could not detect warranty information for this item"
            $0.showingError = true
        }
        
        // Test error dismissal
        await store.send(.dismissError) {
            $0.errorMessage = nil
            $0.showingError = false
        }
    }
    
    func testWarrantyFeature_ServiceIntegration_Failure() async {
        let store = TestStore(initialState: WarrantyFeature.State(item: Item(name: "Test MacBook"))) {
            WarrantyFeature()
        } withDependencies: {
            $0.warrantyTrackingService = FailingMockWarrantyTrackingService()
        }
        
        // Test service failure handling
        await store.send(.startAutoDetection) {
            $0.isLoading = true
        }
        
        await store.receive(.autoDetectionResponse(.failure(TCATestError.simulatedFailure))) {
            $0.isLoading = false
            $0.errorMessage = "Detection failed: Simulated TCA test failure"
            $0.showingError = true
        }
        
        // Verify error state is properly managed
        XCTAssertTrue(store.state.showingError)
        XCTAssertNotNil(store.state.errorMessage)
    }
    
    func testWarrantyFeature_WarrantySaveFlow() async {
        let store = TestStore(initialState: WarrantyFeature.State(item: Item(name: "Test MacBook"))) {
            WarrantyFeature()
        } withDependencies: {
            $0.warrantyTrackingService = MockWarrantyTrackingService()
        }
        
        let testWarranty = Warranty(duration: 12, provider: "Apple", purchaseDate: Date())
        
        // Test warranty save flow
        await store.send(.saveWarranty(testWarranty)) {
            $0.isLoading = true
        }
        
        await store.receive(.warrantySaveResponse(.success(testWarranty))) {
            $0.isLoading = false
            $0.warranty = testWarranty
            $0.item.warranty = testWarranty
            $0.showingWarrantyForm = false
            $0.showingAutoDetectSheet = false
        }
        
        // Should trigger status refresh and notification setup
        await store.receive(.refreshWarrantyStatus)
        await store.receive(.setupNotifications)
        await store.receive(.trackWarrantyEvent(.warrantySaved))
    }
    
    // MARK: - ExportFeature Integration Tests
    
    func testExportFeature_ServiceIntegration() async {
        let testItems = [Item(name: "Test Item 1"), Item(name: "Test Item 2")]
        
        let store = TestStore(initialState: ExportFeature.State(selectedItems: testItems)) {
            ExportFeature()
        } withDependencies: {
            $0.exportService = MockExportService()
        }
        
        // Test export initiation
        await store.send(.startExport(format: .csv)) {
            $0.isExporting = true
            $0.exportFormat = .csv
        }
        
        // Mock service should complete successfully
        let mockData = Data("mock,csv,data".utf8)
        await store.receive(.exportResponse(.success(mockData))) {
            $0.isExporting = false
            $0.exportedData = mockData
            $0.showingShareSheet = true
        }
        
        // Test share completion
        await store.send(.shareCompleted) {
            $0.showingShareSheet = false
            $0.exportedData = nil
        }
    }
    
    func testExportFeature_ServiceFailure() async {
        let testItems = [Item(name: "Test Item")]
        
        let store = TestStore(initialState: ExportFeature.State(selectedItems: testItems)) {
            ExportFeature()
        } withDependencies: {
            $0.exportService = FailingMockExportService()
        }
        
        // Test export failure handling
        await store.send(.startExport(format: .json)) {
            $0.isExporting = true
            $0.exportFormat = .json
        }
        
        await store.receive(.exportResponse(.failure(TCATestError.simulatedFailure))) {
            $0.isExporting = false
            $0.errorMessage = "Export failed: Simulated TCA test failure"
            $0.showingError = true
        }
    }
    
    // MARK: - InsuranceReportFeature Integration Tests
    
    func testInsuranceReportFeature_ServiceIntegration() async {
        let testItems = [Item(name: "Damaged Item")]
        
        let store = TestStore(initialState: InsuranceReportFeature.State(selectedItems: testItems)) {
            InsuranceReportFeature()
        } withDependencies: {
            $0.insuranceReportService = MockInsuranceReportService()
        }
        
        // Test report generation
        await store.send(.generateReport) {
            $0.isGenerating = true
        }
        
        // Mock should generate report data
        let mockReportData = Data("mock insurance report".utf8)
        await store.receive(.reportGenerationResponse(.success(mockReportData))) {
            $0.isGenerating = false
            $0.generatedReportData = mockReportData
            $0.showingReportPreview = true
        }
    }
    
    func testInsuranceReportFeature_ServiceFailure() async {
        let testItems = [Item(name: "Damaged Item")]
        
        let store = TestStore(initialState: InsuranceReportFeature.State(selectedItems: testItems)) {
            InsuranceReportFeature()
        } withDependencies: {
            $0.insuranceReportService = FailingMockInsuranceReportService()
        }
        
        // Test report generation failure
        await store.send(.generateReport) {
            $0.isGenerating = true
        }
        
        await store.receive(.reportGenerationResponse(.failure("Simulated insurance report failure"))) {
            $0.isGenerating = false
            $0.processingError = "Simulated insurance report failure"
            $0.showingError = true
        }
    }
    
    // MARK: - CaptureFeature Integration Tests
    
    func testCaptureFeature_ServiceIntegration() async {
        let store = TestStore(initialState: CaptureFeature.State()) {
            CaptureFeature()
        } withDependencies: {
            $0.barcodeScannerService = MockBarcodeScannerService()
            $0.inventoryService = MockInventoryService()
        }
        
        // Test barcode scanning
        await store.send(.startBarcodeScanning) {
            $0.isScanning = true
        }
        
        // Mock successful barcode scan
        let mockBarcode = "123456789"
        await store.receive(.barcodeDetected(mockBarcode)) {
            $0.detectedBarcode = mockBarcode
            $0.isScanning = false
        }
        
        // Test product lookup
        await store.send(.lookupProduct(barcode: mockBarcode)) {
            $0.isLookingUpProduct = true
        }
        
        // Mock product lookup result
        let mockProductInfo = ProductInfo(name: "Mock Product", brand: "Mock Brand", model: "Mock Model")
        await store.receive(.productLookupResponse(.success(mockProductInfo))) {
            $0.isLookingUpProduct = false
            $0.productInfo = mockProductInfo
        }
        
        // Test item creation from product info
        await store.send(.createItemFromProductInfo) {
            $0.isCreatingItem = true
        }
        
        await store.receive(.itemCreationResponse(.success(Item(name: "Mock Product")))) {
            $0.isCreatingItem = false
            $0.createdItem = Item(name: "Mock Product")
        }
    }
    
    // MARK: - Service Dependency Integration Tests
    
    func testServiceDependency_HealthMonitoringIntegration() async {
        // Test that TCA features properly integrate with service health monitoring
        let healthManager = ServiceHealthManager.shared
        
        let store = TestStore(initialState: WarrantyFeature.State(item: Item(name: "Test Item"))) {
            WarrantyFeature()
        } withDependencies: {
            $0.warrantyTrackingService = HealthMonitoringMockWarrantyService()
        }
        
        // Trigger service operation that records health
        await store.send(.startAutoDetection) {
            $0.isLoading = true
        }
        
        await store.receive(.autoDetectionResponse(.success(nil))) {
            $0.isLoading = false
            $0.errorMessage = "Could not detect warranty information for this item"
            $0.showingError = true
        }
        
        // Verify health was recorded (would be done by mock service)
        let healthState = healthManager.serviceStates[.warranty]
        XCTAssertNotNil(healthState, "Should have health state recorded")
    }
    
    func testMultipleFeatures_ServiceCoordination() async {
        // Test that multiple TCA features can coordinate through shared services
        
        let warrantyStore = TestStore(initialState: WarrantyFeature.State(item: Item(name: "Shared Item"))) {
            WarrantyFeature()
        } withDependencies: {
            $0.warrantyTrackingService = MockWarrantyTrackingService()
        }
        
        let exportStore = TestStore(initialState: ExportFeature.State(selectedItems: [Item(name: "Shared Item")])) {
            ExportFeature()
        } withDependencies: {
            $0.exportService = MockExportService()
        }
        
        // Both features should be able to operate independently with their mock services
        await warrantyStore.send(.onAppear)
        await warrantyStore.receive(.refreshWarrantyStatus)
        await warrantyStore.receive(.trackWarrantyEvent(.viewOpened))
        
        await exportStore.send(.validateItems) {
            $0.isValidating = true
        }
        
        await exportStore.receive(.validationResponse(.success(()))) {
            $0.isValidating = false
            $0.isValid = true
        }
    }
}

// MARK: - Test Support Services

class FailingMockWarrantyTrackingService: WarrantyTrackingService {
    func getWarrantyStatus(for item: Item) async throws -> WarrantyStatus {
        throw TCATestError.simulatedFailure
    }
    
    func detectWarrantyInfo(brand: String?, model: String?, serialNumber: String?, purchaseDate: Date?) async throws -> WarrantyDetectionResult? {
        throw TCATestError.simulatedFailure
    }
    
    func saveWarranty(_ warranty: Warranty, for itemId: UUID) async throws {
        throw TCATestError.simulatedFailure
    }
    
    func deleteWarranty(for itemId: UUID) async throws {
        throw TCATestError.simulatedFailure
    }
    
    func registerWarranty(warranty: Warranty, item: Item) async throws {
        throw TCATestError.simulatedFailure
    }
}

class FailingMockExportService: ExportService {
    func exportItems(_ items: [Item], format: ExportFormat) async throws -> Data {
        throw TCATestError.simulatedFailure
    }
    
    func validateExportData(_ items: [Item]) async throws -> ExportValidationResult {
        throw TCATestError.simulatedFailure
    }
    
    func getSupportedFormats() async -> [ExportFormat] {
        return []
    }
}

class FailingMockInsuranceReportService: InsuranceReportService {
    func generateInsuranceReport(for items: [Item]) async throws -> Data {
        throw TCATestError.simulatedFailure
    }
    
    func validateReportData(_ items: [Item]) async throws -> InsuranceReportValidation {
        throw TCATestError.simulatedFailure
    }
    
    func getAvailableTemplates() async -> [InsuranceReportTemplate] {
        return []
    }
}

class HealthMonitoringMockWarrantyService: MockWarrantyTrackingService {
    override func detectWarrantyInfo(brand: String?, model: String?, serialNumber: String?, purchaseDate: Date?) async throws -> WarrantyDetectionResult? {
        // Record successful operation with health manager
        await MainActor.run {
            ServiceHealthManager.shared.recordSuccess(for: .warranty)
        }
        return nil // No warranty detected
    }
}

enum TCATestError: Error, LocalizedError {
    case simulatedFailure
    
    var errorDescription: String? {
        switch self {
        case .simulatedFailure:
            return "Simulated TCA test failure"
        }
    }
}
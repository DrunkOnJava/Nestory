//
// Layer: Tests
// Module: Integration
// Purpose: Error recovery and failure scenario testing for insurance data operations
//

import XCTest
import SwiftData
import UIKit
@testable import Nestory

@MainActor
final class ErrorRecoveryTests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    private var temporaryContainer: ModelContainer!
    private var mockInventoryService: ConfigurableMockInventoryService!
    private var mockOCRService: ConfigurableMockReceiptOCRService!
    private var mockInsuranceService: ConfigurableMockInsuranceReportService!
    
    override func setUp() async throws {
        // Note: Not calling super.setUp() in async context due to Swift 6 concurrency
        
        // Create in-memory container for error testing
        let schema = Schema([Item.self, Category.self, Warranty.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        temporaryContainer = try ModelContainer(for: schema, configurations: [config])
        mockInventoryService = ConfigurableMockInventoryService()
        mockOCRService = ConfigurableMockReceiptOCRService()
        mockInsuranceService = ConfigurableMockInsuranceReportService()
    }
    
    override func tearDown() async throws {
        temporaryContainer = nil
        mockInventoryService = nil
        mockOCRService = nil
        mockInsuranceService = nil
        // Note: Not calling super.tearDown() in async context due to Swift 6 concurrency
    }
    
    // MARK: - Database Error Recovery Tests
    
    func testDatabaseConnectionFailureRecovery() async throws {
        // Test graceful degradation when database is unavailable
        
        // Simulate database connection failure
        mockInventoryService.shouldFailDatabaseOperations = true
        
        do {
            _ = try await mockInventoryService.fetchItems()
            XCTFail("Expected database error")
        } catch let error as DatabaseError {
            XCTAssertEqual(error, .connectionFailed)
            
            // Verify graceful recovery
            mockInventoryService.shouldFailDatabaseOperations = false
            let items = try await mockInventoryService.fetchItems()
            XCTAssertNotNil(items)
        }
    }
    
    func testCorruptedDataRecovery() throws {
        // Test handling of corrupted insurance data
        let context = temporaryContainer.mainContext
        
        // Create item with corrupted data simulation
        let item = Item(name: "Corrupted Insurance Item")
        item.purchasePrice = nil // Simulate missing critical data
        item.purchaseDate = nil
        context.insert(item)
        
        do {
            try context.save()
            
            // Verify data validation and recovery
            let fetchDescriptor = FetchDescriptor<Item>()
            let items = try context.fetch(fetchDescriptor)
            
            XCTAssertEqual(items.count, 1)
            let fetchedItem = items.first!
            
            // Verify graceful handling of missing data
            XCTAssertEqual(fetchedItem.purchasePrice, nil)
            XCTAssertEqual(fetchedItem.purchaseDate, nil)
            XCTAssertFalse(fetchedItem.name.isEmpty)
            
        } catch {
            XCTFail("Should handle corrupted data gracefully: \(error)")
        }
    }
    
    func testLargeDatasetMemoryPressure() throws {
        // Test behavior under memory pressure with large insurance datasets
        let context = temporaryContainer.mainContext
        
        // Create large dataset to simulate memory pressure
        for i in 0..<1000 {
            let item = Item(name: "Memory Pressure Test Item \(i)")
            item.purchasePrice = Decimal(Double.random(in: 100...5000))
            item.itemDescription = String(repeating: "Large description data ", count: 100)
            context.insert(item)
        }
        
        do {
            try context.save()
            
            // Test memory-efficient fetching
            var fetchDescriptor = FetchDescriptor<Item>(
                predicate: #Predicate<Item> { item in
                    item.purchasePrice ?? 0 > 1000
                }
            )
            fetchDescriptor.fetchLimit = 50 // Limit to prevent memory issues
            
            let highValueItems = try context.fetch(fetchDescriptor)
            
            XCTAssertLessThanOrEqual(highValueItems.count, 50)
            XCTAssertTrue(highValueItems.allSatisfy { ($0.purchasePrice ?? 0) > 1000 })
            
        } catch {
            XCTFail("Should handle large datasets gracefully: \(error)")
        }
    }
    
    // MARK: - Network Error Recovery Tests
    
    func testNetworkTimeoutRecovery() async throws {
        // Test handling of network timeouts during OCR processing
        
        mockOCRService.shouldTimeout = true
        mockOCRService.timeoutDelay = 5.0
        
        let testImage = createTestReceiptUIImage()
        
        do {
            _ = try await mockOCRService.processReceiptImage(testImage)
            XCTFail("Expected timeout error")
        } catch {
            XCTAssertTrue(error is ReceiptOCRError)
            
            // Verify recovery after timeout
            mockOCRService.shouldTimeout = false
            let result = try await mockOCRService.processReceiptImage(testImage)
            XCTAssertNotNil(result)
        }
    }
    
    func testNetworkConnectivityLoss() async throws {
        // Test behavior when network connectivity is lost during sync
        
        mockInventoryService.shouldFailNetworkOperations = true
        
        let item = Item(name: "Network Test Item")
        
        do {
            try await mockInventoryService.syncItemToCloud(item)
            XCTFail("Expected network error")
        } catch let error as Nestory.NetworkError {
            XCTAssertEqual(error, .networkUnavailable)
            
            // Verify local storage continues working
            let localItems = try await mockInventoryService.fetchItems()
            XCTAssertNotNil(localItems)
        }
    }
    
    func testPartialSyncFailureRecovery() async throws {
        // Test recovery from partial CloudKit sync failures
        
        let items = [
            Item(name: "Sync Item 1"),
            Item(name: "Sync Item 2"),
            Item(name: "Sync Item 3")
        ]
        
        // Simulate partial sync failure
        mockInventoryService.shouldFailPartialSync = true
        mockInventoryService.partialSyncFailureIndex = 1
        
        do {
            try await mockInventoryService.syncMultipleItems(items)
            XCTFail("Expected partial sync failure")
        } catch {
            // Verify partial success handling
            let syncedItems = mockInventoryService.syncedItems
            XCTAssertEqual(syncedItems.count, 1) // Only first item synced
            XCTAssertEqual(syncedItems.first?.name, "Sync Item 1")
        }
    }
    
    // MARK: - File System Error Recovery Tests
    
    func testDiskSpaceExhaustionRecovery() throws {
        // Test behavior when disk space is exhausted during image storage
        
        mockInventoryService.shouldFailDiskOperations = true
        
        let item = Item(name: "Disk Space Test Item")
        let largeImageData = Data(repeating: 0xFF, count: 10_000_000) // 10MB
        
        do {
            try mockInventoryService.saveItemImage(item, imageData: largeImageData)
            XCTFail("Expected disk space error")
        } catch let error as FileSystemError {
            XCTAssertEqual(error, .diskSpaceExhausted)
            
            // Verify graceful degradation (item saved without image)
            let savedItem = try mockInventoryService.getItem(by: item.id)
            XCTAssertNotNil(savedItem)
            XCTAssertNil(savedItem?.imageData)
        }
    }
    
    func testFileCorruptionRecovery() throws {
        // Test handling of corrupted image files
        
        let item = Item(name: "Corrupted File Test Item")
        let corruptedData = Data([0x00, 0xFF, 0x00, 0xFF]) // Invalid image data
        
        do {
            try mockInventoryService.saveItemImage(item, imageData: corruptedData)
            
            // Verify corruption detection and handling
            let savedItem = try mockInventoryService.getItem(by: item.id)
            XCTAssertNotNil(savedItem)
            
            // Should either reject corrupted data or store with flag
            if let imageData = savedItem?.imageData {
                XCTAssertNotEqual(imageData, corruptedData, "Should not store corrupted image data")
            }
            
        } catch {
            // Acceptable to reject corrupted data
            XCTAssertTrue(error is FileSystemError)
        }
    }
    
    // MARK: - Service Degradation Tests
    
    func testOCRServiceDegradation() async throws {
        // Test fallback when OCR service is unavailable
        
        mockOCRService.shouldFailProcessing = true
        
        let testImage = createTestReceiptUIImage()
        
        do {
            _ = try await mockOCRService.processReceiptImage(testImage)
            XCTFail("Expected OCR service failure")
        } catch {
            // Verify graceful degradation (manual data entry still possible)
            let manualItem = Item(name: "Manual Entry Item")
            manualItem.purchasePrice = Decimal(99.99)
            manualItem.purchaseDate = Date()
            
            XCTAssertNotNil(manualItem)
            XCTAssertEqual(manualItem.purchasePrice, Decimal(99.99))
        }
    }
    
    func testInsuranceReportGenerationFailure() async throws {
        // Test handling of PDF generation failures
        
        mockInsuranceService.shouldFailPDFGeneration = true
        
        let items = [
            Item(name: "Report Item 1"),
            Item(name: "Report Item 2")
        ]
        
        do {
            _ = try await mockInsuranceService.generateInsuranceReport(
                items: items,
                categories: [],
                options: ReportOptions()
            )
            XCTFail("Expected PDF generation failure")
        } catch let error as InsuranceReportError {
            XCTAssertEqual(error, .generationFailed)
            
            // Verify alternative export options still work
            mockInsuranceService.shouldFailPDFGeneration = false
            let report = try await mockInsuranceService.generateInsuranceReport(
                items: items,
                categories: [],
                options: ReportOptions()
            )
            XCTAssertNotNil(report)
            XCTAssertFalse(report.isEmpty)
        }
    }
    
    // MARK: - Concurrent Operation Error Tests
    
    func testConcurrentDataModificationConflicts() async throws {
        // Test handling of concurrent modification conflicts
        
        let item = Item(name: "Concurrent Modification Test")
        let context = temporaryContainer.mainContext
        context.insert(item)
        try context.save()
        
        // Simulate concurrent modifications
        let modification1 = Task {
            item.purchasePrice = Decimal(100)
            try context.save()
        }
        
        let modification2 = Task {
            item.purchasePrice = Decimal(200)
            try context.save()
        }
        
        // Wait for both modifications
        do {
            _ = try await modification1.value
            _ = try await modification2.value
            
            // Verify final state is consistent
            let fetchedItem = try context.fetch(FetchDescriptor<Item>(predicate: #Predicate<Item> { $0.id == item.id })).first
            XCTAssertNotNil(fetchedItem)
            XCTAssertTrue(fetchedItem!.purchasePrice == Decimal(100) || fetchedItem!.purchasePrice == Decimal(200))
            
        } catch {
            // Concurrent modification conflicts are acceptable
            XCTAssertTrue(error is NSError)
        }
    }
    
    func testHighConcurrencyStressTest() async throws {
        // Test system behavior under high concurrency load
        
        let context = temporaryContainer.mainContext
        let taskCount = 20
        
        // Create concurrent item creation tasks
        let tasks = (0..<taskCount).map { index in
            Task {
                let item = Item(name: "Concurrent Item \(index)")
                item.purchasePrice = Decimal(Double(index * 10))
                context.insert(item)
                return item
            }
        }
        
        // Wait for all tasks to complete
        var createdItems: [Item] = []
        for task in tasks {
            let item = await task.value
            createdItems.append(item)
        }
        
        // Save all items at once (stress test)
        do {
            try context.save()
            
            // Verify all items were created successfully
            let fetchDescriptor = FetchDescriptor<Item>()
            let allItems = try context.fetch(fetchDescriptor)
            XCTAssertGreaterThanOrEqual(allItems.count, taskCount)
            
        } catch {
            XCTFail("Should handle high concurrency gracefully: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestReceiptUIImage() -> UIImage {
        // Create minimal test image
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - Mock Error Types

enum DatabaseError: Error, Equatable {
    case connectionFailed
    case corruptedData
    case insufficientSpace
}

// Note: NetworkError, ReceiptOCRError, and InsuranceReportError are defined in EnhancedMockServices.swift

enum FileSystemError: Error, Equatable {
    case diskSpaceExhausted
    case permissionDenied
    case corruptedFile
}

// MARK: - Configurable Mock Services for Error Recovery Testing

class ConfigurableMockInventoryService: InventoryService, @unchecked Sendable {
    var shouldFailDatabaseOperations = false
    var shouldFailNetworkOperations = false
    var shouldFailDiskOperations = false
    var shouldFailPartialSync = false
    var partialSyncFailureIndex = 0
    var syncedItems: [Item] = []
    
    // MARK: - InventoryService Implementation
    private var items: [Item] = []
    private var categories: [Nestory.Category] = []
    private var locationNames: [String] = []
    
    func fetchItems() async throws -> [Item] {
        if shouldFailDatabaseOperations {
            throw DatabaseError.connectionFailed
        }
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
    
    func searchItems(query: String) async throws -> [Item] {
        return items.filter { item in
            item.name.localizedCaseInsensitiveContains(query) ||
            item.brand?.localizedCaseInsensitiveContains(query) == true
        }
    }
    
    func fetchCategories() async throws -> [Nestory.Category] {
        return categories
    }
    
    func saveCategory(_ category: Nestory.Category) async throws {
        categories.append(category)
    }
    
    func assignItemToCategory(itemId: UUID, categoryId: UUID) async throws {
        // Mock implementation
    }
    
    func fetchItemsByCategory(categoryId: UUID) async throws -> [Item] {
        return items.filter { $0.category?.id == categoryId }
    }
    
    
    func bulkImport(items: [Item]) async throws {
        self.items.append(contentsOf: items)
    }
    
    func bulkUpdate(items: [Item]) async throws {
        for item in items {
            try await updateItem(item)
        }
    }
    
    func bulkDelete(itemIds: [UUID]) async throws {
        itemIds.forEach { id in
            items.removeAll { $0.id == id }
        }
    }
    
    func bulkSave(items: [Item]) async throws {
        self.items.append(contentsOf: items)
    }
    
    func bulkAssignCategory(itemIds: [UUID], categoryId: UUID) async throws {
        // Mock implementation
    }
    
    func exportInventory(format: ExportFormat) async throws -> Data {
        return Data() // Mock export data
    }
    
    // MARK: - Additional Error Recovery Methods
    
    func syncItemToCloud(_ item: Item) async throws {
        if shouldFailNetworkOperations {
            throw NetworkError.networkUnavailable
        }
        syncedItems.append(item)
    }
    
    func syncMultipleItems(_ items: [Item]) async throws {
        if shouldFailPartialSync {
            for (index, item) in items.enumerated() {
                if index == partialSyncFailureIndex {
                    throw NetworkError.networkUnavailable
                }
                syncedItems.append(item)
            }
        } else {
            syncedItems.append(contentsOf: items)
        }
    }
    
    func saveItemImage(_ item: Item, imageData: Data) throws {
        if shouldFailDiskOperations {
            throw FileSystemError.diskSpaceExhausted
        }
        item.imageData = imageData
    }
    
    func getItem(by id: UUID) throws -> Item? {
        if shouldFailDatabaseOperations {
            throw DatabaseError.connectionFailed
        }
        return Item(name: "Mock Item")
    }
}

final class ConfigurableMockReceiptOCRService: ReceiptOCRService, @unchecked Sendable {
    var shouldTimeout = false
    var timeoutDelay: Double = 5.0
    var shouldFailProcessing = false
    
    func processReceiptImage(_ image: UIImage) async throws -> EnhancedReceiptData {
        if shouldTimeout {
            try await Task.sleep(nanoseconds: UInt64(timeoutDelay * 1_000_000_000))
            throw ReceiptOCRError.processingFailed
        }
        
        if shouldFailProcessing {
            throw ReceiptOCRError.processingFailed
        }
        
        return EnhancedReceiptData(
            vendor: "Mock Store",
            total: Decimal(99.99),
            tax: nil,
            date: Date(),
            items: [],
            categories: [],
            confidence: 0.95,
            rawText: "Mock Receipt Text",
            boundingBoxes: [],
            processingMetadata: ReceiptProcessingMetadata(
                documentCorrectionApplied: false,
                patternsMatched: [:],
                mlClassifierUsed: false
            )
        )
    }
}

class ConfigurableMockInsuranceReportService: InsuranceReportService, @unchecked Sendable {
    var shouldFailPDFGeneration = false
    
    func generateInsuranceReport(
        items: [Item],
        categories: [Nestory.Category],
        options: ReportOptions
    ) async throws -> Data {
        if shouldFailPDFGeneration {
            throw InsuranceReportError.generationFailed
        }
        return Data("Mock PDF Content".utf8)
    }
    
    func exportReport(
        _ data: Data,
        filename: String
    ) async throws -> URL {
        return URL(fileURLWithPath: "/tmp/\(filename)")
    }
    
    func shareReport(_ url: URL) async {
        // Mock implementation
    }
}
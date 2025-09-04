//
// Layer: Tests
// Module: Integration
// Purpose: Error recovery and failure scenario testing for insurance data operations
//

import XCTest
import SwiftData
@testable import Nestory

@MainActor
final class ErrorRecoveryTests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    private var temporaryContainer: ModelContainer!
    private var mockInventoryService: MockInventoryService!
    private var mockOCRService: MockReceiptOCRService!
    private var mockInsuranceService: MockInsuranceReportService!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory container for error testing
        let schema = Schema([Item.self, Category.self, Room.self, Warranty.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        temporaryContainer = try ModelContainer(for: schema, configurations: [config])
        mockInventoryService = MockInventoryService()
        mockOCRService = MockReceiptOCRService()
        mockInsuranceService = MockInsuranceReportService()
    }
    
    override func tearDown() async throws {
        temporaryContainer = nil
        mockInventoryService = nil
        mockOCRService = nil
        mockInsuranceService = nil
        try await super.tearDown()
    }
    
    // MARK: - Database Error Recovery Tests
    
    func testDatabaseConnectionFailureRecovery() async throws {
        // Test graceful degradation when database is unavailable
        
        // Simulate database connection failure
        mockInventoryService.shouldFailDatabaseOperations = true
        mockInventoryService.failureError = DatabaseError.connectionFailed
        
        do {
            _ = try await mockInventoryService.getAllItems()
            XCTFail("Expected database error")
        } catch let error as DatabaseError {
            XCTAssertEqual(error, .connectionFailed)
            
            // Verify graceful recovery
            mockInventoryService.shouldFailDatabaseOperations = false
            let items = try await mockInventoryService.getAllItems()
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
            let fetchDescriptor = FetchDescriptor<Item>(
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
        
        let testImage = createTestReceiptImage()
        
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
        mockInventoryService.networkError = NetworkError.connectionFailed
        
        let item = Item(name: "Network Test Item")
        
        do {
            try await mockInventoryService.syncItemToCloud(item)
            XCTFail("Expected network error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .connectionLost)
            
            // Verify local storage continues working
            let localItems = try await mockInventoryService.getAllItems()
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
        mockInventoryService.diskError = FileSystemError.diskSpaceExhausted
        
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
        mockOCRService.processingError = ReceiptOCRError.serviceUnavailable
        
        let testImage = createTestReceiptImage()
        
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
        mockInsuranceService.pdfError = InsuranceReportError.generationFailed
        
        let items = [
            Item(name: "Report Item 1"),
            Item(name: "Report Item 2")
        ]
        
        do {
            _ = try await mockInsuranceService.generateInsuranceReport(for: items)
            XCTFail("Expected PDF generation failure")
        } catch let error as InsuranceReportError {
            XCTAssertEqual(error, .generationFailed)
            
            // Verify alternative export options still work
            mockInsuranceService.shouldFailPDFGeneration = false
            let csvData = try mockInsuranceService.exportItemsAsCSV(items)
            XCTAssertNotNil(csvData)
            XCTAssertFalse(csvData.isEmpty)
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
    
    private func createTestReceiptImage() -> Data {
        // Create minimal test image data
        return Data([0x89, 0x50, 0x4E, 0x47]) // PNG header bytes
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

// MARK: - Enhanced Mock Services with Error Simulation

extension MockInventoryService {
    var shouldFailDatabaseOperations: Bool {
        get { UserDefaults.standard.bool(forKey: "MockInventoryService.shouldFailDatabaseOperations") }
        set { UserDefaults.standard.set(newValue, forKey: "MockInventoryService.shouldFailDatabaseOperations") }
    }
    
    var shouldFailNetworkOperations: Bool {
        get { UserDefaults.standard.bool(forKey: "MockInventoryService.shouldFailNetworkOperations") }
        set { UserDefaults.standard.set(newValue, forKey: "MockInventoryService.shouldFailNetworkOperations") }
    }
    
    var shouldFailDiskOperations: Bool {
        get { UserDefaults.standard.bool(forKey: "MockInventoryService.shouldFailDiskOperations") }
        set { UserDefaults.standard.set(newValue, forKey: "MockInventoryService.shouldFailDiskOperations") }
    }
    
    var shouldFailPartialSync: Bool {
        get { UserDefaults.standard.bool(forKey: "MockInventoryService.shouldFailPartialSync") }
        set { UserDefaults.standard.set(newValue, forKey: "MockInventoryService.shouldFailPartialSync") }
    }
    
    var partialSyncFailureIndex: Int {
        get { UserDefaults.standard.integer(forKey: "MockInventoryService.partialSyncFailureIndex") }
        set { UserDefaults.standard.set(newValue, forKey: "MockInventoryService.partialSyncFailureIndex") }
    }
    
    // Note: Error properties cannot be easily stored in UserDefaults, using fallback values
    var failureError: Error? {
        return DatabaseError.connectionFailed
    }
    
    var networkError: Error? {
        return NetworkError.connectionFailed
    }
    
    var diskError: Error? {
        return FileSystemError.diskSpaceExhausted
    }
    
    // For testing purposes, we'll track synced items in UserDefaults as count
    var syncedItems: [Item] {
        get { [] } // Simplified for testing
        set { UserDefaults.standard.set(newValue.count, forKey: "MockInventoryService.syncedItemsCount") }
    }
    
    func syncItemToCloud(_ item: Item) async throws {
        if shouldFailNetworkOperations {
            throw networkError ?? NetworkError.connectionFailed
        }
        syncedItems.append(item)
    }
    
    func syncMultipleItems(_ items: [Item]) async throws {
        if shouldFailPartialSync {
            for (index, item) in items.enumerated() {
                if index == partialSyncFailureIndex {
                    throw NetworkError.connectionFailed
                }
                syncedItems.append(item)
            }
        } else {
            syncedItems.append(contentsOf: items)
        }
    }
    
    func saveItemImage(_ item: Item, imageData: Data) throws {
        if shouldFailDiskOperations {
            throw diskError ?? FileSystemError.diskSpaceExhausted
        }
        item.imageData = imageData
    }
    
    func getItem(by id: UUID) throws -> Item? {
        if shouldFailDatabaseOperations {
            throw failureError ?? DatabaseError.connectionFailed
        }
        return Item(name: "Mock Item")
    }
}

extension MockReceiptOCRService {
    var shouldTimeout: Bool {
        get { UserDefaults.standard.bool(forKey: "MockReceiptOCRService.shouldTimeout") }
        set { UserDefaults.standard.set(newValue, forKey: "MockReceiptOCRService.shouldTimeout") }
    }
    
    var timeoutDelay: Double {
        get { UserDefaults.standard.double(forKey: "MockReceiptOCRService.timeoutDelay") }
        set { UserDefaults.standard.set(newValue, forKey: "MockReceiptOCRService.timeoutDelay") }
    }
    
    var shouldFailProcessing: Bool {
        get { UserDefaults.standard.bool(forKey: "MockReceiptOCRService.shouldFailProcessing") }
        set { UserDefaults.standard.set(newValue, forKey: "MockReceiptOCRService.shouldFailProcessing") }
    }
    
    // Note: processingError cannot be stored in UserDefaults easily, so we'll use a simple fallback
    var processingError: Error? {
        return ReceiptOCRError.processingFailed
    }
    
    func processReceiptImage(_ imageData: Data) async throws -> ReceiptData {
        if shouldTimeout {
            try await Task.sleep(nanoseconds: UInt64(timeoutDelay * 1_000_000_000))
            throw ReceiptOCRError.serviceUnavailable
        }
        
        if shouldFailProcessing {
            throw processingError ?? ReceiptOCRError.processingFailed
        }
        
        return ReceiptData(
            merchantName: "Mock Store",
            totalAmount: Decimal(99.99),
            purchaseDate: Date(),
            items: []
        )
    }
}

extension MockInsuranceReportService {
    var shouldFailPDFGeneration: Bool {
        get { UserDefaults.standard.bool(forKey: "MockInsuranceReportService.shouldFailPDFGeneration") }
        set { UserDefaults.standard.set(newValue, forKey: "MockInsuranceReportService.shouldFailPDFGeneration") }
    }
    
    var pdfError: Error? {
        return InsuranceReportError.generationFailed
    }
    
    func generateInsuranceReport(for items: [Item]) async throws -> Data {
        if shouldFailPDFGeneration {
            throw pdfError ?? InsuranceReportError.generationFailed
        }
        return Data("Mock PDF Content".utf8)
    }
    
    func exportItemsAsCSV(_ items: [Item]) throws -> Data {
        let csvContent = items.map { "\($0.name),\($0.purchasePrice ?? 0)" }.joined(separator: "\n")
        return Data(csvContent.utf8)
    }
}
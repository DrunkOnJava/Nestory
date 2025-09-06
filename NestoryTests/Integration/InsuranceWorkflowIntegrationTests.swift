//
// Layer: Tests
// Module: Integration
// Purpose: Minimal integration testing for insurance workflows (reduced functionality)
//

import XCTest
import SwiftData
import ComposableArchitecture
import UIKit
@testable import Nestory

/// Minimal integration tests for insurance documentation workflows
/// NOTE: Full damage assessment and insurance report generation tests disabled
/// pending integration of these features into RootFeature
@MainActor
final class InsuranceWorkflowIntegrationTests: XCTestCase {
    
    var store: TestStore<RootFeature.State, RootFeature.Action>!
    var modelContainer: ModelContainer!
    
    override func setUp() async throws {
        // Note: Not calling super.setUp() in async context due to Swift 6 concurrency
        
        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            modelContainer = try ModelContainer(
                for: Item.self, Category.self, Warranty.self, Receipt.self,
                configurations: config
            )
        } catch {
            // Use print instead of Logger in test files
            print("Failed to create test ModelContainer: \(error.localizedDescription)")
            XCTFail("Failed to create test ModelContainer: \(error.localizedDescription)")
            throw error
        }
        
        // Create test store with live dependencies
        store = TestStore(
            initialState: RootFeature.State(),
            reducer: { RootFeature() }
        ) {
            $0.inventoryService = TestMockInventoryService()
            // Note: insuranceReportService and receiptOCRService are not directly on DependencyValues
            // They may be part of specific features
        }
    }
    
    override func tearDown() async throws {
        store = nil
        modelContainer = nil
        // Note: Not calling super.tearDown() in async context due to Swift 6 concurrency
    }
    
    // MARK: - Basic Inventory Tests
    
    /// Test basic inventory item creation for insurance documentation
    func testBasicInventoryItemCreation() async throws {
        // Given: Insurance scenario with high-value items  
        let scenario = InsuranceTestScenarios.kitchenFloodingIncident()
        
        // When: Items are added to inventory
        for item in scenario.items {
            try modelContainer.mainContext.insert(item)
        }
        try modelContainer.mainContext.save()
        
        // Then: Items should be available for insurance documentation
        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try modelContainer.mainContext.fetch(fetchDescriptor)
        
        XCTAssertEqual(items.count, scenario.items.count, "All items should be saved")
    }
    
    // NOTE: Full test suite disabled pending feature integration
    // See InsuranceWorkflowIntegrationTests_DISABLED.swift for complete tests
}

// MARK: - Mock Services for Testing

/// Mock inventory service that simulates real behavior without actual persistence
private final class TestMockInventoryService: InventoryService, @unchecked Sendable {
    private var items: [Item] = []
    private var categories: [Nestory.Category] = []
    private var locationNames: [String] = []
    
    // MARK: - Core Operations
    func fetchItems() async throws -> [Item] {
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
    
    // MARK: - Search Operations
    func searchItems(query: String) async throws -> [Item] {
        return items.filter { item in
            item.name.localizedCaseInsensitiveContains(query) ||
            item.brand?.localizedCaseInsensitiveContains(query) == true
        }
    }
    
    // MARK: - Category Operations
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
    
    // MARK: - Room Operations
    
    // MARK: - Batch Operations
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
        // Mock implementation - would assign category to multiple items
    }
    
    func exportInventory(format: ExportFormat) async throws -> Data {
        return Data() // Mock export data
    }
}

// ExportFormat is imported from Foundation/Models/ExportFormat.swift via @testable import Nestory

/// Mock insurance report service
private final class TestMockInsuranceReportService: InsuranceReportService, @unchecked Sendable {
    func generateInsuranceReport(items: [Item], categories: [Nestory.Category], options: ReportOptions) async throws -> Data {
        return Data() // Mock PDF data
    }
    
    func exportReport(_ data: Data, filename: String) async throws -> URL {
        return URL(fileURLWithPath: "/tmp/\(filename)")
    }
    
    func shareReport(_ url: URL) async {
        // Mock implementation
    }
}

/// Mock receipt OCR service
private final class TestMockReceiptOCRService: ReceiptOCRService, @unchecked Sendable {
    func processReceiptImage(_ image: UIImage) async throws -> EnhancedReceiptData {
        return EnhancedReceiptData(
            vendor: "Mock Store",
            total: Decimal(100.00),
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

// InsuranceTestScenarios is defined in the separate file InsuranceTestScenarios.swift
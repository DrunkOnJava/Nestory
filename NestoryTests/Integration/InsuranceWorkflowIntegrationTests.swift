//
// Layer: Tests
// Module: Integration
// Purpose: Minimal integration testing for insurance workflows (reduced functionality)
//

import XCTest
import SwiftData
import ComposableArchitecture
@testable import Nestory

/// Minimal integration tests for insurance documentation workflows
/// NOTE: Full damage assessment and insurance report generation tests disabled
/// pending integration of these features into RootFeature
@MainActor
final class InsuranceWorkflowIntegrationTests: XCTestCase {
    
    var store: TestStore<RootFeature.State, RootFeature.Action>!
    var modelContainer: ModelContainer!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            modelContainer = try ModelContainer(
                for: Item.self, Nestory.Category.self, Room.self, Receipt.self, Warranty.self,
                configurations: config
            )
        } catch {
            print("Failed to create test ModelContainer: \(error.localizedDescription)")
            throw error
        }
        
        // Create test store with live dependencies
        store = TestStore(
            initialState: RootFeature.State(),
            reducer: { RootFeature() }
        ) {
            $0.inventoryService = MockInventoryService()
            $0.insuranceReportService = MockInsuranceReportService()
            $0.receiptOCRService = MockReceiptOCRService()
            // Note: damageAssessmentService not available in current RootFeature
        }
    }
    
    override func tearDown() async throws {
        store = nil
        modelContainer = nil
        try await super.tearDown()
    }
    
    // MARK: - Basic Inventory Tests
    
    /// Test basic inventory item creation for insurance documentation
    func testBasicInventoryItemCreation() async throws {
        // Given: Insurance scenario with high-value items
        let scenario = InsuranceTestScenarios.floodDamage()
        
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
private final class MockInventoryService: InventoryService, @unchecked Sendable {
    private var items: [Item] = []
    private var categories: [Nestory.Category] = []
    private var rooms: [Room] = []
    
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
    func fetchRooms() async throws -> [Room] {
        return rooms
    }
    
    func saveRoom(_ room: Room) async throws {
        rooms.append(room)
    }
    
    func assignItemToRoom(itemId: UUID, roomId: UUID) async throws {
        // Mock implementation
    }
    
    func fetchItemsByRoom(roomId: UUID) async throws -> [Item] {
        return items.filter { $0.room?.id == roomId }
    }
    
    // MARK: - Batch Operations
    func batchUpdateItems(_ items: [Item]) async throws {
        for item in items {
            try await updateItem(item)
        }
    }
    
    func deleteItems(ids: [UUID]) async throws {
        ids.forEach { id in
            items.removeAll { $0.id == id }
        }
    }
}

/// Mock insurance report service
private final class MockInsuranceReportService: InsuranceReportService, @unchecked Sendable {
    func generateReport(for items: [Item]) async throws -> Data {
        return Data() // Mock PDF data
    }
    
    func estimateClaimValue(for items: [Item]) async -> Decimal {
        return items.reduce(Decimal.zero) { $0 + $1.purchasePrice }
    }
}

/// Mock receipt OCR service
private final class MockReceiptOCRService: ReceiptOCRService, @unchecked Sendable {
    func scanReceipt(imageData: Data) async throws -> Receipt {
        return Receipt(
            merchantName: "Mock Store",
            date: Date(),
            totalAmount: Decimal(100),
            taxAmount: Decimal(10),
            items: []
        )
    }
}

// MARK: - Test Data Scenarios

/// Predefined insurance claim scenarios for testing
enum InsuranceTestScenarios {
    
    /// Creates a flood damage scenario with water-damaged items
    static func floodDamage() -> (items: [Item], rooms: [Room]) {
        let basement = Room(name: "Basement", floor: 0)
        
        let items = [
            Item(
                name: "Gaming Console",
                brand: "Sony",
                model: "PlayStation 5",
                serialNumber: "PS5-123456",
                purchasePrice: Decimal(500),
                purchaseDate: Date().addingTimeInterval(-365 * 24 * 60 * 60),
                category: nil,
                room: basement,
                notes: "Water damage from flooding"
            ),
            Item(
                name: "4K Television",
                brand: "Samsung",
                model: "QN55Q80B",
                serialNumber: "TV-789012",
                purchasePrice: Decimal(1200),
                purchaseDate: Date().addingTimeInterval(-180 * 24 * 60 * 60),
                category: nil,
                room: basement,
                notes: "Water damage - non-functional"
            ),
            Item(
                name: "Home Theater System",
                brand: "Bose",
                model: "Lifestyle 650",
                serialNumber: "BOSE-345678",
                purchasePrice: Decimal(3000),
                purchaseDate: Date().addingTimeInterval(-730 * 24 * 60 * 60),
                category: nil,
                room: basement,
                notes: "Complete water damage"
            )
        ]
        
        return (items, [basement])
    }
    
    /// Creates a house fire scenario affecting multiple rooms
    static func houseFire() -> (items: [Item], rooms: [Room]) {
        let livingRoom = Room(name: "Living Room", floor: 1)
        let kitchen = Room(name: "Kitchen", floor: 1)
        let bedroom = Room(name: "Master Bedroom", floor: 2)
        
        // Create items across different rooms - simplified for testing
        let items = [
            Item(
                name: "Laptop",
                brand: "Apple",
                model: "MacBook Pro",
                serialNumber: "MBP-001",
                purchasePrice: Decimal(2500),
                purchaseDate: Date().addingTimeInterval(-90 * 24 * 60 * 60),
                category: nil,
                room: livingRoom,
                notes: "Fire damage"
            )
        ]
        
        return (items, [livingRoom, kitchen, bedroom])
    }
}
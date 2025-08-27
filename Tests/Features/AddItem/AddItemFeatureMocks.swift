//
// Layer: Tests
// Module: Features
// Purpose: Mock services for AddItemFeature tests
//

@testable import Nestory
import Foundation

// MARK: - Mock Inventory Service

class MockInventoryService: InventoryService {
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

// MARK: - Mock Category Service

class MockCategoryService: CategoryService {
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

// MARK: - Mock Warranty Tracking Service

class MockWarrantyTrackingService: WarrantyTrackingService {
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

// MARK: - Mock Barcode Scanner Service

class MockBarcodeScannerService: BarcodeScannerService {
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

// MARK: - Mock Errors

enum MockError: Error {
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
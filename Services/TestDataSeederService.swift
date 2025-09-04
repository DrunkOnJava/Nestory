//
// Layer: Services
// Module: TestDataSeederService
// Purpose: Provides test data seeding functionality for development and testing environments
//

import Foundation
import SwiftData
import ComposableArchitecture

protocol TestDataSeederService: Sendable {
    func seedTestData() async throws
    func clearTestData() async throws
    func hasTestData() async throws -> Bool
}

@MainActor
final class LiveTestDataSeederService: TestDataSeederService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func seedTestData() async throws {
        // Only seed if no existing data
        guard try await hasTestData() == false else { return }
        
        // Create sample items for testing
        let sampleItems = [
            createSampleItem(name: "MacBook Pro", category: "Electronics", value: 2999.99, room: "Home Office"),
            createSampleItem(name: "Wedding Ring", category: "Jewelry", value: 5000.00, room: "Bedroom"),
            createSampleItem(name: "Dining Table", category: "Furniture", value: 1200.00, room: "Dining Room"),
            createSampleItem(name: "Camera", category: "Electronics", value: 800.00, room: "Living Room"),
            createSampleItem(name: "Artwork", category: "Art", value: 1500.00, room: "Living Room")
        ]
        
        for item in sampleItems {
            modelContext.insert(item)
        }
        
        try modelContext.save()
    }
    
    func clearTestData() async throws {
        let descriptor = FetchDescriptor<Item>()
        let items = try modelContext.fetch(descriptor)
        
        for item in items {
            modelContext.delete(item)
        }
        
        try modelContext.save()
    }
    
    func hasTestData() async throws -> Bool {
        let descriptor = FetchDescriptor<Item>()
        let count = try modelContext.fetchCount(descriptor)
        return count > 0
    }
    
    private func createSampleItem(name: String, category: String, value: Double, room: String) -> Item {
        let item = Item(name: name)
        item.purchasePrice = Decimal(value)
        item.room = room
        item.notes = "Sample item for testing"
        item.purchaseDate = Date().addingTimeInterval(-Double.random(in: 0...31536000)) // Random date in past year
        return item
    }
}

final class MockTestDataSeederService: TestDataSeederService {
    func seedTestData() async throws {
        // Mock implementation - no actual seeding
    }
    
    func clearTestData() async throws {
        // Mock implementation - no actual clearing
    }
    
    func hasTestData() async throws -> Bool {
        return false
    }
}
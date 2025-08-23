//
// Layer: Services
// Module: Services
// Purpose: Enhanced mock inventory service with reliability features
//

import Foundation

/// Enhanced mock inventory service that provides realistic behavior and reliability testing
public struct ReliableMockInventoryService: InventoryService, Sendable {
    
    public init() {}
    
    public func fetchItems() async throws -> [Item] {
        // Simulate realistic network conditions
        try await simulateNetworkConditions()
        
        let items = createMockItems()
        
        // Record successful operation
        Task { @MainActor in
            ServiceHealthManager.shared.recordSuccess(for: .inventory)
        }
        
        return items
    }
    
    public func fetchItem(id: UUID) async throws -> Item? {
        try await simulateNetworkConditions()
        
        let items = createMockItems()
        return items.first { $0.id == id }
    }
    
    public func saveItem(_ item: Item) async throws {
        try await simulateNetworkConditions()
        
        // Simulate potential save failures in degraded conditions
        if await shouldSimulateFailure() {
            let error = InventoryError.saveFailed("Simulated network timeout")
            Task { @MainActor in
                ServiceHealthManager.shared.recordFailure(for: .inventory, error: error)
            }
            throw error
        }
        
        // Simulate save operation - in a real implementation this would persist
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        Task { @MainActor in
            ServiceHealthManager.shared.recordSuccess(for: .inventory)
        }
    }
    
    public func updateItem(_ item: Item) async throws {
        try await simulateNetworkConditions()
        
        // Simulate update operation - in a real implementation this would persist
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        Task { @MainActor in
            ServiceHealthManager.shared.recordSuccess(for: .inventory)
        }
    }
    
    public func deleteItem(id: UUID) async throws {
        try await simulateNetworkConditions()
        
        // Simulate delete operation - in a real implementation this would persist
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        Task { @MainActor in
            ServiceHealthManager.shared.recordSuccess(for: .inventory)
        }
    }
    
    public func searchItems(query: String) async throws -> [Item] {
        try await simulateNetworkConditions()
        
        let items = createMockItems()
        
        if query.isEmpty { return items }
        
        return items.filter { item in
            item.name.localizedCaseInsensitiveContains(query) ||
            item.category?.name.localizedCaseInsensitiveContains(query) == true ||
            item.room?.localizedCaseInsensitiveContains(query) == true ||
            item.brand?.localizedCaseInsensitiveContains(query) == true ||
            item.modelNumber?.localizedCaseInsensitiveContains(query) == true
        }
    }
    
    public func fetchCategories() async throws -> [Category] {
        try await simulateNetworkConditions()
        return createMockCategories()
    }
    
    public func saveCategory(_ category: Category) async throws {
        try await simulateNetworkConditions()
        // Simulate category save
        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
    }
    
    public func assignItemToCategory(itemId: UUID, categoryId: UUID) async throws {
        try await simulateNetworkConditions()
        // Simulate assignment
        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
    }
    
    public func fetchItemsByCategory(categoryId: UUID) async throws -> [Item] {
        try await simulateNetworkConditions()
        
        let items = createMockItems()
        return items.filter { $0.category?.id == categoryId }
    }
    
    public func fetchRooms() async throws -> [Room] {
        try await simulateNetworkConditions()
        return createMockRooms()
    }
    
    public func bulkImport(items: [Item]) async throws {
        try await simulateNetworkConditions()
        
        // Simulate bulk import
        try await Task.sleep(nanoseconds: UInt64(items.count * 50_000_000)) // 0.05s per item
    }
    
    public func bulkUpdate(items: [Item]) async throws {
        try await simulateNetworkConditions()
        
        // Simulate bulk update
        try await Task.sleep(nanoseconds: UInt64(items.count * 50_000_000)) // 0.05s per item
    }
    
    public func bulkDelete(itemIds: [UUID]) async throws {
        try await simulateNetworkConditions()
        
        // Simulate bulk delete
        try await Task.sleep(nanoseconds: UInt64(itemIds.count * 50_000_000)) // 0.05s per item
    }
    
    public func bulkSave(items: [Item]) async throws {
        try await simulateNetworkConditions()
        
        // Simulate bulk save
        try await Task.sleep(nanoseconds: UInt64(items.count * 50_000_000)) // 0.05s per item
    }
    
    public func bulkAssignCategory(itemIds: [UUID], categoryId: UUID) async throws {
        try await simulateNetworkConditions()
        
        // Simulate bulk category assignment
        try await Task.sleep(nanoseconds: UInt64(itemIds.count * 25_000_000)) // 0.025s per item
    }
    
    public func exportInventory(format: ExportFormat) async throws -> Data {
        try await simulateNetworkConditions()
        
        let items = createMockItems()
        
        // Simulate export process
        switch format {
        case .json:
            return try JSONEncoder().encode(items)
        case .csv:
            return "Name,Brand,Category,Purchase Price\n".data(using: .utf8) ?? Data()
        default:
            return Data()
        }
    }
    
    // MARK: - Reliability Simulation
    
    private func simulateNetworkConditions() async throws {
        // Simulate realistic network delays
        let delay = UInt64.random(in: 100_000_000...500_000_000) // 0.1-0.5 seconds
        try await Task.sleep(nanoseconds: delay)
        
        // Simulate occasional network issues (5% failure rate in degraded mode)
        if await shouldSimulateFailure() {
            throw URLError(.notConnectedToInternet)
        }
    }
    
    private func shouldSimulateFailure() async -> Bool {
        return await withCheckedContinuation { continuation in
            Task { @MainActor in
                let healthManager = ServiceHealthManager.shared
                let result = healthManager.isDegradedMode && Int.random(in: 1...20) == 1 // 5% failure rate
                continuation.resume(returning: result)
            }
        }
    }
}

// MARK: - Mock Data Creation

private func createMockItems() -> [Item] {
    let electronics = createMockCategories().first { $0.name == "Electronics" }
    let furniture = createMockCategories().first { $0.name == "Furniture" }
    let kitchen = createMockCategories().first { $0.name == "Kitchen" }
    
    // Create MacBook Pro
    let macbook = Item(
        name: "MacBook Pro 16-inch",
        itemDescription: "Space Gray, 16GB RAM, 512GB SSD - Primary work computer",
        quantity: 1,
        category: electronics
    )
    macbook.brand = "Apple"
    macbook.modelNumber = "MK183LL/A"
    macbook.serialNumber = "C02YX0ABMD6T"
    macbook.purchasePrice = 2399
    macbook.purchaseDate = Date().addingTimeInterval(-365 * 24 * 60 * 60) // 1 year ago
    macbook.room = "Home Office"
    macbook.specificLocation = "Desk"
    macbook.condition = ItemCondition.excellent.rawValue
    macbook.warrantyExpirationDate = Date().addingTimeInterval(365 * 24 * 60 * 60) // 1 year from now
    macbook.warrantyProvider = "Apple Inc."
    macbook.notes = "AppleCare+ coverage included. Used for professional development work."
    
    // Create Herman Miller Chair (High-value item for insurance demo)
    let chair = Item(
        name: "Herman Miller Aeron Chair",
        itemDescription: "Size B, Graphite frame with Mineral finish - Ergonomic office chair",
        quantity: 1,
        category: furniture
    )
    chair.brand = "Herman Miller"
    chair.modelNumber = "AER1C23DW"
    chair.purchasePrice = 1395
    chair.purchaseDate = Date().addingTimeInterval(-180 * 24 * 60 * 60) // 6 months ago
    chair.room = "Home Office"
    chair.specificLocation = "Under desk"
    chair.condition = ItemCondition.likeNew.rawValue
    chair.warrantyExpirationDate = Date().addingTimeInterval(11 * 365 * 24 * 60 * 60) // 11 years from now
    chair.warrantyProvider = "Herman Miller"
    chair.notes = "12-year warranty. Purchased for ergonomic health benefits."
    
    // Create KitchenAid Mixer (Warranty expired - good for testing)
    let mixer = Item(
        name: "KitchenAid Stand Mixer",
        itemDescription: "Artisan Series 5-Quart, Empire Red - Professional baking equipment",
        quantity: 1,
        category: kitchen
    )
    mixer.brand = "KitchenAid"
    mixer.modelNumber = "KSM150PSER"
    mixer.serialNumber = "KA240507-2023"
    mixer.purchasePrice = 429
    mixer.purchaseDate = Date().addingTimeInterval(-730 * 24 * 60 * 60) // 2 years ago
    mixer.room = "Kitchen"
    mixer.specificLocation = "Counter next to stove"
    mixer.condition = ItemCondition.good.rawValue
    mixer.warrantyExpirationDate = Date().addingTimeInterval(-365 * 24 * 60 * 60) // Expired 1 year ago
    mixer.warrantyProvider = "KitchenAid"
    mixer.notes = "Used regularly for baking. Minor wear on mixing bowl."
    
    // Create iPhone (Recent purchase with active warranty)
    let iphone = Item(
        name: "iPhone 15 Pro",
        itemDescription: "Natural Titanium, 256GB - Primary mobile device",
        quantity: 1,
        category: electronics
    )
    iphone.brand = "Apple"
    iphone.modelNumber = "A3101"
    iphone.serialNumber = "F2LYX1AFQH"
    iphone.purchasePrice = 1199
    iphone.purchaseDate = Date().addingTimeInterval(-90 * 24 * 60 * 60) // 3 months ago
    iphone.room = "Bedroom"
    iphone.specificLocation = "Nightstand"
    iphone.condition = ItemCondition.excellent.rawValue
    iphone.warrantyExpirationDate = Date().addingTimeInterval(275 * 24 * 60 * 60) // ~9 months from now
    iphone.warrantyProvider = "Apple Inc."
    iphone.notes = "Includes MagSafe case and screen protector. No AppleCare+."
    
    // Create Sony Headphones (Warranty expired)
    let headphones = Item(
        name: "Sony WH-1000XM4 Headphones",
        itemDescription: "Wireless Noise Canceling, Black - Premium audio equipment",
        quantity: 1,
        category: electronics
    )
    headphones.brand = "Sony"
    headphones.modelNumber = "WH-1000XM4"
    headphones.purchasePrice = 348
    headphones.purchaseDate = Date().addingTimeInterval(-420 * 24 * 60 * 60) // ~14 months ago
    headphones.room = "Home Office"
    headphones.specificLocation = "Desk drawer"
    headphones.condition = ItemCondition.good.rawValue
    headphones.warrantyExpirationDate = Date().addingTimeInterval(-55 * 24 * 60 * 60) // Expired ~2 months ago
    headphones.warrantyProvider = "Sony"
    headphones.notes = "Battery life still excellent. Minor scuffs on headband."
    
    return [macbook, chair, mixer, iphone, headphones]
}

private func createMockCategories() -> [Category] {
    return [
        Category(name: "Electronics", icon: "laptopcomputer", colorHex: "#007AFF"),
        Category(name: "Furniture", icon: "chair.lounge", colorHex: "#34C759"),
        Category(name: "Kitchen", icon: "fork.knife", colorHex: "#FF9500"),
        Category(name: "Clothing", icon: "tshirt", colorHex: "#AF52DE"),
        Category(name: "Books", icon: "book", colorHex: "#FF2D92"),
        Category(name: "Sports", icon: "figure.run", colorHex: "#00CED1"),
        Category(name: "Tools", icon: "hammer", colorHex: "#8B4513")
    ]
}

private func createMockRooms() -> [Room] {
    return [
        Room(name: "Home Office", icon: "desktopcomputer"),
        Room(name: "Living Room", icon: "sofa"),
        Room(name: "Kitchen", icon: "fork.knife"),
        Room(name: "Bedroom", icon: "bed.double"),
        Room(name: "Garage", icon: "car"),
        Room(name: "Basement", icon: "stairs"),
        Room(name: "Attic", icon: "house.lodge")
    ]
}

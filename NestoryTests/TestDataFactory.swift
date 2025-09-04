//
// Layer: Tests
// Module: TestData
// Purpose: Centralized test data generation with realistic insurance scenarios
//

import Foundation
@testable import Nestory

/// Comprehensive test data factory for generating realistic insurance documentation scenarios
@MainActor
struct TestDataFactory {
    
    // MARK: - Core Data Generation
    
    /// Generate a basic item with minimal required data
    static func createBasicItem(name: String = "Test Item") -> Item {
        let item = Item(name: name)
        item.itemDescription = "\(name) - Basic test item for unit testing"
        item.purchasePrice = Decimal(100.0)
        item.currentValue = Decimal(100.0)
        return item
    }
    
    /// Generate a complete item with all fields populated for comprehensive testing
    static func createCompleteItem(
        name: String = "MacBook Pro 16-inch",
        category: NestoryCategory? = nil,
        room: Room? = nil
    ) -> Item {
        let item = Item(name: name)
        item.itemDescription = "High-performance laptop for professional work and development"
        item.brand = "Apple"
        item.modelNumber = "MBP16-M3-2024"
        item.serialNumber = "C02ABC123XYZ"
        item.purchasePrice = Decimal(2499.0)
        item.currentValue = Decimal(2200.0)
        item.purchaseDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())
        item.notes = "Primary development machine with extended warranty"
        item.tags = ["electronics", "work", "apple", "laptop"]
        item.condition = "excellent"
        item.isArchived = false
        item.category = category
        item.room = room?.name
        return item
    }
    
    /// Generate a damaged item for insurance claim testing
    static func createDamagedItem(
        name: String = "Water Damaged iPhone",
        damageType: String = "water",
        severity: String = "major"
    ) -> Item {
        let item = Item(name: name)
        item.itemDescription = "iPhone 15 Pro with water damage from kitchen flooding"
        item.brand = "Apple"
        item.modelNumber = "iPhone15,2"
        item.serialNumber = "F2ABC123456"
        item.purchasePrice = Decimal(999.0)
        item.currentValue = Decimal(50.0) // Significantly reduced due to damage
        item.purchaseDate = Calendar.current.date(byAdding: .month, value: -3, to: Date())
        item.condition = "poor" // Reflects damage
        item.notes = "Water damage occurred during kitchen flooding incident on \(Date().formatted(date: .abbreviated, time: .omitted))"
        item.tags = ["damaged", damageType, "insurance-claim", "electronics"]
        return item
    }
    
    /// Generate a high-value item for insurance documentation testing
    static func createHighValueItem(
        name: String = "Rolex Submariner Watch",
        value: Decimal = Decimal(8500.0)
    ) -> Item {
        let item = Item(name: name)
        item.itemDescription = "Luxury Swiss automatic diving watch with ceramic bezel"
        item.brand = "Rolex"
        item.modelNumber = "126610LN"
        item.serialNumber = "R12345678"
        item.purchasePrice = value
        item.currentValue = value * 1.1 // Appreciation for luxury items
        item.purchaseDate = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        item.condition = "excellent"
        item.notes = "Certified pre-owned luxury timepiece with original box and papers"
        item.tags = ["luxury", "jewelry", "high-value", "collectible"]
        return item
    }
    
    // MARK: - Category Generation
    
    static func createCategory(
        name: String = "Electronics",
        icon: String = "tv",
        colorHex: String = "#007AFF"
    ) -> NestoryCategory {
        return NestoryCategory(name: name, icon: icon, colorHex: colorHex)
    }
    
    static func createStandardCategories() -> [NestoryCategory] {
        return [
            NestoryCategory(name: "Electronics", icon: "tv", colorHex: "#007AFF"),
            NestoryCategory(name: "Furniture", icon: "sofa.fill", colorHex: "#8E4EC6"),
            NestoryCategory(name: "Jewelry", icon: "star.fill", colorHex: "#FFD60A"),
            NestoryCategory(name: "Appliances", icon: "washer.fill", colorHex: "#30D158"),
            NestoryCategory(name: "Clothing", icon: "tshirt.fill", colorHex: "#FF6482"),
            NestoryCategory(name: "Documents", icon: "doc.fill", colorHex: "#BF5AF2"),
            NestoryCategory(name: "Art & Collectibles", icon: "paintpalette.fill", colorHex: "#FF9F0A")
        ]
    }
    
    // MARK: - Room Generation
    
    static func createRoom(
        name: String = "Living Room",
        icon: String = "sofa.fill",
        floor: String = "Ground Floor"
    ) -> Room {
        return Room(
            name: name,
            icon: icon,
            roomDescription: "Primary \(name.lowercased()) area",
            floor: floor
        )
    }
    
    static func createStandardRooms() -> [Room] {
        return [
            Room(name: "Living Room", icon: "sofa.fill", floor: "Ground Floor"),
            Room(name: "Kitchen", icon: "fork.knife", floor: "Ground Floor"),
            Room(name: "Master Bedroom", icon: "bed.double.fill", floor: "Upper Floor"),
            Room(name: "Home Office", icon: "desktopcomputer", floor: "Upper Floor"),
            Room(name: "Garage", icon: "car.fill", floor: "Ground Floor"),
            Room(name: "Basement", icon: "house.fill", floor: "Lower Level"),
            Room(name: "Bathroom", icon: "shower.fill", floor: "Upper Floor")
        ]
    }
    
    // MARK: - Insurance Scenario Generation
    
    /// Generate complete insurance claim scenario with multiple damaged items
    static func createInsuranceClaimScenario(
        incidentType: String = "water_damage",
        itemCount: Int = 5
    ) -> (items: [Item], categories: [NestoryCategory], rooms: [Room]) {
        let categories = createStandardCategories()
        let rooms = createStandardRooms()
        
        var items: [Item] = []
        
        switch incidentType {
        case "water_damage":
            items = [
                createDamagedItem(name: "Samsung 65\" 4K TV", damageType: "water", severity: "total-loss"),
                createDamagedItem(name: "MacBook Pro 16-inch", damageType: "water", severity: "major"),
                createDamagedItem(name: "Leather Sectional Sofa", damageType: "water", severity: "major"),
                createDamagedItem(name: "Hardwood Coffee Table", damageType: "water", severity: "minor"),
                createDamagedItem(name: "Persian Rug 9x12", damageType: "water", severity: "major")
            ]
        case "fire_damage":
            items = [
                createDamagedItem(name: "Entire Wardrobe Collection", damageType: "fire", severity: "total-loss"),
                createDamagedItem(name: "Home Theater System", damageType: "fire", severity: "total-loss"),
                createDamagedItem(name: "Kitchen Appliance Set", damageType: "fire", severity: "total-loss"),
                createDamagedItem(name: "Dining Room Set", damageType: "smoke", severity: "major"),
                createDamagedItem(name: "Art Collection", damageType: "smoke", severity: "major")
            ]
        case "theft":
            items = [
                createDamagedItem(name: "MacBook Pro Laptop", damageType: "theft", severity: "total-loss"),
                createDamagedItem(name: "iPad Pro with Accessories", damageType: "theft", severity: "total-loss"),
                createDamagedItem(name: "Sony Camera Equipment", damageType: "theft", severity: "total-loss"),
                createDamagedItem(name: "Jewelry Collection", damageType: "theft", severity: "total-loss"),
                createDamagedItem(name: "Designer Watch Collection", damageType: "theft", severity: "total-loss")
            ]
        default:
            items = Array(1...itemCount).map { i in
                createDamagedItem(name: "Damaged Item \(i)", damageType: incidentType, severity: "major")
            }
        }
        
        // Associate items with appropriate categories and rooms
        for (index, item) in items.enumerated() {
            item.category = categories[index % categories.count]
            item.room = room?.names[index % rooms.count]
        }
        
        return (items: items, categories: categories, rooms: rooms)
    }
    
    // MARK: - Performance Testing Data
    
    /// Generate large dataset for performance testing (1000+ items)
    static func createLargeDataset(itemCount: Int = 1000) -> (items: [Item], categories: [NestoryCategory], rooms: [Room]) {
        let categories = createStandardCategories()
        let rooms = createStandardRooms()
        
        let items = Array(1...itemCount).map { i in
            let item = createCompleteItem(
                name: "Item \(i)",
                category: categories[i % categories.count],
                room: rooms[i % rooms.count]
            )
            // Add variety to the data
            item.purchasePrice = Decimal(Double.random(in: 10...5000))
            item.currentValue = item.purchasePrice * Decimal(Double.random(in: 0.5...1.2))
            item.condition = ["excellent", "good", "fair", "poor"].randomElement() ?? "good"
            return item
        }
        
        return (items: items, categories: categories, rooms: rooms)
    }
    
    /// Generate search test data with specific patterns
    static func createSearchTestData() -> (items: [Item], categories: [NestoryCategory], rooms: [Room]) {
        let categories = createStandardCategories()
        let rooms = createStandardRooms()
        
        let items = [
            // Apple products for brand filtering
            createCompleteItem(name: "MacBook Pro 16-inch M3", category: categories[0], room: rooms[3]),
            createCompleteItem(name: "iPad Pro 12.9-inch", category: categories[0], room: rooms[3]),
            createCompleteItem(name: "iPhone 15 Pro Max", category: categories[0], room: rooms[2]),
            createCompleteItem(name: "Apple Watch Series 9", category: categories[2], room: rooms[2]),
            
            // High-value items for price filtering
            createHighValueItem(name: "Diamond Engagement Ring", value: Decimal(12000)),
            createHighValueItem(name: "Vintage Guitar Collection", value: Decimal(8500)),
            createHighValueItem(name: "Rolex Submariner", value: Decimal(9500)),
            
            // Items with specific tags for tag filtering
            createBasicItem(name: "Test Item with Multiple Tags").apply { item in
                item.tags = ["electronics", "portable", "work", "expensive", "apple"]
                item.brand = "Apple"
                item.purchasePrice = Decimal(1999)
            },
            
            // Items in different conditions for condition filtering
            createBasicItem(name: "Excellent Condition Item").apply { $0.condition = "excellent" },
            createBasicItem(name: "Good Condition Item").apply { $0.condition = "good" },
            createBasicItem(name: "Fair Condition Item").apply { $0.condition = "fair" },
            createBasicItem(name: "Poor Condition Item").apply { $0.condition = "poor" }
        ]
        
        return (items: items, categories: categories, rooms: rooms)
    }
    
    // MARK: - Receipt and Warranty Test Data
    
    static func createReceiptTestData() -> Receipt {
        let receipt = Receipt()
        receipt.id = UUID()
        receipt.merchantName = "Apple Store"
        receipt.total = Decimal(2499.99)
        receipt.taxAmount = Decimal(224.99)
        receipt.purchaseDate = Date()
        receipt.receiptNumber = "APL-2024-001234"
        receipt.paymentMethod = "Credit Card (**** 4567)"
        receipt.items = ["MacBook Pro 16-inch M3: $2,274.00", "AppleCare+: $199.00"]
        receipt.confidence = 0.95
        receipt.rawText = "APPLE STORE\nMacBook Pro 16-inch M3 - $2,274.00\nAppleCare+ - $199.00\nSubtotal: $2,473.00\nTax: $224.99\nTotal: $2,499.99"
        return receipt
    }
    
    static func createWarrantyTestData() -> Warranty {
        let warranty = Warranty()
        warranty.id = UUID()
        warranty.name = "AppleCare+ Protection Plan"
        warranty.provider = "Apple Inc."
        warranty.startDate = Date()
        warranty.endDate = Calendar.current.date(byAdding: .year, value: 3, to: Date()) ?? Date()
        warranty.warrantyCoverage = "Hardware repairs, accidental damage protection"
        warranty.contactInfo = "1-800-APL-CARE"
        warranty.terms = "Covers hardware defects and up to 2 incidents of accidental damage"
        warranty.isActive = true
        return warranty
    }
    
    // MARK: - Mock Services Support
    
    /// Generate realistic delay for network simulation (50-500ms)
    static func simulatedNetworkDelay() async {
        let delayMs = Int.random(in: 50...500)
        try? await Task.sleep(nanoseconds: UInt64(delayMs * 1_000_000))
    }
    
    /// Generate realistic failure scenarios for error testing
    static func shouldSimulateFailure(failureRate: Double = 0.1) -> Bool {
        return Double.random(in: 0...1) < failureRate
    }
}

// MARK: - Helper Extensions

extension Item {
    /// Functional-style property setter for test data chaining
    func apply(_ configuration: (Item) -> Void) -> Item {
        configuration(self)
        return self
    }
}

/// Insurance-specific test scenario types
enum InsuranceTestScenario: String, CaseIterable {
    case waterDamage = "water_damage"
    case fireDamage = "fire_damage"
    case theft = "theft"
    case naturalDisaster = "natural_disaster"
    case vandalism = "vandalism"
    
    var displayName: String {
        switch self {
        case .waterDamage: return "Water Damage"
        case .fireDamage: return "Fire Damage"
        case .theft: return "Theft"
        case .naturalDisaster: return "Natural Disaster"
        case .vandalism: return "Vandalism"
        }
    }
    
    var typicalItemCount: Int {
        switch self {
        case .waterDamage, .fireDamage: return 8
        case .naturalDisaster: return 15
        case .theft: return 5
        case .vandalism: return 3
        }
    }
}
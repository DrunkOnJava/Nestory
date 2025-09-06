//
// Layer: Tests
// Module: TestData
// Purpose: Main test data factory coordinator - delegates to specialized factories
//

import Foundation
@testable import Nestory

/// Main test data factory that provides all test data creation
/// This serves as the primary interface for all test data creation
@MainActor
struct TestDataFactory {
    
    // MARK: - Item Creation
    
    /// Generate a basic item with minimal required data
    static func createBasicItem(name: String = "Test Item") -> Item {
        let item = Item(name: name)
        item.itemDescription = "\(name) - Basic test item for unit testing"
        item.purchasePrice = Decimal(100.0)
        return item
    }
    
    /// Generate a complete item with all fields populated for comprehensive testing
    static func createCompleteItem(
        name: String = "MacBook Pro 16-inch",
        category: Nestory.Category? = nil,
        roomName: String? = nil
    ) -> Item {
        let item = Item(name: name)
        item.itemDescription = "\(name) - Complete test item with all properties set"
        item.purchasePrice = Decimal(Double.random(in: 200...2000))
        item.purchaseDate = Date().addingTimeInterval(-Double.random(in: 86400...31536000))
        item.serialNumber = "TEST\(Int.random(in: 100000...999999))"
        item.brand = ["Apple", "Samsung", "Sony", "Microsoft", "Dell"].randomElement()
        item.modelNumber = "MODEL-\(Int.random(in: 1000...9999))"
        item.condition = ["excellent", "good", "fair", "poor"].randomElement() ?? "good"
        item.category = category
        item.locationName = roomName ?? ["Living Room", "Bedroom", "Kitchen", "Office"].randomElement()
        item.tags = ["test", "sample", "mock"]
        return item
    }
    
    /// Generate a high-value item for insurance documentation testing
    static func createHighValueItem(
        name: String = "Rolex Submariner Watch",
        value: Decimal = Decimal(8500.0)
    ) -> Item {
        let item = Item(name: name)
        item.purchasePrice = value
        item.itemDescription = "\(name) - High-value item for insurance testing"
        item.serialNumber = "HV\(Int.random(in: 100000...999999))"
        item.condition = "excellent"
        item.tags = ["high-value", "insurance", "premium"]
        return item
    }
    
    /// Generate a damaged item for insurance claim testing
    static func createDamagedItem(
        name: String = "Water Damaged iPhone",
        damageType: String = "water",
        severity: String = "major"
    ) -> Item {
        let item = Item(name: name)
        item.itemDescription = "\(name) - Damaged item for insurance claim testing"
        item.purchasePrice = Decimal(Double.random(in: 300...1500))
        item.condition = severity == "total-loss" ? "poor" : ["fair", "good"].randomElement() ?? "fair"
        item.notes = "\(damageType.capitalized) damage - \(severity) severity"
        item.tags = ["damaged", damageType, severity]
        return item
    }
    
    // MARK: - Category Creation
    
    /// Generate a single category with specified properties
    static func createCategory(
        name: String = "Electronics",
        icon: String = "tv",
        colorHex: String = "#007AFF"
    ) -> Nestory.Category {
        return Nestory.Category(name: name, icon: icon, colorHex: colorHex)
    }
    
    /// Generate standard household categories for comprehensive testing
    static func createStandardCategories() -> [Nestory.Category] {
        return [
            Nestory.Category(name: "Electronics", icon: "tv", colorHex: "#007AFF"),
            Nestory.Category(name: "Furniture", icon: "sofa", colorHex: "#34C759"),
            Nestory.Category(name: "Clothing", icon: "tshirt", colorHex: "#FF9500"),
            Nestory.Category(name: "Jewelry", icon: "diamond", colorHex: "#FF2D92"),
            Nestory.Category(name: "Appliances", icon: "refrigerator", colorHex: "#5856D6"),
            Nestory.Category(name: "Books", icon: "book", colorHex: "#AF52DE"),
            Nestory.Category(name: "Sports", icon: "sportscourt", colorHex: "#FF3B30"),
            Nestory.Category(name: "Tools", icon: "wrench", colorHex: "#8E8E93")
        ]
    }
    
    // MARK: - Location Names (replaces Room model)
    
    /// Generate standard location names for testing
    static func createStandardRoomNames() -> [String] {
        return [
            "Living Room", "Kitchen", "Master Bedroom", "Guest Bedroom", "Home Office",
            "Basement", "Garage", "Attic", "Dining Room", "Family Room", "Bathroom",
            "Laundry Room", "Pantry", "Walk-in Closet", "Patio", "Balcony"
        ]
    }
    
    /// Generate standard locations - alias for backward compatibility
    static func createStandardRooms() -> [String] {
        return createStandardRoomNames()
    }
    
    // MARK: - Insurance Scenarios
    
    /// Generate complete insurance claim scenario with multiple damaged items
    static func createInsuranceClaimScenario(
        incidentType: String = "water_damage",
        itemCount: Int = 5
    ) -> [Item] {
        let damageTypes = ["water", "fire", "theft", "storm", "vandalism"]
        let severities = ["minor", "major", "total-loss"]
        
        return (0..<itemCount).map { i in
            let damageType = damageTypes.randomElement() ?? "water"
            let severity = severities.randomElement() ?? "major"
            return createDamagedItem(
                name: "Claim Item \(i + 1)",
                damageType: damageType,
                severity: severity
            )
        }
    }
    
    // MARK: - Performance Testing
    
    /// Generate large dataset for performance testing (1000+ items)
    static func createLargeDataset(itemCount: Int = 1000) -> [Item] {
        let categories = createStandardCategories()
        let locationNames = createStandardRoomNames()
        
        return (0..<itemCount).map { i in
            let item = createCompleteItem(
                name: "Item \(i + 1)",
                category: categories[i % categories.count],
                roomName: locationNames[i % locationNames.count]
            )
            return item
        }
    }
    
    // MARK: - Search Testing
    
    /// Generate search test data with specific patterns
    static func createSearchTestData() -> [Item] {
        let categories = createStandardCategories()
        
        return [
            // Apple products for brand filtering
            createCompleteItem(name: "iPhone 15 Pro", category: categories[0]).apply {
                $0.brand = "Apple"
                $0.tags = ["electronics", "apple", "premium"]
            },
            createCompleteItem(name: "MacBook Pro", category: categories[0]).apply {
                $0.brand = "Apple"
                $0.tags = ["electronics", "apple", "laptop"]
            },
            
            // High-value items for price filtering
            createHighValueItem(name: "Diamond Ring", value: Decimal(12000)),
            createHighValueItem(name: "Vintage Guitar", value: Decimal(8500)),
            createHighValueItem(name: "Rolex Watch", value: Decimal(9500)),
            
            // Items with various conditions
            createCompleteItem(name: "Excellent Item").apply { $0.condition = "excellent" },
            createCompleteItem(name: "Good Item").apply { $0.condition = "good" },
            createCompleteItem(name: "Fair Item").apply { $0.condition = "fair" },
            createCompleteItem(name: "Poor Item").apply { $0.condition = "poor" }
        ]
    }
    
    // MARK: - Receipt and Warranty Testing
    
    /// Generate comprehensive receipt test data for OCR testing
    static func createReceiptTestData() -> Receipt {
        let receipt = Receipt(
            vendor: "Apple Store",
            total: Money(amount: Decimal(1299.99), currencyCode: "USD"),
            purchaseDate: Date()
        )
        receipt.receiptNumber = "R\(Int.random(in: 100000...999999))"
        return receipt
    }
    
    /// Generate comprehensive warranty test data
    static func createWarrantyTestData() -> Warranty {
        return Warranty(
            provider: "AppleCare",
            type: .manufacturer,
            startDate: Date(),
            expiresAt: Date().addingTimeInterval(365 * 24 * 60 * 60) // 1 year
        )
    }
    
    // MARK: - Mock Services
    
    /// Generate realistic delay for network simulation (50-500ms)
    static func simulatedNetworkDelay() async {
        let delay = Double.random(in: 0.05...0.5)
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
    
    /// Generate realistic failure scenarios for error testing
    static func shouldSimulateFailure(failureRate: Double = 0.1) -> Bool {
        return Double.random(in: 0...1) < failureRate
    }
}

// MARK: - Helper Extensions (preserved from original)

extension Item {
    /// Functional-style property setter for test data chaining
    func apply(_ configuration: (Item) -> Void) -> Item {
        configuration(self)
        return self
    }
}

// MARK: - Legacy Support Types

// Note: InsuranceTestScenario is defined in InsuranceTestFactory.swift to avoid duplicate declarations
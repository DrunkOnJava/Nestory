//
// Layer: Tests
// Module: TestFactories
// Purpose: Specialized factory for creating test Item instances
//

import Foundation
@testable import Nestory

/// Specialized factory for creating Item test data with various configurations
@MainActor
struct ItemTestFactory {
    
    // MARK: - Basic Item Creation
    
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
        item.itemDescription = "High-performance laptop for professional work and development"
        item.brand = "Apple"
        item.modelNumber = "MBP16-M3-2024"
        item.serialNumber = "C02ABC123XYZ"
        item.purchasePrice = Decimal(2499.0)
        item.purchaseDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())
        item.notes = "Primary development machine with extended warranty"
        item.tags = ["electronics", "work", "apple", "laptop"]
        item.condition = "excellent"
        item.category = category
        item.locationName = roomName ?? "Home Office"
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
        item.purchaseDate = Calendar.current.date(byAdding: .month, value: -3, to: Date())
        item.condition = "poor" // Reflects damage
        item.notes = "Water damage occurred during kitchen flooding incident on \(Date().formatted(date: .abbreviated, time: .omitted))"
        item.tags = ["damaged", damageType, "insurance-claim", "electronics"]
        item.locationName = "Kitchen"
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
        item.purchaseDate = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        item.condition = "excellent"
        item.notes = "Certified pre-owned luxury timepiece with original box and papers"
        item.tags = ["luxury", "jewelry", "high-value", "collectible"]
        item.locationName = "Master Bedroom"
        return item
    }
    
    // MARK: - Specialized Item Variations
    
    /// Create an item with specific Apple product details
    static func createAppleProduct(
        name: String = "MacBook Pro",
        price: Decimal = Decimal(2499.0)
    ) -> Item {
        let item = createCompleteItem(name: name)
        item.brand = "Apple"
        item.purchasePrice = price
        item.tags = ["electronics", "apple", "work", "portable"]
        return item
    }
    
    /// Create an item with specific condition and location
    static func createItemWithCondition(
        name: String = "Test Item",
        condition: String = "good",
        locationName: String = "Living Room"
    ) -> Item {
        let item = createBasicItem(name: name)
        item.condition = condition
        item.locationName = locationName
        return item
    }
    
    // MARK: - Batch Creation
    
    /// Create multiple items with incremental names
    static func createMultipleItems(
        count: Int,
        namePrefix: String = "Item",
        categoryProvider: (() -> Nestory.Category?)? = nil
    ) -> [Item] {
        return (1...count).map { index in
            let item = createBasicItem(name: "\(namePrefix) \(index)")
            item.category = categoryProvider?()
            item.purchasePrice = Decimal(Double.random(in: 10...1000))
            return item
        }
    }
}

// MARK: - Helper Extensions
// Note: Item.apply extension is defined in TestDataFactory.swift to avoid duplicate declarations
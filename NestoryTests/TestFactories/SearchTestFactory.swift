//
// Layer: Tests
// Module: TestFactories
// Purpose: Specialized factory for search functionality test data
//

import Foundation
@testable import Nestory

/// Specialized factory for creating search-specific test data
@MainActor
struct SearchTestFactory {
    
    // MARK: - Search Test Data
    
    /// Generate search test data with specific patterns
    static func createSearchTestData() -> [Item] {
        let categories = CategoryTestFactory.createStandardCategories()
        
        var items = [
            // Apple products for brand filtering
            createAppleProducts(),
            
            // High-value items for price filtering
            ItemTestFactory.createHighValueItem(name: "Diamond Engagement Ring", value: Decimal(12000)),
            ItemTestFactory.createHighValueItem(name: "Vintage Guitar Collection", value: Decimal(8500)),
            ItemTestFactory.createHighValueItem(name: "Rolex Submariner", value: Decimal(9500)),
            
            // Items with specific tags for tag filtering
            ItemTestFactory.createBasicItem(name: "Test Item with Multiple Tags").apply { item in
                item.tags = ["electronics", "portable", "work", "expensive", "apple"]
                item.brand = "Apple"
                item.purchasePrice = Decimal(1999)
            },
            
            // Items in different conditions for condition filtering
            ItemTestFactory.createItemWithCondition(name: "Excellent Condition Item", condition: "excellent"),
            ItemTestFactory.createItemWithCondition(name: "Good Condition Item", condition: "good"),
            ItemTestFactory.createItemWithCondition(name: "Fair Condition Item", condition: "fair"),
            ItemTestFactory.createItemWithCondition(name: "Poor Condition Item", condition: "poor")
        ].flatMap { $0 is [Item] ? $0 as! [Item] : [$0 as! Item] }
        
        // Associate with categories
        for (index, item) in items.enumerated() {
            if item.category == nil {
                item.category = categories[index % categories.count]
            }
        }
        
        return items
    }
    
    // MARK: - Brand-Specific Test Data
    
    /// Create Apple products for brand search testing
    static func createAppleProducts() -> [Item] {
        return [
            ItemTestFactory.createAppleProduct(name: "MacBook Pro 16-inch", price: Decimal(2499)),
            ItemTestFactory.createAppleProduct(name: "iPhone 15 Pro", price: Decimal(999)),
            ItemTestFactory.createAppleProduct(name: "iPad Pro", price: Decimal(799)),
            ItemTestFactory.createAppleProduct(name: "Apple Watch Ultra", price: Decimal(599)),
            ItemTestFactory.createAppleProduct(name: "AirPods Pro", price: Decimal(249))
        ]
    }
    
    /// Create Samsung products for brand comparison
    static func createSamsungProducts() -> [Item] {
        return [
            createBrandProduct(name: "Samsung Galaxy S24", brand: "Samsung", price: Decimal(899)),
            createBrandProduct(name: "Samsung 65\" QLED TV", brand: "Samsung", price: Decimal(1299)),
            createBrandProduct(name: "Samsung Galaxy Tab", brand: "Samsung", price: Decimal(549))
        ]
    }
    
    // MARK: - Price Range Test Data
    
    /// Create items in specific price ranges for filtering tests
    static func createPriceRangeItems() -> [Item] {
        return [
            createItemInPriceRange(name: "Budget Item 1", price: 25.00, range: .budget),
            createItemInPriceRange(name: "Budget Item 2", price: 75.00, range: .budget),
            createItemInPriceRange(name: "Mid-Range Item 1", price: 250.00, range: .midRange),
            createItemInPriceRange(name: "Mid-Range Item 2", price: 750.00, range: .midRange),
            createItemInPriceRange(name: "Premium Item 1", price: 1500.00, range: .premium),
            createItemInPriceRange(name: "Premium Item 2", price: 3500.00, range: .premium),
            createItemInPriceRange(name: "Luxury Item 1", price: 8000.00, range: .luxury),
            createItemInPriceRange(name: "Luxury Item 2", price: 15000.00, range: .luxury)
        ]
    }
    
    // MARK: - Tag Variation Test Data
    
    /// Create items with various tag combinations
    static func createTagVariationItems() -> [Item] {
        return [
            createItemWithTags(name: "Electronics Bundle", tags: ["electronics", "portable", "work"]),
            createItemWithTags(name: "Gaming Setup", tags: ["gaming", "electronics", "entertainment"]),
            createItemWithTags(name: "Kitchen Essentials", tags: ["kitchen", "appliances", "cooking"]),
            createItemWithTags(name: "Jewelry Collection", tags: ["jewelry", "luxury", "collectible", "gift"]),
            createItemWithTags(name: "Workout Equipment", tags: ["fitness", "health", "sports", "home-gym"]),
            createItemWithTags(name: "Art Supplies", tags: ["art", "creative", "hobby", "tools"]),
            createItemWithTags(name: "Travel Gear", tags: ["travel", "portable", "outdoor", "adventure"])
        ]
    }
    
    // MARK: - Location-Based Test Data
    
    /// Create items distributed across different locations
    static func createLocationDistributedItems() -> [Item] {
        let locations = LocationTestFactory.createStandardLocationNames()
        return locations.map { location in
            let item = ItemTestFactory.createBasicItem(name: "\(location) Item")
            item.locationName = location
            return item
        }
    }
    
    // MARK: - Helper Methods
    
    private static func createBrandProduct(name: String, brand: String, price: Decimal) -> Item {
        let item = ItemTestFactory.createCompleteItem(name: name)
        item.brand = brand
        item.purchasePrice = price
        return item
    }
    
    private static func createItemInPriceRange(name: String, price: Double, range: PriceRange) -> Item {
        let item = ItemTestFactory.createBasicItem(name: name)
        item.purchasePrice = Decimal(price)
        item.tags = [range.rawValue, "price-test"]
        return item
    }
    
    private static func createItemWithTags(name: String, tags: [String]) -> Item {
        let item = ItemTestFactory.createBasicItem(name: name)
        item.tags = tags
        return item
    }
}

// MARK: - Supporting Types

/// Price ranges for search testing
enum PriceRange: String, CaseIterable {
    case budget = "budget"      // $0-100
    case midRange = "mid-range" // $100-1000
    case premium = "premium"    // $1000-5000
    case luxury = "luxury"      // $5000+
    
    var displayName: String {
        switch self {
        case .budget: return "Budget ($0-100)"
        case .midRange: return "Mid-Range ($100-1000)"
        case .premium: return "Premium ($1000-5000)"
        case .luxury: return "Luxury ($5000+)"
        }
    }
}
//
// Layer: Tests
// Module: TestFactories
// Purpose: Specialized factory for performance testing with large datasets
//

import Foundation
@testable import Nestory

/// Specialized factory for creating large datasets for performance testing
@MainActor
struct PerformanceTestFactory {
    
    // MARK: - Large Dataset Generation
    
    /// Generate large dataset for performance testing (1000+ items)
    static func createLargeDataset(itemCount: Int = 1000) -> [Item] {
        let categories = CategoryTestFactory.createStandardCategories()
        let locationNames = LocationTestFactory.createStandardLocationNames()
        
        let items = Array(1...itemCount).map { i in
            let item = ItemTestFactory.createCompleteItem(
                name: "Item \(i)",
                category: categories[i % categories.count],
                roomName: locationNames[i % locationNames.count]
            )
            
            // Add variety to the data
            item.purchasePrice = Decimal(Double.random(in: 10...5000))
            item.condition = ["excellent", "good", "fair", "poor"].randomElement() ?? "good"
            item.brand = performanceTestBrands.randomElement()
            item.tags = generateRandomTags()
            
            // Vary purchase dates across 5 years
            if let randomDate = Calendar.current.date(byAdding: .day, 
                                                    value: -Int.random(in: 0...1825), 
                                                    to: Date()) {
                item.purchaseDate = randomDate
            }
            
            return item
        }
        
        return items
    }
    
    /// Generate memory-efficient batch of items
    static func createBatchItems(
        batchSize: Int = 100,
        batchIndex: Int = 0,
        totalCount: Int = 1000
    ) -> [Item] {
        let categories = CategoryTestFactory.createStandardCategories()
        let startIndex = batchIndex * batchSize
        let endIndex = min(startIndex + batchSize, totalCount)
        
        return Array(startIndex..<endIndex).map { i in
            let item = ItemTestFactory.createBasicItem(name: "Batch Item \(i)")
            item.category = categories[i % categories.count]
            item.purchasePrice = Decimal(Double.random(in: 10...1000))
            return item
        }
    }
    
    // MARK: - Stress Testing Data
    
    /// Generate data specifically for UI stress testing
    static func createUIStressTestData() -> [Item] {
        let items = Array(1...500).map { i in
            let item = ItemTestFactory.createCompleteItem(name: "UI Stress Item \(i)")
            
            // Create challenging UI scenarios
            item.itemDescription = String(repeating: "This is a very long description that will test text wrapping and layout performance. ", count: 10)
            item.notes = String(repeating: "Extended notes field with lots of text for performance testing. ", count: 5)
            item.tags = Array(repeating: "tag\(i)", count: 20) // Many tags
            
            return item
        }
        
        return items
    }
    
    /// Generate data for search performance testing
    static func createSearchPerformanceData() -> [Item] {
        let searchTerms = ["Apple", "Samsung", "Sony", "Dell", "HP", "Canon", "Nikon", "Nike", "Adidas", "Rolex"]
        
        return Array(1...2000).map { i in
            let item = ItemTestFactory.createBasicItem(name: "Search Item \(i)")
            item.brand = searchTerms[i % searchTerms.count]
            item.tags = [searchTerms.randomElement() ?? "test", "performance", "search"]
            item.itemDescription = "Performance test item containing \(searchTerms.randomElement() ?? "search") terms for indexing"
            return item
        }
    }
    
    // MARK: - Memory Testing
    
    /// Generate items with large memory footprints for memory testing
    static func createMemoryTestItems(count: Int = 50) -> [Item] {
        return Array(1...count).map { i in
            let item = ItemTestFactory.createCompleteItem(name: "Memory Test Item \(i)")
            
            // Large text fields to test memory usage
            item.itemDescription = String(repeating: "Large memory footprint description. ", count: 100)
            item.notes = String(repeating: "Extensive notes for memory testing purposes. ", count: 150)
            
            // Many tags for memory stress testing
            item.tags = Array(1...50).map { "memoryTag\($0)" }
            
            return item
        }
    }
    
    // MARK: - Helper Data
    
    /// Common brands for performance testing variety
    private static let performanceTestBrands = [
        "Apple", "Samsung", "Sony", "Dell", "HP", "Canon", "Nikon", "Microsoft", "Google", "Amazon",
        "Nike", "Adidas", "Under Armour", "Levi's", "Gap", "H&M", "Zara", "Target", "Walmart",
        "Rolex", "Omega", "Tag Heuer", "Seiko", "Casio", "Timex", "Fossil", "Citizen",
        "BMW", "Mercedes", "Audi", "Toyota", "Honda", "Ford", "Chevrolet", "Nissan"
    ]
    
    /// Generate random tags for variety
    private static func generateRandomTags() -> [String] {
        let allTags = [
            "electronics", "furniture", "clothing", "jewelry", "appliances", "tools", "books", "toys",
            "sports", "musical", "automotive", "garden", "kitchen", "bedroom", "office", "vintage",
            "luxury", "collectible", "antique", "modern", "handmade", "imported", "domestic", "rare"
        ]
        
        let tagCount = Int.random(in: 1...8)
        return Array(allTags.shuffled().prefix(tagCount))
    }
}

// MARK: - Location Factory Helper

/// Helper factory for location names (replacing Room model)
struct LocationTestFactory {
    static func createStandardLocationNames() -> [String] {
        return [
            "Living Room", "Kitchen", "Master Bedroom", "Guest Bedroom", "Home Office",
            "Basement", "Garage", "Attic", "Dining Room", "Family Room", "Bathroom",
            "Laundry Room", "Pantry", "Walk-in Closet", "Patio", "Balcony"
        ]
    }
}
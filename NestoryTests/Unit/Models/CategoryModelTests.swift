//
// Layer: Unit/Models
// Module: CategoryModelTests
// Purpose: Comprehensive tests for Category model, hierarchy, and item relationships
//

import XCTest
import SwiftData
@testable import Nestory

/// Comprehensive test suite for Category model covering initialization, relationships, and data integrity
final class CategoryModelTests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    private var modelContext: ModelContext!
    private var container: ModelContainer!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory model context for testing
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Item.self, Category.self, Warranty.self, Receipt.self, configurations: configuration)
        modelContext = ModelContext(container)
    }
    
    override func tearDown() async throws {
        modelContext = nil
        container = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testBasicInitialization() {
        let category = Nestory.Category(name: "Electronics")
        
        // Test required properties
        XCTAssertEqual(category.name, "Electronics")
        XCTAssertNotNil(category.id)
        XCTAssertNotNil(category.createdAt)
        XCTAssertNotNil(category.updatedAt)
        
        // Test default values
        XCTAssertEqual(category.icon, "folder.fill")
        XCTAssertEqual(category.colorHex, "#007AFF")
        XCTAssertEqual(category.itemCount, 0)
        XCTAssertTrue(category.items?.isEmpty == true)
    }
    
    func testFullInitialization() {
        let category = Nestory.Category(
            name: "Home & Garden",
            icon: "house.fill",
            colorHex: "#34C759"
        )
        
        XCTAssertEqual(category.name, "Home & Garden")
        XCTAssertEqual(category.icon, "house.fill")
        XCTAssertEqual(category.colorHex, "#34C759")
        XCTAssertEqual(category.itemCount, 0)
    }
    
    func testUniqueIdentifiers() {
        let category1 = Nestory.Category(name: "Category 1")
        let category2 = Nestory.Category(name: "Category 2")
        
        XCTAssertNotEqual(category1.id, category2.id)
    }
    
    // MARK: - Property Tests
    
    func testNameProperty() {
        let category = Nestory.Category(name: "Books")
        
        XCTAssertEqual(category.name, "Books")
        
        // Test name modification
        category.name = "Books & Magazines"
        XCTAssertEqual(category.name, "Books & Magazines")
        
        // Test empty name
        category.name = ""
        XCTAssertEqual(category.name, "")
    }
    
    func testIconProperty() {
        let category = Nestory.Category(name: "Music")
        
        // Test default icon
        XCTAssertEqual(category.icon, "folder.fill")
        
        // Test custom icons
        let musicIcons = ["music.note", "headphones", "speaker.3.fill", "radio"]
        for icon in musicIcons {
            category.icon = icon
            XCTAssertEqual(category.icon, icon)
        }
    }
    
    func testColorProperty() {
        let category = Nestory.Category(name: "Art")
        
        // Test default color (iOS blue)
        XCTAssertEqual(category.colorHex, "#007AFF")
        
        // Test various color formats
        let colors = ["#FF0000", "#00FF00", "#0000FF", "#FFFFFF", "#000000", "#34C759"]
        for color in colors {
            category.colorHex = color
            XCTAssertEqual(category.colorHex, color)
        }
    }
    
    func testItemCountProperty() {
        let category = Nestory.Category(name: "Sports")
        
        // Test initial count
        XCTAssertEqual(category.itemCount, 0)
        
        // Test count modification
        category.itemCount = 5
        XCTAssertEqual(category.itemCount, 5)
        
        category.itemCount = 100
        XCTAssertEqual(category.itemCount, 100)
    }
    
    // MARK: - Relationship Tests
    
    func testItemRelationship() throws {
        let category = Nestory.Category(name: "Technology")
        let item1 = Item(name: "iPhone", category: category)
        let item2 = Item(name: "iPad", category: category)
        
        // Insert into context
        modelContext.insert(category)
        modelContext.insert(item1)
        modelContext.insert(item2)
        
        try modelContext.save()
        
        // Test relationship
        XCTAssertEqual(category.items?.count, 2)
        XCTAssertEqual(item1.category?.name, "Technology")
        XCTAssertEqual(item2.category?.name, "Technology")
        
        // Test category contains both items
        let itemNames = category.items?.map { $0.name }.sorted()
        XCTAssertEqual(itemNames, ["iPad", "iPhone"])
    }
    
    func testEmptyItemRelationship() {
        let category = Nestory.Category(name: "Empty Category")
        
        XCTAssertTrue(category.items?.isEmpty == true)
        XCTAssertEqual(category.itemCount, 0)
    }
    
    func testNullifyOnCategoryDeletion() throws {
        let category = Nestory.Category(name: "Temporary")
        let item = Item(name: "Test Item", category: category)
        
        modelContext.insert(category)
        modelContext.insert(item)
        try modelContext.save()
        
        // Verify relationship exists
        XCTAssertEqual(item.category?.name, "Temporary")
        
        // Delete category
        modelContext.delete(category)
        try modelContext.save()
        
        // Item should still exist but category should be nil (nullify rule)
        XCTAssertNil(item.category)
    }
    
    // MARK: - Insurance Category Tests
    
    func testInsuranceRelevantCategories() {
        // Test categories commonly used for insurance documentation
        let insuranceCategories = [
            ("Jewelry", "diamond.fill", "#FFD700"),
            ("Electronics", "laptopcomputer", "#007AFF"),
            ("Furniture", "chair.lounge.fill", "#8B4513"),
            ("Appliances", "refrigerator.fill", "#C0C0C0"),
            ("Art & Collectibles", "paintbrush.pointed.fill", "#800080"),
            ("Musical Instruments", "music.note", "#FF6347"),
            ("Sports Equipment", "sportscourt.fill", "#32CD32"),
            ("Tools & Equipment", "wrench.and.screwdriver.fill", "#696969")
        ]
        
        for (name, icon, color) in insuranceCategories {
            let category = Nestory.Category(name: name, icon: icon, colorHex: color)
            
            XCTAssertEqual(category.name, name)
            XCTAssertEqual(category.icon, icon)
            XCTAssertEqual(category.colorHex, color)
            XCTAssertFalse(category.name.isEmpty, "Insurance categories should have descriptive names")
        }
    }
    
    @MainActor
    func testHighValueItemCategories() throws {
        let jewelryCategory = Nestory.Category(name: "Jewelry & Watches", icon: "diamond.fill", colorHex: "#FFD700")
        
        // Create high-value items
        let watch = TestDataFactory.createHighValueItem()
        watch.name = "Rolex Submariner"
        watch.category = jewelryCategory
        
        let ring = TestDataFactory.createHighValueItem()
        ring.name = "Diamond Engagement Ring"
        ring.category = jewelryCategory
        
        modelContext.insert(jewelryCategory)
        modelContext.insert(watch)
        modelContext.insert(ring)
        try modelContext.save()
        
        // Verify high-value items are properly categorized
        XCTAssertEqual(jewelryCategory.items?.count, 2)
        
        // All items in jewelry category should have high purchase prices
        for item in jewelryCategory.items ?? [] {
            XCTAssertNotNil(item.purchasePrice, "High-value items should have purchase price documented")
            if let price = item.purchasePrice {
                XCTAssertGreaterThan(price, 1000, "High-value category items should have significant value")
            }
        }
    }
    
    // MARK: - Category Hierarchy Tests
    
    func testCategoryNaming() {
        let categories = [
            "Electronics",
            "Home & Garden",
            "Clothing & Accessories",
            "Books & Media",
            "Sports & Outdoors",
            "Health & Beauty",
            "Automotive",
            "Office Supplies"
        ]
        
        for categoryName in categories {
            let category = Nestory.Category(name: categoryName)
            XCTAssertEqual(category.name, categoryName)
            XCTAssertFalse(category.name.isEmpty)
            XCTAssertTrue(category.name.count > 2, "Category names should be descriptive")
        }
    }
    
    func testCategoryIconConsistency() {
        // Test that common category types have appropriate icons
        let categoryIconPairs = [
            ("Electronics", "laptopcomputer"),
            ("Books", "book.fill"),
            ("Music", "music.note"),
            ("Photos", "photo.fill"),
            ("Documents", "doc.fill"),
            ("Home", "house.fill"),
            ("Sports", "sportscourt.fill"),
            ("Travel", "airplane"),
            ("Food & Dining", "fork.knife"),
            ("Health", "heart.fill")
        ]
        
        for (name, icon) in categoryIconPairs {
            let category = Nestory.Category(name: name, icon: icon)
            XCTAssertEqual(category.icon, icon)
            XCTAssertFalse(category.icon.isEmpty)
        }
    }
    
    // MARK: - Data Integrity Tests
    
    func testTimestampUpdates() {
        let category = Nestory.Category(name: "Timestamp Test")
        let originalCreated = category.createdAt
        let originalUpdated = category.updatedAt
        
        // Simulate time passing
        Thread.sleep(forTimeInterval: 0.001)
        
        // Update category
        category.updatedAt = Date()
        
        XCTAssertEqual(category.createdAt, originalCreated) // Created should not change
        XCTAssertGreaterThan(category.updatedAt, originalUpdated) // Updated should be newer
    }
    
    func testDefaultValues() {
        let category = Nestory.Category(name: "Default Test")
        
        // Test all default values
        XCTAssertEqual(category.icon, "folder.fill")
        XCTAssertEqual(category.colorHex, "#007AFF")
        XCTAssertEqual(category.itemCount, 0)
        XCTAssertTrue(category.items?.isEmpty == true)
    }
    
    func testItemCountConsistency() throws {
        let category = Nestory.Category(name: "Count Test")
        
        modelContext.insert(category)
        try modelContext.save()
        
        // Initially empty
        XCTAssertEqual(category.items?.count, 0)
        
        // Add items
        let item1 = Item(name: "Item 1", category: category)
        let item2 = Item(name: "Item 2", category: category)
        let item3 = Item(name: "Item 3", category: category)
        
        modelContext.insert(item1)
        modelContext.insert(item2)
        modelContext.insert(item3)
        try modelContext.save()
        
        // Verify relationship count
        XCTAssertEqual(category.items?.count, 3)
        
        // Note: itemCount property is manually managed, not automatically synced
        // In real app, services would update this when items are added/removed
    }
    
    // MARK: - Performance Tests
    
    func testCategoryCreationPerformance() {
        measure {
            for i in 0..<1000 {
                let category = Nestory.Category(
                    name: "Category \(i)",
                    icon: "folder.fill",
                    colorHex: "#007AFF"
                )
                _ = category.id // Force lazy initialization
            }
        }
    }
    
    func testCategoryWithManyItemsPerformance() throws {
        let category = Nestory.Category(name: "Performance Test")
        modelContext.insert(category)
        
        // Create many items
        let items = (0..<100).map { i in
            Item(name: "Item \(i)", category: category)
        }
        
        measure {
            for item in items {
                modelContext.insert(item)
            }
        }
        
        try modelContext.save()
        XCTAssertEqual(category.items?.count, 100)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyStringProperties() {
        let category = Nestory.Category(name: "")
        
        XCTAssertEqual(category.name, "")
        
        category.icon = ""
        category.colorHex = ""
        
        XCTAssertEqual(category.icon, "")
        XCTAssertEqual(category.colorHex, "")
    }
    
    func testVeryLongCategoryName() {
        let longName = String(repeating: "A", count: 1000)
        let category = Nestory.Category(name: longName)
        
        XCTAssertEqual(category.name.count, 1000)
        XCTAssertEqual(category.name, longName)
    }
    
    func testSpecialCharactersInName() {
        let specialNames = [
            "Electronics & Gadgets",
            "Books/Magazines",
            "Home-Office",
            "Art & Crafts (Hobby)",
            "Café & Restaurant",
            "Naïve & Résumé",
            "Test@Category#1",
            "Category with emoji 📱"
        ]
        
        for name in specialNames {
            let category = Nestory.Category(name: name)
            XCTAssertEqual(category.name, name)
        }
    }
    
    func testInvalidColorValues() {
        let category = Nestory.Category(name: "Color Test")
        let invalidColors = ["invalid", "red", "blue", "123456", "rgb(255,0,0)", "hsl(0,100%,50%)"]
        
        for color in invalidColors {
            category.colorHex = color
            XCTAssertEqual(category.colorHex, color) // Should accept any string
        }
    }
    
    func testNegativeItemCount() {
        let category = Nestory.Category(name: "Negative Test")
        
        category.itemCount = -5
        XCTAssertEqual(category.itemCount, -5) // Should accept negative values
        
        category.itemCount = 0
        XCTAssertEqual(category.itemCount, 0)
    }
    
    // MARK: - Real-world Category Scenarios
    
    func testHomeInventoryCategories() throws {
        // Test a realistic home inventory categorization system
        let homeCategories = [
            Nestory.Category(name: "Kitchen Appliances", icon: "refrigerator.fill", colorHex: "#FF6B6B"),
            Nestory.Category(name: "Living Room", icon: "sofa.fill", colorHex: "#4ECDC4"),
            Nestory.Category(name: "Bedroom Furniture", icon: "bed.double.fill", colorHex: "#45B7D1"),
            Nestory.Category(name: "Electronics", icon: "tv.fill", colorHex: "#96CEB4"),
            Nestory.Category(name: "Clothing", icon: "tshirt.fill", colorHex: "#FFEAA7"),
            Nestory.Category(name: "Jewelry", icon: "diamond.fill", colorHex: "#DDA0DD"),
            Nestory.Category(name: "Tools", icon: "hammer.fill", colorHex: "#98D8C8"),
            Nestory.Category(name: "Garden", icon: "leaf.fill", colorHex: "#82CD47")
        ]
        
        for category in homeCategories {
            modelContext.insert(category)
            XCTAssertFalse(category.name.isEmpty)
            XCTAssertFalse(category.icon.isEmpty)
            XCTAssertTrue(category.colorHex.hasPrefix("#"))
        }
        
        try modelContext.save()
        
        // Verify all categories were saved
        let savedCategories = try modelContext.fetch(FetchDescriptor<Nestory.Category>())
        XCTAssertEqual(savedCategories.count, homeCategories.count)
    }
    
    func testCategoryWithItemsIntegration() throws {
        let electronicsCategory = Nestory.Category(name: "Electronics", icon: "laptopcomputer", colorHex: "#007AFF")
        
        // Add various electronic items
        let items = [
            Item(name: "MacBook Pro", itemDescription: "15-inch laptop", category: electronicsCategory),
            Item(name: "iPhone 15", itemDescription: "Smartphone", category: electronicsCategory),
            Item(name: "AirPods Pro", itemDescription: "Wireless earbuds", category: electronicsCategory),
            Item(name: "Apple Watch", itemDescription: "Smartwatch", category: electronicsCategory)
        ]
        
        modelContext.insert(electronicsCategory)
        for item in items {
            modelContext.insert(item)
        }
        
        try modelContext.save()
        
        // Verify relationships
        XCTAssertEqual(electronicsCategory.items?.count, 4)
        
        for item in items {
            XCTAssertEqual(item.category?.name, "Electronics")
            XCTAssertEqual(item.category?.icon, "laptopcomputer")
        }
        
        // Test that all items are Apple products (common insurance scenario)
        let itemNames = electronicsCategory.items?.map { $0.name } ?? []
        XCTAssertTrue(itemNames.allSatisfy { $0.contains("Mac") || $0.contains("iPhone") || $0.contains("AirPods") || $0.contains("Apple") })
    }
    
    func testCategoryForInsuranceReporting() {
        // Test categories optimized for insurance claim documentation
        let insuranceOptimizedCategory = Nestory.Category(
            name: "High-Value Electronics",
            icon: "crown.fill",
            colorHex: "#FFD700"
        )
        
        // Properties that matter for insurance
        XCTAssertTrue(insuranceOptimizedCategory.name.contains("High-Value"), "Insurance categories should indicate value level")
        XCTAssertEqual(insuranceOptimizedCategory.colorHex, "#FFD700", "High-value categories should use distinctive colors")
        XCTAssertEqual(insuranceOptimizedCategory.icon, "crown.fill", "High-value categories should use premium icons")
    }
}
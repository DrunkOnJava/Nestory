//
// Layer: Tests
// Module: TestFactories
// Purpose: Specialized factory for creating test Category instances
//

import Foundation
@testable import Nestory

/// Specialized factory for creating Category test data
@MainActor
struct CategoryTestFactory {
    
    // MARK: - Single Category Creation
    
    /// Generate a single category with specified properties
    static func createCategory(
        name: String = "Electronics",
        icon: String = "tv",
        colorHex: String = "#007AFF"
    ) -> Nestory.Category {
        return Nestory.Category(name: name, icon: icon, colorHex: colorHex)
    }
    
    // MARK: - Standard Category Sets
    
    /// Generate standard household categories for comprehensive testing
    static func createStandardCategories() -> [Nestory.Category] {
        return [
            Nestory.Category(name: "Electronics", icon: "tv", colorHex: "#007AFF"),
            Nestory.Category(name: "Furniture", icon: "sofa.fill", colorHex: "#8E4EC6"),
            Nestory.Category(name: "Jewelry", icon: "star.fill", colorHex: "#FFD60A"),
            Nestory.Category(name: "Appliances", icon: "washer.fill", colorHex: "#30D158"),
            Nestory.Category(name: "Clothing", icon: "tshirt.fill", colorHex: "#FF6482"),
            Nestory.Category(name: "Documents", icon: "doc.fill", colorHex: "#BF5AF2"),
            Nestory.Category(name: "Art & Collectibles", icon: "paintpalette.fill", colorHex: "#FF9F0A")
        ]
    }
    
    /// Generate minimal category set for basic testing
    static func createBasicCategories() -> [Nestory.Category] {
        return [
            createCategory(name: "Electronics", icon: "tv", colorHex: "#007AFF"),
            createCategory(name: "Furniture", icon: "sofa.fill", colorHex: "#8E4EC6"),
            createCategory(name: "Personal", icon: "person.fill", colorHex: "#FF6482")
        ]
    }
    
    // MARK: - Specialized Categories
    
    /// Generate electronics-focused categories
    static func createElectronicsCategories() -> [Nestory.Category] {
        return [
            createCategory(name: "Computers", icon: "laptopcomputer", colorHex: "#007AFF"),
            createCategory(name: "Mobile Devices", icon: "iphone", colorHex: "#34C759"),
            createCategory(name: "Audio Equipment", icon: "speaker.2.fill", colorHex: "#FF9500"),
            createCategory(name: "Gaming", icon: "gamecontroller.fill", colorHex: "#5856D6")
        ]
    }
    
    /// Generate luxury/high-value categories
    static func createLuxuryCategories() -> [Nestory.Category] {
        return [
            createCategory(name: "Jewelry & Watches", icon: "star.fill", colorHex: "#FFD60A"),
            createCategory(name: "Art & Antiques", icon: "paintpalette.fill", colorHex: "#FF9F0A"),
            createCategory(name: "Collectibles", icon: "trophy.fill", colorHex: "#8E4EC6"),
            createCategory(name: "Luxury Items", icon: "crown.fill", colorHex: "#AF52DE")
        ]
    }
    
    // MARK: - Category Constants for Testing
    
    /// Common category names used across tests
    enum TestCategoryNames {
        static let electronics = "Electronics"
        static let furniture = "Furniture"
        static let jewelry = "Jewelry"
        static let appliances = "Appliances"
        static let clothing = "Clothing"
        static let documents = "Documents"
        static let artCollectibles = "Art & Collectibles"
    }
    
    /// Common category icons used across tests
    enum TestCategoryIcons {
        static let electronics = "tv"
        static let furniture = "sofa.fill"
        static let jewelry = "star.fill"
        static let appliances = "washer.fill"
        static let clothing = "tshirt.fill"
        static let documents = "doc.fill"
        static let art = "paintpalette.fill"
    }
    
    /// Common category colors used across tests
    enum TestCategoryColors {
        static let blue = "#007AFF"
        static let purple = "#8E4EC6"
        static let yellow = "#FFD60A"
        static let green = "#30D158"
        static let pink = "#FF6482"
        static let violet = "#BF5AF2"
        static let orange = "#FF9F0A"
    }
}

// MARK: - Helper Extensions

extension Array where Element == Nestory.Category {
    /// Get a category by name for test assertions
    func category(named name: String) -> Nestory.Category? {
        return first { $0.name == name }
    }
    
    /// Get random category for test data variation
    func randomCategory() -> Nestory.Category? {
        return randomElement()
    }
}
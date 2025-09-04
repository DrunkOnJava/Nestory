//
// Layer: Tests
// Module: Integration
// Purpose: Insurance-specific test scenarios for comprehensive workflow testing
//

import Foundation
@testable import Nestory

/// Specialized insurance test scenarios that mirror real-world insurance documentation needs
@MainActor
struct InsuranceTestScenarios {
    
    // MARK: - Real-World Insurance Claim Scenarios
    
    /// Complete water damage scenario from kitchen flooding
    static func kitchenFloodingIncident() -> InsuranceTestScenarioData {
        let rooms = TestDataFactory.createStandardRooms()
        let categories = TestDataFactory.createStandardCategories()
        
        let kitchen = rooms.first { $0.name == "Kitchen" }!
        let livingRoom = rooms.first { $0.name == "Living Room" }!
        
        let electronicsCategory = categories.first { $0.name == "Electronics" }!
        let appliancesCategory = categories.first { $0.name == "Appliances" }!
        let furnitureCategory = categories.first { $0.name == "Furniture" }!
        
        let items = [
            // Kitchen appliances - total loss
            TestDataFactory.createDamagedItem(
                name: "KitchenAid Stand Mixer",
                damageType: "water",
                severity: "total-loss"
            ).apply { item in
                item.brand = "KitchenAid"
                item.modelNumber = "KSM150PSER"
                item.purchasePrice = Decimal(399.99)
                item.currentValue = Decimal(0) // Total loss
                item.category = appliancesCategory
                item.room = kitchen.name
                item.notes = "Submerged in 3 inches of water for 6+ hours"
            },
            
            // Electronics - water damage
            TestDataFactory.createDamagedItem(
                name: "Samsung 50\" Smart TV",
                damageType: "water",
                severity: "total-loss"
            ).apply { item in
                item.brand = "Samsung"
                item.modelNumber = "UN50TU8000"
                item.purchasePrice = Decimal(649.99)
                item.currentValue = Decimal(0)
                item.category = electronicsCategory
                item.room = livingRoom.name
                item.serialNumber = "SAM123456789"
            },
            
            // Furniture - major damage
            TestDataFactory.createDamagedItem(
                name: "Hardwood Dining Table",
                damageType: "water",
                severity: "major"
            ).apply { item in
                item.brand = "West Elm"
                item.purchasePrice = Decimal(1299.00)
                item.currentValue = Decimal(200.00) // Warped beyond repair
                item.category = furnitureCategory
                item.room = kitchen.name
                item.condition = "poor"
                item.notes = "Solid oak table warped and finish damaged"
            }
        ]
        
        return InsuranceTestScenarioData(
            title: "Kitchen Flooding Incident",
            description: "Dishwasher malfunction caused 3 inches of standing water",
            incidentDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            claimAmount: items.reduce(Decimal.zero) { $0 + $1.purchasePrice },
            items: items,
            categories: categories,
            rooms: rooms,
            incidentType: .waterDamage,
            severity: .major
        )
    }
    
    /// House fire scenario with smoke and fire damage
    static func houseFire() -> InsuranceTestScenarioData {
        let rooms = TestDataFactory.createStandardRooms()
        let categories = TestDataFactory.createStandardCategories()
        
        let bedroom = rooms.first { $0.name == "Master Bedroom" }!
        let livingRoom = rooms.first { $0.name == "Living Room" }!
        let office = rooms.first { $0.name == "Home Office" }!
        
        let clothingCategory = categories.first { $0.name == "Clothing" }!
        let electronicsCategory = categories.first { $0.name == "Electronics" }!
        let furnitureCategory = categories.first { $0.name == "Furniture" }!
        
        let items = [
            // Complete wardrobe loss
            TestDataFactory.createDamagedItem(
                name: "Master Bedroom Wardrobe",
                damageType: "fire",
                severity: "total-loss"
            ).apply { item in
                item.purchasePrice = Decimal(8500.00) // Entire wardrobe estimated value
                item.currentValue = Decimal(0)
                item.category = clothingCategory
                item.room = bedroom.name
                item.itemDescription = "Complete wardrobe including suits, dresses, casual wear, and shoes"
                item.notes = "Total loss due to direct fire damage and smoke"
            },
            
            // Home office equipment
            TestDataFactory.createDamagedItem(
                name: "Home Office Setup",
                damageType: "fire",
                severity: "total-loss"
            ).apply { item in
                item.purchasePrice = Decimal(4500.00)
                item.currentValue = Decimal(0)
                item.category = electronicsCategory
                item.room = office.name
                item.itemDescription = "Complete home office: MacBook Pro, monitor, printer, desk accessories"
                item.notes = "Fire originated near electrical outlet in office"
            },
            
            // Smoke damage in living room
            TestDataFactory.createDamagedItem(
                name: "Living Room Furniture Set",
                damageType: "smoke",
                severity: "major"
            ).apply { item in
                item.purchasePrice = Decimal(3200.00)
                item.currentValue = Decimal(800.00) // Salvageable but needs professional cleaning
                item.category = furnitureCategory
                item.room = livingRoom.name
                item.condition = "fair"
                item.notes = "Heavy smoke damage, requires professional restoration"
            }
        ]
        
        return InsuranceTestScenarioData(
            title: "Residential Fire Damage",
            description: "Electrical fire in home office spread to adjacent rooms",
            incidentDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            claimAmount: items.reduce(Decimal.zero) { $0 + $1.purchasePrice },
            items: items,
            categories: categories,
            rooms: rooms,
            incidentType: .fireDamage,
            severity: .catastrophic
        )
    }
    
    /// Theft scenario - selective high-value items
    static func selectiveTheft() -> InsuranceTestScenarioData {
        let rooms = TestDataFactory.createStandardRooms()
        let categories = TestDataFactory.createStandardCategories()
        
        let bedroom = rooms.first { $0.name == "Master Bedroom" }!
        let office = rooms.first { $0.name == "Home Office" }!
        
        let electronicsCategory = categories.first { $0.name == "Electronics" }!
        let jewelryCategory = categories.first { $0.name == "Jewelry" }!
        
        let items = [
            // High-value electronics
            TestDataFactory.createDamagedItem(
                name: "MacBook Pro 16-inch M3 Max",
                damageType: "theft",
                severity: "total-loss"
            ).apply { item in
                item.brand = "Apple"
                item.modelNumber = "MBP16-M3MAX-2024"
                item.serialNumber = "C02XYZ123ABC"
                item.purchasePrice = Decimal(4299.00)
                item.currentValue = Decimal(3800.00)
                item.category = electronicsCategory
                item.room = office.name
                item.notes = "Stolen during targeted burglary - serial number reported to police"
            },
            
            // Jewelry collection
            TestDataFactory.createHighValueItem(
                name: "Diamond Jewelry Collection",
                value: Decimal(15000.00)
            ).apply { item in
                item.itemDescription = "Wedding ring set, diamond earrings, tennis bracelet"
                item.category = jewelryCategory
                item.room = bedroom.name
                item.notes = "Stolen from bedroom jewelry box - appraisal documents available"
                item.tags = ["stolen", "high-value", "jewelry", "certified"]
            },
            
            // Camera equipment
            TestDataFactory.createDamagedItem(
                name: "Canon EOS R5 Camera Kit",
                damageType: "theft",
                severity: "total-loss"
            ).apply { item in
                item.brand = "Canon"
                item.modelNumber = "EOS-R5-KIT"
                item.purchasePrice = Decimal(6499.00)
                item.currentValue = Decimal(5800.00)
                item.category = electronicsCategory
                item.room = office.name
                item.itemDescription = "Professional camera body with 24-70mm and 70-200mm lenses"
                item.notes = "Complete photography kit stolen - all serial numbers documented"
            }
        ]
        
        return InsuranceTestScenarioData(
            title: "Targeted Burglary",
            description: "Selective theft of high-value electronics and jewelry",
            incidentDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            claimAmount: items.reduce(Decimal.zero) { $0 + $1.currentValue },
            items: items,
            categories: categories,
            rooms: rooms,
            incidentType: .theft,
            severity: .major
        )
    }
    
    /// Natural disaster - tornado damage
    static func tornadoDamage() -> InsuranceTestScenarioData {
        let rooms = TestDataFactory.createStandardRooms()
        let categories = TestDataFactory.createStandardCategories()
        
        let items = TestDataFactory.createLargeDataset(itemCount: 25).items.map { item in
            // Convert to damaged items
            item.condition = ["poor", "fair"].randomElement() ?? "poor"
            item.currentValue = item.purchasePrice * Decimal(Double.random(in: 0.0...0.3)) // 0-30% of original value
            item.notes = "Tornado damage: \(["structural damage", "water exposure", "debris impact", "wind damage"].randomElement() ?? "tornado damage")"
            item.tags.append(contentsOf: ["tornado", "natural-disaster", "total-loss"])
            return item
        }
        
        return InsuranceTestScenarioData(
            title: "F3 Tornado Damage",
            description: "Direct tornado strike causing widespread property damage",
            incidentDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
            claimAmount: items.reduce(Decimal.zero) { $0 + $1.purchasePrice },
            items: items,
            categories: categories,
            rooms: rooms,
            incidentType: .naturalDisaster,
            severity: .catastrophic
        )
    }
    
    // MARK: - Receipt and Documentation Scenarios
    
    /// High-value purchase with complete documentation
    static func luxuryPurchaseWithReceipts() -> InsuranceTestScenarioData {
        let categories = TestDataFactory.createStandardCategories()
        let rooms = TestDataFactory.createStandardRooms()
        
        let luxuryItem = TestDataFactory.createHighValueItem(
            name: "Hermès Birkin 35 Handbag",
            value: Decimal(25000.00)
        ).apply { item in
            item.category = categories.first { $0.name == "Clothing" }
            item.room = rooms.first { $0.name == "Master Bedroom" }?.name
            item.itemDescription = "Hermès Birkin 35 in Togo leather with palladium hardware"
            item.brand = "Hermès"
            item.serialNumber = "HER-BIRKIN-123456"
            item.condition = "excellent"
            item.notes = "Purchased from Hermès Madison Avenue store with full authenticity documentation"
        }
        
        return InsuranceTestScenarioData(
            title: "Luxury Item Documentation",
            description: "High-value purchase requiring detailed documentation",
            incidentDate: Date(),
            claimAmount: Decimal(25000.00),
            items: [luxuryItem],
            categories: categories,
            rooms: rooms,
            incidentType: .theft, // Common scenario for luxury items
            severity: .minor
        )
    }
    
    // MARK: - Performance Testing Scenarios
    
    /// Large inventory for performance testing
    static func largeInventoryScenario(itemCount: Int = 1000) -> InsuranceTestScenarioData {
        let dataset = TestDataFactory.createLargeDataset(itemCount: itemCount)
        
        return InsuranceTestScenarioData(
            title: "Large Inventory Performance Test",
            description: "Testing with \(itemCount) items for performance validation",
            incidentDate: Date(),
            claimAmount: dataset.items.reduce(Decimal.zero) { $0 + $1.currentValue },
            items: dataset.items,
            categories: dataset.categories,
            rooms: dataset.rooms,
            incidentType: .naturalDisaster,
            severity: .catastrophic
        )
    }
}

// MARK: - Supporting Data Structures

struct InsuranceTestScenarioData {
    let title: String
    let description: String
    let incidentDate: Date
    let claimAmount: Decimal
    let items: [Item]
    let categories: [NestoryCategory]
    let rooms: [Room]
    let incidentType: InsuranceIncidentType
    let severity: IncidentSeverity
}

enum InsuranceIncidentType: String, CaseIterable {
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
}

enum IncidentSeverity: String, CaseIterable {
    case minor = "minor"
    case major = "major"
    case catastrophic = "catastrophic"
    
    var claimProcessingTime: TimeInterval {
        switch self {
        case .minor: return 7 * 24 * 3600 // 1 week
        case .major: return 21 * 24 * 3600 // 3 weeks
        case .catastrophic: return 45 * 24 * 3600 // 6+ weeks
        }
    }
}

// MARK: - Test Helper Extensions

extension InsuranceTestScenarioData {
    /// Calculate total replacement value for insurance claim
    var totalReplacementValue: Decimal {
        items.reduce(Decimal.zero) { $0 + $1.currentValue }
    }
    
    /// Calculate depreciated value for settlement
    var depreciatedValue: Decimal {
        totalReplacementValue * Decimal(0.8) // 20% depreciation typical
    }
    
    /// Generate claim summary for testing
    var claimSummary: String {
        """
        Insurance Claim Summary
        Title: \(title)
        Date: \(incidentDate.formatted(date: .abbreviated, time: .omitted))
        Items Affected: \(items.count)
        Total Claim Value: $\(claimAmount.formatted(.currency(code: "USD")))
        Incident Type: \(incidentType.displayName)
        Severity: \(severity.rawValue.capitalized)
        """
    }
    
    /// Items requiring immediate attention (high value or total loss)
    var priorityItems: [Item] {
        items.filter { item in
            item.currentValue > Decimal(1000) || item.currentValue == Decimal.zero
        }
    }
}
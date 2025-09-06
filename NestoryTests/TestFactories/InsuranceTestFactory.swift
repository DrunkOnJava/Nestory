//
// Layer: Tests
// Module: TestFactories
// Purpose: Specialized factory for insurance claim and damage assessment test scenarios
//

import Foundation
@testable import Nestory

/// Specialized factory for creating insurance-related test data
@MainActor
struct InsuranceTestFactory {
    
    // MARK: - Insurance Claim Scenarios
    
    /// Generate complete insurance claim scenario with multiple damaged items
    static func createInsuranceClaimScenario(
        incidentType: String = "water_damage",
        itemCount: Int = 5
    ) -> [Item] {
        let categories = CategoryTestFactory.createStandardCategories()
        
        var items: [Item] = []
        
        switch incidentType {
        case "water_damage":
            items = [
                ItemTestFactory.createDamagedItem(name: "Samsung 65\" 4K TV", damageType: "water", severity: "total-loss"),
                ItemTestFactory.createDamagedItem(name: "MacBook Pro 16-inch", damageType: "water", severity: "major"),
                ItemTestFactory.createDamagedItem(name: "Leather Sectional Sofa", damageType: "water", severity: "major"),
                ItemTestFactory.createDamagedItem(name: "Hardwood Coffee Table", damageType: "water", severity: "minor"),
                ItemTestFactory.createDamagedItem(name: "Persian Rug 9x12", damageType: "water", severity: "major")
            ]
        case "fire_damage":
            items = [
                ItemTestFactory.createDamagedItem(name: "Entire Wardrobe Collection", damageType: "fire", severity: "total-loss"),
                ItemTestFactory.createDamagedItem(name: "Home Theater System", damageType: "fire", severity: "total-loss"),
                ItemTestFactory.createDamagedItem(name: "Kitchen Appliance Set", damageType: "fire", severity: "total-loss"),
                ItemTestFactory.createDamagedItem(name: "Dining Room Set", damageType: "smoke", severity: "major"),
                ItemTestFactory.createDamagedItem(name: "Art Collection", damageType: "smoke", severity: "major")
            ]
        case "theft":
            items = [
                ItemTestFactory.createDamagedItem(name: "MacBook Pro Laptop", damageType: "theft", severity: "total-loss"),
                ItemTestFactory.createDamagedItem(name: "iPad Pro with Accessories", damageType: "theft", severity: "total-loss"),
                ItemTestFactory.createDamagedItem(name: "Sony Camera Equipment", damageType: "theft", severity: "total-loss"),
                ItemTestFactory.createDamagedItem(name: "Jewelry Collection", damageType: "theft", severity: "total-loss"),
                ItemTestFactory.createDamagedItem(name: "Designer Watch Collection", damageType: "theft", severity: "total-loss")
            ]
        default:
            items = Array(1...itemCount).map { i in
                ItemTestFactory.createDamagedItem(name: "Damaged Item \(i)", damageType: incidentType, severity: "major")
            }
        }
        
        // Associate items with appropriate categories
        for (index, item) in items.enumerated() {
            item.category = categories[index % categories.count]
            item.locationName = createLocationForIncidentType(incidentType)
        }
        
        return items
    }
    
    /// Create a complete damage assessment scenario
    static func createDamageAssessmentScenario(
        incidentType: String = "water_damage",
        severity: DamageAssessmentSeverity = .major
    ) -> (items: [Item], assessment: String) {
        let items = createInsuranceClaimScenario(incidentType: incidentType, itemCount: 3)
        let assessment = createDamageAssessmentReport(for: incidentType, severity: severity)
        return (items, assessment)
    }
    
    // MARK: - Damage Assessment Reports
    
    /// Generate realistic damage assessment text
    static func createDamageAssessmentReport(
        for incidentType: String,
        severity: DamageAssessmentSeverity
    ) -> String {
        switch (incidentType, severity) {
        case ("water_damage", .minor):
            return "Minor water intrusion detected in lower levels. Surface moisture present but no structural damage. Items show minimal water contact with potential for restoration."
            
        case ("water_damage", .major):
            return "Significant water damage throughout affected areas. Standing water observed for extended period. Multiple items show severe water damage with questionable restoration potential."
            
        case ("fire_damage", .totalLoss):
            return "Complete fire destruction of affected areas. Extreme heat damage and smoke penetration throughout. All items in affected zones considered total losses."
            
        case ("theft", .totalLoss):
            return "Criminal entry confirmed. Multiple high-value items reported missing. No recovery expected. Police report filed and security measures recommended."
            
        default:
            return "Damage assessment pending. Initial inspection reveals \(severity.rawValue) level impact from \(incidentType.replacingOccurrences(of: "_", with: " ")) incident."
        }
    }
    
    // MARK: - Location Mapping
    
    /// Get appropriate location for incident type
    static func createLocationForIncidentType(_ incidentType: String) -> String {
        switch incidentType {
        case "water_damage":
            return ["Kitchen", "Basement", "Bathroom", "Laundry Room"].randomElement() ?? "Kitchen"
        case "fire_damage":
            return ["Kitchen", "Living Room", "Bedroom", "Garage"].randomElement() ?? "Kitchen"
        case "theft":
            return ["Master Bedroom", "Home Office", "Living Room"].randomElement() ?? "Master Bedroom"
        default:
            return "Living Room"
        }
    }
    
    // MARK: - High-Value Claim Scenarios
    
    /// Generate high-value insurance claim for luxury items
    static func createHighValueClaimScenario() -> [Item] {
        return [
            ItemTestFactory.createHighValueItem(name: "Rolex Submariner", value: Decimal(12000)),
            ItemTestFactory.createHighValueItem(name: "Diamond Engagement Ring", value: Decimal(15000)),
            ItemTestFactory.createHighValueItem(name: "Steinway Piano", value: Decimal(80000)),
            ItemTestFactory.createHighValueItem(name: "Original Oil Painting", value: Decimal(25000)),
            ItemTestFactory.createHighValueItem(name: "Vintage Wine Collection", value: Decimal(18000))
        ]
    }
}

// MARK: - Supporting Types

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

/// Damage severity levels for assessments
enum DamageAssessmentSeverity: String, CaseIterable {
    case minor = "minor"
    case major = "major"
    case totalLoss = "total-loss"
    
    var displayName: String {
        switch self {
        case .minor: return "Minor Damage"
        case .major: return "Major Damage"
        case .totalLoss: return "Total Loss"
        }
    }
}
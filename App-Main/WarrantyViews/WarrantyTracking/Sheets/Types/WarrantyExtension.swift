//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/Types
// Purpose: Warranty extension data model with display formatting
//

import Foundation

public struct WarrantyExtension: Sendable, Identifiable {
    public let id: UUID
    public let duration: Int // months
    public let price: Double
    public let coverageType: String
    public let benefits: [String]
    
    public init(
        id: UUID = UUID(),
        duration: Int,
        price: Double,
        coverageType: String,
        benefits: [String]
    ) {
        self.id = id
        self.duration = duration
        self.price = price
        self.coverageType = coverageType
        self.benefits = benefits
    }
    
    // MARK: - Display Formatting
    
    public var displayDuration: String {
        if duration == 12 {
            return "1 Year"
        } else if duration % 12 == 0 {
            return "\(duration / 12) Years"
        } else {
            return "\(duration) Months"
        }
    }
    
    public var displayPrice: String {
        return String(format: "$%.2f", price)
    }
    
    // MARK: - Factory Methods
    
    public static func standardExtensions() -> [WarrantyExtension] {
        [
            WarrantyExtension(
                duration: 12,
                price: 99.99,
                coverageType: "Standard Extended",
                benefits: ["Extended repair coverage", "Priority support", "Free diagnostics"]
            ),
            WarrantyExtension(
                duration: 24,
                price: 179.99,
                coverageType: "Premium Extended",
                benefits: ["Full replacement coverage", "24/7 support", "Free shipping", "Accident protection"]
            ),
            WarrantyExtension(
                duration: 36,
                price: 249.99,
                coverageType: "Ultimate Protection",
                benefits: ["Complete coverage", "Concierge service", "Annual check-ups", "Data recovery"]
            )
        ]
    }
}
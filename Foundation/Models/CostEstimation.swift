//
// Layer: Foundation
// Module: Models
// Purpose: Cost estimation data model for damage assessment and repair planning
//

import Foundation

public struct CostEstimation: Equatable, Sendable, Codable, Identifiable {
    public let id: UUID
    
    // Basic costs
    public var replacementCost: Decimal?
    public var materialsCost: Decimal = 0
    public var laborHours: Decimal = 0
    public var hourlyRate: Decimal = 50
    
    // Detailed cost breakdowns
    public var repairCosts: [RepairCost] = []
    public var additionalCosts: [AdditionalCost] = []
    
    // Computed properties
    public var totalRepairCosts: Decimal {
        repairCosts.reduce(0) { $0 + $1.amount }
    }
    
    public var totalAdditionalCosts: Decimal {
        additionalCosts.reduce(0) { $0 + $1.amount }
    }
    
    public var laborCost: Decimal {
        laborHours * hourlyRate
    }
    
    public var totalEstimate: Decimal {
        totalRepairCosts + totalAdditionalCosts + laborCost + materialsCost
    }
    
    public init(
        id: UUID = UUID(),
        replacementCost: Decimal? = nil,
        materialsCost: Decimal = 0,
        laborHours: Decimal = 0,
        hourlyRate: Decimal = 50,
        repairCosts: [RepairCost] = [],
        additionalCosts: [AdditionalCost] = []
    ) {
        self.id = id
        self.replacementCost = replacementCost
        self.materialsCost = materialsCost
        self.laborHours = laborHours
        self.hourlyRate = hourlyRate
        self.repairCosts = repairCosts
        self.additionalCosts = additionalCosts
    }
    
    // MARK: - Nested Types
    
    public struct RepairCost: Identifiable, Equatable, Sendable, Codable {
        public let id: UUID
        public let description: String
        public let amount: Decimal
        public let category: String
        
        public init(id: UUID = UUID(), description: String, amount: Decimal, category: String) {
            self.id = id
            self.description = description
            self.amount = amount
            self.category = category
        }
    }
    
    public struct AdditionalCost: Identifiable, Equatable, Sendable, Codable {
        public let id: UUID
        public let description: String
        public let amount: Decimal
        public let type: CostType
        
        public init(id: UUID = UUID(), description: String, amount: Decimal, type: CostType) {
            self.id = id
            self.description = description
            self.amount = amount
            self.type = type
        }
        
        public enum CostType: String, CaseIterable, Equatable, Sendable, Codable {
            case permit = "Permit"
            case disposal = "Disposal"
            case inspection = "Inspection"
            case storage = "Storage"
            case emergency = "Emergency"
            case other = "Other"
            
            public var displayName: String { rawValue }
            
            public var icon: String {
                switch self {
                case .permit:
                    return "doc.badge.gearshape"
                case .disposal:
                    return "trash.circle"
                case .inspection:
                    return "magnifyingglass.circle"
                case .storage:
                    return "shippingbox"
                case .emergency:
                    return "exclamationmark.triangle"
                case .other:
                    return "ellipsis.circle"
                }
            }
        }
    }
}
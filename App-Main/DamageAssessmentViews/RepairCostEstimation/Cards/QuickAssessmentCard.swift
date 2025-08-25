//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Cards
// Purpose: Quick assessment card wrapper component for repair cost estimation
//

import SwiftUI

public struct QuickAssessmentCard: View {
    let severity: DamageSeverity
    let damageType: DamageType
    let replacementCost: Decimal?
    
    public init(severity: DamageSeverity, damageType: DamageType, replacementCost: Decimal?) {
        self.severity = severity
        self.damageType = damageType
        self.replacementCost = replacementCost
    }
    
    public var body: some View {
        let assessment = DamageAssessment(
            itemId: UUID(),
            damageType: damageType,
            severity: severity,
            incidentDescription: ""
        )
        let quickEstimate = replacementCost.map { $0 * Decimal(severity.valueImpactPercentage) }
        
        QuickAssessmentSection(assessment: assessment, quickDamageEstimate: quickEstimate)
    }
}
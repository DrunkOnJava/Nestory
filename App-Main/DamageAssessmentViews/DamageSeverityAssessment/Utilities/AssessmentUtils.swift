//
// Layer: App-Main
// Module: DamageAssessment/DamageSeverityAssessment/Utilities
// Purpose: Utility functions for damage severity calculations and recommendations
//

import SwiftUI

public struct AssessmentUtils {
    
    public static func calculateCurrentValue(
        originalValue: Decimal?,
        severity: DamageSeverity
    ) -> String {
        guard let originalValue = originalValue else { return "Unknown" }
        let impactMultiplier = 1.0 - severity.valueImpactPercentage
        let currentValue = originalValue * Decimal(impactMultiplier)
        return currentValue.description
    }
    
    public static func shouldRecommendProfessional(
        severity: DamageSeverity,
        damageType: DamageType
    ) -> Bool {
        severity == .major || severity == .total ||
            damageType == .fire || damageType == .naturalDisaster
    }
    
    public static func professionalRecommendationReason(
        severity: DamageSeverity,
        damageType: DamageType
    ) -> String {
        switch severity {
        case .major, .total:
            return "Extensive damage requires professional evaluation for accurate assessment"
        default:
            switch damageType {
            case .fire:
                return "Fire damage often has hidden structural and safety implications"
            case .naturalDisaster:
                return "Natural disaster damage requires specialized structural assessment"
            default:
                return "Complex damage patterns benefit from professional expertise"
            }
        }
    }
}
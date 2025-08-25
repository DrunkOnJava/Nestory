//
// Layer: App-Main
// Module: DamageAssessment/DamageSeverityAssessment/Sections
// Purpose: Value impact analysis with before/after value comparison
//

import SwiftUI

public struct ValueImpactSection: View {
    let selectedSeverity: DamageSeverity
    let assessment: DamageAssessment
    
    public init(selectedSeverity: DamageSeverity, assessment: DamageAssessment) {
        self.selectedSeverity = selectedSeverity
        self.assessment = assessment
    }
    
    private var calculatedCurrentValue: String {
        guard let originalValue = assessment.replacementCost else { return "Unknown" }
        let impactMultiplier = 1.0 - selectedSeverity.valueImpactPercentage
        let currentValue = originalValue * Decimal(impactMultiplier)
        return currentValue.description
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Value Impact Analysis", systemImage: "dollarsign.circle")
                    .font(.headline)
                    .foregroundColor(.blue)

                VStack(spacing: 12) {
                    ValueImpactBar(
                        severity: selectedSeverity,
                        originalValue: assessment.replacementCost ?? 1000
                    )

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Original Value")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("$\(assessment.replacementCost?.description ?? "Unknown")")
                                .font(.callout)
                                .fontWeight(.medium)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("Estimated Current Value")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("$\(calculatedCurrentValue)")
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: selectedSeverity.color))
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
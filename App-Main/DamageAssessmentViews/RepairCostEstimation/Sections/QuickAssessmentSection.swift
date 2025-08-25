//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Sections
// Purpose: Quick assessment section component for repair cost estimation
//

import SwiftUI

public struct QuickAssessmentSection: View {
    let assessment: DamageAssessment
    let quickDamageEstimate: Decimal?

    public init(assessment: DamageAssessment, quickDamageEstimate: Decimal?) {
        self.assessment = assessment
        self.quickDamageEstimate = quickDamageEstimate
    }

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Quick Assessment", systemImage: "speedometer")
                    .font(.headline)
                    .foregroundColor(.blue)

                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Damage Severity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(assessment.severity.rawValue)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: assessment.severity.color))
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("Estimated Impact")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(Int(assessment.severity.valueImpactPercentage * 100))%")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: assessment.severity.color))
                        }
                    }

                    if let estimatedDamage = quickDamageEstimate {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quick Damage Estimate")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack {
                                Text("$\(estimatedDamage.description)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: assessment.severity.color))

                                Text("(based on \(assessment.severity.rawValue.lowercased()) damage)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color(hex: assessment.severity.color).opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
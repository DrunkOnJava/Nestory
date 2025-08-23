//
// Layer: App-Main
// Module: DamageAssessment/DamageSeverityAssessment/Sections
// Purpose: Professional assessment recommendation display with conditional logic
//

import SwiftUI

public struct ProfessionalAssessmentSection: View {
    let selectedSeverity: DamageSeverity
    let assessment: DamageAssessment
    
    public init(selectedSeverity: DamageSeverity, assessment: DamageAssessment) {
        self.selectedSeverity = selectedSeverity
        self.assessment = assessment
    }
    
    private var shouldRecommendProfessional: Bool {
        AssessmentUtils.shouldRecommendProfessional(
            severity: selectedSeverity,
            damageType: assessment.damageType
        )
    }
    
    private var professionalRecommendationReason: String {
        AssessmentUtils.professionalRecommendationReason(
            severity: selectedSeverity,
            damageType: assessment.damageType
        )
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label("Professional Assessment", systemImage: "person.badge.shield.checkmark")
                    .font(.headline)
                    .foregroundColor(.purple)

                if shouldRecommendProfessional {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Professional assessment recommended")
                                .font(.body)
                                .fontWeight(.medium)
                        }

                        Text(professionalRecommendationReason)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Self-assessment appears sufficient")
                            .font(.body)
                    }
                    .foregroundColor(.green)
                }
            }
        }
        .padding(.horizontal)
    }
}
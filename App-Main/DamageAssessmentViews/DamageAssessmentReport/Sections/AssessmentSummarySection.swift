//
// Layer: App-Main
// Module: DamageAssessment/DamageAssessmentReport/Sections
// Purpose: Assessment data summary display section
//

import SwiftUI

struct AssessmentSummarySection: View {
    let workflow: DamageAssessmentWorkflow
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Assessment Summary", systemImage: "info.circle.fill")
                    .font(.headline)
                    .foregroundColor(.blue)

                VStack(spacing: 12) {
                    SummaryRow(
                        label: "Damage Type",
                        value: workflow.assessment.damageType.rawValue.capitalized
                    )

                    SummaryRow(
                        label: "Severity Level",
                        value: workflow.assessment.severity.rawValue.capitalized
                    )

                    SummaryRow(
                        label: "Affected Items",
                        value: "\(workflow.affectedItems.count)"
                    )

                    SummaryRow(
                        label: "Assessment Date",
                        value: workflow.assessment.assessmentDate.formatted(date: .abbreviated, time: .omitted)
                    )

                    if let incidentDate = workflow.assessment.incidentDate {
                        SummaryRow(
                            label: "Incident Date",
                            value: incidentDate.formatted(date: .abbreviated, time: .omitted)
                        )
                    }

                    SummaryRow(
                        label: "Estimated Cost",
                        value: estimatedCostText
                    )

                    if workflow.assessment.professionalAssessmentRequired {
                        SummaryRow(
                            label: "Professional Required",
                            value: "Yes"
                        )
                    }

                    if hasAssessmentNotes {
                        SummaryRow(
                            label: "Notes Available",
                            value: "Yes"
                        )
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Computed Properties
    
    private var severityIcon: String {
        switch workflow.assessment.severity {
        case .minor: return "1.circle.fill"
        case .moderate: return "2.circle.fill"
        case .major: return "3.circle.fill"
        case .severe: return "4.circle.fill"
        case .total: return "5.circle.fill"
        }
    }
    
    private var severityColor: Color {
        switch workflow.assessment.severity {
        case .minor: return .green
        case .moderate: return .yellow
        case .major: return .orange
        case .severe: return .red
        case .total: return .red
        }
    }
    
    private var estimatedCostText: String {
        if let repairEstimate = workflow.assessment.repairEstimate {
            return "$\(repairEstimate) repair"
        } else if let replacementCost = workflow.assessment.replacementCost {
            return "$\(replacementCost) replacement"
        } else {
            return "Not set"
        }
    }
    
    private var hasAssessmentNotes: Bool {
        !workflow.assessment.assessmentNotes.isEmpty
    }
}
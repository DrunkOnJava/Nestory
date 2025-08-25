//
// Layer: App-Main
// Module: DamageAssessment/DamageAssessmentReport/Sections
// Purpose: Report generation status and workflow progress display
//

import SwiftUI

struct ReportStatusSection: View {
    let workflow: DamageAssessmentWorkflow
    
    var body: some View {
        GroupBox("Assessment Status") {
            VStack(alignment: .leading, spacing: 16) {
                Label("Report Status", systemImage: "list.clipboard.fill")
                    .font(.headline)
                    .foregroundColor(.indigo)

                VStack(spacing: 8) {
                    StatusIndicator(
                        title: "Damage Assessment",
                        isComplete: workflow.isComplete,
                        detail: workflow.isComplete ? "Complete" : "Incomplete"
                    )

                    StatusIndicator(
                        title: "Photo Documentation",
                        isComplete: workflow.hasPhotoDocumentation,
                        count: workflow.hasPhotoDocumentation ? workflow.photos.count : 0
                    )

                    StatusIndicator(
                        title: "Repair Cost Estimation",
                        isComplete: workflow.hasRepairEstimate,
                        detail: workflow.hasRepairEstimate ? "Estimated" : "Pending"
                    )

                    StatusIndicator(
                        title: "Professional Assessment",
                        isComplete: !workflow.assessment.professionalAssessmentRequired,
                        detail: workflow.assessment.professionalAssessmentRequired ? "Required" : "Not needed"
                    )
                }

                // Overall completion status
                HStack {
                    Image(systemName: workflow.isComplete ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(workflow.isComplete ? .green : .orange)

                    Text(workflow.isComplete ? "Assessment Complete - Ready for Report" : "Assessment Incomplete - Some steps missing")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(workflow.isComplete ? .green : .orange)

                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal)
    }
}
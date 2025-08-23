//
// Layer: App-Main
// Module: DamageAssessment/DamageAssessmentReport/Sections
// Purpose: Report generation interface and progress display
//

import SwiftUI

struct ReportGenerationSection: View {
    let workflow: DamageAssessmentWorkflow
    @Binding var isGenerating: Bool
    let onGenerate: () -> Void
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Generate Report", systemImage: "doc.richtext")
                    .font(.headline)
                    .foregroundColor(.green)

                Text("Create a comprehensive PDF report with all assessment details, photos, and cost estimates for insurance or professional use.")
                    .font(.body)
                    .foregroundColor(.secondary)

                if isGenerating {
                    VStack(spacing: 8) {
                        ProgressView()
                        Text("Generating report...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                } else {
                    Button(action: onGenerate) {
                        HStack {
                            Image(systemName: "doc.richtext")
                            Text("Generate PDF Report")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!workflow.isComplete)

                    if !workflow.isComplete {
                        Text("Complete the assessment workflow to generate a report")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
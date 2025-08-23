//
// Layer: App-Main
// Module: DamageAssessmentViews/DamageAssessmentReport/Sections
// Purpose: Header section for damage assessment reports
//

import SwiftUI

struct ReportHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Report Icon and Title
            VStack(spacing: 8) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
                
                Text("Damage Assessment Report")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                
                Text("Professional damage documentation and analysis")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Report Benefits
            VStack(alignment: .leading, spacing: 8) {
                BenefitRow(
                    icon: "checkmark.circle.fill",
                    text: "Comprehensive damage documentation"
                )
                
                BenefitRow(
                    icon: "photo.fill",
                    text: "Photo evidence and analysis"
                )
                
                BenefitRow(
                    icon: "dollarsign.circle.fill",
                    text: "Cost estimates and recommendations"
                )
                
                BenefitRow(
                    icon: "paperplane.fill",
                    text: "Ready for insurance submission"
                )
            }
        }
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Supporting Views

private struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.green)
                .font(.subheadline)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    ReportHeaderView()
        .padding()
}
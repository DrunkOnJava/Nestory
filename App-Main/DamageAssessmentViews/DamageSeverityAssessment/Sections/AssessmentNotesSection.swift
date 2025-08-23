//
// Layer: App-Main
// Module: DamageAssessment/DamageSeverityAssessment/Sections
// Purpose: Free-form text area for detailed damage observations
//

import SwiftUI

public struct AssessmentNotesSection: View {
    @Binding var severityNotes: String
    
    public init(severityNotes: Binding<String>) {
        self._severityNotes = severityNotes
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Assessment Notes")
                .font(.headline)
                .padding(.horizontal)

            Text("Detailed observations about the damage")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            TextEditor(text: $severityNotes)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .padding(.horizontal)
        }
    }
}
//
// Layer: App-Main
// Module: DamageAssessment
// Purpose: Interactive severity assessment interface - now organized into modular components
//

import SwiftUI

// MARK: - Modular Component Architecture
//
// This view has been refactored from 592 lines into focused components:
// 
// • Sections/: Individual assessment sections (5 components)
//   - SeveritySelectionSection: Interactive severity level grid
//   - CurrentSelectionSummarySection: Real-time selection display
//   - ValueImpactSection: Financial impact analysis with visual progress bar
//   - RepairabilitySection: Repair vs replacement assessment
//   - AssessmentNotesSection: Free-form detailed observations
//   - ProfessionalAssessmentSection: Expert recommendation logic
//
// • Components/: Supporting UI elements (4 components)
//   - DamageSeverityAssessmentHeader: Dynamic header with severity-based styling
//   - SeverityCard: Individual severity selection buttons
//   - ValueImpactBar: Visual progress indicator for value reduction
//   - RepairabilityGuide: Context-sensitive repair guidance
//
// • Utilities/: Business logic and calculations (1 utility)
//   - AssessmentUtils: Centralized calculation and recommendation logic
//
// This modular structure provides better maintainability, testability, and reusability
// while preserving all existing functionality and user interactions.

struct DamageSeverityAssessmentView: View {
    @Binding var assessment: DamageAssessment
    @State private var selectedSeverity: DamageSeverity
    @State private var severityNotes = ""
    @State private var isRepairable = true
    @State private var estimatedRepairTime = ""
    @State private var showingRepairabilityHelp = false
    @Environment(\.dismiss) private var dismiss

    init(assessment: Binding<DamageAssessment>) {
        self._assessment = assessment
        self._selectedSeverity = State(initialValue: assessment.wrappedValue.severity)
        self._severityNotes = State(initialValue: assessment.wrappedValue.assessmentNotes)
        self._isRepairable = State(initialValue: assessment.wrappedValue.isRepairable)
        self._estimatedRepairTime = State(initialValue: assessment.wrappedValue.estimatedRepairTime ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with dynamic severity styling
                    DamageSeverityAssessmentHeader(selectedSeverity: selectedSeverity)

                    // Interactive severity level selection
                    SeveritySelectionSection(selectedSeverity: $selectedSeverity)

                    // Current selection display with insurance impact
                    CurrentSelectionSummarySection(selectedSeverity: selectedSeverity)

                    // Financial value impact analysis
                    ValueImpactSection(selectedSeverity: selectedSeverity, assessment: assessment)

                    // Repair vs replacement assessment
                    RepairabilitySection(
                        selectedSeverity: selectedSeverity,
                        isRepairable: $isRepairable,
                        estimatedRepairTime: $estimatedRepairTime,
                        showingRepairabilityHelp: $showingRepairabilityHelp
                    )

                    // Free-form detailed observations
                    AssessmentNotesSection(severityNotes: $severityNotes)

                    // Professional assessment recommendation
                    ProfessionalAssessmentSection(
                        selectedSeverity: selectedSeverity,
                        assessment: assessment
                    )
                }
                .padding(.vertical)
            }
            .navigationTitle("Severity Assessment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAssessment()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingRepairabilityHelp) {
            RepairabilityHelpView()
        }
    }

    private func saveAssessment() {
        assessment.severity = selectedSeverity
        assessment.assessmentNotes = severityNotes
        assessment.isRepairable = isRepairable
        assessment.estimatedRepairTime = estimatedRepairTime.isEmpty ? nil : estimatedRepairTime
        assessment.professionalAssessmentRequired = AssessmentUtils.shouldRecommendProfessional(
            severity: selectedSeverity,
            damageType: assessment.damageType
        )

        dismiss()
    }
}

#Preview {
    DamageSeverityAssessmentView(
        assessment: .constant(DamageAssessment(
            itemId: UUID(),
            damageType: .fire,
            severity: .moderate,
            incidentDescription: "Fire damage from kitchen incident"
        ))
    )
}
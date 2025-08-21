//
// Layer: App-Main
// Module: DamageAssessment
// Purpose: Interactive severity assessment and rating interface
//

import SwiftUI

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
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: selectedSeverity.color))

                        Text("Damage Severity Assessment")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Evaluate the extent and impact of the damage")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)

                    // Severity Level Selection
                    severitySelectionGrid

                    // Current Selection Summary
                    currentSelectionSummary

                    // Value Impact Assessment
                    valueImpactSection

                    // Repairability Assessment
                    repairabilitySection

                    // Assessment Notes
                    assessmentNotesSection

                    // Professional Assessment Recommendation
                    professionalAssessmentSection
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

    // MARK: - Severity Selection Grid

    private var severitySelectionGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Damage Severity Level")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                ForEach(DamageSeverity.allCases, id: \.self) { severity in
                    SeverityCard(
                        severity: severity,
                        isSelected: selectedSeverity == severity
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedSeverity = severity
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Current Selection Summary

    private var currentSelectionSummary: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: selectedSeverity.icon)
                        .font(.title2)
                        .foregroundColor(Color(hex: selectedSeverity.color))

                    VStack(alignment: .leading) {
                        Text(selectedSeverity.rawValue)
                            .font(.headline)
                        Text(selectedSeverity.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Insurance Impact:")
                        .font(.caption)
                        .fontWeight(.semibold)

                    Text("Estimated value reduction: \(Int(selectedSeverity.valueImpactPercentage * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Value Impact Section

    private var valueImpactSection: some View {
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

    // MARK: - Repairability Section

    private var repairabilitySection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Repairability Assessment", systemImage: "wrench.and.screwdriver")
                        .font(.headline)
                        .foregroundColor(.orange)

                    Spacer()

                    Button(action: {
                        showingRepairabilityHelp = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.blue)
                    }
                }

                VStack(spacing: 12) {
                    HStack {
                        Text("Can this item be repaired?")
                            .font(.body)

                        Spacer()

                        Picker("Repairability", selection: $isRepairable) {
                            Text("Yes").tag(true)
                            Text("No").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                    }

                    if isRepairable {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Estimated Repair Time")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            TextField("e.g., 2-3 weeks", text: $estimatedRepairTime)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        RepairabilityGuide(severity: selectedSeverity)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Item requires replacement")
                                    .font(.body)
                                    .foregroundColor(.red)
                            }

                            Text("Total loss - repair not economically viable")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Assessment Notes Section

    private var assessmentNotesSection: some View {
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

    // MARK: - Professional Assessment Section

    private var professionalAssessmentSection: some View {
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

    // MARK: - Computed Properties

    private var calculatedCurrentValue: String {
        guard let originalValue = assessment.replacementCost else { return "Unknown" }
        let impactMultiplier = 1.0 - selectedSeverity.valueImpactPercentage
        let currentValue = originalValue * Decimal(impactMultiplier)
        return currentValue.description
    }

    private var shouldRecommendProfessional: Bool {
        selectedSeverity == .major || selectedSeverity == .total ||
            assessment.damageType == .fire || assessment.damageType == .naturalDisaster
    }

    private var professionalRecommendationReason: String {
        switch selectedSeverity {
        case .major, .total:
            "Extensive damage requires professional evaluation for accurate assessment"
        default:
            switch assessment.damageType {
            case .fire:
                "Fire damage often has hidden effects requiring professional evaluation"
            case .naturalDisaster:
                "Natural disaster damage may have structural implications"
            case .water:
                "Water damage assessment benefits from moisture and mold evaluation"
            default:
                "Complex damage assessment recommended"
            }
        }
    }

    // MARK: - Actions

    private func saveAssessment() {
        assessment.severity = selectedSeverity
        assessment.assessmentNotes = severityNotes
        assessment.isRepairable = isRepairable
        assessment.estimatedRepairTime = estimatedRepairTime.isEmpty ? nil : estimatedRepairTime
        assessment.professionalAssessmentRequired = shouldRecommendProfessional

        dismiss()
    }
}

// MARK: - Supporting Views

struct SeverityCard: View {
    let severity: DamageSeverity
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: severity.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: severity.color))

                VStack(spacing: 4) {
                    Text(severity.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("\(Int(severity.valueImpactPercentage * 100))% impact")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                isSelected ? Color(hex: severity.color).opacity(0.1) : Color(.systemGray6)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color(hex: severity.color) : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ValueImpactBar: View {
    let severity: DamageSeverity
    let originalValue: Decimal

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Value Impact")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(Int(severity.valueImpactPercentage * 100))% reduction")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: severity.color))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(Color(hex: severity.color))
                        .frame(
                            width: geometry.size.width * severity.valueImpactPercentage,
                            height: 8
                        )
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

struct RepairabilityGuide: View {
    let severity: DamageSeverity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repair Considerations:")
                .font(.caption)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 4) {
                switch severity {
                case .minor:
                    Text("• Simple repairs or cleaning usually sufficient")
                    Text("• DIY repairs often possible")
                    Text("• Quick turnaround expected")
                case .moderate:
                    Text("• Professional repair recommended")
                    Text("• May require part replacement")
                    Text("• Moderate time and cost investment")
                case .major:
                    Text("• Extensive professional work required")
                    Text("• Multiple components may need replacement")
                    Text("• Significant time and cost")
                case .total:
                    Text("• Repair not economically viable")
                    Text("• Complete replacement recommended")
                    Text("• Focus on salvage value if any")
                }
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct RepairabilityHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Determining Repairability")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Consider these factors when assessing whether an item can be repaired:")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        RepairabilityFactor(
                            title: "Cost vs. Value",
                            description: "If repair costs exceed 70% of replacement value, replacement is usually preferred"
                        )

                        RepairabilityFactor(
                            title: "Safety Considerations",
                            description: "Items with safety implications (electrical, structural) may not be repairable"
                        )

                        RepairabilityFactor(
                            title: "Part Availability",
                            description: "Older items may not have replacement parts available"
                        )

                        RepairabilityFactor(
                            title: "Structural Integrity",
                            description: "Core structural damage often makes repair unviable"
                        )

                        RepairabilityFactor(
                            title: "Contamination",
                            description: "Certain types of contamination make items unrepairable"
                        )
                    }

                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Professional Consultation", systemImage: "person.badge.shield.checkmark")
                                .font(.headline)
                                .foregroundColor(.blue)

                            Text("When in doubt, consult with a professional assessor or repair specialist. They can provide accurate repair estimates and safety evaluations.")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Repairability Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct RepairabilityFactor: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
        }
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

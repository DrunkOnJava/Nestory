//
// Layer: App-Main
// Module: DamageAssessmentComponents
// Purpose: Reusable UI components for damage assessment workflow
//

import SwiftUI

// MARK: - Damage Type Selection

public struct DamageTypeCard: View {
    let damageType: DamageType
    let isSelected: Bool
    let action: () -> Void

    public init(damageType: DamageType, isSelected: Bool, action: @escaping () -> Void) {
        self.damageType = damageType
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: damageType.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: damageType.color))

                Text(damageType.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color(hex: damageType.color).opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color(hex: damageType.color) : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Information Display

public struct InfoRow: View {
    let label: String
    let value: String

    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }

    public var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Progress Views

public struct WorkflowProgressHeader: View {
    let workflow: DamageAssessmentWorkflow
    let item: Item

    public init(workflow: DamageAssessmentWorkflow, item: Item) {
        self.workflow = workflow
        self.item = item
    }

    public var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: workflow.damageType.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: workflow.damageType.color))

                VStack(alignment: .leading) {
                    Text(workflow.damageType.rawValue)
                        .font(.headline)
                    Text("Assessment for \(item.name)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // Progress Bar
            ProgressView(value: workflow.progress) {
                HStack {
                    Text("Progress")
                    Spacer()
                    Text("\(Int(workflow.progress * 100))%")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .tint(Color(hex: workflow.damageType.color))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Summary Views

public struct AssessmentSummary: View {
    let workflow: DamageAssessmentWorkflow
    let onGenerateReport: () -> Void
    let isGenerating: Bool

    public init(workflow: DamageAssessmentWorkflow, onGenerateReport: @escaping () -> Void, isGenerating: Bool = false) {
        self.workflow = workflow
        self.onGenerateReport = onGenerateReport
        self.isGenerating = isGenerating
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)

                VStack(alignment: .leading) {
                    Text("Assessment Complete")
                        .font(.headline)
                    Text("Review the results below")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // Assessment Results
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Damage Type", value: workflow.damageType.rawValue)
                InfoRow(label: "Severity", value: workflow.assessment.severity.rawValue)
                InfoRow(label: "Repairable", value: workflow.assessment.isRepairable ? "Yes" : "No")

                if let repairEstimate = workflow.assessment.repairEstimate {
                    InfoRow(label: "Repair Estimate", value: "$\(repairEstimate)")
                }

                if let replacementCost = workflow.assessment.replacementCost {
                    InfoRow(label: "Replacement Cost", value: "$\(replacementCost)")
                }
            }

            // Generate Report Button
            Button(action: onGenerateReport) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "doc.richtext")
                    }
                    Text("Generate Assessment Report")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isGenerating)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

// MARK: - Loading Views

public struct DamageLoadingView: View {
    let message: String

    public init(message: String = "Starting assessment...") {
        self.message = message
    }

    public var body: some View {
        VStack {
            ProgressView()
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Color Extension (if not already defined)


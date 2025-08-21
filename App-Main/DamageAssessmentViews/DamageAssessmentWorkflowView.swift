//
// Layer: App-Main
// Module: DamageAssessment
// Purpose: Main guided workflow view for damage assessment process
//

import SwiftUI
import SwiftData

struct DamageAssessmentWorkflowView: View {
    let item: Item
    @StateObject private var core: DamageAssessmentCore
    @Environment(\.dismiss) private var dismiss

    init(item: Item, modelContext: ModelContext) {
        self.item = item
        self._core = StateObject(wrappedValue: {
            do {
                return try DamageAssessmentCore(item: item, modelContext: modelContext)
            } catch {
                fatalError("Failed to initialize DamageAssessmentCore: \(error)")
            }
        }())
    }

    var body: some View {
        NavigationStack {
            Group {
                if core.showingDamageTypeSelector {
                    damageTypeSelectionView
                } else if let workflow = core.workflow {
                    workflowProgressView(workflow: workflow)
                } else {
                    DamageLoadingView(message: "Starting assessment...")
                }
            }
            .navigationTitle("Damage Assessment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if !core.showingDamageTypeSelector {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save & Exit") {
                            dismiss()
                        }
                        .disabled(core.isLoading)
                    }
                }
            }
        }
    }

    // MARK: - Damage Type Selection

    private var damageTypeSelectionView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)

                    Text("Document Damage Assessment")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    Text("Select the type of damage to begin a guided assessment process for \"\(item.name)\"")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)

                // Damage Type Selection
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 16) {
                    ForEach(DamageType.allCases, id: \.self) { type in
                        DamageTypeCard(
                            damageType: type,
                            isSelected: core.damageType == type
                        ) {
                            core.selectDamageType(type)
                        }
                    }
                }
                .padding(.horizontal)

                // Incident Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Incident Description")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Provide a brief description of what happened")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextEditor(text: $core.incidentDescription)
                        .frame(minHeight: 80)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                .padding(.horizontal)

                // Start Assessment Button
                Button(action: core.startAssessment) {
                    HStack {
                        if core.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "play.circle.fill")
                        }

                        Text("Start Assessment")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(core.canStartAssessment ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!core.canStartAssessment || core.isLoading)
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
    }

    // MARK: - Workflow Progress View

    private func workflowProgressView(workflow: DamageAssessmentWorkflow) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress Header
                WorkflowProgressHeader(workflow: workflow, item: item)

                // Current Step
                if !workflow.isComplete {
                    CurrentStepView(
                        workflow: workflow,
                        onCompleteStep: core.completeCurrentStep,
                        isLoading: core.isLoading
                    )
                }

                // Completed Steps
                if !workflow.completedSteps.isEmpty {
                    CompletedStepsView(workflow: workflow)
                }

                // Assessment Summary (if complete)
                if workflow.isComplete {
                    AssessmentSummary(
                        workflow: workflow,
                        onGenerateReport: core.generateReport,
                        isGenerating: core.isLoading
                    )
                }

                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    DamageAssessmentWorkflowView(
        item: Item(name: "Test Item"),
        modelContext: ModelContext(
            try! ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        )
    )
}

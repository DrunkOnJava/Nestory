//
// Layer: App-Main
// Module: DamageAssessmentSteps
// Purpose: Step-specific views and workflow progression logic for damage assessment
//

import SwiftUI
import SwiftData

// MARK: - Step Content Builder

public enum StepContentBuilder {
    @ViewBuilder
    @MainActor
    public static func stepContentView(for step: DamageAssessmentStep, workflow: DamageAssessmentWorkflow, damageService: DamageAssessmentService) -> some View {
        switch step {
        case .initialDocumentation:
            InitialDocumentationStepView(workflow: workflow, damageService: damageService)
        case .costEstimation, .replacementCostCalculation:
            CostEstimationStepView(workflow: workflow, damageService: damageService)
        case .reportGeneration:
            ReportGenerationStepView(workflow: workflow, damageService: damageService)
        default:
            GenericStepView(step: step, workflow: workflow, damageService: damageService)
        }
    }
}

// MARK: - Step-Specific Views

public struct InitialDocumentationStepView: View {
    let workflow: DamageAssessmentWorkflow
    let damageService: DamageAssessmentService

    public init(workflow: DamageAssessmentWorkflow, damageService: DamageAssessmentService) {
        self.workflow = workflow
        self.damageService = damageService
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Take overview photos showing the extent of damage")
                .font(.body)

            Button(action: {
                // Navigate to photo capture
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Take Photos")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
            }
        }
    }
}

public struct CostEstimationStepView: View {
    let workflow: DamageAssessmentWorkflow
    let damageService: DamageAssessmentService
    @State private var repairCost = ""
    @State private var replacementCost = ""

    public init(workflow: DamageAssessmentWorkflow, damageService: DamageAssessmentService) {
        self.workflow = workflow
        self.damageService = damageService
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estimate repair and replacement costs")
                .font(.body)

            VStack(alignment: .leading, spacing: 8) {
                Text("Repair Cost")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField("Enter repair cost", text: $repairCost)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Replacement Cost")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField("Enter replacement cost", text: $replacementCost)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
            }
        }
    }
}

public struct ReportGenerationStepView: View {
    let workflow: DamageAssessmentWorkflow
    let damageService: DamageAssessmentService

    public init(workflow: DamageAssessmentWorkflow, damageService: DamageAssessmentService) {
        self.workflow = workflow
        self.damageService = damageService
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ready to generate comprehensive assessment report")
                .font(.body)

            Text("This report will include all documentation, photos, and cost estimates.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

public struct GenericStepView: View {
    let step: DamageAssessmentStep
    let workflow: DamageAssessmentWorkflow
    let damageService: DamageAssessmentService

    public init(step: DamageAssessmentStep, workflow: DamageAssessmentWorkflow, damageService: DamageAssessmentService) {
        self.step = step
        self.workflow = workflow
        self.damageService = damageService
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Step: \(step.rawValue)")
                .font(.headline)

            Text(step.description)
                .font(.body)
                .foregroundColor(.secondary)

            // Step description
            VStack(alignment: .leading, spacing: 4) {
                Text("Description:")
                    .font(.caption)
                    .fontWeight(.medium)

                Text(step.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Step Progress Views

public struct CurrentStepView: View {
    let workflow: DamageAssessmentWorkflow
    let onCompleteStep: () -> Void
    let isLoading: Bool

    public init(workflow: DamageAssessmentWorkflow, onCompleteStep: @escaping () -> Void, isLoading: Bool = false) {
        self.workflow = workflow
        self.onCompleteStep = onCompleteStep
        self.isLoading = isLoading
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Step Header
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading) {
                    Text("Current Step")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(workflow.currentStep.rawValue)
                        .font(.headline)
                }

                Spacer()

                Text("Step \((workflow.damageType.assessmentSteps.firstIndex(of: workflow.currentStep) ?? 0) + 1) of \(workflow.damageType.assessmentSteps.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Step Content
            Group {
                if let container = try? ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)),
                   let damageService = try? DamageAssessmentService(modelContext: ModelContext(container)) {
                    StepContentBuilder.stepContentView(
                        for: workflow.currentStep,
                        workflow: workflow,
                        damageService: damageService
                    )
                } else {
                    Text("Unable to initialize damage assessment service")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            // Complete Step Button
            Button(action: onCompleteStep) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark.circle")
                    }
                    Text("Complete Step")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isLoading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

public struct CompletedStepsView: View {
    let workflow: DamageAssessmentWorkflow

    public init(workflow: DamageAssessmentWorkflow) {
        self.workflow = workflow
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Completed Steps")
                    .font(.headline)
                Spacer()
                Text("\(workflow.completedSteps.count) completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ForEach(Array(workflow.completedSteps), id: \.self) { (step: DamageAssessmentStep) in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)

                    Text(step.rawValue)
                        .font(.body)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

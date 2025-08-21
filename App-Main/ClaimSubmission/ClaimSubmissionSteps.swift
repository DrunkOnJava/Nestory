//
// Layer: App
// Module: ClaimSubmission
// Purpose: Step-specific views and logic for claim submission workflow
//

import SwiftUI
import MessageUI

// MARK: - Step Content Views

public enum ClaimSubmissionSteps {
    // MARK: - Step 1: Claim Configuration

    @MainActor
    public static func claimConfigurationStep(
        core: ClaimSubmissionCore
    ) -> some View {
        StepContainer {
            VStack(alignment: .leading, spacing: 20) {
                Text("Claim Information")
                    .font(.title2)
                    .fontWeight(.semibold)

                Group {
                    ClaimTypeSelector(claimType: Binding(
                        get: { core.claimType },
                        set: { core.claimType = $0 }
                    ))

                    InsuranceCompanySelector(insuranceCompany: Binding(
                        get: { core.insuranceCompany },
                        set: { core.insuranceCompany = $0 }
                    ))

                    PolicyNumberField(policyNumber: Binding(
                        get: { core.policyNumber },
                        set: { core.policyNumber = $0 }
                    ))

                    IncidentDatePicker(incidentDate: Binding(
                        get: { core.incidentDate },
                        set: { core.incidentDate = $0 }
                    ))

                    IncidentDescriptionEditor(incidentDescription: Binding(
                        get: { core.incidentDescription },
                        set: { core.incidentDescription = $0 }
                    ))
                }

                Button("Next: Select Items") {
                    core.nextStep()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!core.canProceedFromStep(1))
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Step 2: Item Selection

    @MainActor
    public static func itemSelectionStep(
        core: ClaimSubmissionCore,
        items: [Item]
    ) -> some View {
        StepContainer {
            VStack(alignment: .leading, spacing: 20) {
                Text("Select Items to Include")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Choose the items you want to include in this claim.")
                    .foregroundColor(.secondary)

                // Selection Summary
                if !core.selectedItems.isEmpty {
                    ItemSelectionControls(
                        selectedCount: core.selectedItems.count,
                        onSelectAll: { core.selectAllItems(items) },
                        onClearAll: { core.clearAllItems() }
                    )
                }

                // Items List
                LazyVStack {
                    ForEach(items) { item in
                        ItemSelectionRow(
                            item: item,
                            isSelected: core.selectedItems.contains(item.id),
                            onToggle: { core.toggleItem(item.id) }
                        )
                    }
                }

                Button("Next: Validate Claim") {
                    core.nextStep()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!core.canProceedFromStep(2))
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Step 3: Validation

    @MainActor
    public static func validationStep(
        core: ClaimSubmissionCore,
        items: [Item]
    ) -> some View {
        StepContainer {
            VStack(alignment: .leading, spacing: 20) {
                Text("Claim Validation")
                    .font(.title2)
                    .fontWeight(.semibold)

                if let results = core.validationResults {
                    ValidationSummaryView(results: results)

                    Button("View Detailed Validation") {
                        core.showingValidation = true
                    }
                    .foregroundColor(.blue)
                } else {
                    Text("Validating your claim...")
                        .foregroundColor(.secondary)

                    ProgressView()
                        .frame(maxWidth: .infinity)
                }

                if core.validationCompleted {
                    Button("Next: Submit Claim") {
                        core.nextStep()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!core.canProceedFromStep(3))
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .task {
            if core.validationResults == nil, !core.validationCompleted {
                await core.validateClaim(with: items)
            }
        }
    }

    // MARK: - Step 4: Submission

    @MainActor
    public static func submissionStep(
        core: ClaimSubmissionCore
    ) -> some View {
        StepContainer {
            VStack(alignment: .leading, spacing: 20) {
                Text("Submit Your Claim")
                    .font(.title2)
                    .fontWeight(.semibold)

                // Submission Method Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Submission Method")
                        .fontWeight(.medium)

                    let availableMethods = core.availableSubmissionMethods
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: 12) {
                        ForEach(availableMethods, id: \.self) { method in
                            SubmissionMethodCard(
                                method: method,
                                isSelected: core.submissionMethod == method,
                                onSelect: { core.submissionMethod = method }
                            )
                        }
                    }
                }

                // Method-specific options
                Group {
                    switch core.submissionMethod {
                    case .email:
                        RecipientEmailField(recipientEmail: Binding(
                            get: { core.recipientEmail },
                            set: { core.recipientEmail = $0 }
                        ))

                    case .cloudUpload:
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cloud Storage Service")
                                .fontWeight(.medium)

                            CloudServiceGrid(
                                services: core.cloudServices,
                                selectedService: core.selectedCloudService,
                                onSelect: { core.selectedCloudService = $0 }
                            )
                        }

                    default:
                        Text("Manual submission required - we'll prepare your claim package")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                Button(core.isProcessing ? "Processing..." : "Create and Submit Claim") {
                    // Note: This should be handled by the parent view
                    // since it needs access to the data collections
                }
                .buttonStyle(.borderedProminent)
                .disabled(core.isProcessing || !core.canProceedFromStep(4))
                .frame(maxWidth: .infinity)

                if core.isProcessing {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - Step Builder

public struct ClaimSubmissionStepView: View {
    @ObservedObject var core: ClaimSubmissionCore
    let items: [Item]
    let categories: [Category]
    let rooms: [Room]
    let onSubmit: () -> Void

    public init(
        core: ClaimSubmissionCore,
        items: [Item],
        categories: [Category],
        rooms: [Room],
        onSubmit: @escaping () -> Void
    ) {
        self.core = core
        self.items = items
        self.categories = categories
        self.rooms = rooms
        self.onSubmit = onSubmit
    }

    public var body: some View {
        Group {
            switch core.currentStep {
            case 1:
                ClaimSubmissionSteps.claimConfigurationStep(core: core)
            case 2:
                ClaimSubmissionSteps.itemSelectionStep(core: core, items: items)
            case 3:
                ClaimSubmissionSteps.validationStep(core: core, items: items)
            case 4:
                ClaimSubmissionSteps.submissionStep(core: core)
                    .onTapGesture {
                        if core.canProceedFromStep(4), !core.isProcessing {
                            onSubmit()
                        }
                    }
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - Mail Composer View
// MailComposerView is defined in ClaimEmailService in Services layer

// MARK: - Supporting Types

public struct ClaimEmailConfiguration {
    public let recipientEmail: String
    public let subject: String
    public let body: String
    public let attachment: EmailAttachment?

    public init(recipientEmail: String, subject: String, body: String, attachment: EmailAttachment?) {
        self.recipientEmail = recipientEmail
        self.subject = subject
        self.body = body
        self.attachment = attachment
    }
}

// EmailAttachment is defined in ClaimEmailService in Services layer

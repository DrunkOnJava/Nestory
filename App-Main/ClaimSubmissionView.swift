//
// Layer: App
// Module: ClaimSubmission
// Purpose: Claim submission interface coordinator using modular components
//

import SwiftUI
import SwiftData
import MessageUI

// Modular components are automatically available within the same target
// ClaimSubmissionCore, ClaimSubmissionComponents, ClaimSubmissionSteps included

struct ClaimSubmissionView: View {
    @Query private var items: [Item]
    @Query private var categories: [Category]
    @Query private var rooms: [Room]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var core: ClaimSubmissionCore

    init(modelContext: ModelContext) {
        _core = StateObject(wrappedValue: ClaimSubmissionCore(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Progress Indicator
                    WorkflowProgressView(currentStep: core.currentStep, totalSteps: core.totalSteps)

                    // Step Content
                    ClaimSubmissionStepView(
                        core: core,
                        items: items,
                        categories: categories,
                        rooms: rooms,
                        onSubmit: handleSubmission
                    )
                }
                .padding()
            }
            .navigationTitle("Submit Insurance Claim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        core.reset()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if core.currentStep > 1 {
                        Button("Back") {
                            core.previousStep()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { core.showingValidation },
            set: { core.showingValidation = $0 }
        )) {
            ValidationResultsView(
                results: core.validationResults,
                onDismiss: { core.showingValidation = false }
            )
        }
        .sheet(isPresented: Binding(
            get: { core.showingEmailComposer },
            set: { core.showingEmailComposer = $0 }
        )) {
            if MFMailComposeViewController.canSendMail(),
               let claim = core.currentClaim,
               let fileURL = claim.exportedFileURL,
               let url = URL(string: fileURL)
            {
                let email = createClaimEmail(claim: claim, fileURL: url)
                MailComposerView(email: email) { result in
                    Task {
                        await core.handleEmailResult(result)
                        if case .success = result {
                            dismiss()
                        }
                    }
                }
            } else {
                Text("Mail not available")
                    .padding()
            }
        }
        .alert("Processing Error", isPresented: Binding(
            get: { core.showingError },
            set: { core.showingError = $0 }
        )) {
            Button("OK") { core.processingError = nil }
        } message: {
            Text(core.processingError?.localizedDescription ?? "An error occurred")
        }
    }

    // MARK: - Helper Methods

    private func handleSubmission() {
        Task {
            await core.createAndSubmitClaim(
                items: items,
                categories: categories,
                rooms: rooms
            )

            if !core.showingEmailComposer, core.processingError == nil {
                dismiss()
            }
        }
    }

    private func createClaimEmail(claim: ClaimSubmission, fileURL: URL) -> ClaimEmailConfiguration {
        let subject = "Insurance Claim Submission - \(claim.claimType.rawValue)"
        let body = """
        Dear Claims Department,

        Please find attached my insurance claim submission for policy \(claim.policyNumber ?? "[Policy Number]").

        Claim Details:
        - Claim Type: \(claim.claimType.rawValue)
        - Incident Date: \(claim.incidentDate?.formatted(date: .abbreviated, time: .omitted) ?? "Not specified")
        - Total Items: \(claim.totalItemCount)
        - Total Claimed Value: $\(claim.totalClaimedValue)

        This submission includes detailed documentation for all claimed items, including photos and supporting documentation where available.

        Please confirm receipt of this submission and provide a claim reference number for future correspondence.

        Thank you for your prompt attention to this matter.

        Best regards,
        [Policyholder Name]
        """

        let attachment = try? Data(contentsOf: fileURL).map { data in
            EmailAttachment(
                data: data,
                mimeType: "application/octet-stream",
                fileName: fileURL.lastPathComponent
            )
        }

        return ClaimEmailConfiguration(
            recipientEmail: core.recipientEmail,
            subject: subject,
            body: body,
            attachment: attachment
        )
    }
}

#Preview {
    ClaimSubmissionView(modelContext: ModelContext(
        try! ModelContainer(for: Item.self, Category.self, Room.self, ClaimSubmission.self)
    ))
}

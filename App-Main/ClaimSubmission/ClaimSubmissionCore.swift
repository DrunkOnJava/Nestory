//
// Layer: App
// Module: ClaimSubmission
// Purpose: Core state management and business logic for claim submission workflow
//

import SwiftUI
import SwiftData
import MessageUI

// MARK: - Core State Management

@MainActor
public final class ClaimSubmissionCore: ObservableObject {
    // MARK: - Dependencies

    private let modelContext: ModelContext
    private let claimExportService: ClaimExportService
    private let claimValidationService = ClaimValidationService()
    private let claimTrackingService: ClaimTrackingService
    private let claimEmailService = ClaimEmailService()
    private let cloudStorageManager = CloudStorageManager()

    // MARK: - State Properties

    // Selection State
    @Published public var selectedItems: Set<UUID> = []
    @Published public var selectedCategories: Set<UUID> = []
    @Published public var selectedRooms: Set<UUID> = []

    // Claim Configuration
    @Published public var claimType: InsuranceClaimType = .other
    @Published public var insuranceCompany: InsuranceCompanyFormat = .generic
    @Published public var submissionMethod: SubmissionMethod = .email
    @Published public var policyNumber = ""
    @Published public var incidentDate = Date()
    @Published public var incidentDescription = ""

    // Validation State
    @Published public var validationResults: ClaimValidationResults?
    @Published public var showingValidation = false
    @Published public var validationCompleted = false

    // Submission State
    @Published public var showingSubmissionOptions = false
    @Published public var showingEmailComposer = false
    @Published public var showingCloudUpload = false
    @Published public var selectedCloudService: (any CloudStorageService)?
    @Published public var recipientEmail = ""

    // Processing State
    @Published public var isProcessing = false
    @Published public var currentClaim: ClaimSubmission?
    @Published public var processingError: (any Error)?
    @Published public var showingError = false

    // UI State
    @Published public var currentStep = 1
    public let totalSteps = 4

    // MARK: - Computed Properties

    public var cloudServices: [any CloudStorageService] {
        cloudStorageManager.availableServices
    }

    public var availableSubmissionMethods: [SubmissionMethod] {
        insuranceCompany.submissionMethods
    }

    // MARK: - Initialization

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.claimExportService = ClaimExportService(modelContext: modelContext)
        self.claimTrackingService = ClaimTrackingService(modelContext: modelContext)
    }

    // MARK: - Navigation

    public func nextStep() {
        guard currentStep < totalSteps else { return }
        withAnimation { currentStep += 1 }
    }

    public func previousStep() {
        guard currentStep > 1 else { return }
        withAnimation { currentStep -= 1 }
    }

    public func canProceedFromStep(_ step: Int) -> Bool {
        switch step {
        case 1: !policyNumber.isEmpty
        case 2: !selectedItems.isEmpty
        case 3: validationCompleted && validationResults?.isReadyForSubmission == true
        case 4: canSubmit()
        default: false
        }
    }

    // MARK: - Item Selection

    public func toggleItem(_ itemId: UUID) {
        if selectedItems.contains(itemId) {
            selectedItems.remove(itemId)
        } else {
            selectedItems.insert(itemId)
        }
    }

    public func selectAllItems(_ items: [Item]) {
        selectedItems = Set(items.map(\.id))
    }

    public func clearAllItems() {
        selectedItems.removeAll()
    }

    // MARK: - Validation

    public func validateClaim(with items: [Item]) async {
        let selectedItemsArray = items.filter { selectedItems.contains($0.id) }

        do {
            let results = try await claimValidationService.validateClaim(
                items: selectedItemsArray,
                claimType: claimType,
                insuranceCompany: insuranceCompany
            )

            await MainActor.run {
                self.validationResults = results
                self.validationCompleted = true
            }
        } catch {
            await MainActor.run {
                self.processingError = error
                self.showingError = true
            }
        }
    }

    // MARK: - Claim Creation and Submission

    public func createAndSubmitClaim(
        items: [Item],
        categories: [Category],
        rooms: [Room]
    ) async {
        isProcessing = true
        defer { isProcessing = false }

        let selectedItemsArray = items.filter { selectedItems.contains($0.id) }

        do {
            // Create claim
            let claim = try await claimExportService.createClaim(
                items: selectedItemsArray,
                categories: categories,
                rooms: rooms,
                insuranceCompany: insuranceCompany,
                claimType: claimType,
                submissionMethod: submissionMethod,
                policyNumber: policyNumber.isEmpty ? nil : policyNumber,
                incidentDate: incidentDate
            )

            currentClaim = claim

            // Submit based on method
            switch submissionMethod {
            case .email:
                await handleEmailSubmission(claim: claim)

            case .cloudUpload:
                try await handleCloudUpload(claim: claim)

            default:
                // Manual submission - just create the claim
                await completeClaimCreation(claim: claim)
            }

        } catch {
            processingError = error
            showingError = true
        }
    }

    // MARK: - Submission Handlers

    private func handleEmailSubmission(claim: ClaimSubmission) async {
        if MFMailComposeViewController.canSendMail(), !recipientEmail.isEmpty {
            showingEmailComposer = true
        } else {
            // Fallback - just create the claim
            await completeClaimCreation(claim: claim)
        }
    }

    private func handleCloudUpload(claim: ClaimSubmission) async throws {
        guard let service = selectedCloudService,
              let fileURL = claim.exportedFileURL,
              let url = URL(string: fileURL)
        else {
            throw ClaimExportError.uploadFailed("No cloud service selected")
        }

        let uploadURL = try await cloudStorageManager.uploadToService(
            service,
            fileURL: url,
            fileName: url.lastPathComponent
        )

        // Update claim with upload information
        await claimTrackingService.recordCorrespondence(
            for: claim,
            direction: .outgoing,
            type: .portal,
            subject: "Claim uploaded to \(service.name)",
            content: "Upload URL: \(uploadURL)"
        )

        await completeClaimCreation(claim: claim)
    }

    public func handleEmailResult(_ result: Result<Void, EmailError>) async {
        switch result {
        case .success:
            if let claim = currentClaim {
                await claimTrackingService.updateClaimStatus(
                    claim,
                    newStatus: .submitted,
                    notes: "Sent via email to \(recipientEmail)"
                )
                await completeClaimCreation(claim: claim)
            }

        case let .failure(error):
            processingError = error
            showingError = true
        }

        showingEmailComposer = false
    }

    private func completeClaimCreation(claim: ClaimSubmission) async {
        // Update claim status
        await claimTrackingService.updateClaimStatus(
            claim,
            newStatus: submissionMethod.requiresManualSubmission ? .preparing : .submitted,
            notes: "Claim package created successfully"
        )
    }

    // MARK: - Validation Helpers

    private func canSubmit() -> Bool {
        switch submissionMethod {
        case .email:
            !recipientEmail.isEmpty
        case .cloudUpload:
            selectedCloudService != nil
        default:
            true
        }
    }

    // MARK: - Reset

    public func reset() {
        selectedItems.removeAll()
        selectedCategories.removeAll()
        selectedRooms.removeAll()

        claimType = .other
        insuranceCompany = .generic
        submissionMethod = .email
        policyNumber = ""
        incidentDate = Date()
        incidentDescription = ""

        validationResults = nil
        showingValidation = false
        validationCompleted = false

        showingSubmissionOptions = false
        showingEmailComposer = false
        showingCloudUpload = false
        selectedCloudService = nil
        recipientEmail = ""

        isProcessing = false
        currentClaim = nil
        processingError = nil
        showingError = false

        currentStep = 1
    }
}

// MARK: - Supporting Types
// EmailError is imported from ClaimEmailService in Services layer

//
// Layer: Services
// Module: ClaimExport
// Purpose: Core coordination and business logic for claim export operations
//

import Foundation
import SwiftData
import MessageUI

// MARK: - Core Service Coordination

@MainActor
public final class ClaimExportCore: ObservableObject {
    // MARK: - Published Properties

    @Published public var isProcessing = false
    @Published public var processingProgress = 0.0
    @Published public var errorMessage: String?
    @Published public var activeSubmissions: [ClaimSubmission] = []

    // MARK: - Dependencies

    private let modelContext: ModelContext
    private let formatters: ClaimExportFormatters
    private let validators: ClaimExportValidators.Type

    // MARK: - Initialization

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.formatters = ClaimExportFormatters()
        self.validators = ClaimExportValidators.self
        loadActiveSubmissions()
    }

    // MARK: - Claim Creation and Export

    public func createClaim(
        items: [Item],
        categories: [Category],
        rooms: [Room],
        insuranceCompany: InsuranceCompanyFormat,
        claimType: InsuranceClaimType,
        submissionMethod: SubmissionMethod,
        policyNumber: String? = nil,
        incidentDate: Date? = nil
    ) async throws -> ClaimSubmission {
        isProcessing = true
        processingProgress = 0.0
        defer {
            isProcessing = false
            processingProgress = 1.0
        }

        // Create claim record
        let claim = ClaimSubmission(
            insuranceCompany: insuranceCompany.rawValue,
            claimType: claimType,
            submissionMethod: submissionMethod,
            exportFormat: insuranceCompany.fileExtension
        )

        claim.policyNumber = policyNumber
        claim.incidentDate = incidentDate
        claim.itemIds = items.map(\.id)
        claim.totalItemCount = items.count
        claim.totalClaimedValue = items.compactMap(\.purchasePrice).reduce(0, +)

        processingProgress = 0.2

        // Validate claim requirements
        try validators.validateClaimRequirements(
            items: items,
            format: insuranceCompany,
            requirements: .standard
        )

        processingProgress = 0.4

        // Export data in appropriate format
        let exportResult = try await formatters.exportClaimData(
            items: items,
            categories: categories,
            rooms: rooms,
            format: insuranceCompany,
            claim: claim
        )

        processingProgress = 0.8

        // Update claim with export results
        claim.exportedFileURL = exportResult.fileURL.path
        claim.fileSize = exportResult.fileSize

        // Save claim to database
        modelContext.insert(claim)
        try modelContext.save()

        // Add to active submissions
        activeSubmissions.append(claim)

        processingProgress = 1.0

        return claim
    }

    // MARK: - Submission Methods

    public func submitClaimViaEmail(
        claim: ClaimSubmission,
        recipientEmail _: String,
        subject: String? = nil,
        message: String? = nil
    ) async throws {
        guard let fileURL = claim.exportedFileURL,
              let url = URL(string: fileURL),
              FileManager.default.fileExists(atPath: url.path)
        else {
            throw ClaimExportError.fileNotFound
        }

        // Create email composition
        let emailSubject = subject ?? "Insurance Claim Submission - \(claim.claimType.rawValue)"
        let emailBody = message ?? formatters.generateDefaultEmailMessage(for: claim)

        // Record correspondence
        let correspondence = CorrespondenceRecord(
            type: .email,
            direction: .sent,
            subject: emailSubject,
            content: emailBody,
            attachments: [url.lastPathComponent]
        )

        claim.correspondenceHistory.append(correspondence)
        claim.status = .submitted
        claim.submissionDate = Date()
        claim.updatedAt = Date()

        try modelContext.save()

        // Note: Actual email sending would require MFMailComposeViewController
        // For now, we'll prepare the data and mark as submitted
    }

    public func uploadToCloudStorage(
        claim: ClaimSubmission,
        service: any CloudStorageService
    ) async throws -> String {
        guard let fileURL = claim.exportedFileURL,
              let url = URL(string: fileURL)
        else {
            throw ClaimExportError.fileNotFound
        }

        let fileName = "\(claim.insuranceCompany)_Claim_\(claim.id.uuidString.prefix(8)).zip"

        // Upload file (simplified - would integrate with actual cloud service)
        let uploadURL = try await service.upload(fileURL: url, fileName: fileName)

        // Record correspondence
        let correspondence = CorrespondenceRecord(
            type: .portal,
            direction: .sent,
            subject: "Claim uploaded to \(service.name)",
            content: "File uploaded: \(fileName)\nUpload URL: \(uploadURL)"
        )

        claim.correspondenceHistory.append(correspondence)
        claim.status = .submitted
        claim.submissionDate = Date()
        claim.confirmationNumber = String(uploadURL.hashValue)
        claim.updatedAt = Date()

        try modelContext.save()

        return uploadURL
    }

    // MARK: - Status Tracking

    public func updateClaimStatus(
        claim: ClaimSubmission,
        newStatus: ClaimStatus,
        notes: String? = nil
    ) {
        claim.status = newStatus
        claim.updatedAt = Date()

        if let notes {
            claim.notes += "\n\(DateUtils.shortDateFormatter.string(from: Date())): \(notes)"
        }

        // Add correspondence record for status change
        let correspondence = CorrespondenceRecord(
            type: .portal,
            direction: .received,
            subject: "Claim Status Update",
            content: "Status changed to: \(newStatus.rawValue)\nNotes: \(notes ?? "")"
        )

        claim.correspondenceHistory.append(correspondence)

        try? modelContext.save()
    }

    public func addCorrespondence(
        to claim: ClaimSubmission,
        correspondence: CorrespondenceRecord
    ) {
        claim.correspondenceHistory.append(correspondence)
        claim.updatedAt = Date()
        try? modelContext.save()
    }

    // MARK: - Validation Operations

    public func validateItemsForClaim(_ items: [Item]) -> [ExportValidationIssue] {
        validators.validateItems(items)
    }

    public func validateForFormat(
        items: [Item],
        format: InsuranceCompanyFormat
    ) -> [ExportValidationIssue] {
        validators.validateForFormat(items: items, format: format)
    }

    // MARK: - Data Loading

    private func loadActiveSubmissions() {
        // SwiftData Predicate macro requires simpler expressions
        // Using rawValue comparison for enum types
        let closedRawValue = ClaimStatus.closed.rawValue
        let settledRawValue = ClaimStatus.settled.rawValue
        
        let descriptor = FetchDescriptor<ClaimSubmission>(
            predicate: #Predicate<ClaimSubmission> { submission in
                submission.status.rawValue != closedRawValue && submission.status.rawValue != settledRawValue
            },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        do {
            activeSubmissions = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Failed to load claim submissions: \(error.localizedDescription)"
        }
    }

    // MARK: - Utility Methods

    public func refreshActiveSubmissions() {
        loadActiveSubmissions()
    }

    public func getSubmission(by id: UUID) -> ClaimSubmission? {
        activeSubmissions.first { $0.id == id }
    }

    public func deleteSubmission(_ submission: ClaimSubmission) {
        modelContext.delete(submission)
        try? modelContext.save()
        loadActiveSubmissions()
    }
}

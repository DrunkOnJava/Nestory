//
// Layer: Services
// Module: ClaimExport
// Purpose: Facade service for comprehensive claim export and submission system
//

import Foundation
import SwiftData

// Re-export modular components for backward compatibility
@_exported import ClaimExportModels
@_exported import ClaimExportCore
@_exported import ClaimExportFormatters
@_exported import ClaimExportValidators

// MARK: - Service Facade

@MainActor
public final class ClaimExportService: ObservableObject {
    // MARK: - Dependencies

    private let core: ClaimExportCore

    // MARK: - Initialization

    public init(modelContext: ModelContext) {
        self.core = ClaimExportCore(modelContext: modelContext)
    }

    // MARK: - Published Properties (Delegated)

    public var isProcessing: Bool { core.isProcessing }
    public var processingProgress: Double { core.processingProgress }
    public var errorMessage: String? { core.errorMessage }
    public var activeSubmissions: [ClaimSubmission] { core.activeSubmissions }

    // MARK: - Main Functions (Delegated)

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
        try await core.createClaim(
            items: items,
            categories: categories,
            rooms: rooms,
            insuranceCompany: insuranceCompany,
            claimType: claimType,
            submissionMethod: submissionMethod,
            policyNumber: policyNumber,
            incidentDate: incidentDate
        )
    }

    public func submitClaimViaEmail(
        claim: ClaimSubmission,
        recipientEmail: String,
        subject: String? = nil,
        message: String? = nil
    ) async throws {
        try await core.submitClaimViaEmail(
            claim: claim,
            recipientEmail: recipientEmail,
            subject: subject,
            message: message
        )
    }

    public func uploadToCloudStorage(
        claim: ClaimSubmission,
        service: CloudStorageService
    ) async throws -> String {
        try await core.uploadToCloudStorage(claim: claim, service: service)
    }

    // MARK: - Status Tracking (Delegated)

    public func updateClaimStatus(
        claim: ClaimSubmission,
        newStatus: ClaimStatus,
        notes: String? = nil
    ) {
        core.updateClaimStatus(claim: claim, newStatus: newStatus, notes: notes)
    }

    public func addCorrespondence(
        to claim: ClaimSubmission,
        correspondence: CorrespondenceRecord
    ) {
        core.addCorrespondence(to: claim, correspondence: correspondence)
    }

    // MARK: - Validation Functions (Delegated)

    public func validateItemsForClaim(_ items: [Item]) -> [ValidationIssue] {
        core.validateItemsForClaim(items)
    }

    public func validateForFormat(
        items: [Item],
        format: InsuranceCompanyFormat
    ) -> [ValidationIssue] {
        core.validateForFormat(items: items, format: format)
    }

    // MARK: - Utility Functions (Delegated)

    public func refreshActiveSubmissions() {
        core.refreshActiveSubmissions()
    }

    public func getSubmission(by id: UUID) -> ClaimSubmission? {
        core.getSubmission(by: id)
    }

    public func deleteSubmission(_ submission: ClaimSubmission) {
        core.deleteSubmission(submission)
    }
}

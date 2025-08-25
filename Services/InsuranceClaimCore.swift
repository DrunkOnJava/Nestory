//
// Layer: Services
// Module: InsuranceClaimCore
// Purpose: Core service coordination for insurance claim generation
//

import Foundation
import SwiftData

@MainActor
public final class InsuranceClaimCore: ObservableObject {
    // MARK: - Published Properties

    @Published public var isGenerating = false
    @Published public var generatedClaims: [GeneratedClaim] = []

    // MARK: - Dependencies

    private let documentGenerator: ClaimDocumentGenerator
    private let templateManager: ClaimTemplateManager
    private let trackingService: ClaimTrackingService

    // MARK: - Initialization

    public init(modelContext: ModelContext) {
        self.documentGenerator = ClaimDocumentGenerator()
        self.templateManager = ClaimTemplateManager()
        self.trackingService = ClaimTrackingService(modelContext: modelContext)
    }

    // MARK: - Claim Generation

    public func generateClaim(for request: ClaimRequest) async throws -> GeneratedClaim {
        guard !request.items.isEmpty else {
            throw ClaimError.noItemsSelected
        }

        isGenerating = true
        defer { isGenerating = false }

        // Validate request
        try InsuranceClaimValidator.validateClaimRequest(request)

        // Get template for insurance company
        let template = try templateManager.getTemplate(
            for: request.insuranceCompany,
            claimType: request.claimType
        )

        // Generate document data
        let documentData = try await documentGenerator.generateDocument(
            request: request,
            template: template
        )

        // Generate filename
        let filename = InsuranceClaimValidator.generateFilename(for: request)

        // Generate checklist and instructions
        let checklist = InsuranceClaimValidator.generateChecklist(for: request)
        let instructions = InsuranceClaimValidator.generateSubmissionInstructions(for: request)

        // Create generated claim
        let generatedClaim = GeneratedClaim(
            request: request,
            documentData: documentData,
            filename: filename,
            format: request.format,
            checklistItems: checklist,
            submissionInstructions: instructions
        )

        // Store in generated claims
        generatedClaims.append(generatedClaim)

        // Track the claim if tracking service is available
        try await trackingService.trackClaim(generatedClaim)

        return generatedClaim
    }

    // MARK: - Claim Management

    public func getClaim(by id: UUID) -> GeneratedClaim? {
        generatedClaims.first { $0.id == id }
    }

    public func removeClaim(by id: UUID) {
        generatedClaims.removeAll { $0.id == id }
    }

    public func exportClaim(_ claim: GeneratedClaim) async throws -> URL {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(claim.filename)
        try claim.documentData.write(to: tempURL)
        return tempURL
    }

    public func createHTMLPackage(for claim: GeneratedClaim) async throws -> URL {
        // Create temporary directory for package
        let packageURL = FileManager.default.temporaryDirectory.appendingPathComponent(claim.filename + "_package")
        try FileManager.default.createDirectory(at: packageURL, withIntermediateDirectories: true)

        // Write main HTML document
        let htmlURL = packageURL.appendingPathComponent("claim_document.html")
        try claim.documentData.write(to: htmlURL)

        // Create images directory and copy photos
        let imagesURL = packageURL.appendingPathComponent("images")
        try FileManager.default.createDirectory(at: imagesURL, withIntermediateDirectories: true)

        for (index, item) in claim.request.items.enumerated() {
            if let imageData = item.imageData {
                let imageURL = imagesURL.appendingPathComponent("item_\(index)_\(item.id.uuidString).jpg")
                try imageData.write(to: imageURL)
            }
        }

        return packageURL
    }

    // MARK: - Claim Tracking Integration

    public func getClaimStatus(_ claimId: UUID) async throws -> ClaimStatus {
        // Note: This would need to be implemented based on available tracking service methods
        // For now, return a default status
        return .submitted
    }

    public func updateClaimStatus(
        _ claimId: UUID,
        status: ClaimStatus,
        notes: String? = nil
    ) async throws {
        // Note: This would need to be implemented based on available tracking service methods
        // For now, this is a placeholder implementation
        // The trackingService has updateClaimStatus method that takes different parameters
    }

    // MARK: - Utility Functions (Delegated)

    public func getSupportedCompanies(for claimType: ClaimType) -> [InsuranceCompany] {
        InsuranceClaimValidator.getSupportedCompanies(for: claimType)
    }

    public func getRequiredDocumentation(for claimType: ClaimType) -> [String] {
        InsuranceClaimValidator.getRequiredDocumentation(for: claimType)
    }

    public func estimateClaimValue(items: [Item]) -> Decimal {
        InsuranceClaimValidator.estimateClaimValue(items: items)
    }

    public func validateItemsForClaim(items: [Item]) -> [String] {
        InsuranceClaimValidator.validateItemsForClaim(items: items)
    }
}

// MARK: - Supporting Types

// ClaimStatus is defined in ClaimExport/ClaimExportModels.swift

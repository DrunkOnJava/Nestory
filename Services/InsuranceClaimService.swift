//
// Layer: Services
// Module: Insurance
// Purpose: Facade service for generating insurance claim documents
//

import Foundation
import SwiftData
import SwiftUI

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with PDFKit - Advanced PDF form field population
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with MessageUI - Direct email integration for claim submission
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with QuickLook - Preview claim documents before submission

// MARK: - InsuranceClaimService Protocol

@MainActor
public protocol InsuranceClaimService: Sendable {
    var isGenerating: Bool { get }
    
    func generateClaim(for request: ClaimRequest) async throws -> GeneratedClaim
    func getClaim(by id: UUID) async -> GeneratedClaim?
    func exportClaim(_ claim: GeneratedClaim, includePhotos: Bool) async throws -> URL
    func validateItemsForClaim(items: [Item]) -> [String]
    func estimateClaimValue(items: [Item]) -> Decimal
}

// MARK: - Live Implementation

@MainActor
public final class LiveInsuranceClaimService: InsuranceClaimService, ObservableObject {
    // MARK: - Dependencies

    private let core: InsuranceClaimCore

    // MARK: - Initialization

    public init(modelContext: ModelContext) {
        self.core = InsuranceClaimCore(modelContext: modelContext)
    }

    // Convenience initializer for compatibility
    public convenience init() {
        // Create a temporary in-memory context for backward compatibility
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Item.self, configurations: config)
        let context = ModelContext(container)
        self.init(modelContext: context)
    }

    // MARK: - Published Properties (Delegated)

    public var isGenerating: Bool { core.isGenerating }
    public var generatedClaims: [GeneratedClaim] { core.generatedClaims }

    // MARK: - Main Functions (Delegated)

    public func generateClaim(for request: ClaimRequest) async throws -> GeneratedClaim {
        try await core.generateClaim(for: request)
    }

    public func getClaim(by id: UUID) async -> GeneratedClaim? {
        core.getClaim(by: id)
    }

    public func removeClaim(by id: UUID) {
        core.removeClaim(by: id)
    }

    public func exportClaim(_ claim: GeneratedClaim, includePhotos: Bool = true) async throws -> URL {
        try await core.exportClaim(claim, includePhotos: includePhotos)
    }

    public func createHTMLPackage(for claim: GeneratedClaim) async throws -> URL {
        try await core.createHTMLPackage(for: claim)
    }

    // MARK: - Claim Tracking (Delegated)

    public func getClaimStatus(_ claimId: UUID) async throws -> ClaimStatus {
        try await core.getClaimStatus(claimId)
    }

    public func updateClaimStatus(
        _ claimId: UUID,
        status: ClaimStatus,
        notes: String? = nil
    ) async throws {
        try await core.updateClaimStatus(claimId, status: status, notes: notes)
    }

    // MARK: - Utility Functions (Delegated)

    public func getSupportedCompanies(for claimType: ClaimType) -> [InsuranceCompany] {
        core.getSupportedCompanies(for: claimType)
    }

    public func getRequiredDocumentation(for claimType: ClaimType) -> [String] {
        core.getRequiredDocumentation(for: claimType)
    }

    public func estimateClaimValue(items: [Item]) -> Decimal {
        core.estimateClaimValue(items: items)
    }

    public func validateItemsForClaim(items: [Item]) -> [String] {
        core.validateItemsForClaim(items: items)
    }
}

// MARK: - Re-exported Types for Backward Compatibility
// Types are directly available since InsuranceClaimModels.swift is in the same Services module

// MARK: - Array Extension for Chunking

extension Array {
    private func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

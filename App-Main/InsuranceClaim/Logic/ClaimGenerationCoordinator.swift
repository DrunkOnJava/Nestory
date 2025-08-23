//
// Layer: App-Main
// Module: InsuranceClaim/Logic
// Purpose: Coordinates claim generation process with service integration
//

import Foundation
import ComposableArchitecture

@MainActor
public struct ClaimGenerationCoordinator {
    @Dependency(\.insuranceClaimService) var claimService
    
    public init() {}
    
    // MARK: - Generation Methods
    
    public func generateClaim(
        from data: ClaimFormData,
        items: [Item]
    ) async throws -> GeneratedClaim {
        let contactInfo = ClaimContactInfo(
            name: data.contactName,
            phone: data.contactPhone,
            email: data.contactEmail,
            address: data.contactAddress,
            emergencyContact: data.emergencyContact.isEmpty ? nil : data.emergencyContact
        )

        let request = ClaimRequest(
            claimType: data.selectedClaimType,
            insuranceCompany: data.selectedCompany,
            items: items,
            incidentDate: data.incidentDate,
            incidentDescription: data.incidentDescription,
            policyNumber: data.policyNumber.isEmpty ? nil : data.policyNumber,
            claimNumber: data.claimNumber.isEmpty ? nil : data.claimNumber,
            contactInfo: contactInfo,
            estimatedTotalLoss: estimateClaimValue(items: items)
        )

        return try await claimService.generateClaim(for: request)
    }
    
    // MARK: - Validation Methods
    
    public func validateItemsForClaim(items: [Item]) -> [String]? {
        return claimService.validateItemsForClaim(items: items)
    }
    
    public func estimateClaimValue(items: [Item]) -> Decimal {
        return claimService.estimateClaimValue(items: items)
    }
    
    // MARK: - Status Methods
    
    public var isGenerating: Bool {
        return claimService.isGenerating
    }
    
    // MARK: - Formatting Helpers
    
    public func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    public func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$\(amount)"
    }
}
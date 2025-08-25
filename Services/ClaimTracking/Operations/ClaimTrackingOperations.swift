//
// Layer: Services
// Module: ClaimTracking/Operations
// Purpose: Core claim tracking operations and status management
//

import Foundation
import SwiftData

/// Handles core claim tracking operations including status updates and data persistence
public struct ClaimTrackingOperations {
    
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Claim Tracking
    
    /// Track a newly generated claim by creating a submission record
    @MainActor 
    public func trackClaim(_ claim: GeneratedClaim) async throws {
        // Create a ClaimSubmission record for tracking
        let submission = ClaimSubmission(
            insuranceCompany: claim.request.insuranceCompany.rawValue,
            claimType: InsuranceClaimType(rawValue: claim.request.claimType.rawValue) ?? .fire,
            submissionMethod: .onlinePortal,
            exportFormat: claim.format.rawValue
        )
        
        // Set additional properties
        submission.itemIds = claim.request.items.map { $0.id }
        submission.totalItemCount = claim.request.items.count
        submission.totalClaimedValue = claim.request.estimatedTotalLoss
        submission.incidentDate = claim.request.incidentDate
        submission.notes = "Generated Claim ID: \(claim.id)\nIncident: \(claim.request.incidentDescription)"
        submission.policyNumber = claim.request.policyNumber
        submission.claimNumber = claim.request.claimNumber
        
        modelContext.insert(submission)
        try modelContext.save()
        
        // Record initial activity
        let activity = ClaimActivity(
            claimId: submission.id,
            type: .statusUpdate,
            description: "Claim generated and ready for submission",
            timestamp: Date(),
            details: [
                "generatedClaimId": claim.id.uuidString,
                "itemCount": String(claim.request.items.count),
                "totalValue": claim.request.estimatedTotalLoss.description
            ]
        )
        
        try await recordActivity(activity)
    }
    
    // MARK: - Status Management
    
    @MainActor
    public func updateClaimStatus(
        _ claim: ClaimSubmission,
        newStatus: ClaimStatus,
        notes: String? = nil,
        confirmationNumber: String? = nil
    ) async throws {
        let oldStatus = claim.status
        claim.status = newStatus
        claim.updatedAt = Date()

        if let notes {
            addNoteToClaimHistory(claim, note: notes)
        }

        if let confirmationNumber {
            claim.confirmationNumber = confirmationNumber
        }

        // Record the status change
        let activity = ClaimActivity(
            claimId: claim.id,
            type: .statusUpdate,
            description: "Status changed from \(oldStatus.rawValue) to \(newStatus.rawValue)",
            timestamp: Date(),
            details: [
                "oldStatus": oldStatus.rawValue,
                "newStatus": newStatus.rawValue,
                "confirmationNumber": confirmationNumber ?? "",
                "notes": notes ?? ""
            ]
        )

        try await recordActivity(activity)
        try modelContext.save()
    }
    
    // MARK: - Data Queries
    
    public func getActiveClaims() -> [ClaimSubmission] {
        let activeStatuses: [ClaimStatus] = [.draft, .submitted, .acknowledged, .underReview, .pendingDocuments, .scheduledInspection]
        
        let descriptor = FetchDescriptor<ClaimSubmission>(
            predicate: #Predicate<ClaimSubmission> { claim in
                activeStatuses.contains(claim.status)
            },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    public func getAllClaims() -> [ClaimSubmission] {
        let descriptor = FetchDescriptor<ClaimSubmission>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    public func getRecentActivity(limit: Int = 50) -> [ClaimActivity] {
        var descriptor = FetchDescriptor<ClaimActivity>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    public func getClaimActivities(for claimId: UUID) -> [ClaimActivity] {
        let descriptor = FetchDescriptor<ClaimActivity>(
            predicate: #Predicate<ClaimActivity> { activity in
                activity.claimId == claimId
            },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // MARK: - Activity Recording
    
    @MainActor
    public func recordActivity(_ activity: ClaimActivity) async throws {
        modelContext.insert(activity)
        try modelContext.save()
    }
    
    @MainActor
    public func recordCorrespondence(
        for claimId: UUID,
        direction: CorrespondenceDirection,
        type: CorrespondenceType,
        subject: String,
        content: String? = nil
    ) async throws {
        let activity = ClaimActivity(
            claimId: claimId,
            type: .correspondence,
            description: "\(direction.rawValue) \(type.rawValue): \(subject)",
            timestamp: Date(),
            details: [
                "direction": direction.rawValue,
                "type": type.rawValue,
                "subject": subject,
                "content": content ?? ""
            ]
        )
        
        try await recordActivity(activity)
    }
    
    @MainActor
    public func recordDocumentAddition(
        for claimId: UUID,
        documentName: String,
        documentType: String? = nil
    ) async throws {
        let activity = ClaimActivity(
            claimId: claimId,
            type: .documentAdded,
            description: "Document added: \(documentName)",
            timestamp: Date(),
            details: [
                "documentName": documentName,
                "documentType": documentType ?? "Unknown"
            ]
        )
        
        try await recordActivity(activity)
    }
    
    // MARK: - Helper Methods
    
    private func addNoteToClaimHistory(_ claim: ClaimSubmission, note: String) {
        let timestamp = DateUtils.shortDateFormatter.string(from: Date())
        claim.notes += "\n\(timestamp): \(note)"
    }
}

// MARK: - Supporting Extensions
// DateFormatter.shortDateFormatter is defined in Foundation/Utils/DateUtils.swift
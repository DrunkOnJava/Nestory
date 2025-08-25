//
// Layer: Services
// Module: ClaimTracking
// Purpose: Track claim submissions, status updates, and manage follow-up actions
//

import Foundation
import SwiftData
import UserNotifications

// MARK: - Claim Tracking Service

@MainActor
public final class ClaimTrackingService: ObservableObject {
    @Published public var activeClaims: [ClaimSubmission] = []
    @Published public var recentActivity: [ClaimActivity] = []
    @Published public var pendingFollowUps: [FollowUpAction] = []
    @Published public var isLoading = false

    private let modelContext: ModelContext
    private let notificationService: NotificationService?

    public init(modelContext: ModelContext, notificationService: NotificationService? = nil) {
        self.modelContext = modelContext
        self.notificationService = notificationService
        loadActiveClaims()
        loadRecentActivity()
        loadPendingFollowUps()
    }

    // MARK: - Claim Tracking
    
    /// Track a newly generated claim by creating a submission record
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
        
        await recordActivity(activity)
        await refreshData()
    }

    // MARK: - Claim Status Management

    public func updateClaimStatus(
        _ claim: ClaimSubmission,
        newStatus: ClaimStatus,
        notes: String? = nil,
        confirmationNumber: String? = nil
    ) async {
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
                "notes": notes ?? "",
            ]
        )

        await recordActivity(activity)

        // Create follow-up actions based on status
        await createFollowUpActions(for: claim, status: newStatus)

        // Send notification for important status changes
        await sendStatusUpdateNotification(claim: claim, oldStatus: oldStatus, newStatus: newStatus)

        try? modelContext.save()
        await refreshData()
    }

    public func addCorrespondence(
        to claim: ClaimSubmission,
        type: CorrespondenceType,
        direction: CommunicationDirection,
        subject: String,
        content: String,
        attachments: [String] = []
    ) async {
        let correspondence = CorrespondenceRecord(
            type: type,
            direction: direction,
            subject: subject,
            content: content,
            attachments: attachments
        )

        claim.correspondenceHistory.append(correspondence)
        claim.updatedAt = Date()

        let activity = ClaimActivity(
            claimId: claim.id,
            type: .correspondence,
            description: "\(direction.rawValue) \(type.rawValue): \(subject)",
            timestamp: Date(),
            details: [
                "type": type.rawValue,
                "direction": direction.rawValue,
                "subject": subject,
                "hasAttachments": String(!attachments.isEmpty),
            ]
        )

        await recordActivity(activity)

        try? modelContext.save()
        await refreshData()
    }

    // MARK: - Follow-Up Management

    public func createFollowUp(
        for claim: ClaimSubmission,
        action: FollowUpActionType,
        dueDate: Date,
        description: String
    ) async {
        let followUp = FollowUpAction(
            claimId: claim.id,
            actionType: action,
            description: description,
            dueDate: dueDate,
            createdAt: Date()
        )

        modelContext.insert(followUp)

        // Schedule notification
        await scheduleFollowUpNotification(followUp)

        let activity = ClaimActivity(
            claimId: claim.id,
            type: .followUpCreated,
            description: "Follow-up created: \(description)",
            timestamp: Date(),
            details: [
                "actionType": action.rawValue,
                "dueDate": ISO8601DateFormatter().string(from: dueDate),
            ]
        )

        await recordActivity(activity)

        try? modelContext.save()
        await refreshData()
    }

    public func completeFollowUp(_ followUp: FollowUpAction, notes: String? = nil) async {
        followUp.isCompleted = true
        followUp.completedAt = Date()
        followUp.completionNotes = notes

        let activity = ClaimActivity(
            claimId: followUp.claimId,
            type: .followUpCompleted,
            description: "Follow-up completed: \(followUp.actionDescription)",
            timestamp: Date(),
            details: [
                "actionType": followUp.actionType.rawValue,
                "notes": notes ?? "",
            ]
        )

        await recordActivity(activity)

        try? modelContext.save()
        await refreshData()
    }

    // MARK: - Claim Timeline

    public func getClaimTimeline(for claim: ClaimSubmission) -> [TimelineEvent] {
        var timeline: [TimelineEvent] = []

        // Add claim creation
        timeline.append(TimelineEvent(
            date: claim.createdAt,
            type: .claimCreated,
            title: "Claim Created",
            description: "Claim for \(claim.claimType.rawValue) created",
            status: nil
        ))

        // Add submission
        if let submissionDate = claim.submissionDate {
            timeline.append(TimelineEvent(
                date: submissionDate,
                type: .submitted,
                title: "Claim Submitted",
                description: "Submitted via \(claim.submissionMethod.rawValue)",
                status: .submitted
            ))
        }

        // Add correspondence
        for correspondence in claim.correspondenceHistory {
            timeline.append(TimelineEvent(
                date: correspondence.date,
                type: .correspondence,
                title: "\(correspondence.direction.rawValue) \(correspondence.type.rawValue)",
                description: correspondence.subject,
                status: nil
            ))
        }

        // Add status changes from activity log
        let statusActivities = recentActivity.filter {
            $0.claimId == claim.id && $0.type == .statusUpdate
        }

        for activity in statusActivities {
            if let newStatusString = activity.details?["newStatus"],
               let newStatus = ClaimStatus(rawValue: newStatusString)
            {
                timeline.append(TimelineEvent(
                    date: activity.timestamp,
                    type: .statusChanged,
                    title: "Status Updated",
                    description: "Changed to \(newStatus.rawValue)",
                    status: newStatus
                ))
            }
        }

        return timeline.sorted { $0.date < $1.date }
    }

    // MARK: - Analytics and Insights

    public func getClaimAnalytics() -> ClaimAnalytics {
        let allClaims = getAllClaims()

        let statusDistribution = Dictionary(grouping: allClaims) { $0.status }
            .mapValues { $0.count }

        let typeDistribution = Dictionary(grouping: allClaims) { $0.claimType.rawValue }
            .mapValues { $0.count }

        let averageProcessingTime = calculateAverageProcessingTime(allClaims)

        let totalClaimValue = allClaims.reduce(0) { $0 + $1.totalClaimedValue }

        let submissionMethodDistribution = Dictionary(grouping: allClaims) { $0.submissionMethod }
            .mapValues { $0.count }

        return ClaimAnalytics(
            totalClaims: allClaims.count,
            activeClaims: activeClaims.count,
            statusDistribution: statusDistribution,
            typeDistribution: typeDistribution,
            averageProcessingDays: averageProcessingTime,
            totalClaimValue: totalClaimValue,
            submissionMethodDistribution: submissionMethodDistribution,
            successRate: calculateSuccessRate(allClaims)
        )
    }

    // MARK: - Notification Management

    private func sendStatusUpdateNotification(
        claim: ClaimSubmission,
        oldStatus _: ClaimStatus,
        newStatus: ClaimStatus
    ) async {
        guard let notificationService else { return }

        // Only send notifications for significant status changes
        let significantStatuses: [ClaimStatus] = [.acknowledged, .approved, .denied, .settled]
        guard significantStatuses.contains(newStatus) else { return }

        let title = "Claim Status Update"
        let body = "Your \(claim.claimType.rawValue) claim status changed to \(newStatus.rawValue)"

        // TODO: Add general notification scheduling to NotificationService protocol
        // await notificationService.scheduleNotification(
        //     title: title,
        //     body: body,
        //     identifier: "claim-status-\(claim.id.uuidString)",
        //     delay: 1
        // )
    }

    private func scheduleFollowUpNotification(_ followUp: FollowUpAction) async {
        guard let notificationService else { return }

        let title = "Claim Follow-up Due"
        let body = followUp.actionDescription
        let timeInterval = followUp.dueDate.timeIntervalSinceNow

        if timeInterval > 0 {
            // TODO: Add general notification scheduling to NotificationService protocol
            // await notificationService.scheduleNotification(
            //     title: title,
            //     body: body,
            //     identifier: "followup-\(followUp.id.uuidString)",
            //     delay: timeInterval
            // )
        }
    }

    // MARK: - Data Loading and Management

    private func loadActiveClaims() {
        let descriptor = FetchDescriptor<ClaimSubmission>(
            predicate: #Predicate<ClaimSubmission> { submission in
                submission.status.rawValue != "closed" && submission.status.rawValue != "settled"
            },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        do {
            activeClaims = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load active claims: \(error)")
        }
    }

    private func getAllClaims() -> [ClaimSubmission] {
        let descriptor = FetchDescriptor<ClaimSubmission>()

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load all claims: \(error)")
            return []
        }
    }

    private func loadRecentActivity() {
        let descriptor = FetchDescriptor<ClaimActivity>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            let allActivities = try modelContext.fetch(descriptor)
            recentActivity = Array(allActivities.prefix(50)) // Limit to recent 50 activities
        } catch {
            print("Failed to load recent activity: \(error)")
        }
    }

    private func loadPendingFollowUps() {
        let descriptor = FetchDescriptor<FollowUpAction>(
            predicate: #Predicate<FollowUpAction> { action in
                !action.isCompleted
            },
            sortBy: [SortDescriptor(\.dueDate, order: .forward)]
        )

        do {
            pendingFollowUps = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load pending follow-ups: \(error)")
        }
    }

    private func refreshData() async {
        loadActiveClaims()
        loadRecentActivity()
        loadPendingFollowUps()
    }

    private func recordActivity(_ activity: ClaimActivity) async {
        modelContext.insert(activity)
        try? modelContext.save()
    }

    private func addNoteToClaimHistory(_ claim: ClaimSubmission, note: String) {
        let timestamp = DateFormatter.shortDateFormatter.string(from: Date())
        claim.notes += "\n\(timestamp): \(note)"
    }

    private func createFollowUpActions(for claim: ClaimSubmission, status: ClaimStatus) async {
        switch status {
        case .submitted:
            await createFollowUp(
                for: claim,
                action: .checkAcknowledgment,
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                description: "Check if claim has been acknowledged"
            )

        case .acknowledged:
            await createFollowUp(
                for: claim,
                action: .followUpProgress,
                dueDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date(),
                description: "Follow up on claim processing progress"
            )

        case .underReview:
            await createFollowUp(
                for: claim,
                action: .followUpProgress,
                dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                description: "Check review status and provide additional info if needed"
            )

        default:
            break
        }
    }

    // MARK: - Helper Methods

    private func calculateAverageProcessingTime(_ claims: [ClaimSubmission]) -> Double {
        let completedClaims = claims.filter {
            $0.status == .settled || $0.status == .denied || $0.status == .closed
        }

        guard !completedClaims.isEmpty else { return 0 }

        let totalDays = completedClaims.compactMap { claim -> Double? in
            guard let submissionDate = claim.submissionDate else { return nil }
            return claim.updatedAt.timeIntervalSince(submissionDate) / (24 * 60 * 60)
        }.reduce(0, +)

        return totalDays / Double(completedClaims.count)
    }

    private func calculateSuccessRate(_ claims: [ClaimSubmission]) -> Double {
        let finalizedClaims = claims.filter {
            $0.status == .settled || $0.status == .denied || $0.status == .closed
        }

        guard !finalizedClaims.isEmpty else { return 0 }

        let approvedClaims = finalizedClaims.count(where: { $0.status == .settled })
        return Double(approvedClaims) / Double(finalizedClaims.count)
    }
}

// MARK: - Data Models

@Model
public final class ClaimActivity {
    public var id = UUID()
    var claimId: UUID
    var type: ClaimActivityType
    var activityDescription: String
    var timestamp: Date
    var details: [String: String]?

    public init(
        claimId: UUID,
        type: ClaimActivityType,
        description: String,
        timestamp: Date,
        details: [String: String]? = nil
    ) {
        self.claimId = claimId
        self.type = type
        self.activityDescription = description
        self.timestamp = timestamp
        self.details = details
    }
}

@Model
public final class FollowUpAction {
    public var id = UUID()
    var claimId: UUID
    var actionType: FollowUpActionType
    var actionDescription: String
    var dueDate: Date
    var createdAt: Date
    var isCompleted = false
    var completedAt: Date?
    var completionNotes: String?

    public init(
        claimId: UUID,
        actionType: FollowUpActionType,
        description: String,
        dueDate: Date,
        createdAt: Date
    ) {
        self.claimId = claimId
        self.actionType = actionType
        self.actionDescription = description
        self.dueDate = dueDate
        self.createdAt = createdAt
    }
}

public enum ClaimActivityType: String, CaseIterable, Codable {
    case statusUpdate = "Status Update"
    case correspondence = "Correspondence"
    case followUpCreated = "Follow-up Created"
    case followUpCompleted = "Follow-up Completed"
    case documentAdded = "Document Added"
    case paymentReceived = "Payment Received"
}

public enum FollowUpActionType: String, CaseIterable, Codable {
    case checkAcknowledgment = "Check Acknowledgment"
    case followUpProgress = "Follow Up Progress"
    case provideDocuments = "Provide Documents"
    case scheduleInspection = "Schedule Inspection"
    case reviewOffer = "Review Settlement Offer"
    case finalizePayment = "Finalize Payment"
    case closeFile = "Close File"
}

public struct TimelineEvent {
    public let date: Date
    public let type: TimelineEventType
    public let title: String
    public let description: String
    public let status: ClaimStatus?

    public init(
        date: Date,
        type: TimelineEventType,
        title: String,
        description: String,
        status: ClaimStatus? = nil
    ) {
        self.date = date
        self.type = type
        self.title = title
        self.description = description
        self.status = status
    }
}

public enum TimelineEventType: String, CaseIterable {
    case claimCreated = "Claim Created"
    case submitted = "Submitted"
    case statusChanged = "Status Changed"
    case correspondence = "Correspondence"
    case documentAdded = "Document Added"
    case inspection = "Inspection"
    case settlement = "Settlement"
}

public struct ClaimAnalytics {
    public let totalClaims: Int
    public let activeClaims: Int
    public let statusDistribution: [ClaimStatus: Int]
    public let typeDistribution: [String: Int]
    public let averageProcessingDays: Double
    public let totalClaimValue: Decimal
    public let submissionMethodDistribution: [SubmissionMethod: Int]
    public let successRate: Double

    public init(
        totalClaims: Int,
        activeClaims: Int,
        statusDistribution: [ClaimStatus: Int],
        typeDistribution: [String: Int],
        averageProcessingDays: Double,
        totalClaimValue: Decimal,
        submissionMethodDistribution: [SubmissionMethod: Int],
        successRate: Double
    ) {
        self.totalClaims = totalClaims
        self.activeClaims = activeClaims
        self.statusDistribution = statusDistribution
        self.typeDistribution = typeDistribution
        self.averageProcessingDays = averageProcessingDays
        self.totalClaimValue = totalClaimValue
        self.submissionMethodDistribution = submissionMethodDistribution
        self.successRate = successRate
    }
}

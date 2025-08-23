//
// Layer: Services
// Module: ClaimTracking/Models
// Purpose: Data models and types for claim tracking functionality
//

import Foundation
import SwiftData

// MARK: - SwiftData Models

@Model
public final class ClaimActivity {
    public var id = UUID()
    public var claimId: UUID
    public var type: ClaimActivityType
    public var activityDescription: String
    public var timestamp: Date
    public var details: [String: String]?

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
    public var claimId: UUID
    public var actionType: FollowUpActionType
    public var actionDescription: String
    public var dueDate: Date
    public var createdAt: Date
    public var isCompleted = false
    public var completedAt: Date?
    public var completionNotes: String?

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
    
    public var isOverdue: Bool {
        !isCompleted && dueDate < Date()
    }
}

// MARK: - Enumerations

public enum ClaimActivityType: String, CaseIterable, Codable, Sendable {
    case statusUpdate = "Status Update"
    case correspondence = "Correspondence"
    case followUpCreated = "Follow-up Created"
    case followUpCompleted = "Follow-up Completed"
    case documentAdded = "Document Added"
    case paymentReceived = "Payment Received"
    
    public var icon: String {
        switch self {
        case .statusUpdate: return "arrow.up.circle"
        case .correspondence: return "envelope"
        case .followUpCreated: return "calendar.badge.plus"
        case .followUpCompleted: return "checkmark.circle"
        case .documentAdded: return "doc.badge.plus"
        case .paymentReceived: return "dollarsign.circle"
        }
    }
}

public enum FollowUpActionType: String, CaseIterable, Codable, Sendable {
    case checkAcknowledgment = "Check Acknowledgment"
    case followUpProgress = "Follow Up Progress"
    case provideDocuments = "Provide Documents"
    case scheduleInspection = "Schedule Inspection"
    case reviewOffer = "Review Settlement Offer"
    case finalizePayment = "Finalize Payment"
    case closeFile = "Close File"
    
    public var priority: FollowUpPriority {
        switch self {
        case .checkAcknowledgment, .provideDocuments: return .high
        case .followUpProgress, .scheduleInspection: return .medium
        case .reviewOffer, .finalizePayment, .closeFile: return .low
        }
    }
    
    public var defaultDaysFromNow: Int {
        switch self {
        case .checkAcknowledgment: return 3
        case .followUpProgress: return 7
        case .provideDocuments: return 5
        case .scheduleInspection: return 10
        case .reviewOffer: return 14
        case .finalizePayment: return 7
        case .closeFile: return 1
        }
    }
}

public enum FollowUpPriority: String, CaseIterable, Sendable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    public var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "red"
        }
    }
}

public enum TimelineEventType: String, CaseIterable, Sendable {
    case claimCreated = "Claim Created"
    case submitted = "Submitted"
    case statusChanged = "Status Changed"
    case correspondence = "Correspondence"
    case documentAdded = "Document Added"
    case inspection = "Inspection"
    case settlement = "Settlement"
    
    public var icon: String {
        switch self {
        case .claimCreated: return "plus.circle"
        case .submitted: return "paperplane"
        case .statusChanged: return "arrow.triangle.2.circlepath"
        case .correspondence: return "envelope"
        case .documentAdded: return "doc.badge.plus"
        case .inspection: return "magnifyingglass"
        case .settlement: return "dollarsign.circle"
        }
    }
}

// MARK: - Value Types

public struct TimelineEvent: Identifiable, Sendable {
    public let id = UUID()
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

public struct ClaimAnalytics: Sendable {
    public let totalClaims: Int
    public let activeClaims: Int
    public let statusDistribution: [ClaimStatus: Int]
    public let typeDistribution: [String: Int]
    public let averageProcessingDays: Double
    public let totalClaimValue: Decimal
    public let submissionMethodDistribution: [SubmissionMethod: Int]
    public let successRate: Double
    
    // Computed properties for better insights
    public var mostCommonStatus: ClaimStatus? {
        statusDistribution.max(by: { $0.value < $1.value })?.key
    }
    
    public var mostCommonType: String? {
        typeDistribution.max(by: { $0.value < $1.value })?.key
    }
    
    public var preferredSubmissionMethod: SubmissionMethod? {
        submissionMethodDistribution.max(by: { $0.value < $1.value })?.key
    }

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
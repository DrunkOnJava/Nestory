//
// Layer: Services
// Module: ClaimTracking/Timeline
// Purpose: Timeline event creation and chronological tracking for claims
//

import Foundation

/// Manages timeline events and chronological tracking for insurance claims
public struct ClaimTimelineManager {
    
    private let operations: ClaimTrackingOperations
    
    public init(operations: ClaimTrackingOperations) {
        self.operations = operations
    }
    
    // MARK: - Timeline Generation
    
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
        let activities = operations.getClaimActivities(for: claim.id)
        let statusActivities = activities.filter { $0.type == .statusUpdate }
        
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
        
        // Add document additions
        let documentActivities = activities.filter { $0.type == .documentAdded }
        for activity in documentActivities {
            timeline.append(TimelineEvent(
                date: activity.timestamp,
                type: .documentAdded,
                title: "Document Added",
                description: activity.activityDescription,
                status: nil
            ))
        }
        
        return timeline.sorted { $0.date < $1.date }
    }
    
    // MARK: - Timeline Analysis
    
    public func analyzeTimeline(for claim: ClaimSubmission) -> TimelineAnalysis {
        let timeline = getClaimTimeline(for: claim)
        
        let totalDuration = calculateTotalDuration(timeline)
        let averageTimeBetweenEvents = calculateAverageTimeBetweenEvents(timeline)
        let statusChangeCount = timeline.filter { $0.type == .statusChanged }.count
        let correspondenceCount = timeline.filter { $0.type == .correspondence }.count
        let documentAdditionCount = timeline.filter { $0.type == .documentAdded }.count
        
        // Identify potential bottlenecks
        let bottlenecks = identifyBottlenecks(timeline)
        
        // Calculate processing phases
        let phases = calculateProcessingPhases(timeline)
        
        return TimelineAnalysis(
            totalEvents: timeline.count,
            totalDurationDays: totalDuration,
            averageTimeBetweenEventsDays: averageTimeBetweenEvents,
            statusChangeCount: statusChangeCount,
            correspondenceCount: correspondenceCount,
            documentAdditionCount: documentAdditionCount,
            bottlenecks: bottlenecks,
            processingPhases: phases
        )
    }
    
    // MARK: - Milestone Tracking
    
    public func getKeyMilestones(for claim: ClaimSubmission) -> [TimelineMilestone] {
        let timeline = getClaimTimeline(for: claim)
        var milestones: [TimelineMilestone] = []
        
        // Creation milestone
        if let creationEvent = timeline.first(where: { $0.type == .claimCreated }) {
            milestones.append(TimelineMilestone(
                name: "Claim Created",
                date: creationEvent.date,
                isCompleted: true,
                importance: .high
            ))
        }
        
        // Submission milestone
        if let submissionEvent = timeline.first(where: { $0.type == .submitted }) {
            milestones.append(TimelineMilestone(
                name: "Claim Submitted",
                date: submissionEvent.date,
                isCompleted: true,
                importance: .high
            ))
        } else {
            // Submission is pending
            milestones.append(TimelineMilestone(
                name: "Claim Submission",
                date: nil,
                isCompleted: false,
                importance: .high
            ))
        }
        
        // Acknowledgment milestone
        let acknowledgmentCompleted = timeline.contains { event in
            event.status == .acknowledged
        }
        
        if acknowledgmentCompleted {
            if let ackEvent = timeline.first(where: { $0.status == .acknowledged }) {
                milestones.append(TimelineMilestone(
                    name: "Claim Acknowledged",
                    date: ackEvent.date,
                    isCompleted: true,
                    importance: .medium
                ))
            }
        } else {
            milestones.append(TimelineMilestone(
                name: "Claim Acknowledgment",
                date: nil,
                isCompleted: false,
                importance: .medium
            ))
        }
        
        // Final resolution milestone
        let finalStatuses: [ClaimStatus] = [.settled, .denied, .closed]
        let isResolved = finalStatuses.contains(claim.status)
        
        if isResolved {
            milestones.append(TimelineMilestone(
                name: "Claim Resolved",
                date: claim.updatedAt,
                isCompleted: true,
                importance: .high
            ))
        } else {
            milestones.append(TimelineMilestone(
                name: "Claim Resolution",
                date: nil,
                isCompleted: false,
                importance: .high
            ))
        }
        
        return milestones
    }
    
    // MARK: - Private Helper Methods
    
    private func calculateTotalDuration(_ timeline: [TimelineEvent]) -> Double {
        guard let firstEvent = timeline.first,
              let lastEvent = timeline.last else { return 0 }
        
        return lastEvent.date.timeIntervalSince(firstEvent.date) / (24 * 60 * 60) // Convert to days
    }
    
    private func calculateAverageTimeBetweenEvents(_ timeline: [TimelineEvent]) -> Double {
        guard timeline.count > 1 else { return 0 }
        
        let totalDuration = calculateTotalDuration(timeline)
        return totalDuration / Double(timeline.count - 1)
    }
    
    private func identifyBottlenecks(_ timeline: [TimelineEvent]) -> [TimelineBottleneck] {
        var bottlenecks: [TimelineBottleneck] = []
        
        for i in 0..<timeline.count - 1 {
            let currentEvent = timeline[i]
            let nextEvent = timeline[i + 1]
            
            let daysBetween = nextEvent.date.timeIntervalSince(currentEvent.date) / (24 * 60 * 60)
            
            // Consider a gap of more than 14 days a potential bottleneck
            if daysBetween > 14 {
                bottlenecks.append(TimelineBottleneck(
                    fromEvent: currentEvent.type,
                    toEvent: nextEvent.type,
                    durationDays: daysBetween,
                    severity: daysBetween > 30 ? .high : .medium
                ))
            }
        }
        
        return bottlenecks
    }
    
    private func calculateProcessingPhases(_ timeline: [TimelineEvent]) -> [ProcessingPhase] {
        var phases: [ProcessingPhase] = []
        
        // Pre-submission phase
        let submissionEvent = timeline.first { $0.type == .submitted }
        if let submission = submissionEvent,
           let creation = timeline.first(where: { $0.type == .claimCreated }) {
            let duration = submission.date.timeIntervalSince(creation.date) / (24 * 60 * 60)
            phases.append(ProcessingPhase(
                name: "Pre-Submission",
                startDate: creation.date,
                endDate: submission.date,
                durationDays: duration,
                eventCount: timeline.filter { $0.date <= submission.date }.count
            ))
        }
        
        // Processing phase
        if let submission = submissionEvent {
            let endDate = timeline.last?.date ?? Date()
            let duration = endDate.timeIntervalSince(submission.date) / (24 * 60 * 60)
            phases.append(ProcessingPhase(
                name: "Processing",
                startDate: submission.date,
                endDate: endDate,
                durationDays: duration,
                eventCount: timeline.filter { $0.date > submission.date }.count
            ))
        }
        
        return phases
    }
}

// MARK: - Supporting Types

public struct TimelineAnalysis {
    public let totalEvents: Int
    public let totalDurationDays: Double
    public let averageTimeBetweenEventsDays: Double
    public let statusChangeCount: Int
    public let correspondenceCount: Int
    public let documentAdditionCount: Int
    public let bottlenecks: [TimelineBottleneck]
    public let processingPhases: [ProcessingPhase]
    
    public init(totalEvents: Int, totalDurationDays: Double, averageTimeBetweenEventsDays: Double, statusChangeCount: Int, correspondenceCount: Int, documentAdditionCount: Int, bottlenecks: [TimelineBottleneck], processingPhases: [ProcessingPhase]) {
        self.totalEvents = totalEvents
        self.totalDurationDays = totalDurationDays
        self.averageTimeBetweenEventsDays = averageTimeBetweenEventsDays
        self.statusChangeCount = statusChangeCount
        self.correspondenceCount = correspondenceCount
        self.documentAdditionCount = documentAdditionCount
        self.bottlenecks = bottlenecks
        self.processingPhases = processingPhases
    }
}

public struct TimelineMilestone {
    public let name: String
    public let date: Date?
    public let isCompleted: Bool
    public let importance: MilestoneImportance
    
    public init(name: String, date: Date?, isCompleted: Bool, importance: MilestoneImportance) {
        self.name = name
        self.date = date
        self.isCompleted = isCompleted
        self.importance = importance
    }
}

public enum MilestoneImportance: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

public struct TimelineBottleneck {
    public let fromEvent: TimelineEventType
    public let toEvent: TimelineEventType
    public let durationDays: Double
    public let severity: BottleneckSeverity
    
    public init(fromEvent: TimelineEventType, toEvent: TimelineEventType, durationDays: Double, severity: BottleneckSeverity) {
        self.fromEvent = fromEvent
        self.toEvent = toEvent
        self.durationDays = durationDays
        self.severity = severity
    }
}

public enum BottleneckSeverity: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

public struct ProcessingPhase {
    public let name: String
    public let startDate: Date
    public let endDate: Date
    public let durationDays: Double
    public let eventCount: Int
    
    public init(name: String, startDate: Date, endDate: Date, durationDays: Double, eventCount: Int) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.durationDays = durationDays
        self.eventCount = eventCount
    }
}
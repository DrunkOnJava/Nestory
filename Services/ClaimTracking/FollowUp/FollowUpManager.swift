//
// Layer: Services
// Module: ClaimTracking/FollowUp
// Purpose: Automated follow-up action creation and management for claims
//

import Foundation
import SwiftData
import UserNotifications

/// Manages follow-up actions and reminders for insurance claim tracking
public struct FollowUpManager {
    
    private let modelContext: ModelContext
    private let operations: ClaimTrackingOperations
    private let notificationService: NotificationService?
    
    public init(
        modelContext: ModelContext, 
        operations: ClaimTrackingOperations,
        notificationService: NotificationService? = nil
    ) {
        self.modelContext = modelContext
        self.operations = operations
        self.notificationService = notificationService
    }
    
    // MARK: - Follow-up Creation
    
    @MainActor
    public func createFollowUpActions(for claim: ClaimSubmission, status: ClaimStatus) async throws {
        switch status {
        case .submitted:
            try await createFollowUp(
                for: claim,
                action: .checkAcknowledgment,
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                description: "Check if claim has been acknowledged"
            )
            
        case .acknowledged:
            try await createFollowUp(
                for: claim,
                action: .followUpProgress,
                dueDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date(),
                description: "Follow up on claim processing progress"
            )
            
        case .underReview:
            try await createFollowUp(
                for: claim,
                action: .followUpProgress,
                dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                description: "Check review status and provide additional info if needed"
            )
            
        case .pendingDocuments:
            try await createFollowUp(
                for: claim,
                action: .provideDocuments,
                dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
                description: "Provide required documents for claim processing"
            )
            
        case .scheduledInspection:
            try await createFollowUp(
                for: claim,
                action: .scheduleInspection,
                dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                description: "Schedule inspection appointment"
            )
            
        case .settlementOffered:
            try await createFollowUp(
                for: claim,
                action: .reviewOffer,
                dueDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date(),
                description: "Review settlement offer and make decision"
            )
            
        default:
            break // No automatic follow-up for other statuses
        }
    }
    
    @MainActor
    public func createFollowUp(
        for claim: ClaimSubmission,
        action: FollowUpActionType,
        dueDate: Date,
        description: String
    ) async throws {
        let followUp = FollowUpAction(
            claimId: claim.id,
            actionType: action,
            description: description,
            dueDate: dueDate,
            createdAt: Date()
        )
        
        modelContext.insert(followUp)
        try modelContext.save()
        
        // Record activity
        let activity = ClaimActivity(
            claimId: claim.id,
            type: .followUpCreated,
            description: "Follow-up action created: \(description)",
            timestamp: Date(),
            details: [
                "actionType": action.rawValue,
                "dueDate": DateFormatter.localizedString(from: dueDate, dateStyle: .short, timeStyle: .none),
                "priority": action.priority.rawValue
            ]
        )
        
        try await operations.recordActivity(activity)
        
        // Schedule notification if service is available
        if let notificationService = notificationService {
            try await scheduleFollowUpNotification(followUp: followUp, notificationService: notificationService)
        }
    }
    
    // MARK: - Follow-up Management
    
    @MainActor
    public func markFollowUpCompleted(
        _ followUp: FollowUpAction,
        notes: String? = nil
    ) async throws {
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
        
        try await operations.recordActivity(activity)
        try modelContext.save()
    }
    
    public func getPendingFollowUps() -> [FollowUpAction] {
        let descriptor = FetchDescriptor<FollowUpAction>(
            predicate: #Predicate<FollowUpAction> { followUp in
                !followUp.isCompleted
            },
            sortBy: [SortDescriptor(\.dueDate, order: .forward)]
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    public func getOverdueFollowUps() -> [FollowUpAction] {
        let now = Date()
        let descriptor = FetchDescriptor<FollowUpAction>(
            predicate: #Predicate<FollowUpAction> { followUp in
                !followUp.isCompleted && followUp.dueDate < now
            },
            sortBy: [SortDescriptor(\.dueDate, order: .forward)]
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    public func getFollowUps(for claimId: UUID) -> [FollowUpAction] {
        let descriptor = FetchDescriptor<FollowUpAction>(
            predicate: #Predicate<FollowUpAction> { followUp in
                followUp.claimId == claimId
            },
            sortBy: [SortDescriptor(\.dueDate, order: .forward)]
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // MARK: - Follow-up Analytics
    
    public func getFollowUpAnalytics() -> FollowUpAnalytics {
        let allFollowUps = getAllFollowUps()
        let pending = getPendingFollowUps()
        let overdue = getOverdueFollowUps()
        let completed = allFollowUps.filter { $0.isCompleted }
        
        // Calculate completion rate
        let completionRate = allFollowUps.isEmpty ? 0.0 : 
            Double(completed.count) / Double(allFollowUps.count)
        
        // Calculate average completion time
        let completionTimes = completed.compactMap { followUp -> Double? in
            guard let completedAt = followUp.completedAt else { return nil }
            return completedAt.timeIntervalSince(followUp.createdAt) / (24 * 60 * 60) // days
        }
        
        let averageCompletionDays = completionTimes.isEmpty ? 0.0 :
            completionTimes.reduce(0, +) / Double(completionTimes.count)
        
        // Action type distribution
        let actionTypeDistribution = Dictionary(grouping: allFollowUps) { $0.actionType }
            .mapValues { $0.count }
        
        return FollowUpAnalytics(
            totalFollowUps: allFollowUps.count,
            pendingCount: pending.count,
            overdueCount: overdue.count,
            completedCount: completed.count,
            completionRate: completionRate,
            averageCompletionDays: averageCompletionDays,
            actionTypeDistribution: actionTypeDistribution
        )
    }
    
    // MARK: - Private Methods
    
    private func getAllFollowUps() -> [FollowUpAction] {
        let descriptor = FetchDescriptor<FollowUpAction>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    @MainActor
    private func scheduleFollowUpNotification(
        followUp: FollowUpAction,
        notificationService: NotificationService
    ) async throws {
        // Schedule notification for the due date
        let content = UNMutableNotificationContent()
        content.title = "Follow-up Action Due"
        content.body = followUp.actionDescription
        content.userInfo = [
            "followUpId": followUp.id.uuidString,
            "claimId": followUp.claimId.uuidString,
            "actionType": followUp.actionType.rawValue
        ]
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: followUp.dueDate),
            repeats: false
        )
        
        try await notificationService.scheduleNotification(
            id: "followup-\(followUp.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Schedule reminder notification 1 day before due date
        if let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: followUp.dueDate),
           reminderDate > Date() {
            let reminderContent = UNMutableNotificationContent()
            reminderContent.title = "Follow-up Reminder"
            reminderContent.body = "Tomorrow: \(followUp.actionDescription)"
            reminderContent.userInfo = [
                "followUpId": followUp.id.uuidString,
                "claimId": followUp.claimId.uuidString,
                "type": "reminder"
            ]
            
            let reminderTrigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate),
                repeats: false
            )
            
            try await notificationService.scheduleNotification(
                id: "followup-reminder-\(followUp.id.uuidString)",
                content: reminderContent,
                trigger: reminderTrigger
            )
        }
    }
}

// MARK: - Supporting Types

public struct FollowUpAnalytics {
    public let totalFollowUps: Int
    public let pendingCount: Int
    public let overdueCount: Int
    public let completedCount: Int
    public let completionRate: Double // 0.0 to 1.0
    public let averageCompletionDays: Double
    public let actionTypeDistribution: [FollowUpActionType: Int]
    
    public var overdueRate: Double {
        guard totalFollowUps > 0 else { return 0.0 }
        return Double(overdueCount) / Double(totalFollowUps)
    }
    
    public var onTimeCompletionRate: Double {
        guard completedCount > 0 else { return 0.0 }
        // This would need tracking of on-time vs late completions
        // For now, return an estimate
        return max(0.0, 1.0 - overdueRate)
    }
    
    public init(totalFollowUps: Int, pendingCount: Int, overdueCount: Int, completedCount: Int, completionRate: Double, averageCompletionDays: Double, actionTypeDistribution: [FollowUpActionType: Int]) {
        self.totalFollowUps = totalFollowUps
        self.pendingCount = pendingCount
        self.overdueCount = overdueCount
        self.completedCount = completedCount
        self.completionRate = completionRate
        self.averageCompletionDays = averageCompletionDays
        self.actionTypeDistribution = actionTypeDistribution
    }
}
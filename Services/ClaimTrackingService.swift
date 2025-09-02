//
// Layer: Services
// Module: ClaimTracking
// Purpose: Orchestrates claim tracking operations - Modularized Architecture
//

import Foundation
import SwiftData
import UserNotifications
import os.log

// MARK: - Modularized Claim Tracking Service

@MainActor
public final class ClaimTrackingService: ObservableObject {
    
    // MARK: - Published State
    
    @Published public var activeClaims: [ClaimSubmission] = []
    @Published public var recentActivity: [ClaimActivity] = []
    @Published public var pendingFollowUps: [FollowUpAction] = []
    @Published public var isLoading = false
    
    // MARK: - Modular Components
    
    private let operations: ClaimTrackingOperations
    private let timelineManager: ClaimTimelineManager
    private let analyticsEngine: ClaimAnalyticsEngine
    private let followUpManager: FollowUpManager
    
    // MARK: - Dependencies
    
    private let modelContext: ModelContext
    private let notificationService: (any NotificationService)?
    
    // MARK: - Initialization
    
    public init(modelContext: ModelContext, notificationService: (any NotificationService)? = nil) {
        self.modelContext = modelContext
        self.notificationService = notificationService
        
        // Initialize modular components
        self.operations = ClaimTrackingOperations(modelContext: modelContext)
        self.timelineManager = ClaimTimelineManager(operations: operations)
        self.analyticsEngine = ClaimAnalyticsEngine(operations: operations)
        self.followUpManager = FollowUpManager(
            modelContext: modelContext,
            operations: operations,
            notificationService: notificationService
        )
        
        // Load initial data
        loadActiveClaims()
        loadRecentActivity()
        loadPendingFollowUps()
    }
    
    // MARK: - Core Tracking Operations (Delegated)
    
    /// Track a newly generated claim by creating a submission record
    public func trackClaim(_ claim: GeneratedClaim) async throws {
        try await operations.trackClaim(claim)
        await refreshData()
    }
    
    // MARK: - Status Management (Delegated)
    
    public func updateClaimStatus(
        _ claim: ClaimSubmission,
        newStatus: ClaimStatus,
        notes: String? = nil,
        confirmationNumber: String? = nil
    ) async {
        do {
            try await operations.updateClaimStatus(
                claim,
                newStatus: newStatus,
                notes: notes,
                confirmationNumber: confirmationNumber
            )
            
            // Create follow-up actions based on new status
            try await followUpManager.createFollowUpActions(for: claim, status: newStatus)
            
            await refreshData()
        } catch {
            // Handle error gracefully - could add error publishing here
            Logger.service.error("Failed to update claim status: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Follow-up Management (Delegated)
    
    public func markFollowUpCompleted(
        _ followUp: FollowUpAction,
        notes: String? = nil
    ) async {
        do {
            try await followUpManager.markFollowUpCompleted(followUp, notes: notes)
            await refreshData()
        } catch {
            Logger.service.error("Failed to mark follow-up completed: \(error.localizedDescription)")
        }
    }
    
    public func createCustomFollowUp(
        for claim: ClaimSubmission,
        action: FollowUpActionType,
        dueDate: Date,
        description: String
    ) async {
        do {
            try await followUpManager.createFollowUp(
                for: claim,
                action: action,
                dueDate: dueDate,
                description: description
            )
            await refreshData()
        } catch {
            Logger.service.error("Failed to create follow-up: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Timeline Management (Delegated)
    
    public func getClaimTimeline(for claim: ClaimSubmission) -> [TimelineEvent] {
        timelineManager.getClaimTimeline(for: claim)
    }
    
    public func getTimelineAnalysis(for claim: ClaimSubmission) -> TimelineAnalysis {
        timelineManager.analyzeTimeline(for: claim)
    }
    
    public func getKeyMilestones(for claim: ClaimSubmission) -> [TimelineMilestone] {
        timelineManager.getKeyMilestones(for: claim)
    }
    
    // MARK: - Analytics and Insights (Delegated)
    
    public func getClaimAnalytics() -> ClaimAnalytics {
        analyticsEngine.generateClaimAnalytics()
    }
    
    public func getTrendAnalysis(months: Int = 12) -> ClaimTrendAnalysis {
        analyticsEngine.analyzeTrends(months: months)
    }
    
    public func getPerformanceMetrics() -> ClaimPerformanceMetrics {
        analyticsEngine.calculatePerformanceMetrics()
    }
    
    public func getFollowUpAnalytics() -> FollowUpAnalytics {
        followUpManager.getFollowUpAnalytics()
    }
    
    // MARK: - Activity Recording (Delegated)
    
    public func recordCorrespondence(
        for claim: ClaimSubmission,
        direction: CorrespondenceDirection,
        type: CorrespondenceType,
        subject: String,
        content: String? = nil
    ) async {
        do {
            try await operations.recordCorrespondence(
                for: claim.id,
                direction: direction,
                type: type,
                subject: subject,
                content: content
            )
            await refreshData()
        } catch {
            Logger.service.error("Failed to record correspondence: \(error.localizedDescription)")
        }
    }
    
    public func recordDocumentAddition(
        for claim: ClaimSubmission,
        documentName: String,
        documentType: String? = nil
    ) async {
        do {
            try await operations.recordDocumentAddition(
                for: claim.id,
                documentName: documentName,
                documentType: documentType
            )
            await refreshData()
        } catch {
            Logger.service.error("Failed to record document addition: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Data Management
    
    private func loadActiveClaims() {
        activeClaims = operations.getActiveClaims()
    }
    
    private func loadRecentActivity() {
        recentActivity = operations.getRecentActivity()
    }
    
    private func loadPendingFollowUps() {
        pendingFollowUps = followUpManager.getPendingFollowUps()
    }
    
    private func refreshData() async {
        loadActiveClaims()
        loadRecentActivity()
        loadPendingFollowUps()
    }
}

// MARK: - Architecture Documentation

//
// 🏗️ MODULAR ARCHITECTURE: Specialized operations organized by responsibility
// - ClaimTrackingOperations: Core CRUD operations and status management
// - ClaimTimelineManager: Timeline event creation and chronological analysis
// - ClaimAnalyticsEngine: Statistical analysis and trend reporting
// - FollowUpManager: Automated follow-up creation and reminder management
// - Supporting Models: SwiftData models and value types in dedicated module
//
// 🎯 BENEFITS ACHIEVED:
// - Separation of Concerns: Each module handles one specific domain
// - Testability: Individual components can be tested in isolation
// - Maintainability: Changes to analytics don't affect timeline management
// - Extensibility: New functionality can be added without touching core operations
// - Performance: Optimized queries and batch operations where appropriate
//
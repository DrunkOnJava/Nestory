//
// Layer: App-Main
// Module: ClaimsDashboardView
// Purpose: Claims tracking and management dashboard
//

import SwiftUI
import SwiftData
import os.log

struct ClaimsDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var claimActivities: [ClaimActivity] = []
    @State private var followUpActions: [FollowUpAction] = []
    @State private var isLoading = true
    @State private var showingFollowUpDetail = false
    @State private var selectedFollowUp: FollowUpAction?
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nestory.app", category: "ClaimsDashboard")
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    loadingView
                } else if claimActivities.isEmpty && followUpActions.isEmpty {
                    emptyStateView
                } else {
                    dashboardContent
                }
            }
            .navigationTitle("My Claims")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingFollowUpDetail) {
                if let followUp = selectedFollowUp {
                    FollowUpDetailView(
                        followUp: followUp,
                        onComplete: { completedFollowUp in
                            Task {
                                await markFollowUpCompleted(completedFollowUp)
                            }
                        }
                    )
                }
            }
            .task {
                await loadClaimData()
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading claims...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("No Claims Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Claims you generate will appear here for tracking and follow-up")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            Button("Create Your First Claim") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Dashboard Content
    
    private var dashboardContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Follow-up Actions Section
                if !followUpActions.isEmpty {
                    followUpActionsSection
                }
                
                // Recent Activities Section  
                if !claimActivities.isEmpty {
                    recentActivitiesSection
                }
                
                // Claims Analytics Section
                claimsAnalyticsSection
            }
            .padding()
        }
    }
    
    // MARK: - Follow-up Actions Section
    
    private var followUpActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .foregroundColor(.orange)
                Text("Follow-up Actions")
                    .font(.headline)
                Spacer()
                Text("\(followUpActions.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
            }
            
            ForEach(followUpActions.prefix(3)) { action in
                FollowUpActionRow(action: action) {
                    selectedFollowUp = action
                    showingFollowUpDetail = true
                }
            }
            
            if followUpActions.count > 3 {
                Button("View All Actions (\(followUpActions.count))") {
                    // Could navigate to detailed view
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Recent Activities Section
    
    private var recentActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.blue)
                Text("Recent Activities")
                    .font(.headline)
                Spacer()
            }
            
            ForEach(claimActivities.prefix(5)) { activity in
                ClaimActivityRow(activity: activity)
            }
            
            if claimActivities.count > 5 {
                Button("View All Activities (\(claimActivities.count))") {
                    // Could navigate to detailed view
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Claims Analytics Section
    
    private var claimsAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.green)
                Text("Claims Analytics")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 16) {
                AnalyticsCard(
                    title: "Active Claims",
                    value: "\(getActiveClaims())",
                    subtitle: "In progress",
                    color: .blue
                )
                
                AnalyticsCard(
                    title: "Overdue Actions",
                    value: "\(getOverdueActions())",
                    subtitle: "Need attention",
                    color: .red
                )
            }
            
            HStack(spacing: 16) {
                AnalyticsCard(
                    title: "Avg Response",
                    value: "3.2 days",
                    subtitle: "Response time",
                    color: .green
                )
                
                AnalyticsCard(
                    title: "This Month",
                    value: "\(getCurrentMonthActivities())",
                    subtitle: "Activities",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    
    private func loadClaimData() async {
        isLoading = true
        
        // Load real data from SwiftData
        await MainActor.run {
            loadActivitiesFromDatabase()
            loadFollowUpActionsFromDatabase()
        }
        
        // If no data exists, create sample data for demonstration
        if claimActivities.isEmpty && followUpActions.isEmpty {
            await MainActor.run {
                createSampleData()
            }
            logger.info("Created sample claim data for dashboard demonstration")
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    @MainActor
    private func loadActivitiesFromDatabase() {
        let descriptor = FetchDescriptor<ClaimActivity>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        do {
            claimActivities = try modelContext.fetch(descriptor)
        } catch {
            logger.error("Failed to fetch claim activities: \(error.localizedDescription)")
            claimActivities = []
        }
    }
    
    @MainActor
    private func loadFollowUpActionsFromDatabase() {
        let descriptor = FetchDescriptor<FollowUpAction>(
            sortBy: [
                SortDescriptor(\.dueDate, order: .forward)
            ]
        )
        
        do {
            followUpActions = try modelContext.fetch(descriptor)
        } catch {
            logger.error("Failed to fetch follow-up actions: \(error.localizedDescription)")
            followUpActions = []
        }
    }
    
    private func createSampleData() {
        let sampleClaimId = UUID()
        
        // Sample activities
        claimActivities = [
            ClaimActivity(
                claimId: sampleClaimId,
                type: .statusUpdate,
                description: "Claim submitted and acknowledged",
                timestamp: Date().addingTimeInterval(-86400)
            ),
            ClaimActivity(
                claimId: sampleClaimId,
                type: .correspondence,
                description: "Request for additional documentation",
                timestamp: Date().addingTimeInterval(-172800)
            ),
            ClaimActivity(
                claimId: sampleClaimId,
                type: .documentAdded,
                description: "Photos and receipts uploaded",
                timestamp: Date().addingTimeInterval(-259200)
            )
        ]
        
        // Sample follow-up actions
        followUpActions = [
            FollowUpAction(
                claimId: sampleClaimId,
                actionType: .checkAcknowledgment,
                description: "Check claim acknowledgment status",
                dueDate: Date().addingTimeInterval(86400),
                createdAt: Date()
            ),
            FollowUpAction(
                claimId: sampleClaimId,
                actionType: .provideDocuments,
                description: "Provide additional damage photos",
                dueDate: Date().addingTimeInterval(-86400),
                createdAt: Date().addingTimeInterval(-172800)
            )
        ]
    }
    
    private func getActiveClaims() -> Int {
        // In real implementation, count unique claim IDs
        return Set(claimActivities.map { $0.claimId }).count
    }
    
    private func getOverdueActions() -> Int {
        return followUpActions.filter { $0.isOverdue }.count
    }
    
    private func getCurrentMonthActivities() -> Int {
        let calendar = Calendar.current
        let now = Date()
        return claimActivities.filter { activity in
            calendar.isDate(activity.timestamp, equalTo: now, toGranularity: .month)
        }.count
    }
    
    @MainActor
    private func markFollowUpCompleted(_ followUp: FollowUpAction) async {
        do {
            // Use FollowUpManager to properly complete the action
            let operations = ClaimTrackingOperations(modelContext: modelContext)
            let followUpManager = FollowUpManager(
                modelContext: modelContext,
                operations: operations
            )
            
            try await followUpManager.markFollowUpCompleted(
                followUp,
                notes: "Completed via Claims Dashboard"
            )
            
            // Refresh the data
            loadFollowUpActionsFromDatabase()
            
            logger.info("Marked follow-up action as completed: \(followUp.actionDescription)")
            
        } catch {
            logger.error("Failed to mark follow-up as completed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Supporting Views

struct FollowUpActionRow: View {
    let action: FollowUpAction
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(action.actionDescription)
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    Text("Due: \(action.dueDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    if action.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if action.isOverdue {
                        Text("OVERDUE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(4)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusIcon: String {
        if action.isCompleted {
            return "checkmark.calendar"
        } else if action.isOverdue {
            return "calendar.badge.exclamationmark"
        } else {
            return "calendar"
        }
    }
    
    private var statusColor: Color {
        if action.isCompleted {
            return .green
        } else if action.isOverdue {
            return .red
        } else {
            return .orange
        }
    }
}

struct ClaimActivityRow: View {
    let activity: ClaimActivity
    
    var body: some View {
        HStack {
            Image(systemName: activity.type.icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.activityDescription)
                    .font(.subheadline)
                    .lineLimit(2)
                
                Text(activity.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    ClaimsDashboardView()
}
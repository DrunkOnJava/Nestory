//
// Layer: App-Main
// Module: ClaimsDashboardComponents
// Purpose: Supporting components for Claims Dashboard
//

import SwiftUI
import SwiftData

// MARK: - Follow-Up Detail View

struct FollowUpDetailView: View {
    let followUp: FollowUpAction
    let onComplete: (FollowUpAction) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var completionNotes = ""
    @State private var showingCompletionConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Action Details") {
                    ClaimDetailRow(label: "Action", value: followUp.actionDescription)
                    ClaimDetailRow(label: "Due Date", value: DateFormatter.localizedString(from: followUp.dueDate, dateStyle: .medium, timeStyle: .none))
                    ClaimDetailRow(label: "Created", value: DateFormatter.localizedString(from: followUp.createdAt, dateStyle: .medium, timeStyle: .short))
                    ClaimDetailRow(label: "Priority", value: followUp.actionType.priority.rawValue)
                }
                
                Section("Status") {
                    HStack {
                        Image(systemName: statusIcon)
                            .foregroundColor(statusColor)
                        Text(statusText)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
                    if followUp.isOverdue && !followUp.isCompleted {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("This action is overdue")
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                if followUp.isCompleted {
                    Section("Completion Details") {
                        if let completedAt = followUp.completedAt {
                            ClaimDetailRow(label: "Completed On", value: DateFormatter.localizedString(from: completedAt, dateStyle: .medium, timeStyle: .short))
                        }
                        
                        if let notes = followUp.completionNotes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notes")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(notes)
                                    .font(.body)
                            }
                        }
                    }
                } else {
                    Section("Complete Action") {
                        TextField("Add completion notes (optional)", text: $completionNotes, axis: .vertical)
                            .lineLimit(3...6)
                        
                        Button("Mark as Complete") {
                            showingCompletionConfirmation = true
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Follow-Up Action")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Mark as Complete",
                isPresented: $showingCompletionConfirmation
            ) {
                Button("Complete") {
                    onComplete(followUp)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Mark this follow-up action as completed?")
            }
        }
    }
    
    private var statusIcon: String {
        if followUp.isCompleted {
            return "checkmark.circle.fill"
        } else if followUp.isOverdue {
            return "exclamationmark.triangle.fill"
        } else {
            return "clock.fill"
        }
    }
    
    private var statusColor: Color {
        if followUp.isCompleted {
            return .green
        } else if followUp.isOverdue {
            return .red
        } else {
            return .orange
        }
    }
    
    private var statusText: String {
        if followUp.isCompleted {
            return "Completed"
        } else if followUp.isOverdue {
            return "Overdue"
        } else {
            return "Pending"
        }
    }
}

// MARK: - Supporting Components

struct ClaimDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}
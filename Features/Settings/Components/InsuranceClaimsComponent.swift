//
// Layer: Features
// Module: Settings/Components
// Purpose: Insurance claims management and settings component
//

import SwiftUI
import ComposableArchitecture
import Foundation

struct InsuranceClaimsComponent: View {
    @State private var defaultInsuranceCompany = ""
    @State private var policyNumber = ""
    @State private var agentName = ""
    @State private var agentPhone = ""
    @State private var enableClaimTracking = true
    @State private var autoGenerateReports = false
    @State private var includePhotos = true
    @State private var includeReceipts = true
    
    var body: some View {
        Section("Insurance Information") {
            TextField("Insurance Company", text: $defaultInsuranceCompany)
            TextField("Policy Number", text: $policyNumber)
            TextField("Agent Name", text: $agentName)
            TextField("Agent Phone", text: $agentPhone)
                .keyboardType(.phonePad)
        }
        
        Section("Claim Settings") {
            Toggle("Enable Claim Tracking", isOn: $enableClaimTracking)
            Toggle("Auto-generate Reports", isOn: $autoGenerateReports)
            Toggle("Include Photos in Reports", isOn: $includePhotos)
            Toggle("Include Receipts in Reports", isOn: $includeReceipts)
        }
        
        Section("Active Claims") {
            NavigationLink("View Active Claims (\(activeClaims.count))") {
                ActiveClaimsView()
            }
            
            NavigationLink("Claim History") {
                ClaimHistoryView()
            }
            
            Button("Start New Claim") {
                // Start new claim process
            }
        }
        
        Section("Templates") {
            NavigationLink("Claim Form Templates") {
                ClaimTemplatesView()
            }
            
            NavigationLink("Report Templates") {
                ReportTemplatesView()
            }
        }
    }
    
    private var activeClaims: [InsuranceClaim] {
        // Mock data - in real app, this would come from a service
        return [
            InsuranceClaim(id: "CLM001", type: "Water Damage", status: .inProgress, dateSubmitted: Date()),
            InsuranceClaim(id: "CLM002", type: "Theft", status: .pending, dateSubmitted: Date().addingTimeInterval(-86400))
        ]
    }
}

private struct ActiveClaimsView: View {
    @State private var claims: [InsuranceClaim] = [
        InsuranceClaim(id: "CLM001", type: "Water Damage", status: .inProgress, dateSubmitted: Date()),
        InsuranceClaim(id: "CLM002", type: "Theft", status: .pending, dateSubmitted: Date().addingTimeInterval(-86400)),
        InsuranceClaim(id: "CLM003", type: "Fire Damage", status: .approved, dateSubmitted: Date().addingTimeInterval(-172800))
    ]
    
    var body: some View {
        List(claims) { claim in
            NavigationLink(destination: ClaimDetailView(claim: claim)) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Claim #\(claim.id)")
                            .font(.headline)
                        
                        Spacer()
                        
                        ClaimStatusBadge(status: claim.status)
                    }
                    
                    Text(claim.type)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Submitted: \(claim.dateSubmitted.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Active Claims")
    }
}

private struct ClaimDetailView: View {
    let claim: InsuranceClaim
    @State private var notes = ""
    @State private var attachments: [ClaimAttachment] = []
    
    var body: some View {
        List {
            Section("Claim Information") {
                LabeledContent("Claim ID", value: claim.id)
                LabeledContent("Type", value: claim.type)
                LabeledContent("Status") {
                    ClaimStatusBadge(status: claim.status)
                }
                LabeledContent("Date Submitted", value: claim.dateSubmitted.formatted(date: .abbreviated, time: .omitted))
            }
            
            Section("Affected Items") {
                Text("5 items affected")
                    .foregroundColor(.secondary)
                
                Button("Review Affected Items") {
                    // Show affected items
                }
            }
            
            Section("Documentation") {
                ForEach(attachments) { attachment in
                    HStack {
                        Image(systemName: attachment.iconName)
                        Text(attachment.name)
                        Spacer()
                        Text(attachment.size)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button("Add Documentation") {
                    // Add new attachment
                }
            }
            
            Section("Notes") {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
            }
            
            Section("Actions") {
                Button("Generate Updated Report") {
                    // Generate report
                }
                
                Button("Contact Adjuster") {
                    // Contact functionality
                }
                
                Button("Upload to Portal") {
                    // Upload to insurance portal
                }
            }
        }
        .navigationTitle("Claim Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ClaimHistoryView: View {
    @State private var pastClaims: [InsuranceClaim] = [
        InsuranceClaim(id: "CLM004", type: "Hail Damage", status: .closed, dateSubmitted: Date().addingTimeInterval(-2592000)),
        InsuranceClaim(id: "CLM005", type: "Burglary", status: .denied, dateSubmitted: Date().addingTimeInterval(-5184000))
    ]
    
    var body: some View {
        List(pastClaims) { claim in
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Claim #\(claim.id)")
                        .font(.headline)
                    
                    Spacer()
                    
                    ClaimStatusBadge(status: claim.status)
                }
                
                Text(claim.type)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Submitted: \(claim.dateSubmitted.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Claim History")
    }
}

private struct ClaimTemplatesView: View {
    @State private var templates = [
        "Standard Claim Form",
        "Water Damage Checklist",
        "Theft Report Template",
        "Fire Damage Assessment"
    ]
    
    var body: some View {
        List {
            ForEach(templates, id: \.self) { template in
                HStack {
                    Text(template)
                    Spacer()
                    Button("Use") {
                        // Use template
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                }
            }
            
            Button("Create Custom Template") {
                // Create new template
            }
            .foregroundColor(.blue)
        }
        .navigationTitle("Claim Templates")
    }
}

private struct ReportTemplatesView: View {
    var body: some View {
        List {
            Text("PDF Report Templates")
                .font(.headline)
            
            ForEach(["Comprehensive Report", "Summary Report", "Photo Catalog"], id: \.self) { template in
                HStack {
                    Text(template)
                    Spacer()
                    Button("Preview") {
                        // Preview template
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                }
            }
        }
        .navigationTitle("Report Templates")
    }
}

private struct ClaimStatusBadge: View {
    let status: InsuranceClaimStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
            Text(status.displayName)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(status.color.opacity(0.2))
        .foregroundColor(status.color)
        .clipShape(Capsule())
    }
}

private struct InsuranceClaim: Identifiable {
    let id: String
    let type: String
    let status: InsuranceClaimStatus
    let dateSubmitted: Date
}

private struct ClaimAttachment: Identifiable {
    let id = UUID()
    let name: String
    let size: String
    let type: AttachmentType
    
    var iconName: String {
        switch type {
        case .photo: return "photo"
        case .document: return "doc"
        case .receipt: return "receipt"
        }
    }
}

private enum InsuranceClaimStatus {
    case pending, inProgress, approved, denied, closed
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .inProgress: return "In Progress"
        case .approved: return "Approved"
        case .denied: return "Denied"
        case .closed: return "Closed"
        }
    }
    
    var iconName: String {
        switch self {
        case .pending: return "clock"
        case .inProgress: return "arrow.clockwise"
        case .approved: return "checkmark.circle"
        case .denied: return "xmark.circle"
        case .closed: return "folder"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .inProgress: return .blue
        case .approved: return .green
        case .denied: return .red
        case .closed: return .gray
        }
    }
}

private enum AttachmentType {
    case photo, document, receipt
}

#Preview {
    NavigationView {
        List {
            InsuranceClaimsComponent()
        }
        .navigationTitle("Settings")
    }
}
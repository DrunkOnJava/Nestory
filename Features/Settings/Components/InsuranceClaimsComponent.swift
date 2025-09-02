//
// Layer: Features
// Module: Settings/Components
// Purpose: Insurance claims dashboard components
//

import SwiftUI
import Foundation

struct InsuranceClaimsComponent {
    
    @MainActor
    static func insuranceClaimsDashboardView() -> some View {
        VStack {
            Text("Insurance Claims Dashboard")
                .font(.title2)
            // TODO: Implement insurance claims dashboard
        }
    }
    
    // MARK: - Claims and Insurance Views
    
    @MainActor
    static func claimsDashboardView() -> some View {
        ClaimsDashboardView()
    }
    
    @MainActor
    static func insuranceReportsView() -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Insurance Reports")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Generate professional reports for insurance documentation")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Quick Actions
                VStack(spacing: 12) {
                    ReportActionCard(
                        title: "Generate Full Inventory Report",
                        subtitle: "Complete listing of all items with values",
                        systemImage: "doc.text",
                        color: .blue
                    ) {
                        // TODO: Wire to InsuranceExportOptionsView with all items
                    }
                    
                    ReportActionCard(
                        title: "Room-Specific Report",
                        subtitle: "Generate reports for individual rooms",
                        systemImage: "house.rooms.fill",
                        color: .green
                    ) {
                        // TODO: Wire to room selection for InsuranceExportOptionsView
                    }
                    
                    ReportActionCard(
                        title: "High-Value Items Report",
                        subtitle: "Focus on items above specified value threshold",
                        systemImage: "star.circle",
                        color: .orange
                    ) {
                        // TODO: Wire to filtered InsuranceExportOptionsView
                    }
                    
                    ReportActionCard(
                        title: "Damage Assessment Report",
                        subtitle: "Document damage for claims processing",
                        systemImage: "exclamationmark.triangle",
                        color: .red
                    ) {
                        // TODO: Wire to damage assessment workflow
                    }
                }
                
                Spacer()
                
                // Info Box
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Report Information")
                            .font(.headline)
                    }
                    
                    Text("• Reports include photos, purchase dates, and values")
                    Text("• PDF format recommended for insurance companies")
                    Text("• Keep multiple copies in different locations")
                    Text("• Update reports annually or after major purchases")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Insurance Reports")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @MainActor
    static func claimTemplatesView() -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "doc.richtext")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Claim Templates")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Pre-configured templates for common insurance claims")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Template Categories
                VStack(spacing: 12) {
                    ClaimTemplateCard(
                        title: "Fire Damage Claim",
                        subtitle: "Template for fire-related property damage",
                        systemImage: "flame",
                        color: .red,
                        description: "Includes sections for damage assessment, affected items, repair estimates, and supporting documentation."
                    ) {
                        // TODO: Create fire damage claim template
                    }
                    
                    ClaimTemplateCard(
                        title: "Water Damage Claim",
                        subtitle: "Template for water damage incidents",
                        systemImage: "drop",
                        color: .blue,
                        description: "Covers flood, leak, or burst pipe damage with moisture readings and remediation requirements."
                    ) {
                        // TODO: Create water damage claim template
                    }
                    
                    ClaimTemplateCard(
                        title: "Theft & Burglary Claim",
                        subtitle: "Template for stolen or missing items",
                        systemImage: "lock.open",
                        color: .orange,
                        description: "Structured format for documenting missing items, serial numbers, and police report information."
                    ) {
                        // TODO: Create theft claim template
                    }
                    
                    ClaimTemplateCard(
                        title: "Natural Disaster Claim",
                        subtitle: "Template for weather-related damage",
                        systemImage: "cloud.bolt",
                        color: .purple,
                        description: "Comprehensive template for hurricane, earthquake, tornado, or other natural disaster claims."
                    ) {
                        // TODO: Create disaster claim template
                    }
                    
                    ClaimTemplateCard(
                        title: "General Property Damage",
                        subtitle: "Multi-purpose damage claim template",
                        systemImage: "house.circle",
                        color: .green,
                        description: "Flexible template that can be adapted for various types of property damage claims."
                    ) {
                        // TODO: Create general damage claim template
                    }
                }
                
                Spacer()
                
                // Template Features Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                        Text("Template Features")
                            .font(.headline)
                    }
                    
                    Text("• Pre-filled standard information sections")
                    Text("• Guidance for required documentation")
                    Text("• Automatic calculation of total damages")
                    Text("• Export in insurance company preferred formats")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Claim Templates")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Supporting Views

private struct ReportActionCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct ClaimTemplateCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .foregroundColor(color)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 42)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
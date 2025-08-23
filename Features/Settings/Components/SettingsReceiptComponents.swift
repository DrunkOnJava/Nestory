//
// Layer: Features
// Module: Settings/Components
// Purpose: Receipt processing dashboard components for Settings feature
//

import SwiftUI
import Foundation

struct SettingsReceiptComponents {
    
    // MARK: - Receipt Processing Dashboard
    
    @MainActor
    static func receiptProcessingDashboardView() -> some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.viewfinder")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Receipt Processing Dashboard")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Monitor and manage AI-powered receipt processing with 3-tier machine learning extraction.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Processing Statistics
                VStack(spacing: 12) {
                    HStack {
                        Text("Processing Statistics")
                            .font(.headline)
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        ReceiptMetricCard(
                            title: "Receipts Processed",
                            value: "127", // TODO: Connect to actual data
                            subtitle: "Total scanned",
                            color: .blue,
                            systemImage: "doc.text"
                        )
                        
                        ReceiptMetricCard(
                            title: "Success Rate",
                            value: "94%",
                            subtitle: "OCR accuracy",
                            color: .green,
                            systemImage: "checkmark.circle"
                        )
                    }
                    
                    HStack(spacing: 12) {
                        ReceiptMetricCard(
                            title: "Auto-extracted",
                            value: "312",
                            subtitle: "Data fields",
                            color: .purple,
                            systemImage: "brain.head.profile"
                        )
                        
                        ReceiptMetricCard(
                            title: "This Month",
                            value: "23",
                            subtitle: "Receipts added",
                            color: .orange,
                            systemImage: "calendar"
                        )
                    }
                }
                
                // Processing Methods
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Processing Methods")
                            .font(.headline)
                        Spacer()
                    }
                    
                    ProcessingMethodRow(
                        icon: "brain.head.profile",
                        title: "Machine Learning",
                        subtitle: "Custom ML models for data extraction",
                        color: .purple
                    )
                    
                    ProcessingMethodRow(
                        icon: "eye.fill",
                        title: "Apple Vision Framework",
                        subtitle: "Built-in OCR text recognition",
                        color: .blue
                    )
                    
                    ProcessingMethodRow(
                        icon: "doc.viewfinder",
                        title: "Pattern Recognition",
                        subtitle: "Smart field detection algorithms",
                        color: .green
                    )
                }
                
                // Settings Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Processing Settings")
                            .font(.headline)
                        Spacer()
                    }
                    
                    VStack(spacing: 8) {
                        SettingToggleRow(
                            title: "Auto-enhance Images",
                            subtitle: "Improve image quality before OCR",
                            isOn: .constant(true) // TODO: Connect to actual setting
                        )
                        
                        SettingToggleRow(
                            title: "Perspective Correction",
                            subtitle: "Automatically straighten receipt photos",
                            isOn: .constant(true)
                        )
                        
                        SettingToggleRow(
                            title: "Batch Processing",
                            subtitle: "Process multiple receipts simultaneously",
                            isOn: .constant(false)
                        )
                    }
                }
                
                Spacer()
                
                // Info Box
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb")
                            .foregroundColor(.orange)
                        Text("Processing Tips")
                            .font(.headline)
                    }
                    
                    Text("• Ensure good lighting when capturing receipts")
                    Text("• Include the entire receipt in the frame")
                    Text("• Hold your device steady during capture")
                    Text("• Processing accuracy improves with high-quality images")
                    
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Receipt Processing")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Supporting Components

private struct ReceiptMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct ProcessingMethodRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

private struct SettingToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle())
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}
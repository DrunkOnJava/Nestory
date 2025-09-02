//
// Layer: Features
// Module: Settings/Components
// Purpose: Cloud storage options and configuration components
//

import SwiftUI
import Foundation

struct CloudStorageComponent {
    
    @MainActor
    static func cloudStorageOptionsView() -> some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "icloud.and.arrow.up")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Cloud Storage Options")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Backup your inventory data to cloud storage services for secure access across devices.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Service Options
                VStack(spacing: 12) {
                    CloudStorageServiceRow(
                        serviceName: "iCloud Drive",
                        icon: "icloud",
                        description: "Built-in Apple cloud storage"
                    )
                    
                    CloudStorageServiceRow(
                        serviceName: "Google Drive",
                        icon: "doc.circle",
                        description: "Google cloud storage service"
                    )
                    
                    CloudStorageServiceRow(
                        serviceName: "Dropbox",
                        icon: "square.and.arrow.up.on.square",
                        description: "Popular file sharing service"
                    )
                    
                    CloudStorageServiceRow(
                        serviceName: "OneDrive",
                        icon: "square.grid.3x3",
                        description: "Microsoft cloud storage"
                    )
                }
                
                Spacer()
                
                // Info Box
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Information")
                            .font(.headline)
                    }
                    
                    Text("• Cloud storage integration requires compatible services to be installed on your device")
                    Text("• Your data is encrypted before upload for security")
                    Text("• Backups include inventory items, categories, and associated documentation")
                    
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Cloud Storage")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct CloudStorageServiceRow: View {
    let serviceName: String
    let icon: String
    let description: String
    
    var body: some View {
        Button(action: {
            // TODO: Implement cloud storage service selection
            // This would typically open the service selection flow
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(serviceName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
//
// Layer: App-Main
// Module: Settings
// Purpose: Cloud storage service selection and backup options
//

import SwiftUI
import SwiftData

struct CloudStorageOptionsView: View {
    let items: [Item]
    @ObservedObject var cloudStorageManager: CloudStorageManager
    let onUploadComplete: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedService: (any CloudStorageService)?
    @State private var uploadError: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "icloud.and.arrow.up")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Backup to Cloud Storage")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Select a cloud service to backup your inventory data securely.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Service Selection
                if cloudStorageManager.availableServices.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 30))
                            .foregroundColor(.orange)
                        
                        Text("No Cloud Services Available")
                            .font(.headline)
                        
                        Text("Cloud storage services are not available in the simulator. Please test on a real device.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose Cloud Service")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(cloudStorageManager.availableServices, id: \.name) { service in
                            ServiceSelectionRow(
                                service: service,
                                isSelected: selectedService?.name == service.name,
                                action: { selectedService = service }
                            )
                        }
                    }
                }
                
                Spacer()
                
                // Upload Progress
                if cloudStorageManager.isUploading {
                    VStack(spacing: 8) {
                        ProgressView(value: cloudStorageManager.uploadProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                        
                        Text("Uploading... \(Int(cloudStorageManager.uploadProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                
                // Error Display
                if let uploadError = uploadError {
                    Text(uploadError)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Start Backup") {
                        startBackup()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedService == nil || cloudStorageManager.isUploading || cloudStorageManager.availableServices.isEmpty)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Cloud Backup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func startBackup() {
        guard let service = selectedService else { return }
        
        Task {
            do {
                uploadError = nil
                
                // Create a temporary JSON export of the data
                let exportData = try await createExportData()
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("nestory-backup-\(Date().timeIntervalSince1970).json")
                
                try exportData.write(to: tempURL)
                defer { try? FileManager.default.removeItem(at: tempURL) }
                
                // Upload to selected cloud service
                let uploadURL = try await cloudStorageManager.uploadToService(
                    service,
                    fileURL: tempURL,
                    fileName: tempURL.lastPathComponent
                )
                
                await MainActor.run {
                    onUploadComplete(uploadURL)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    uploadError = "Backup failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func createExportData() async throws -> Data {
        // Create a simple JSON export of items for backup
        let exportItems = items.map { item in
            [
                "id": item.id.uuidString,
                "name": item.name,
                "category": item.category?.name ?? "",
                "purchasePrice": item.purchasePrice?.description ?? "",
                "purchaseDate": item.purchaseDate?.ISO8601Format() ?? "",
                "notes": item.notes ?? ""
            ]
        }
        
        let exportDict = [
            "exportDate": Date().ISO8601Format(),
            "itemCount": items.count,
            "items": exportItems
        ] as [String: Any]
        
        return try JSONSerialization.data(withJSONObject: exportDict, options: .prettyPrinted)
    }
}

struct ServiceSelectionRow: View {
    let service: any CloudStorageService
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconForService(service.name))
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(service.name)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text("Secure cloud backup")
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
    
    private func iconForService(_ name: String) -> String {
        switch name.lowercased() {
        case "icloud drive": return "icloud"
        case "google drive": return "doc.circle"
        case "dropbox": return "square.and.arrow.up.on.square"
        case "onedrive": return "square.grid.3x3"
        case "box": return "cube.box"
        default: return "externaldrive.connected"
        }
    }
}

#Preview {
    CloudStorageOptionsView(
        items: [],
        cloudStorageManager: CloudStorageManager(),
        onUploadComplete: { _ in }
    )
}
//
// Layer: Features
// Module: Settings/Components
// Purpose: Cloud storage and sync settings component
//

import SwiftUI
import CloudKit
import Foundation

struct CloudStorageComponent: View {
    @State private var iCloudEnabled = true
    @State private var autoSync = true
    @State private var syncOnCellular = false
    @State private var lastSyncDate = Date()
    @State private var storageUsed = 245.7 // MB
    @State private var storageQuota = 5000.0 // MB
    @State private var syncStatus = CloudSyncStatus.synced
    @State private var showingAccountInfo = false
    
    var body: some View {
        Section("iCloud Sync") {
            Toggle("Enable iCloud Sync", isOn: $iCloudEnabled)
                .onChange(of: iCloudEnabled) { _, newValue in
                    if newValue {
                        checkiCloudStatus()
                    }
                }
            
            if iCloudEnabled {
                HStack {
                    Text("Status")
                    Spacer()
                    SyncStatusBadge(status: syncStatus)
                }
                
                HStack {
                    Text("Last Sync")
                    Spacer()
                    Text(lastSyncDate.formatted(date: .abbreviated, time: .shortened))
                        .foregroundColor(.secondary)
                }
                
                Toggle("Auto Sync", isOn: $autoSync)
                    .padding(.leading)
                
                Toggle("Sync on Cellular", isOn: $syncOnCellular)
                    .padding(.leading)
                
                Button("Sync Now") {
                    performManualSync()
                }
                .padding(.leading)
                .disabled(syncStatus == .syncing)
            }
        }
        
        Section("Storage") {
            HStack {
                VStack(alignment: .leading) {
                    Text("iCloud Storage Used")
                    ProgressView(value: storageUsed, total: storageQuota)
                        .progressViewStyle(LinearProgressViewStyle())
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(storageUsed, specifier: "%.1f") MB")
                        .font(.headline)
                    Text("of \(storageQuota, specifier: "%.0f") MB")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button("Manage iCloud Storage") {
                showingAccountInfo = true
            }
            
            NavigationLink("Storage Breakdown") {
                StorageBreakdownView()
            }
        }
        
        Section("Backup & Restore") {
            NavigationLink("Backup History") {
                BackupHistoryView()
            }
            
            Button("Create Manual Backup") {
                createManualBackup()
            }
            
            Button("Restore from Backup") {
                // Show restore options
            }
            .foregroundColor(.orange)
        }
        
        Section("Advanced") {
            Toggle("Sync Photos", isOn: .constant(true))
            Toggle("Sync Receipts", isOn: .constant(true))
            Toggle("Sync Reports", isOn: .constant(false))
            
            NavigationLink("Conflict Resolution") {
                ConflictResolutionView()
            }
            
            Button("Reset Sync Data") {
                // Reset sync
            }
            .foregroundColor(.red)
        }
        .sheet(isPresented: $showingAccountInfo) {
            iCloudAccountView()
        }
    }
    
    private func checkiCloudStatus() {
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    syncStatus = .synced
                case .noAccount:
                    syncStatus = .error
                case .restricted, .couldNotDetermine:
                    syncStatus = .offline
                @unknown default:
                    syncStatus = .offline
                }
            }
        }
    }
    
    private func performManualSync() {
        syncStatus = .syncing
        
        // Simulate sync process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            syncStatus = .synced
            lastSyncDate = Date()
        }
    }
    
    private func createManualBackup() {
        // Create manual backup
    }
}

private struct StorageBreakdownView: View {
    @State private var storageData = [
        StorageItem(category: "Photos", size: 125.3, percentage: 51.0),
        StorageItem(category: "Item Data", size: 45.2, percentage: 18.4),
        StorageItem(category: "Receipts", size: 38.7, percentage: 15.7),
        StorageItem(category: "Reports", size: 22.1, percentage: 9.0),
        StorageItem(category: "Backups", size: 14.4, percentage: 5.9)
    ]
    
    var body: some View {
        List {
            Section("Storage Usage") {
                ForEach(storageData) { item in
                    HStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 12, height: 12)
                        
                        Text(item.category)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(item.size, specifier: "%.1f") MB")
                                .font(.headline)
                            Text("\(item.percentage, specifier: "%.1f")%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Section("Actions") {
                Button("Optimize Storage") {
                    // Optimize storage
                }
                
                Button("Clear Cache") {
                    // Clear cache
                }
                
                Button("Compress Photos") {
                    // Compress photos
                }
            }
        }
        .navigationTitle("Storage Breakdown")
    }
}

private struct BackupHistoryView: View {
    @State private var backups = [
        BackupRecord(date: Date(), type: .automatic, size: 125.4, status: .completed),
        BackupRecord(date: Date().addingTimeInterval(-86400), type: .manual, size: 123.8, status: .completed),
        BackupRecord(date: Date().addingTimeInterval(-172800), type: .automatic, size: 122.1, status: .completed),
        BackupRecord(date: Date().addingTimeInterval(-259200), type: .automatic, size: 0.0, status: .failed)
    ]
    
    var body: some View {
        List {
            ForEach(backups) { backup in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(backup.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.headline)
                        
                        Spacer()
                        
                        BackupStatusBadge(status: backup.status)
                    }
                    
                    HStack {
                        Text(backup.type.displayName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if backup.status == .completed {
                            Text("\(backup.size, specifier: "%.1f") MB")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .onDelete(perform: deleteBackups)
        }
        .navigationTitle("Backup History")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }
    
    private func deleteBackups(offsets: IndexSet) {
        backups.remove(atOffsets: offsets)
    }
}

private struct ConflictResolutionView: View {
    @State private var conflicts = [
        ConflictRecord(itemName: "MacBook Pro", conflictType: .valueDifference, deviceA: "iPhone", deviceB: "iPad", date: Date()),
        ConflictRecord(itemName: "Wedding Ring", conflictType: .photoMismatch, deviceA: "iPhone", deviceB: "Mac", date: Date().addingTimeInterval(-3600))
    ]
    
    var body: some View {
        List {
            if conflicts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    
                    Text("No Conflicts")
                        .font(.headline)
                    
                    Text("All your devices are in sync")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(conflicts) { conflict in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(conflict.itemName)
                                .font(.headline)
                            
                            Spacer()
                            
                            ConflictTypeBadge(type: conflict.conflictType)
                        }
                        
                        Text("Conflict between \(conflict.deviceA) and \(conflict.deviceB)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Button("Resolve") {
                                resolveConflict(conflict)
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .controlSize(.small)
                            
                            Button("Details") {
                                // Show conflict details
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .controlSize(.small)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .navigationTitle("Conflict Resolution")
    }
    
    private func resolveConflict(_ conflict: ConflictRecord) {
        if let index = conflicts.firstIndex(where: { $0.id == conflict.id }) {
            conflicts.remove(at: index)
        }
    }
}

private struct iCloudAccountView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "icloud.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                
                Text("iCloud Account")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(label: "Account", value: "user@example.com")
                    InfoRow(label: "Plan", value: "iCloud+ 50GB")
                    InfoRow(label: "Available", value: "4.75 GB")
                    InfoRow(label: "Status", value: "Active")
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Button("Manage iCloud Account") {
                    // Open iCloud settings
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
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
}

private struct InfoRow: View {
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

// MARK: - Status Badges

private struct SyncStatusBadge: View {
    let status: CloudSyncStatus
    
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

private struct BackupStatusBadge: View {
    let status: BackupStatus
    
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

private struct ConflictTypeBadge: View {
    let type: ConflictType
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.iconName)
            Text(type.displayName)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(type.color.opacity(0.2))
        .foregroundColor(type.color)
        .clipShape(Capsule())
    }
}

// MARK: - Models

private struct StorageItem: Identifiable {
    let id = UUID()
    let category: String
    let size: Double
    let percentage: Double
    
    var color: Color {
        switch category {
        case "Photos": return .blue
        case "Item Data": return .green
        case "Receipts": return .orange
        case "Reports": return .purple
        case "Backups": return .gray
        default: return .primary
        }
    }
}

private struct BackupRecord: Identifiable {
    let id = UUID()
    let date: Date
    let type: BackupType
    let size: Double
    let status: BackupStatus
}

private struct ConflictRecord: Identifiable {
    let id = UUID()
    let itemName: String
    let conflictType: ConflictType
    let deviceA: String
    let deviceB: String
    let date: Date
}

private enum CloudSyncStatus {
    case synced, syncing, error, offline
    
    var displayName: String {
        switch self {
        case .synced: return "Synced"
        case .syncing: return "Syncing"
        case .error: return "Error"
        case .offline: return "Offline"
        }
    }
    
    var iconName: String {
        switch self {
        case .synced: return "checkmark.circle.fill"
        case .syncing: return "arrow.clockwise"
        case .error: return "exclamationmark.triangle.fill"
        case .offline: return "wifi.slash"
        }
    }
    
    var color: Color {
        switch self {
        case .synced: return .green
        case .syncing: return .blue
        case .error: return .red
        case .offline: return .orange
        }
    }
}

private enum BackupType {
    case automatic, manual
    
    var displayName: String {
        switch self {
        case .automatic: return "Automatic"
        case .manual: return "Manual"
        }
    }
}



private enum ConflictType {
    case valueDifference, photoMismatch, dateMismatch
    
    var displayName: String {
        switch self {
        case .valueDifference: return "Value"
        case .photoMismatch: return "Photos"
        case .dateMismatch: return "Date"
        }
    }
    
    var iconName: String {
        switch self {
        case .valueDifference: return "dollarsign.circle"
        case .photoMismatch: return "photo"
        case .dateMismatch: return "calendar"
        }
    }
    
    var color: Color {
        switch self {
        case .valueDifference: return .orange
        case .photoMismatch: return .blue
        case .dateMismatch: return .purple
        }
    }
}

#Preview {
    NavigationView {
        List {
            CloudStorageComponent()
        }
        .navigationTitle("Settings")
    }
}
//
// Layer: App
// Module: Settings
// Purpose: iCloud backup and restore functionality
//

import SwiftData
import SwiftUI

struct CloudBackupSettingsView: View {
    @StateObject private var cloudBackup = CloudBackupService()
    @Query private var items: [Item]
    @Query private var categories: [Category]
    @Query private var rooms: [Room]
    @Environment(\.modelContext) private var modelContext

    @State private var showingRestoreConfirmation = false
    @State private var backupResult: String?
    @State private var showingBackupResult = false

    var body: some View {
        Section("iCloud Backup") {
            // Backup status
            if let lastBackup = cloudBackup.lastBackupDate {
                HStack {
                    Label("Last Backup", systemImage: "clock")
                    Spacer()
                    Text(lastBackup.formatted(.relative(presentation: .named)))
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }

            // Backup button
            Button(action: { performBackup() }) {
                if cloudBackup.isBackingUp {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                        Text("Backing up... \(Int(cloudBackup.progress * 100))%")
                    }
                } else {
                    Label("Backup Now", systemImage: "icloud.and.arrow.up")
                }
            }
            .disabled(cloudBackup.isBackingUp || cloudBackup.isRestoring)

            // Restore button
            Button(action: { showingRestoreConfirmation = true }) {
                if cloudBackup.isRestoring {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                        Text("Restoring... \(Int(cloudBackup.progress * 100))%")
                    }
                } else {
                    Label("Restore from iCloud", systemImage: "icloud.and.arrow.down")
                }
            }
            .disabled(cloudBackup.isBackingUp || cloudBackup.isRestoring)

            // REMINDER: CloudKit backup is wired here for disaster recovery!
            if cloudBackup.errorMessage != nil {
                Text(cloudBackup.errorMessage!)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .alert("Restore from iCloud?", isPresented: $showingRestoreConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Restore", role: .destructive) {
                performRestore()
            }
        } message: {
            Text("This will replace all current data with the backup from iCloud. Your current data will be lost.")
        }
        .alert("Backup Result", isPresented: $showingBackupResult) {
            Button("OK") {}
        } message: {
            Text(backupResult ?? "Operation completed")
        }
    }

    private func performBackup() {
        Task {
            do {
                try await cloudBackup.performBackup(
                    items: items,
                    categories: categories,
                    rooms: rooms
                )
                backupResult = "Backup completed successfully! \(items.count) items backed up to iCloud."
                showingBackupResult = true
            } catch {
                backupResult = "Backup failed: \(error.localizedDescription)"
                showingBackupResult = true
            }
        }
    }

    private func performRestore() {
        Task {
            do {
                let result = try await cloudBackup.performRestore(modelContext: modelContext)
                backupResult = "Restore completed! Restored \(result.itemsRestored) items, \(result.categoriesRestored) categories, and \(result.roomsRestored) rooms from \(result.backupDate.formatted())."
                showingBackupResult = true
            } catch {
                backupResult = "Restore failed: \(error.localizedDescription)"
                showingBackupResult = true
            }
        }
    }
}

#Preview {
    Form {
        CloudBackupSettingsView()
            .modelContainer(for: [Item.self, Category.self, Room.self], inMemory: true)
    }
}

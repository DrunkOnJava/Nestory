//
// Layer: App
// Module: Settings
// Purpose: Main settings coordinator view
//
// REMINDER: Settings is a common place to wire up utility features like:
// - Import/Export (✓ Wired)
// - Insurance Reports (✓ Wired)
// - Backup/Restore (✓ Wired)
// - Account Management
// Always check if new services should be accessible from Settings!

import SwiftData
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Form {
                // Appearance settings
                AppearanceSettingsView()

                // General settings
                GeneralSettingsView()

                // Notification settings
                NotificationSettingsView()

                // Data & Storage
                DataStorageSettingsView()

                // iCloud Backup
                CloudBackupSettingsView()

                // Import & Export
                ImportExportSettingsView()

                // Support & About
                AboutSupportSettingsView()

                // Danger Zone
                DangerZoneSettingsView()
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager.shared)
        .modelContainer(for: [Item.self, Category.self, Room.self], inMemory: true)
}

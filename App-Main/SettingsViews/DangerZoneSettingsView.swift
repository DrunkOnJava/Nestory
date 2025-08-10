//
// Layer: App
// Module: Settings
// Purpose: Danger zone section for clearing data
//

import SwiftData
import SwiftUI

struct DangerZoneSettingsView: View {
    @Query private var items: [Item]
    @Query private var categories: [Category]
    @Environment(\.modelContext) private var modelContext
    @State private var showingClearDataAlert = false

    var body: some View {
        Section {
            Button("Clear All Data", role: .destructive) {
                showingClearDataAlert = true
            }
        } header: {
            Text("Danger Zone")
        } footer: {
            Text("This action cannot be undone.")
        }
        .alert("Clear All Data?", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all items and categories. This action cannot be undone.")
        }
    }

    private func clearAllData() {
        for item in items {
            modelContext.delete(item)
        }
        for category in categories {
            modelContext.delete(category)
        }
        try? modelContext.save()
    }
}

#Preview {
    Form {
        DangerZoneSettingsView()
            .modelContainer(for: [Item.self, Category.self], inMemory: true)
    }
}

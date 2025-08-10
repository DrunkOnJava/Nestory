//
// Layer: App
// Module: Settings
// Purpose: Data and storage statistics section
//

import SwiftData
import SwiftUI

struct DataStorageSettingsView: View {
    @Query private var items: [Item]
    @Query private var categories: [Category]
    @AppStorage("autoBackupEnabled") private var autoBackupEnabled = false

    var body: some View {
        Section("Data & Storage") {
            HStack {
                Label("Total Items", systemImage: "shippingbox.fill")
                Spacer()
                Text("\(items.count)")
                    .foregroundColor(.secondary)
            }

            HStack {
                Label("Categories", systemImage: "square.grid.2x2")
                Spacer()
                Text("\(categories.count)")
                    .foregroundColor(.secondary)
            }

            HStack {
                Label("Storage Used", systemImage: "internaldrive")
                Spacer()
                Text(formatStorageSize())
                    .foregroundColor(.secondary)
            }

            Toggle("Auto Backup", isOn: $autoBackupEnabled)
        }
    }

    private func formatStorageSize() -> String {
        let totalSize = calculateStorageSize()
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(totalSize))
    }

    private func calculateStorageSize() -> Int {
        var totalSize = 0
        for item in items {
            totalSize += item.name.count
            totalSize += item.itemDescription?.count ?? 0
            totalSize += item.notes?.count ?? 0
            totalSize += item.imageData?.count ?? 0
        }
        return totalSize
    }
}

#Preview {
    Form {
        DataStorageSettingsView()
            .modelContainer(for: [Item.self, Category.self], inMemory: true)
    }
}

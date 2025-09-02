//
// Layer: App-Main
// Module: WarrantyDocuments
// Purpose: Main coordinator view for warranty, location, and document management
//
// REMINDER: This view is WIRED UP in ItemDetailView and EditItemView
// Provides warranty tracking, document attachments, and room assignment

import SwiftData
import SwiftUI

struct WarrantyDocumentsView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector
                Picker("View", selection: $selectedTab) {
                    Label("Warranty", systemImage: "shield").tag(0)
                    Label("Location", systemImage: "location").tag(1)
                    Label("Documents", systemImage: "doc.stack").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()

                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case 0:
                            WarrantyManagementView(item: item)
                        case 1:
                            LocationManagementView(item: item)
                        case 2:
                            DocumentManagementView(item: item)
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Warranty & Documents")
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

#Preview {
    let item = Item(name: "Test Item")
    WarrantyDocumentsView(item: item)
        .modelContainer(for: [Item.self, Room.self], inMemory: true)
}

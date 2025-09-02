//
// Layer: App-Main
// Module: WarrantyViews
// Purpose: Manage document attachments for items
//

// App layer - no direct logging imports
import SwiftUI
import UniformTypeIdentifiers
import os.log

struct DocumentManagementView: View {
    @Bindable var item: Item
    @State private var showingDocumentPicker = false
    // Logging handled by service layer
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nestory.app", category: "DocumentManagement")

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Attached Documents")
                    .font(.headline)
                Spacer()
                Button(action: { showingDocumentPicker = true }) {
                    Label("Add", systemImage: "plus.circle.fill")
                }
            }

            if item.documentNames.isEmpty {
                emptyDocumentsView
            } else {
                documentsList
            }

            // Tips section
            DocumentTipsView()
        }
        .fileImporter(
            isPresented: $showingDocumentPicker,
            allowedContentTypes: [.pdf, .image, .text],
            allowsMultipleSelection: true,
        ) { result in
            handleDocumentImport(result)
        }
    }

    private var emptyDocumentsView: some View {
        GroupBox {
            VStack(spacing: 12) {
                Image(systemName: "doc.text")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                Text("No Documents Attached")
                    .font(.headline)
                Text("Add user manuals, warranties, receipts, or other important documents")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button(action: { showingDocumentPicker = true }) {
                    Label("Add Document", systemImage: "doc.badge.plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }

    private var documentsList: some View {
        ForEach(Array(item.documentNames.enumerated()), id: \.offset) { index, name in
            DocumentRow(
                name: name,
                size: (index < item.documentAttachments.count) ? item.documentAttachments[index].count : 0,
            ) { removeDocument(at: index) }
        }
    }

    private func handleDocumentImport(_ result: Result<[URL], any Error>) {
        switch result {
        case let .success(urls):
            for url in urls {
                guard url.startAccessingSecurityScopedResource() else { continue }
                defer { url.stopAccessingSecurityScopedResource() }

                if let data = try? Data(contentsOf: url) {
                    item.documentAttachments.append(data)
                    item.documentNames.append(url.lastPathComponent)
                }
            }
            item.updatedAt = Date()
        case let .failure(error):
            logger.error("Document import failed: \(error)")
        }
    }

    private func removeDocument(at index: Int) {
        guard index < item.documentNames.count else { return }
        item.documentNames.remove(at: index)
        if index < item.documentAttachments.count {
            item.documentAttachments.remove(at: index)
        }
        item.updatedAt = Date()
    }
}

// MARK: - Document Tips View

struct DocumentTipsView: View {
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                Label("Document Tips", systemImage: "lightbulb")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("• Keep user manuals for warranty claims")
                    .font(.caption2)
                Text("• Store purchase invoices for proof")
                    .font(.caption2)
                Text("• Add appraisal documents for valuables")
                    .font(.caption2)
                Text("• Include service records for maintenance")
                    .font(.caption2)
            }
            .foregroundColor(.secondary)
        }
    }
}

//
// Layer: App
// Module: ClaimPreviewView
// Purpose: Preview generated insurance claim documents
//

import ComposableArchitecture
import SwiftUI
import PDFKit
import QuickLook

struct ClaimPreviewView: View {
    let claim: GeneratedClaim
    @Environment(\.dismiss) private var dismiss

    @State private var showingQuickLook = false
    @State private var documentURL: URL?
    @State private var isExporting = false
    @State private var exportURL: URL?

    @Dependency(\.insuranceClaimService) var claimService

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Document info header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: claim.format == .pdf ? "doc.fill" : "doc.text.fill")
                            .foregroundColor(.blue)
                            .font(.title2)

                        VStack(alignment: .leading) {
                            Text(claim.filename)
                                .font(.headline)
                                .fontWeight(.medium)

                            Text("\(claim.format.rawValue) • Generated \(formatDate(claim.generatedAt))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Text(formatFileSize(claim.documentData.count))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Claim details
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Claim Type")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(claim.request.claimType.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }

                        Spacer()

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Insurance Company")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(claim.request.insuranceCompany.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }

                        Spacer()

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(claim.request.items.count)")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))

                // Document preview
                if claim.format == .pdf || claim.format == .detailedPDF || claim.format == .militaryFormat {
                    PDFPreviewView(data: claim.documentData)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if claim.format == .htmlPackage {
                    HTMLPreviewView(data: claim.documentData)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    TextPreviewView(data: claim.documentData, format: claim.format)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Action buttons
                VStack(spacing: 12) {
                    if !claim.checklistItems.isEmpty {
                        ChecklistView(items: claim.checklistItems)
                    }

                    HStack(spacing: 12) {
                        Button("View in QuickLook") {
                            Task {
                                await prepareQuickLook()
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(isExporting)

                        Button("Export & Share") {
                            Task {
                                await exportDocument()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isExporting)
                    }

                    if isExporting {
                        ProgressView("Preparing document...")
                            .font(.caption)
                    }
                }
                .padding()
            }
            .navigationTitle("Claim Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Share Document") {
                            Task { await exportDocument() }
                        }

                        Button("View Instructions") {
                            // Show submission instructions
                        }

                        Button("Track Claim Status") {
                            // Open claim tracking
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .quickLookPreview($documentURL)
        .sheet(item: Binding<QuickLookDocument?>(
            get: { exportURL != nil ? QuickLookDocument(url: exportURL!) : nil },
            set: { _ in exportURL = nil }
        )) { document in
            QuickLookShareView(url: document.url)
        }
    }

    // MARK: - Helper Views

    private func ChecklistView(items: [String]) -> some View {
        GroupBox("Submission Checklist") {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Image(systemName: item.hasPrefix("✓") ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(item.hasPrefix("✓") ? .green : .gray)

                        Text(item.hasPrefix("✓") || item.hasPrefix("□") ? String(item.dropFirst(2)) : item)
                            .font(.caption)

                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func prepareQuickLook() async {
        isExporting = true
        defer { isExporting = false }

        do {
            let url = try await claimService.exportClaim(claim)
            await MainActor.run {
                documentURL = url
                showingQuickLook = true
            }
        } catch {
            print("Failed to prepare QuickLook: \(error)")
        }
    }

    private func exportDocument() async {
        isExporting = true
        defer { isExporting = false }

        do {
            let url = try await claimService.exportClaim(claim, includePhotos: true)
            await MainActor.run {
                exportURL = url
            }
        } catch {
            print("Failed to export document: \(error)")
        }
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Preview Components

private struct PDFPreviewView: View {
    let data: Data

    var body: some View {
        if let pdfDocument = PDFDocument(data: data) {
            PDFKitView(document: pdfDocument)
        } else {
            ContentUnavailableView(
                "PDF Preview Unavailable",
                systemImage: "doc.fill",
                description: Text("Unable to load PDF document for preview")
            )
        }
    }
}

private struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context _: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        return pdfView
    }

    func updateUIView(_: PDFView, context _: Context) {
        // No updates needed
    }
}

private struct HTMLPreviewView: View {
    let data: Data

    var body: some View {
        if let htmlString = String(data: data, encoding: .utf8) {
            WebView(htmlContent: htmlString)
        } else {
            ContentUnavailableView(
                "HTML Preview Unavailable",
                systemImage: "globe",
                description: Text("Unable to load HTML document for preview")
            )
        }
    }
}

private struct WebView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context _: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context _: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

import WebKit

private struct TextPreviewView: View {
    let data: Data
    let format: ClaimDocumentFormat

    var body: some View {
        ScrollView {
            if let content = String(data: data, encoding: .utf8) {
                if format == .structuredJSON {
                    CodeView(content: content, language: "json")
                } else {
                    Text(content)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                }
            } else {
                ContentUnavailableView(
                    "Preview Unavailable",
                    systemImage: "doc.text",
                    description: Text("Unable to preview this document format")
                )
            }
        }
    }
}

private struct CodeView: View {
    let content: String
    let language: String

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            Text(content)
                .font(.system(.caption2, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.black.opacity(0.05))
    }
}

// MARK: - Supporting Types

private struct QuickLookDocument: Identifiable {
    let id = UUID()
    let url: URL
}

private struct QuickLookShareView: View {
    let url: URL

    var body: some View {
        ShareSheet(items: [url])
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {
        // No updates needed
    }
}

// MARK: - Preview

#Preview {
    let mockRequest = ClaimRequest(
        claimType: .fire,
        insuranceCompany: .stateFarm,
        items: [],
        incidentDate: Date(),
        incidentDescription: "House fire caused damage to personal belongings",
        contactInfo: ClaimContactInfo(
            name: "John Doe",
            phone: "555-0123",
            email: "john@example.com",
            address: "123 Main St, Anytown, ST 12345"
        )
    )

    let mockClaim = GeneratedClaim(
        request: mockRequest,
        documentData: "Mock PDF Data".data(using: .utf8)!,
        filename: "Insurance_Claim_Fire_StateFarm_2024-01-15.pdf",
        format: .standardPDF,
        checklistItems: [
            "✓ Review all item details for accuracy",
            "□ Police report",
            "□ Fire department report",
            "✓ Photos of damage",
        ],
        submissionInstructions: "Submit to State Farm online or by phone."
    )

    ClaimPreviewView(claim: mockClaim)
}

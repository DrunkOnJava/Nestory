//
// Layer: App
// Module: Settings
// Purpose: Import and export functionality including insurance reports
//

import SwiftData
import SwiftUI

struct ImportExportSettingsView: View {
    @Query private var items: [Item]
    @Query private var categories: [Category]
    @Query private var rooms: [Room]
    @Environment(\.modelContext) private var modelContext

    @StateObject private var insuranceReportService = InsuranceReportService()
    @StateObject private var importExportService = ImportExportService()
    @StateObject private var insuranceExportService = InsuranceExportService()

    @State private var showingExportOptions = false
    @State private var showingInsuranceReportOptions = false
    @State private var isGeneratingReport = false
    @State private var reportError: Error?
    @State private var showingImportPicker = false
    @State private var importResult: ImportExportService.ImportResult?
    @State private var showingImportResult = false
    @State private var showingInsuranceExportOptions = false

    var body: some View {
        Section("Import & Export") {
            Button(action: { showingExportOptions = true }) {
                Label("Export Data", systemImage: "square.and.arrow.up")
            }

            Button(action: { showingImportPicker = true }) {
                Label("Import Data", systemImage: "square.and.arrow.down")
            }

            Button(action: { showingInsuranceReportOptions = true }) {
                if isGeneratingReport {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                        Text("Generating Report...")
                    }
                } else {
                    Label("Generate Insurance Report", systemImage: "doc.text")
                }
            }
            .disabled(items.isEmpty || isGeneratingReport)

            // REMINDER: InsuranceExportService is wired here!
            Button(action: { showingInsuranceExportOptions = true }) {
                if insuranceExportService.isExporting {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                        Text("Exporting... \(Int(insuranceExportService.exportProgress * 100))%")
                    }
                } else {
                    Label("Export for Insurance Company", systemImage: "doc.richtext")
                }
            }
            .disabled(items.isEmpty || insuranceExportService.isExporting)
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportOptionsView(items: items, categories: categories)
        }
        .sheet(isPresented: $showingInsuranceReportOptions) {
            InsuranceReportOptionsView(
                items: items,
                categories: categories,
                insuranceReportService: insuranceReportService,
                isGenerating: $isGeneratingReport,
            )
        }
        .sheet(isPresented: $showingInsuranceExportOptions) {
            InsuranceExportOptionsView(
                items: items,
                categories: categories,
                rooms: rooms,
                exportService: insuranceExportService,
            )
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json, .commaSeparatedText],
            allowsMultipleSelection: false,
        ) { result in
            Task {
                switch result {
                case let .success(urls):
                    if let url = urls.first {
                        await handleImport(url: url)
                    }
                case let .failure(error):
                    importResult = ImportExportService.ImportResult(
                        itemsImported: 0,
                        itemsSkipped: 0,
                        errors: [error.localizedDescription],
                    )
                    showingImportResult = true
                }
            }
        }
        .alert("Import Complete", isPresented: $showingImportResult) {
            Button("OK") {}
        } message: {
            if let importResult {
                Text(importResult.summary)
            }
        }
        .alert("Report Error", isPresented: .constant(reportError != nil)) {
            Button("OK") { reportError = nil }
        } message: {
            Text(reportError?.localizedDescription ?? "An error occurred while generating the report.")
        }
    }

    @MainActor
    private func handleImport(url: URL) async {
        do {
            // Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                throw ImportExportService.ImportError.dataConversionError
            }
            defer { url.stopAccessingSecurityScopedResource() }

            // Determine file type and import
            if url.pathExtension.lowercased() == "csv" {
                importResult = try await importExportService.importCSV(from: url, modelContext: modelContext)
            } else if url.pathExtension.lowercased() == "json" {
                importResult = try await importExportService.importJSON(from: url, modelContext: modelContext)
            } else {
                throw ImportExportService.ImportError.invalidFormat
            }

            showingImportResult = true
        } catch {
            importResult = ImportExportService.ImportResult(
                itemsImported: 0,
                itemsSkipped: 0,
                errors: [error.localizedDescription],
            )
            showingImportResult = true
        }
    }
}

#Preview {
    Form {
        ImportExportSettingsView()
            .modelContainer(for: [Item.self, Category.self, Room.self], inMemory: true)
    }
}

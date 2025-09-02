//
// Layer: App
// Module: Settings
// Purpose: TCA-driven import and export functionality including insurance reports
//
// 🏗️ TCA PATTERN: Progressive dependency injection conversion
// - Converting @StateObject to @Dependency for services with protocols
// - ImportExportService: ✅ CONVERTED to TCA dependency injection
// - InsuranceReportService, InsuranceExportService: ⏳ PENDING protocol creation

import ComposableArchitecture
import SwiftData
import SwiftUI

struct ImportExportSettingsView: View {
    @Query private var items: [Item]
    @Query private var categories: [Category]
    @Query private var rooms: [Room]
    @Environment(\.modelContext) private var modelContext

    @Dependency(\.insuranceReportService) var insuranceReportService
    @Dependency(\.importExportService) var importExportService
    @State private var insuranceExportService = InsuranceExportService()
    @StateObject private var cloudStorageManager = CloudStorageManager()

    // REMINDER: any InsuranceReportService, ImportExportService, InsuranceExportService, and CloudStorageManager are all wired here!

    @State private var showingExportOptions = false
    @State private var showingInsuranceReportOptions = false
    @State private var isGeneratingReport = false
    @State private var reportError: (any Error)?
    @State private var showingImportPicker = false
    @State private var importSuccessCount: Int?
    @State private var showingImportResult = false
    @State private var importResult: ImportResult?
    @State private var showingInsuranceExportOptions = false
    @State private var showingClaimSubmission = false
    @State private var showingCloudStorageOptions = false
    @State private var cloudUploadURL: String?
    @State private var showingCloudUploadResult = false

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

            // REMINDER: ClaimSubmissionView is wired here!
            Button(action: { showingClaimSubmission = true }) {
                Label("Submit Insurance Claim", systemImage: "paperplane.fill")
            }
            .disabled(items.isEmpty)
            
            // REMINDER: CloudStorageManager is wired here!
            Button(action: { showingCloudStorageOptions = true }) {
                if cloudStorageManager.isUploading {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                        Text("Uploading... \(Int(cloudStorageManager.uploadProgress * 100))%")
                    }
                } else {
                    Label("Backup to Cloud Storage", systemImage: "icloud.and.arrow.up")
                }
            }
            .disabled(items.isEmpty || cloudStorageManager.isUploading)
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
        .sheet(isPresented: $showingClaimSubmission) {
            ClaimSubmissionView()
        }
        .sheet(isPresented: $showingCloudStorageOptions) {
            CloudStorageOptionsView(
                items: items,
                cloudStorageManager: cloudStorageManager,
                onUploadComplete: { url in
                    cloudUploadURL = url
                    showingCloudUploadResult = true
                }
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
                    importResult = ImportResult(
                        itemsImported: 0,
                        itemsSkipped: 0,
                        errors: [error.localizedDescription],
                        warnings: [],
                        fileSize: 0,
                        processingTime: 0,
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
        .alert("Cloud Backup Complete", isPresented: $showingCloudUploadResult) {
            Button("OK") { cloudUploadURL = nil }
        } message: {
            if let cloudUploadURL = cloudUploadURL {
                Text("Your data has been successfully backed up to cloud storage. URL: \(cloudUploadURL)")
            }
        }
    }

    @MainActor
    private func handleImport(url: URL) async {
        do {
            // Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                throw ImportError.dataConversionError("Invalid file format")
            }
            defer { url.stopAccessingSecurityScopedResource() }

            // Determine file type and import
            if url.pathExtension.lowercased() == "csv" {
                importResult = try await importExportService.importCSV(from: url, modelContext: modelContext)
            } else if url.pathExtension.lowercased() == "json" {
                importResult = try await importExportService.importJSON(from: url, modelContext: modelContext)
            } else {
                throw ImportError.invalidFormat("Unsupported file format")
            }

            showingImportResult = true
        } catch {
            importResult = ImportResult(
                itemsImported: 0,
                itemsSkipped: 0,
                errors: [error.localizedDescription],
                warnings: [],
                fileSize: 0,
                processingTime: 0,
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

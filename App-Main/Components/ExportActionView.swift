//
// Layer: App
// Module: Components
// Purpose: Export action button component for insurance exports
//

import SwiftUI

struct ExportActionView: View {
    let items: [Item]
    let categories: [Category]
    let selectedFormat: InsuranceExportService.ExportFormat
    let exportOptions: ExportOptions
    let exportService: InsuranceExportService
    
    @State private var isExporting = false
    @State private var exportError: Error?
    @State private var showingExportError = false
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?
    
    var body: some View {
        Section {
            ExportButton(
                isExporting: isExporting || exportService.isExporting,
                exportProgress: exportService.exportProgress,
                items: items,
                onExport: performExport
            )
        }
        .alert("Export Error", isPresented: $showingExportError) {
            Button("OK") {}
        } message: {
            Text(exportError?.localizedDescription ?? "Failed to export inventory")
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    private func performExport() {
        isExporting = true
        
        Task {
            do {
                let result = try await exportService.exportInventory(
                    items: items,
                    categories: categories,
                    format: selectedFormat,
                    options: exportOptions
                )
                
                await MainActor.run {
                    exportedFileURL = result.fileURL
                    showingShareSheet = true
                    isExporting = false
                }
            } catch {
                await MainActor.run {
                    exportError = error
                    showingExportError = true
                    isExporting = false
                }
            }
        }
    }
}

private struct ExportButton: View {
    let isExporting: Bool
    let exportProgress: Double
    let items: [Item]
    let onExport: () -> Void
    
    var body: some View {
        Button(action: onExport) {
            if isExporting {
                ExportProgressView(progress: exportProgress)
            } else {
                ExportButtonLabel()
            }
        }
        .disabled(isExporting || items.isEmpty)
    }
}

private struct ExportProgressView: View {
    let progress: Double
    
    var body: some View {
        HStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Text("Exporting... \(Int(progress * 100))%")
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ExportButtonLabel: View {
    var body: some View {
        Text("Export for Insurance")
            .frame(maxWidth: .infinity)
            .fontWeight(.semibold)
    }
}

#Preview {
    NavigationStack {
        Form {
            ExportActionView(
                items: [],
                categories: [],
                selectedFormat: .standardForm,
                exportOptions: ExportOptions(),
                exportService: InsuranceExportService()
            )
        }
    }
}
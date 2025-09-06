//
//  InsuranceExportOptionsView.swift
//  Nestory
//
//  REMINDER: This view is WIRED UP in SettingsView
//  Provides export options specifically formatted for insurance companies

import SwiftData
import SwiftUI

struct InsuranceExportOptionsView: View {
    let items: [Item]
    let categories: [Category]
    let exportService: InsuranceExportService

    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat = InsuranceExportService.ExportFormat.standardForm
    @State private var exportOptions = ExportOptions()

    var body: some View {
        NavigationStack {
            Form {
                FormatSelectionView(selectedFormat: $selectedFormat)
                PolicyInformationView(exportOptions: $exportOptions)
                ExportOptionsConfigView(exportOptions: $exportOptions)
                ExportSummaryView(items: items, selectedFormat: selectedFormat)
                ExportActionView(
                    items: items,
                    categories: categories,
                    selectedFormat: selectedFormat,
                    exportOptions: exportOptions,
                    exportService: exportService
                )
            }
            .navigationTitle("Insurance Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    InsuranceExportOptionsView(
        items: [],
        categories: [],
        exportService: InsuranceExportService()
    )
}
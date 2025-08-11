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
    let rooms: [Room]
    let exportService: InsuranceExportService

    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat = InsuranceExportService.ExportFormat.standardForm
    @State private var exportOptions = ExportOptions()
    @State private var isExporting = false
    @State private var exportError: Error?
    @State private var showingExportError = false
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?

    var body: some View {
        NavigationStack {
            Form {
                // Format Selection
                Section("Export Format") {
                    ForEach(InsuranceExportService.ExportFormat.allCases, id: \.self) { format in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(format.rawValue)
                                    .font(.headline)
                                Text(formatDescription(format))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if selectedFormat == format {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFormat = format
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Policy Information
                Section("Policy Information (Optional)") {
                    TextField("Policy Holder Name", text: .init(
                        get: { exportOptions.policyHolderName ?? "" },
                        set: { exportOptions.policyHolderName = $0.isEmpty ? nil : $0 },
                    ))

                    TextField("Policy Number", text: .init(
                        get: { exportOptions.policyNumber ?? "" },
                        set: { exportOptions.policyNumber = $0.isEmpty ? nil : $0 },
                    ))

                    TextField("Property Address", text: .init(
                        get: { exportOptions.propertyAddress ?? "" },
                        set: { exportOptions.propertyAddress = $0.isEmpty ? nil : $0 },
                    ))
                    .textContentType(.fullStreetAddress)
                }

                // Export Options
                Section("Include in Export") {
                    Toggle("Photos", isOn: $exportOptions.includePhotos)
                    Toggle("Receipts", isOn: $exportOptions.includeReceipts)
                    Toggle("Warranty Information", isOn: $exportOptions.includeWarrantyInfo)
                    Toggle("Group by Room", isOn: $exportOptions.groupByRoom)

                    VStack(alignment: .leading) {
                        Toggle("Calculate Depreciation", isOn: $exportOptions.includeDepreciation)

                        if exportOptions.includeDepreciation {
                            HStack {
                                Text("Annual Rate:")
                                Slider(value: $exportOptions.depreciationRate, in: 0.05 ... 0.25, step: 0.05)
                                Text("\(Int(exportOptions.depreciationRate * 100))%")
                                    .frame(width: 40)
                            }
                            .font(.caption)
                        }
                    }
                }

                // Statistics
                Section("Export Summary") {
                    HStack {
                        Text("Total Items")
                        Spacer()
                        Text("\(items.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Total Value")
                        Spacer()
                        Text(formatCurrency(totalValue))
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Items with Photos")
                        Spacer()
                        Text("\(itemsWithPhotos)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Items with Receipts")
                        Spacer()
                        Text("\(itemsWithReceipts)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Format")
                        Spacer()
                        Text(".\(selectedFormat.fileExtension)")
                            .foregroundColor(.secondary)
                            .font(.system(.body, design: .monospaced))
                    }
                }

                // Export Button
                Section {
                    Button(action: performExport) {
                        if isExporting || exportService.isExporting {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Exporting... \(Int(exportService.exportProgress * 100))%")
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Text("Export for Insurance")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isExporting || items.isEmpty)
                }
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
            .alert("Export Error", isPresented: $showingExportError) {
                Button("OK") {}
            } message: {
                Text(exportError?.localizedDescription ?? "Failed to export inventory")
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportedFileURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    // MARK: - Helper Methods

    private var totalValue: Decimal {
        items.compactMap(\.purchasePrice).reduce(0, +)
    }

    private var itemsWithPhotos: Int {
        items.count(where: { $0.imageData != nil })
    }

    private var itemsWithReceipts: Int {
        items.count(where: { $0.receiptImageData != nil })
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: value as NSNumber) ?? "$0"
    }

    private func formatDescription(_ format: InsuranceExportService.ExportFormat) -> String {
        switch format {
        case .standardForm:
            "PDF with photos and values for claims"
        case .detailedSpreadsheet:
            "Excel-compatible CSV with all data"
        case .digitalPackage:
            "ZIP file with all photos and documents"
        case .xmlFormat:
            "Industry-standard XML format"
        case .claimsReady:
            "Complete package for adjusters"
        }
    }

    private func performExport() {
        isExporting = true

        Task {
            do {
                let result = try await exportService.exportInventory(
                    items: items,
                    categories: categories,
                    rooms: rooms,
                    format: selectedFormat,
                    options: exportOptions,
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

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}

#Preview {
    InsuranceExportOptionsView(
        items: [],
        categories: [],
        rooms: [],
        exportService: InsuranceExportService(),
    )
}

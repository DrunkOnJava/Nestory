//
// Layer: UI
// Module: Components
// Purpose: Export options view for data export functionality
//

import SwiftUI

public struct ExportOptionsView: View {
    let items: [Item]
    let categories: [Category]
    @Environment(\.dismiss) private var dismiss
    @State private var exportFormat: ExportFormat = .json
    @State private var includeImages = false
    @State private var isExporting = false

    public enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV"
        case pdf = "PDF Report"

        var icon: String {
            switch self {
            case .json: "doc.text"
            case .csv: "tablecells"
            case .pdf: "doc.richtext"
            }
        }
    }

    public init(items: [Item], categories: [Category]) {
        self.items = items
        self.categories = categories
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Export Format") {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        HStack {
                            Image(systemName: format.icon)
                                .foregroundColor(.accentColor)
                                .frame(width: 30)

                            Text(format.rawValue)

                            Spacer()

                            if exportFormat == format {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            exportFormat = format
                        }
                    }
                }

                Section("Options") {
                    Toggle("Include Images", isOn: $includeImages)
                        .disabled(exportFormat == .csv)

                    HStack {
                        Text("Items to Export")
                        Spacer()
                        Text("\(items.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Estimated Size")
                        Spacer()
                        Text(estimatedSize())
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    Button(action: performExport) {
                        if isExporting {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                                Text("Exporting...")
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Text("Export")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isExporting || items.isEmpty)
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func estimatedSize() -> String {
        var size = items.count * 500 // Base size per item
        if includeImages {
            size += items.compactMap { $0.imageData?.count }.reduce(0, +)
        }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        return formatter.string(fromByteCount: Int64(size))
    }

    private func performExport() {
        isExporting = true

        Task {
            let importExportService = ImportExportService()
            var exportData: Data?
            var fileName: String

            switch exportFormat {
            case .csv:
                exportData = importExportService.exportToCSV(items: items)
                fileName = "Nestory_Export_\(Date().formatted(date: .abbreviated, time: .omitted)).csv"
            case .json:
                exportData = importExportService.exportToJSON(items: items)
                fileName = "Nestory_Export_\(Date().formatted(date: .abbreviated, time: .omitted)).json"
            case .pdf:
                // Use InsuranceReportService for PDF
                let reportService = InsuranceReportService()
                do {
                    exportData = try await reportService.generateInsuranceReport(
                        items: items,
                        categories: categories,
                        options: InsuranceReportService.ReportOptions()
                    )
                    fileName = "Nestory_Report_\(Date().formatted(date: .abbreviated, time: .omitted)).pdf"
                } catch {
                    print("PDF generation error: \(error)")
                    isExporting = false
                    return
                }
            }

            if let data = exportData {
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                do {
                    try data.write(to: tempURL)

                    await MainActor.run {
                        let activityVC = UIActivityViewController(
                            activityItems: [tempURL],
                            applicationActivities: nil
                        )

                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first,
                           let rootVC = window.rootViewController
                        {
                            if let popover = activityVC.popoverPresentationController {
                                popover.sourceView = rootVC.view
                                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                                popover.permittedArrowDirections = []
                            }

                            rootVC.present(activityVC, animated: true) {
                                isExporting = false
                                dismiss()
                            }
                        }
                    }
                } catch {
                    print("Export error: \(error)")
                    isExporting = false
                }
            } else {
                isExporting = false
            }
        }
    }
}

#Preview {
    ExportOptionsView(items: [], categories: [])
}

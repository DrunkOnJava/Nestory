//
// Layer: App
// Module: Components
// Purpose: Export summary display component for insurance exports
//

import SwiftUI

struct ExportSummaryView: View {
    let items: [Item]
    let selectedFormat: InsuranceExportService.ExportFormat
    
    var body: some View {
        Section("Export Summary") {
            ExportSummaryRow(label: "Total Items", value: "\(items.count)")
            ExportSummaryRow(label: "Total Value", value: formatCurrency(totalValue))
            ExportSummaryRow(label: "Items with Photos", value: "\(itemsWithPhotos)")
            ExportSummaryRow(label: "Items with Receipts", value: "\(itemsWithReceipts)")
            FormatRow(selectedFormat: selectedFormat)
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalValue: Decimal {
        items.compactMap(\.purchasePrice).reduce(0, +)
    }
    
    private var itemsWithPhotos: Int {
        items.count { $0.imageData != nil }
    }
    
    private var itemsWithReceipts: Int {
        items.count { $0.receiptImageData != nil }
    }
    
    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: value as NSNumber) ?? "$0"
    }
}

private struct ExportSummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

private struct FormatRow: View {
    let selectedFormat: InsuranceExportService.ExportFormat
    
    var body: some View {
        HStack {
            Text("Format")
            Spacer()
            Text(".\(selectedFormat.fileExtension)")
                .foregroundColor(.secondary)
                .font(.system(.body, design: .monospaced))
        }
    }
}

#Preview {
    NavigationStack {
        Form {
            ExportSummaryView(
                items: [],
                selectedFormat: .standardForm
            )
        }
    }
}
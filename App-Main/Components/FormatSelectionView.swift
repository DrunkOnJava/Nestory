//
// Layer: App
// Module: Components
// Purpose: Format selection component for insurance exports
//

import SwiftUI

struct FormatSelectionView: View {
    @Binding var selectedFormat: InsuranceExportService.ExportFormat
    
    var body: some View {
        Section("Export Format") {
            ForEach(InsuranceExportService.ExportFormat.allCases, id: \.self) { format in
                FormatOptionRow(
                    format: format,
                    isSelected: selectedFormat == format
                ) {
                    selectedFormat = format
                }
            }
        }
    }
}

private struct FormatOptionRow: View {
    let format: InsuranceExportService.ExportFormat
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(format.rawValue)
                    .font(.headline)
                Text(formatDescription(format))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
                    .accessibilityLabel("Selected")
            }
        }
        .contentShape(Rectangle())
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
            onSelect()
        }
        .padding(.vertical, 4)
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
}

#Preview {
    NavigationStack {
        Form {
            FormatSelectionView(selectedFormat: .constant(.standardForm))
        }
    }
}
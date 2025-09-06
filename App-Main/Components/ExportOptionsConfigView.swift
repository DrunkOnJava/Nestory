//
// Layer: App
// Module: Components
// Purpose: Export options configuration component for insurance exports
//

import SwiftUI

struct ExportOptionsConfigView: View {
    @Binding var exportOptions: ExportOptions
    
    var body: some View {
        Section("Include in Export") {
            BasicExportToggles(exportOptions: $exportOptions)
            DepreciationSection(exportOptions: $exportOptions)
        }
    }
}

private struct BasicExportToggles: View {
    @Binding var exportOptions: ExportOptions
    
    var body: some View {
        Toggle("Photos", isOn: $exportOptions.includePhotos)
        Toggle("Receipts", isOn: $exportOptions.includeReceipts)
        Toggle("Warranty Information", isOn: $exportOptions.includeWarrantyInfo)
    }
}

private struct DepreciationSection: View {
    @Binding var exportOptions: ExportOptions
    
    var body: some View {
        VStack(alignment: .leading) {
            Toggle("Calculate Depreciation", isOn: $exportOptions.includeDepreciation)
            
            if exportOptions.includeDepreciation {
                DepreciationRateSlider(exportOptions: $exportOptions)
            }
        }
    }
}

private struct DepreciationRateSlider: View {
    @Binding var exportOptions: ExportOptions
    
    var body: some View {
        HStack {
            Text("Annual Rate:")
            Slider(value: $exportOptions.depreciationRate, in: 0.05...0.25, step: 0.05)
            Text("\(Int(exportOptions.depreciationRate * 100))%")
                .frame(width: 40)
        }
        .font(.caption)
    }
}

#Preview {
    NavigationStack {
        Form {
            ExportOptionsConfigView(exportOptions: .constant(ExportOptions()))
        }
    }
}
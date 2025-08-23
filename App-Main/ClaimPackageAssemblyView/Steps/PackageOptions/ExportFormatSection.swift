//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/PackageOptions
// Purpose: Export format selection for package output
//

import SwiftUI

public struct ExportFormatSection: View {
    @Binding public var primaryFormat: ExportFormat
    
    public init(primaryFormat: Binding<ExportFormat>) {
        self._primaryFormat = primaryFormat
    }
    
    public var body: some View {
        Section("Export Format") {
            Picker("Primary Format", selection: $primaryFormat) {
                Text("PDF").tag(ExportFormat.pdf)
                Text("HTML").tag(ExportFormat.html)
                Text("Spreadsheet").tag(ExportFormat.spreadsheet)
            }
        }
    }
}

#Preview {
    Form {
        ExportFormatSection(primaryFormat: .constant(.pdf))
    }
}
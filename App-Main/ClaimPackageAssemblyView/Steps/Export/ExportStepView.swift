//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/Export
// Purpose: Export step view with package sharing capabilities
//

import SwiftUI

public struct ExportStepView: View {
    public let generatedPackage: ClaimPackage?
    public let onExportAction: @Sendable () -> Void
    
    public init(
        generatedPackage: ClaimPackage?,
        onExportAction: @escaping @Sendable () -> Void
    ) {
        self.generatedPackage = generatedPackage
        self.onExportAction = onExportAction
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            if let package = generatedPackage {
                ExportReadyView(
                    package: package,
                    onExportAction: onExportAction
                )
            } else {
                ExportUnavailableView()
            }
        }
        .padding()
    }
}

#Preview {
    ExportStepView(
        generatedPackage: nil,
        onExportAction: {}
    )
}
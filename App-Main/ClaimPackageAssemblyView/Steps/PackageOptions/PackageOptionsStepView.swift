//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/PackageOptions
// Purpose: Package configuration options with documentation level and format selection
//

import SwiftUI

public struct PackageOptionsStepView: View {
    @Binding public var options: ClaimPackageOptions
    public let onAdvancedOptions: @Sendable () -> Void
    
    public init(
        options: Binding<ClaimPackageOptions>,
        onAdvancedOptions: @escaping @Sendable () -> Void
    ) {
        self._options = options
        self.onAdvancedOptions = onAdvancedOptions
    }
    
    public var body: some View {
        Form {
            DocumentationLevelSection(documentationLevel: $options.documentationLevel)
            
            IncludePhotosSection(
                includePhotos: $options.includePhotos,
                includeReceipts: $options.includeReceipts,
                includeWarranties: $options.includeWarranties
            )
            
            ExportFormatSection(primaryFormat: $options.primaryFormat)
            
            AdvancedOptionsSection(onAdvancedOptions: onAdvancedOptions)
        }
    }
}

#Preview {
    @Previewable @State var options = ClaimPackageOptions()
    PackageOptionsStepView(
        options: $options,
        onAdvancedOptions: {}
    )
}
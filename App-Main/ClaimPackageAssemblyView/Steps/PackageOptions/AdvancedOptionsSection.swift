//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/PackageOptions
// Purpose: Advanced options navigation section
//

import SwiftUI

public struct AdvancedOptionsSection: View {
    public let onAdvancedOptions: @Sendable () -> Void
    
    public init(onAdvancedOptions: @escaping @Sendable () -> Void) {
        self.onAdvancedOptions = onAdvancedOptions
    }
    
    public var body: some View {
        Section(content: {
            Button("Advanced Package Options") {
                onAdvancedOptions()
            }
        })
    }
}

#Preview {
    Form {
        AdvancedOptionsSection(onAdvancedOptions: {})
    }
}
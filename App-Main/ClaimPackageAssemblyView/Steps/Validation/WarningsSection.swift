//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/Validation
// Purpose: Warnings section displaying validation issues
//

import SwiftUI

public struct WarningsSection: View {
    public let warnings: [String]
    
    public init(warnings: [String]) {
        self.warnings = warnings
    }
    
    public var body: some View {
        Section("Warnings") {
            ForEach(warnings, id: \.self) { warning in
                Label(warning, systemImage: "exclamationmark.triangle")
                    .foregroundColor(.orange)
            }
        }
    }
}

#Preview {
    Form {
        WarningsSection(warnings: [
            "Some items are missing purchase prices",
            "Some items don't have photos",
            "Incident description could be more detailed"
        ])
    }
}
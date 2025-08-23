//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/Export
// Purpose: Unavailable export state view
//

import SwiftUI

public struct ExportUnavailableView: View {
    public init() {}
    
    public var body: some View {
        Text("No package available for export")
            .foregroundColor(.secondary)
    }
}

#Preview {
    ExportUnavailableView()
}
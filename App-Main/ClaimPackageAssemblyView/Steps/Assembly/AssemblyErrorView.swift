//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/Assembly
// Purpose: Error state view for failed package assembly
//

import SwiftUI

public struct AssemblyErrorView: View {
    public let error: ErrorAlert
    
    public init(error: ErrorAlert) {
        self.error = error
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Assembly Failed")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(error.message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    AssemblyErrorView(
        error: ErrorAlert(
            message: "Assembly Failed: Failed to generate package due to missing required information."
        )
    )
}
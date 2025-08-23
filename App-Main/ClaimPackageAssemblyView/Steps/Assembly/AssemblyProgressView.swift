//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/Assembly
// Purpose: Progress state view for ongoing package assembly
//

import SwiftUI

public struct AssemblyProgressView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Assembling Package...")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("This may take a moment while we process your items and generate documentation.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    AssemblyProgressView()
}
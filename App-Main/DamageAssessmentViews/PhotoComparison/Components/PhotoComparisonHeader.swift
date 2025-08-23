//
// Layer: App-Main
// Module: DamageAssessment/PhotoComparison/Components
// Purpose: Header component for photo comparison view
//

import SwiftUI

public struct PhotoComparisonHeader: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 40))
                .foregroundColor(.blue)

            Text("Photo Documentation")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Capture before, after, and detail photos to document the damage")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
}

#Preview {
    PhotoComparisonHeader()
}
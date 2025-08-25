//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/AutoDetection
// Purpose: Header component for auto-detection results
//

import SwiftUI

public struct AutoDetectionHeader: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("Warranty Detected")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("We found warranty information for this item")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top)
    }
}

#Preview {
    AutoDetectionHeader()
}
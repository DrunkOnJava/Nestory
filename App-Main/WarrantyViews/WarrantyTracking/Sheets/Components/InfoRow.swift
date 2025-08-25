//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/Components
// Purpose: Information display row component for warranty details
//

import SwiftUI

public struct InfoRow: View {
    public let label: String
    public let value: String
    
    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    public var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    VStack {
        InfoRow(label: "Provider", value: "Apple Inc.")
        InfoRow(label: "Duration", value: "12 months")
        InfoRow(label: "Cost", value: "$199.99")
    }
    .padding()
}
//
// Layer: App-Main
// Module: InsuranceClaim/Components
// Purpose: Summary display row for claim information
//

import SwiftUI

public struct SummaryRow: View {
    public let label: String
    public let value: String
    
    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    public var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    VStack {
        SummaryRow(label: "Claim Type", value: "Fire Damage")
        SummaryRow(label: "Insurance Company", value: "State Farm")
        SummaryRow(label: "Estimated Value", value: "$2,500.00")
    }
    .padding()
}
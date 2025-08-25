//
// Layer: UI
// Module: Components
// Purpose: Shared info row component for displaying label-value pairs
//

import SwiftUI

public struct InfoRow: View {
    let label: String
    let value: String

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
    InfoRow(label: "Label", value: "Value")
        .padding()
}
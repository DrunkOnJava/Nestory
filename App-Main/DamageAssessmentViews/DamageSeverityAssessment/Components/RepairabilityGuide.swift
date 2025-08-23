//
// Layer: App-Main
// Module: DamageAssessment/DamageSeverityAssessment/Components
// Purpose: Context-sensitive repair guidance based on damage severity level
//

import SwiftUI

public struct RepairabilityGuide: View {
    let severity: DamageSeverity

    public init(severity: DamageSeverity) {
        self.severity = severity
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repair Considerations:")
                .font(.caption)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 4) {
                switch severity {
                case .minor:
                    Text("• Simple repairs or cleaning usually sufficient")
                    Text("• DIY repairs often possible")
                    Text("• Quick turnaround expected")
                case .moderate:
                    Text("• Professional repair recommended")
                    Text("• May require part replacement")
                    Text("• Moderate repair time required")
                case .major:
                    Text("• Extensive professional repair needed")
                    Text("• May require multiple specialists")
                    Text("• Consider replacement cost vs repair")
                case .severe:
                    Text("• Significant structural or functional damage")
                    Text("• Specialist assessment required")
                    Text("• Replacement may be necessary")
                case .total:
                    Text("• Replacement typically more cost-effective")
                    Text("• Salvage value may be minimal")
                    Text("• Focus on documentation for insurance")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
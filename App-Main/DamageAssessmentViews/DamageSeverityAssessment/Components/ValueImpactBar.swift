//
// Layer: App-Main
// Module: DamageAssessment/DamageSeverityAssessment/Components
// Purpose: Visual progress bar showing value reduction based on damage severity
//

import SwiftUI

public struct ValueImpactBar: View {
    let severity: DamageSeverity
    let originalValue: Decimal

    public init(severity: DamageSeverity, originalValue: Decimal) {
        self.severity = severity
        self.originalValue = originalValue
    }

    public var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Value Impact")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(Int(severity.valueImpactPercentage * 100))% reduction")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: severity.color))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(Color(hex: severity.color) ?? .gray)
                        .frame(
                            width: geometry.size.width * severity.valueImpactPercentage,
                            height: 8
                        )
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}
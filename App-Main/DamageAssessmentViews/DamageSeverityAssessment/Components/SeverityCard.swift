//
// Layer: App-Main
// Module: DamageAssessment/DamageSeverityAssessment/Components
// Purpose: Individual severity selection card with selection state and styling
//

import SwiftUI

public struct SeverityCard: View {
    let severity: DamageSeverity
    let isSelected: Bool
    let action: () -> Void

    public init(severity: DamageSeverity, isSelected: Bool, action: @escaping () -> Void) {
        self.severity = severity
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: severity.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: severity.color))

                VStack(spacing: 4) {
                    Text(severity.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("\(Int(severity.valueImpactPercentage * 100))% impact")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                isSelected ? (Color(hex: severity.color) ?? .gray).opacity(0.1) : Color(.systemGray6)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? (Color(hex: severity.color) ?? .gray) : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
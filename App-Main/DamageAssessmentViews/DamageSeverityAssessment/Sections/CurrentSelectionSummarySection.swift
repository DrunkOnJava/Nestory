//
// Layer: App-Main
// Module: DamageAssessment/DamageSeverityAssessment/Sections
// Purpose: Summary display of current severity selection with impact details
//

import SwiftUI

public struct CurrentSelectionSummarySection: View {
    let selectedSeverity: DamageSeverity
    
    public init(selectedSeverity: DamageSeverity) {
        self.selectedSeverity = selectedSeverity
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: selectedSeverity.icon)
                        .font(.title2)
                        .foregroundColor(Color(hex: selectedSeverity.color))

                    VStack(alignment: .leading) {
                        Text(selectedSeverity.rawValue)
                            .font(.headline)
                        Text(selectedSeverity.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Insurance Impact:")
                        .font(.caption)
                        .fontWeight(.semibold)

                    Text("Estimated value reduction: \(Int(selectedSeverity.valueImpactPercentage * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }
}
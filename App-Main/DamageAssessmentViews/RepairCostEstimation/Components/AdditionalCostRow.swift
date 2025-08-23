//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Components
// Purpose: Row component for displaying individual additional costs
//

import SwiftUI

public struct AdditionalCostRow: View {
    let additionalCost: CostEstimation.AdditionalCost
    let onDelete: () -> Void

    public init(additionalCost: CostEstimation.AdditionalCost, onDelete: @escaping () -> Void) {
        self.additionalCost = additionalCost
        self.onDelete = onDelete
    }

    public var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: additionalCost.type.icon)
                    .foregroundColor(.red)
                    .font(.caption)

                VStack(alignment: .leading, spacing: 2) {
                    Text(additionalCost.description)
                        .font(.body)
                        .fontWeight(.medium)

                    Text(additionalCost.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                Text("$\(additionalCost.amount.description)")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
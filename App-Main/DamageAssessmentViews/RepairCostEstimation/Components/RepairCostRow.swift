//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Components
// Purpose: Row component for displaying individual repair costs
//

import SwiftUI

public struct RepairCostRow: View {
    let repairCost: CostEstimation.RepairCost
    let onDelete: () -> Void

    public init(repairCost: CostEstimation.RepairCost, onDelete: @escaping () -> Void) {
        self.repairCost = repairCost
        self.onDelete = onDelete
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(repairCost.description)
                    .font(.body)
                    .fontWeight(.medium)

                Text(repairCost.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Text("$\(repairCost.amount.description)")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)

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
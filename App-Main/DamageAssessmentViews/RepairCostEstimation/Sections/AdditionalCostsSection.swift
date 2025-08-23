//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Sections
// Purpose: Additional costs section component for repair cost estimation
//

import SwiftUI

public struct AdditionalCostsSection: View {
    @ObservedObject var core: RepairCostEstimationCore

    public init(core: RepairCostEstimationCore) {
        self.core = core
    }

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Additional Costs", systemImage: "plus.square")
                        .font(.headline)
                        .foregroundColor(.red)

                    Spacer()

                    Button(action: {
                        core.showingAddAdditionalCost = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.red)
                    }
                }

                if core.costEstimation.additionalCosts.isEmpty {
                    Text("No additional costs added yet")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                } else {
                    VStack(spacing: 8) {
                        ForEach(core.costEstimation.additionalCosts) { additionalCost in
                            AdditionalCostRow(additionalCost: additionalCost) {
                                core.removeAdditionalCost(additionalCost)
                            }
                        }

                        Divider()

                        HStack {
                            Text("Total Additional Costs")
                                .font(.body)
                                .fontWeight(.medium)

                            Spacer()

                            Text("$\(core.totalAdditionalCosts.description)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
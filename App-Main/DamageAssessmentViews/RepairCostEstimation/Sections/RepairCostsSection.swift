//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Sections
// Purpose: Repair costs section component for repair cost estimation
//

import SwiftUI

public struct RepairCostsSection: View {
    @ObservedObject var core: RepairCostEstimationCore

    public init(core: RepairCostEstimationCore) {
        self.core = core
    }

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Repair Costs", systemImage: "wrench.and.screwdriver")
                        .font(.headline)
                        .foregroundColor(.orange)

                    Spacer()

                    Button(action: {
                        core.showingAddRepairCost = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                    }
                }

                if core.costEstimation.repairCosts.isEmpty {
                    Text("No repair costs added yet")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                } else {
                    VStack(spacing: 8) {
                        ForEach(core.costEstimation.repairCosts) { repairCost in
                            RepairCostRow(repairCost: repairCost) {
                                core.removeRepairCost(repairCost)
                            }
                        }

                        Divider()

                        HStack {
                            Text("Total Repair Costs")
                                .font(.body)
                                .fontWeight(.medium)

                            Spacer()

                            Text("$\(core.totalRepairCosts.description)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
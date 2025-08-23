//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Sections
// Purpose: Cost summary section component for repair cost estimation
//

import SwiftUI

public struct CostSummarySection: View {
    @ObservedObject var core: RepairCostEstimationCore

    public init(core: RepairCostEstimationCore) {
        self.core = core
    }

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Cost Summary", systemImage: "doc.text.magnifyingglass")
                    .font(.headline)
                    .foregroundColor(.green)

                VStack(spacing: 8) {
                    HStack {
                        Text("Repair Costs:")
                            .font(.body)

                        Spacer()

                        Text("$\(core.totalRepairCosts.description)")
                            .font(.body)
                            .foregroundColor(.orange)
                    }

                    HStack {
                        Text("Additional Costs:")
                            .font(.body)

                        Spacer()

                        Text("$\(core.totalAdditionalCosts.description)")
                            .font(.body)
                            .foregroundColor(.red)
                    }

                    HStack {
                        Text("Labor Cost:")
                            .font(.body)

                        Spacer()

                        Text("$\(core.costEstimation.laborCost.description)")
                            .font(.body)
                            .foregroundColor(.blue)
                    }

                    HStack {
                        Text("Materials:")
                            .font(.body)

                        Spacer()

                        Text("$\(core.costEstimation.materialsCost.description)")
                            .font(.body)
                            .foregroundColor(.purple)
                    }

                    Divider()

                    HStack {
                        Text("Total Estimate:")
                            .font(.title3)
                            .fontWeight(.bold)

                        Spacer()

                        Text("$\(core.costEstimation.totalEstimate.description)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
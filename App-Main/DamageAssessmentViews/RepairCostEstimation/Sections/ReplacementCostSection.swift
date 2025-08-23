//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Sections
// Purpose: Replacement cost section component for repair cost estimation
//

import SwiftUI

public struct ReplacementCostSection: View {
    @ObservedObject var core: RepairCostEstimationCore

    public init(core: RepairCostEstimationCore) {
        self.core = core
    }

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Replacement Cost", systemImage: "arrow.triangle.2.circlepath")
                    .font(.headline)
                    .foregroundColor(.purple)

                VStack(alignment: .leading, spacing: 12) {
                    if let replacementCost = core.costEstimation.replacementCost {
                        HStack {
                            Text("Current replacement cost:")
                                .font(.body)
                            Spacer()
                            Text("$\(replacementCost.description)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }
                    }

                    HStack {
                        TextField("Enter replacement cost", text: Binding(
                            get: { core.costEstimation.replacementCost?.description ?? "" },
                            set: { core.updateReplacementCost($0) }
                        ))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)

                        Text("USD")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
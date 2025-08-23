//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Sections
// Purpose: Labor and materials section component for repair cost estimation
//

import SwiftUI

public struct LaborMaterialsSection: View {
    @ObservedObject var core: RepairCostEstimationCore

    public init(core: RepairCostEstimationCore) {
        self.core = core
    }

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Labor & Materials", systemImage: "person.2.square.stack")
                    .font(.headline)
                    .foregroundColor(.blue)

                VStack(spacing: 12) {
                    HStack {
                        Text("Labor Hours:")
                            .font(.body)

                        Spacer()

                        TextField("Hours", text: Binding(
                            get: { core.costEstimation.laborHours == 0 ? "" : core.costEstimation.laborHours.description },
                            set: { core.updateLaborHours($0) }
                        ))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                    }

                    HStack {
                        Text("Hourly Rate:")
                            .font(.body)

                        Spacer()

                        HStack {
                            Text("$")
                                .foregroundColor(.secondary)
                            TextField("Rate", text: Binding(
                                get: { core.costEstimation.hourlyRate.description },
                                set: { core.updateLaborRate($0) }
                            ))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        }
                        .frame(width: 100)
                    }

                    HStack {
                        Text("Materials Cost:")
                            .font(.body)

                        Spacer()

                        HStack {
                            Text("$")
                                .foregroundColor(.secondary)
                            TextField("Materials", text: Binding(
                                get: { core.costEstimation.materialsCost == 0 ? "" : core.costEstimation.materialsCost.description },
                                set: { core.updateMaterialsCost($0) }
                            ))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        }
                        .frame(width: 100)
                    }

                    Divider()

                    HStack {
                        Text("Labor Cost:")
                            .font(.body)
                            .fontWeight(.medium)

                        Spacer()

                        Text("$\(core.costEstimation.laborCost.description)")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Cards
// Purpose: Repair costs card wrapper component for repair cost estimation
//

import SwiftUI

public struct RepairCostsCard: View {
    let repairCosts: [CostEstimation.RepairCost]
    let totalCosts: Decimal
    let onAdd: () -> Void
    let onRemove: (CostEstimation.RepairCost) -> Void
    
    public init(
        repairCosts: [CostEstimation.RepairCost],
        totalCosts: Decimal,
        onAdd: @escaping () -> Void,
        onRemove: @escaping (CostEstimation.RepairCost) -> Void
    ) {
        self.repairCosts = repairCosts
        self.totalCosts = totalCosts
        self.onAdd = onAdd
        self.onRemove = onRemove
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Repair Costs", systemImage: "wrench.and.screwdriver")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Button(action: onAdd) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                if repairCosts.isEmpty {
                    Text("No repair costs added yet")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                } else {
                    VStack(spacing: 8) {
                        ForEach(repairCosts) { repairCost in
                            RepairCostRow(repairCost: repairCost) {
                                onRemove(repairCost)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total Repair Costs")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("$\(totalCosts.description)")
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
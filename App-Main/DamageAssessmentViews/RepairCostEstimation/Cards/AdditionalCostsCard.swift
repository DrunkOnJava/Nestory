//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Cards
// Purpose: Additional costs card wrapper component for repair cost estimation
//

import SwiftUI

public struct AdditionalCostsCard: View {
    let additionalCosts: [CostEstimation.AdditionalCost]
    let totalCosts: Decimal
    let onAdd: () -> Void
    let onRemove: (CostEstimation.AdditionalCost) -> Void
    
    public init(
        additionalCosts: [CostEstimation.AdditionalCost],
        totalCosts: Decimal,
        onAdd: @escaping () -> Void,
        onRemove: @escaping (CostEstimation.AdditionalCost) -> Void
    ) {
        self.additionalCosts = additionalCosts
        self.totalCosts = totalCosts
        self.onAdd = onAdd
        self.onRemove = onRemove
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Additional Costs", systemImage: "plus.square")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button(action: onAdd) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                
                if additionalCosts.isEmpty {
                    Text("No additional costs added yet")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                } else {
                    VStack(spacing: 8) {
                        ForEach(additionalCosts) { additionalCost in
                            AdditionalCostRow(additionalCost: additionalCost) {
                                onRemove(additionalCost)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total Additional Costs")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("$\(totalCosts.description)")
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
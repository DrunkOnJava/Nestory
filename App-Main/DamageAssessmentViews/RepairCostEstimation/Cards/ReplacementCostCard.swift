//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Cards
// Purpose: Replacement cost card wrapper component for repair cost estimation
//

import SwiftUI

public struct ReplacementCostCard: View {
    let replacementCost: Decimal?
    let onUpdate: (String) -> Void
    
    public init(replacementCost: Decimal?, onUpdate: @escaping (String) -> Void) {
        self.replacementCost = replacementCost
        self.onUpdate = onUpdate
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Replacement Cost", systemImage: "arrow.triangle.2.circlepath")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                VStack(alignment: .leading, spacing: 12) {
                    if let replacementCost = replacementCost {
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
                            get: { replacementCost?.description ?? "" },
                            set: { onUpdate($0) }
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
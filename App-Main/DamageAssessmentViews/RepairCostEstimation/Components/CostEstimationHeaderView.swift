//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Components
// Purpose: Header view component for cost estimation views
//

import SwiftUI

public struct CostEstimationHeaderView: View {
    public init() {}
    
    public var body: some View {
        GroupBox {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading) {
                    Text("Repair Cost Estimation")
                        .font(.headline)
                    Text("Estimate costs for insurance claims")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}
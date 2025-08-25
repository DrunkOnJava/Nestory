//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Cards
// Purpose: Cost summary card wrapper component for repair cost estimation
//

import SwiftUI

public struct CostSummaryCard: View {
    let costEstimation: CostEstimation
    let assessment: DamageAssessment
    
    public init(costEstimation: CostEstimation, assessment: DamageAssessment) {
        self.costEstimation = costEstimation
        self.assessment = assessment
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
                        
                        Text("$\(costEstimation.totalRepairCosts.description)")
                            .font(.body)
                            .foregroundColor(.orange)
                    }
                    
                    HStack {
                        Text("Additional Costs:")
                            .font(.body)
                        
                        Spacer()
                        
                        Text("$\(costEstimation.totalAdditionalCosts.description)")
                            .font(.body)
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        Text("Labor Cost:")
                            .font(.body)
                        
                        Spacer()
                        
                        Text("$\(costEstimation.laborCost.description)")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("Materials:")
                            .font(.body)
                        
                        Spacer()
                        
                        Text("$\(costEstimation.materialsCost.description)")
                            .font(.body)
                            .foregroundColor(.purple)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total Estimate:")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("$\(costEstimation.totalEstimate.description)")
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
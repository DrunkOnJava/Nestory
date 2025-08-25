//
// Layer: App-Main
// Module: DamageAssessment/DamageSeverityAssessment/Components
// Purpose: Help view explaining repairability assessment criteria
//

import SwiftUI

public struct RepairabilityHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Repairability Assessment Guide")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Use this guide to determine if an item should be repaired or replaced")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("When to Choose 'Yes' (Repairable)")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("• Repair cost is less than 50% of replacement cost")
                        Text("• Item has sentimental or unique value")
                        Text("• Damage is limited to specific components")
                        Text("• Replacement parts are readily available")
                        Text("• Repair maintains item's functionality and safety")
                    }
                    .font(.body)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("When to Choose 'No' (Replace)")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text("• Repair cost exceeds 70% of replacement cost")
                        Text("• Multiple systems or components are damaged")
                        Text("• Safety concerns cannot be fully addressed")
                        Text("• Item is obsolete or lacks replacement parts")
                        Text("• Repair would only provide temporary fix")
                    }
                    .font(.body)
                }
                .padding()
            }
            .navigationTitle("Repairability Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
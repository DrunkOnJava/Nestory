//
// Layer: App-Main
// Module: DamageAssessment/DamageSeverityAssessment/Components
// Purpose: Header component with dynamic severity-based styling
//

import SwiftUI

public struct DamageSeverityAssessmentHeader: View {
    let selectedSeverity: DamageSeverity
    
    public init(selectedSeverity: DamageSeverity) {
        self.selectedSeverity = selectedSeverity
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(hex: selectedSeverity.color))

            Text("Damage Severity Assessment")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Evaluate the extent and impact of the damage")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
}
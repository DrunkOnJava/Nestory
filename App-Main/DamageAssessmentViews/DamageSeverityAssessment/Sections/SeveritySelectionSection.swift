//
// Layer: App-Main
// Module: DamageAssessment/DamageSeverityAssessment/Sections
// Purpose: Interactive severity level selection grid component
//

import SwiftUI

public struct SeveritySelectionSection: View {
    @Binding var selectedSeverity: DamageSeverity
    
    public init(selectedSeverity: Binding<DamageSeverity>) {
        self._selectedSeverity = selectedSeverity
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Damage Severity Level")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                ForEach(DamageSeverity.allCases, id: \.self) { severity in
                    SeverityCard(
                        severity: severity,
                        isSelected: selectedSeverity == severity
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedSeverity = severity
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
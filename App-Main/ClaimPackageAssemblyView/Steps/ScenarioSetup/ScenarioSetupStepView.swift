//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/ScenarioSetup
// Purpose: Scenario configuration step with claim type and incident details
//

import SwiftUI

public struct ScenarioSetupStepView: View {
    @Binding public var scenario: ClaimScenario
    public let selectedItemCount: Int
    public let onAdvancedSetup: @Sendable () -> Void
    
    public init(
        scenario: Binding<ClaimScenario>,
        selectedItemCount: Int,
        onAdvancedSetup: @escaping @Sendable () -> Void
    ) {
        self._scenario = scenario
        self.selectedItemCount = selectedItemCount
        self.onAdvancedSetup = onAdvancedSetup
    }
    
    public var body: some View {
        Form {
            ClaimTypeSection(claimType: $scenario.type)
            
            IncidentDetailsSection(
                incidentDate: $scenario.incidentDate,
                description: $scenario.description
            )
            
            QuickStatsSection(selectedItemCount: selectedItemCount)
            
            AdvancedSetupSection(onAdvancedSetup: onAdvancedSetup)
        }
    }
}

#Preview {
    ScenarioSetupStepView(
        scenario: .constant(ClaimScenario(
            type: .fire,
            incidentDate: Date(),
            description: "Sample incident"
        )),
        selectedItemCount: 5,
        onAdvancedSetup: {}
    )
}
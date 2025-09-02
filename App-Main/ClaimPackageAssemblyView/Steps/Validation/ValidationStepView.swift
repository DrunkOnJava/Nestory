//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/Validation
// Purpose: Validation step with package summary and checks
//

import SwiftUI

public struct ValidationStepView: View {
    public let selectedItems: [Item]
    public let scenario: ClaimScenario
    public let options: ClaimPackageOptions
    
    public init(
        selectedItems: [Item],
        scenario: ClaimScenario,
        options: ClaimPackageOptions
    ) {
        self.selectedItems = selectedItems
        self.scenario = scenario
        self.options = options
    }
    
    public var body: some View {
        Form {
            PackageSummarySection(
                selectedItems: selectedItems,
                scenario: scenario
            )
            
            ValidationChecksSection(
                selectedItems: selectedItems,
                scenario: scenario
            )
            
            if !warnings.isEmpty {
                WarningsSection(warnings: warnings)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var warnings: [String] {
        ValidationWarningsCalculator.calculateWarnings(
            selectedItems: selectedItems,
            scenario: scenario
        )
    }
}

#Preview {
    @Previewable @State var sampleItems: [Item] = {
        let items = [
            Item(name: "MacBook Pro", itemDescription: "Laptop", quantity: 1),
            Item(name: "iPhone", itemDescription: "Phone", quantity: 1)
        ]
        items[0].purchasePrice = 2500.00
        return items
    }()
    
    ValidationStepView(
        selectedItems: sampleItems,
        scenario: ClaimScenario(
            type: .fire,
            incidentDate: Date(),
            description: "Fire damage incident"
        ),
        options: ClaimPackageOptions()
    )
}
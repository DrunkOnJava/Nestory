//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/Validation
// Purpose: Package summary section with key metrics
//

import SwiftUI

public struct PackageSummarySection: View {
    public let selectedItems: [Item]
    public let scenario: ClaimScenario
    
    public init(selectedItems: [Item], scenario: ClaimScenario) {
        self.selectedItems = selectedItems
        self.scenario = scenario
    }
    
    public var body: some View {
        Section("Package Summary") {
            HStack {
                Text("Items")
                Spacer()
                Text("\(selectedItems.count)")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Total Value")
                Spacer()
                Text(totalValue, format: .currency(code: "USD"))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Claim Type")
                Spacer()
                Text(scenario.type.rawValue)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalValue: Decimal {
        selectedItems.compactMap(\.purchasePrice).reduce(0, +)
    }
}

#Preview {
    @Previewable @State var sampleItems: [Item] = {
        let items = [
            Item(name: "MacBook Pro", itemDescription: "Laptop", quantity: 1),
            Item(name: "iPhone", itemDescription: "Phone", quantity: 1)
        ]
        items[0].purchasePrice = 2500.00
        items[1].purchasePrice = 1000.00
        return items
    }()
    
    Form {
        PackageSummarySection(
            selectedItems: sampleItems,
            scenario: ClaimScenario(
                type: .fire,
                incidentDate: Date(),
                description: "Fire damage"
            )
        )
    }
}
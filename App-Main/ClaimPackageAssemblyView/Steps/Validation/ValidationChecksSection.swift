//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/Validation
// Purpose: Validation checks section with detailed status indicators
//

import SwiftUI

public struct ValidationChecksSection: View {
    public let selectedItems: [Item]
    public let scenario: ClaimScenario
    
    public init(selectedItems: [Item], scenario: ClaimScenario) {
        self.selectedItems = selectedItems
        self.scenario = scenario
    }
    
    public var body: some View {
        Section("Validation Checks") {
            ValidationCheckRow(
                title: "Items Selected",
                isValid: !selectedItems.isEmpty,
                detail: "\(selectedItems.count) items"
            )
            
            ValidationCheckRow(
                title: "Incident Description",
                isValid: !scenario.description.isEmpty,
                detail: scenario.description.isEmpty ? "Missing" : "Provided"
            )
            
            ValidationCheckRow(
                title: "Item Photos",
                isValid: hasPhotos,
                detail: photoStatus
            )
            
            ValidationCheckRow(
                title: "Purchase Information",
                isValid: hasPurchaseInfo,
                detail: purchaseInfoStatus
            )
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasPhotos: Bool {
        selectedItems.contains { item in
            !item.photos.isEmpty
        }
    }
    
    private var photoStatus: String {
        let itemsWithPhotos = selectedItems.filter { !$0.photos.isEmpty }.count
        return "\(itemsWithPhotos)/\(selectedItems.count) items have photos"
    }
    
    private var hasPurchaseInfo: Bool {
        selectedItems.contains { $0.purchasePrice != nil }
    }
    
    private var purchaseInfoStatus: String {
        let itemsWithPrices = selectedItems.filter { $0.purchasePrice != nil }.count
        return "\(itemsWithPrices)/\(selectedItems.count) items have prices"
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
    
    Form {
        ValidationChecksSection(
            selectedItems: sampleItems,
            scenario: ClaimScenario(
                type: .fire,
                incidentDate: Date(),
                description: "Fire damage incident"
            )
        )
    }
}
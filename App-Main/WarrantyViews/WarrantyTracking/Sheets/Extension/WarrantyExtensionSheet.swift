//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/Extension
// Purpose: Warranty extension purchase sheet with selection workflow
//

import SwiftUI

public struct WarrantyExtensionSheet: View {
    public let currentWarranty: Warranty
    public let onExtensionPurchased: @Sendable (WarrantyExtension) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedExtension: WarrantyExtension?
    
    public init(
        currentWarranty: Warranty,
        onExtensionPurchased: @escaping @Sendable (WarrantyExtension) -> Void
    ) {
        self.currentWarranty = currentWarranty
        self.onExtensionPurchased = onExtensionPurchased
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    CurrentWarrantyCard(warranty: currentWarranty)
                    
                    ExtensionOptionsSection(
                        availableExtensions: WarrantyExtension.standardExtensions(),
                        selectedExtension: $selectedExtension
                    )
                    
                    if let selected = selectedExtension {
                        SelectedExtensionCard(extension: selected)
                    }
                    
                    if selectedExtension != nil {
                        ExtensionPurchaseButton(
                            onPurchase: {
                                Task { @MainActor in
                                    if let selected = selectedExtension {
                                        onExtensionPurchased(selected)
                                        dismiss()
                                    }
                                }
                            }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Extend Warranty")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let warranty = Warranty(
        provider: "Apple Inc.",
        type: .manufacturer,
        startDate: Date(),
        expiresAt: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date(),
        item: Item(name: "iPhone 15 Pro", itemDescription: "Smartphone", quantity: 1)
    )
    
    WarrantyExtensionSheet(
        currentWarranty: warranty,
        onExtensionPurchased: { _ in }
    )
}
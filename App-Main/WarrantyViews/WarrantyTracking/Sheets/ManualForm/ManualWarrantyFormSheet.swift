//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/ManualForm
// Purpose: Manual warranty form sheet with comprehensive input validation
//

import SwiftUI

public struct ManualWarrantyFormSheet: View {
    @Binding public var item: Item
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var formState = WarrantyFormState()
    
    public init(item: Binding<Item>) {
        self._item = item
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                BasicInformationSection(
                    warrantyType: $formState.warrantyType,
                    provider: $formState.provider
                )
                
                CoveragePeriodSection(
                    startDate: $formState.startDate,
                    endDate: $formState.endDate
                )
                
                AdditionalDetailsSection(
                    registrationRequired: $formState.registrationRequired,
                    isRegistered: $formState.isRegistered,
                    terms: $formState.terms
                )
            }
            .navigationTitle("Add Warranty")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWarranty()
                    }
                    .fontWeight(.semibold)
                    .disabled(!formState.isValid)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @MainActor
    private func saveWarranty() {
        let warranty = Warranty(
            provider: formState.provider.isEmpty ? "Unknown" : formState.provider,
            type: formState.warrantyType,
            startDate: formState.startDate,
            expiresAt: formState.endDate,
            item: item
        )
        
        // Note: Additional properties like terms and registration not available in current Warranty model
        // Future enhancement: add coverageNotes property to Warranty model
        
        item.warranty = warranty
        dismiss()
    }
}

#Preview {
    let item = Item(name: "iPhone 15 Pro", itemDescription: "Smartphone", quantity: 1)
    
    ManualWarrantyFormSheet(item: .constant(item))
}
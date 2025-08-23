//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/ManualForm
// Purpose: Additional warranty details input section
//

import SwiftUI

public struct AdditionalDetailsSection: View {
    @Binding public var registrationRequired: Bool
    @Binding public var isRegistered: Bool
    @Binding public var terms: String
    
    public init(
        registrationRequired: Binding<Bool>,
        isRegistered: Binding<Bool>,
        terms: Binding<String>
    ) {
        self._registrationRequired = registrationRequired
        self._isRegistered = isRegistered
        self._terms = terms
    }
    
    public var body: some View {
        Section {
            Toggle("Registration Required", isOn: $registrationRequired)
            
            if registrationRequired {
                Toggle("Already Registered", isOn: $isRegistered)
            }
            
            TextField("Terms and Conditions", text: $terms, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Additional Details")
        } footer: {
            Text("Enter any specific warranty terms, coverage limitations, or important notes.")
        }
    }
}

#Preview {
    Form {
        AdditionalDetailsSection(
            registrationRequired: .constant(true),
            isRegistered: .constant(false),
            terms: .constant("Standard manufacturer warranty covering defects in materials and workmanship.")
        )
    }
}
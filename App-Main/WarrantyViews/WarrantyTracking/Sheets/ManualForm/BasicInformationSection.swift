//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/ManualForm
// Purpose: Basic warranty information input section
//

import SwiftUI

public struct BasicInformationSection: View {
    @Binding public var warrantyType: WarrantyType
    @Binding public var provider: String
    
    public init(
        warrantyType: Binding<WarrantyType>,
        provider: Binding<String>
    ) {
        self._warrantyType = warrantyType
        self._provider = provider
    }
    
    public var body: some View {
        Section(header: Text("Basic Information")) {
            Picker("Warranty Type", selection: $warrantyType) {
                ForEach(WarrantyType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            
            TextField("Provider/Company", text: $provider)
        }
    }
}

#Preview {
    Form {
        BasicInformationSection(
            warrantyType: .constant(.manufacturer),
            provider: .constant("Apple Inc.")
        )
    }
}
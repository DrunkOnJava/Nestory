//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/Extension
// Purpose: Extension options selection section with cards
//

import SwiftUI

public struct ExtensionOptionsSection: View {
    public let availableExtensions: [WarrantyExtension]
    @Binding public var selectedExtension: WarrantyExtension?
    
    public init(
        availableExtensions: [WarrantyExtension],
        selectedExtension: Binding<WarrantyExtension?>
    ) {
        self.availableExtensions = availableExtensions
        self._selectedExtension = selectedExtension
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Extension Options")
                .font(.headline)
            
            ForEach(availableExtensions, id: \.id) { warrantyExt in
                ExtensionOptionCard(
                    extension: warrantyExt,
                    isSelected: selectedExtension?.id == warrantyExt.id,
                    onSelect: {
                        Task { @MainActor in
                            selectedExtension = warrantyExt
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    ExtensionOptionsSection(
        availableExtensions: WarrantyExtension.standardExtensions(),
        selectedExtension: .constant(nil)
    )
    .padding()
}
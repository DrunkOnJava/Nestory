//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/ScenarioSetup
// Purpose: Quick statistics section showing selected item count
//

import SwiftUI

public struct QuickStatsSection: View {
    public let selectedItemCount: Int
    
    public init(selectedItemCount: Int) {
        self.selectedItemCount = selectedItemCount
    }
    
    public var body: some View {
        Section("Quick Stats") {
            HStack {
                Text("Selected Items")
                Spacer()
                Text("\(selectedItemCount)")
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    Form {
        QuickStatsSection(selectedItemCount: 5)
    }
}
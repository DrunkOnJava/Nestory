//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/ScenarioSetup
// Purpose: Claim type selection section for scenario setup
//

import SwiftUI

public struct ClaimTypeSection: View {
    @Binding public var claimType: ClaimScope
    
    public init(claimType: Binding<ClaimScope>) {
        self._claimType = claimType
    }
    
    public var body: some View {
        Section("Claim Scope") {
            Picker("Scope", selection: $claimType) {
                ForEach(ClaimScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue).tag(scope)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

#Preview {
    Form {
        ClaimTypeSection(claimType: .constant(.fire))
    }
}
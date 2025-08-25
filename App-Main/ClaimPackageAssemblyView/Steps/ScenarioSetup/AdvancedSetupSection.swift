//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/ScenarioSetup
// Purpose: Advanced setup section with navigation to detailed configuration
//

import SwiftUI

public struct AdvancedSetupSection: View {
    public let onAdvancedSetup: @Sendable () -> Void
    
    public init(onAdvancedSetup: @escaping @Sendable () -> Void) {
        self.onAdvancedSetup = onAdvancedSetup
    }
    
    public var body: some View {
        Section(content: {
            Button("Advanced Scenario Setup") {
                onAdvancedSetup()
            }
        })
    }
}

#Preview {
    Form {
        AdvancedSetupSection(onAdvancedSetup: {})
    }
}
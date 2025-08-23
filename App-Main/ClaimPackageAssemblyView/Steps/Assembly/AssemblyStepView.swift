//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/Assembly
// Purpose: Assembly step view with progress and results display
//

import SwiftUI

public struct AssemblyStepView: View {
    public let assemblyService: ClaimPackageAssemblerService
    public let generatedPackage: ClaimPackage?
    public let errorAlert: ErrorAlert?
    
    public init(
        assemblyService: ClaimPackageAssemblerService,
        generatedPackage: ClaimPackage?,
        errorAlert: ErrorAlert?
    ) {
        self.assemblyService = assemblyService
        self.generatedPackage = generatedPackage
        self.errorAlert = errorAlert
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            if let package = generatedPackage {
                AssemblySuccessView(package: package)
            } else if let error = errorAlert {
                AssemblyErrorView(error: error)
            } else {
                AssemblyProgressView()
            }
        }
        .padding()
    }
}

#Preview {
    AssemblyStepView(
        assemblyService: LiveClaimPackageAssemblerService(),
        generatedPackage: nil,
        errorAlert: nil
    )
}
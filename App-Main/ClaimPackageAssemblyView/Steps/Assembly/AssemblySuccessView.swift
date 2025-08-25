//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/Assembly
// Purpose: Success state view for completed package assembly
//

import SwiftUI

public struct AssemblySuccessView: View {
    public let package: ClaimPackage
    
    public init(package: ClaimPackage) {
        self.package = package
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Package Assembled Successfully")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Package ID:")
                    Spacer()
                    Text(String(package.id.uuidString.prefix(8)))
                        .font(.monospaced(.body)())
                }
                
                HStack {
                    Text("Items Included:")
                    Spacer()
                    Text("\(package.items.count)")
                }
                
                HStack {
                    Text("Total Value:")
                    Spacer()
                    Text(package.validation.totalValue, format: .currency(code: "USD"))
                }
                
                HStack {
                    Text("Files Generated:")
                    Spacer()
                    Text("\(package.forms.count + package.documentation.count)")
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

#Preview {
    let package = ClaimPackage(
        id: UUID(),
        scenario: ClaimScenario(
            type: .fire,
            incidentDate: Date(),
            description: "Sample fire damage claim"
        ),
        items: [],
        coverLetter: ClaimCoverLetter(
            summary: ClaimSummary(
                claimType: .propertyDamage,
                incidentDate: Date(),
                totalItems: 0,
                totalValue: 0,
                affectedRooms: [],
                description: "Sample property damage summary"
            ),
            content: "This is a sample claim.",
            generatedDate: Date(),
            policyHolder: "John Doe",
            policyNumber: "POL123456"
        ),
        documentation: [],
        forms: [],
        attestations: [],
        validation: PackageValidation(
            isValid: true,
            issues: [],
            missingRequirements: [],
            totalItems: 0,
            documentedItems: 0,
            totalValue: 0,
            validationDate: Date()
        ),
        packageURL: URL(fileURLWithPath: "/tmp/sample.zip"),
        createdDate: Date(),
        options: ClaimPackageOptions()
    )
    
    AssemblySuccessView(package: package)
}
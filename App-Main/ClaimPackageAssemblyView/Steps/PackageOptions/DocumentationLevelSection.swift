//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/PackageOptions
// Purpose: Documentation level selection section with explanation
//

import SwiftUI

public struct DocumentationLevelSection: View {
    @Binding public var documentationLevel: DocumentationLevel
    
    public init(documentationLevel: Binding<DocumentationLevel>) {
        self._documentationLevel = documentationLevel
    }
    
    public var body: some View {
        Section(content: {
            Picker("Level", selection: $documentationLevel) {
                Text("Basic").tag(DocumentationLevel.basic)
                Text("Detailed").tag(DocumentationLevel.detailed)
                Text("Comprehensive").tag(DocumentationLevel.comprehensive)
            }
            .pickerStyle(.segmented)
        }, header: {
            Text("Documentation Level")
        }, footer: {
            Text("Choose how much detail to include in the package.")
        })
    }
}

#Preview {
    Form {
        DocumentationLevelSection(documentationLevel: .constant(.detailed))
    }
}
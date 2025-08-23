//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/ScenarioSetup
// Purpose: Incident details input section with date and description
//

import SwiftUI

public struct IncidentDetailsSection: View {
    @Binding public var incidentDate: Date
    @Binding public var description: String
    
    public init(
        incidentDate: Binding<Date>,
        description: Binding<String>
    ) {
        self._incidentDate = incidentDate
        self._description = description
    }
    
    public var body: some View {
        Section(content: {
            DatePicker("Incident Date", selection: $incidentDate, displayedComponents: .date)
            
            TextEditor(text: $description)
                .frame(minHeight: 80)
        }, header: {
            Text("Incident Details")
        }, footer: {
            Text("Describe what happened and how the items were affected.")
        })
    }
}

#Preview {
    Form {
        IncidentDetailsSection(
            incidentDate: .constant(Date()),
            description: .constant("Sample incident description")
        )
    }
}
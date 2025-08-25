//
// Layer: App-Main
// Module: InsuranceClaim/Steps
// Purpose: Incident details collection with documentation requirements
//

import SwiftUI

public struct IncidentDetailsStep: View {
    @Binding public var incidentDate: Date
    @Binding public var incidentDescription: String
    @Binding public var policyNumber: String
    @Binding public var claimNumber: String
    public let selectedClaimType: ClaimType
    
    public init(
        incidentDate: Binding<Date>,
        incidentDescription: Binding<String>,
        policyNumber: Binding<String>,
        claimNumber: Binding<String>,
        selectedClaimType: ClaimType
    ) {
        self._incidentDate = incidentDate
        self._incidentDescription = incidentDescription
        self._policyNumber = policyNumber
        self._claimNumber = claimNumber
        self.selectedClaimType = selectedClaimType
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Step 2: Incident Details")
                .font(.title2)
                .fontWeight(.bold)

            Text("Provide details about when and how the incident occurred.")
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 16) {
                Text("Date of Incident")
                    .font(.headline)

                DatePicker("Incident Date", selection: $incidentDate, displayedComponents: [.date])
                    .datePickerStyle(.compact)

                Text("Description of Incident")
                    .font(.headline)

                TextEditor(text: $incidentDescription)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                Text("Policy Number (Optional)")
                    .font(.headline)

                TextField("Policy Number", text: $policyNumber)
                    .textFieldStyle(.roundedBorder)

                Text("Claim Number (if assigned)")
                    .font(.headline)

                TextField("Claim Number", text: $claimNumber)
                    .textFieldStyle(.roundedBorder)
            }

            // Required documentation reminder
            if !selectedClaimType.requiredDocumentation.isEmpty {
                GroupBox("Required Documentation") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("For \(selectedClaimType.rawValue) claims, you may need:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ForEach(selectedClaimType.requiredDocumentation, id: \.self) { doc in
                            HStack {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.blue)
                                Text(doc)
                                    .font(.caption)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    IncidentDetailsStep(
        incidentDate: .constant(Date()),
        incidentDescription: .constant("Sample incident description"),
        policyNumber: .constant(""),
        claimNumber: .constant(""),
        selectedClaimType: .fire
    )
    .padding()
}
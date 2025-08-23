//
// Layer: App-Main
// Module: InsuranceClaim/Steps
// Purpose: Contact information collection with persistence support
//

import SwiftUI

public struct ContactInformationStep: View {
    @Binding public var contactName: String
    @Binding public var contactPhone: String
    @Binding public var contactEmail: String
    @Binding public var contactAddress: String
    @Binding public var emergencyContact: String
    public let onSaveContactInfo: () -> Void
    
    public init(
        contactName: Binding<String>,
        contactPhone: Binding<String>,
        contactEmail: Binding<String>,
        contactAddress: Binding<String>,
        emergencyContact: Binding<String>,
        onSaveContactInfo: @escaping () -> Void
    ) {
        self._contactName = contactName
        self._contactPhone = contactPhone
        self._contactEmail = contactEmail
        self._contactAddress = contactAddress
        self._emergencyContact = emergencyContact
        self.onSaveContactInfo = onSaveContactInfo
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Step 3: Contact Information")
                .font(.title2)
                .fontWeight(.bold)

            Text("Provide your contact details for the insurance company.")
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("Full Name")
                        .font(.headline)
                    TextField("Your Full Name", text: $contactName)
                        .textFieldStyle(.roundedBorder)

                    Text("Phone Number")
                        .font(.headline)
                    TextField("Phone Number", text: $contactPhone)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)

                    Text("Email Address")
                        .font(.headline)
                    TextField("Email Address", text: $contactEmail)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    Text("Address")
                        .font(.headline)
                    TextField("Full Address", text: $contactAddress, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3)
                }

                Text("Emergency Contact (Optional)")
                    .font(.headline)
                TextField("Emergency Contact", text: $emergencyContact)
                    .textFieldStyle(.roundedBorder)
            }

            Button("Save Contact Info") {
                onSaveContactInfo()
            }
            .buttonStyle(.bordered)
            .font(.caption)
        }
    }
}

#Preview {
    ContactInformationStep(
        contactName: .constant("John Doe"),
        contactPhone: .constant("555-0123"),
        contactEmail: .constant("john@example.com"),
        contactAddress: .constant("123 Main St"),
        emergencyContact: .constant("Jane Doe"),
        onSaveContactInfo: {}
    )
    .padding()
}
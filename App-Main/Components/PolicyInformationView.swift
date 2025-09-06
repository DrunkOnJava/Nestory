//
// Layer: App
// Module: Components
// Purpose: Policy information form component for insurance exports
//

import SwiftUI

struct PolicyInformationView: View {
    @Binding var exportOptions: ExportOptions
    
    var body: some View {
        Section("Policy Information (Optional)") {
            PolicyHolderNameField(exportOptions: $exportOptions)
            PolicyNumberTextField(exportOptions: $exportOptions)
            PropertyAddressTextField(exportOptions: $exportOptions)
        }
    }
}

private struct PolicyHolderNameField: View {
    @Binding var exportOptions: ExportOptions
    
    var body: some View {
        TextField("Policy Holder Name", text: .init(
            get: { exportOptions.policyHolderName ?? "" },
            set: { exportOptions.policyHolderName = $0.isEmpty ? nil : $0 }
        ))
    }
}

private struct PolicyNumberTextField: View {
    @Binding var exportOptions: ExportOptions
    
    var body: some View {
        TextField("Policy Number", text: .init(
            get: { exportOptions.policyNumber ?? "" },
            set: { exportOptions.policyNumber = $0.isEmpty ? nil : $0 }
        ))
    }
}

private struct PropertyAddressTextField: View {
    @Binding var exportOptions: ExportOptions
    
    var body: some View {
        TextField("Property Address", text: .init(
            get: { exportOptions.propertyAddress ?? "" },
            set: { exportOptions.propertyAddress = $0.isEmpty ? nil : $0 }
        ))
        .textContentType(.fullStreetAddress)
    }
}

#Preview {
    NavigationStack {
        Form {
            PolicyInformationView(exportOptions: .constant(ExportOptions()))
        }
    }
}
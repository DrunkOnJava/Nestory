//
// Layer: App
// Module: Components
// Purpose: Manual barcode entry form component
//

import SwiftUI

struct ManualBarcodeEntryView: View {
    @State private var barcodeValue = ""
    @State private var selectedType = "UPC"
    @Environment(\.dismiss) private var dismiss

    let onSave: (String, String) -> Void

    let barcodeTypes = ["UPC", "EAN", "Serial Number", "QR Code", "Other"]

    init(onSave: @escaping (String, String) -> Void) {
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Barcode Information") {
                    TextField("Barcode Value", text: $barcodeValue)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .font(.system(.body, design: .monospaced))

                    Picker("Type", selection: $selectedType) {
                        ForEach(barcodeTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                }

                Section {
                    Text("Enter the barcode number exactly as it appears on the product label.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(barcodeValue, selectedType)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(barcodeValue.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ManualBarcodeEntryView { _, _ in }
}

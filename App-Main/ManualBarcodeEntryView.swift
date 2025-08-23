//
// Layer: App
// Module: Components
// Purpose: Enhanced manual item entry form component
//

import SwiftUI

// Helper extension for placeholder text
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: .leading) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
    
    func placeholder(_ text: String) -> some View {
        self.placeholder(when: true) {
            Text(text).foregroundColor(.secondary)
        }
    }
}

struct ManualBarcodeEntryView: View {
    @State private var itemName = ""
    @State private var itemDescription = ""
    @State private var barcodeValue = ""
    @State private var selectedType = "UPC"
    @State private var brand = ""
    @State private var modelNumber = ""
    @State private var serialNumber = ""
    @State private var purchasePrice = ""
    @State private var purchaseDate = Date()
    @State private var room = ""
    @State private var specificLocation = ""
    @State private var quantity = 1
    @State private var selectedCategory = "Electronics"
    
    @Environment(\.dismiss) private var dismiss

    let onSave: (String, String) -> Void

    let barcodeTypes = ["UPC", "EAN", "Serial Number", "QR Code", "Other"]
    let categories = ["Electronics", "Furniture", "Kitchen", "Clothing", "Books", "Sports", "Tools"]
    let rooms = ["Home Office", "Living Room", "Kitchen", "Bedroom", "Garage", "Basement", "Attic"]

    init(onSave: @escaping (String, String) -> Void) {
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                // Essential Item Information
                Section("Item Information") {
                    TextField("Item Name", text: $itemName)
                    
                    TextField("Description (Optional)", text: $itemDescription, axis: .vertical)
                        .lineLimit(2...4)
                    
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...999)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                // Product Details
                Section("Product Details") {
                    TextField("Brand (Optional)", text: $brand)
                    
                    TextField("Model Number (Optional)", text: $modelNumber)
                        .textInputAutocapitalization(.characters)
                    
                    TextField("Serial Number (Optional)", text: $serialNumber)
                        .textInputAutocapitalization(.characters)
                }
                
                // Purchase Information
                Section("Purchase Information") {
                    HStack {
                        Text("Purchase Price")
                        Spacer()
                        TextField("0.00", text: $purchasePrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                // Location
                Section("Location") {
                    Picker("Room", selection: $room) {
                        Text("Select Room").tag("")
                        ForEach(rooms, id: \.self) { room in
                            Text(room).tag(room)
                        }
                    }
                    
                    if !room.isEmpty {
                        TextField("Specific Location (Optional)", text: $specificLocation)
                            .placeholder("e.g., Desk, Shelf, Closet")
                    }
                }
                
                // Barcode Information (collapsed by default)
                Section("Barcode Information") {
                    TextField("Barcode Value (Optional)", text: $barcodeValue)
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
                    Text("Fill in the information you know. You can always add missing details later.")
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
                    .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    ManualBarcodeEntryView { _, _ in }
}

//
//  EditItemView.swift
//  Nestory
//

import SwiftData
import SwiftUI

struct EditItemView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [Category]

    @State private var name: String
    @State private var itemDescription: String
    @State private var quantity: Int
    @State private var selectedCategory: Category?
    @State private var brand: String
    @State private var modelNumber: String
    @State private var serialNumber: String
    @State private var notes: String
    @State private var purchasePrice: String
    @State private var purchaseDate: Date
    @State private var showPurchaseDetails: Bool
    @State private var imageData: Data?
    @State private var showingPhotoCapture = false
    @State private var showingReceiptCapture = false
    @State private var showingWarrantyDocuments = false
    @State private var showingBarcodeScanner = false

    init(item: Item) {
        self.item = item
        _name = State(initialValue: item.name)
        _itemDescription = State(initialValue: item.itemDescription ?? "")
        _quantity = State(initialValue: item.quantity)
        _selectedCategory = State(initialValue: item.category)
        _brand = State(initialValue: item.brand ?? "")
        _modelNumber = State(initialValue: item.modelNumber ?? "")
        _serialNumber = State(initialValue: item.serialNumber ?? "")
        _notes = State(initialValue: item.notes ?? "")
        _purchasePrice = State(initialValue: item.purchasePrice != nil ? "\(item.purchasePrice!)" : "")
        _purchaseDate = State(initialValue: item.purchaseDate ?? Date())
        _showPurchaseDetails = State(initialValue: item.purchasePrice != nil || item.purchaseDate != nil)
        _imageData = State(initialValue: item.imageData)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button(action: { showingPhotoCapture = true }) {
                        if let imageData,
                           let uiImage = UIImage(data: imageData)
                        {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: 200)
                                .clipped()
                                .cornerRadius(8)
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("Add Photo")
                                    .foregroundColor(.accentColor)
                            }
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(8)
                        }
                    }
                    .buttonStyle(.plain)
                }

                Section("Item Information") {
                    TextField("Item Name", text: $name)
                    TextField("Description", text: $itemDescription, axis: .vertical)
                        .lineLimit(2 ... 4)

                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1 ... 999)

                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(nil as Category?)
                        ForEach(categories) { category in
                            Label(category.name, systemImage: category.icon)
                                .tag(category as Category?)
                        }
                    }
                }

                Section("Additional Details") {
                    TextField("Brand", text: $brand)

                    HStack {
                        TextField("Model Number", text: $modelNumber)
                        Button(action: { showingBarcodeScanner = true }) {
                            Image(systemName: "barcode.viewfinder")
                                .foregroundColor(.accentColor)
                        }
                    }

                    HStack {
                        TextField("Serial Number", text: $serialNumber)
                        Button(action: { showingBarcodeScanner = true }) {
                            Image(systemName: "barcode.viewfinder")
                                .foregroundColor(.accentColor)
                        }
                    }

                    // REMINDER: Barcode scanner is wired here for editing!
                    if !modelNumber.isEmpty || !serialNumber.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("Product codes present")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    Toggle("Purchase Information", isOn: $showPurchaseDetails)
                    if showPurchaseDetails {
                        TextField("Purchase Price", text: $purchasePrice)
                            .keyboardType(.decimalPad)
                        DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                    }
                }

                Section("Warranty, Location & Documents") {
                    // Warranty & Location button
                    Button(action: { showingWarrantyDocuments = true }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "shield.checkerboard")
                                        .foregroundColor(.green)
                                    Text("Warranty & Location")
                                        .foregroundColor(.primary)
                                }

                                HStack(spacing: 16) {
                                    if item.warrantyExpirationDate != nil {
                                        Label("Warranty Active", systemImage: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                    if !item.documentNames.isEmpty {
                                        Label("\(item.documentNames.count) docs", systemImage: "doc.stack")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                }

                Section("Receipt & Documentation") {
                    Button(action: { showingReceiptCapture = true }) {
                        HStack {
                            Image(systemName: item.receiptImageData != nil ? "checkmark.circle.fill" : "doc.text.viewfinder")
                                .foregroundColor(item.receiptImageData != nil ? .green : .accentColor)
                            Text(item.receiptImageData != nil ? "Receipt Attached - Tap to View/Edit" : "Add Receipt (OCR Scan)")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)

                    if item.extractedReceiptText != nil {
                        Text("OCR data available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingPhotoCapture) {
                PhotoCaptureView(imageData: $imageData)
            }
            .sheet(isPresented: $showingReceiptCapture) {
                ReceiptCaptureView(item: item)
            }
            .sheet(isPresented: $showingWarrantyDocuments) {
                WarrantyDocumentsView(item: item)
            }
            .sheet(isPresented: $showingBarcodeScanner) {
                LegacyBarcodeScannerView(item: item)
                    .onDisappear {
                        // Update form fields if scanner populated them
                        if let newSerial = item.serialNumber {
                            serialNumber = newSerial
                        }
                        if let newModel = item.modelNumber {
                            modelNumber = newModel
                        }
                        if let newBrand = item.brand {
                            brand = newBrand
                        }
                    }
            }
        }
    }

    private func saveChanges() {
        item.name = name
        item.itemDescription = itemDescription.isEmpty ? nil : itemDescription
        item.quantity = quantity
        item.category = selectedCategory
        item.brand = brand.isEmpty ? nil : brand
        item.modelNumber = modelNumber.isEmpty ? nil : modelNumber
        item.serialNumber = serialNumber.isEmpty ? nil : serialNumber
        item.notes = notes.isEmpty ? nil : notes

        if showPurchaseDetails {
            if let price = Decimal(string: purchasePrice) {
                item.purchasePrice = price
            } else {
                item.purchasePrice = nil
            }
            item.purchaseDate = purchaseDate
        } else {
            item.purchasePrice = nil
            item.purchaseDate = nil
        }

        item.imageData = imageData
        item.updatedAt = Date()
        dismiss()
    }
}

#Preview {
    EditItemView(item: Item(name: "Sample Item", itemDescription: "Sample description", quantity: 5))
        .modelContainer(for: [Item.self, Category.self], inMemory: true)
}

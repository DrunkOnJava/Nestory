//
//  AddItemView.swift
//  Nestory
//

import SwiftData
import SwiftUI

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [Category]

    @State private var name = ""
    @State private var itemDescription = ""
    @State private var quantity = 1
    @State private var selectedCategory: Category?
    @State private var brand = ""
    @State private var modelNumber = ""
    @State private var serialNumber = ""
    @State private var notes = ""
    @State private var purchasePrice = ""
    @State private var purchaseDate = Date()
    @State private var showPurchaseDetails = false
    @State private var imageData: Data?
    @State private var showingPhotoCapture = false
    @State private var showingBarcodeScanner = false
    @State private var tempItem = Item(name: "")

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
                    TextField("Model Number", text: $modelNumber)
                    HStack {
                        TextField("Serial Number", text: $serialNumber)
                        Button(action: { showingBarcodeScanner = true }) {
                            Image(systemName: "barcode.viewfinder")
                                .foregroundColor(.accentColor)
                        }
                    }

                    // REMINDER: Barcode scanner is wired here!
                    if !modelNumber.isEmpty || !serialNumber.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("Product codes captured")
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

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingPhotoCapture) {
                PhotoCaptureView(imageData: $imageData)
            }
            .sheet(isPresented: $showingBarcodeScanner) {
                BarcodeScannerView(item: tempItem)
                    .onDisappear {
                        // Apply scanned values back to form
                        if let scannedSerial = tempItem.serialNumber {
                            serialNumber = scannedSerial
                        }
                        if let scannedModel = tempItem.modelNumber {
                            modelNumber = scannedModel
                        }
                        if let scannedBrand = tempItem.brand {
                            brand = scannedBrand
                        }
                        // If name was populated from product lookup
                        if !tempItem.name.isEmpty, name.isEmpty {
                            name = tempItem.name
                        }
                    }
            }
        }
        .onAppear {
            if categories.isEmpty {
                setupDefaultCategories()
            }
        }
    }

    private func saveItem() {
        let newItem = Item(
            name: name,
            itemDescription: itemDescription.isEmpty ? nil : itemDescription,
            quantity: quantity,
            category: selectedCategory
        )

        newItem.brand = brand.isEmpty ? nil : brand
        newItem.modelNumber = modelNumber.isEmpty ? nil : modelNumber
        newItem.serialNumber = serialNumber.isEmpty ? nil : serialNumber
        newItem.notes = notes.isEmpty ? nil : notes
        newItem.imageData = imageData

        if showPurchaseDetails {
            if let price = Decimal(string: purchasePrice) {
                newItem.purchasePrice = price
            }
            newItem.purchaseDate = purchaseDate
        }

        modelContext.insert(newItem)
        dismiss()
    }

    private func setupDefaultCategories() {
        for defaultCategory in Category.createDefaultCategories() {
            modelContext.insert(defaultCategory)
        }
    }
}

#Preview {
    AddItemView()
        .modelContainer(for: [Item.self, Category.self], inMemory: true)
}

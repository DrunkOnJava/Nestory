// Layer: App
// Module: AddItemView
// Purpose: Add new item to inventory

import SwiftData
import SwiftUI
import os.log

// APPLE_FRAMEWORK_OPPORTUNITY: Consider adding MapKit - Could add location-based organization of items (where purchased, where stored) with visual location tracking

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
    @State private var detectedWarranty: WarrantyDetectionResult?
    @State private var showingWarrantyDetection = false
    @State private var isDetectingWarranty = false

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

                // Quick Barcode Scan Section
                Section {
                    Button(action: { showingBarcodeScanner = true }) {
                        HStack {
                            Image(systemName: "barcode.viewfinder")
                                .foregroundColor(.accentColor)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Scan Barcode")
                                    .foregroundColor(.accentColor)
                                Text("Add barcode for product identification")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
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
                    TextField("Serial Number", text: $serialNumber)

                    // Show barcode if captured
                    if let scannedBarcode = tempItem.barcode, !scannedBarcode.isEmpty {
                        HStack {
                            Image(systemName: "barcode")
                                .foregroundColor(.accentColor)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Barcode: \(scannedBarcode)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if !tempItem.name.isEmpty, tempItem.name != "New Item" {
                                    Text("Product details auto-populated")
                                        .font(.caption2)
                                        .foregroundColor(.green)
                                }
                            }
                            Spacer()
                        }
                    }

                    // Product codes captured indicator
                    if !modelNumber.isEmpty || !serialNumber.isEmpty || (tempItem.barcode?.isEmpty == false) {
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

                // Warranty Detection Section
                if !brand.isEmpty || !modelNumber.isEmpty || showPurchaseDetails {
                    Section("Smart Warranty Detection") {
                        Button(action: { 
                            Task { await detectWarranty() } 
                        }) {
                            HStack {
                                Image(systemName: isDetectingWarranty ? "gear.circle" : "shield.checkered")
                                    .foregroundColor(.blue)
                                    .symbolEffect(.variableColor, isActive: isDetectingWarranty)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(isDetectingWarranty ? "Detecting warranty..." : "Detect Warranty Info")
                                        .foregroundColor(.blue)
                                    Text("Analyze product details for warranty coverage")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .disabled(isDetectingWarranty)
                        
                        // Show detected warranty info
                        if let detectedWarranty {
                            WarrantyDetectionResultView(result: detectedWarranty)
                        }
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
                LegacyBarcodeScannerView(item: tempItem)
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
                        // Copy barcode if captured
                        if let scannedBarcode = tempItem.barcode, !scannedBarcode.isEmpty {
                            // Barcode will be saved with the item
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
            category: selectedCategory,
        )

        newItem.brand = brand.isEmpty ? nil : brand
        newItem.modelNumber = modelNumber.isEmpty ? nil : modelNumber
        newItem.serialNumber = serialNumber.isEmpty ? nil : serialNumber
        newItem.barcode = tempItem.barcode?.isEmpty == false ? tempItem.barcode : nil
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

    private func detectWarranty() async {
        guard !brand.isEmpty || !modelNumber.isEmpty || showPurchaseDetails else { return }
        
        isDetectingWarranty = true
        
        do {
            let warrantyEngine = WarrantyDetectionEngine(logger: Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nestory.app", category: "WarrantyDetection"))
            
            let result = try await warrantyEngine.detectWarrantyFromProduct(
                brand: brand.isEmpty ? nil : brand,
                model: modelNumber.isEmpty ? nil : modelNumber,
                serialNumber: serialNumber.isEmpty ? nil : serialNumber,
                purchaseDate: showPurchaseDetails ? purchaseDate : nil
            )
            
            await MainActor.run {
                detectedWarranty = result
                showingWarrantyDetection = true
            }
        } catch {
            await MainActor.run {
                detectedWarranty = nil
            }
        }
        
        isDetectingWarranty = false
    }
    
    private func setupDefaultCategories() {
        for defaultCategory in Category.createDefaultCategories() {
            modelContext.insert(defaultCategory)
        }
    }
}

// MARK: - Supporting Views

struct WarrantyDetectionResultView: View {
    let result: WarrantyDetectionResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "shield.fill")
                    .foregroundColor(.green)
                Text("Warranty Detected")
                    .font(.headline)
                    .foregroundColor(.green)
                Spacer()
                Text("\(Int(result.confidence * 100))% confidence")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if case .detected(let provider, let duration, _) = result {
                    HStack {
                        Text("Provider:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(provider)
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
                    HStack {
                        Text("Duration:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(duration) months")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    AddItemView()
        .modelContainer(for: [Item.self, Category.self], inMemory: true)
}

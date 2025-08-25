//
// Layer: Features 
// Module: AddItem
// Purpose: TCA-driven add item view with form validation and smart features
//

import ComposableArchitecture
import SwiftUI
import os.log

struct AddItemView: View {
    let store: StoreOf<AddItemFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                Form {
                    photoSection(viewStore)
                    barcodeScanSection(viewStore)
                    itemInformationSection(viewStore)
                    additionalDetailsSection(viewStore)
                    purchaseDetailsSection(viewStore)
                    warrantyDetectionSection(viewStore)
                    notesSection(viewStore)
                }
                .navigationTitle("Add Item")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent(viewStore)
                }
                .sheet(isPresented: viewStore.binding(
                    get: \.showingPhotoCapture,
                    send: { .photoCapturePresented($0) }
                )) {
                    PhotoCaptureView(imageData: viewStore.binding(
                        get: \.imageData,
                        send: { .imageDataSet($0) }
                    ))
                }
                .sheet(isPresented: viewStore.binding(
                    get: \.showingBarcodeScanner,
                    send: { .barcodeScannerPresented($0) }
                )) {
                    LegacyBarcodeScannerView(item: viewStore.tempItem)
                        .onDisappear {
                            viewStore.send(.barcodeDataLoaded(nil))
                        }
                }
                .alert("Error", isPresented: .constant(viewStore.errorMessage != nil)) {
                    Button("OK") { }
                } message: {
                    Text(viewStore.errorMessage ?? "")
                }
                .overlay {
                    if viewStore.isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(.systemBackground).opacity(0.8))
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
    
    @ViewBuilder
    private func photoSection(_ viewStore: ViewStoreOf<AddItemFeature>) -> some View {
        Section {
            Button(action: { 
                viewStore.send(.photoCaptureButtonTapped) 
            }) {
                if let imageData = viewStore.imageData,
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
    }
    
    @ViewBuilder
    private func barcodeScanSection(_ viewStore: ViewStoreOf<AddItemFeature>) -> some View {
        Section {
            Button(action: { 
                viewStore.send(.barcodeScannerButtonTapped) 
            }) {
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
    }
    
    @ViewBuilder
    private func itemInformationSection(_ viewStore: ViewStoreOf<AddItemFeature>) -> some View {
        Section("Item Information") {
            TextField("Item Name", text: viewStore.binding(
                get: \.name,
                send: { .nameChanged($0) }
            ))
            
            TextField("Description", text: viewStore.binding(
                get: \.itemDescription,
                send: { .descriptionChanged($0) }
            ), axis: .vertical)
                .lineLimit(2...4)
            
            Stepper("Quantity: \(viewStore.quantity)", value: viewStore.binding(
                get: \.quantity,
                send: { .quantityChanged($0) }
            ), in: 1...999)
            
            Picker("Category", selection: viewStore.binding(
                get: \.selectedCategory,
                send: { .categorySelected($0) }
            )) {
                Text("None").tag(nil as Category?)
                ForEach(viewStore.categories) { category in
                    Label(category.name, systemImage: category.icon)
                        .tag(category as Category?)
                }
            }
        }
    }
    
    @ViewBuilder
    private func additionalDetailsSection(_ viewStore: ViewStoreOf<AddItemFeature>) -> some View {
        Section("Additional Details") {
            TextField("Brand", text: viewStore.binding(
                get: \.brand,
                send: { .brandChanged($0) }
            ))
            
            TextField("Model Number", text: viewStore.binding(
                get: \.modelNumber,
                send: { .modelNumberChanged($0) }
            ))
            
            TextField("Serial Number", text: viewStore.binding(
                get: \.serialNumber,
                send: { .serialNumberChanged($0) }
            ))
            
            // Show barcode if captured
            if let scannedBarcode = viewStore.tempItem.barcode, !scannedBarcode.isEmpty {
                HStack {
                    Image(systemName: "barcode")
                        .foregroundColor(.accentColor)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Barcode: \(scannedBarcode)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if !viewStore.tempItem.name.isEmpty, viewStore.tempItem.name != "New Item" {
                            Text("Product details auto-populated")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                    Spacer()
                }
            }
            
            // Product codes captured indicator
            if !viewStore.modelNumber.isEmpty || !viewStore.serialNumber.isEmpty || (viewStore.tempItem.barcode?.isEmpty == false) {
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
    }
    
    @ViewBuilder
    private func purchaseDetailsSection(_ viewStore: ViewStoreOf<AddItemFeature>) -> some View {
        Section {
            Toggle("Purchase Information", isOn: viewStore.binding(
                get: \.showPurchaseDetails,
                send: { _ in .togglePurchaseDetails }
            ))
            
            if viewStore.showPurchaseDetails {
                TextField("Purchase Price", text: viewStore.binding(
                    get: \.purchasePrice,
                    send: { .purchasePriceChanged($0) }
                ))
                    .keyboardType(.decimalPad)
                
                DatePicker("Purchase Date", selection: viewStore.binding(
                    get: \.purchaseDate,
                    send: { .purchaseDateChanged($0) }
                ), displayedComponents: .date)
            }
        }
    }
    
    @ViewBuilder
    private func warrantyDetectionSection(_ viewStore: ViewStoreOf<AddItemFeature>) -> some View {
        // Warranty Detection Section
        if !viewStore.brand.isEmpty || !viewStore.modelNumber.isEmpty || viewStore.showPurchaseDetails {
            Section("Smart Warranty Detection") {
                Button(action: { 
                    viewStore.send(.warrantyDetectionStarted)
                }) {
                    HStack {
                        Image(systemName: viewStore.isDetectingWarranty ? "gear.circle" : "shield.checkered")
                            .foregroundColor(.blue)
                            .symbolEffect(.variableColor, isActive: viewStore.isDetectingWarranty)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewStore.isDetectingWarranty ? "Detecting warranty..." : "Detect Warranty Info")
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
                .disabled(viewStore.isDetectingWarranty)
                
                // Show detected warranty info
                if let detectedWarranty = viewStore.detectedWarranty {
                    WarrantyDetectionResultView(result: detectedWarranty)
                }
            }
        }
    }
    
    @ViewBuilder
    private func notesSection(_ viewStore: ViewStoreOf<AddItemFeature>) -> some View {
        Section("Notes") {
            TextEditor(text: viewStore.binding(
                get: \.notes,
                send: { .notesChanged($0) }
            ))
                .frame(minHeight: 60)
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarContent(_ viewStore: ViewStoreOf<AddItemFeature>) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                viewStore.send(.cancelButtonTapped)
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Save") {
                viewStore.send(.saveButtonTapped)
            }
            .fontWeight(.semibold)
            .disabled(!viewStore.canSave || viewStore.isSaving)
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

// MARK: - Preview

#Preview {
    AddItemView(
        store: Store(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
    )
}
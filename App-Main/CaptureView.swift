//
// Layer: App
// Module: Capture
// Purpose: Standalone capture tab for creating new items via barcode scanning
//

import ComposableArchitecture
import SwiftUI
import PhotosUI

struct CaptureView: View {
    @Dependency(\.barcodeScannerService) var scanner
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var scannedResult: BarcodeResult?
    @State private var productInfo: ProductInfo?
    @State private var isProcessing = false
    @State private var showingManualEntry = false
    @State private var createdItem: Item?
    @State private var showingItemDetail = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let result = scannedResult {
                    // Show scan result and option to create item
                    ScanResultView(
                        result: result,
                        productInfo: productInfo,
                        onApply: createItemFromScan,
                        onRescan: rescan
                    )
                } else {
                    // Show scan options
                    ScanOptionsView(
                        onCameraScan: checkCameraAndScan,
                        onPhotoScan: { showingPhotoPicker = true },
                        onManualEntry: { showingManualEntry = true }
                    )
                }
                
                Spacer()
                
                // Tips section
                if scannedResult == nil {
                    ScanningTipsView()
                }
            }
            .navigationTitle("Capture")
            .navigationBarTitleDisplayMode(.large)
            .overlay {
                if isProcessing {
                    ProcessingOverlay()
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraScannerView(scanner: scanner, onScan: handleScanResult)
            }
            .photosPicker(
                isPresented: $showingPhotoPicker,
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: selectedPhotoItem) { _, newValue in
                if let item = newValue {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            await processImageForBarcode(data)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualBarcodeEntryView(onSave: handleManualEntry)
            }
            .sheet(item: $createdItem) { item in
                ItemDetailView(item: item)
            }
        }
    }
    
    // MARK: - Actions
    
    private func checkCameraAndScan() {
        Task {
            if await scanner.checkCameraPermission() {
                showingCamera = true
            }
        }
    }
    
    private func handleScanResult(_ result: BarcodeResult) {
        scannedResult = result
        
        // Look up product info if it's a product barcode
        if !result.isSerialNumber {
            Task {
                productInfo = await scanner.lookupProduct(
                    barcode: result.value,
                    type: result.type
                )
            }
        }
    }
    
    private func processImageForBarcode(_ imageData: Data) async {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            if let result = try await scanner.detectBarcode(from: imageData) {
                await MainActor.run {
                    handleScanResult(result)
                }
            }
        } catch {
            // Handle error silently for now
            // TODO: Add proper error handling
        }
    }
    
    private func handleManualEntry(value: String, type: String) {
        let result = BarcodeResult(
            value: value,
            type: type,
            confidence: 1.0
        )
        handleScanResult(result)
    }
    
    private func createItemFromScan() {
        guard let result = scannedResult else { return }
        
        // Create new item with scanned data
        let newItem = Item(name: "New Item")
        
        // Apply scanned data to item
        if result.isSerialNumber {
            newItem.serialNumber = result.value
        } else {
            newItem.barcode = result.value
        }
        
        // Apply product info if available
        if let product = productInfo {
            newItem.name = product.name.isEmpty ? "New Item" : product.name
            newItem.brand = product.brand
            newItem.modelNumber = product.model
            if let estimatedValue = product.estimatedValue {
                newItem.purchasePrice = Decimal(estimatedValue)
            }
        }
        
        // Save item to model context
        modelContext.insert(newItem)
        
        do {
            try modelContext.save()
            
            // Reset state and show item detail
            scannedResult = nil
            productInfo = nil
            selectedPhotoItem = nil
            createdItem = newItem
            showingItemDetail = true
            
        } catch {
            // Handle save error
            // TODO: Show error alert
        }
    }
    
    private func rescan() {
        scannedResult = nil
        productInfo = nil
        selectedPhotoItem = nil
    }
}

// MARK: - Processing Overlay

private struct ProcessingOverlay: View {
    var body: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Processing...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(30)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
    }
}

#Preview {
    CaptureView()
        .modelContainer(for: [Item.self, Category.self], inMemory: true)
}
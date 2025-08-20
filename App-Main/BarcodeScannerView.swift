//
// Layer: App
// Module: BarcodeScanner
// Purpose: Main barcode scanner coordinator view
//
// REMINDER: This view MUST be wired up in AddItemView and EditItemView
// Provides barcode/QR code scanning for quick item entry

import AVFoundation
import SwiftUI
import Vision

struct BarcodeScannerView: View {
    @Bindable var item: Item
    @StateObject private var scanner = LiveBarcodeScannerService()
    @Environment(\.dismiss) private var dismiss

    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var selectedImage: Data?
    @State private var scannedResult: BarcodeResult?
    @State private var productInfo: ProductInfo?
    @State private var isProcessing = false
    @State private var showingManualEntry = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Show scan options or results
                if let result = scannedResult {
                    ScanResultView(
                        result: result,
                        productInfo: productInfo,
                        onApply: applyScanResult,
                        onRescan: rescan,
                    )
                } else {
                    ScanOptionsView(
                        onCameraScan: checkCameraAndScan,
                        onPhotoScan: { showingPhotoPicker = true },
                        onManualEntry: { showingManualEntry = true },
                    )
                }

                Spacer()

                // Tips section
                if scannedResult == nil {
                    ScanningTipsView()
                }
            }
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if isProcessing {
                    ProcessingOverlay()
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraScannerView(scanner: scanner, onScan: handleScanResult)
            }
            .sheet(isPresented: $showingPhotoPicker) {
                PhotoPicker(imageData: $selectedImage)
                    .onChange(of: selectedImage) { _, newValue in
                        if let data = newValue {
                            Task {
                                await processImageForBarcode(data)
                            }
                        }
                    }
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualBarcodeEntryView(onSave: handleManualEntry)
            }
            .alert("Scanner Error", isPresented: .constant(scanner.errorMessage != nil)) {
                Button("OK") {
                    scanner.errorMessage = nil
                }
            } message: {
                Text(scanner.errorMessage ?? "Unknown error")
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
                    type: result.type,
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
            } else {
                await MainActor.run {
                    scanner.errorMessage = "No barcode found in image"
                }
            }
        } catch {
            await MainActor.run {
                scanner.errorMessage = error.localizedDescription
            }
        }
    }

    private func handleManualEntry(value: String, type: String) {
        let result = BarcodeResult(
            value: value,
            type: type,
            confidence: 1.0,
        )
        handleScanResult(result)
    }

    private func applyScanResult() {
        guard let result = scannedResult else { return }

        // Apply scanned data to item
        if result.isSerialNumber {
            item.serialNumber = result.value
        } else {
            // It's a product barcode - store in model number field
            item.modelNumber = result.value
        }

        // Apply product info if available
        if let product = productInfo {
            if item.name.isEmpty || item.name == "New Item" {
                item.name = product.name
            }
            if item.brand == nil, let brand = product.brand {
                item.brand = brand
            }
        }

        item.updatedAt = Date()
        dismiss()
    }

    private func rescan() {
        scannedResult = nil
        productInfo = nil
        selectedImage = nil
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
    BarcodeScannerView(item: Item(name: "Test Item"))
        .modelContainer(for: [Item.self, Category.self], inMemory: true)
}

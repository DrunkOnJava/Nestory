//
// Layer: App
// Module: BarcodeScanner
// Purpose: TCA-driven barcode scanner coordinator view
//
// 🏗️ TCA PATTERN: Dependency injection for service access
// - Uses @Dependency for BarcodeScannerService instead of @StateObject
// - Clean separation between UI logic and service implementation
// - Testable through TCA dependency injection system
//
// 🎯 INSURANCE FOCUS: Quick item documentation through barcode scanning
// - Rapid item entry for insurance inventory cataloging
// - Product lookup for accurate item valuation
// - Streamlined workflow for claim preparation
//
// APPLE_FRAMEWORK_OPPORTUNITY: Vision Framework - VNDetectBarcodesRequest for enhanced detection

import AVFoundation
import ComposableArchitecture
import SwiftUI
import Vision
import PhotosUI

struct LegacyBarcodeScannerView: View {
    @Bindable var item: Item
    @Dependency(\.barcodeScannerService) var scanner
    @Environment(\.dismiss) private var dismiss

    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
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
            // TODO: P0.1.4 - Fix BarcodeScannerService protocol to include errorMessage
            // .alert("Scanner Error", isPresented: .constant(scanner.errorMessage != nil)) {
            //     Button("OK") {
            //         scanner.errorMessage = nil
            //     }
            // } message: {
            //     Text(scanner.errorMessage ?? "Unknown error")
            // }
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
                    // TODO: P0.1.4 - Fix BarcodeScannerService protocol
                    // scanner.errorMessage = "No barcode found in image"
                }
            }
        } catch {
            await MainActor.run {
                // TODO: P0.1.4 - Fix BarcodeScannerService protocol
                // scanner.errorMessage = error.localizedDescription
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
            // It's a product barcode - store in barcode field
            item.barcode = result.value
        }

        // Apply product info if available
        if let product = productInfo {
            if item.name.isEmpty || item.name == "New Item" {
                item.name = product.name
            }
            if item.brand == nil, let brand = product.brand {
                item.brand = brand
            }
            if item.modelNumber == nil, let model = product.model {
                item.modelNumber = model
            }
            // Set estimated value if available and no purchase price exists
            if item.purchasePrice == nil, let estimatedValue = product.estimatedValue {
                item.purchasePrice = Decimal(estimatedValue)
            }
        }

        item.updatedAt = Date()
        dismiss()
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

// MARK: - Compatibility Alias for Legacy Views

/// Compatibility alias for views that still reference BarcodeScannerView
typealias BarcodeScannerView = LegacyBarcodeScannerView

#Preview {
    LegacyBarcodeScannerView(item: Item(name: "Test Item"))
        .modelContainer(for: [Item.self, Category.self], inMemory: true)
}

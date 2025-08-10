//
//  ReceiptCaptureView.swift
//  Nestory
//

import PhotosUI
import SwiftData
import SwiftUI
import VisionKit

struct ReceiptCaptureView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss
    @StateObject private var ocrService = ReceiptOCRService()

    @State private var showingScanner = false
    @State private var showingPhotoPicker = false
    @State private var scannedImage: UIImage?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var extractedText = ""
    @State private var isProcessing = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Receipt Image Display
                    if let receiptData = item.receiptImageData,
                       let uiImage = UIImage(data: receiptData)
                    {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current Receipt")
                                .font(.headline)

                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                                .shadow(radius: 2)

                            HStack {
                                Button("Replace Receipt") {
                                    showCaptureOptions()
                                }
                                .buttonStyle(.bordered)

                                Button("Remove Receipt", role: .destructive) {
                                    item.receiptImageData = nil
                                    item.extractedReceiptText = nil
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    } else {
                        // No Receipt - Show Capture Options
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.viewfinder")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)

                            Text("Add Receipt")
                                .font(.headline)

                            Text("Capture or import a receipt to automatically extract purchase information")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)

                            HStack(spacing: 12) {
                                Button(action: { showingScanner = true }) {
                                    Label("Scan Receipt", systemImage: "doc.text.viewfinder")
                                }
                                .buttonStyle(.borderedProminent)

                                Button(action: { showingPhotoPicker = true }) {
                                    Label("Choose Photo", systemImage: "photo")
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }

                    // Extracted Text Display
                    if !extractedText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Extracted Information")
                                    .font(.headline)
                                Spacer()
                                Button("Apply to Item") {
                                    applyExtractedData()
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(isProcessing)
                            }

                            ScrollView {
                                Text(extractedText)
                                    .font(.caption)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.tertiarySystemBackground))
                                    .cornerRadius(8)
                            }
                            .frame(maxHeight: 200)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }

                    // Processing Indicator
                    if isProcessing {
                        HStack {
                            ProgressView()
                            Text("Processing receipt...")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }

                    // Tips
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Tips for Best Results", systemImage: "lightbulb")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Ensure receipt is well-lit and flat")
                            Text("• Include the entire receipt in frame")
                            Text("• Avoid shadows and glare")
                            Text("• Text should be clearly readable")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Receipt Capture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingScanner) {
                if #available(iOS 16.0, *) {
                    DocumentScannerView(scannedImage: $scannedImage)
                        .ignoresSafeArea()
                        .onDisappear {
                            if let image = scannedImage {
                                processScannedImage(image)
                            }
                        }
                }
            }
            .photosPicker(
                isPresented: $showingPhotoPicker,
                selection: $selectedPhoto,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let photo = newValue {
                        await loadPhoto(from: photo)
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func showCaptureOptions() {
        // Reset state
        extractedText = ""
        scannedImage = nil
        selectedPhoto = nil

        // Show action sheet could go here, but for simplicity showing scanner
        showingScanner = true
    }

    private func processScannedImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            showError("Failed to process image")
            return
        }

        item.receiptImageData = imageData
        extractTextFromReceipt(imageData)
    }

    private func loadPhoto(from item: PhotosPickerItem) async {
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        processScannedImage(uiImage)
                    }
                }
            }
        } catch {
            await MainActor.run {
                showError("Failed to load photo: \(error.localizedDescription)")
            }
        }
    }

    private func extractTextFromReceipt(_ imageData: Data) {
        isProcessing = true

        Task {
            do {
                let text = try await ocrService.extractTextFromImage(imageData)
                let receiptData = ocrService.parseReceiptData(from: text)

                await MainActor.run {
                    extractedText = formatExtractedData(receiptData)

                    // Auto-apply if confident
                    if receiptData.totalAmount != nil || receiptData.date != nil {
                        ocrService.autoFillItemFromReceipt(receiptData, for: item)
                    }

                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    showError("OCR failed: \(error.localizedDescription)")
                    isProcessing = false
                }
            }
        }
    }

    private func formatExtractedData(_ data: ReceiptOCRService.ReceiptData) -> String {
        var result = "=== Extracted Receipt Data ===\n\n"

        if let store = data.storeName {
            result += "Store: \(store)\n"
        }

        if let date = data.date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            result += "Date: \(formatter.string(from: date))\n"
        }

        if let total = data.totalAmount {
            result += "Total: $\(total)\n"
        }

        if !data.items.isEmpty {
            result += "\nItems Found:\n"
            for item in data.items {
                result += "• \(item.name)"
                if let price = item.price {
                    result += " - $\(price)"
                }
                if let qty = item.quantity {
                    result += " (Qty: \(qty))"
                }
                result += "\n"
            }
        }

        result += "\n--- Full Text ---\n\(data.fullText)"

        return result
    }

    private func applyExtractedData() {
        // Data is already applied via autoFillItemFromReceipt
        dismiss()
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

#Preview {
    let container = try! ModelContainer(for: Item.self, configurations: .init(isStoredInMemoryOnly: true))
    let item = Item(name: "Sample Item")
    container.mainContext.insert(item)

    return ReceiptCaptureView(item: item)
        .modelContainer(container)
}

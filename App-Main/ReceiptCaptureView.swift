//
//  ReceiptCaptureView.swift
//  Nestory
//

import ComposableArchitecture
import PhotosUI
import SwiftData
import SwiftUI
import VisionKit

struct ReceiptCaptureView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Dependency(\.receiptOCRService) var ocrService

    @State private var showingScanner = false
    @State private var showingPhotoPicker = false
    @State private var scannedImage: UIImage?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var extractedText = ""
    @State private var isProcessing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var latestReceipt: Receipt?
    @State private var ocrConfidence = 0.0
    @State private var showingReceiptPreview = false
    @State private var enhancedReceiptData: EnhancedReceiptData?
    @State private var showingMLProgress = false

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

                    // ML Processing Progress
                    if showingMLProgress || isProcessing {
                        VStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Processing receipt...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }

                    // Enhanced Receipt Data Display
                    if let enhancedData = enhancedReceiptData {
                        EnhancedReceiptDataView(data: enhancedData)
                    }

                    // Extracted Text Display
                    if !extractedText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Extracted Information")
                                        .font(.headline)
                                    if ocrConfidence > 0 {
                                        HStack(spacing: 4) {
                                            Text("Confidence:")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text(confidenceText)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(confidenceColor)
                                        }
                                    }
                                }
                                Spacer()
                                VStack(spacing: 4) {
                                    Button("Apply to Item") {
                                        applyExtractedData()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .disabled(isProcessing)

                                    if latestReceipt != nil {
                                        Button("View Receipt") {
                                            showingReceiptPreview = true
                                        }
                                        .buttonStyle(.bordered)
                                        .font(.caption)
                                    }
                                }
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
                    // TODO: ARCH - Move DocumentScannerView to UI layer for proper access
                    // DocumentScannerView(scannedImage: $scannedImage)
                    Text("Document Scanner - Architecture Fix Needed")
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
                photoLibrary: .shared(),
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
            .sheet(isPresented: $showingReceiptPreview) {
                if let receipt = latestReceipt {
                    ReceiptDetailView(receipt: receipt)
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var confidenceText: String {
        switch ocrConfidence {
        case 0.9 ... 1.0: "Excellent"
        case 0.7 ..< 0.9: "Good"
        case 0.5 ..< 0.7: "Fair"
        case 0.0 ..< 0.5: "Poor"
        default: "Unknown"
        }
    }

    private var confidenceColor: Color {
        switch ocrConfidence {
        case 0.9 ... 1.0: .green
        case 0.7 ..< 0.9: .blue
        case 0.5 ..< 0.7: .orange
        case 0.0 ..< 0.5: .red
        default: .secondary
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
        guard let image = UIImage(data: imageData) else {
            showError("Invalid image data")
            return
        }

        isProcessing = true
        showingMLProgress = true

        Task {
            do {
                // Use enhanced ML processing  
                let enhancedData = try await ocrService.processReceiptImage(image)

                await MainActor.run {
                    self.enhancedReceiptData = enhancedData
                    extractedText = formatEnhancedReceiptData(enhancedData)
                    ocrConfidence = enhancedData.confidence

                    // Create Receipt model from enhanced data
                    let receipt = createReceiptFromEnhancedData(enhancedData, imageData: imageData)
                    if let receipt {
                        latestReceipt = receipt
                        modelContext.insert(receipt)
                        try? modelContext.save()
                    }

                    isProcessing = false
                    showingMLProgress = false
                }
            } catch {
                await MainActor.run {
                    showError("Enhanced OCR failed: \(error.localizedDescription)")
                    isProcessing = false
                    showingMLProgress = false
                }
            }
        }
    }

    private func createReceiptFromEnhancedData(_ data: EnhancedReceiptData, imageData: Data) -> Receipt? {
        guard let vendor = data.vendor,
              let total = data.total,
              let date = data.date
        else {
            return nil
        }

        let money = Money(amount: total, currencyCode: "USD")
        let receipt = Receipt(vendor: vendor, total: money, purchaseDate: date, item: item)

        // Set enhanced data
        receipt.setOCRResults(
            text: data.rawText,
            confidence: data.confidence,
            categories: data.categories
        )

        if let tax = data.tax {
            receipt.taxMoney = Money(amount: tax, currencyCode: "USD")
        }

        receipt.setImageData(imageData, fileName: "receipt_\(receipt.id.uuidString).jpg")

        return receipt
    }

    private func formatEnhancedReceiptData(_ data: EnhancedReceiptData) -> String {
        var result = "=== AI-Enhanced Receipt Analysis ===\n\n"

        if let vendor = data.vendor {
            result += "🏪 Vendor: \(vendor)\n"
        }

        if let total = data.total {
            result += "💰 Total: $\(total)\n"
        }

        if let tax = data.tax {
            result += "🧾 Tax: $\(tax)\n"
        }

        if let date = data.date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            result += "📅 Date: \(formatter.string(from: date))\n"
        }

        if !data.categories.isEmpty {
            result += "🏷️ Categories: \(data.categories.joined(separator: ", "))\n"
        }

        result += "🎯 Confidence: \(Int(data.confidence * 100))%\n"

        if data.processingMetadata.mlClassifierUsed {
            result += "🤖 Enhanced with Machine Learning\n"
        }

        if !data.items.isEmpty {
            result += "\n📝 Items Detected:\n"
            for (index, item) in data.items.enumerated() {
                result += "\(index + 1). \(item.name) - $\(item.price)\n"
            }
        }

        result += "\n--- Raw OCR Text ---\n\(data.rawText)"

        return result
    }

    // Legacy formatExtractedData method removed - replaced by formatEnhancedReceiptData
    // which properly handles the new EnhancedReceiptData structure

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
    do {
        let container = try ModelContainer(for: Item.self, configurations: .init(isStoredInMemoryOnly: true))
        let item = Item(name: "Sample Item")
        container.mainContext.insert(item)

        return ReceiptCaptureView(item: item)
            .modelContainer(container)
    } catch {
        return Text("Preview Error: \(error.localizedDescription)")
    }
}

//
// Layer: App
// Module: LiveReceiptScannerView
// Purpose: VisionKit-powered live receipt scanning with real-time text recognition
//

import SwiftUI
import VisionKit

@available(iOS 16.0, *)
struct LiveReceiptScannerView: UIViewControllerRepresentable {
    @Binding var scannedText: String
    @Binding var isPresented: Bool

    let onReceiptDetected: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scannerViewController = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )

        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }

    func updateUIViewController(_: DataScannerViewController, context _: Context) {
        // Update configuration if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let parent: LiveReceiptScannerView

        init(_ parent: LiveReceiptScannerView) {
            self.parent = parent
        }

        func dataScanner(_: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case let .text(text):
                parent.scannedText = text.transcript
                parent.onReceiptDetected(text.transcript)
            default:
                break
            }
        }

        func dataScanner(_: DataScannerViewController, didAdd _: [RecognizedItem], allItems: [RecognizedItem]) {
            // Automatically process when enough text is detected
            let textItems = allItems.compactMap { item -> String? in
                if case let .text(text) = item {
                    return text.transcript
                }
                return nil
            }

            if textItems.count >= 5 { // Minimum lines for a receipt
                let fullText = textItems.joined(separator: "\n")
                parent.scannedText = fullText
                parent.onReceiptDetected(fullText)
            }
        }

        func dataScanner(_: DataScannerViewController, didRemove _: [RecognizedItem], allItems _: [RecognizedItem]) {
            // Handle removed items if needed
        }

        func dataScanner(_: DataScannerViewController, didUpdate _: [RecognizedItem], allItems _: [RecognizedItem]) {
            // Handle updated recognition
        }

        func dataScannerDidStartScanning(_: DataScannerViewController) {
            // Scanning started
        }

        func dataScannerDidStopScanning(_: DataScannerViewController) {
            // Scanning stopped
        }
    }
}

// MARK: - Enhanced Receipt Capture with VisionKit

struct EnhancedReceiptCaptureView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var appleProcessor = AppleFrameworksReceiptProcessor()

    @State private var showingLiveScanner = false
    @State private var showingPhotoPicker = false
    @State private var scannedText = ""
    @State private var isProcessing = false
    @State private var enhancedData: EnhancedReceiptData?
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Live Scanning Option (iOS 16+)
                    if DataScannerViewController.isSupported, DataScannerViewController.isAvailable {
                        VStack(spacing: 16) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)

                            Text("Live Receipt Scanning")
                                .font(.headline)

                            Text("Point your camera at a receipt for instant recognition")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)

                            Button("Start Live Scanning") {
                                showingLiveScanner = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }

                    // Traditional Photo Capture
                    VStack(spacing: 16) {
                        Image(systemName: "camera")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)

                        Text("Traditional Capture")
                            .font(.headline)

                        HStack(spacing: 12) {
                            Button("Take Photo") {
                                // Camera capture
                            }
                            .buttonStyle(.bordered)

                            Button("Choose from Photos") {
                                showingPhotoPicker = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(12)

                    // Apple Frameworks Benefits
                    AppleFrameworksBenefitsView()

                    // Processing Results
                    if let data = enhancedData {
                        EnhancedReceiptDataView(data: data)
                    }

                    if !scannedText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Live Scanned Text")
                                .font(.headline)

                            ScrollView {
                                Text(scannedText)
                                    .font(.caption)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.tertiarySystemBackground))
                                    .cornerRadius(8)
                            }
                            .frame(maxHeight: 200)

                            Button("Process with Apple ML") {
                                processScannedText()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isProcessing)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Enhanced Scanning")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showingLiveScanner) {
            if #available(iOS 16.0, *) {
                LiveReceiptScannerView(
                    scannedText: $scannedText,
                    isPresented: $showingLiveScanner
                ) { text in
                    scannedText = text
                    showingLiveScanner = false
                }
            }
        }
        .alert("Processing Error", isPresented: $showingError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }

    private func processScannedText() {
        guard !scannedText.isEmpty else { return }

        isProcessing = true

        Task {
            do {
                // Create a simple image from text (for demo - in practice you'd use the actual image)
                let image = createImageFromText(scannedText)
                let result = try await appleProcessor.processReceiptImage(image)

                await MainActor.run {
                    enhancedData = result
                    createReceiptFromData(result)
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isProcessing = false
                }
            }
        }
    }

    private func createReceiptFromData(_ data: EnhancedReceiptData) {
        guard let vendor = data.vendor,
              let total = data.total,
              let date = data.date else { return }

        let money = Money(amount: total, currencyCode: "USD")
        let receipt = Receipt(vendor: vendor, total: money, purchaseDate: date, item: item)

        receipt.setOCRResults(
            text: data.rawText,
            confidence: data.confidence,
            categories: data.categories
        )

        if let tax = data.tax {
            receipt.taxMoney = Money(amount: tax, currencyCode: "USD")
        }

        modelContext.insert(receipt)
        try? modelContext.save()
    }

    private func createImageFromText(_ text: String) -> UIImage {
        // Create a simple image for demo purposes
        // In practice, you'd use the actual captured image
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 300, height: 400), false, 0)
        defer { UIGraphicsEndImageContext() }

        let rect = CGRect(x: 0, y: 0, width: 300, height: 400)
        UIColor.white.setFill()
        UIRectFill(rect)

        text.draw(in: rect.insetBy(dx: 10, dy: 10), withAttributes: [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black,
        ])

        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}

// MARK: - Apple Frameworks Benefits Display

struct AppleFrameworksBenefitsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Apple Frameworks Integration")
                .font(.headline)

            FrameworkBenefit(
                icon: "camera.viewfinder",
                title: "VisionKit",
                description: "Live text recognition with automatic document detection"
            )

            FrameworkBenefit(
                icon: "eye",
                title: "Vision Framework",
                description: "Advanced OCR with language correction and custom vocabulary"
            )

            FrameworkBenefit(
                icon: "brain.head.profile",
                title: "Natural Language",
                description: "Intelligent text analysis with named entity recognition"
            )

            FrameworkBenefit(
                icon: "cube.box",
                title: "Core ML",
                description: "On-device machine learning for classification"
            )
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct FrameworkBenefit: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - Preview

struct EnhancedReceiptCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        let item = Item(name: "Sample Item")

        EnhancedReceiptCaptureView(item: item)
            .previewDisplayName("Enhanced Capture")
    }
}

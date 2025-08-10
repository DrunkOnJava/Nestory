//
//  BarcodeScannerView.swift
//  Nestory
//
//  REMINDER: This view MUST be wired up in AddItemView and EditItemView
//  Provides barcode/QR code scanning for quick item entry

import SwiftUI
import AVFoundation
import Vision

struct BarcodeScannerView: View {
    @Bindable var item: Item
    @StateObject private var scanner = BarcodeScannerService()
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
                // Scan Options
                VStack(spacing: 20) {
                    // Camera scan button
                    Button(action: { checkCameraAndScan() }) {
                        VStack(spacing: 12) {
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 50))
                                .foregroundColor(.accentColor)
                            Text("Scan with Camera")
                                .font(.headline)
                            Text("Point at barcode or serial number")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    // Photo picker button
                    Button(action: { showingPhotoPicker = true }) {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            Text("Select from Photos")
                                .font(.headline)
                            Text("Choose photo with barcode")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 25)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    // Manual entry button
                    Button(action: { showingManualEntry = true }) {
                        HStack {
                            Image(systemName: "keyboard")
                                .foregroundColor(.blue)
                            Text("Enter Manually")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                
                // Scanned Result Display
                if let result = scannedResult {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Scanned Successfully!")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        GroupBox {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Value:")
                                        .foregroundColor(.secondary)
                                    Text(result.value)
                                        .font(.system(.body, design: .monospaced))
                                        .textSelection(.enabled)
                                }
                                
                                HStack {
                                    Text("Type:")
                                        .foregroundColor(.secondary)
                                    Text(result.type)
                                    
                                    Spacer()
                                    
                                    if result.isSerialNumber {
                                        Label("Serial Number", systemImage: "number")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(6)
                                    } else {
                                        Label("Product Code", systemImage: "barcode")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.orange.opacity(0.1))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                        }
                        
                        // Product info if available
                        if let product = productInfo {
                            GroupBox("Product Information") {
                                VStack(alignment: .leading, spacing: 8) {
                                    if !product.name.isEmpty {
                                        DetailRow(label: "Name", value: product.name)
                                    }
                                    if let brand = product.brand {
                                        DetailRow(label: "Brand", value: brand)
                                    }
                                    if let model = product.model {
                                        DetailRow(label: "Model", value: model)
                                    }
                                }
                            }
                        }
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            Button(action: applyScanResult) {
                                Label("Apply to Item", systemImage: "checkmark.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button(action: rescan) {
                                Label("Scan Again", systemImage: "arrow.clockwise")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
                
                // Tips section
                if scannedResult == nil {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Scanning Tips", systemImage: "lightbulb")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("• Hold steady with good lighting")
                                .font(.caption2)
                            Text("• Barcode should fill most of frame")
                                .font(.caption2)
                            Text("• Works with UPC, EAN, QR codes")
                                .font(.caption2)
                            Text("• Serial numbers on product labels")
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding()
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
            confidence: 1.0
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

// MARK: - Camera Scanner View

struct CameraScannerView: UIViewControllerRepresentable {
    let scanner: BarcodeScannerService
    let onScan: (BarcodeResult) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> CameraScannerViewController {
        let controller = CameraScannerViewController()
        controller.scanner = scanner
        controller.onScan = { result in
            onScan(result)
            dismiss()
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraScannerViewController, context: Context) {}
}

class CameraScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var scanner: BarcodeScannerService?
    var onScan: ((BarcodeResult) -> Void)?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession?.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let captureSession = captureSession else { return }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [
                .ean8, .ean13, .pdf417, .qr, .code128,
                .code39, .code93, .upce, .aztec, .dataMatrix
            ]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
        
        // Add overlay
        addScanOverlay()
    }
    
    private func addScanOverlay() {
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.isUserInteractionEnabled = false
        
        let scanRect = CGRect(x: 50, y: 200, width: view.bounds.width - 100, height: 200)
        let path = UIBezierPath(rect: overlayView.bounds)
        let scanPath = UIBezierPath(rect: scanRect)
        path.append(scanPath.reversing())
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        overlayView.layer.mask = maskLayer
        
        view.addSubview(overlayView)
        
        // Add scan frame
        let frameView = UIView(frame: scanRect)
        frameView.layer.borderColor = UIColor.systemYellow.cgColor
        frameView.layer.borderWidth = 2
        frameView.layer.cornerRadius = 8
        frameView.isUserInteractionEnabled = false
        view.addSubview(frameView)
        
        // Add instruction label
        let label = UILabel()
        label.text = "Position barcode within frame"
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100)
        ])
    }
    
    nonisolated func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        Task { @MainActor in
            guard !hasScanned,
                  let metadataObject = metadataObjects.first,
                  let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }
            
            hasScanned = true
            
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            let result = BarcodeResult(
                value: stringValue,
                type: readableObject.type.rawValue,
                confidence: 1.0
            )
            
            onScan?(result)
        }
    }
}

// MARK: - Manual Entry View

struct ManualBarcodeEntryView: View {
    @State private var barcodeValue = ""
    @State private var selectedType = "UPC"
    @Environment(\.dismiss) private var dismiss
    
    let onSave: (String, String) -> Void
    
    let barcodeTypes = ["UPC", "EAN", "Serial Number", "QR Code", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Barcode Information") {
                    TextField("Barcode Value", text: $barcodeValue)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .font(.system(.body, design: .monospaced))
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(barcodeTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                }
                
                Section {
                    Text("Enter the barcode number exactly as it appears on the product label.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(barcodeValue, selectedType)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(barcodeValue.isEmpty)
                }
            }
        }
    }
}

#Preview {
    BarcodeScannerView(item: Item(name: "Test Item"))
        .modelContainer(for: [Item.self, Category.self], inMemory: true)
}
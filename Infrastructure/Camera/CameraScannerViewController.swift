//
// Layer: Infrastructure
// Module: Camera
// Purpose: Camera scanner view controller for barcode detection
//

import AVFoundation
import UIKit

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with VisionKit - Use VNDocumentCameraViewController for document scanning and VNBarcodeObservation for barcode detection

public class CameraScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    public var scanner: BarcodeScannerService?
    public var onScan: ((BarcodeResult) -> Void)?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession?.startRunning()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let captureSession else { return }

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
                .code39, .code93, .upce, .aztec, .dataMatrix,
            ]
        } else {
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill

        if let previewLayer {
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
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
        ])
    }

    public nonisolated func metadataOutput(_: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from _: AVCaptureConnection) {
        guard let firstObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = firstObject.stringValue else { return }

        let typeRawValue = firstObject.type.rawValue

        Task { @MainActor in
            guard !hasScanned else { return }
            hasScanned = true

            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()

            let result = BarcodeResult(
                value: stringValue,
                type: typeRawValue,
                confidence: 1.0,
            )

            onScan?(result)
        }
    }
}

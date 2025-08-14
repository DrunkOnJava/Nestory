//
// Layer: UI
// Module: UI-Components
// Purpose: Document scanner view using VisionKit framework
//

import SwiftUI
import VisionKit

@available(iOS 16.0, *)
public struct DocumentScannerView: UIViewControllerRepresentable {
    @Binding var scannedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    public init(scannedImage: Binding<UIImage?>) {
        _scannedImage = scannedImage
    }

    public func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    public func updateUIViewController(_: VNDocumentCameraViewController, context _: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate, @unchecked Sendable {
        let parent: DocumentScannerView

        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }

        @MainActor
        private func handleDismiss() {
            parent.dismiss()
        }

        @MainActor
        private func handleScan(_ image: UIImage) {
            parent.scannedImage = image
            parent.dismiss()
        }

        public func documentCameraViewController(
            _: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan,
        ) {
            guard scan.pageCount > 0 else {
                Task { @MainActor in
                    self.handleDismiss()
                }
                return
            }

            let image = scan.imageOfPage(at: 0)
            Task { @MainActor in
                self.handleScan(image)
            }
        }

        public func documentCameraViewControllerDidCancel(_: VNDocumentCameraViewController) {
            Task { @MainActor in
                self.handleDismiss()
            }
        }

        public func documentCameraViewController(
            _: VNDocumentCameraViewController,
            didFailWithError _: Error,
        ) {
            Task { @MainActor in
                self.handleDismiss()
            }
        }
    }
}

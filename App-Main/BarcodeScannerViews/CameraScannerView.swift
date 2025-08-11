//
// Layer: App
// Module: BarcodeScanner
// Purpose: SwiftUI wrapper for camera scanner view controller
//

import SwiftUI

struct CameraScannerView: UIViewControllerRepresentable {
    let scanner: BarcodeScannerService
    let onScan: (BarcodeResult) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context _: Context) -> CameraScannerViewController {
        let controller = CameraScannerViewController()
        controller.scanner = scanner
        controller.onScan = { result in
            onScan(result)
            dismiss()
        }
        return controller
    }

    func updateUIViewController(_: CameraScannerViewController, context _: Context) {}
}

#Preview {
    CameraScannerView(
        scanner: BarcodeScannerService(),
        onScan: { _ in },
    )
}

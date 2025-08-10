//
// Layer: App
// Module: BarcodeScanner
// Purpose: Scanning tips display component
//

import SwiftUI

struct ScanningTipsView: View {
    var body: some View {
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

#Preview {
    ScanningTipsView()
}
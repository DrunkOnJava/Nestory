//
// Layer: App
// Module: BarcodeScanner
// Purpose: Scan options selection view for barcode scanning
//

import SwiftUI

struct ScanOptionsView: View {
    let onCameraScan: () -> Void
    let onPhotoScan: () -> Void
    let onManualEntry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Camera scan button
            Button(action: onCameraScan) {
                VStack(spacing: 12) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 50))
                        .foregroundColor(.accentColor)
                    Text("Scan with Camera")
                        .font(.headline)
                    Text("Auto-detects product info and categories")
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
            Button(action: onPhotoScan) {
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    Text("Select from Photos")
                        .font(.headline)
                    Text("Extract product details from photo")
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
            Button(action: onManualEntry) {
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
    }
}

#Preview {
    ScanOptionsView(
        onCameraScan: {},
        onPhotoScan: {},
        onManualEntry: {},
    )
}

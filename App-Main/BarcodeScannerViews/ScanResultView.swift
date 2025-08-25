//
// Layer: App
// Module: BarcodeScanner
// Purpose: Display scanned barcode results
//

import SwiftUI

struct ScanResultView: View {
    let result: BarcodeResult
    let productInfo: ProductInfo?
    let onApply: () -> Void
    let onRescan: () -> Void

    var body: some View {
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
                            ScanDetailRow(label: "Name", value: product.name, icon: "tag.fill")
                        }
                        if let brand = product.brand {
                            ScanDetailRow(label: "Brand", value: brand, icon: "building.2.fill")
                        }
                        if let model = product.model {
                            ScanDetailRow(label: "Model", value: model, icon: "cube.fill")
                        }
                        if let category = product.category {
                            ScanDetailRow(label: "Category", value: category, icon: "folder.fill")
                        }
                        if let value = product.estimatedValue {
                            ScanDetailRow(label: "Est. Value", value: "$\(value)", icon: "dollarsign.circle.fill")
                        }
                    }
                }
                .foregroundColor(.green)
            } else if !result.isSerialNumber {
                // Show that we're looking up product info
                GroupBox("Product Lookup") {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Looking up product information...")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Spacer()
                    }
                }
            }

            // Action buttons
            HStack(spacing: 12) {
                Button(action: onApply) {
                    Label("Apply to Item", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: onRescan) {
                    Label("Scan Again", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// Supporting view for detail rows
struct ScanDetailRow: View {
    let label: String
    let value: String
    let icon: String?

    init(label: String, value: String, icon: String? = nil) {
        self.label = label
        self.value = value
        self.icon = icon
    }

    var body: some View {
        HStack {
            if let icon {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .frame(width: 16)
            }
            Text("\(label):")
                .foregroundColor(.secondary)
            Text(value)
                .fontWeight(.medium)
            Spacer()
        }
    }
}

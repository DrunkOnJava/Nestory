//
// Layer: App
// Module: ReceiptsSection
// Purpose: Receipt management section for ItemDetailView
//

import SwiftData
import SwiftUI

struct ReceiptsSection: View {
    let item: Item
    @Binding var showingReceiptCapture: Bool

    @State private var showingReceiptDetail = false
    @State private var selectedReceipt: Receipt?

    var body: some View {
        GroupBox("Receipt Documentation") {
            VStack(spacing: 12) {
                if !(item.receipts?.isEmpty ?? true) {
                    // Show receipts list
                    VStack(spacing: 8) {
                        ForEach((item.receipts ?? []).sorted(by: { $0.purchaseDate > $1.purchaseDate })) { receipt in
                            ReceiptRow(receipt: receipt) {
                                selectedReceipt = receipt
                                showingReceiptDetail = true
                            }
                        }

                        // Add another receipt button
                        Button("Add Another Receipt") {
                            showingReceiptCapture = true
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                } else if let receiptData = item.receiptImageData,
                          let uiImage = UIImage(data: receiptData)
                {
                    // Legacy receipt support
                    HStack {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                        VStack(alignment: .leading) {
                            Text("Legacy Receipt")
                                .font(.headline)
                            if item.extractedReceiptText != nil {
                                Text("OCR data available")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Button("View/Convert") {
                            showingReceiptCapture = true
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    // No receipts
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("No Receipts Attached")
                                .foregroundColor(.secondary)
                            Text("Add receipts for insurance documentation")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: { showingReceiptCapture = true }) {
                            Label("Add Receipt", systemImage: "doc.text.viewfinder")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .sheet(isPresented: $showingReceiptDetail) {
            if let receipt = selectedReceipt {
                ReceiptDetailView(receipt: receipt)
            }
        }
    }
}

struct ReceiptRow: View {
    let receipt: Receipt
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Receipt thumbnail
                if let imageData = receipt.imageData,
                   let uiImage = UIImage(data: imageData)
                {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "receipt")
                                .foregroundColor(.gray)
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(receipt.vendor)
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack {
                        if let total = receipt.totalMoney {
                            Text(formatCurrency(total))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }

                        Spacer()

                        Text(receipt.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Confidence indicator
                    if receipt.confidence > 0 {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(confidenceColor)
                                .frame(width: 8, height: 8)
                            Text(receipt.confidenceLevel)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    private var confidenceColor: Color {
        switch receipt.confidence {
        case 0.9 ... 1.0: .green
        case 0.7 ..< 0.9: .blue
        case 0.5 ..< 0.7: .orange
        case 0.0 ..< 0.5: .red
        default: .gray
        }
    }

    private func formatCurrency(_ money: Money) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = money.currencyCode
        return formatter.string(from: NSDecimalNumber(decimal: money.amount)) ?? "$0.00"
    }
}

struct ReceiptsSection_Previews: PreviewProvider {
    static var previews: some View {
        let item = Item(name: "Sample Item")

        let money1 = Money(amount: 25.99, currencyCode: "USD")
        let receipt1 = Receipt(vendor: "Target", total: money1, purchaseDate: Date())
        receipt1.setOCRResults(text: "Sample", confidence: 0.85, categories: ["Grocery"])

        let money2 = Money(amount: 149.99, currencyCode: "USD")
        let receipt2 = Receipt(vendor: "Best Buy", total: money2, purchaseDate: Date().addingTimeInterval(-86400))
        receipt2.setOCRResults(text: "Sample", confidence: 0.92, categories: ["Electronics"])

        item.receipts = [receipt1, receipt2]

        ReceiptsSection(item: item, showingReceiptCapture: .constant(false))
            .padding()
    }
}

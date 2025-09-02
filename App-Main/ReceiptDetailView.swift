//
// Layer: App
// Module: ReceiptDetailView
// Purpose: Display detailed receipt information and management
//

import SwiftData
import SwiftUI

struct ReceiptDetailView: View {
    let receipt: Receipt
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showingEditMode = false
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Receipt Image
                    if let imageData = receipt.imageData,
                       let uiImage = UIImage(data: imageData)
                    {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Receipt Image")
                                .font(.headline)

                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 400)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }

                    // Receipt Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Receipt Details")
                            .font(.headline)

                        VStack(spacing: 12) {
                            DetailRow(label: "Vendor", value: receipt.vendor)

                            if let total = receipt.totalMoney {
                                DetailRow(label: "Total", value: formatCurrency(total))
                            }

                            if let tax = receipt.taxMoney {
                                DetailRow(label: "Tax", value: formatCurrency(tax))
                            }

                            DetailRow(label: "Date", value: formatDate(receipt.purchaseDate))

                            if let receiptNumber = receipt.receiptNumber {
                                DetailRow(label: "Receipt #", value: receiptNumber)
                            }

                            if let paymentMethod = receipt.paymentMethod {
                                DetailRow(label: "Payment", value: paymentMethod)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)

                    // OCR Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("OCR Analysis")
                            .font(.headline)

                        VStack(spacing: 12) {
                            HStack {
                                Text("Confidence:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(receipt.confidenceLevel)
                                    .fontWeight(.medium)
                                    .foregroundColor(confidenceColor)
                            }

                            if !receipt.categories.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Detected Categories:")
                                        .foregroundColor(.secondary)

                                    LazyVGrid(columns: [
                                        GridItem(.adaptive(minimum: 100)),
                                    ], spacing: 8) {
                                        ForEach(receipt.categories, id: \.self) { category in
                                            Text(category)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue.opacity(0.1))
                                                .foregroundColor(.blue)
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                            }

                            if receipt.hasOCRData {
                                HStack {
                                    Text("Processing Status:")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Label("Processed", systemImage: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)

                    // Raw OCR Text (Expandable)
                    if let rawText = receipt.rawText, !rawText.isEmpty {
                        DisclosureGroup("Raw OCR Text") {
                            Text(rawText)
                                .font(.caption)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(8)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }

                    // Actions
                    VStack(spacing: 12) {
                        Button("Edit Receipt") {
                            showingEditMode = true
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)

                        Button("Delete Receipt", role: .destructive) {
                            showingDeleteAlert = true
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Delete Receipt", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteReceipt()
                }
            } message: {
                Text("Are you sure you want to delete this receipt? This action cannot be undone.")
            }
        }
    }

    // MARK: - Helper Views

    private func DetailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }

    // MARK: - Computed Properties

    private var confidenceColor: Color {
        switch receipt.confidence {
        case 0.9 ... 1.0: .green
        case 0.7 ..< 0.9: .blue
        case 0.5 ..< 0.7: .orange
        case 0.0 ..< 0.5: .red
        default: .secondary
        }
    }

    // MARK: - Helper Methods

    private func formatCurrency(_ money: Money) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = money.currencyCode
        return formatter.string(from: NSDecimalNumber(decimal: money.amount)) ?? "$0.00"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func deleteReceipt() {
        modelContext.delete(receipt)
        try? modelContext.save()
        dismiss()
    }
}

struct ReceiptDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let money = Money(amount: 25.99, currencyCode: "USD")
        let receipt = Receipt(vendor: "Target", total: money, purchaseDate: Date())
        receipt.setOCRResults(text: "Sample receipt text", confidence: 0.85, categories: ["Grocery", "Electronics"])

        return ReceiptDetailView(receipt: receipt)
    }
}

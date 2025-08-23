//
// Layer: App
// Module: EnhancedReceiptDataView
// Purpose: Display enhanced receipt data from ML processing
//

import SwiftUI

struct EnhancedReceiptDataView: View {
    let data: EnhancedReceiptData
    @State private var showingRawText = false
    @State private var showingItems = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with confidence
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI-Enhanced Analysis")
                        .font(.headline)

                    HStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)

                        Text("Machine Learning Enhanced")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                Spacer()

                ConfidenceIndicatorView(confidence: data.confidence)
            }

            // Core Receipt Information
            VStack(spacing: 12) {
                if let vendor = data.vendor {
                    ReceiptDataRow(
                        icon: "storefront.fill",
                        label: "Vendor",
                        value: vendor,
                        color: .blue
                    )
                }

                if let total = data.total {
                    ReceiptDataRow(
                        icon: "dollarsign.circle.fill",
                        label: "Total",
                        value: "$\(total)",
                        color: .green
                    )
                }

                if let tax = data.tax {
                    ReceiptDataRow(
                        icon: "percent",
                        label: "Tax",
                        value: "$\(tax)",
                        color: .orange
                    )
                }

                if let date = data.date {
                    ReceiptDataRow(
                        icon: "calendar",
                        label: "Date",
                        value: formatDate(date),
                        color: .purple
                    )
                }
            }

            // Categories Section
            if !data.categories.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Auto-Detected Categories", systemImage: "tag.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 100)),
                    ], spacing: 8) {
                        ForEach(data.categories, id: \.self) { category in
                            CategoryTag(category: category)
                        }
                    }
                }
                .padding(.top, 4)
            }

            // Processing Details
            ProcessingMetadataView(metadata: data.processingMetadata)

            // Expandable Sections
            VStack(spacing: 8) {
                // Items Section
                if !data.items.isEmpty {
                    DisclosureGroup("Detected Items (\(data.items.count))", isExpanded: $showingItems) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(data.items.enumerated()), id: \.offset) { index, item in
                                ReceiptItemRowView(item: item, index: index + 1)
                            }
                        }
                        .padding(.top, 8)
                    }
                }

                // Raw Text Section
                DisclosureGroup("Raw OCR Text", isExpanded: $showingRawText) {
                    ScrollView {
                        Text(data.rawText)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(8)
                    }
                    .frame(maxHeight: 200)
                    .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct ConfidenceIndicatorView: View {
    let confidence: Double
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "gauge.badge.minus")
                .foregroundColor(confidenceColor)
                .font(.caption)
            
            Text("\(Int(confidence * 100))%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(confidenceColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(confidenceColor.opacity(0.1))
        .cornerRadius(6)
    }
    
    private var confidenceColor: Color {
        switch confidence {
        case 0.8...:
            return .green
        case 0.6..<0.8:
            return .orange
        default:
            return .red
        }
    }
}

struct ReceiptDataRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()
        }
    }
}

struct CategoryTag: View {
    let category: String

    var body: some View {
        Text(category)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(6)
    }
}

struct ProcessingMetadataView: View {
    let metadata: ReceiptProcessingMetadata

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Processing Details")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                if metadata.mlClassifierUsed {
                    ProcessingBadge(
                        icon: "brain.head.profile",
                        label: "ML Enhanced",
                        color: .blue
                    )
                }

                if metadata.documentCorrectionApplied {
                    ProcessingBadge(
                        icon: "perspective",
                        label: "Corrected",
                        color: .green
                    )
                }

                let matchedCount = metadata.patternsMatched.values.count(where: { $0 })
                if matchedCount > 0 {
                    ProcessingBadge(
                        icon: "checkmark.circle",
                        label: "\(matchedCount) Patterns",
                        color: .orange
                    )
                }
            }
        }
    }
}

struct ProcessingBadge: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(label)
                .font(.caption2)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(4)
    }
}

struct ReceiptItemRowView: View {
    let item: ReceiptItem
    let index: Int

    var body: some View {
        HStack {
            Text("\(index).")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .leading)

            Text(item.name)
                .font(.caption)
                .lineLimit(1)

            Spacer()

            if item.quantity > 1 {
                Text("\(item.quantity)x")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text("$\(item.price)")
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Preview

struct EnhancedReceiptDataView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = EnhancedReceiptData(
            vendor: "Target",
            total: Decimal(45.99),
            tax: Decimal(3.68),
            date: Date(),
            items: [
                ReceiptItem(name: "Milk", price: Decimal(3.99), quantity: 1),
                ReceiptItem(name: "Bread", price: Decimal(2.49), quantity: 2),
                ReceiptItem(name: "Eggs", price: Decimal(4.99), quantity: 1),
            ],
            categories: ["Grocery", "Food"],
            confidence: 0.87,
            rawText: "TARGET\n123 Main St\nMilk $3.99\nBread $2.49 x2\nEggs $4.99\nSubtotal: $42.31\nTax: $3.68\nTotal: $45.99",
            boundingBoxes: [],
            processingMetadata: ReceiptProcessingMetadata(
                documentCorrectionApplied: true,
                patternsMatched: ["vendor": true, "total": true, "date": true],
                mlClassifierUsed: true
            )
        )

        EnhancedReceiptDataView(data: sampleData)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}


// MARK: - Preview

#Preview {
    EnhancedReceiptDataView(
        data: EnhancedReceiptData(
            vendor: "Apple Store",
            total: Decimal(1299.00),
            tax: Decimal(61.00),
            date: Date(),
            items: [
                ReceiptItem(name: "MacBook Air", price: Decimal(1199.00), quantity: 1),
                ReceiptItem(name: "USB-C Cable", price: Decimal(39.00), quantity: 1),
                ReceiptItem(name: "Tax", price: Decimal(61.00), quantity: 1)
            ],
            categories: ["Electronics", "Apple"],
            confidence: 0.89,
            rawText: "APPLE STORE\n123 Apple Street\nMacBook Air    $1199.00\nUSB-C Cable    $39.00\nTax            $61.00\nTOTAL         $1299.00",
            boundingBoxes: [],
            processingMetadata: ReceiptProcessingMetadata(
                documentCorrectionApplied: true,
                patternsMatched: ["vendor": true, "total": true, "date": true],
                mlClassifierUsed: true
            )
        )
    )
    .padding()
}

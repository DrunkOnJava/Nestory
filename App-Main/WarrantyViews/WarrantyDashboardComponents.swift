//
// Layer: App-Main
// Module: WarrantyViews
// Purpose: Supporting components for warranty dashboard
//

import Charts
import SwiftUI

// MARK: - Supporting Views

struct WarrantySummaryCardsView: View {
    let insights: WarrantyInsights

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 12) {
            SummaryCard(
                title: "Total Items",
                value: "\(insights.totalItems)",
                subtitle: "\(insights.itemsWithWarranty) protected",
                icon: "shippingbox.fill",
                color: .blue
            )

            SummaryCard(
                title: "Coverage",
                value: String(format: "%.1f%%", NSDecimalNumber(decimal: insights.coveragePercentage).doubleValue),
                subtitle: "Value protected",
                icon: "shield.fill",
                color: .green
            )

            SummaryCard(
                title: "Expiring Soon",
                value: "\(insights.expiringSoon)",
                subtitle: "Next 30 days",
                icon: "exclamationmark.shield",
                color: .orange
            )

            SummaryCard(
                title: "Need Attention",
                value: "\(insights.expired + insights.withoutWarranty)",
                subtitle: "Expired or missing",
                icon: "exclamationmark.triangle.fill",
                color: .red
            )
        }
    }
}

struct WarrantyAlertCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    let items: [Item]
    let onItemTap: (Item) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.2))
                    .foregroundColor(color)
                    .clipShape(Capsule())
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(items.prefix(10)) { item in
                        WarrantyItemCard(item: item) {
                            onItemTap(item)
                        }
                    }

                    if items.count > 10 {
                        Button("View All") {
                            // Handle view all
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

struct WarrantyActionCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    let items: [Item]
    let onItemTap: (Item) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.2))
                    .foregroundColor(color)
                    .clipShape(Capsule())
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(items.prefix(5)) { item in
                        WarrantyItemCard(item: item) {
                            onItemTap(item)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

struct WarrantyItemCard: View {
    let item: Item
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 60)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray4))
                        .frame(width: 80, height: 60)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        }
                }

                Text(item.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(width: 80, alignment: .leading)

                if let expirationDate = item.warrantyExpirationDate {
                    let status = WarrantyStatusCalculator.calculate(expirationDate: expirationDate)
                    Text(status?.text ?? "Unknown")
                        .font(.caption2)
                        .foregroundColor(status?.color ?? .secondary)
                        .lineLimit(1)
                        .frame(width: 80, alignment: .leading)
                } else {
                    Text("No warranty")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 80, alignment: .leading)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct CategoryCoverageRow: View {
    let coverage: CategoryCoverage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(coverage.category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: "%.1f%%", NSDecimalNumber(decimal: coverage.coveragePercentage).doubleValue))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(coverageColor(coverage.coveragePercentage))
            }

            HStack(spacing: 8) {
                Text("\(coverage.itemsWithWarranty)/\(coverage.totalItems) items")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if coverage.totalValue > 0 {
                    Text("$\(NSDecimalNumber(decimal: coverage.protectedValue).intValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)

                    Rectangle()
                        .fill(coverageColor(coverage.coveragePercentage))
                        .frame(
                            width: geometry.size.width * max(0, min(1, NSDecimalNumber(decimal: coverage.coveragePercentage / 100).doubleValue)),
                            height: 4
                        )
                }
            }
            .frame(height: 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func coverageColor(_ percentage: Decimal) -> Color {
        let value = NSDecimalNumber(decimal: percentage).doubleValue
        if value >= 80 { return .green }
        if value >= 60 { return .orange }
        return .red
    }
}

struct WarrantyBulkAddView: View {
    let items: [Item]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("Bulk Add Warranty - Coming Soon")
                .navigationTitle("Add Warranties")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

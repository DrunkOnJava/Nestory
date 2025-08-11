//
// Layer: App-Main
// Module: AnalyticsViews
// Purpose: Display summary metric cards for analytics dashboard
//

import SwiftUI

struct SummaryCardsView: View {
    let totalItems: Int
    let totalValue: Decimal
    let categoriesCount: Int
    let averageValue: Decimal

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            SummaryCard(
                title: "Total Items",
                value: "\(totalItems)",
                icon: "shippingbox.fill",
                color: .blue,
            )

            SummaryCard(
                title: "Total Value",
                value: formatCurrency(totalValue),
                icon: "dollarsign.circle.fill",
                color: .green,
            )

            SummaryCard(
                title: "Categories",
                value: "\(categoriesCount)",
                icon: "square.grid.2x2.fill",
                color: .purple,
            )

            SummaryCard(
                title: "Avg. Value",
                value: formatCurrency(averageValue),
                icon: "chart.line.uptrend.xyaxis",
                color: .orange,
            )
        }
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSNumber) ?? "$0"
    }
}

// MARK: - Summary Card Component

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

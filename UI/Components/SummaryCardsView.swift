//
// Layer: UI
// Module: Components
// Purpose: Reusable summary metric cards for analytics displays
//
// 🎨 UI COMPONENT: Pure presentational component
// - Displays key metrics in a consistent card grid layout
// - No business logic - purely presentational
// - Reusable across Analytics, Dashboard, and Reports features
// - Foundation-only imports for maximum reusability

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
        // Use system currency formatting for better localization
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSNumber) ?? "$0"
    }
}

// MARK: - Summary Card Component

struct SummaryCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let color: Color

    init(title: String, value: String, subtitle: String? = nil, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
    }

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

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.tertiary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

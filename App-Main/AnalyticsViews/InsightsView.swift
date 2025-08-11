//
// Layer: App-Main
// Module: AnalyticsViews
// Purpose: Display actionable insights from analytics data
//

import SwiftUI

struct InsightsView: View {
    let dataProvider: AnalyticsDataProvider
    @State private var showingInsights = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Insights")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button(action: { showingInsights.toggle() }) {
                    Image(systemName: showingInsights ? "chevron.up" : "chevron.down")
                }
            }

            if showingInsights {
                VStack(alignment: .leading, spacing: 12) {
                    InsightRow(
                        icon: "doc.text.fill",
                        text: "\(dataProvider.itemsNeedingDocumentation.count) items need documentation",
                        color: .orange,
                    )

                    if let mostValuableCategory = dataProvider.mostValuableCategory {
                        InsightRow(
                            icon: "crown.fill",
                            text: "\(mostValuableCategory.name) is your most valuable category",
                            color: .yellow,
                        )
                    }

                    InsightRow(
                        icon: "chart.line.uptrend.xyaxis",
                        text: "You've added \(dataProvider.recentlyAddedCount) items this month",
                        color: .green,
                    )

                    if dataProvider.uncategorizedCount > 0 {
                        InsightRow(
                            icon: "questionmark.folder.fill",
                            text: "\(dataProvider.uncategorizedCount) items need categorization",
                            color: .red,
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Insight Row

struct InsightRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

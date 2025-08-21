//
// Layer: App-Main
// Module: AnalyticsViews
// Purpose: Enhanced analytics summary using sophisticated AnalyticsService
//

import SwiftUI

struct EnhancedAnalyticsSummaryView: View {
    let dashboardData: DashboardData

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Enhanced Analytics")
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                Text("Updated: \(dashboardData.lastUpdated, style: .time)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 16) {
                // Total Depreciation
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Depreciation")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(dashboardData.totalDepreciation)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }

                Spacer()

                // Top Category
                if let topCategory = dashboardData.categoryBreakdown.first {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Top Category")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(topCategory.categoryName)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    let sampleData = DashboardData(
        totalItems: 15,
        totalValue: 8500,
        categoryBreakdown: [
            CategoryBreakdown(categoryName: "Electronics", itemCount: 10, totalValue: 5000, percentage: 45.5),
        ],
        topValueItemIds: [],
        recentItemIds: [],
        valueTrends: [],
        totalDepreciation: 500,
        lastUpdated: Date()
    )

    EnhancedAnalyticsSummaryView(dashboardData: sampleData)
        .padding()
}

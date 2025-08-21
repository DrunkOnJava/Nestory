//
// Layer: App-Main
// Module: AnalyticsViews
// Purpose: Enhanced insights view using AnalyticsService data
//

import SwiftUI
import Foundation

struct EnhancedInsightsView: View {
    let dashboardData: DashboardData?
    let depreciationReports: [DepreciationReport]
    @State private var showingInsights = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Enhanced Insights")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button(action: { showingInsights.toggle() }) {
                    Image(systemName: showingInsights ? "chevron.up" : "chevron.down")
                }
            }

            if showingInsights {
                VStack(alignment: .leading, spacing: 12) {
                    if let data = dashboardData {
                        // Total value insight
                        InsightRow(
                            icon: "dollarsign.circle.fill",
                            text: "Total portfolio value: $\(data.totalValue)",
                            color: .green
                        )

                        // Category distribution insight
                        if let topCategory = data.categoryBreakdown.first {
                            InsightRow(
                                icon: "crown.fill",
                                text: "\(topCategory.categoryName) accounts for \(Int(topCategory.percentage))% of your value",
                                color: .yellow
                            )
                        }

                        // Recent activity insight
                        let recentCount = data.recentItemIds.count
                        if recentCount > 0 {
                            InsightRow(
                                icon: "clock.fill",
                                text: "\(recentCount) recently added items",
                                color: .blue
                            )
                        }

                        // Depreciation insights
                        if !depreciationReports.isEmpty {
                            let totalDepreciation = data.totalDepreciation
                            if totalDepreciation > 0 {
                                InsightRow(
                                    icon: "chart.line.downtrend.xyaxis",
                                    text: "Total depreciation: $\(totalDepreciation)",
                                    color: .red
                                )
                            }

                            // Most depreciated item insight
                            if let mostDepreciated = depreciationReports.first {
                                InsightRow(
                                    icon: "exclamationmark.triangle.fill",
                                    text: "\(mostDepreciated.itemName) has depreciated by $\(mostDepreciated.totalDepreciation)",
                                    color: .orange
                                )
                            }
                        }

                        // Value trend insight
                        if let latestTrend = data.valueTrends.last,
                           let previousTrend = data.valueTrends.dropLast().last
                        {
                            let trendDirection = latestTrend.value > previousTrend.value
                            InsightRow(
                                icon: trendDirection ? "arrow.up.right" : "arrow.down.right",
                                text: "Portfolio value is \(trendDirection ? "increasing" : "decreasing")",
                                color: trendDirection ? .green : .red
                            )
                        }

                    } else {
                        InsightRow(
                            icon: "info.circle.fill",
                            text: "Loading analytics data...",
                            color: .gray
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    EnhancedInsightsView(
        dashboardData: nil,
        depreciationReports: []
    )
    .padding()
}

//
// Layer: App-Main
// Module: WarrantyViews
// Purpose: Chart components for warranty dashboard
//

import Charts
import SwiftUI

// MARK: - Chart Views

struct WarrantyTimelineChart: View {
    let items: [Item]

    var body: some View {
        Chart {
            ForEach(items.prefix(20), id: \.id) { item in
                if let expirationDate = item.warrantyExpirationDate {
                    BarMark(
                        x: .value("Days", Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0),
                        y: .value("Item", item.name)
                    )
                    .foregroundStyle(colorForDaysRemaining(Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0))
                }
            }
        }
        .frame(height: 200)
        .chartXAxis {
            AxisMarks(values: [0, 7, 14, 30]) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let days = value.as(Int.self) {
                        Text("\(days)d")
                    }
                }
            }
        }
    }

    private func colorForDaysRemaining(_ days: Int) -> Color {
        if days < 0 { return .red }
        if days <= 7 { return .orange }
        if days <= 30 { return .yellow }
        return .green
    }
}

struct ValueProtectionChart: View {
    let insights: WarrantyInsights

    var body: some View {
        Chart {
            SectorMark(
                angle: .value("Protected", insights.protectedValue),
                innerRadius: .ratio(0.5),
                angularInset: 1.5
            )
            .foregroundStyle(.green)
            .cornerRadius(4)

            SectorMark(
                angle: .value("Unprotected", insights.totalValue - insights.protectedValue),
                innerRadius: .ratio(0.5),
                angularInset: 1.5
            )
            .foregroundStyle(.red.opacity(0.3))
            .cornerRadius(4)
        }
        .frame(height: 200)
        .chartLegend(position: .bottom, alignment: .center) {
            HStack {
                Label("Protected: $\(NSDecimalNumber(decimal: insights.protectedValue).intValue)", systemImage: "circle.fill")
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(.green)

                Spacer()

                Label("Unprotected: $\(NSDecimalNumber(decimal: insights.totalValue - insights.protectedValue).intValue)", systemImage: "circle.fill")
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(.red.opacity(0.3))
            }
            .font(.caption)
        }
    }
}

struct CategoryCoverageChart: View {
    let coverage: [CategoryCoverage]

    var body: some View {
        Chart {
            ForEach(coverage.prefix(8).indices, id: \.self) { index in
                let item = coverage[index]
                BarMark(
                    x: .value("Coverage", item.coveragePercentage),
                    y: .value("Category", item.category.name)
                )
                .foregroundStyle(colorForCoverage(item.coveragePercentage))
            }
        }
        .frame(height: 200)
        .chartXAxis {
            AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let percentage = value.as(Decimal.self) {
                        Text("\(NSDecimalNumber(decimal: percentage).intValue)%")
                    }
                }
            }
        }
    }

    private func colorForCoverage(_ percentage: Decimal) -> Color {
        let value = NSDecimalNumber(decimal: percentage).doubleValue
        if value >= 80 { return .green }
        if value >= 60 { return .orange }
        return .red
    }
}

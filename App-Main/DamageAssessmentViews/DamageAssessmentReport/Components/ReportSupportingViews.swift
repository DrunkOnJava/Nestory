//
// Layer: App-Main
// Module: DamageAssessment/DamageAssessmentReport/Components
// Purpose: Supporting view components for damage assessment reports
//

import SwiftUI

// MARK: - Summary Row Component
// SummaryRow is defined in App-Main/InsuranceClaim/Components/SummaryRow.swift

// MARK: - Status Indicator Component

struct StatusIndicator: View {
    let title: String
    let isComplete: Bool
    var count: Int? = nil
    var detail: String? = nil

    var body: some View {
        HStack {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isComplete ? .green : .secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)

                if let count {
                    Text("\(count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if let detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Report Feature Component

struct ReportFeature: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.indigo)

            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Report Header Component
// ReportHeaderView is available from DamageAssessmentReport/Sections/ReportHeaderView.swift
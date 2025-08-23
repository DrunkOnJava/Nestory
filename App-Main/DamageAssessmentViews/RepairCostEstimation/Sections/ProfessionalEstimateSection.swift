//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Sections
// Purpose: Professional estimate recommendation section component for repair cost estimation
//

import SwiftUI

public struct ProfessionalEstimateSection: View {
    let shouldRecommend: Bool
    let reason: String

    public init(shouldRecommend: Bool, reason: String) {
        self.shouldRecommend = shouldRecommend
        self.reason = reason
    }

    public var body: some View {
        if shouldRecommend {
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "person.badge.shield.checkmark")
                            .foregroundColor(.orange)

                        Text("Professional Estimate Recommended")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }

                    Text(reason)
                        .font(.body)
                        .foregroundColor(.secondary)

                    Text("Consider getting quotes from licensed contractors for more accurate estimates.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
    }
}
//
// Layer: App-Main
// Module: DamageAssessment/DamageAssessmentReport/Sections
// Purpose: Report features and capabilities overview display
//

import SwiftUI

struct ReportFeaturesSection: View {
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Report Features", systemImage: "star.fill")
                    .font(.headline)
                    .foregroundColor(.indigo)

                Text("Your damage assessment report includes:")
                    .font(.body)
                    .foregroundColor(.secondary)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ReportFeature(
                        icon: "photo.on.rectangle.angled",
                        title: "Photo Documentation",
                        description: "Before/after images with annotations"
                    )

                    ReportFeature(
                        icon: "chart.bar.fill",
                        title: "Cost Analysis",
                        description: "Detailed repair and replacement estimates"
                    )

                    ReportFeature(
                        icon: "list.bullet.clipboard",
                        title: "Item Inventory",
                        description: "Complete list of affected items"
                    )

                    ReportFeature(
                        icon: "shield.checkered",
                        title: "Insurance Ready",
                        description: "Formatted for insurance claims"
                    )

                    ReportFeature(
                        icon: "person.badge.shield.checkmark",
                        title: "Professional Grade",
                        description: "Meets industry standards"
                    )

                    ReportFeature(
                        icon: "signature",
                        title: "Digital Signature",
                        description: "Authenticated assessment"
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}
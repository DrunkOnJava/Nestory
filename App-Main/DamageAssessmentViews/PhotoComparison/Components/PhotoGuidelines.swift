//
// Layer: App-Main
// Module: DamageAssessment/PhotoComparison/Components
// Purpose: Guidelines and tips for photo documentation
//

import SwiftUI

public struct PhotoGuidelines: View {
    public init() {}
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label("Photo Guidelines", systemImage: "info.circle")
                    .font(.headline)
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 8) {
                    GuidelineRow(
                        icon: "photo",
                        title: "Before Photos",
                        description: "Show the item's condition prior to damage if available"
                    )

                    GuidelineRow(
                        icon: "photo.fill",
                        title: "After Photos",
                        description: "Document current damaged condition from multiple angles"
                    )

                    GuidelineRow(
                        icon: "magnifyingglass.circle",
                        title: "Detail Photos",
                        description: "Close-up shots highlighting specific damage areas"
                    )
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Tips for Better Documentation:")
                        .font(.caption)
                        .fontWeight(.semibold)

                    Text("• Use good lighting and avoid shadows")
                        .font(.caption2)
                    Text("• Include reference objects for scale")
                        .font(.caption2)
                    Text("• Take photos from multiple angles")
                        .font(.caption2)
                    Text("• Focus clearly on damage areas")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

public struct GuidelineRow: View {
    public let icon: String
    public let title: String
    public let description: String
    
    public init(icon: String, title: String, description: String) {
        self.icon = icon
        self.title = title
        self.description = description
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    PhotoGuidelines()
}
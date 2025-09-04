//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/Extension
// Purpose: Selected extension details display card with benefits
//

import SwiftUI

public struct SelectedExtensionCard: View {
    public let warrantyExtension: WarrantyExtension
    
    public init(extension: WarrantyExtension) {
        self.warrantyExtension = `extension`
    }
    
    public var body: some View {
        GroupBox("Selected Extension") {
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Duration", value: warrantyExtension.displayDuration)
                InfoRow(label: "Cost", value: warrantyExtension.displayPrice)
                InfoRow(label: "Coverage", value: warrantyExtension.coverageType)
                
                if !warrantyExtension.benefits.isEmpty {
                    BenefitsSection(benefits: warrantyExtension.benefits)
                }
            }
        }
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}

private struct BenefitsSection: View {
    let benefits: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Benefits:")
                .font(.caption)
                .fontWeight(.medium)
            
            ForEach(benefits, id: \.self) { benefit in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text(benefit)
                        .font(.caption)
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    SelectedExtensionCard(
        extension: WarrantyExtension(
            duration: 24,
            price: 179.99,
            coverageType: "Premium Extended",
            benefits: [
                "Full replacement coverage",
                "24/7 support",
                "Free shipping",
                "Accident protection"
            ]
        )
    )
    .padding()
}
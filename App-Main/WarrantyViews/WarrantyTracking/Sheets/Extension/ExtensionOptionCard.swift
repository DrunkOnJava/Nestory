//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/Extension
// Purpose: Individual extension option card with selection state
//

import SwiftUI

public struct ExtensionOptionCard: View {
    public let warrantyExtension: WarrantyExtension
    public let isSelected: Bool
    public let onSelect: @Sendable () -> Void
    
    public init(
        extension: WarrantyExtension,
        isSelected: Bool,
        onSelect: @escaping @Sendable () -> Void
    ) {
        self.warrantyExtension = `extension`
        self.isSelected = isSelected
        self.onSelect = onSelect
    }
    
    public var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(warrantyExtension.displayDuration)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(warrantyExtension.coverageType)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(warrantyExtension.displayPrice)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 8) {
        ExtensionOptionCard(
            extension: WarrantyExtension(
                duration: 12,
                price: 99.99,
                coverageType: "Standard Extended",
                benefits: ["Extended repair coverage", "Priority support"]
            ),
            isSelected: true,
            onSelect: {}
        )
        
        ExtensionOptionCard(
            extension: WarrantyExtension(
                duration: 24,
                price: 179.99,
                coverageType: "Premium Extended",
                benefits: ["Full replacement coverage", "24/7 support"]
            ),
            isSelected: false,
            onSelect: {}
        )
    }
    .padding()
}
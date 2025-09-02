//
// Layer: App-Main
// Module: ClaimPackageAssembly/Components
// Purpose: Reusable item row component for claim package assembly with concurrency safety
//

import SwiftUI

public struct ClaimItemRow: View {
    public let item: Item
    public let isSelected: Bool
    public let onToggle: @Sendable () -> Void
    
    public init(
        item: Item,
        isSelected: Bool,
        onToggle: @escaping @Sendable () -> Void
    ) {
        self.item = item
        self.isSelected = isSelected
        self.onToggle = onToggle
    }
    
    public var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                
                HStack {
                    if let category = item.category {
                        Text(category.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let price = item.purchasePrice {
                        Text(price, format: .currency(code: "USD"))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
}

#Preview {
    @Previewable @State var sampleItem: Item = {
        let item = Item(name: "MacBook Pro", itemDescription: "Laptop", quantity: 1)
        item.purchasePrice = 2500.00
        return item
    }()
    
    List {
        ClaimItemRow(item: sampleItem, isSelected: true, onToggle: {})
        ClaimItemRow(item: sampleItem, isSelected: false, onToggle: {})
    }
}
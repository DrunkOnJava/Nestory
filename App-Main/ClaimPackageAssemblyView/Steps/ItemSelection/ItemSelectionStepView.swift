//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/ItemSelection
// Purpose: Item selection step with bulk operations and concurrency safety
//

import SwiftUI

public struct ItemSelectionStepView: View {
    public let allItems: [Item]
    public let selectedItems: Set<UUID>
    public let onToggleItem: @Sendable (UUID) -> Void
    public let onSelectAll: @Sendable () -> Void
    public let onClearAll: @Sendable () -> Void
    
    public init(
        allItems: [Item],
        selectedItems: Set<UUID>,
        onToggleItem: @escaping @Sendable (UUID) -> Void,
        onSelectAll: @escaping @Sendable () -> Void,
        onClearAll: @escaping @Sendable () -> Void
    ) {
        self.allItems = allItems
        self.selectedItems = selectedItems
        self.onToggleItem = onToggleItem
        self.onSelectAll = onSelectAll
        self.onClearAll = onClearAll
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Selection controls
            ItemSelectionControls(
                selectedCount: selectedItems.count,
                totalCount: allItems.count,
                onSelectAll: onSelectAll,
                onClearAll: onClearAll
            )
            
            // Items list
            List {
                ForEach(allItems) { item in
                    ClaimItemRow(
                        item: item,
                        isSelected: selectedItems.contains(item.id),
                        onToggle: { onToggleItem(item.id) }
                    )
                }
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    let items = [
        Item(name: "MacBook Pro", itemDescription: "Laptop", quantity: 1),
        Item(name: "iPhone", itemDescription: "Phone", quantity: 1)
    ]
    
    ItemSelectionStepView(
        allItems: items,
        selectedItems: [items[0].id],
        onToggleItem: { _ in },
        onSelectAll: {},
        onClearAll: {}
    )
}
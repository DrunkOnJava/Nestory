//
// Layer: Features
// Module: Inventory/Components
// Purpose: Item header information component for item detail view
//

import SwiftUI

struct ItemDetailHeaderView: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Group {
                Text(item.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if let description = item.itemDescription, !description.isEmpty {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    ItemDetailHeaderView(
        item: Item(
            name: "Sample Item",
            itemDescription: "This is a sample description"
        )
    )
}
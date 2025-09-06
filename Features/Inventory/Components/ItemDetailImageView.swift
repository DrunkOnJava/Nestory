//
// Layer: Features
// Module: Inventory/Components
// Purpose: Item image display component for item detail view
//

import SwiftUI

struct ItemDetailImageView: View {
    let item: Item
    
    var body: some View {
        if let imageData = item.imageData,
           let uiImage = UIImage(data: imageData)
        {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 300)
                .cornerRadius(12)
                .padding(.horizontal)
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 200)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No Image")
                            .foregroundColor(.secondary)
                    }
                )
                .padding(.horizontal)
        }
    }
}

#Preview {
    ItemDetailImageView(item: Item(name: "Sample Item"))
}
//
// Layer: App-Main
// Module: DamageAssessment/PhotoComparison/Components
// Purpose: Individual photo card component with delete functionality
//

import SwiftUI

public struct PhotoCard: View {
    public let imageData: Data
    public let type: PhotoType
    public let description: String
    public let onDelete: @Sendable () -> Void
    
    public init(
        imageData: Data,
        type: PhotoType,
        description: String,
        onDelete: @escaping @Sendable () -> Void
    ) {
        self.imageData = imageData
        self.type = type
        self.description = description
        self.onDelete = onDelete
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topTrailing) {
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 100)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 100)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        )
                }

                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(4)
            }

            if !description.isEmpty {
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

#Preview {
    PhotoCard(
        imageData: Data(),
        type: .before,
        description: "Sample photo description",
        onDelete: {}
    )
    .padding()
}
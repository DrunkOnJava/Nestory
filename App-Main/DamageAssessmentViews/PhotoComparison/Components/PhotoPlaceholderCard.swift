//
// Layer: App-Main
// Module: DamageAssessment/PhotoComparison/Components
// Purpose: Placeholder card for empty photo states
//

import SwiftUI

public struct PhotoPlaceholderCard: View {
    public let type: PhotoType
    
    public init(type: PhotoType) {
        self.type = type
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(.systemGray6))
            .frame(height: 100)
            .overlay(
                VStack {
                    Image(systemName: type.systemImage)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("No \(type.lowercasedTitle) photos")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            )
    }
}

#Preview {
    HStack {
        PhotoPlaceholderCard(type: .before)
        PhotoPlaceholderCard(type: .after)
        PhotoPlaceholderCard(type: .detail)
    }
    .padding()
}
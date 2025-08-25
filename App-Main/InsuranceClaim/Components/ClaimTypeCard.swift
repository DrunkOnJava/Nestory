//
// Layer: App-Main
// Module: InsuranceClaim/Components
// Purpose: Interactive claim type selection card component
//

import SwiftUI

public struct ClaimTypeCard: View {
    public let claimType: ClaimType
    public let isSelected: Bool
    public let action: () -> Void
    
    public init(
        claimType: ClaimType,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.claimType = claimType
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: claimType.icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : .accentColor)

                Text(claimType.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        ClaimTypeCard(
            claimType: .fire,
            isSelected: true,
            action: {}
        )
        
        ClaimTypeCard(
            claimType: .theft,
            isSelected: false,
            action: {}
        )
    }
    .padding()
}
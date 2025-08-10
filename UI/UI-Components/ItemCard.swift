//
// Layer: UI
// Module: Components
// Purpose: Item Card Component
//

import SwiftUI

public struct ItemCard: View {
    let title: String
    let subtitle: String?
    let imageSystemName: String?
    let price: String?
    let badge: String?
    
    public init(
        title: String,
        subtitle: String? = nil,
        imageSystemName: String? = nil,
        price: String? = nil,
        badge: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageSystemName = imageSystemName
        self.price = price
        self.badge = badge
    }
    
    public var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Icon/Image
            if let imageSystemName = imageSystemName {
                Image(systemName: imageSystemName)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.md)
            }
            
            // Content
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack {
                    Text(title)
                        .font(Typography.headline())
                        .foregroundColor(.primaryText)
                        .lineLimit(1)
                    
                    if let badge = badge {
                        BadgeView(text: badge)
                    }
                }
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(Typography.subheadline())
                        .foregroundColor(.secondaryText)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Price
            if let price = price {
                Text(price)
                    .font(Typography.headline())
                    .foregroundColor(.primaryText)
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.tertiaryText)
        }
        .padding(Theme.Spacing.md)
        .background(Color.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.lg)
    }
}

// MARK: - Badge View
public struct BadgeView: View {
    let text: String
    let style: BadgeStyle
    
    public enum BadgeStyle {
        case `default`, success, warning, destructive, info
        
        var backgroundColor: Color {
            switch self {
            case .default: return .gray
            case .success: return .success
            case .warning: return .warning
            case .destructive: return .destructive
            case .info: return .info
            }
        }
    }
    
    public init(text: String, style: BadgeStyle = .default) {
        self.text = text
        self.style = style
    }
    
    public var body: some View {
        Text(text)
            .font(Typography.caption())
            .foregroundColor(.white)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xxs)
            .background(style.backgroundColor)
            .cornerRadius(Theme.CornerRadius.sm)
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.md) {
        ItemCard(
            title: "MacBook Pro",
            subtitle: "Electronics",
            imageSystemName: "laptopcomputer",
            price: "$2,499",
            badge: "New"
        )
        
        ItemCard(
            title: "Office Chair",
            subtitle: "Furniture",
            imageSystemName: "chair",
            price: "$450"
        )
        
        ItemCard(
            title: "Coffee Maker",
            imageSystemName: "cup.and.saucer"
        )
    }
    .padding()
    .background(Color.primaryBackground)
}

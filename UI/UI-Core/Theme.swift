//
// Layer: UI
// Module: Core
// Purpose: Design System Theme
//

import SwiftUI

public enum Theme {
    // MARK: - Spacing
    public enum Spacing {
        public static let xxs: CGFloat = 2
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        public static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    public enum CornerRadius {
        public static let sm: CGFloat = 4
        public static let md: CGFloat = 8
        public static let lg: CGFloat = 12
        public static let xl: CGFloat = 16
        public static let round: CGFloat = 9999
    }
    
    // MARK: - Animation
    public enum Animation {
        public static let fast: Double = 0.2
        public static let normal: Double = 0.3
        public static let slow: Double = 0.5
        public static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
    }
    
    // MARK: - Shadows
    public enum Shadow {
        public static let sm = ShadowStyle(radius: 2, y: 1)
        public static let md = ShadowStyle(radius: 4, y: 2)
        public static let lg = ShadowStyle(radius: 8, y: 4)
        
        public struct ShadowStyle: Sendable {
            let radius: CGFloat
            let y: CGFloat
            
            public func apply(to view: some View) -> some View {
                view.shadow(
                    color: .black.opacity(0.1),
                    radius: radius,
                    x: 0,
                    y: y
                )
            }
        }
    }
}

// MARK: - Semantic Colors
extension Color {
    public static let primaryBackground = Color(.systemBackground)
    public static let secondaryBackground = Color(.secondarySystemBackground)
    public static let tertiaryBackground = Color(.tertiarySystemBackground)
    
    public static let primaryText = Color(.label)
    public static let secondaryText = Color(.secondaryLabel)
    public static let tertiaryText = Color(.tertiaryLabel)
    
    public static let destructive = Color(.systemRed)
    public static let success = Color(.systemGreen)
    public static let warning = Color(.systemOrange)
    public static let info = Color(.systemBlue)
}

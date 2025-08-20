//
// Layer: UI
// Module: Core
// Purpose: Typography System
//

import SwiftUI

public enum Typography {
    // MARK: - Text Styles

    public static func largeTitle() -> Font {
        Font.largeTitle
    }

    public static func title() -> Font {
        Font.title
    }

    public static func title2() -> Font {
        Font.title2
    }

    public static func title3() -> Font {
        Font.title3
    }

    public static func headline() -> Font {
        Font.headline
    }

    public static func body() -> Font {
        Font.body
    }

    public static func callout() -> Font {
        Font.callout
    }

    public static func subheadline() -> Font {
        Font.subheadline
    }

    public static func footnote() -> Font {
        Font.footnote
    }

    public static func caption() -> Font {
        Font.caption
    }

    public static func caption2() -> Font {
        Font.caption2
    }
}

// MARK: - Text Modifiers

public struct BodyStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(Typography.body())
            .foregroundColor(.primaryText)
    }
}

public struct HeadlineStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(Typography.headline())
            .foregroundColor(.primaryText)
    }
}

public struct SubheadlineStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(Typography.subheadline())
            .foregroundColor(.secondaryText)
    }
}

extension View {
    public func bodyStyle() -> some View {
        modifier(BodyStyle())
    }

    public func headlineStyle() -> some View {
        modifier(HeadlineStyle())
    }

    public func subheadlineStyle() -> some View {
        modifier(SubheadlineStyle())
    }
}

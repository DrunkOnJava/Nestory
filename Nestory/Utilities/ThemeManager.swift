//
//  ThemeManager.swift
//  Nestory
//
//  Created by Assistant on 8/9/25.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("darkModeEnabled") var darkModeEnabled: Bool = false
    @AppStorage("useSystemTheme") var useSystemTheme: Bool = true

    static let shared = ThemeManager()

    private init() {}

    var currentColorScheme: ColorScheme? {
        if useSystemTheme {
            return nil
        }
        return darkModeEnabled ? .dark : .light
    }
}

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let accent = Color("AccentColor")

    @Environment(\.colorScheme) private var colorScheme

    var background: Color {
        Color(UIColor.systemBackground)
    }

    var secondaryBackground: Color {
        Color(UIColor.secondarySystemBackground)
    }

    var tertiaryBackground: Color {
        Color(UIColor.tertiarySystemBackground)
    }

    var groupedBackground: Color {
        Color(UIColor.systemGroupedBackground)
    }

    var text: Color {
        Color(UIColor.label)
    }

    var secondaryText: Color {
        Color(UIColor.secondaryLabel)
    }

    var tertiaryText: Color {
        Color(UIColor.tertiaryLabel)
    }

    var separator: Color {
        Color(UIColor.separator)
    }

    var cardBackground: Color {
        Color(UIColor.secondarySystemBackground)
    }

    var itemRowBackground: Color {
        Color(UIColor.secondarySystemBackground)
    }

    var searchBarBackground: Color {
        Color(UIColor.tertiarySystemBackground)
    }
}

struct ThemedCard: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(Color.theme.cardBackground)
            .cornerRadius(12)
            .shadow(color: shadowColor, radius: shadowRadius)
    }

    private var shadowColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.1)
    }

    private var shadowRadius: CGFloat {
        colorScheme == .dark ? 2 : 4
    }
}

extension View {
    func themedCard() -> some View {
        modifier(ThemedCard())
    }
}

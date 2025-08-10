//
//  ThemeManager.swift
//  Nestory
//

import SwiftUI

@MainActor
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

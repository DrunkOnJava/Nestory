//
// Layer: App
// Module: Settings
// Purpose: Appearance settings section for theme and dark mode
//

import SwiftUI

struct AppearanceSettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Section("Appearance") {
            Toggle("Use System Theme", isOn: $themeManager.useSystemTheme)

            if !themeManager.useSystemTheme {
                Toggle("Dark Mode", isOn: $themeManager.darkModeEnabled)
            }

            Picker("App Icon", selection: .constant("Default")) {
                Text("Default").tag("Default")
                Text("Dark").tag("Dark")
                Text("Colorful").tag("Colorful")
            }
        }
    }
}

#Preview {
    Form {
        AppearanceSettingsView()
            .environmentObject(ThemeManager.shared)
    }
}

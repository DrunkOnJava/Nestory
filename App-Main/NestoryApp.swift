//
// Layer: App
// Module: Main
// Purpose: App Entry Point
//

import SwiftData
import SwiftUI

@main
struct NestoryApp: App {
    @StateObject private var themeManager = ThemeManager.shared

    var sharedModelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: Item.self, Category.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(themeManager.currentColorScheme)
                .environmentObject(themeManager)
        }
        .modelContainer(sharedModelContainer)
    }
}

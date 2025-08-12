//
// Layer: App
// Module: Main
// Purpose: App Entry Point
//

import SwiftData
import SwiftUI

// Hot reload is handled via Inject package in ContentView and other views

@main
struct NestoryApp: App {
    @StateObject private var themeManager = ThemeManager.shared

    var sharedModelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: Item.self, Category.self, Room.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        #if DEBUG
            // Bootstrap HotReloading at startup
            HotReloadBootstrap.start()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(themeManager.currentColorScheme)
                .environmentObject(themeManager)
        }
        .modelContainer(sharedModelContainer)
    }
}

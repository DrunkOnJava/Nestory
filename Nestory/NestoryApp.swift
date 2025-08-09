//
//  NestoryApp.swift
//  Nestory
//
//  Created by Griffin on 8/9/25.
//

import SwiftData
import SwiftUI

@main
struct NestoryApp: App {
    @StateObject private var themeManager = ThemeManager.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
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

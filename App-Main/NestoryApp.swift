//
// Layer: App
// Module: Main
// Purpose: App Entry Point
//

import SwiftData
import SwiftUI
import UserNotifications
#if DEBUG
    import Foundation
#endif

@main
struct NestoryApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var notificationService: LiveNotificationService

    var sharedModelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: Item.self, Category.self, Room.self, Warranty.self, Receipt.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // Initialize notification service with model context
        let modelContext = sharedModelContainer.mainContext
        let service = LiveNotificationService(modelContext: modelContext)
        _notificationService = StateObject(wrappedValue: service)

        // Set up notification categories on app launch
        Task {
            await service.setupNotificationCategories()
            await service.checkAuthorizationStatus()
            if service.isAuthorized {
                try? await service.scheduleAllWarrantyNotifications()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(themeManager.currentColorScheme)
                .environmentObject(themeManager)
                .environmentObject(notificationService)
                .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.willEnterForegroundNotification,
                )) { _ in
                    // Refresh notifications when app comes to foreground
                    Task {
                        await notificationService.checkAuthorizationStatus()
                        if notificationService.isAuthorized {
                            try? await notificationService.scheduleAllWarrantyNotifications()
                        }
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

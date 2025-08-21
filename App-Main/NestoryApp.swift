//
// Layer: App
// Module: Main
// Purpose: App Entry Point
//
// 🏗️ TCA ARCHITECTURE NOTES:
// - This is the ROOT of our 6-layer TCA architecture
// - Creates the main TCA Store with RootFeature as the root reducer
// - Integrates legacy @StateObject patterns during migration (will be phased out)
// - ALL new features must be added through TCA Features layer, not directly here
//
// 📱 DEVICE TARGET: iPhone 16 Pro Max (per ProjectConfiguration.json)
// 🎯 APP PURPOSE: Personal home inventory for INSURANCE DOCUMENTATION (not business inventory)
//

import ComposableArchitecture
import SwiftData
import SwiftUI
import UserNotifications

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with AdServices - Implement privacy-respecting ad attribution for app marketing
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with BackgroundAssets - Download insurance form templates and product databases in background
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with OSLog - Integrate app lifecycle logging with unified logging system
#if DEBUG
    import Foundation
#endif

@main
struct NestoryApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var notificationService: LiveNotificationService

    var sharedModelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: Item.self, Category.self, Room.self, Warranty.self, Receipt.self, ClaimSubmission.self, ClaimActivity.self, FollowUpAction.self)
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
            // 🏗️ TCA ROOT STORE: This creates the main TCA store that manages all app state
            // - RootFeature coordinates tab navigation and feature composition
            // - All feature state flows through this central store
            // - Future: Add dependency injection for services here
            RootView(
                store: Store(initialState: RootFeature.State()) {
                    RootFeature()
                }
            )
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

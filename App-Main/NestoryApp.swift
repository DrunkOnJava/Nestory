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
import OSLog

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
            // ✅ CLOUDKIT COMPATIBLE: Models updated for CloudKit compatibility
            // - Removed unique constraints from all model IDs
            // - Made Item.receipts optional relationship
            // - All properties have defaults or are optional
            let schema = Schema([Item.self, Category.self, Warranty.self, Receipt.self])
            
            #if DEBUG
            // Development: Test with local-only first, then enable CloudKit
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none  // Test local-only first
            )
            #else
            // Production: Use CloudKit with private database
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private(Bundle.main.bundleIdentifier ?? "com.nestory.app")
            )
            #endif
            
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            Logger.app.error("Primary storage configuration failed: \(error.localizedDescription)")
            Logger.app.info("Falling back to local-only storage for graceful degradation")
            
            // Fallback to local-only storage for development
            do {
                let schema = Schema([Item.self, Category.self, Warranty.self, Receipt.self])
                let fallbackConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .none  // Local-only fallback
                )
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                Logger.app.error("Local storage fallback failed: \(error.localizedDescription)")
                Logger.app.warning("Using in-memory storage as last resort")
                
                // Last resort: in-memory storage
                do {
                    let schema = Schema([Item.self, Category.self, Warranty.self, Receipt.self])
                    let emergencyConfig = ModelConfiguration(
                        schema: schema,
                        isStoredInMemoryOnly: true,
                        cloudKitDatabase: .none
                    )
                    return try ModelContainer(for: schema, configurations: [emergencyConfig])
                } catch {
                    Logger.app.error("Could not create any ModelContainer: \(error.localizedDescription)")
                    Logger.app.warning("Creating absolute minimal container as last resort")
                    #if DEBUG
                    Logger.app.debug("ModelContainer creation error details: \(error)")
                    #endif
                    // Ultra-minimal container with just Item model
                    let minimalSchema = Schema([Item.self])
                    let ultraMinimalConfig = ModelConfiguration(
                        schema: minimalSchema,
                        isStoredInMemoryOnly: true
                    )
                    // Last resort with proper error handling
                    do {
                        return try ModelContainer(for: minimalSchema, configurations: [ultraMinimalConfig])
                    } catch {
                        // Fatal error is appropriate here as the app cannot function without any storage
                        fatalError("Critical: Unable to create any ModelContainer. Error: \(error)")
                    }
                }
            }
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
            // - Dependency injection will be handled after concurrency issues are resolved
            RootView(
                store: Store(initialState: RootFeature.State()) {
                    RootFeature()
                        ._printChanges()
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

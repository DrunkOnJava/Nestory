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
            // ✅ CLOUDKIT COMPATIBLE: Models updated for CloudKit compatibility
            // - Removed unique constraints from all model IDs
            // - Made Item.receipts optional relationship
            // - All properties have defaults or are optional
            let schema = Schema([Item.self, Category.self, Room.self, Warranty.self, Receipt.self, ClaimSubmission.self])
            
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
            print("❌ Primary storage configuration failed: \(error)")
            print("🔄 Falling back to local-only storage...")
            
            // Fallback to local-only storage for development
            do {
                let schema = Schema([Item.self, Category.self, Room.self, Warranty.self, Receipt.self, ClaimSubmission.self])
                let fallbackConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .none  // Local-only fallback
                )
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                print("❌ Local storage fallback failed: \(error)")
                print("🆘 Using in-memory storage as last resort...")
                
                // Last resort: in-memory storage
                do {
                    let schema = Schema([Item.self, Category.self, Room.self, Warranty.self, Receipt.self, ClaimSubmission.self])
                    let emergencyConfig = ModelConfiguration(
                        schema: schema,
                        isStoredInMemoryOnly: true,
                        cloudKitDatabase: .none
                    )
                    return try ModelContainer(for: schema, configurations: [emergencyConfig])
                } catch {
                    print("🆘 Could not create any ModelContainer: \(error)")
                    print("🔄 Creating absolute minimal container as last resort...")
                    // Ultra-minimal container with just Item model
                    let minimalSchema = Schema([Item.self])
                    let ultraMinimalConfig = ModelConfiguration(
                        schema: minimalSchema,
                        isStoredInMemoryOnly: true
                    )
                    return try! ModelContainer(for: minimalSchema, configurations: [ultraMinimalConfig])
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

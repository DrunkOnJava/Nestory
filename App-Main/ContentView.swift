// Layer: App
// Module: ContentView
// Purpose: Main navigation hub and entry point
//
// 🏗️ LEGACY VIEW: Will be replaced by TCA RootView
// - Currently handles tab-based navigation
// - PLANNED: Will be replaced by RootView.swift with TCA Store
// - Keep functional during TCA migration transition
// - Do NOT add new features here - use RootFeature instead
//
// 🎯 INSURANCE NAVIGATION: Organized for claim preparation workflow
// - Inventory: Core item cataloging and documentation
// - Search: Quick item discovery and documentation status
// - Warranties: Protection tracking and expiration management
// - Analytics: Coverage analysis and portfolio insights
// - Categories: Organization for insurance rider planning
// - Settings: Data export and backup for claim preparation
//
// 📱 TABVIEW ARCHITECTURE: Standard iOS bottom tab navigation
// - 6 primary tabs covering all insurance documentation needs
// - Tab order optimized for most-frequent to least-frequent usage
// - Each tab is independently navigable with NavigationStack
//
// 🔄 TCA MIGRATION STATUS:
// - Part 1: Keep ContentView functional alongside RootView
// - Part 2: All ContentView usage migrated to RootView
// - Part 3: Remove ContentView entirely
//
// 🎨 THEMING: Uses legacy ThemeManager pattern
// - Will be replaced by TCA-managed theme state
// - Environment object injection for color scheme
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        TabView {
            InventoryListView()
                .tabItem {
                    Label("Inventory", systemImage: "shippingbox.fill")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            WarrantyDashboardView()
                .tabItem {
                    Label("Warranties", systemImage: "shield.fill")
                }

            AnalyticsDashboardView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }

            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .preferredColorScheme(themeManager.currentColorScheme)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self, Category.self, Warranty.self], inMemory: true)
}

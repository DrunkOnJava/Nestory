//
//  ContentView.swift
//  Nestory
//
//  REMINDER: This is the main navigation hub - ALL major features should be
//  accessible from here via tabs or navigation. When adding new features,
//  ALWAYS add a way to access them from ContentView or its child views!

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
        .modelContainer(for: Item.self, inMemory: true)
}

//
// Layer: App
// Module: Main
// Purpose: Root View with Tab Navigation
//

import ComposableArchitecture
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import QuartzCore

// Import Features and UI components needed for root navigation
// App layer can import from Features, UI, Services, Infrastructure, Foundation

public struct RootView: View {
    @Bindable var store: StoreOf<RootFeature>
    
    private var isUITestMode: Bool {
        ProcessInfo.processInfo.arguments.contains("UITEST_MODE")
    }

    public var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            tabView(for: .inventory)
                .tabItem {
                    Label("Inventory", systemImage: "archivebox")
                }
                .tag(RootFeature.State.Tab.inventory)
            
            tabView(for: .search)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(RootFeature.State.Tab.search)
            
            tabView(for: .capture)
                .tabItem {
                    Label("Capture", systemImage: "camera")
                }
                .tag(RootFeature.State.Tab.capture)
            
            tabView(for: .analytics)
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
                .tag(RootFeature.State.Tab.analytics)
            
            tabView(for: .settings)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(RootFeature.State.Tab.settings)
        }
        .onAppear {
            handleTestModeConfiguration()
            if !isUITestMode {
                store.send(.onAppear)
            }
        }
        .environment(\.sizeCategory, isUITestMode ? .medium : .large)
    }
    
    private func handleTestModeConfiguration() {
        #if DEBUG
        if isUITestMode {
            #if canImport(UIKit)
            UIView.setAnimationsEnabled(false)
            #endif
            CATransaction.setDisableActions(true)
            
            // Check for start tab argument
            let args = ProcessInfo.processInfo.arguments
            if let start = args.first(where: { $0.hasPrefix("UITEST_START_TAB=") }) {
                let name = String(start.split(separator: "=").last ?? "")
                // Map to tab based on name if needed
                // For now, default handling in RootFeature is sufficient
            }
        }
        #endif
    }
    
    @ViewBuilder
    private func tabView(for tab: RootFeature.State.Tab) -> some View {
        switch tab {
        case .inventory:
            InventoryView(
                store: store.scope(state: \.inventory, action: \.inventory)
            )
            .accessibilityIdentifier("InventoryView")
        case .search:
            SearchView(
                store: store.scope(state: \.search, action: \.search)
            )
            .accessibilityIdentifier("SearchView")
        case .capture:
            CaptureView()
                .accessibilityIdentifier("CaptureView")
        case .analytics:
            AnalyticsDashboardView(
                store: store.scope(state: \.analytics, action: \.analytics)
            )
            .accessibilityIdentifier("AnalyticsView")
        case .settings:
            SettingsView(
                store: store.scope(state: \.settings, action: \.settings)
            )
            .accessibilityIdentifier("SettingsView")
        }
    }
}

// Temporary placeholder view
struct ComingSoonView: View {
    let title: String
    let message: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "clock.badge.checkmark")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)

                Text(message)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(title)
        }
    }
}

#Preview {
    RootView(
        store: Store(initialState: RootFeature.State()) {
            RootFeature()
        },
    )
}

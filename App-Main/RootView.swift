//
// Layer: App
// Module: Main
// Purpose: Root View with Tab Navigation
//

import ComposableArchitecture
import SwiftUI

struct RootView: View {
    @Bindable var store: StoreOf<RootFeature>

    var body: some View {
        TabView(selection: $store.selectedTab) {
            ForEach(RootFeature.State.Tab.allCases, id: \.self) { tab in
                Group {
                    switch tab {
                    case .inventory:
                        InventoryView(
                            store: store.scope(state: \.inventory, action: \.inventory)
                        )

                    case .capture:
                        BarcodeScannerView()

                    case .analytics:
                        AnalyticsDashboardView(
                            store: store.scope(state: \.analytics, action: \.analytics)
                        )

                    case .settings:
                        SettingsView(
                            store: store.scope(state: \.settings, action: \.settings)
                        )
                    }
                }
                .tabItem {
                    Label(tab.rawValue, systemImage: tab.icon)
                }
                .tag(tab)
            }
        }
        .onAppear {
            store.send(.onAppear)
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

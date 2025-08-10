//
// Layer: App
// Module: Main
// Purpose: Root View with Tab Navigation
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    @Bindable var store: StoreOf<RootFeature>
    
    var body: some View {
        TabView(selection: $store.selectedTab) {
            ForEach(RootFeature.State.Tab.allCases, id: \.self) { tab in
                Group {
                    switch tab {
                    case .inventory:
                        ComingSoonView(
                            title: "Inventory",
                            message: "Item management coming soon"
                        )
                        
                    case .capture:
                        ComingSoonView(
                            title: "Capture",
                            message: "OCR and barcode scanning coming soon"
                        )
                        
                    case .analytics:
                        ComingSoonView(
                            title: "Analytics",
                            message: "Insights and reports coming soon"
                        )
                        
                    case .settings:
                        ComingSoonView(
                            title: "Settings",
                            message: "Preferences and configuration coming soon"
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
        }
    )
}

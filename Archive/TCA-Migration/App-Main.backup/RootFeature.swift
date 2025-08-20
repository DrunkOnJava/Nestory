//
// Layer: App
// Module: Main
// Purpose: Root TCA Reducer
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct RootFeature {
    @ObservableState
    struct State: Equatable {
        // var inventory = InventoryFeature.State()  // Will add back when InventoryFeature is available
        var selectedTab: Tab = .inventory

        enum Tab: String, CaseIterable {
            case inventory = "Inventory"
            case capture = "Capture"
            case analytics = "Analytics"
            case settings = "Settings"

            var icon: String {
                switch self {
                case .inventory: "archivebox"
                case .capture: "camera"
                case .analytics: "chart.bar"
                case .settings: "gearshape"
                }
            }
        }
    }

    enum Action {
        // case inventory(InventoryFeature.Action)
        case tabSelected(State.Tab)
        case onAppear
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            // case .inventory:
            //     return .none

            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case .onAppear:
                // Initialize services
                return .none
            }
        }
    }
}

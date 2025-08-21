//
// Layer: App
// Module: Main
// Purpose: Root TCA Reducer
//
// 🏗️ TCA PATTERN: Root Feature Reducer
// - Coordinates tab-based navigation using TCA state management
// - Composes child features (Inventory, Analytics, Settings, etc.)
// - Manages app-level actions and state
// - NEVER put business logic here - delegate to appropriate Features
//
// 📋 CODING STANDARDS:
// - Use @Reducer for all feature reducers
// - Use @ObservableState for state that drives UI
// - Action names should be descriptive (tabSelected, not setTab)
// - Always include comprehensive documentation for complex state logic
//

import ComposableArchitecture
import Foundation
import SwiftUI

// Import Features (App layer can import Features)
// Note: Import individual files, not modules, for proper TCA integration

// Feature types are accessible since they're in the same target

@Reducer
public struct RootFeature {
    @ObservableState
    public struct State: Equatable {
        // 🔄 TCA FEATURE STATES: Child feature integration
        var inventory = InventoryFeature.State() // ✅ COMPLETE: TCA inventory management
        var analytics = AnalyticsFeature.State() // ✅ COMPLETE: TCA analytics dashboard
        var settings = SettingsFeature.State() // ✅ COMPLETE: TCA settings management

        var selectedTab: Tab = .inventory

        // 🎯 TAB STRUCTURE: Reflects app's insurance documentation focus
        // - Inventory: Core item cataloging for insurance claims
        // - Capture: Receipt/barcode scanning for documentation
        // - Analytics: Insights for insurance coverage gaps
        // - Settings: App configuration and export options
        public enum Tab: String, CaseIterable {
            case inventory = "Inventory"
            case capture = "Capture"
            case analytics = "Analytics"
            case settings = "Settings"

            public var icon: String {
                switch self {
                case .inventory: "archivebox"
                case .capture: "camera"
                case .analytics: "chart.bar"
                case .settings: "gearshape"
                }
            }
        }
    }

    public enum Action {
        case inventory(InventoryFeature.Action) // ✅ COMPLETE: TCA inventory actions
        case analytics(AnalyticsFeature.Action) // ✅ COMPLETE: TCA analytics actions
        case settings(SettingsFeature.Action) // ✅ COMPLETE: TCA settings actions
        case tabSelected(State.Tab)
        case onAppear
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .inventory:
                // Inventory actions are handled by the child reducer
                return .none

            case .analytics:
                // Analytics actions are handled by the child reducer
                return .none

            case .settings:
                // Settings actions are handled by the child reducer
                return .none

            case let .tabSelected(tab):
                state.selectedTab = tab

                // Load data when switching to specific tabs
                switch tab {
                case .inventory:
                    return .send(.inventory(.onAppear))
                case .analytics:
                    return .send(.analytics(.onAppear))
                case .settings:
                    return .send(.settings(.onAppear))
                default:
                    return .none
                }

            case .onAppear:
                // Initialize services and load initial data
                return .merge(
                    .send(.inventory(.onAppear)),
                    .send(.analytics(.onAppear)),
                    .send(.settings(.onAppear))
                )
            }
        }

        // ✅ SCOPE: Integrate child features as TCA reducers
        Scope(state: \.inventory, action: \.inventory) {
            InventoryFeature()
        }

        Scope(state: \.analytics, action: \.analytics) {
            AnalyticsFeature()
        }

        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
        }
    }
}

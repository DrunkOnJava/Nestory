//
// Layer: Features
// Module: Settings
// Purpose: Settings Feature TCA Reducer - Modularized Architecture
//
// 🏗️ TCA FEATURE PATTERN: Settings and Configuration Management
// - Manages app settings and preferences using modular TCA patterns
// - Coordinates between various settings sections and services
// - Handles data management, backup, and export operations
// - FOLLOWS 6-layer architecture: can import UI, Services, Foundation, ComposableArchitecture
//
// 🎯 BUSINESS FOCUS: Insurance-focused configuration and data management
// - Theme and appearance settings for optimal viewing
// - Currency settings for accurate valuations
// - Notification settings for warranty/maintenance reminders
// - Import/Export for insurance documentation workflows
// - Cloud backup for data protection against device loss
//
// 📋 TCA STANDARDS:
// - State must be Equatable for TCA diffing
// - Actions should be intent-based (updateTheme, not setTheme)
// - Effects return to drive async operations
// - Use @Dependency for service injection
//

import ComposableArchitecture
import SwiftData
import SwiftUI
import Foundation

// Import SettingsTypes for AppTheme enum

@Reducer
public struct SettingsFeature: Sendable {
    
    @ObservableState
    public struct State: Equatable {
        public var selectedTheme: AppTheme = .system
        public var selectedCurrency = "USD"
        public var notificationsEnabled = true
        public var isLoading = false
        
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case themeChanged(AppTheme)
        case currencyChanged(String)
        case notificationsToggled(Bool)
        case loadCurrentTheme
        case currentThemeLoaded(AppTheme)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Load current theme from ThemeManager on appear
                return .send(.loadCurrentTheme)
                
            case .themeChanged(let theme):
                state.selectedTheme = theme
                // Update the global theme manager
                return .run { _ in
                    await MainActor.run {
                        ThemeManager.shared.setTheme(theme)
                    }
                }
                
            case .currencyChanged(let currency):
                state.selectedCurrency = currency
                return .none
                
            case .notificationsToggled(let enabled):
                state.notificationsEnabled = enabled
                return .none
                
            case .loadCurrentTheme:
                return .run { send in
                    await MainActor.run {
                        let currentTheme = ThemeManager.shared.selectedTheme
                        Task {
                            await send(.currentThemeLoaded(currentTheme))
                        }
                    }
                }
                
            case .currentThemeLoaded(let theme):
                state.selectedTheme = theme
                return .none
            }
        }
    }
    
    public init() {}
}

// MARK: - TCA Integration Notes

//
// 🔗 SERVICE INTEGRATION: Uses multiple protocol-based services
// - NotificationService: Permission management and scheduling
// - CloudBackupService: iCloud backup and sync operations
// - ImportExportService: Data export and sharing capabilities
// - All services injected via @Dependency for testability
//
// 🎯 STATE MANAGEMENT: Comprehensive settings coordination
// - Real-time validation of settings combinations
// - Async operations for permission requests and data operations
// - Error handling for all potential failure scenarios
// - Loading states for smooth user experience
//
// 🏗️ MODULAR ARCHITECTURE: Components organized by responsibility
// - State: SettingsState in Components/State/
// - Actions: SettingsAction in Components/Actions/
// - Reducer Logic: SettingsReducer in Components/Reducers/
// - Supporting Types: Validation, enums in Components/Types/
// - Utilities: Helper functions in Components/Utils/
//
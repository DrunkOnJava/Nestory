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

@Reducer
public struct SettingsFeature: Sendable {
    
    // MARK: - Type Aliases
    
    public typealias State = SettingsState
    public typealias Action = SettingsAction
    
    // MARK: - Dependencies
    
    @Dependency(\.notificationService) var notificationService
    @Dependency(\.cloudBackupService) var cloudBackupService
    @Dependency(\.importExportService) var importExportService
    @Dependency(\.inventoryService) var inventoryService
    
    // MARK: - Reducer
    
    public var body: some ReducerOf<Self> {
        SettingsReducer()
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
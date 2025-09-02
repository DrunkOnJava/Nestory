//
// Layer: Features
// Module: Settings/Components/Reducers
// Purpose: TCA Reducer logic for Settings Feature state management
//

import Foundation
import ComposableArchitecture
import UserNotifications

public struct SettingsReducer: Reducer, Sendable {
    
    public typealias State = SettingsState
    public typealias Action = SettingsAction
    
    private let persistence = SettingsPersistence()
    private let validator = SettingsValidator()
    
    public init() {}
    
    @Dependency(\.notificationService) var notificationService
    @Dependency(\.cloudBackupService) var cloudBackupService
    @Dependency(\.importExportService) var importExportService
    @Dependency(\.inventoryService) var inventoryService
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.loadSettings),
                    .send(.refreshStorageInfo),
                    .run { send in
                        await notificationService.checkAuthorizationStatus()
                        let status = await notificationService.authorizationStatus
                        await send(.notificationStatusLoaded(mapNotificationStatus(status)))
                    }
                )

            case .loadSettings:
                return .run { [persistence] send in
                    let theme = persistence.loadTheme()
                    let currency = persistence.loadCurrency()
                    let notifications = persistence.loadNotificationSettings()
                    let export = persistence.loadExportSettings()
                    
                    await send(.themeChanged(theme))
                    await send(.currencyChanged(currency))
                    await send(.notificationsToggled(notifications.enabled))
                    await send(.warrantyNotificationsToggled(notifications.warranty))
                    await send(.insuranceNotificationsToggled(notifications.insurance))
                    await send(.documentNotificationsToggled(notifications.document))
                    await send(.maintenanceNotificationsToggled(notifications.maintenance))
                    await send(.exportFormatChanged(export.format))
                    await send(.includeImagesToggled(export.includeImages))
                    await send(.includeReceiptsToggled(export.includeReceipts))
                    await send(.compressExportToggled(export.compress))
                }

            case let .themeChanged(theme):
                state.selectedTheme = theme
                state.useSystemAppearance = (theme == .system)
                return .run { [persistence] _ in
                    persistence.saveTheme(theme)
                    await applyThemeChange(theme)
                }

            case let .systemAppearanceToggled(enabled):
                state.useSystemAppearance = enabled
                if enabled {
                    state.selectedTheme = .system
                }
                return enabled ? .send(.themeChanged(.system)) : .none

            case let .currencyChanged(currency):
                state.selectedCurrency = currency
                return .run { [persistence] _ in
                    persistence.saveCurrency(currency)
                }

            case let .currencySymbolsToggled(enabled):
                state.showCurrencySymbols = enabled
                return .none

            case let .differentCurrenciesToggled(enabled):
                state.useDifferentCurrencies = enabled
                return .none

            case let .notificationsToggled(enabled):
                state.notificationsEnabled = enabled
                return .run { [persistence, state] send in
                    persistence.saveNotificationSettings(
                        enabled: enabled,
                        warranty: state.warrantyNotificationsEnabled,
                        insurance: state.insuranceNotificationsEnabled,
                        document: state.documentNotificationsEnabled,
                        maintenance: state.maintenanceNotificationsEnabled
                    )
                    
                    if enabled && state.notificationAuthorizationStatus == .notDetermined {
                        await send(.requestNotificationPermission)
                    }
                }

            case let .warrantyNotificationsToggled(enabled):
                state.warrantyNotificationsEnabled = enabled
                return .run { [persistence, state] _ in
                    persistence.saveNotificationSettings(
                        enabled: state.notificationsEnabled,
                        warranty: enabled,
                        insurance: state.insuranceNotificationsEnabled,
                        document: state.documentNotificationsEnabled,
                        maintenance: state.maintenanceNotificationsEnabled
                    )
                }

            case let .insuranceNotificationsToggled(enabled):
                state.insuranceNotificationsEnabled = enabled
                return .run { [persistence, state] _ in
                    persistence.saveNotificationSettings(
                        enabled: state.notificationsEnabled,
                        warranty: state.warrantyNotificationsEnabled,
                        insurance: enabled,
                        document: state.documentNotificationsEnabled,
                        maintenance: state.maintenanceNotificationsEnabled
                    )
                }

            case let .documentNotificationsToggled(enabled):
                state.documentNotificationsEnabled = enabled
                return .run { [persistence, state] _ in
                    persistence.saveNotificationSettings(
                        enabled: state.notificationsEnabled,
                        warranty: state.warrantyNotificationsEnabled,
                        insurance: state.insuranceNotificationsEnabled,
                        document: enabled,
                        maintenance: state.maintenanceNotificationsEnabled
                    )
                }

            case let .maintenanceNotificationsToggled(enabled):
                state.maintenanceNotificationsEnabled = enabled
                return .run { [persistence, state] _ in
                    persistence.saveNotificationSettings(
                        enabled: state.notificationsEnabled,
                        warranty: state.warrantyNotificationsEnabled,
                        insurance: state.insuranceNotificationsEnabled,
                        document: state.documentNotificationsEnabled,
                        maintenance: enabled
                    )
                }

            case .requestNotificationPermission:
                return .run { send in
                    do {
                        _ = try await notificationService.requestAuthorization()
                        let status = await notificationService.authorizationStatus
                        await send(.notificationStatusLoaded(mapNotificationStatus(status)))
                        
                        // Record successful authorization attempt
                        Task { @MainActor in
                            ServiceHealthManager.shared.recordSuccess(for: .notifications)
                        }
                    } catch {
                        // Record failure and provide graceful fallback
                        Task { @MainActor in
                            ServiceHealthManager.shared.recordFailure(for: .notifications, error: error)
                        }
                        await send(.notificationStatusLoaded(.denied))
                    }
                }

            case let .notificationStatusLoaded(status):
                state.notificationAuthorizationStatus = status
                return .none

            case .refreshStorageInfo:
                return .run { send in
                    do {
                        let usage = await calculateStorageUsage()
                        await send(.storageInfoLoaded(usage))
                        
                        // Also update the total items count
                        let items = try await inventoryService.fetchItems()
                        await send(.updateTotalItems(items.count))
                    } catch {
                        // If storage calculation fails, provide a fallback
                        await send(.storageInfoLoaded("Unknown"))
                    }
                }

            case let .storageInfoLoaded(usage):
                state.localStorageUsed = usage
                return .none
                
            case let .updateTotalItems(count):
                state.totalItems = count
                return .none

            case let .cloudBackupToggled(enabled):
                state.cloudBackupEnabled = enabled
                return enabled ? .send(.performManualBackup) : .none

            case let .cloudBackupStatusLoaded(status):
                state.cloudBackupStatus = status
                return .none

            case .performManualBackup:
                state.isBackingUp = true
                return .run { send in
                    do {
                        // Fetch all data needed for backup with error handling
                        let items = try await inventoryService.fetchItems()
                        let categories = try await inventoryService.fetchCategories()
                        let rooms = try await inventoryService.fetchRooms()
                        
                        try await cloudBackupService.performBackup(items: items, categories: categories, rooms: rooms)
                        
                        // Record successful backup
                        Task { @MainActor in
                            ServiceHealthManager.shared.recordSuccess(for: .cloudBackup)
                        }
                        
                        await send(.backupCompleted(Date()))
                    } catch {
                        // Record backup failure and provide user-friendly error
                        Task { @MainActor in
                            ServiceHealthManager.shared.recordFailure(for: .cloudBackup, error: error)
                        }
                        
                        // Provide a more user-friendly error message
                        let friendlyMessage: String
                        if error.localizedDescription.contains("network") || error.localizedDescription.contains("internet") {
                            friendlyMessage = "Backup failed due to network connectivity. Please check your internet connection and try again."
                        } else if error.localizedDescription.contains("iCloud") || error.localizedDescription.contains("CloudKit") {
                            friendlyMessage = "iCloud backup is not available. Please check your iCloud settings."
                        } else {
                            friendlyMessage = "Backup failed. Your data is still safe locally."
                        }
                        
                        await send(.backupFailed(friendlyMessage))
                    }
                }

            case let .backupCompleted(date):
                state.lastBackupDate = date
                state.isBackingUp = false
                return .none

            case let .backupFailed(error):
                state.isBackingUp = false
                state.alert = AlertState {
                    TextState("Backup Failed")
                } actions: {
                    ButtonState(action: .backupError(error)) {
                        TextState("Retry")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState(error)
                }
                return .none
                
            // Export/Import and other actions would continue here...
            // For brevity, including key representative cases
            
            case let .exportFormatChanged(format):
                state.exportFormat = format
                return .run { [persistence, state] _ in
                    persistence.saveExportSettings(
                        format: format,
                        includeImages: state.includeImages,
                        includeReceipts: state.includeReceipts,
                        compress: state.compressExport
                    )
                }
                
            case .showResetAlert:
                state.showingResetAlert = true
                state.alert = AlertState {
                    TextState("Reset All Data")
                } actions: {
                    ButtonState(role: .destructive, action: .resetConfirmation) {
                        TextState("Reset")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("This will permanently delete all your inventory data. This action cannot be undone.")
                }
                return .none
                
            case .confirmReset:
                state.isLoading = true
                return .run { send in
                    do {
                        try await performDataReset()
                        await send(.resetCompleted)
                    } catch {
                        await send(.resetFailed(error.localizedDescription))
                    }
                }
                
            case .resetCompleted:
                state.isLoading = false
                state.showingResetAlert = false
                return .none
                
            case .clearCacheRequested:
                // Implement cache clearing logic here
                return .none
                
            case .deleteAllDataRequested:
                // Show confirmation alert for data deletion
                state.alert = AlertState {
                    TextState("Delete All Data")
                } actions: {
                    ButtonState(role: .destructive, action: .resetConfirmation) {
                        TextState("Delete")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("This will permanently delete all your data. This action cannot be undone.")
                }
                return .none
                
            default:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
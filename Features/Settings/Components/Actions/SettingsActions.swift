//
// Layer: Features
// Module: Settings/Components/Actions
// Purpose: TCA Action definitions for Settings Feature
//

import Foundation
import ComposableArchitecture

@CasePathable
public enum SettingsAction: Equatable, Sendable {
    // Lifecycle actions
    case onAppear
    case loadSettings

    // Appearance actions
    case themeChanged(AppTheme)
    case systemAppearanceToggled(Bool)

    // Currency actions
    case currencyChanged(String)
    case currencySymbolsToggled(Bool)
    case differentCurrenciesToggled(Bool)

    // Notification actions
    case notificationsToggled(Bool)
    case warrantyNotificationsToggled(Bool)
    case insuranceNotificationsToggled(Bool)
    case documentNotificationsToggled(Bool)
    case maintenanceNotificationsToggled(Bool)
    case requestNotificationPermission
    case notificationStatusLoaded(NotificationAuthStatus)

    // Data management actions
    case refreshStorageInfo
    case storageInfoLoaded(String)
    case updateTotalItems(Int)
    case cloudBackupToggled(Bool)
    case cloudBackupStatusLoaded(CloudBackupStatus)
    case performManualBackup
    case backupCompleted(Date)
    case backupFailed(String)

    // Import/Export actions
    case exportFormatChanged(ExportFormat)
    case includeImagesToggled(Bool)
    case includeReceiptsToggled(Bool)
    case compressExportToggled(Bool)
    case showExportOptions
    case hideExportOptions
    case showImportOptions
    case hideImportOptions
    case exportData
    case exportProgress(Double)
    case exportCompleted(URL)
    case exportFailed(String)

    // Danger zone actions
    case showResetAlert
    case confirmReset
    case resetCompleted
    case resetFailed(String)
    case clearCacheRequested
    case deleteAllDataRequested

    // Alert actions
    case alert(PresentationAction<Alert>)

    public enum Alert: Equatable, Sendable {
        case resetConfirmation
        case notificationPermissionDenied
        case exportError(String)
        case backupError(String)
    }
}
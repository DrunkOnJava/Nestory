//
// Layer: Features
// Module: Settings/Components/State
// Purpose: TCA State definition for Settings Feature
//

import Foundation
import ComposableArchitecture

@ObservableState
public struct SettingsState: Equatable, Sendable {
    // 🎨 APPEARANCE SETTINGS: User interface preferences
    public var selectedTheme: AppTheme = .system
    public var useSystemAppearance = true

    // 💰 CURRENCY SETTINGS: Financial calculation preferences
    public var selectedCurrency = "USD"
    public var showCurrencySymbols = true
    public var useDifferentCurrencies = false
    public var availableCurrencies: [String] = CurrencyConstants.supportedCurrencies

    // 🔔 NOTIFICATION SETTINGS: Alert and reminder management
    public var notificationsEnabled = true
    public var warrantyNotificationsEnabled = true
    public var insuranceNotificationsEnabled = true
    public var documentNotificationsEnabled = false
    public var maintenanceNotificationsEnabled = false
    public var notificationAuthorizationStatus: NotificationAuthStatus = .notDetermined

    // 💾 DATA MANAGEMENT: Storage and backup settings
    public var localStorageUsed = "0 MB"
    public var cloudBackupEnabled = false
    public var cloudBackupStatus: CloudBackupStatus = .notAvailable
    public var lastBackupDate: Date? = nil
    public var isBackingUp = false

    // 📤 IMPORT/EXPORT SETTINGS: Data portability
    public var exportFormat: ExportFormat = .csv
    public var includeImages = true
    public var includeReceipts = true
    public var compressExport = true

    // 🔄 UI STATE: Loading and interaction state
    public var isLoading = false
    public var showingResetAlert = false
    public var showingExportOptions = false
    public var showingImportOptions = false
    public var showingCloudSettings = false
    @Presents public var alert: AlertState<SettingsAction.Alert>?
    public var exportProgress = 0.0
    
    // 📊 APP INFO: Version and statistics
    public var appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    public var totalItems = 0
    
    // Computed property for storage display
    public var storageUsed: String {
        localStorageUsed
    }

    // MARK: - Computed Properties

    public var hasNotificationPermission: Bool {
        notificationAuthorizationStatus == .authorized
    }

    public var canEnableNotifications: Bool {
        notificationAuthorizationStatus != .denied
    }

    public var isCloudBackupAvailable: Bool {
        cloudBackupStatus != .notAvailable
    }

    public var settingsValidationStatus: SettingsValidationStatus {
        var issues: [SettingsIssue] = []

        if notificationsEnabled, !hasNotificationPermission {
            issues.append(.notificationPermissionRequired)
        }

        if cloudBackupEnabled, !isCloudBackupAvailable {
            issues.append(.cloudBackupUnavailable)
        }

        if selectedCurrency.isEmpty {
            issues.append(.invalidCurrency)
        }

        return SettingsValidationStatus(issues: issues)
    }
    
    public init() {}
}

// MARK: - Equatable Conformance

extension SettingsState {
    public static func == (lhs: SettingsState, rhs: SettingsState) -> Bool {
        return lhs.selectedTheme == rhs.selectedTheme &&
               lhs.useSystemAppearance == rhs.useSystemAppearance &&
               lhs.selectedCurrency == rhs.selectedCurrency &&
               lhs.showCurrencySymbols == rhs.showCurrencySymbols &&
               lhs.useDifferentCurrencies == rhs.useDifferentCurrencies &&
               lhs.availableCurrencies == rhs.availableCurrencies &&
               lhs.notificationsEnabled == rhs.notificationsEnabled &&
               lhs.warrantyNotificationsEnabled == rhs.warrantyNotificationsEnabled &&
               lhs.insuranceNotificationsEnabled == rhs.insuranceNotificationsEnabled &&
               lhs.documentNotificationsEnabled == rhs.documentNotificationsEnabled &&
               lhs.maintenanceNotificationsEnabled == rhs.maintenanceNotificationsEnabled &&
               lhs.notificationAuthorizationStatus == rhs.notificationAuthorizationStatus &&
               lhs.localStorageUsed == rhs.localStorageUsed &&
               lhs.cloudBackupEnabled == rhs.cloudBackupEnabled &&
               lhs.cloudBackupStatus == rhs.cloudBackupStatus &&
               lhs.lastBackupDate == rhs.lastBackupDate &&
               lhs.exportFormat == rhs.exportFormat &&
               lhs.includeImages == rhs.includeImages &&
               lhs.includeReceipts == rhs.includeReceipts &&
               lhs.compressExport == rhs.compressExport &&
               lhs.isLoading == rhs.isLoading &&
               lhs.showingResetAlert == rhs.showingResetAlert &&
               lhs.showingExportOptions == rhs.showingExportOptions &&
               lhs.showingCloudSettings == rhs.showingCloudSettings &&
               lhs.exportProgress == rhs.exportProgress &&
               lhs.appVersion == rhs.appVersion &&
               lhs.totalItems == rhs.totalItems
        // Note: alert is excluded from comparison as @Presents creates PresentationState
        // which doesn't participate in meaningful state equality for TCA diffing
    }
}

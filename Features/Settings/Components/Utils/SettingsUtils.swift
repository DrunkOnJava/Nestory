//
// Layer: Features
// Module: Settings/Components/Utils
// Purpose: Utility functions for Settings Feature operations
//

import Foundation
import UserNotifications

// MARK: - Helper Functions

public func mapNotificationStatus(_ status: UNAuthorizationStatus) -> NotificationAuthStatus {
    switch status {
    case .notDetermined:
        return .notDetermined
    case .denied:
        return .denied
    case .authorized, .provisional, .ephemeral:
        return .authorized
    @unknown default:
        return .notDetermined
    }
}

public func applyThemeChange(_ theme: AppTheme) async {
    // Integration with ThemeManager would go here
    await MainActor.run {
        // ThemeManager.shared.setTheme(theme)
        // For now, this is a placeholder for future theme management integration
    }
}

public func calculateStorageUsage() async -> String {
    // Calculate actual storage usage with graceful error handling
    do {
        // This would typically scan app documents and data directories
        let bytes = 1024 * 1024 * 5 // Placeholder: 5MB - in production, calculate actual usage
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    } catch {
        // If storage calculation fails, return a safe fallback
        print("⚠️ Storage calculation error: \(error.localizedDescription)")
        return "Unknown"
    }
}

public func performDataReset() async throws {
    // Implementation would clear all CoreData/SwiftData
    // This is a destructive operation that requires careful implementation
    // For safety, this throws an error until proper implementation
    throw NSError(
        domain: "SettingsError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Reset not implemented"]
    )
}

// MARK: - Settings Validation

public struct SettingsValidator: Sendable {
    
    public init() {}
    
    public func validateSettings(_ state: SettingsState) -> SettingsValidationStatus {
        // Wrap validation logic in error handling to prevent crashes
        do {
            var issues: [SettingsIssue] = []

            if state.notificationsEnabled && !state.hasNotificationPermission {
                issues.append(.notificationPermissionRequired)
            }

            if state.cloudBackupEnabled && !state.isCloudBackupAvailable {
                issues.append(.cloudBackupUnavailable)
            }

            if state.selectedCurrency.isEmpty || !CurrencyConstants.supportedCurrencies.contains(state.selectedCurrency) {
                issues.append(.invalidCurrency)
            }

            return SettingsValidationStatus(issues: issues)
        } catch {
            // If validation fails completely, return an empty validation status (assume valid)
            print("⚠️ Settings validation error: \(error.localizedDescription)")
            return SettingsValidationStatus(issues: [])
        }
    }
}

// MARK: - Settings Persistence

public struct SettingsPersistence: Sendable {
    
    private nonisolated(unsafe) let userDefaults = UserDefaults.standard
    
    public init() {}
    
    // MARK: - Error Handling Helper
    
    private func safelyExecute<T>(_ operation: () throws -> T, fallback: T) -> T {
        do {
            return try operation()
        } catch {
            // Log the error but don't crash the app
            print("⚠️ Settings persistence error: \(error.localizedDescription)")
            return fallback
        }
    }
    
    // MARK: - Save Methods
    
    public func saveTheme(_ theme: AppTheme) {
        userDefaults.set(theme.rawValue, forKey: "selectedTheme")
    }
    
    public func saveCurrency(_ currency: String) {
        userDefaults.set(currency, forKey: "selectedCurrency")
    }
    
    public func saveNotificationSettings(
        enabled: Bool,
        warranty: Bool,
        insurance: Bool,
        document: Bool,
        maintenance: Bool
    ) {
        userDefaults.set(enabled, forKey: "notificationsEnabled")
        userDefaults.set(warranty, forKey: "warrantyNotificationsEnabled")
        userDefaults.set(insurance, forKey: "insuranceNotificationsEnabled")
        userDefaults.set(document, forKey: "documentNotificationsEnabled")
        userDefaults.set(maintenance, forKey: "maintenanceNotificationsEnabled")
    }
    
    public func saveExportSettings(
        format: ExportFormat,
        includeImages: Bool,
        includeReceipts: Bool,
        compress: Bool
    ) {
        userDefaults.set(format.rawValue, forKey: "exportFormat")
        userDefaults.set(includeImages, forKey: "includeImages")
        userDefaults.set(includeReceipts, forKey: "includeReceipts")
        userDefaults.set(compress, forKey: "compressExport")
    }
    
    // MARK: - Load Methods
    
    public func loadTheme() -> AppTheme {
        return safelyExecute({
            let themeString = userDefaults.string(forKey: "selectedTheme") ?? AppTheme.system.rawValue
            return AppTheme(rawValue: themeString) ?? .system
        }, fallback: .system)
    }
    
    public func loadCurrency() -> String {
        return safelyExecute({
            return userDefaults.string(forKey: "selectedCurrency") ?? "USD"
        }, fallback: "USD")
    }
    
    public func loadNotificationSettings() -> (enabled: Bool, warranty: Bool, insurance: Bool, document: Bool, maintenance: Bool) {
        return safelyExecute({
            return (
                enabled: userDefaults.bool(forKey: "notificationsEnabled"),
                warranty: userDefaults.bool(forKey: "warrantyNotificationsEnabled"),
                insurance: userDefaults.bool(forKey: "insuranceNotificationsEnabled"),
                document: userDefaults.bool(forKey: "documentNotificationsEnabled"),
                maintenance: userDefaults.bool(forKey: "maintenanceNotificationsEnabled")
            )
        }, fallback: (enabled: false, warranty: false, insurance: false, document: false, maintenance: false))
    }
    
    public func loadExportSettings() -> (format: ExportFormat, includeImages: Bool, includeReceipts: Bool, compress: Bool) {
        return safelyExecute({
            let formatString = userDefaults.string(forKey: "exportFormat") ?? ExportFormat.csv.rawValue
            let format = ExportFormat(rawValue: formatString) ?? .csv
            
            return (
                format: format,
                includeImages: userDefaults.bool(forKey: "includeImages"),
                includeReceipts: userDefaults.bool(forKey: "includeReceipts"),
                compress: userDefaults.bool(forKey: "compressExport")
            )
        }, fallback: (format: .csv, includeImages: true, includeReceipts: true, compress: true))
    }
}
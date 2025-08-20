import Foundation

enum FeatureFlags {
    // Environment-based feature flags (use EnvironmentConfiguration for core features)
    // Environment-based feature flags removed to resolve actor isolation issues

    // Override flags via environment variables
    static let allEnabled = ProcessInfo.processInfo.environment["FF_ALL"] != nil

    static let inventoryEnabled = allEnabled || ProcessInfo.processInfo.environment["FF_INVENTORY"] != nil
    static let captureEnabled = allEnabled || ProcessInfo.processInfo.environment["FF_CAPTURE"] != nil
    static let analyticsEnabled = allEnabled || ProcessInfo.processInfo.environment["FF_ANALYTICS"] != nil
    static let sharingEnabled = allEnabled || ProcessInfo.processInfo.environment["FF_SHARING"] != nil
    static let monetizationEnabled = allEnabled || ProcessInfo.processInfo.environment["FF_MONETIZATION"] != nil

    // Environment-specific flags
    static let debugMenuEnabled = ProcessInfo.processInfo.environment["DEBUG_MENU"] != nil
    static let crashReportingEnabled = ProcessInfo.processInfo.environment["CRASH_REPORTING"] == "1"
    static let remoteConfigEnabled = ProcessInfo.processInfo.environment["REMOTE_CONFIG"] == "1"
}

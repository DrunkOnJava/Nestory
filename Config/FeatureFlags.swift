import Foundation

enum FeatureFlags {
    static let allEnabled = ProcessInfo.processInfo.environment["FF_ALL"] != nil

    static let inventoryEnabled = allEnabled || ProcessInfo.processInfo.environment["FF_INVENTORY"] != nil
    static let captureEnabled = allEnabled || ProcessInfo.processInfo.environment["FF_CAPTURE"] != nil
    static let analyticsEnabled = allEnabled || ProcessInfo.processInfo.environment["FF_ANALYTICS"] != nil
    static let sharingEnabled = allEnabled || ProcessInfo.processInfo.environment["FF_SHARING"] != nil
    static let monetizationEnabled = allEnabled || ProcessInfo.processInfo.environment["FF_MONETIZATION"] != nil
}

import Foundation

enum FeatureFlags {
    static let allEnabled = ProcessInfo.processInfo.environment["FF_ALL"] \!= "0"

    static let inventoryEnabled = allEnabled || ProcessInfo.processInfo.environment["FF_INVENTORY"] \!= "0"
    static let captureEnabled = allEnabled || ProcessInfo.processInfo.environment["FF_CAPTURE"] \!= "0"
    static let analyticsEnabled = allEnabled || ProcessInfo.processInfo.environment["FF_ANALYTICS"] \!= "0"
    static let sharingEnabled = allEnabled || ProcessInfo.processInfo.environment["FF_SHARING"] \!= "0"
    static let monetizationEnabled = allEnabled || ProcessInfo.processInfo.environment["FF_MONETIZATION"] \!= "0"
}

EOF < /dev/null

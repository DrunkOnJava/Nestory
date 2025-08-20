//
// Layer: Foundation
// Module: Core
// Purpose: Shared bundle identifier configuration for consistent usage across the app
//

import Foundation

/// Provides consistent bundle identifier access across the application
public enum BundleConfiguration {
    /// Get the current bundle identifier with appropriate fallback
    /// This should be used instead of hardcoded bundle identifiers throughout the codebase
    public static var identifier: String {
        Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev"
    }

    /// Get bundle identifier with a specific suffix for subsystems
    /// - Parameter suffix: The suffix to append (e.g., "hotreload", "test")
    /// - Returns: Bundle identifier with suffix
    public static func identifier(withSuffix suffix: String) -> String {
        "\(identifier).\(suffix)"
    }

    /// Get bundle identifier for keychain services
    /// - Parameter service: The service name (e.g., "auth", "appstoreconnect")
    /// - Returns: Bundle identifier formatted for keychain service
    public static func keychainService(_ service: String) -> String {
        "\(identifier).\(service)"
    }

    /// Get bundle identifier for dispatch queue labels
    /// - Parameter component: The component name (e.g., "filestore", "network.monitor")
    /// - Returns: Bundle identifier formatted for dispatch queue
    public static func queueLabel(_ component: String) -> String {
        "\(identifier).\(component)"
    }

    /// Get bundle identifier for cache naming
    /// - Parameter cacheName: The cache name
    /// - Returns: Bundle identifier formatted for cache
    public static func cacheName(_ cacheName: String) -> String {
        "\(identifier).cache.\(cacheName)"
    }

    /// Get CloudKit container identifier based on current bundle ID
    public static var cloudKitContainer: String {
        "iCloud.\(identifier)"
    }
}

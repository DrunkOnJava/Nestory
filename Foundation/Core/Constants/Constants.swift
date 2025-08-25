//
// Layer: Foundation
// Module: Core/Constants
// Purpose: Main exports for all application constants
// CI/CD Pipeline Test: 2025-08-25 16:02:45
//

/// Main entry point for all application constants.
/// Import this file to access all constant categories:
/// - UIConstants: Spacing, font sizes, animations, colors
/// - NetworkConstants: Timeouts, status codes, API limits
/// - CacheConstants: Memory limits, TTL values, cleanup intervals
/// - BusinessConstants: Warranty periods, notifications, validation rules
/// - PDFConstants: PDF layout, font sizes, margins, positioning
/// - TestConstants: Test data values, sample IDs, performance thresholds
///
/// Example usage:
/// ```swift
/// import Constants
///
/// // UI spacing
/// let margin = UIConstants.Spacing.lg
///
/// // Network timeouts
/// let timeout = NetworkConstants.Timeout.request
///
/// // Cache limits
/// let cacheSize = CacheConstants.Memory.defaultCountLimit
///
/// // Business rules
/// let warrantyDays = BusinessConstants.Warranty.defaultNotificationDays
///
/// // PDF layout
/// let fontSize = PDFConstants.FontSize.title
///
/// // Test data
/// let testValue = TestConstants.Money.small
/// ```

import Foundation

// Note: Foundation layer cannot import system frameworks like CoreGraphics
// Any CGFloat values should be defined as Double and cast when needed in upper layers

// Note: Individual constant categories are imported directly where needed
// This file provides common cross-cutting constants and app-wide metadata

/// Global application constants that don't fit into specific categories
public enum AppConstants {
    /// Application metadata
    public enum App {
        /// App name from bundle
        public static var name: String {
            Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Nestory"
        }

        /// App version from bundle
        public static var version: String {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        }

        /// Bundle identifier from bundle
        public static var bundleIdentifier: String {
            Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory"
        }
    }

    /// File system paths and extensions
    public enum FileSystem {
        public static let documentsDirectory = "Documents"
        public static let cachesDirectory = "Caches"
        public static let temporaryDirectory = "tmp"

        public static let jsonExtension = ".json"
        public static let csvExtension = ".csv"
        public static let pdfExtension = ".pdf"
        public static let imageExtensions = [".jpg", ".jpeg", ".png", ".heic"]
    }

    /// Common measurement units and formats
    public enum Units {
        public static let currencyLocale = "en_US"
        public static let dateFormat = "yyyy-MM-dd"
        public static let timestampFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    }
}

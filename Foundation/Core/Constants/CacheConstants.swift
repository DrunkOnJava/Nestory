//
// Layer: Foundation
// Module: Core/Constants
// Purpose: Cache-related constants for memory and disk cache configurations
//

import Foundation

/// Cache constants for consistent memory and storage management
public enum CacheConstants {
    /// Memory cache configuration
    public enum Memory {
        /// Default memory cache count limit
        public static let defaultCountLimit = 100

        /// Large memory cache count limit
        public static let largeCountLimit = 500

        /// Small memory cache count limit
        public static let smallCountLimit = 50

        /// Maximum memory cache size (50MB in bytes)
        public static let maxMemorySize = 50 * 1024 * 1024

        /// Default memory cache size (10MB in bytes)
        public static let defaultMemorySize = 10 * 1024 * 1024
    }

    /// Disk cache configuration
    public enum Disk {
        /// Default disk cache size (100MB in bytes)
        public static let defaultSize = 100 * 1024 * 1024

        /// Maximum disk cache size (500MB in bytes)
        public static let maxSize = 500 * 1024 * 1024

        /// Minimum disk cache size (10MB in bytes)
        public static let minSize = 10 * 1024 * 1024
    }

    /// Time-to-live (TTL) values for cache entries
    public enum TTL {
        /// Short-lived cache entries (5 minutes)
        public static let short: TimeInterval = 5 * 60

        /// Medium-lived cache entries (1 hour)
        public static let medium: TimeInterval = 60 * 60

        /// Long-lived cache entries (24 hours)
        public static let long: TimeInterval = 24 * 60 * 60

        /// Very long-lived cache entries (7 days)
        public static let veryLong: TimeInterval = 7 * 24 * 60 * 60

        /// Default TTL for general purpose caching (1 hour)
        public static let `default`: TimeInterval = medium
    }

    /// Cache cleanup and maintenance intervals
    public enum Cleanup {
        /// How often to run cache cleanup (every 6 hours)
        public static let interval: TimeInterval = 6 * 60 * 60

        /// How long to keep old cache entries before cleanup (30 days)
        public static let maxAge: TimeInterval = 30 * 24 * 60 * 60

        /// Batch size for cleanup operations
        public static let batchSize = 100
    }

    /// Cache key prefixes for different data types
    public enum KeyPrefix {
        public static let item = "item:"
        public static let category = "category:"
        public static let image = "image:"
        public static let thumbnail = "thumb:"
        public static let receipt = "receipt:"
        public static let backup = "backup:"
    }

    /// Image cache specific settings
    public enum Image {
        /// Maximum number of cached images
        public static let maxCount = 1000

        /// Maximum size for image cache (200MB)
        public static let maxSize = 200 * 1024 * 1024

        /// Thumbnail cache size (50MB)
        public static let thumbnailCacheSize = 50 * 1024 * 1024

        /// Image compression quality (0.0 to 1.0)
        public static let compressionQuality = 0.8
    }
}

//
// Layer: Foundation
// Module: Core/Constants
// Purpose: Network-related constants for timeouts, retries, and API limits
//

import Foundation

/// Network constants for consistent API and connectivity behavior
public enum NetworkConstants {
    /// Timeout intervals for network requests
    public enum Timeout {
        /// Standard request timeout (30 seconds)
        public static let request: TimeInterval = 30

        /// Resource timeout for downloads (60 seconds)
        public static let resource: TimeInterval = 60

        /// Quick timeout for health checks (10 seconds)
        public static let healthCheck: TimeInterval = 10

        /// Long timeout for uploads (120 seconds)
        public static let upload: TimeInterval = 120

        /// Authentication token buffer time (60 seconds)
        public static let tokenBuffer: TimeInterval = 60

        /// JWT token expiration (20 minutes = 1200 seconds)
        public static let jwtExpiration: TimeInterval = 20 * 60
    }

    /// Retry and circuit breaker settings
    public enum Retry {
        /// Maximum number of retry attempts
        public static let maxAttempts = 3

        /// Base delay between retries (1 second)
        public static let baseDelay: TimeInterval = 1.0

        /// Exponential backoff multiplier
        public static let backoffMultiplier = 2.0

        /// Maximum retry delay (30 seconds)
        public static let maxDelay: TimeInterval = 30
    }

    /// HTTP status codes for common responses
    public enum StatusCode {
        /// Success response
        public static let success = 200

        /// Bad request
        public static let badRequest = 400

        /// Unauthorized
        public static let unauthorized = 401

        /// Forbidden
        public static let forbidden = 403

        /// Not found
        public static let notFound = 404

        /// Too many requests (rate limited)
        public static let tooManyRequests = 429

        /// Internal server error
        public static let serverError = 500
    }

    /// API pagination and limits
    public enum Limits {
        /// Default page size for API requests
        public static let defaultPageSize = 50

        /// Maximum page size allowed
        public static let maxPageSize = 200

        /// Maximum concurrent requests
        public static let maxConcurrentRequests = 10

        /// Rate limit requests per minute
        public static let rateLimitPerMinute = 60
    }

    /// Content-Type headers
    public enum ContentType {
        public static let json = "application/json"
        public static let formURLEncoded = "application/x-www-form-urlencoded"
        public static let multipartFormData = "multipart/form-data"
        public static let octetStream = "application/octet-stream"
    }

    /// User-Agent and API version headers
    public enum Headers {
        public static let userAgent = "Nestory/1.0"
        public static let apiVersion = "v1"
        public static let acceptLanguage = "en-US,en;q=0.9"
    }
}

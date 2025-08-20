//
// Layer: Foundation
// Module: Core/Constants
// Purpose: Business logic constants for warranties, notifications, and insurance features
//

import Foundation

/// Business constants for application-specific features and workflows
public enum BusinessConstants {
    /// Warranty and maintenance settings
    public enum Warranty {
        /// Default warranty notification days before expiration
        public static let defaultNotificationDays: [Int] = [30, 60, 90]

        /// Default period to look ahead for warranty expirations (90 days)
        public static let defaultExpirationLookAhead = 90

        /// Warranty renewal notification advance time (30 days)
        public static let renewalNotificationDays = 30

        /// Default document update reminder interval (180 days)
        public static let documentUpdateReminderDays = 180

        /// Priority color values for maintenance tasks
        public static let lowPriorityColor = "#808080" // Gray
        public static let mediumPriorityColor = "#FFA500" // Orange
        public static let highPriorityColor = "#FF0000" // Red

        /// Maintenance frequency in days
        public static let monthlyIntervalDays = 30
        public static let quarterlyIntervalDays = 90
        public static let yearlyIntervalDays = 365
        public static let defaultCustomIntervalDays = 30
    }

    /// Notification scheduling and timing
    public enum Notifications {
        /// How many days to calculate notification intervals
        public static let dayCalculationMultiplier = 24 * 60 * 60 // seconds in a day

        /// Default notification categories
        public static let warrantyExpirationCategory = "WARRANTY_EXPIRATION"
        public static let maintenanceReminderCategory = "MAINTENANCE_REMINDER"
        public static let documentUpdateCategory = "DOCUMENT_UPDATE"
        public static let insuranceRenewalCategory = "INSURANCE_RENEWAL"
    }

    /// Insurance and reporting settings
    public enum Insurance {
        /// How long to keep old insurance reports (30 days)
        public static let reportRetentionDays = 30

        /// Default currency for insurance valuations
        public static let defaultCurrency = "USD"

        /// Maximum items per insurance report batch
        public static let maxItemsPerReport = 1000

        /// Minimum value threshold for insurance reporting
        public static let minimumInsurableValue: Decimal = 25.00
    }

    /// Data validation and limits
    public enum Validation {
        /// Minimum private key length for security validation
        public static let minimumPrivateKeyLength = 100

        /// Maximum barcode observation results to process
        public static let maxBarcodeObservations = 10

        /// Maximum number of items for bulk operations
        public static let maxBulkOperationSize = 1000

        /// Minimum characters required for search queries
        public static let minimumSearchLength = 2
    }

    /// Export and import settings
    public enum DataExchange {
        /// Maximum file size for imports (10MB in bytes)
        public static let maxImportFileSize = 10 * 1024 * 1024

        /// CSV field separator
        public static let csvSeparator = ","

        /// JSON export formatting options
        public static let jsonDateFormat = "iso8601"

        /// Maximum records per export batch
        public static let maxExportBatchSize = 5000
    }

    /// Authentication and security timeouts
    public enum Authentication {
        /// Standard access token lifetime (1 hour in seconds)
        public static let accessTokenLifetime: TimeInterval = 3600

        /// Anonymous session lifetime (24 hours in seconds)
        public static let anonymousSessionLifetime: TimeInterval = 86400

        /// Demo session lifetime (1 hour in seconds)
        public static let demoSessionLifetime: TimeInterval = 3600

        /// Token refresh buffer time (5 minutes in seconds)
        public static let tokenRefreshBuffer: TimeInterval = 300
    }

    /// Performance and monitoring thresholds
    public enum Performance {
        /// Maximum items to load per page in lists
        public static let itemsPerPage = 25

        /// Thumbnail generation timeout (10 seconds)
        public static let thumbnailTimeout: TimeInterval = 10

        /// Database query timeout (30 seconds)
        public static let databaseTimeout: TimeInterval = 30

        /// Background task execution limit (25 seconds)
        public static let backgroundTaskLimit: TimeInterval = 25
    }

    /// App Store Connect submission settings
    public enum AppStoreConnect {
        /// Progress percentage for configuring submission (80%)
        public static let configurationProgress: Double = 80

        /// Progress percentage for submitting for review (90%)
        public static let submissionProgress: Double = 90

        /// Progress percentage for completion (100%)
        public static let completionProgress: Double = 100

        /// Maximum keywords allowed (100 characters total)
        public static let maxKeywordCharacters = 100

        /// Maximum screenshot file size (10MB in bytes)
        public static let maxScreenshotFileSize = 10 * 1024 * 1024
    }
}

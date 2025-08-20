//
// Layer: Foundation
// Module: Core/Constants
// Purpose: Test data constants for consistent test values across test files
//

import Foundation

/// Test constants for consistent values across test files
public enum TestConstants {
    /// Sample monetary values for testing
    public enum Money {
        /// Small test value ($100)
        public static let small: Decimal = 100

        /// Medium test value ($250)
        public static let medium: Decimal = 250

        /// Large test value ($1000)
        public static let large: Decimal = 1000

        /// Extra large test value ($5000)
        public static let extraLarge: Decimal = 5000

        /// Maximum test value for edge cases ($10000)
        public static let maximum: Decimal = 10000
    }

    /// Sample quantities for testing
    public enum Quantity {
        /// Single item
        public static let single = 1

        /// Small quantity (2)
        public static let small = 2

        /// Medium quantity (5)
        public static let medium = 5

        /// Large quantity (10)
        public static let large = 10

        /// Bulk quantity (25)
        public static let bulk = 25

        /// Maximum reasonable quantity (100)
        public static let maximum = 100
    }

    /// Sample counts for collections and lists
    public enum Count {
        /// Empty collection
        public static let empty = 0

        /// Single item
        public static let one = 1

        /// Few items (3)
        public static let few = 3

        /// Several items (5)
        public static let several = 5

        /// Many items (10)
        public static let many = 10

        /// Large collection (25)
        public static let large = 25

        /// Very large collection (100)
        public static let veryLarge = 100

        /// Maximum test collection size (1000)
        public static let maximum = 1000
    }

    /// Sample text lengths for validation testing
    public enum TextLength {
        /// Short text (10 characters)
        public static let short = 10

        /// Medium text (50 characters)
        public static let medium = 50

        /// Long text (100 characters)
        public static let long = 100

        /// Very long text (500 characters)
        public static let veryLong = 500

        /// Maximum text length (1000 characters)
        public static let maximum = 1000
    }

    /// Sample IDs for testing
    public enum SampleID {
        /// Sample item ID
        public static let item = UUID(uuidString: "12345678-1234-1234-1234-123456789abc")!

        /// Sample category ID
        public static let category = UUID(uuidString: "87654321-4321-4321-4321-cba987654321")!

        /// Sample user ID
        public static let user = UUID(uuidString: "abcdefab-cdef-abcd-efab-cdefabcdefab")!

        /// Sample organization ID
        public static let organization = UUID(uuidString: "fedcbafe-dcba-fedc-bafe-dcbafedcbafe")!
    }

    /// Sample strings for testing
    public enum SampleText {
        /// Sample item name
        public static let itemName = "Test Item"

        /// Sample item description
        public static let itemDescription = "This is a sample item for testing purposes"

        /// Sample brand name
        public static let brand = "Test Brand"

        /// Sample model number
        public static let model = "TEST-123"

        /// Sample serial number
        public static let serial = "SN123456789"

        /// Sample category name
        public static let categoryName = "Test Category"

        /// Sample location name
        public static let locationName = "Test Location"
    }

    /// Performance test thresholds
    public enum Performance {
        /// Fast operation threshold (0.1 seconds)
        public static let fastThreshold: TimeInterval = 0.1

        /// Reasonable operation threshold (1 second)
        public static let reasonableThreshold: TimeInterval = 1.0

        /// Slow operation threshold (5 seconds)
        public static let slowThreshold: TimeInterval = 5.0

        /// Maximum acceptable operation time (30 seconds)
        public static let maxThreshold: TimeInterval = 30.0
    }
}

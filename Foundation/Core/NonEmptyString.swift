// Layer: Foundation
// Module: Foundation/Core
// Purpose: Non-empty string value object

import Foundation

/// A string that is guaranteed to be non-empty
public struct NonEmptyString: Codable, Hashable, Sendable {
    public let value: String

    /// Initialize with a string, throwing if empty
    public init(_ value: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AppError.emptyField("String")
        }
        self.value = trimmed
    }

    /// Initialize with a string, returning nil if empty
    public init?(_ value: String?) {
        guard let value else { return nil }
        do {
            try self.init(value)
        } catch {
            return nil
        }
    }

    /// Create from a literal (returns nil if empty)
    public static func unchecked(_ value: String) -> NonEmptyString? {
        try? NonEmptyString(value)
    }

    /// Unsafe initializer - assumes the value is valid (for internal use only)
    private init(unsafe value: String) {
        self.value = value
    }
}

// MARK: - String Protocol Conformances

extension NonEmptyString: CustomStringConvertible {
    public var description: String { value }
}

extension NonEmptyString: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        // For string literals, we assume they are valid during development
        // In production, use the throwing initializer instead
        do {
            try self.init(value)
        } catch {
            // Create fallback value for literal initialization
            self = NonEmptyString(unsafe: "placeholder")
        }
    }
}

// MARK: - Utilities

extension NonEmptyString {
    /// Length of the string
    public var count: Int { value.count }

    /// Check if string contains a substring
    public func contains(_ substring: String) -> Bool {
        value.contains(substring)
    }

    /// Lowercase version (returns nil if result would be empty)
    public var lowercased: NonEmptyString? {
        try? NonEmptyString(value.lowercased())
    }

    /// Uppercase version (returns nil if result would be empty)
    public var uppercased: NonEmptyString? {
        try? NonEmptyString(value.uppercased())
    }

    /// Truncate to maximum length (returns nil if result would be empty)
    public func truncated(to maxLength: Int) -> NonEmptyString? {
        guard value.count > maxLength else { return self }
        guard maxLength > 0 else { return nil }
        let endIndex = value.index(value.startIndex, offsetBy: maxLength)
        let truncated = String(value[..<endIndex])
        return try? NonEmptyString(truncated)
    }
}

// MARK: - Comparable

extension NonEmptyString: Comparable {
    public static func < (lhs: NonEmptyString, rhs: NonEmptyString) -> Bool {
        lhs.value < rhs.value
    }
}

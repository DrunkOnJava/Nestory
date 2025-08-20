// Layer: Foundation
// Module: Foundation/Core
// Purpose: URL-safe slug value object

import Foundation

/// A URL-safe slug (lowercase, alphanumeric with hyphens)
public struct Slug: Codable, Hashable, Sendable {
    public let value: String

    /// Initialize with a string, converting to slug format
    public init(_ value: String) throws {
        let slug = Slug.slugify(value)
        guard !slug.isEmpty else {
            throw AppError.invalidFormat(field: "Slug", expectedFormat: "alphanumeric with hyphens")
        }
        self.value = slug
    }

    /// Create from an already-valid slug (returns nil if invalid)
    public static func unchecked(_ value: String) -> Slug? {
        try? Slug(value)
    }

    /// Unsafe initializer - assumes the value is valid (for internal use only)
    private init(unsafe value: String) {
        self.value = value
    }

    /// Convert any string to slug format
    private static func slugify(_ string: String) -> String {
        // Convert to lowercase
        var slug = string.lowercased()

        // Replace spaces and underscores with hyphens
        slug = slug.replacingOccurrences(of: " ", with: "-")
        slug = slug.replacingOccurrences(of: "_", with: "-")

        // Remove any character that isn't alphanumeric or hyphen
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        slug = slug.unicodeScalars.filter { allowed.contains($0) }.map { String($0) }.joined()

        // Replace multiple hyphens with single hyphen
        while slug.contains("--") {
            slug = slug.replacingOccurrences(of: "--", with: "-")
        }

        // Remove leading and trailing hyphens
        slug = slug.trimmingCharacters(in: CharacterSet(charactersIn: "-"))

        return slug
    }

    /// Validate if a string is a valid slug
    public static func isValid(_ string: String) -> Bool {
        let pattern = "^[a-z0-9]+(?:-[a-z0-9]+)*$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: string.utf16.count)
        return regex?.firstMatch(in: string, options: [], range: range) != nil
    }
}

// MARK: - String Protocol Conformances

extension Slug: CustomStringConvertible {
    public var description: String { value }
}

extension Slug: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        // For string literals, we assume they are valid during development
        // In production, use the throwing initializer instead
        do {
            try self.init(value)
        } catch {
            // Create empty slug as fallback for literal initialization
            self = Slug(unsafe: "empty")
        }
    }
}

// MARK: - Comparable

extension Slug: Comparable {
    public static func < (lhs: Slug, rhs: Slug) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - Utilities

extension Slug {
    /// Generate a random slug with optional prefix
    public static func random(prefix: String? = nil, length: Int = 8) -> Slug? {
        let characters = "abcdefghijklmnopqrstuvwxyz0123456789"
        let random = (0 ..< length).compactMap { _ in
            characters.randomElement().map(String.init)
        }.joined()

        guard random.count == length else { return nil }

        let value = prefix.map { "\($0)-\(random)" } ?? random
        return try? Slug(value)
    }

    /// Append a suffix to the slug
    public func appending(_ suffix: String) -> Slug? {
        try? Slug("\(value)-\(suffix)")
    }

    /// Prepend a prefix to the slug
    public func prepending(_ prefix: String) -> Slug? {
        try? Slug("\(prefix)-\(value)")
    }
}

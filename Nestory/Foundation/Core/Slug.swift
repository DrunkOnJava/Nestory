// Layer: Foundation

import Foundation

public struct Slug: Equatable, Hashable, Codable, Sendable {
    public let value: String

    public init(_ value: String) throws {
        let slugified = Slug.slugify(value)
        guard !slugified.isEmpty else {
            throw AppError.validation(field: "slug", reason: "Cannot create slug from empty string")
        }
        guard slugified.count >= 2 else {
            throw AppError.validation(field: "slug", reason: "Slug must be at least 2 characters")
        }
        guard slugified.count <= 100 else {
            throw AppError.validation(field: "slug", reason: "Slug must be at most 100 characters")
        }
        self.value = slugified
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(string)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }

    private static func slugify(_ input: String) -> String {
        let lowercased = input.lowercased()
        let alphanumeric = lowercased.replacingOccurrences(
            of: "[^a-z0-9\\s-]",
            with: "",
            options: .regularExpression
        )
        let hyphenated = alphanumeric.replacingOccurrences(
            of: "[\\s]+",
            with: "-",
            options: .regularExpression
        )
        let trimmed = hyphenated.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        let deduplicated = trimmed.replacingOccurrences(
            of: "-+",
            with: "-",
            options: .regularExpression
        )
        return deduplicated
    }
}

extension Slug: CustomStringConvertible {
    public var description: String {
        value
    }
}

extension Slug: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        do {
            try self.init(value)
        } catch {
            fatalError("Invalid Slug literal: \(value)")
        }
    }
}

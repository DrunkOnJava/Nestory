// Layer: Foundation

import Foundation

public struct NonEmptyString: Equatable, Hashable, Codable, Sendable {
    public let value: String

    public init(_ value: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AppError.validation(field: "string", reason: "String cannot be empty")
        }
        self.value = trimmed
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
}

extension NonEmptyString: CustomStringConvertible {
    public var description: String {
        value
    }
}

extension NonEmptyString: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        do {
            try self.init(value)
        } catch {
            fatalError("Invalid NonEmptyString literal: \(value)")
        }
    }
}

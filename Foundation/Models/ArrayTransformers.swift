//
// Layer: Foundation
// Module: Models/ArrayTransformers
// Purpose: Utilities for transforming arrays and collections for SwiftData persistence
//

import Foundation

// MARK: - Array Transform Protocols

public protocol ArrayTransformer {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: [Input]) -> [Output]
    func reverseTransform(_ output: [Output]) -> [Input]
}

// MARK: - Common Array Transformers

public struct StringArrayTransformer: ArrayTransformer {
    public typealias Input = String
    public typealias Output = String
    
    public init() {}
    
    public func transform(_ input: [String]) -> [String] {
        return input.compactMap { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                   .filter { !$0.isEmpty }
    }
    
    public func reverseTransform(_ output: [String]) -> [String] {
        return output
    }
}

public struct URLArrayTransformer: ArrayTransformer {
    public typealias Input = URL
    public typealias Output = String
    
    public init() {}
    
    public func transform(_ input: [URL]) -> [String] {
        return input.map { $0.absoluteString }
    }
    
    public func reverseTransform(_ output: [String]) -> [URL] {
        return output.compactMap { URL(string: $0) }
    }
}

public struct PhotoPathArrayTransformer: ArrayTransformer {
    public typealias Input = String
    public typealias Output = String
    
    public init() {}
    
    public func transform(_ input: [String]) -> [String] {
        return input.compactMap { path in
            // Ensure the path is valid and points to an accessible file
            guard !path.isEmpty else { return nil }
            let url = URL(fileURLWithPath: path)
            return FileManager.default.fileExists(atPath: url.path) ? path : nil
        }
    }
    
    public func reverseTransform(_ output: [String]) -> [String] {
        return output
    }
}

// MARK: - Collection Extensions for SwiftData

public extension Array where Element == String {
    
    /// Converts an array of strings to a single comma-separated string for storage
    var commaSeparatedString: String {
        return self.joined(separator: ",")
    }
    
    /// Creates an array of strings from a comma-separated string
    static func from(commaSeparatedString: String) -> [String] {
        guard !commaSeparatedString.isEmpty else { return [] }
        return commaSeparatedString.components(separatedBy: ",")
                                 .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                 .filter { !$0.isEmpty }
    }
    
    /// Converts to a JSON string for complex storage scenarios
    var jsonString: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// Creates an array from a JSON string
    static func from(jsonString: String) -> [String] {
        guard let data = jsonString.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: data) as? [String] else {
            return []
        }
        return array
    }
}

public extension Array where Element: Codable {
    
    /// Converts a codable array to JSON data for persistence
    var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    /// Creates an array from JSON data
    static func from(jsonData: Data) -> [Element] {
        guard let array = try? JSONDecoder().decode([Element].self, from: jsonData) else {
            return []
        }
        return array
    }
    
    /// Converts a codable array to a base64 encoded string
    var base64String: String? {
        guard let data = jsonData else { return nil }
        return data.base64EncodedString()
    }
    
    /// Creates an array from a base64 encoded string
    static func from(base64String: String) -> [Element] {
        guard let data = Data(base64Encoded: base64String) else { return [] }
        return from(jsonData: data)
    }
}

// MARK: - SwiftData Compatible Transformers

/// A transformer that converts arrays to strings for SwiftData storage
public struct ArrayToStringTransformer<T: Codable> {
    
    public init() {}
    
    public func encode(_ array: [T]) -> String {
        guard let data = try? JSONEncoder().encode(array),
              let string = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return string
    }
    
    public func decode(_ string: String) -> [T] {
        guard let data = string.data(using: .utf8),
              let array = try? JSONDecoder().decode([T].self, from: data) else {
            return []
        }
        return array
    }
}

/// A transformer specifically for photo arrays
public struct PhotoArrayTransformer {
    
    public init() {}
    
    public func encode(_ photos: [PhotoReference]) -> String {
        let transformer = ArrayToStringTransformer<PhotoReference>()
        return transformer.encode(photos)
    }
    
    public func decode(_ string: String) -> [PhotoReference] {
        let transformer = ArrayToStringTransformer<PhotoReference>()
        return transformer.decode(string)
    }
}

/// A transformer for tag arrays
public struct TagArrayTransformer {
    
    public init() {}
    
    public func encode(_ tags: [String]) -> String {
        return tags.joined(separator: ",")
    }
    
    public func decode(_ string: String) -> [String] {
        guard !string.isEmpty else { return [] }
        return string.components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
    }
}

// MARK: - Photo Reference Model

public struct PhotoReference: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public let filename: String
    public let path: String
    public let thumbnailPath: String?
    public let createdAt: Date
    public let fileSize: Int64
    
    public init(
        id: UUID = UUID(),
        filename: String,
        path: String,
        thumbnailPath: String? = nil,
        createdAt: Date = Date(),
        fileSize: Int64 = 0
    ) {
        self.id = id
        self.filename = filename
        self.path = path
        self.thumbnailPath = thumbnailPath
        self.createdAt = createdAt
        self.fileSize = fileSize
    }
    
    public var exists: Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    public var url: URL {
        return URL(fileURLWithPath: path)
    }
    
    public var thumbnailURL: URL? {
        guard let thumbnailPath = thumbnailPath else { return nil }
        return URL(fileURLWithPath: thumbnailPath)
    }
}

// MARK: - Collection Validation

public extension Array {
    
    /// Removes duplicate elements based on a key path
    func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { element in
            let key = element[keyPath: keyPath]
            return seen.insert(key).inserted
        }
    }
    
    /// Safely accesses an element at the given index
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension Array where Element: Identifiable {
    
    /// Removes duplicates based on id
    func removingDuplicates() -> [Element] {
        return removingDuplicates(by: \.id)
    }
    
    /// Updates or inserts an element based on its id
    mutating func upsert(_ element: Element) {
        if let index = firstIndex(where: { $0.id == element.id }) {
            self[index] = element
        } else {
            append(element)
        }
    }
    
    /// Removes an element by its id
    mutating func remove(id: Element.ID) {
        removeAll { $0.id == id }
    }
}

// MARK: - Array Chunking for Performance

public extension Array {
    
    /// Splits the array into chunks of the specified size
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Sorting Extensions

public extension Array where Element: Comparable {
    
    /// Returns a sorted copy of the array
    func sorted() -> [Element] {
        return sorted(by: <)
    }
}

public extension Array {
    
    /// Sorts the array by multiple criteria
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, ascending: Bool = true) -> [Element] {
        return sorted { lhs, rhs in
            let lhsValue = lhs[keyPath: keyPath]
            let rhsValue = rhs[keyPath: keyPath]
            return ascending ? lhsValue < rhsValue : lhsValue > rhsValue
        }
    }
    
    /// Sorts by multiple key paths with different sort orders
    func sorted<T: Comparable, U: Comparable>(
        by firstKeyPath: KeyPath<Element, T>,
        ascending firstAscending: Bool = true,
        then secondKeyPath: KeyPath<Element, U>,
        ascending secondAscending: Bool = true
    ) -> [Element] {
        return sorted { lhs, rhs in
            let firstLhs = lhs[keyPath: firstKeyPath]
            let firstRhs = rhs[keyPath: firstKeyPath]
            
            if firstLhs == firstRhs {
                let secondLhs = lhs[keyPath: secondKeyPath]
                let secondRhs = rhs[keyPath: secondKeyPath]
                return secondAscending ? secondLhs < secondRhs : secondLhs > secondRhs
            }
            
            return firstAscending ? firstLhs < firstRhs : firstLhs > firstRhs
        }
    }
}

// MARK: - Mock Data for Testing

#if DEBUG
public extension Array where Element == PhotoReference {
    static let mockPhotos: [PhotoReference] = [
        PhotoReference(
            filename: "IMG_001.jpg",
            path: "/mock/path/IMG_001.jpg",
            thumbnailPath: "/mock/path/thumbnails/IMG_001_thumb.jpg",
            fileSize: 2048576
        ),
        PhotoReference(
            filename: "IMG_002.jpg",
            path: "/mock/path/IMG_002.jpg",
            thumbnailPath: "/mock/path/thumbnails/IMG_002_thumb.jpg",
            fileSize: 1843200
        )
    ]
}

public extension Array where Element == String {
    static let mockTags: [String] = ["Electronics", "High Value", "Warranty", "Gift"]
    static let mockCategories: [String] = ["Electronics", "Furniture", "Jewelry", "Appliances"]
    static let mockRooms: [String] = ["Living Room", "Bedroom", "Kitchen", "Office", "Garage"]
}
#endif
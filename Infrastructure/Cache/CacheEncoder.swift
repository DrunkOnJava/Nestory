//
// Layer: Infrastructure
// Module: Cache
// Purpose: Encoding and decoding utilities for cache storage
//

import Foundation
import UIKit

struct CacheEncoder<Value> {
    
    func encode(_ value: Value) -> Data? {
        if let data = value as? Data {
            return data
        }
        
        if let codable = value as? any Codable {
            return try? JSONEncoder().encode(AnyEncodable(codable))
        }
        
        if let image = value as? UIImage {
            return image.jpegData(compressionQuality: 0.8)
        }
        
        return nil
    }
    
    func decode(_ data: Data, type: Value.Type) -> Value? {
        if type == Data.self {
            return data as? Value
        }
        
        if let decodableType = type as? any Decodable.Type {
            return (try? JSONDecoder().decode(decodableType, from: data)) as? Value
        }
        
        if type == UIImage.self {
            return UIImage(data: data) as? Value
        }
        
        return nil
    }
}

// MARK: - Type Erasure Helper

private struct AnyEncodable: Encodable {
    private let _encode: (any Encoder) throws -> Void
    
    init(_ wrapped: any Encodable) {
        _encode = wrapped.encode
    }
    
    func encode(to encoder: any Encoder) throws {
        try _encode(encoder)
    }
}

// MARK: - Specialized Encoders

extension CacheEncoder {
    
    static func encodeImage(_ image: UIImage, compressionQuality: CGFloat = 0.8) -> Data? {
        // Try JPEG first for photos
        if let jpegData = image.jpegData(compressionQuality: compressionQuality) {
            return jpegData
        }
        
        // Fall back to PNG for images with transparency
        return image.pngData()
    }
    
    static func decodeImage(from data: Data) -> UIImage? {
        UIImage(data: data)
    }
    
    static func encodeCodable<T: Codable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(value)
    }
    
    static func decodeCodable<T: Codable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: data)
    }
}
// Layer: Foundation
// Module: Foundation/Models
// Purpose: Photo asset model for item images

import Foundation
import SwiftData

/// Photo asset attached to an item
@Model
public final class PhotoAsset {
    // MARK: - Properties

    @Attribute(.unique)
    public var id: UUID

    public var fileName: String
    public var thumbnailFileName: String?
    public var width: Int
    public var height: Int
    public var fileSize: Int64 // in bytes
    public var mimeType: String
    public var perceptualHash: Int64? // For duplicate detection
    public var caption: String?
    public var sortOrder: Int

    // Timestamps
    public var capturedAt: Date?
    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Relationships

    @Relationship(inverse: \Item.photos)
    public var item: Item?

    // MARK: - Initialization

    public init(
        fileName: String,
        width: Int,
        height: Int,
        fileSize: Int64,
        mimeType: String = "image/jpeg",
        item: Item? = nil
    ) {
        id = UUID()
        self.fileName = fileName
        self.width = width
        self.height = height
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.item = item
        sortOrder = 0
        createdAt = Date()
        updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// Aspect ratio of the image
    public var aspectRatio: Double {
        guard height > 0 else { return 1.0 }
        return Double(width) / Double(height)
    }

    /// Human-readable file size
    public var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }

    /// Check if image is landscape orientation
    public var isLandscape: Bool {
        width > height
    }

    /// Check if image is portrait orientation
    public var isPortrait: Bool {
        height > width
    }

    /// Check if image is square
    public var isSquare: Bool {
        width == height
    }

    /// Resolution in megapixels
    public var megapixels: Double {
        Double(width * height) / 1_000_000
    }

    /// Formatted resolution string
    public var formattedResolution: String {
        "\(width) × \(height)"
    }

    // MARK: - Methods

    /// Update photo properties
    public func update(
        caption: String? = nil,
        sortOrder: Int? = nil
    ) {
        if let caption {
            self.caption = caption
        }
        if let sortOrder {
            self.sortOrder = sortOrder
        }
        updatedAt = Date()
    }

    /// Set perceptual hash for duplicate detection
    public func setPerceptualHash(_ hash: Int64) {
        perceptualHash = hash
        updatedAt = Date()
    }

    /// Calculate Hamming distance between two perceptual hashes
    public static func hammingDistance(_ hash1: Int64, _ hash2: Int64) -> Int {
        var xor = hash1 ^ hash2
        var count = 0
        while xor != 0 {
            count += 1
            xor &= xor - 1
        }
        return count
    }

    /// Check if this photo is likely a duplicate of another
    public func isDuplicate(of other: PhotoAsset, threshold: Int = 5) -> Bool {
        guard let hash1 = perceptualHash,
              let hash2 = other.perceptualHash
        else {
            return false
        }
        return PhotoAsset.hammingDistance(hash1, hash2) <= threshold
    }
}

// MARK: - Comparable

extension PhotoAsset: Comparable {
    public static func < (lhs: PhotoAsset, rhs: PhotoAsset) -> Bool {
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        return lhs.createdAt < rhs.createdAt
    }
}

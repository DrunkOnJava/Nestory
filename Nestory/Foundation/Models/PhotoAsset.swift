// Layer: Foundation

import Foundation
import SwiftData

@Model
public final class PhotoAsset {
    @Attribute(.unique) public var id: UUID
    public var fileName: String
    public var width: Int
    public var height: Int
    public var sizeInBytes: Int64
    public var mimeType: String
    public var thumbnailFileName: String?
    public var caption: String?
    public var sortOrder: Int

    @Relationship(deleteRule: .nullify)
    public var item: Item?

    public var createdAt: Date
    public var updatedAt: Date

    public init(
        fileName: String,
        width: Int,
        height: Int,
        sizeInBytes: Int64,
        mimeType: String = "image/jpeg",
        caption: String? = nil,
        sortOrder: Int = 0
    ) throws {
        guard width > 0, height > 0 else {
            throw AppError.validation(field: "dimensions", reason: "Width and height must be positive")
        }
        guard sizeInBytes > 0 else {
            throw AppError.validation(field: "size", reason: "File size must be positive")
        }

        id = UUID()
        self.fileName = fileName
        self.width = width
        self.height = height
        self.sizeInBytes = sizeInBytes
        self.mimeType = mimeType
        self.caption = caption
        self.sortOrder = sortOrder
        createdAt = Date()
        updatedAt = Date()
    }

    public var aspectRatio: Double {
        Double(width) / Double(height)
    }

    public var isPortrait: Bool {
        height > width
    }

    public var isLandscape: Bool {
        width > height
    }

    public var isSquare: Bool {
        width == height
    }

    public var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: sizeInBytes)
    }

    public var dimensions: String {
        "\(width) × \(height)"
    }
}

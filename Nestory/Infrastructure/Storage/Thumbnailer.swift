// Layer: Infrastructure

import CoreGraphics
import Foundation
import os.log
import UIKit

public final class Thumbnailer {
    private let thumbnailSize: CGFloat = 150
    private let displaySize: CGFloat = 800
    private let imageIO: ImageIO
    private let logger = Logger(subsystem: "com.nestory", category: "Thumbnailer")

    public init(imageIO: ImageIO? = nil) {
        self.imageIO = imageIO ?? ImageIO()
    }

    public func generateThumbnail(from image: UIImage) async throws -> UIImage {
        await Task.detached(priority: .userInitiated) {
            let startTime = CFAbsoluteTimeGetCurrent()

            let size = image.size
            let targetSize = self.thumbnailSize

            let widthRatio = targetSize / size.width
            let heightRatio = targetSize / size.height
            let ratio = min(widthRatio, heightRatio)

            let newSize = CGSize(
                width: size.width * ratio,
                height: size.height * ratio
            )

            let format = UIGraphicsImageRendererFormat()
            format.scale = 1.0
            format.opaque = false

            let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
            let thumbnail = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }

            let duration = CFAbsoluteTimeGetCurrent() - startTime
            self.logger.debug("Generated thumbnail in \(String(format: "%.3f", duration))s")

            return thumbnail
        }.value
    }

    public func generateDisplayImage(from image: UIImage) async throws -> UIImage {
        await Task.detached(priority: .userInitiated) {
            let startTime = CFAbsoluteTimeGetCurrent()

            let size = image.size
            let targetSize = self.displaySize

            guard size.width > targetSize || size.height > targetSize else {
                return image
            }

            let widthRatio = targetSize / size.width
            let heightRatio = targetSize / size.height
            let ratio = min(widthRatio, heightRatio)

            let newSize = CGSize(
                width: size.width * ratio,
                height: size.height * ratio
            )

            let format = UIGraphicsImageRendererFormat()
            format.scale = 1.0
            format.opaque = false

            let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
            let displayImage = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }

            let duration = CFAbsoluteTimeGetCurrent() - startTime
            self.logger.debug("Generated display image in \(String(format: "%.3f", duration))s")

            return displayImage
        }.value
    }

    public func generateThumbnail(from url: URL) async throws -> UIImage {
        let image = try await imageIO.loadImage(from: url)
        return try await generateThumbnail(from: image)
    }

    public func generateDisplayImage(from url: URL) async throws -> UIImage {
        let image = try await imageIO.loadImage(from: url)
        return try await generateDisplayImage(from: image)
    }

    public func generateThumbnail(from data: Data) async throws -> UIImage {
        let image = try await imageIO.loadImage(from: data)
        return try await generateThumbnail(from: image)
    }

    public func generateDisplayImage(from data: Data) async throws -> UIImage {
        let image = try await imageIO.loadImage(from: data)
        return try await generateDisplayImage(from: image)
    }

    public func processImage(from url: URL) async throws -> ProcessedImages {
        let image = try await imageIO.loadImage(from: url)

        async let thumbnail = generateThumbnail(from: image)
        async let display = generateDisplayImage(from: image)

        return try await ProcessedImages(
            original: image,
            thumbnail: thumbnail,
            display: display
        )
    }

    public func processImage(from data: Data) async throws -> ProcessedImages {
        let image = try await imageIO.loadImage(from: data)

        async let thumbnail = generateThumbnail(from: image)
        async let display = generateDisplayImage(from: image)

        return try await ProcessedImages(
            original: image,
            thumbnail: thumbnail,
            display: display
        )
    }

    public func saveThumbnail(_ thumbnail: UIImage, to url: URL) async throws {
        try await imageIO.saveImage(thumbnail, to: url, format: .jpeg)
    }

    public func saveDisplayImage(_ displayImage: UIImage, to url: URL) async throws {
        try await imageIO.saveImage(displayImage, to: url, format: .jpeg)
    }

    public func batchGenerateThumbnails(from urls: [URL]) async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: (Int, UIImage).self) { group in
            for (index, url) in urls.enumerated() {
                group.addTask {
                    let thumbnail = try await self.generateThumbnail(from: url)
                    return (index, thumbnail)
                }
            }

            var thumbnails = [UIImage?](repeating: nil, count: urls.count)
            for try await (index, thumbnail) in group {
                thumbnails[index] = thumbnail
            }

            return thumbnails.compactMap { $0 }
        }
    }

    public func estimateMemoryUsage(for image: UIImage) -> Int {
        let pixelCount = Int(image.size.width * image.scale) * Int(image.size.height * image.scale)
        let bytesPerPixel = 4
        return pixelCount * bytesPerPixel
    }
}

public struct ProcessedImages {
    public let original: UIImage
    public let thumbnail: UIImage
    public let display: UIImage

    public var thumbnailData: Data? {
        thumbnail.jpegData(compressionQuality: 0.8)
    }

    public var displayData: Data? {
        display.jpegData(compressionQuality: 0.85)
    }

    public var estimatedMemoryUsage: Int {
        let thumbnailer = Thumbnailer()
        return thumbnailer.estimateMemoryUsage(for: original) +
            thumbnailer.estimateMemoryUsage(for: thumbnail) +
            thumbnailer.estimateMemoryUsage(for: display)
    }
}

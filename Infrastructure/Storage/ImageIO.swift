// Layer: Infrastructure

import CoreImage
import Foundation
import ImageIO
import os.log
import UIKit
import UniformTypeIdentifiers

public final class ImageIO: @unchecked Sendable {
    private let logger = Logger(subsystem: "com.nestory", category: "ImageIO")
    private let context: CIContext
    private let compressionQuality: CGFloat

    public init(compressionQuality: CGFloat = 0.85) {
        self.compressionQuality = compressionQuality
        context = CIContext(options: [
            .useSoftwareRenderer: false,
            .highQualityDownsample: true,
        ])
    }

    public nonisolated func loadImage(from url: URL) async throws -> UIImage {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw ImageError.cannotLoadImage(url.lastPathComponent)
        }

        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: true,
            kCGImageSourceShouldAllowFloat: true,
        ]

        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, options as CFDictionary) else {
            throw ImageError.cannotDecodeImage
        }

        let orientation = getOrientation(from: imageSource)
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
    }

    public nonisolated func loadImage(from data: Data) async throws -> UIImage {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw ImageError.invalidImageData
        }

        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
            kCGImageSourceShouldAllowFloat: true,
        ]

        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, options as CFDictionary) else {
            throw ImageError.cannotDecodeImage
        }

        let orientation = getOrientation(from: imageSource)
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
    }

    public nonisolated func saveImage(_ image: UIImage, to url: URL, format: ImageFormat = .jpeg) async throws {
        let data = try encodeImage(image, format: format)
        try data.write(to: url, options: .atomic)
        logger.debug("Saved image to \(url.lastPathComponent)")
    }

    public nonisolated func encodeImage(_ image: UIImage, format: ImageFormat) throws -> Data {
        switch format {
        case .jpeg:
            guard let data = image.jpegData(compressionQuality: compressionQuality) else {
                throw ImageError.cannotEncodeImage
            }
            return data

        case .heic:
            guard let cgImage = image.cgImage else {
                throw ImageError.cannotEncodeImage
            }

            let data = NSMutableData()
            guard let destination = CGImageDestinationCreateWithData(
                data as CFMutableData,
                UTType.heic.identifier as CFString,
                1,
                nil
            ) else {
                throw ImageError.cannotEncodeImage
            }

            let options: [CFString: Any] = [
                kCGImageDestinationLossyCompressionQuality: compressionQuality,
            ]

            CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)

            guard CGImageDestinationFinalize(destination) else {
                throw ImageError.cannotEncodeImage
            }

            return data as Data

        case .png:
            guard let data = image.pngData() else {
                throw ImageError.cannotEncodeImage
            }
            return data
        }
    }

    public nonisolated func resizeImage(_ image: UIImage, maxDimension: CGFloat) async throws -> UIImage {
        let size = image.size

        guard size.width > maxDimension || size.height > maxDimension else {
            return image
        }

        let scale: CGFloat = if size.width > size.height {
            maxDimension / size.width
        } else {
            maxDimension / size.height
        }

        let newSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    public nonisolated func cropImage(_ image: UIImage, to rect: CGRect) async throws -> UIImage {
        guard let cgImage = image.cgImage else {
            throw ImageError.cannotProcessImage
        }

        let scale = image.scale
        let scaledRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.size.width * scale,
            height: rect.size.height * scale
        )

        guard let croppedCGImage = cgImage.cropping(to: scaledRect) else {
            throw ImageError.cannotProcessImage
        }

        return UIImage(
            cgImage: croppedCGImage,
            scale: scale,
            orientation: image.imageOrientation
        )
    }

    public nonisolated func extractMetadata(from url: URL) async throws -> ImageMetadata {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw ImageError.cannotLoadImage(url.lastPathComponent)
        }

        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] else {
            throw ImageError.cannotExtractMetadata
        }

        let exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any]
        let tiff = properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any]
        let gps = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any]

        let width = properties[kCGImagePropertyPixelWidth] as? Int ?? 0
        let height = properties[kCGImagePropertyPixelHeight] as? Int ?? 0

        return ImageMetadata(
            width: width,
            height: height,
            captureDate: extractDate(from: exif, tiff: tiff),
            cameraModel: tiff?[kCGImagePropertyTIFFModel] as? String,
            lensMake: exif?[kCGImagePropertyExifLensMake] as? String,
            latitude: gps?[kCGImagePropertyGPSLatitude] as? Double,
            longitude: gps?[kCGImagePropertyGPSLongitude] as? Double,
            orientation: extractOrientation(from: properties)
        )
    }

    private nonisolated func getOrientation(from imageSource: CGImageSource) -> UIImage.Orientation {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] else {
            return .up
        }

        return extractOrientation(from: properties)
    }

    private nonisolated func extractOrientation(from properties: [CFString: Any]) -> UIImage.Orientation {
        guard let orientationValue = properties[kCGImagePropertyOrientation] as? Int32 else {
            return .up
        }

        switch CGImagePropertyOrientation(rawValue: UInt32(orientationValue)) {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        default: return .up
        }
    }

    private nonisolated func extractDate(from exif: [CFString: Any]?, tiff: [CFString: Any]?) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"

        if let dateString = exif?[kCGImagePropertyExifDateTimeOriginal] as? String {
            return dateFormatter.date(from: dateString)
        }

        if let dateString = exif?[kCGImagePropertyExifDateTimeDigitized] as? String {
            return dateFormatter.date(from: dateString)
        }

        if let dateString = tiff?[kCGImagePropertyTIFFDateTime] as? String {
            return dateFormatter.date(from: dateString)
        }

        return nil
    }
}

public enum ImageFormat {
    case jpeg
    case heic
    case png
}

public struct ImageMetadata: Sendable {
    public let width: Int
    public let height: Int
    public let captureDate: Date?
    public let cameraModel: String?
    public let lensMake: String?
    public let latitude: Double?
    public let longitude: Double?
    public let orientation: UIImage.Orientation
}

public enum ImageError: LocalizedError {
    case cannotLoadImage(String)
    case cannotDecodeImage
    case cannotEncodeImage
    case cannotProcessImage
    case invalidImageData
    case cannotExtractMetadata

    public var errorDescription: String? {
        switch self {
        case let .cannotLoadImage(filename):
            "Cannot load image: \(filename)"
        case .cannotDecodeImage:
            "Cannot decode image data"
        case .cannotEncodeImage:
            "Cannot encode image"
        case .cannotProcessImage:
            "Cannot process image"
        case .invalidImageData:
            "Invalid image data"
        case .cannotExtractMetadata:
            "Cannot extract image metadata"
        }
    }
}

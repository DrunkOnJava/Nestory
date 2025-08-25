// Layer: Infrastructure

import Accelerate
import CoreImage
import Foundation
import os.log
import UIKit

public final class PerceptualHash: @unchecked Sendable {
    private let hashSize = 8
    private let resizeSize = 32
    private let context: CIContext
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "PerceptualHash")

    public init() {
        context = CIContext(options: [
            .useSoftwareRenderer: false,
            .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
        ])
    }

    public nonisolated func hash(image: UIImage) async throws -> UInt64 {
        let startTime = CFAbsoluteTimeGetCurrent()

        let grayscale = try convertToGrayscale(image)
        let resized = try resize(grayscale, to: CGSize(width: resizeSize, height: resizeSize))
        let dctMatrix = try performDCT(resized)
        let hash = computeHash(from: dctMatrix)

        let duration = CFAbsoluteTimeGetCurrent() - startTime
        logger.debug("Computed perceptual hash in \(duration, format: .fixed(precision: 3))s")

        return hash
    }

    public func similarity(hash1: UInt64, hash2: UInt64) -> Double {
        let distance = hammingDistance(hash1, hash2)
        return 1.0 - (Double(distance) / 64.0)
    }

    public func hammingDistance(_ hash1: UInt64, _ hash2: UInt64) -> Int {
        let xor = hash1 ^ hash2
        return xor.nonzeroBitCount
    }

    public func areImagesSimilar(hash1: UInt64, hash2: UInt64, threshold: Double = 0.85) -> Bool {
        similarity(hash1: hash1, hash2: hash2) >= threshold
    }

    public func hashString(from hash: UInt64) -> String {
        String(format: "%016llx", hash)
    }

    public func hash(from string: String) -> UInt64? {
        UInt64(string, radix: 16)
    }

    private nonisolated func convertToGrayscale(_ image: UIImage) throws -> CIImage {
        guard let ciImage = CIImage(image: image) else {
            throw PerceptualHashError.invalidImage
        }

        guard let filter = CIFilter(name: "CIColorControls") else {
            throw PerceptualHashError.filterCreationFailed
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)

        guard let outputImage = filter.outputImage else {
            throw PerceptualHashError.grayscaleConversionFailed
        }

        return outputImage
    }

    private nonisolated func resize(_ image: CIImage, to size: CGSize) throws -> CIImage {
        let scaleX = size.width / image.extent.width
        let scaleY = size.height / image.extent.height

        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let scaled = image.transformed(by: transform)

        guard let cgImage = context.createCGImage(scaled, from: CGRect(origin: .zero, size: size)) else {
            throw PerceptualHashError.resizeFailed
        }

        return CIImage(cgImage: cgImage)
    }

    private nonisolated func performDCT(_ image: CIImage) throws -> [[Float]] {
        // APPLE_FRAMEWORK_OPPORTUNITY: Replace with Accelerate Framework - Use vDSP_DCT functions for hardware-accelerated discrete cosine transform computations
        let width = resizeSize
        let height = resizeSize

        guard let cgImage = context.createCGImage(image, from: CGRect(x: 0, y: 0, width: width, height: height)) else {
            throw PerceptualHashError.cgImageCreationFailed
        }

        var pixelData = [Float](repeating: 0, count: width * height)

        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)

        guard let bitmapContext = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue,
        ) else {
            throw PerceptualHashError.contextCreationFailed
        }

        bitmapContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var dctMatrix = [[Float]](repeating: [Float](repeating: 0, count: hashSize), count: hashSize)

        for u in 0 ..< hashSize {
            for v in 0 ..< hashSize {
                var sum: Float = 0

                for x in 0 ..< width {
                    for y in 0 ..< height {
                        let pixel = pixelData[y * width + x] / 255.0
                        let xFactor = (2.0 * Float(x) + 1.0) * Float(u) * .pi
                        let yFactor = (2.0 * Float(y) + 1.0) * Float(v) * .pi
                        let widthDivisor = 2.0 * Float(width)
                        let heightDivisor = 2.0 * Float(height)
                        let cosX = cos(xFactor / widthDivisor)
                        let cosY = cos(yFactor / heightDivisor)
                        sum += pixel * cosX * cosY
                    }
                }

                let cu: Float = u == 0 ? 1.0 / sqrt(2.0) : 1.0
                let cv: Float = v == 0 ? 1.0 / sqrt(2.0) : 1.0
                let coefficient = sum * cu * cv
                dctMatrix[u][v] = coefficient * 2.0 / Float(width)
            }
        }

        return dctMatrix
    }

    private nonisolated func computeHash(from dctMatrix: [[Float]]) -> UInt64 {
        var values: [Float] = []

        for u in 0 ..< hashSize {
            for v in 0 ..< hashSize {
                if u == 0, v == 0 { continue }
                values.append(dctMatrix[u][v])
            }
        }

        let median = calculateMedian(values)

        var hash: UInt64 = 0
        var bit = 0

        for u in 0 ..< hashSize {
            for v in 0 ..< hashSize {
                if u == 0, v == 0 { continue }
                if dctMatrix[u][v] > median {
                    hash |= (1 << bit)
                }
                bit += 1
                if bit >= 64 { break }
            }
            if bit >= 64 { break }
        }

        return hash
    }

    private nonisolated func calculateMedian(_ values: [Float]) -> Float {
        let sorted = values.sorted()
        let count = sorted.count

        if sorted.isEmpty {
            return 0
        } else if count % 2 == 0 {
            return (sorted[count / 2 - 1] + sorted[count / 2]) / 2.0
        } else {
            return sorted[count / 2]
        }
    }
}

public enum PerceptualHashError: LocalizedError {
    case invalidImage
    case filterCreationFailed
    case grayscaleConversionFailed
    case resizeFailed
    case cgImageCreationFailed
    case contextCreationFailed
    case dctFailed

    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            "Invalid image provided"
        case .filterCreationFailed:
            "Failed to create image filter"
        case .grayscaleConversionFailed:
            "Failed to convert image to grayscale"
        case .resizeFailed:
            "Failed to resize image"
        case .cgImageCreationFailed:
            "Failed to create CGImage"
        case .contextCreationFailed:
            "Failed to create graphics context"
        case .dctFailed:
            "Failed to perform DCT"
        }
    }
}

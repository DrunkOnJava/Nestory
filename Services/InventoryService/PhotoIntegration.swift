// Layer: Services
// Module: InventoryService
// Purpose: Photo capture and processing integration

import AVFoundation
import Foundation
import os.log
import Photos
import UIKit
import Vision

public protocol PhotoIntegrationService: Sendable {
    func capturePhoto() async throws -> UIImage
    func processPhoto(_ image: UIImage) async throws -> ProcessedPhoto
    func extractText(from image: UIImage) async throws -> [String]
    func detectObjects(in image: UIImage) async throws -> [DetectedObject]
    func generateThumbnail(from image: UIImage, size: CGSize) async throws -> UIImage
    func saveToPhotoLibrary(_ image: UIImage) async throws
    func loadFromPhotoLibrary(identifier: String) async throws -> UIImage?
}

public struct LivePhotoIntegrationService: PhotoIntegrationService, Sendable {
    private let imageIO: ImageIO
    private let thumbnailer: Thumbnailer
    private let perceptualHash: PerceptualHash
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "PhotoIntegration")

    public init() {
        imageIO = ImageIO()
        thumbnailer = Thumbnailer()
        perceptualHash = PerceptualHash()
    }

    public func capturePhoto() async throws -> UIImage {
        guard await requestCameraPermission() else {
            throw PhotoError.cameraPermissionDenied
        }

        let session = AVCaptureSession()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device)
        else {
            throw PhotoError.cameraUnavailable
        }

        session.addInput(input)

        let output = AVCapturePhotoOutput()
        session.addOutput(output)

        session.startRunning()
        defer { session.stopRunning() }

        let delegate = PhotoCaptureDelegate()
        let settings = AVCapturePhotoSettings()

        return try await withCheckedThrowingContinuation { continuation in
            delegate.continuation = continuation
            output.capturePhoto(with: settings, delegate: delegate)
        }
    }

    public nonisolated func processPhoto(_ image: UIImage) async throws -> ProcessedPhoto {
        let signpost = OSSignposter()
        let state = signpost.beginInterval("process_photo", id: signpost.makeSignpostID())
        defer { signpost.endInterval("process_photo", state) }

        async let thumbnail = generateThumbnail(from: image, size: CGSize(width: 200, height: 200))
        async let hash = perceptualHash.hash(image: image)
        async let textDetection = extractText(from: image)
        async let objectDetection = detectObjects(in: image)

        let (thumb, phash, text, objects) = try await (thumbnail, hash, textDetection, objectDetection)

        let metadata = ImageMetadata(
            width: Int(image.size.width * image.scale),
            height: Int(image.size.height * image.scale),
            captureDate: Date(),
            cameraModel: nil,
            lensMake: nil,
            latitude: nil,
            longitude: nil,
            orientation: image.imageOrientation,
        )

        return ProcessedPhoto(
            original: image,
            thumbnail: thumb,
            perceptualHash: phash,
            extractedText: text,
            detectedObjects: objects,
            metadata: metadata,
        )
    }

    public nonisolated func extractText(from image: UIImage) async throws -> [String] {
        guard let cgImage = image.cgImage else {
            throw PhotoError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: PhotoError.textExtractionFailed(error.localizedDescription))
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let texts = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }

                continuation.resume(returning: texts)
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: PhotoError.textExtractionFailed(error.localizedDescription))
            }
        }
    }

    public nonisolated func detectObjects(in image: UIImage) async throws -> [DetectedObject] {
        guard let cgImage = image.cgImage else {
            throw PhotoError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let objectRequest = VNDetectRectanglesRequest { request, error in
                if let error {
                    continuation.resume(throwing: PhotoError.objectDetectionFailed(error.localizedDescription))
                    return
                }

                guard let observations = request.results as? [VNRectangleObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let objects = observations.map { observation in
                    DetectedObject(
                        confidence: observation.confidence,
                        boundingBox: observation.boundingBox,
                        label: "Rectangle",
                    )
                }

                continuation.resume(returning: objects)
            }

            objectRequest.maximumObservations = 10
            objectRequest.minimumConfidence = 0.5

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([objectRequest])
            } catch {
                continuation.resume(throwing: PhotoError.objectDetectionFailed(error.localizedDescription))
            }
        }
    }

    public nonisolated func generateThumbnail(from image: UIImage, size: CGSize) async throws -> UIImage {
        try await thumbnailer.generate(from: image, targetSize: size)
    }

    public func saveToPhotoLibrary(_ image: UIImage) async throws {
        guard await requestPhotoLibraryPermission() else {
            throw PhotoError.photoLibraryPermissionDenied
        }

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }

        logger.info("Saved image to photo library")
    }

    public func loadFromPhotoLibrary(identifier: String) async throws -> UIImage? {
        guard await requestPhotoLibraryPermission() else {
            throw PhotoError.photoLibraryPermissionDenied
        }

        let fetchResult = PHAsset.fetchAssets(
            withLocalIdentifiers: [identifier],
            options: nil,
        )

        guard let asset = fetchResult.firstObject else {
            return nil
        }

        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat

        return try await withCheckedThrowingContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options,
            ) { image, info in
                if let error = info?[PHImageErrorKey] as? any Error {
                    continuation.resume(throwing: PhotoError.loadFailed(error.localizedDescription))
                } else if let image {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private func requestCameraPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            true
        case .notDetermined:
            await AVCaptureDevice.requestAccess(for: .video)
        default:
            false
        }
    }

    private func requestPhotoLibraryPermission() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .authorized, .limited:
            return true
        case .notDetermined:
            return await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
        default:
            return false
        }
    }
}

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    var continuation: CheckedContinuation<UIImage, any Error>?

    func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        if let error {
            continuation?.resume(throwing: PhotoError.captureFailed(error.localizedDescription))
            return
        }

        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data)
        else {
            continuation?.resume(throwing: PhotoError.invalidImage)
            return
        }

        continuation?.resume(returning: image)
    }
}

public struct ProcessedPhoto: @unchecked Sendable {
    public let original: UIImage
    public let thumbnail: UIImage
    public let perceptualHash: UInt64
    public let extractedText: [String]
    public let detectedObjects: [DetectedObject]
    public let metadata: ImageMetadata
}

public struct DetectedObject: Sendable {
    public let confidence: Float
    public let boundingBox: CGRect
    public let label: String
}

public enum PhotoError: LocalizedError, Sendable {
    case cameraPermissionDenied
    case photoLibraryPermissionDenied
    case cameraUnavailable
    case captureFailed(String)
    case invalidImage
    case textExtractionFailed(String)
    case objectDetectionFailed(String)
    case loadFailed(String)

    public var errorDescription: String? {
        switch self {
        case .cameraPermissionDenied:
            "Camera permission denied"
        case .photoLibraryPermissionDenied:
            "Photo library permission denied"
        case .cameraUnavailable:
            "Camera is not available"
        case let .captureFailed(reason):
            "Photo capture failed: \(reason)"
        case .invalidImage:
            "Invalid image data"
        case let .textExtractionFailed(reason):
            "Text extraction failed: \(reason)"
        case let .objectDetectionFailed(reason):
            "Object detection failed: \(reason)"
        case let .loadFailed(reason):
            "Failed to load image: \(reason)"
        }
    }
}

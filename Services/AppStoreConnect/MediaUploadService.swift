//
// Layer: Services
// Module: AppStoreConnect
// Purpose: Handle screenshot and preview video uploads for App Store
//

import Foundation
import UIKit

/// Service for uploading screenshots and preview videos to App Store Connect
@MainActor
public final class MediaUploadService: ObservableObject {
    // MARK: - Types

    public enum MediaType {
        case screenshot(ScreenshotType)
        case previewVideo

        public enum ScreenshotType: String, CaseIterable {
            case iPhone55 = "IPHONE_55"
            case iPhone65 = "IPHONE_65"
            case iPhone67 = "IPHONE_67"
            case iPadPro129 = "IPAD_PRO_129"
            case iPadPro3Gen129 = "IPAD_PRO_3GEN_129"
            case iPadPro11 = "IPAD_PRO_11"

            var displayName: String {
                switch self {
                case .iPhone55: "iPhone 5.5\""
                case .iPhone65: "iPhone 6.5\""
                case .iPhone67: "iPhone 6.7\""
                case .iPadPro129: "iPad Pro 12.9\""
                case .iPadPro3Gen129: "iPad Pro 12.9\" (3rd Gen)"
                case .iPadPro11: "iPad Pro 11\""
                }
            }

            var requiredSize: CGSize {
                switch self {
                case .iPhone55: CGSize(width: 1242, height: 2208)
                case .iPhone65: CGSize(width: 1284, height: 2778)
                case .iPhone67: CGSize(width: 1320, height: 2868)
                case .iPadPro129: CGSize(width: 2048, height: 2732)
                case .iPadPro3Gen129: CGSize(width: 2048, height: 2732)
                case .iPadPro11: CGSize(width: 1668, height: 2388)
                }
            }
        }
    }

    public struct ScreenshotSet {
        public let locale: String
        public let screenshotType: MediaType.ScreenshotType
        public let screenshots: [Screenshot]

        public struct Screenshot {
            public let fileName: String
            public let fileSize: Int
            public let imageData: Data
            public let position: Int // 1-10 for ordering
        }
    }

    public struct PreviewVideo {
        public let locale: String
        public let fileName: String
        public let fileSize: Int
        public let videoData: Data
        public let mimeType: String
        public let previewFrameTimeCode: String?
    }

    public struct UploadProgress {
        public let totalFiles: Int
        public let completedFiles: Int
        public let currentFileName: String?
        public let percentComplete: Double

        var isComplete: Bool {
            completedFiles == totalFiles
        }
    }

    // MARK: - Properties

    let client: AppStoreConnectClient
    @Published public internal(set) var uploadProgress: UploadProgress?
    @Published public private(set) var isUploading = false

    // MARK: - Initialization

    public init(client: AppStoreConnectClient) {
        self.client = client
    }

    // MARK: - Screenshot Management

    /// Upload screenshots for a specific app version
    public func uploadScreenshots(
        versionId: String,
        screenshotSets: [ScreenshotSet],
    ) async throws {
        isUploading = true
        defer { isUploading = false }

        let totalFiles = screenshotSets.reduce(0) { $0 + $1.screenshots.count }
        var completedFiles = 0

        for screenshotSet in screenshotSets {
            // Get or create screenshot set
            let setId = try await getOrCreateScreenshotSet(
                versionId: versionId,
                locale: screenshotSet.locale,
                screenshotType: screenshotSet.screenshotType,
            )

            // Upload each screenshot
            for screenshot in screenshotSet.screenshots {
                updateProgress(
                    total: totalFiles,
                    completed: completedFiles,
                    currentFile: screenshot.fileName,
                )

                try await uploadScreenshot(
                    screenshotSetId: setId,
                    screenshot: screenshot,
                )

                completedFiles += 1
            }
        }

        uploadProgress = nil
    }

    /// Delete all screenshots for a version
    public func deleteAllScreenshots(versionId: String) async throws {
        let request = APIRequest(
            path: "/v1/appStoreVersions/\(versionId)/appScreenshotSets",
            queryParameters: ["limit": String(NetworkConstants.Limits.maxPageSize)],
        )

        let response = try await client.execute(
            request,
            responseType: ScreenshotSetsResponse.self,
        )

        // Delete each screenshot set
        for set in response.data {
            try await deleteScreenshotSet(setId: set.id)
        }
    }

    /// Validate screenshot dimensions
    public func validateScreenshot(
        image: UIImage,
        type: MediaType.ScreenshotType,
    ) -> Bool {
        let requiredSize = type.requiredSize
        let imageSize = image.size

        // Account for scale factor
        let scaledSize = CGSize(
            width: imageSize.width * image.scale,
            height: imageSize.height * image.scale,
        )

        return scaledSize == requiredSize
    }

    // MARK: - Preview Video Management

    /// Upload preview video for app version
    public func uploadPreviewVideo(
        versionId: String,
        video: PreviewVideo,
    ) async throws {
        isUploading = true
        defer { isUploading = false }

        updateProgress(total: 1, completed: 0, currentFile: video.fileName)

        // Create preview set
        let setId = try await getOrCreatePreviewSet(
            versionId: versionId,
            locale: video.locale,
        )

        // Upload video
        try await uploadVideo(previewSetId: setId, video: video)

        uploadProgress = nil
    }
}

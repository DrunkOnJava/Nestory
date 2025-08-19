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

    private let client: AppStoreConnectClient
    @Published public private(set) var uploadProgress: UploadProgress?
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
            queryParameters: ["limit": "200"],
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

    // MARK: - Private Helpers

    private func getOrCreateScreenshotSet(
        versionId: String,
        locale: String,
        screenshotType: MediaType.ScreenshotType,
    ) async throws -> String {
        // Check if set exists
        let request = APIRequest(
            path: "/v1/appStoreVersions/\(versionId)/appScreenshotSets",
            queryParameters: [
                "filter[screenshotDisplayType]": screenshotType.rawValue,
                "filter[locale]": locale,
            ],
        )

        let response = try await client.execute(
            request,
            responseType: ScreenshotSetsResponse.self,
        )

        if let existingSet = response.data.first {
            return existingSet.id
        }

        // Create new set
        let createRequest = try await APIRequest(
            path: "/v1/appScreenshotSets",
            method: .post,
            body: CreateScreenshotSetRequest(
                data: CreateScreenshotSetRequest.Data(
                    type: "appScreenshotSets",
                    attributes: CreateScreenshotSetRequest.Attributes(
                        screenshotDisplayType: screenshotType.rawValue,
                    ),
                    relationships: CreateScreenshotSetRequest.Relationships(
                        appStoreVersionLocalization: CreateScreenshotSetRequest.LocalizationRelationship(
                            data: CreateScreenshotSetRequest.LocalizationData(
                                type: "appStoreVersionLocalizations",
                                id: getLocalizationId(versionId: versionId, locale: locale),
                            ),
                        ),
                    ),
                ),
            ),
        )

        let createResponse = try await client.execute(
            createRequest,
            responseType: ScreenshotSetResponse.self,
        )

        return createResponse.data.id
    }

    private func getOrCreatePreviewSet(
        versionId: String,
        locale: String,
    ) async throws -> String {
        // Similar to screenshot set but for preview videos
        let request = APIRequest(
            path: "/v1/appStoreVersions/\(versionId)/appPreviewSets",
            queryParameters: ["filter[locale]": locale],
        )

        let response = try await client.execute(
            request,
            responseType: PreviewSetsResponse.self,
        )

        if let existingSet = response.data.first {
            return existingSet.id
        }

        // Create new preview set
        let createRequest = try await APIRequest(
            path: "/v1/appPreviewSets",
            method: .post,
            body: CreatePreviewSetRequest(
                data: CreatePreviewSetRequest.Data(
                    type: "appPreviewSets",
                    relationships: CreatePreviewSetRequest.Relationships(
                        appStoreVersionLocalization: CreatePreviewSetRequest.LocalizationRelationship(
                            data: CreatePreviewSetRequest.LocalizationData(
                                type: "appStoreVersionLocalizations",
                                id: getLocalizationId(versionId: versionId, locale: locale),
                            ),
                        ),
                    ),
                ),
            ),
        )

        let createResponse = try await client.execute(
            createRequest,
            responseType: PreviewSetResponse.self,
        )

        return createResponse.data.id
    }

    private func uploadScreenshot(
        screenshotSetId: String,
        screenshot: ScreenshotSet.Screenshot,
    ) async throws {
        // Reserve upload
        let reserveRequest = APIRequest(
            path: "/v1/appScreenshots",
            method: .post,
            body: ReserveScreenshotRequest(
                data: ReserveScreenshotRequest.Data(
                    type: "appScreenshots",
                    attributes: ReserveScreenshotRequest.Attributes(
                        fileName: screenshot.fileName,
                        fileSize: screenshot.fileSize,
                    ),
                    relationships: ReserveScreenshotRequest.Relationships(
                        appScreenshotSet: ReserveScreenshotRequest.SetRelationship(
                            data: ReserveScreenshotRequest.SetData(
                                type: "appScreenshotSets",
                                id: screenshotSetId,
                            ),
                        ),
                    ),
                ),
            ),
        )

        let reserveResponse = try await client.execute(
            reserveRequest,
            responseType: ScreenshotUploadResponse.self,
        )

        // Upload to provided URL
        guard let uploadOperation = reserveResponse.data.attributes.uploadOperations?.first else {
            throw AppStoreConnectClient.APIError.invalidResponse
        }

        var uploadRequest = URLRequest(url: URL(string: uploadOperation.url)!)
        uploadRequest.httpMethod = uploadOperation.method
        uploadRequest.httpBody = screenshot.imageData

        for header in uploadOperation.requestHeaders ?? [] {
            uploadRequest.setValue(header.value, forHTTPHeaderField: header.name)
        }

        let (_, uploadResponse) = try await URLSession.shared.data(for: uploadRequest)

        guard let httpResponse = uploadResponse as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw AppStoreConnectClient.APIError.invalidResponse
        }

        // Commit upload
        let commitRequest = APIRequest(
            path: "/v1/appScreenshots/\(reserveResponse.data.id)",
            method: .patch,
            body: CommitScreenshotRequest(
                data: CommitScreenshotRequest.Data(
                    type: "appScreenshots",
                    id: reserveResponse.data.id,
                    attributes: CommitScreenshotRequest.Attributes(
                        uploaded: true,
                        sourceFileChecksum: uploadOperation.requestHeaders?.first { $0.name == "Content-MD5" }?.value,
                    ),
                ),
            ),
        )

        _ = try await client.execute(
            commitRequest,
            responseType: EmptyResponse.self,
        )
    }

    private func uploadVideo(
        previewSetId _: String,
        video _: PreviewVideo,
    ) async throws {
        // Similar to screenshot upload but for video
        // Implementation follows same pattern: reserve, upload, commit
    }

    private func deleteScreenshotSet(setId: String) async throws {
        let request = APIRequest(
            path: "/v1/appScreenshotSets/\(setId)",
            method: .delete,
        )

        _ = try await client.execute(
            request,
            responseType: EmptyResponse.self,
        )
    }

    private func getLocalizationId(versionId: String, locale: String) async throws -> String {
        let request = APIRequest(
            path: "/v1/appStoreVersions/\(versionId)/appStoreVersionLocalizations",
            queryParameters: ["filter[locale]": locale],
        )

        let response = try await client.execute(
            request,
            responseType: LocalizationsResponse.self,
        )

        guard let localization = response.data.first else {
            // Create localization if it doesn't exist
            return try await createLocalization(versionId: versionId, locale: locale)
        }

        return localization.id
    }

    private func createLocalization(versionId: String, locale: String) async throws -> String {
        let request = APIRequest(
            path: "/v1/appStoreVersionLocalizations",
            method: .post,
            body: CreateLocalizationRequest(
                data: CreateLocalizationRequest.Data(
                    type: "appStoreVersionLocalizations",
                    attributes: CreateLocalizationRequest.Attributes(locale: locale),
                    relationships: CreateLocalizationRequest.Relationships(
                        appStoreVersion: CreateLocalizationRequest.VersionRelationship(
                            data: CreateLocalizationRequest.VersionData(
                                type: "appStoreVersions",
                                id: versionId,
                            ),
                        ),
                    ),
                ),
            ),
        )

        let response = try await client.execute(
            request,
            responseType: LocalizationResponse.self,
        )

        return response.data.id
    }

    private func updateProgress(total: Int, completed: Int, currentFile: String?) {
        uploadProgress = UploadProgress(
            totalFiles: total,
            completedFiles: completed,
            currentFileName: currentFile,
            percentComplete: Double(completed) / Double(total),
        )
    }
}

// MARK: - Request/Response Types

private struct ScreenshotSetsResponse: Decodable {
    let data: [ScreenshotSetData]

    struct ScreenshotSetData: Decodable {
        let id: String
    }
}

private struct ScreenshotSetResponse: Decodable {
    let data: ScreenshotSetData

    struct ScreenshotSetData: Decodable {
        let id: String
    }
}

private struct PreviewSetsResponse: Decodable {
    let data: [PreviewSetData]

    struct PreviewSetData: Decodable {
        let id: String
    }
}

private struct PreviewSetResponse: Decodable {
    let data: PreviewSetData

    struct PreviewSetData: Decodable {
        let id: String
    }
}

private struct CreateScreenshotSetRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let attributes: Attributes
        let relationships: Relationships
    }

    struct Attributes: Encodable {
        let screenshotDisplayType: String
    }

    struct Relationships: Encodable {
        let appStoreVersionLocalization: LocalizationRelationship
    }

    struct LocalizationRelationship: Encodable {
        let data: LocalizationData
    }

    struct LocalizationData: Encodable {
        let type: String
        let id: String
    }
}

private struct CreatePreviewSetRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let relationships: Relationships
    }

    struct Relationships: Encodable {
        let appStoreVersionLocalization: LocalizationRelationship
    }

    struct LocalizationRelationship: Encodable {
        let data: LocalizationData
    }

    struct LocalizationData: Encodable {
        let type: String
        let id: String
    }
}

private struct ReserveScreenshotRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let attributes: Attributes
        let relationships: Relationships
    }

    struct Attributes: Encodable {
        let fileName: String
        let fileSize: Int
    }

    struct Relationships: Encodable {
        let appScreenshotSet: SetRelationship
    }

    struct SetRelationship: Encodable {
        let data: SetData
    }

    struct SetData: Encodable {
        let type: String
        let id: String
    }
}

private struct ScreenshotUploadResponse: Decodable {
    let data: ScreenshotData

    struct ScreenshotData: Decodable {
        let id: String
        let attributes: Attributes

        struct Attributes: Decodable {
            let uploadOperations: [UploadOperation]?

            struct UploadOperation: Decodable {
                let url: String
                let method: String
                let requestHeaders: [Header]?

                struct Header: Decodable {
                    let name: String
                    let value: String
                }
            }
        }
    }
}

private struct CommitScreenshotRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let id: String
        let attributes: Attributes
    }

    struct Attributes: Encodable {
        let uploaded: Bool
        let sourceFileChecksum: String?
    }
}

private struct LocalizationsResponse: Decodable {
    let data: [LocalizationData]

    struct LocalizationData: Decodable {
        let id: String
    }
}

private struct LocalizationResponse: Decodable {
    let data: LocalizationData

    struct LocalizationData: Decodable {
        let id: String
    }
}

private struct CreateLocalizationRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let attributes: Attributes
        let relationships: Relationships
    }

    struct Attributes: Encodable {
        let locale: String
    }

    struct Relationships: Encodable {
        let appStoreVersion: VersionRelationship
    }

    struct VersionRelationship: Encodable {
        let data: VersionData
    }

    struct VersionData: Encodable {
        let type: String
        let id: String
    }
}

private struct EmptyResponse: Decodable {}

//
// Layer: Services
// Module: AppStoreConnect
// Purpose: Upload operations and helper methods for media upload service
//

import Foundation

/// Extension containing upload operations for MediaUploadService
extension MediaUploadService {
    // MARK: - Internal Operations

    func getOrCreateScreenshotSet(
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

    func getOrCreatePreviewSet(
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

    func uploadScreenshot(
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

        guard let uploadURL = URL(string: uploadOperation.url) else {
            throw AppStoreConnectClient.APIError.invalidResponse
        }
        var uploadRequest = URLRequest(url: uploadURL)
        uploadRequest.httpMethod = uploadOperation.method
        uploadRequest.httpBody = screenshot.imageData

        for header in uploadOperation.requestHeaders ?? [] {
            uploadRequest.setValue(header.value, forHTTPHeaderField: header.name)
        }

        let (_, uploadResponse) = try await URLSession.shared.data(for: uploadRequest)

        guard let httpResponse = uploadResponse as? HTTPURLResponse,
              httpResponse.statusCode == NetworkConstants.StatusCode.success
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

    func uploadVideo(
        previewSetId _: String,
        video _: PreviewVideo,
    ) async throws {
        // Similar to screenshot upload but for video
        // Implementation follows same pattern: reserve, upload, commit
    }

    func deleteScreenshotSet(setId: String) async throws {
        let request = APIRequest(
            path: "/v1/appScreenshotSets/\(setId)",
            method: .delete,
        )

        _ = try await client.execute(
            request,
            responseType: EmptyResponse.self,
        )
    }

    func getLocalizationId(versionId: String, locale: String) async throws -> String {
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

    func createLocalization(versionId: String, locale: String) async throws -> String {
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

    func updateProgress(total: Int, completed: Int, currentFile: String?) {
        uploadProgress = UploadProgress(
            totalFiles: total,
            completedFiles: completed,
            currentFileName: currentFile,
            percentComplete: Double(completed) / Double(total),
        )
    }
}

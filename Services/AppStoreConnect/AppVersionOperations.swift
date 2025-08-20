//
// Layer: Services
// Module: AppStoreConnect
// Purpose: Operations and helper methods for app version service
//

import Foundation

/// Extension containing operations for AppVersionService
extension AppVersionService {
    // MARK: - Internal Operations

    func performCreateVersion(
        appId: String,
        versionString: String,
        platform: AppVersion.Platform,
    ) async throws -> AppVersion {
        let request = APIRequest(
            path: "/v1/appStoreVersions",
            method: .post,
            body: CreateVersionRequest(
                data: CreateVersionRequest.Data(
                    type: "appStoreVersions",
                    attributes: CreateVersionRequest.Attributes(
                        versionString: versionString,
                        platform: platform.rawValue,
                    ),
                    relationships: CreateVersionRequest.Relationships(
                        app: CreateVersionRequest.AppRelationship(
                            data: CreateVersionRequest.AppData(
                                type: "apps",
                                id: appId,
                            ),
                        ),
                    ),
                ),
            ),
        )

        let response = try await client.execute(
            request,
            responseType: AppVersionResponse.self,
        )

        return mapToAppVersion(response.data)
    }

    func performFetchVersions(appId: String) async throws -> [AppVersion] {
        let request = APIRequest(
            path: "/v1/apps/\(appId)/appStoreVersions",
            queryParameters: [
                "fields[appStoreVersions]": "versionString,appStoreState,releaseType,earliestReleaseDate,downloadable,createdDate,platform",
                "limit": "\(NetworkConstants.Limits.maxPageSize)",
            ],
        )

        let response = try await client.execute(
            request,
            responseType: AppVersionsResponse.self,
        )

        return response.data.map(mapToAppVersion)
    }

    func performUpdateVersionMetadata(
        versionId _: String,
        localizations: [VersionLocalization],
    ) async throws {
        for localization in localizations {
            let request = APIRequest(
                path: "/v1/appStoreVersionLocalizations",
                method: .patch,
                body: UpdateVersionLocalizationRequest(
                    data: UpdateVersionLocalizationRequest.Data(
                        type: "appStoreVersionLocalizations",
                        attributes: UpdateVersionLocalizationRequest.Attributes(
                            description: localization.description,
                            keywords: localization.keywords,
                            marketingUrl: localization.marketingUrl,
                            promotionalText: localization.promotionalText,
                            supportUrl: localization.supportUrl,
                            whatsNew: localization.whatsNew,
                        ),
                    ),
                ),
            )

            _ = try await client.execute(
                request,
                responseType: EmptyResponse.self,
            )
        }
    }

    func performFetchBuilds(versionId: String) async throws -> [Build] {
        let request = APIRequest(
            path: "/v1/appStoreVersions/\(versionId)/builds",
            queryParameters: [
                "fields[builds]": "version,uploadedDate,expirationDate,processingState",
                "include": "buildBetaDetail",
                "limit": "\(NetworkConstants.Limits.maxPageSize)",
            ],
        )

        let response = try await client.execute(
            request,
            responseType: BuildsResponse.self,
        )

        return response.data.map(mapToBuild)
    }

    func performSelectBuild(versionId: String, buildId: String) async throws {
        let request = APIRequest(
            path: "/v1/appStoreVersions/\(versionId)/relationships/build",
            method: .patch,
            body: SelectBuildRequest(
                data: SelectBuildRequest.Data(
                    type: "builds",
                    id: buildId,
                ),
            ),
        )

        _ = try await client.execute(
            request,
            responseType: EmptyResponse.self,
        )
    }

    func performSubmitForReview(submission: ReviewSubmission) async throws {
        // Create review submission
        let request = APIRequest(
            path: "/v1/appStoreReviewDetails",
            method: .post,
            body: CreateReviewSubmissionRequest(
                data: CreateReviewSubmissionRequest.Data(
                    type: "appStoreReviewDetails",
                    attributes: CreateReviewSubmissionRequest.Attributes(
                        contactFirstName: submission.contactFirstName,
                        contactLastName: submission.contactLastName,
                        contactEmail: submission.contactEmail,
                        contactPhone: submission.contactPhone,
                        demoAccountName: submission.demoAccountName,
                        demoAccountPassword: submission.demoAccountPassword,
                        demoAccountRequired: submission.demoAccountRequired,
                        notes: submission.notes,
                    ),
                    relationships: CreateReviewSubmissionRequest.Relationships(
                        appStoreVersion: CreateReviewSubmissionRequest.VersionRelationship(
                            data: CreateReviewSubmissionRequest.VersionData(
                                type: "appStoreVersions",
                                id: submission.versionId,
                            ),
                        ),
                    ),
                ),
            ),
        )

        _ = try await client.execute(
            request,
            responseType: EmptyResponse.self,
        )

        // Submit the version
        let submitRequest = APIRequest(
            path: "/v1/appStoreVersionSubmissions",
            method: .post,
            body: SubmitVersionRequest(
                data: SubmitVersionRequest.Data(
                    type: "appStoreVersionSubmissions",
                    relationships: SubmitVersionRequest.Relationships(
                        appStoreVersion: SubmitVersionRequest.VersionRelationship(
                            data: SubmitVersionRequest.VersionData(
                                type: "appStoreVersions",
                                id: submission.versionId,
                            ),
                        ),
                    ),
                ),
            ),
        )

        _ = try await client.execute(
            submitRequest,
            responseType: EmptyResponse.self,
        )
    }

    func performSetReleaseType(
        versionId: String,
        releaseType: AppVersion.ReleaseType,
        releaseDate: Date?,
    ) async throws {
        let request = APIRequest(
            path: "/v1/appStoreVersions/\(versionId)",
            method: .patch,
            body: UpdateVersionRequest(
                data: UpdateVersionRequest.Data(
                    type: "appStoreVersions",
                    id: versionId,
                    attributes: UpdateVersionRequest.Attributes(
                        releaseType: releaseType.rawValue,
                        earliestReleaseDate: releaseDate,
                    ),
                ),
            ),
        )

        _ = try await client.execute(
            request,
            responseType: EmptyResponse.self,
        )
    }

    // MARK: - Mapping Helpers

    func mapToAppVersion(_ data: AppVersionResponse.AppVersionData) -> AppVersion {
        let formatter = ISO8601DateFormatter()

        return AppVersion(
            id: data.id,
            versionString: data.attributes.versionString,
            platform: AppVersion.Platform(rawValue: data.attributes.platform) ?? .ios,
            appStoreState: AppVersion.AppStoreState(rawValue: data.attributes.appStoreState) ?? .prepareForSubmission,
            releaseType: data.attributes.releaseType.flatMap { AppVersion.ReleaseType(rawValue: $0) },
            earliestReleaseDate: data.attributes.earliestReleaseDate.flatMap { formatter.date(from: $0) },
            downloadable: data.attributes.downloadable ?? false,
            createdDate: formatter.date(from: data.attributes.createdDate) ?? Date(),
        )
    }

    func mapToBuild(_ data: BuildsResponse.BuildData) -> Build {
        let formatter = ISO8601DateFormatter()

        return Build(
            id: data.id,
            version: data.attributes.version,
            uploadedDate: formatter.date(from: data.attributes.uploadedDate) ?? Date(),
            expirationDate: formatter.date(from: data.attributes.expirationDate) ?? Date(),
            processingState: Build.ProcessingState(rawValue: data.attributes.processingState) ?? .processing,
            buildBetaDetail: nil,
        )
    }
}

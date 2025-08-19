//
// Layer: Services
// Module: AppStoreConnect
// Purpose: Manage app versions, builds, and releases
//

import Foundation

/// Service for managing app versions and builds in App Store Connect
@MainActor
public final class AppVersionService: ObservableObject {
    // MARK: - Types

    public struct AppVersion: Codable, Identifiable {
        public let id: String
        public let versionString: String
        public let platform: Platform
        public let appStoreState: AppStoreState
        public let releaseType: ReleaseType?
        public let earliestReleaseDate: Date?
        public let downloadable: Bool
        public let createdDate: Date

        public enum Platform: String, Codable {
            case ios = "IOS"
            case tvos = "TV_OS"
            case macos = "MAC_OS"
        }

        public enum AppStoreState: String, Codable {
            case developerRemovedFromSale = "DEVELOPER_REMOVED_FROM_SALE"
            case developerRejected = "DEVELOPER_REJECTED"
            case inReview = "IN_REVIEW"
            case invalidBinary = "INVALID_BINARY"
            case metadataRejected = "METADATA_REJECTED"
            case pendingAppleRelease = "PENDING_APPLE_RELEASE"
            case pendingContract = "PENDING_CONTRACT"
            case pendingDeveloperRelease = "PENDING_DEVELOPER_RELEASE"
            case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
            case preorderReadyForSale = "PREORDER_READY_FOR_SALE"
            case processingForAppStore = "PROCESSING_FOR_APP_STORE"
            case readyForSale = "READY_FOR_SALE"
            case rejected = "REJECTED"
            case removedFromSale = "REMOVED_FROM_SALE"
            case waitingForExportCompliance = "WAITING_FOR_EXPORT_COMPLIANCE"
            case waitingForReview = "WAITING_FOR_REVIEW"
            case replaced = "REPLACED_WITH_NEW_VERSION"
        }

        public enum ReleaseType: String, Codable {
            case manual = "MANUAL"
            case afterApproval = "AFTER_APPROVAL"
            case scheduled = "SCHEDULED"
        }
    }

    public struct Build: Codable, Identifiable {
        public let id: String
        public let version: String
        public let uploadedDate: Date
        public let expirationDate: Date
        public let processingState: ProcessingState
        public let buildBetaDetail: BetaDetail?

        public enum ProcessingState: String, Codable {
            case processing = "PROCESSING"
            case failed = "FAILED"
            case invalid = "INVALID"
            case valid = "VALID"
        }

        public struct BetaDetail: Codable {
            public let internalBuildState: InternalState
            public let externalBuildState: ExternalState

            public enum InternalState: String, Codable {
                case processingException = "PROCESSING_EXCEPTION"
                case missingExportCompliance = "MISSING_EXPORT_COMPLIANCE"
                case readyForBetaTesting = "READY_FOR_BETA_TESTING"
                case inBetaTesting = "IN_BETA_TESTING"
                case expired = "EXPIRED"
                case inExportComplianceReview = "IN_EXPORT_COMPLIANCE_REVIEW"
            }

            public enum ExternalState: String, Codable {
                case processingException = "PROCESSING_EXCEPTION"
                case missingExportCompliance = "MISSING_EXPORT_COMPLIANCE"
                case readyForBetaTesting = "READY_FOR_BETA_TESTING"
                case inBetaTesting = "IN_BETA_TESTING"
                case expired = "EXPIRED"
                case readyForBetaSubmission = "READY_FOR_BETA_SUBMISSION"
                case waitingForBetaReview = "WAITING_FOR_BETA_REVIEW"
                case inBetaReview = "IN_BETA_REVIEW"
                case betaRejected = "BETA_REJECTED"
                case betaApproved = "BETA_APPROVED"
            }
        }
    }

    public struct VersionLocalization: Codable {
        public let locale: String
        public var description: String?
        public var keywords: String?
        public var marketingUrl: String?
        public var promotionalText: String?
        public var supportUrl: String?
        public var whatsNew: String?
    }

    public struct ReviewSubmission {
        public let versionId: String
        public let buildId: String
        public let notes: String?
        public let demoAccountRequired: Bool
        public let demoAccountName: String?
        public let demoAccountPassword: String?
        public let contactFirstName: String
        public let contactLastName: String
        public let contactEmail: String
        public let contactPhone: String
    }

    // MARK: - Properties

    private let client: AppStoreConnectClient

    // MARK: - Initialization

    public init(client: AppStoreConnectClient) {
        self.client = client
    }

    // MARK: - Version Management

    /// Create a new app version
    public func createVersion(
        appId: String,
        versionString: String,
        platform: AppVersion.Platform = .ios,
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

    /// Fetch all versions for an app
    public func fetchVersions(appId: String) async throws -> [AppVersion] {
        let request = APIRequest(
            path: "/v1/apps/\(appId)/appStoreVersions",
            queryParameters: [
                "fields[appStoreVersions]": "versionString,appStoreState,releaseType,earliestReleaseDate,downloadable,createdDate,platform",
                "limit": "200",
            ],
        )

        let response = try await client.execute(
            request,
            responseType: AppVersionsResponse.self,
        )

        return response.data.map(mapToAppVersion)
    }

    /// Update version metadata
    public func updateVersionMetadata(
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

    // MARK: - Build Management

    /// Fetch builds for a version
    public func fetchBuilds(versionId: String) async throws -> [Build] {
        let request = APIRequest(
            path: "/v1/appStoreVersions/\(versionId)/builds",
            queryParameters: [
                "fields[builds]": "version,uploadedDate,expirationDate,processingState",
                "include": "buildBetaDetail",
                "limit": "200",
            ],
        )

        let response = try await client.execute(
            request,
            responseType: BuildsResponse.self,
        )

        return response.data.map(mapToBuild)
    }

    /// Select build for version
    public func selectBuild(
        versionId: String,
        buildId: String,
    ) async throws {
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

    // MARK: - Review Submission

    /// Submit version for review
    public func submitForReview(
        submission: ReviewSubmission,
    ) async throws {
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

    /// Set release type (manual, automatic, scheduled)
    public func setReleaseType(
        versionId: String,
        releaseType: AppVersion.ReleaseType,
        releaseDate: Date? = nil,
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

    // MARK: - Private Helpers

    private func mapToAppVersion(_ data: AppVersionResponse.AppVersionData) -> AppVersion {
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

    private func mapToBuild(_ data: BuildsResponse.BuildData) -> Build {
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

// MARK: - Request/Response Types

private struct CreateVersionRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let attributes: Attributes
        let relationships: Relationships
    }

    struct Attributes: Encodable {
        let versionString: String
        let platform: String
    }

    struct Relationships: Encodable {
        let app: AppRelationship
    }

    struct AppRelationship: Encodable {
        let data: AppData
    }

    struct AppData: Encodable {
        let type: String
        let id: String
    }
}

private struct UpdateVersionRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let id: String
        let attributes: Attributes
    }

    struct Attributes: Encodable {
        let releaseType: String?
        let earliestReleaseDate: Date?
    }
}

private struct UpdateVersionLocalizationRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let attributes: Attributes
    }

    struct Attributes: Encodable {
        let description: String?
        let keywords: String?
        let marketingUrl: String?
        let promotionalText: String?
        let supportUrl: String?
        let whatsNew: String?
    }
}

private struct SelectBuildRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let id: String
    }
}

private struct CreateReviewSubmissionRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let attributes: Attributes
        let relationships: Relationships
    }

    struct Attributes: Encodable {
        let contactFirstName: String
        let contactLastName: String
        let contactEmail: String
        let contactPhone: String
        let demoAccountName: String?
        let demoAccountPassword: String?
        let demoAccountRequired: Bool
        let notes: String?
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

private struct SubmitVersionRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let relationships: Relationships
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

private struct AppVersionResponse: Decodable {
    let data: AppVersionData

    struct AppVersionData: Decodable {
        let id: String
        let attributes: Attributes

        struct Attributes: Decodable {
            let versionString: String
            let platform: String
            let appStoreState: String
            let releaseType: String?
            let earliestReleaseDate: String?
            let downloadable: Bool?
            let createdDate: String
        }
    }
}

private struct AppVersionsResponse: Decodable {
    let data: [AppVersionResponse.AppVersionData]
}

private struct BuildsResponse: Decodable {
    let data: [BuildData]

    struct BuildData: Decodable {
        let id: String
        let attributes: Attributes

        struct Attributes: Decodable {
            let version: String
            let uploadedDate: String
            let expirationDate: String
            let processingState: String
        }
    }
}

private struct EmptyResponse: Decodable {}

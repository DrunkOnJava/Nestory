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

    let client: AppStoreConnectClient

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
        try await performCreateVersion(
            appId: appId,
            versionString: versionString,
            platform: platform,
        )
    }

    /// Fetch all versions for an app
    public func fetchVersions(appId: String) async throws -> [AppVersion] {
        try await performFetchVersions(appId: appId)
    }

    /// Update version metadata
    public func updateVersionMetadata(
        versionId: String,
        localizations: [VersionLocalization],
    ) async throws {
        try await performUpdateVersionMetadata(
            versionId: versionId,
            localizations: localizations,
        )
    }

    // MARK: - Build Management

    /// Fetch builds for a version
    public func fetchBuilds(versionId: String) async throws -> [Build] {
        try await performFetchBuilds(versionId: versionId)
    }

    /// Select build for version
    public func selectBuild(
        versionId: String,
        buildId: String,
    ) async throws {
        try await performSelectBuild(
            versionId: versionId,
            buildId: buildId,
        )
    }

    // MARK: - Review Submission

    /// Submit version for review
    public func submitForReview(
        submission: ReviewSubmission,
    ) async throws {
        try await performSubmitForReview(submission: submission)
    }

    /// Set release type (manual, automatic, scheduled)
    public func setReleaseType(
        versionId: String,
        releaseType: AppVersion.ReleaseType,
        releaseDate: Date? = nil,
    ) async throws {
        try await performSetReleaseType(
            versionId: versionId,
            releaseType: releaseType,
            releaseDate: releaseDate,
        )
    }
}

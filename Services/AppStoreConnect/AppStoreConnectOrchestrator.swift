//
// Layer: Services
// Module: AppStoreConnect
// Purpose: Orchestrate complete App Store Connect workflows
//

import Foundation
import UIKit

/// High-level orchestrator for complete App Store Connect workflows
@MainActor
public final class AppStoreConnectOrchestrator: ObservableObject {
    // MARK: - Types

    public struct AppSubmission {
        public let version: String
        public let buildNumber: String
        public let releaseNotes: String
        public let screenshots: [MediaUploadService.ScreenshotSet]?
        public let metadata: AppMetadata
        public let reviewInfo: ReviewInfo
        public let releaseStrategy: ReleaseStrategy

        public struct AppMetadata {
            public let name: String
            public let subtitle: String?
            public let description: String
            public let keywords: String
            public let primaryCategory: AppMetadataService.AppCategories.Category
            public let secondaryCategory: AppMetadataService.AppCategories.Category?
            public let supportURL: String
            public let marketingURL: String?
            public let privacyPolicyURL: String
        }

        public struct ReviewInfo {
            public let demoRequired: Bool
            public let demoAccount: String?
            public let demoPassword: String?
            public let notes: String?
            public let contactFirstName: String
            public let contactLastName: String
            public let contactEmail: String
            public let contactPhone: String
        }

        public enum ReleaseStrategy {
            case immediate
            case manual
            case scheduled(Date)
            case phased(daysPerPhase: Int)
        }
    }

    public enum WorkflowState {
        case idle
        case preparingVersion
        case uploadingMetadata
        case uploadingScreenshots
        case selectingBuild
        case submittingForReview
        case completed
        case failed(any Error)

        var description: String {
            switch self {
            case .idle: "Ready"
            case .preparingVersion: "Preparing version..."
            case .uploadingMetadata: "Uploading metadata..."
            case .uploadingScreenshots: "Uploading screenshots..."
            case .selectingBuild: "Selecting build..."
            case .submittingForReview: "Submitting for review..."
            case .completed: "Completed successfully"
            case let .failed(error): "Failed: \(error.localizedDescription)"
            }
        }
    }

    public struct WorkflowProgress {
        public let state: WorkflowState
        public let percentComplete: Double
        public let currentTask: String
        public let estimatedTimeRemaining: TimeInterval?
    }

    // MARK: - Properties

    private let configuration: AppStoreConnectConfiguration
    private let client: AppStoreConnectClient
    private let metadataService: AppMetadataService
    private let versionService: AppVersionService
    private let mediaService: MediaUploadService

    @Published public private(set) var currentProgress: WorkflowProgress?
    @Published public private(set) var isRunning = false
    @Published public private(set) var lastError: (any Error)?

    // MARK: - Initialization

    public init() throws {
        configuration = AppStoreConnectConfiguration()

        guard configuration.isConfigured else {
            throw AppStoreConnectConfiguration.ConfigurationError.environmentNotConfigured
        }

        client = try configuration.createClient()
        metadataService = AppMetadataService(client: client)
        versionService = AppVersionService(client: client)
        mediaService = MediaUploadService(client: client)
    }

    // MARK: - Complete Workflows

    /// Execute complete app submission workflow
    public func submitApp(_ submission: AppSubmission) async throws {
        isRunning = true
        defer { isRunning = false }

        do {
            // 1. Fetch app info
            updateProgress(.preparingVersion, percent: 0, task: "Fetching app information")
            let appInfo = try await metadataService.fetchApp(bundleId: configuration.currentEnvironment.bundleID)

            // 2. Create or update version
            updateProgress(.preparingVersion, percent: 10, task: "Creating version \(submission.version)")
            let version = try await createOrUpdateVersion(
                appId: appInfo.id,
                versionString: submission.version,
            )

            // 3. Update metadata
            updateProgress(.uploadingMetadata, percent: 20, task: "Updating app metadata")
            try await updateMetadata(
                appId: appInfo.id,
                versionId: version.id,
                metadata: submission.metadata,
                releaseNotes: submission.releaseNotes,
            )

            // 4. Upload screenshots if provided
            if let screenshots = submission.screenshots {
                updateProgress(.uploadingScreenshots, percent: 40, task: "Uploading screenshots")
                try await mediaService.uploadScreenshots(
                    versionId: version.id,
                    screenshotSets: screenshots,
                )
            }

            // 5. Select build
            updateProgress(.selectingBuild, percent: 60, task: "Selecting build \(submission.buildNumber)")
            try await selectBuild(
                versionId: version.id,
                buildNumber: submission.buildNumber,
            )

            // 6. Configure release strategy
            updateProgress(.submittingForReview, percent: BusinessConstants.AppStoreConnect.configurationProgress, task: "Configuring release strategy")
            try await configureReleaseStrategy(
                versionId: version.id,
                strategy: submission.releaseStrategy,
            )

            // 7. Submit for review
            updateProgress(.submittingForReview, percent: BusinessConstants.AppStoreConnect.submissionProgress, task: "Submitting for review")
            try await versionService.submitForReview(
                submission: AppVersionService.ReviewSubmission(
                    versionId: version.id,
                    buildId: submission.buildNumber,
                    notes: submission.reviewInfo.notes,
                    demoAccountRequired: submission.reviewInfo.demoRequired,
                    demoAccountName: submission.reviewInfo.demoAccount,
                    demoAccountPassword: submission.reviewInfo.demoPassword,
                    contactFirstName: submission.reviewInfo.contactFirstName,
                    contactLastName: submission.reviewInfo.contactLastName,
                    contactEmail: submission.reviewInfo.contactEmail,
                    contactPhone: submission.reviewInfo.contactPhone,
                ),
            )

            updateProgress(.completed, percent: BusinessConstants.AppStoreConnect.completionProgress, task: "Submission complete")
        } catch {
            lastError = error
            updateProgress(.failed(error), percent: 0, task: "Submission failed")
            throw error
        }
    }

    /// Validate app before submission
    public func validateSubmission(_ submission: AppSubmission) async throws -> [ValidationIssue] {
        var issues: [ValidationIssue] = []

        // Check credentials
        if !configuration.isConfigured {
            issues.append(ValidationIssue(
                severity: .error,
                message: "App Store Connect API credentials not configured",
            ))
        }

        // Validate metadata
        if submission.metadata.description.count < 10 {
            issues.append(ValidationIssue(
                severity: .error,
                message: "App description is too short (minimum 10 characters)",
            ))
        }

        if submission.metadata.description.count > 4000 {
            issues.append(ValidationIssue(
                severity: .error,
                message: "App description is too long (maximum 4000 characters)",
            ))
        }

        if submission.metadata.keywords.split(separator: ",").count > BusinessConstants.AppStoreConnect.maxKeywordCharacters {
            issues.append(ValidationIssue(
                severity: .warning,
                message: "Too many keywords (maximum \(BusinessConstants.AppStoreConnect.maxKeywordCharacters) characters total)",
            ))
        }

        // Validate screenshots if provided
        if let screenshots = submission.screenshots {
            for set in screenshots {
                for screenshot in set.screenshots {
                    if screenshot.fileSize > BusinessConstants.AppStoreConnect.maxScreenshotFileSize {
                        issues.append(ValidationIssue(
                            severity: .warning,
                            message: "Screenshot \(screenshot.fileName) is larger than 10MB",
                        ))
                    }
                }
            }
        }

        // Validate review info
        if submission.reviewInfo.contactEmail.isEmpty {
            issues.append(ValidationIssue(
                severity: .error,
                message: "Review contact email is required",
            ))
        }

        if submission.reviewInfo.demoRequired, submission.reviewInfo.demoAccount == nil {
            issues.append(ValidationIssue(
                severity: .error,
                message: "Demo account credentials required when demo is needed",
            ))
        }

        return issues
    }

    // MARK: - Private Helpers

    private func createOrUpdateVersion(
        appId: String,
        versionString: String,
    ) async throws -> AppVersionService.AppVersion {
        // Check if version already exists
        let versions = try await versionService.fetchVersions(appId: appId)

        if let existingVersion = versions.first(where: { $0.versionString == versionString }) {
            return existingVersion
        }

        // Create new version
        return try await versionService.createVersion(
            appId: appId,
            versionString: versionString,
        )
    }

    private func updateMetadata(
        appId: String,
        versionId: String,
        metadata: AppSubmission.AppMetadata,
        releaseNotes: String,
    ) async throws {
        // Update app-level metadata
        let categories = AppMetadataService.AppCategories(
            primaryCategory: metadata.primaryCategory,
            secondaryCategory: metadata.secondaryCategory,
        )
        try await metadataService.updateCategories(appId: appId, categories: categories)

        // Update version-specific metadata
        let localization = AppVersionService.VersionLocalization(
            locale: "en-US",
            description: metadata.description,
            keywords: metadata.keywords,
            marketingUrl: metadata.marketingURL,
            promotionalText: nil,
            supportUrl: metadata.supportURL,
            whatsNew: releaseNotes,
        )

        try await versionService.updateVersionMetadata(
            versionId: versionId,
            localizations: [localization],
        )
    }

    private func selectBuild(
        versionId: String,
        buildNumber: String,
    ) async throws {
        // Fetch available builds
        let builds = try await versionService.fetchBuilds(versionId: versionId)

        guard let build = builds.first(where: { $0.version == buildNumber }) else {
            throw AppStoreConnectClient.APIError.invalidResponse
        }

        // Wait for build to be processed
        var processingBuild = build
        var attempts = 0
        while processingBuild.processingState == .processing, attempts < 60 {
            try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
            let updatedBuilds = try await versionService.fetchBuilds(versionId: versionId)
            if let updated = updatedBuilds.first(where: { $0.id == build.id }) {
                processingBuild = updated
            }
            attempts += 1
        }

        guard processingBuild.processingState == .valid else {
            throw AppStoreConnectClient.APIError.invalidResponse
        }

        try await versionService.selectBuild(versionId: versionId, buildId: build.id)
    }

    private func configureReleaseStrategy(
        versionId: String,
        strategy: AppSubmission.ReleaseStrategy,
    ) async throws {
        switch strategy {
        case .immediate:
            try await versionService.setReleaseType(
                versionId: versionId,
                releaseType: .afterApproval,
            )

        case .manual:
            try await versionService.setReleaseType(
                versionId: versionId,
                releaseType: .manual,
            )

        case let .scheduled(date):
            try await versionService.setReleaseType(
                versionId: versionId,
                releaseType: .scheduled,
                releaseDate: date,
            )

        case .phased:
            // Phased release is configured after approval
            try await versionService.setReleaseType(
                versionId: versionId,
                releaseType: .afterApproval,
            )
        }
    }

    private func updateProgress(_ state: WorkflowState, percent: Double, task: String) {
        currentProgress = WorkflowProgress(
            state: state,
            percentComplete: percent,
            currentTask: task,
            estimatedTimeRemaining: nil,
        )
    }

    // MARK: - Validation

    public struct ValidationIssue {
        public enum Severity {
            case error
            case warning
            case info
        }

        public let severity: Severity
        public let message: String
    }
}

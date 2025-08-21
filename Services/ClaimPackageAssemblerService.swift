//
// Layer: Services
// Module: ClaimPackageAssembler
// Purpose: Facade service for assembling comprehensive insurance claim packages
//
// REMINDER: This service MUST be wired up in SettingsView and accessible from main screens

import Foundation
import SwiftData

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with AppleArchive - Compress claim packages for efficient transfer
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with MessageUI - Email claim packages directly
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with FileProvider - Cloud storage integration for claim backup

public enum ClaimPackageError: LocalizedError {
    case noItemsSelected
    case missingDocumentation
    case packageGenerationFailed
    case validationFailed([String])
    case insufficientDocumentation([String])

    public var errorDescription: String? {
        switch self {
        case .noItemsSelected:
            "No items selected for claim package"
        case .missingDocumentation:
            "Required documentation is missing"
        case .packageGenerationFailed:
            "Failed to generate claim package"
        case let .validationFailed(issues):
            "Package validation failed: \(issues.joined(separator: ", "))"
        case let .insufficientDocumentation(missing):
            "Insufficient documentation: \(missing.joined(separator: ", "))"
        }
    }
}

@MainActor
public final class ClaimPackageAssemblerService: ObservableObject {
    // MARK: - Dependencies

    private let core: ClaimPackageCore
    private let exporter: ClaimPackageExporter

    // MARK: - Initialization

    public init() {
        self.core = ClaimPackageCore()
        self.exporter = ClaimPackageExporter()
    }

    // MARK: - Published Properties (Delegated)

    public var isAssembling: Bool { core.isAssembling }
    public var assemblyProgress: Double { core.assemblyProgress }
    public var currentStep: String { core.currentStep }
    public var errorMessage: String? { core.errorMessage }
    public var lastGeneratedPackage: ClaimPackage? { core.lastGeneratedPackage }

    // MARK: - Main Assembly Methods (Delegated)

    public func assembleClaimPackage(
        for scenario: ClaimScenario,
        items: [Item],
        options: ClaimPackageOptions = ClaimPackageOptions()
    ) async throws -> ClaimPackage {
        try await core.assembleClaimPackage(for: scenario, items: items, options: options)
    }

    public func validatePackageCompleteness(
        items: [Item],
        scenario: ClaimScenario
    ) async throws -> PackageValidation {
        try await core.validatePackageCompleteness(items: items, scenario: scenario)
    }

    // MARK: - Export Methods (Delegated)

    public func exportAsZIP(package: ClaimPackage) async throws -> URL {
        try await exporter.exportAsZIP(package: package)
    }

    public func exportAsPDF(package: ClaimPackage) async throws -> URL {
        try await exporter.exportAsPDF(package: package)
    }

    public func prepareForEmail(package: ClaimPackage) async throws -> EmailPackage {
        try await exporter.prepareForEmail(package: package)
    }
}

// MARK: - Data Models (Retained for backward compatibility)

public struct ClaimScenario {
    public let type: ClaimType
    public let incidentDate: Date
    public let description: String
    public let metadata: [String: String]
    public let requiresConditionDocumentation: Bool

    public init(
        type: ClaimType,
        incidentDate: Date,
        description: String,
        metadata: [String: String] = [:],
        requiresConditionDocumentation: Bool = false
    ) {
        self.type = type
        self.incidentDate = incidentDate
        self.description = description
        self.metadata = metadata
        self.requiresConditionDocumentation = requiresConditionDocumentation
    }
}

public enum ClaimType: String, CaseIterable {
    case singleItem = "Single Item"
    case multipleItems = "Multiple Items"
    case roomBased = "Room/Area Based"
    case theft = "Theft"
    case totalLoss = "Total Loss"

    var description: String { rawValue }
}

public struct ClaimPackageOptions {
    public var policyHolder: String?
    public var policyNumber: String?
    public var propertyAddress: String?
    public var contactEmail: String?
    public var contactPhone: String?
    public var includePhotos = true
    public var includeReceipts = true
    public var includeWarranties = true
    public var compressPhotos = false
    public var generateAttestation = true

    public init() {}
}

public struct PackageValidation {
    public let isValid: Bool
    public let issues: [ValidationIssue]
    public let missingRequirements: [String]
    public let totalItems: Int
    public let documentedItems: Int
    public let totalValue: Decimal
    public let validationDate: Date
}

public struct ClaimSummary {
    public let claimType: ClaimType
    public let incidentDate: Date
    public let totalItems: Int
    public let totalValue: Decimal
    public let affectedRooms: [String]
    public let description: String
}

public struct ClaimCoverLetter {
    public let summary: ClaimSummary
    public let content: String
    public let generatedDate: Date
    public let policyHolder: String?
    public let policyNumber: String?
}

public struct ItemDocumentation {
    public let item: Item
    public let photos: [Data]
    public let receipts: [Data]
    public let warranties: [Data]
    public let manuals: [Data]
    public let conditionPhotos: [Data]
}

public struct ClaimForm {
    public let type: FormType
    public let name: String
    public var fileURL: URL?
    public let isRequired: Bool
    public let notes: String?

    public init(type: FormType, name: String, fileURL: URL?, isRequired: Bool, notes: String? = nil) {
        self.type = type
        self.name = name
        self.fileURL = fileURL
        self.isRequired = isRequired
        self.notes = notes
    }
}

public enum FormType {
    case standardInventory
    case detailedSpreadsheet
    case policeReport
    case proofOfLoss
    case attestation
}

public struct Attestation {
    public let type: AttestationType
    public let title: String
    public let content: String
    public let requiresSignature: Bool
}

public enum AttestationType {
    case ownership
    case value
    case incident
}

public struct ClaimPackage {
    public let id: UUID
    public let scenario: ClaimScenario
    public let items: [Item]
    public let coverLetter: ClaimCoverLetter
    public let documentation: [ItemDocumentation]
    public let forms: [ClaimForm]
    public let attestations: [Attestation]
    public let validation: PackageValidation
    public let packageURL: URL
    public let createdDate: Date
    public let options: ClaimPackageOptions
}

public struct EmailPackage {
    public let summaryPDF: URL
    public let compressedPhotos: [URL]
    public let attachmentSize: Int
    public var recipientEmails: [String]
    public let subject: String
    public let body: String
}

//
// Layer: Services
// Module: ClaimExport
// Purpose: Data models and types for claim export and submission system
//

import Foundation
import SwiftData
import UniformTypeIdentifiers

// MARK: - Core Models

/// Represents a claim submission record
@Model
public final class ClaimSubmission {
    // CloudKit compatible: no unique constraint on ID
    public var id = UUID()
    var createdAt = Date()
    var updatedAt = Date()

    // Claim Details
    var claimNumber: String?
    var policyNumber: String?
    var insuranceCompany: String
    var claimType: InsuranceClaimType
    var incidentDate: Date?

    // Submission Details
    var submissionMethod: SubmissionMethod
    var submissionDate: Date?
    var status = ClaimStatus.preparing
    var confirmationNumber: String?

    // Items and Value
    var itemIds: [UUID] = []
    var totalItemCount = 0
    var totalClaimedValue: Decimal = 0

    // File Information
    var exportedFileURL: String?
    var exportFormat: String
    var fileSize = 0

    // Communication History
    var correspondenceHistory: [CorrespondenceRecord] = []
    var followUpDate: Date?
    var notes = ""

    init(
        insuranceCompany: String,
        claimType: InsuranceClaimType,
        submissionMethod: SubmissionMethod,
        exportFormat: String
    ) {
        self.insuranceCompany = insuranceCompany
        self.claimType = claimType
        self.submissionMethod = submissionMethod
        self.exportFormat = exportFormat
    }
}

// MARK: - Enums

/// Types of insurance claims
public enum InsuranceClaimType: String, CaseIterable, Codable {
    case fire = "Fire Damage"
    case flood = "Flood Damage"
    case theft = "Theft/Burglary"
    case vandalism = "Vandalism"
    case storm = "Storm Damage"
    case earthquake = "Earthquake"
    case liability = "Liability"
    case other = "Other"

    var icon: String {
        switch self {
        case .fire: "flame"
        case .flood: "drop"
        case .theft: "lock.open"
        case .vandalism: "exclamationmark.triangle"
        case .storm: "cloud.bolt"
        case .earthquake: "waveform.path.ecg"
        case .liability: "person.2"
        case .other: "questionmark.circle"
        }
    }
}

/// Methods for submitting claims
public enum SubmissionMethod: String, CaseIterable, Codable, Sendable {
    case email = "Email"
    case onlinePortal = "Online Portal"
    case mobileApp = "Mobile App"
    case cloudUpload = "Cloud Upload"
    case physicalMail = "Physical Mail"
    case fax = "Fax"
    case inPerson = "In Person"

    var requiresManualSubmission: Bool {
        switch self {
        case .email, .cloudUpload:
            false
        case .onlinePortal, .mobileApp, .physicalMail, .fax, .inPerson:
            true
        }
    }
}

/// Status of claim submission
public enum ClaimStatus: String, CaseIterable, Codable, Sendable {
    case draft = "Draft"
    case preparing = "Preparing"
    case submitted = "Submitted"
    case acknowledged = "Acknowledged"
    case pendingDocuments = "Pending Documents"
    case underReview = "Under Review"
    case scheduledInspection = "Scheduled Inspection"
    case approved = "Approved"
    case settlementOffered = "Settlement Offered"
    case denied = "Denied"
    case settled = "Settled"
    case closed = "Closed"

    var color: String {
        switch self {
        case .draft, .preparing: "orange"
        case .submitted, .acknowledged: "blue"
        case .pendingDocuments, .underReview: "yellow"
        case .scheduledInspection: "purple"
        case .approved, .settlementOffered, .settled: "green"
        case .denied, .closed: "gray"
        }
    }
}

// MARK: - Communication Models

/// Communication record with insurance company
public struct CorrespondenceRecord: Codable, Identifiable {
    public let id = UUID()
    public let date: Date
    public let type: CorrespondenceType
    public let direction: CommunicationDirection
    public let subject: String
    public let content: String
    public let attachments: [String] // File names

    public init(
        type: CorrespondenceType,
        direction: CommunicationDirection,
        subject: String,
        content: String,
        attachments: [String] = []
    ) {
        self.date = Date()
        self.type = type
        self.direction = direction
        self.subject = subject
        self.content = content
        self.attachments = attachments
    }
}

// CorrespondenceType is imported from Foundation/Models/CorrespondenceTypes.swift

public enum CommunicationDirection: String, Codable {
    case sent = "Sent"
    case received = "Received"
}

// MARK: - Insurance Company Formats

/// Supported insurance company formats
public enum InsuranceCompanyFormat: String, CaseIterable {
    case acord = "ACORD Standard"
    case allstate = "Allstate"
    case statefarm = "State Farm"
    case geico = "GEICO"
    case progressive = "Progressive"
    case farmers = "Farmers"
    case liberty = "Liberty Mutual"
    case travelers = "Travelers"
    case nationwide = "Nationwide"
    case usaa = "USAA"
    case generic = "Generic Form"

    var fileExtension: String {
        switch self {
        case .acord: "xml"
        case .allstate, .statefarm, .geico: "xlsx"
        case .progressive, .farmers: "pdf"
        case .liberty, .travelers: "zip"
        case .nationwide, .usaa: "json"
        case .generic: "pdf"
        }
    }

    var submissionMethods: [SubmissionMethod] {
        switch self {
        case .acord: [.email, .onlinePortal, .cloudUpload]
        case .allstate: [.mobileApp, .onlinePortal, .email]
        case .statefarm: [.mobileApp, .onlinePortal, .email, .physicalMail]
        case .geico: [.mobileApp, .onlinePortal, .email]
        case .progressive: [.mobileApp, .onlinePortal, .email, .fax]
        case .farmers: [.onlinePortal, .email, .physicalMail, .inPerson]
        case .liberty: [.onlinePortal, .email, .cloudUpload]
        case .travelers: [.onlinePortal, .email, .physicalMail]
        case .nationwide: [.mobileApp, .onlinePortal, .email]
        case .usaa: [.mobileApp, .onlinePortal, .email, .cloudUpload]
        case .generic: SubmissionMethod.allCases
        }
    }
}

// MARK: - Validation Models

public struct ClaimValidationRequirements: Sendable {
    let requiresPhotos: Bool
    let requiresReceipts: Bool
    let requiresSerialNumbers: Bool
    let requiresPolicyInfo: Bool
    let requiresIncidentDate: Bool
    let minimumItemValue: Decimal?
    let maximumFileSize: Int // bytes
    let supportedFileTypes: [UTType]

    static let standard = ClaimValidationRequirements(
        requiresPhotos: true,
        requiresReceipts: false,
        requiresSerialNumbers: false,
        requiresPolicyInfo: true,
        requiresIncidentDate: true,
        minimumItemValue: nil,
        maximumFileSize: 50_000_000, // 50MB
        supportedFileTypes: [.pdf, .jpeg, .png, .spreadsheet, .xml, .json]
    )
}

// MARK: - Errors

public enum ClaimExportError: LocalizedError {
    case validationFailed([String])
    case fileNotFound
    case uploadFailed(String)
    case invalidFormat
    case networkError(Error)

    public var errorDescription: String? {
        switch self {
        case let .validationFailed(errors):
            "Claim validation failed: \(errors.joined(separator: ", "))"
        case .fileNotFound:
            "Export file not found"
        case let .uploadFailed(reason):
            "Upload failed: \(reason)"
        case .invalidFormat:
            "Invalid export format"
        case let .networkError(error):
            "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Protocol Definitions

public protocol CloudStorageService: Sendable {
    var name: String { get }
    func upload(fileURL: URL, fileName: String) async throws -> String
}

// MARK: - Extensions
// DateFormatter.shortDateFormatter is defined in Foundation/Utils/DateUtils.swift

//
// Layer: Services
// Module: InsuranceClaimModels
// Purpose: Data models and types for insurance claim generation
//

import Foundation

// Foundation layer imports
// ClaimType and InsuranceCompany are defined in Foundation/Models/InsuranceTypes.swift

// MARK: - Document Formats

public enum ClaimDocumentFormat: String, CaseIterable, Sendable {
    case pdf = "PDF"
    case standardPDF = "Standard PDF"
    case detailedPDF = "Detailed PDF"
    case militaryFormat = "Military Format"
    case structuredJSON = "Structured JSON"
    case spreadsheet = "Excel Spreadsheet"
    case htmlPackage = "HTML Package"

    public var fileExtension: String {
        switch self {
        case .pdf, .standardPDF, .detailedPDF, .militaryFormat:
            "pdf"
        case .structuredJSON:
            "json"
        case .spreadsheet:
            "xlsx"
        case .htmlPackage:
            "html"
        }
    }
}

// MARK: - Claim Request

public struct ClaimRequest: Sendable, Identifiable {
    public let id: UUID
    public let claimType: ClaimType
    public let insuranceCompany: InsuranceCompany
    public let items: [Item]
    public let incidentDate: Date
    public let incidentDescription: String
    public let policyNumber: String?
    public let claimNumber: String?
    public let contactInfo: ClaimContactInfo
    public let additionalDocuments: [URL]
    public let documentNames: [String]
    public let estimatedTotalLoss: Decimal
    public let createdAt: Date
    public let format: ClaimDocumentFormat

    public init(
        claimType: ClaimType,
        insuranceCompany: InsuranceCompany,
        items: [Item],
        incidentDate: Date,
        incidentDescription: String,
        policyNumber: String? = nil,
        claimNumber: String? = nil,
        contactInfo: ClaimContactInfo,
        additionalDocuments: [URL] = [],
        documentNames: [String] = [],
        estimatedTotalLoss: Decimal = 0,
        format: ClaimDocumentFormat? = nil
    ) {
        self.id = UUID()
        self.claimType = claimType
        self.insuranceCompany = insuranceCompany
        self.items = items
        self.incidentDate = incidentDate
        self.incidentDescription = incidentDescription
        self.policyNumber = policyNumber
        self.claimNumber = claimNumber
        self.contactInfo = contactInfo
        self.additionalDocuments = additionalDocuments
        self.documentNames = documentNames
        self.estimatedTotalLoss = estimatedTotalLoss
        self.createdAt = Date()
        self.format = format ?? insuranceCompany.preferredFormat
    }
}

// MARK: - Contact Information

public struct ClaimContactInfo: Sendable {
    public let name: String
    public let phone: String
    public let email: String
    public let address: String
    public let emergencyContact: String?

    public init(
        name: String,
        phone: String,
        email: String,
        address: String,
        emergencyContact: String? = nil
    ) {
        self.name = name
        self.phone = phone
        self.email = email
        self.address = address
        self.emergencyContact = emergencyContact
    }
}

// MARK: - Insurance Company Extensions

extension InsuranceCompany {
    public var preferredFormat: ClaimDocumentFormat {
        switch preferredFormatName {
        case "Standard PDF":
            return .standardPDF
        case "Detailed PDF":
            return .detailedPDF
        case "Military Format":
            return .militaryFormat
        case "Excel Spreadsheet":
            return .spreadsheet
        case "Structured JSON":
            return .structuredJSON
        default:
            return .pdf
        }
    }
}

// MARK: - Generated Claim

public struct GeneratedClaim: Sendable {
    public let id: UUID
    public let request: ClaimRequest
    public let documentData: Data
    public let filename: String
    public let format: ClaimDocumentFormat
    public let generatedAt: Date
    public let checklistItems: [String]
    public let submissionInstructions: String

    public init(
        request: ClaimRequest,
        documentData: Data,
        filename: String,
        format: ClaimDocumentFormat,
        checklistItems: [String] = [],
        submissionInstructions: String = ""
    ) {
        self.id = UUID()
        self.request = request
        self.documentData = documentData
        self.filename = filename
        self.format = format
        self.generatedAt = Date()
        self.checklistItems = checklistItems
        self.submissionInstructions = submissionInstructions
    }
}

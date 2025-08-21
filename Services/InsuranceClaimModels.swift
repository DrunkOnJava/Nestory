//
// Layer: Services
// Module: InsuranceClaimModels
// Purpose: Data models and types for insurance claim generation
//

import Foundation

// MARK: - Claim Types

public enum ClaimType: String, CaseIterable, Codable {
    case theft = "Theft"
    case fire = "Fire Damage"
    case water = "Water Damage"
    case vandalism = "Vandalism"
    case naturalDisaster = "Natural Disaster"
    case accident = "Accidental Damage"
    case burglary = "Burglary"
    case windStorm = "Wind/Storm Damage"
    case generalLoss = "General Loss"

    public var icon: String {
        switch self {
        case .theft, .burglary:
            "lock.open"
        case .fire:
            "flame"
        case .water:
            "drop"
        case .vandalism:
            "hammer"
        case .naturalDisaster:
            "tornado"
        case .accident:
            "exclamationmark.triangle"
        case .windStorm:
            "wind"
        case .generalLoss:
            "questionmark.circle"
        }
    }

    public var description: String {
        switch self {
        case .theft:
            "Items stolen from property"
        case .fire:
            "Damage caused by fire or smoke"
        case .water:
            "Damage from flooding, leaks, or water exposure"
        case .vandalism:
            "Intentional damage to property"
        case .naturalDisaster:
            "Damage from earthquakes, hurricanes, tornados"
        case .accident:
            "Accidental damage to items"
        case .burglary:
            "Break-in with theft"
        case .windStorm:
            "Damage from wind or storms"
        case .generalLoss:
            "Other types of covered losses"
        }
    }

    public var requiredDocumentation: [String] {
        switch self {
        case .theft, .burglary:
            [
                "Police report number",
                "List of stolen items with values",
                "Photos of point of entry",
                "Security system logs (if available)",
            ]
        case .fire:
            [
                "Fire department report",
                "Photos of fire damage",
                "Smoke damage documentation",
                "Professional cleanup estimates",
            ]
        case .water:
            [
                "Photos of water damage",
                "Plumber's report (if applicable)",
                "Moisture readings",
                "Professional restoration estimate",
            ]
        case .vandalism:
            [
                "Police report",
                "Photos of vandalism damage",
                "Witness statements (if available)",
                "Repair estimates",
            ]
        case .naturalDisaster:
            [
                "Weather service reports",
                "Photos of storm damage",
                "Professional assessment",
                "Temporary repairs documentation",
            ]
        case .accident:
            [
                "Incident description",
                "Photos of damage",
                "Witness information",
                "Repair estimates",
            ]
        case .windStorm:
            [
                "Weather reports",
                "Photos of wind damage",
                "Roofing/structural assessment",
                "Emergency repair receipts",
            ]
        case .generalLoss:
            [
                "Detailed incident description",
                "Supporting documentation",
                "Photos of damage/loss",
                "Professional estimates",
            ]
        }
    }
}

// MARK: - Insurance Companies

public enum InsuranceCompany: String, CaseIterable {
    case stateFarm = "State Farm"
    case allstate = "Allstate"
    case geico = "GEICO"
    case progressive = "Progressive"
    case usaa = "USAA"
    case nationwide = "Nationwide"
    case farmers = "Farmers"
    case aaa = "AAA"
    case libertymutual = "Liberty Mutual"
    case travelers = "Travelers"
    case americanFamily = "American Family"
    case amica = "Amica"

    public var supportedClaimTypes: [ClaimType] {
        // Most companies support all claim types, with some exceptions
        switch self {
        case .usaa:
            // USAA has specific military/veteran requirements
            ClaimType.allCases
        default:
            ClaimType.allCases
        }
    }

    public var preferredFormat: ClaimDocumentFormat {
        switch self {
        case .stateFarm, .allstate:
            .standardPDF
        case .geico, .progressive:
            .structuredJSON
        case .usaa:
            .detailedPDF
        default:
            .standardPDF
        }
    }

    public var claimSubmissionURL: String? {
        switch self {
        case .stateFarm:
            "https://www.statefarm.com/claims"
        case .allstate:
            "https://www.allstate.com/claims"
        case .geico:
            "https://www.geico.com/claims"
        case .progressive:
            "https://www.progressive.com/claims"
        case .usaa:
            "https://www.usaa.com/inet/wc/banking_insurance_claims"
        default:
            nil
        }
    }
}

// MARK: - Document Formats

public enum ClaimDocumentFormat: String, CaseIterable {
    case standardPDF = "Standard PDF"
    case detailedPDF = "Detailed PDF"
    case structuredJSON = "Structured JSON"
    case spreadsheet = "Excel Spreadsheet"
    case htmlPackage = "HTML Package"

    public var fileExtension: String {
        switch self {
        case .standardPDF, .detailedPDF:
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

public struct ClaimRequest {
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

public struct ClaimContactInfo {
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

// MARK: - Generated Claim

public struct GeneratedClaim {
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

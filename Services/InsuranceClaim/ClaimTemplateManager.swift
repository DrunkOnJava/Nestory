//
// Layer: Services
// Module: InsuranceClaim
// Purpose: Manage insurance company specific templates and formatting
//

import Foundation
import UIKit

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with PDFKit - Advanced PDF template manipulation
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with CoreImage - Template image processing and watermarks

@MainActor
public struct ClaimTemplateManager {
    public enum TemplateError: LocalizedError {
        case templateNotFound
        case invalidTemplate
        case templateLoadingFailed
        case unsupportedCompany

        public var errorDescription: String? {
            switch self {
            case .templateNotFound:
                "Template not found for specified insurance company"
            case .invalidTemplate:
                "Template data is invalid or corrupted"
            case .templateLoadingFailed:
                "Failed to load template from storage"
            case .unsupportedCompany:
                "Insurance company not supported"
            }
        }
    }

    public init() {}

    // MARK: - Template Retrieval

    public func getTemplate(
        for company: InsuranceClaimService.InsuranceCompany,
        claimType: InsuranceClaimService.ClaimType
    ) throws -> ClaimTemplate {
        switch company {
        case .stateFarm:
            try getStateFarmTemplate(for: claimType)
        case .allstate:
            try getAllstateTemplate(for: claimType)
        case .geico:
            try getGeicoTemplate(for: claimType)
        case .progressive:
            try getProgressiveTemplate(for: claimType)
        case .nationwide:
            try getNationwideTemplate(for: claimType)
        case .farmersInsurance:
            try getFarmersTemplate(for: claimType)
        case .usaa:
            try getUSAATemplate(for: claimType)
        case .liberty:
            try getLibertyMutualTemplate(for: claimType)
        case .travelers:
            try getTravelersTemplate(for: claimType)
        case .amica:
            try getAmicaTemplate(for: claimType)
        case .generic:
            try getGenericTemplate(for: claimType)
        }
    }

    // MARK: - Company-Specific Templates

    private func getStateFarmTemplate(for claimType: InsuranceClaimService.ClaimType) throws -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "State Farm",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createStateFarmLogo(),
            headerText: "State Farm Insurance Company\nHome Inventory Claim",
            requiredFields: getStateFarmRequiredFields(for: claimType),
            formSections: getStateFarmSections(),
            legalDisclaimer: "I certify that the information provided is true and accurate to the best of my knowledge. I understand that any false statements may result in claim denial.",
            submissionInstructions: """
            Submit this claim form along with supporting documentation to:
            • Online: statefarm.com
            • Phone: 1-800-STATE-FARM (1-800-782-8332)
            • Mobile App: State Farm Mobile
            • Mail: State Farm Claims, P.O. Box 106110, Atlanta, GA 30348-6110
            """,
            contactInformation: "For questions, contact your State Farm agent or call 1-800-STATE-FARM",
            formatting: ClaimTemplate.FormattingOptions(
                primaryColor: "#FF0000", // State Farm Red
                secondaryColor: "#FFFFFF",
                fontFamily: "Arial",
                logoPosition: .topLeft,
                includeWatermark: true,
                pageMargins: 50
            )
        )
    }

    private func getAllstateTemplate(for claimType: InsuranceClaimService.ClaimType) throws -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "Allstate",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createAllstateLogo(),
            headerText: "Allstate Insurance Company\nProperty Loss Claim",
            requiredFields: getAllstateRequiredFields(for: claimType),
            formSections: getAllstateSections(),
            legalDisclaimer: "By signing below, I certify that the statements made in this claim are true and complete.",
            submissionInstructions: """
            Submit your claim:
            • Online: allstate.com
            • Phone: 1-800-ALLSTATE (1-800-255-7828)
            • Mobile App: Allstate Mobile with QuickFoto Claim
            • Email: Scan and email to claimdocs@allstate.com
            """,
            contactInformation: "Questions? Contact your Allstate agent or visit allstate.com",
            formatting: ClaimTemplate.FormattingOptions(
                primaryColor: "#004DA6", // Allstate Blue
                secondaryColor: "#FFFFFF",
                fontFamily: "Arial",
                logoPosition: .topCenter,
                includeWatermark: false,
                pageMargins: 40
            )
        )
    }

    private func getGeicoTemplate(for claimType: InsuranceClaimService.ClaimType) throws -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "GEICO",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createGeicoLogo(),
            headerText: "GEICO Insurance\nHome Inventory Claim Form",
            requiredFields: getGeicoRequiredFields(for: claimType),
            formSections: getGeicoSections(),
            legalDisclaimer: "I declare that the information provided is accurate and complete.",
            submissionInstructions: """
            File your claim:
            • Online: geico.com
            • Phone: 1-800-207-7847
            • Mobile App: GEICO Mobile
            • Use Digital Claims Assistant for step-by-step guidance
            """,
            contactInformation: "Need help? Call 1-800-207-7847 or chat at geico.com",
            formatting: ClaimTemplate.FormattingOptions(
                primaryColor: "#00A651", // GEICO Green
                secondaryColor: "#FFFFFF",
                fontFamily: "Helvetica",
                logoPosition: .topLeft,
                includeWatermark: true,
                pageMargins: 45
            )
        )
    }

    private func getUSAATemplate(for claimType: InsuranceClaimService.ClaimType) throws -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "USAA",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createUSAALogo(),
            headerText: "USAA\nProperty Insurance Claim\nServing Military Members and Their Families",
            requiredFields: getUSAARequiredFields(for: claimType),
            formSections: getUSAASections(),
            legalDisclaimer: "I affirm that I am a USAA member or eligible family member and that all information provided is truthful and accurate.",
            submissionInstructions: """
            Submit your claim:
            • Online: usaa.com
            • Phone: 1-800-531-USAA (8722)
            • Mobile App: USAA Mobile
            • Secure Message through usaa.com
            """,
            contactInformation: "Member Support: 1-800-531-USAA | usaa.com",
            formatting: ClaimTemplate.FormattingOptions(
                primaryColor: "#002F5F", // USAA Navy Blue
                secondaryColor: "#FFD100", // USAA Gold
                fontFamily: "Arial",
                logoPosition: .topCenter,
                includeWatermark: true,
                pageMargins: 50
            )
        )
    }

    private func getGenericTemplate(for claimType: InsuranceClaimService.ClaimType) throws -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "Insurance Company",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: nil,
            headerText: "Home Inventory Insurance Claim",
            requiredFields: getGenericRequiredFields(for: claimType),
            formSections: getGenericSections(),
            legalDisclaimer: "I certify that the information provided is true and accurate to the best of my knowledge.",
            submissionInstructions: """
            Submit this claim form to your insurance company:
            • Contact your insurance agent
            • Submit online through your insurer's website
            • Call your insurance company's claims department
            • Mail to the address provided by your insurer
            """,
            contactInformation: "Contact your insurance company for specific submission instructions",
            formatting: ClaimTemplate.FormattingOptions(
                primaryColor: "#007AFF",
                secondaryColor: "#FFFFFF",
                fontFamily: "Arial",
                logoPosition: .topLeft,
                includeWatermark: false,
                pageMargins: 50
            )
        )
    }

    // MARK: - Required Fields by Company

    private func getStateFarmRequiredFields(for claimType: InsuranceClaimService.ClaimType) -> [String] {
        var baseFields = [
            "Policy Number",
            "Claim Number (if assigned)",
            "Date of Loss",
            "Time of Loss",
            "Location of Loss",
            "Description of Loss",
            "Estimated Amount of Loss",
            "Contact Information",
        ]

        switch claimType {
        case .theft, .burglary:
            baseFields.append(contentsOf: ["Police Report Number", "Investigating Officer"])
        case .fire:
            baseFields.append(contentsOf: ["Fire Department Report", "Cause of Fire"])
        case .water:
            baseFields.append(contentsOf: ["Source of Water", "Mitigation Steps Taken"])
        default:
            break
        }

        return baseFields
    }

    private func getAllstateRequiredFields(for _: InsuranceClaimService.ClaimType) -> [String] {
        [
            "Policy Number",
            "Claim Number",
            "Date and Time of Loss",
            "Cause of Loss",
            "Property Address",
            "Description of Damaged Property",
            "Estimated Repair/Replacement Cost",
            "Photos of Damage",
            "Police Report (if applicable)",
        ]
    }

    private func getGeicoRequiredFields(for _: InsuranceClaimService.ClaimType) -> [String] {
        [
            "Policy Number",
            "Date of Loss",
            "Incident Description",
            "Property Location",
            "Contact Information",
            "List of Damaged Items",
            "Supporting Documentation",
            "Estimated Loss Amount",
        ]
    }

    private func getUSAARequiredFields(for claimType: InsuranceClaimService.ClaimType) -> [String] {
        var fields = [
            "USAA Policy Number",
            "Member Number",
            "Date of Loss",
            "Location of Loss",
            "Detailed Description",
            "Member Contact Information",
            "Emergency Contact",
            "Loss Amount Estimate",
        ]

        if claimType == .theft || claimType == .burglary {
            fields.append("Military Police/Local Police Report")
        }

        return fields
    }

    private func getGenericRequiredFields(for _: InsuranceClaimService.ClaimType) -> [String] {
        [
            "Policy Number",
            "Date of Loss",
            "Description of Loss",
            "Contact Information",
            "List of Items",
            "Supporting Documentation",
        ]
    }

    // MARK: - Form Sections

    private func getStateFarmSections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(title: "Policy Information", fields: ["Policy Number", "Agent Name", "Agent Phone"]),
            ClaimTemplate.FormSection(title: "Loss Information", fields: ["Date of Loss", "Time of Loss", "Cause of Loss"]),
            ClaimTemplate.FormSection(title: "Property Details", fields: ["Property Address", "Property Type", "Occupancy"]),
            ClaimTemplate.FormSection(title: "Damaged Items", fields: ["Item Description", "Age", "Cost to Repair/Replace"]),
            ClaimTemplate.FormSection(title: "Additional Information", fields: ["Other Insurance", "Previous Claims", "Comments"]),
        ]
    }

    private func getAllstateSections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(title: "Claim Details", fields: ["Claim Number", "Policy Number", "Date Reported"]),
            ClaimTemplate.FormSection(title: "Incident Information", fields: ["Date of Loss", "Cause of Loss", "Location"]),
            ClaimTemplate.FormSection(title: "Contact Information", fields: ["Insured Name", "Phone", "Email", "Address"]),
            ClaimTemplate.FormSection(title: "Property Inventory", fields: ["Item List", "Values", "Conditions"]),
            ClaimTemplate.FormSection(title: "Documentation", fields: ["Photos", "Receipts", "Estimates"]),
        ]
    }

    private func getGeicoSections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(title: "Policy & Contact", fields: ["Policy Number", "Contact Information"]),
            ClaimTemplate.FormSection(title: "Loss Details", fields: ["Date", "Time", "Location", "Description"]),
            ClaimTemplate.FormSection(title: "Damaged Property", fields: ["Item Inventory", "Damage Assessment"]),
            ClaimTemplate.FormSection(title: "Supporting Documents", fields: ["Photos", "Receipts", "Reports"]),
        ]
    }

    private func getUSAASections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(title: "Member Information", fields: ["USAA Number", "Policy Number", "Rank/Branch"]),
            ClaimTemplate.FormSection(title: "Incident Details", fields: ["Date", "Location", "Circumstances"]),
            ClaimTemplate.FormSection(title: "Property Inventory", fields: ["Military Equipment", "Personal Property", "Values"]),
            ClaimTemplate.FormSection(title: "Military Considerations", fields: ["Deployment Status", "PCS Orders", "BAH Information"]),
        ]
    }

    private func getGenericSections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(title: "Policy Information", fields: ["Policy Number", "Coverage Type"]),
            ClaimTemplate.FormSection(title: "Loss Information", fields: ["Date", "Cause", "Description"]),
            ClaimTemplate.FormSection(title: "Contact Information", fields: ["Name", "Phone", "Email", "Address"]),
            ClaimTemplate.FormSection(title: "Item Details", fields: ["Inventory", "Values", "Documentation"]),
        ]
    }

    // MARK: - Logo Generation (Placeholder)

    private func createStateFarmLogo() -> Data? {
        createPlaceholderLogo(text: "State Farm", color: UIColor.red)
    }

    private func createAllstateLogo() -> Data? {
        createPlaceholderLogo(text: "Allstate", color: UIColor.blue)
    }

    private func createGeicoLogo() -> Data? {
        createPlaceholderLogo(text: "GEICO", color: UIColor.green)
    }

    private func createUSAALogo() -> Data? {
        createPlaceholderLogo(text: "USAA", color: UIColor(red: 0, green: 0.19, blue: 0.37, alpha: 1))
    }

    private func createPlaceholderLogo(text: String, color: UIColor) -> Data? {
        let size = CGSize(width: 200, height: 60)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            // Background
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.white,
            ]

            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            text.draw(in: textRect, withAttributes: attributes)
        }

        return image.pngData()
    }

    // MARK: - Template Validation

    public func validateTemplate(_ template: ClaimTemplate) -> [String] {
        var issues: [String] = []

        if template.companyName.isEmpty {
            issues.append("Company name is required")
        }

        if template.requiredFields.isEmpty {
            issues.append("At least one required field must be specified")
        }

        if template.formSections.isEmpty {
            issues.append("At least one form section must be defined")
        }

        if template.legalDisclaimer.isEmpty {
            issues.append("Legal disclaimer is required")
        }

        return issues
    }

    // MARK: - Template Customization

    public func customizeTemplate(
        _ template: ClaimTemplate,
        with customizations: TemplateCustomizations
    ) -> ClaimTemplate {
        var customized = template

        if let headerText = customizations.customHeaderText {
            customized.headerText = headerText
        }

        if let disclaimer = customizations.customDisclaimer {
            customized.legalDisclaimer = disclaimer
        }

        if let formatting = customizations.formatting {
            customized.formatting = formatting
        }

        if !customizations.additionalFields.isEmpty {
            customized.requiredFields.append(contentsOf: customizations.additionalFields)
        }

        return customized
    }
}

// MARK: - Supporting Types

public struct ClaimTemplate {
    public let id: UUID
    public var companyName: String
    public let claimType: InsuranceClaimService.ClaimType
    public let templateVersion: String
    public let logoData: Data?
    public var headerText: String
    public var requiredFields: [String]
    public let formSections: [FormSection]
    public var legalDisclaimer: String
    public let submissionInstructions: String
    public let contactInformation: String
    public var formatting: FormattingOptions

    public struct FormSection {
        public let title: String
        public let fields: [String]

        public init(title: String, fields: [String]) {
            self.title = title
            self.fields = fields
        }
    }

    public struct FormattingOptions {
        public let primaryColor: String
        public let secondaryColor: String
        public let fontFamily: String
        public let logoPosition: LogoPosition
        public let includeWatermark: Bool
        public let pageMargins: CGFloat

        public enum LogoPosition {
            case topLeft, topCenter, topRight
        }

        public init(
            primaryColor: String,
            secondaryColor: String,
            fontFamily: String,
            logoPosition: LogoPosition,
            includeWatermark: Bool,
            pageMargins: CGFloat
        ) {
            self.primaryColor = primaryColor
            self.secondaryColor = secondaryColor
            self.fontFamily = fontFamily
            self.logoPosition = logoPosition
            self.includeWatermark = includeWatermark
            self.pageMargins = pageMargins
        }
    }
}

public struct TemplateCustomizations {
    public let customHeaderText: String?
    public let customDisclaimer: String?
    public let additionalFields: [String]
    public let formatting: ClaimTemplate.FormattingOptions?

    public init(
        customHeaderText: String? = nil,
        customDisclaimer: String? = nil,
        additionalFields: [String] = [],
        formatting: ClaimTemplate.FormattingOptions? = nil
    ) {
        self.customHeaderText = customHeaderText
        self.customDisclaimer = customDisclaimer
        self.additionalFields = additionalFields
        self.formatting = formatting
    }
}

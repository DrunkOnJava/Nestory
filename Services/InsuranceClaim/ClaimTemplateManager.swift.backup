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
        for company: InsuranceCompany,
        claimType: ClaimType
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
        case .farmers:
            try getFarmersTemplate(for: claimType)
        case .usaa:
            try getUSAATemplate(for: claimType)
        case .libertymutual:
            try getLibertyMutualTemplate(for: claimType)
        case .travelers:
            try getTravelersTemplate(for: claimType)
        case .aig:
            try getAIGTemplate(for: claimType)
        case .amica:
            try getAmicaTemplate(for: claimType)
        case .aaa:
            try getAAATemplate(for: claimType)
        case .other:
            try getGenericTemplate(for: claimType)
        }
    }

    // MARK: - Company-Specific Templates

    private func getStateFarmTemplate(for claimType: ClaimType) throws -> ClaimTemplate {
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

    private func getAllstateTemplate(for claimType: ClaimType) throws -> ClaimTemplate {
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

    private func getGeicoTemplate(for claimType: ClaimType) throws -> ClaimTemplate {
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

    private func getUSAATemplate(for claimType: ClaimType) throws -> ClaimTemplate {
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

    private func getProgressiveTemplate(for claimType: ClaimType) throws -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "Progressive",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createProgressiveLogo(),
            headerText: "Progressive Insurance\nProperty Claim Form",
            requiredFields: getProgressiveRequiredFields(for: claimType),
            formSections: getProgressiveSections(),
            legalDisclaimer: "I certify that the information provided is true and accurate.",
            submissionInstructions: """
            Submit your claim:
            • Online: progressive.com
            • Phone: 1-800-PROGRESSIVE (1-800-776-4737)
            • Mobile App: Progressive Mobile
            """,
            contactInformation: "Questions? Call 1-800-PROGRESSIVE or visit progressive.com",
            formatting: ClaimTemplate.FormattingOptions(
                primaryColor: "#005BAA",
                secondaryColor: "#FFFFFF",
                fontFamily: "Arial",
                logoPosition: .topLeft,
                includeWatermark: false,
                pageMargins: 45
            )
        )
    }

    private func getNationwideTemplate(for claimType: ClaimType) throws -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "Nationwide",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createNationwideLogo(),
            headerText: "Nationwide Insurance\nHome Inventory Claim",
            requiredFields: getNationwideRequiredFields(for: claimType),
            formSections: getNationwideSections(),
            legalDisclaimer: "I declare that the statements made are true to the best of my knowledge.",
            submissionInstructions: """
            File your claim:
            • Online: nationwide.com
            • Phone: 1-877-On Your Side (1-877-669-6877)
            • Mobile App: Nationwide Mobile
            """,
            contactInformation: "Need assistance? Call 1-877-669-6877",
            formatting: ClaimTemplate.FormattingOptions(
                primaryColor: "#003DA5",
                secondaryColor: "#FFFFFF",
                fontFamily: "Arial",
                logoPosition: .topCenter,
                includeWatermark: true,
                pageMargins: 50
            )
        )
    }

    private func getFarmersTemplate(for claimType: ClaimType) throws -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "Farmers Insurance",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createFarmersLogo(),
            headerText: "Farmers Insurance Group\nProperty Loss Claim",
            requiredFields: getFarmersRequiredFields(for: claimType),
            formSections: getFarmersSections(),
            legalDisclaimer: "I certify that the information provided is complete and accurate.",
            submissionInstructions: """
            Submit your claim:
            • Online: farmers.com
            • Phone: 1-800-FARMERS (1-800-327-6377)
            • Mobile App: Farmers Insurance Mobile
            """,
            contactInformation: "Contact your Farmers agent or call 1-800-327-6377",
            formatting: ClaimTemplate.FormattingOptions(
                primaryColor: "#C8102E",
                secondaryColor: "#FFFFFF",
                fontFamily: "Arial",
                logoPosition: .topLeft,
                includeWatermark: true,
                pageMargins: 50
            )
        )
    }

    private func getLibertyMutualTemplate(for claimType: ClaimType) throws -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "Liberty Mutual",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createLibertyMutualLogo(),
            headerText: "Liberty Mutual Insurance\nProperty Insurance Claim",
            requiredFields: getLibertyMutualRequiredFields(for: claimType),
            formSections: getLibertyMutualSections(),
            legalDisclaimer: "I affirm that all information provided is true and complete.",
            submissionInstructions: """
            Submit your claim:
            • Online: libertymutual.com
            • Phone: 1-800-225-2467
            • Mobile App: Liberty Mutual Mobile
            """,
            contactInformation: "Questions? Call 1-800-225-2467 or contact your agent",
            formatting: ClaimTemplate.FormattingOptions(
                primaryColor: "#FFD100",
                secondaryColor: "#000000",
                fontFamily: "Arial",
                logoPosition: .topCenter,
                includeWatermark: false,
                pageMargins: 45
            )
        )
    }

    private func getTravelersTemplate(for claimType: ClaimType) throws -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "Travelers",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createTravelersLogo(),
            headerText: "Travelers Insurance\nProperty Claim Documentation",
            requiredFields: getTravelersRequiredFields(for: claimType),
            formSections: getTravelersSections(),
            legalDisclaimer: "I certify that the information provided is accurate and complete.",
            submissionInstructions: """
            Submit your claim:
            • Online: travelers.com
            • Phone: 1-800-TRAVELERS (1-800-872-8356)
            • Mobile App: Travelers Mobile
            """,
            contactInformation: "Need help? Call 1-800-872-8356 or visit travelers.com",
            formatting: ClaimTemplate.FormattingOptions(
                primaryColor: "#D71921",
                secondaryColor: "#FFFFFF",
                fontFamily: "Arial",
                logoPosition: .topLeft,
                includeWatermark: true,
                pageMargins: 50
            )
        )
    }

    private func getAIGTemplate(for claimType: ClaimType) throws -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "AIG",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createAIGLogo(),
            headerText: "AIG Insurance\nProperty Loss Claim Form",
            requiredFields: getAIGRequiredFields(for: claimType),
            formSections: getAIGSections(),
            legalDisclaimer: "I declare that all statements made are true and accurate.",
            submissionInstructions: """
            Submit your claim:
            • Online: aig.com
            • Phone: 1-877-638-4244
            • Email: claims@aig.com
            """,
            contactInformation: "For assistance, call 1-877-638-4244",
            formatting: ClaimTemplate.FormattingOptions(
                primaryColor: "#001F5C",
                secondaryColor: "#FFFFFF",
                fontFamily: "Arial",
                logoPosition: .topCenter,
                includeWatermark: true,
                pageMargins: 50
            )
        )
    }

    private func getAmicaTemplate(for claimType: ClaimType) throws -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "Amica Mutual",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createAmicaLogo(),
            headerText: "Amica Mutual Insurance\nHome Insurance Claim",
            requiredFields: getAmicaRequiredFields(for: claimType),
            formSections: getAmicaSections(),
            legalDisclaimer: "I certify that the information provided is true and accurate.",
            submissionInstructions: """
            Submit your claim:
            • Online: amica.com
            • Phone: 1-800-242-6422
            • Mobile App: Amica Mobile
            """,
            contactInformation: "Questions? Call 1-800-242-6422 or visit amica.com",
            formatting: ClaimTemplate.FormattingOptions(
                primaryColor: "#0066CC",
                secondaryColor: "#FFFFFF",
                fontFamily: "Arial",
                logoPosition: .topLeft,
                includeWatermark: false,
                pageMargins: 45
            )
        )
    }

    private func getAAATemplate(for claimType: ClaimType) throws -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "AAA Insurance",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createAALogo(),
            headerText: "AAA Insurance\nProperty Insurance Claim",
            requiredFields: getAAARequiredFields(for: claimType),
            formSections: getAAASections(),
            legalDisclaimer: "I certify that all information provided is true and complete.",
            submissionInstructions: """
            Submit your claim:
            • Online: aaa.com
            • Phone: 1-800-AAA-HELP (1-800-222-4357)
            • Visit your local AAA branch
            """,
            contactInformation: "Member services: 1-800-222-4357 or aaa.com",
            formatting: ClaimTemplate.FormattingOptions(
                primaryColor: "#004F9F",
                secondaryColor: "#FFFFFF",
                fontFamily: "Arial",
                logoPosition: .topCenter,
                includeWatermark: true,
                pageMargins: 50
            )
        )
    }

    private func getGenericTemplate(for claimType: ClaimType) throws -> ClaimTemplate {
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

    private func getStateFarmRequiredFields(for claimType: ClaimType) -> [String] {
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

    private func getAllstateRequiredFields(for _: ClaimType) -> [String] {
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

    private func getGeicoRequiredFields(for _: ClaimType) -> [String] {
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

    private func getUSAARequiredFields(for claimType: ClaimType) -> [String] {
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

    private func getProgressiveRequiredFields(for _: ClaimType) -> [String] {
        [
            "Policy Number",
            "Claim Number",
            "Date and Time of Loss",
            "Location of Incident",
            "Description of Damage",
            "Photos and Documentation",
            "Contact Information",
            "Estimated Cost of Repair",
        ]
    }

    private func getNationwideRequiredFields(for _: ClaimType) -> [String] {
        [
            "Policy Number",
            "Date of Loss",
            "Time of Loss",
            "Cause of Loss",
            "Property Location",
            "Description of Damage",
            "Contact Information",
            "Supporting Documents",
        ]
    }

    private func getFarmersRequiredFields(for claimType: ClaimType) -> [String] {
        var fields = [
            "Policy Number",
            "Date of Loss",
            "Location of Loss",
            "Description of Loss",
            "Contact Information",
            "Estimated Loss Value",
            "Photos of Damage",
        ]

        if claimType == .theft || claimType == .burglary {
            fields.append("Police Report Number")
        }

        return fields
    }

    private func getLibertyMutualRequiredFields(for _: ClaimType) -> [String] {
        [
            "Policy Number",
            "Date of Incident",
            "Location of Loss",
            "Cause of Damage",
            "Description of Items",
            "Contact Information",
            "Repair Estimates",
            "Supporting Documentation",
        ]
    }

    private func getTravelersRequiredFields(for _: ClaimType) -> [String] {
        [
            "Policy Number",
            "Date of Loss",
            "Time of Loss",
            "Location of Property",
            "Cause and Description",
            "Contact Information",
            "Property Inventory",
            "Documentation and Photos",
        ]
    }

    private func getAIGRequiredFields(for _: ClaimType) -> [String] {
        [
            "Policy Number",
            "Date of Loss",
            "Location of Loss",
            "Description of Incident",
            "Contact Information",
            "Property Details",
            "Supporting Evidence",
            "Loss Amount Estimate",
        ]
    }

    private func getAmicaRequiredFields(for _: ClaimType) -> [String] {
        [
            "Policy Number",
            "Date of Loss",
            "Location of Incident",
            "Description of Damage",
            "Contact Information",
            "Property Inventory",
            "Photos and Documentation",
            "Estimated Replacement Cost",
        ]
    }

    private func getAAARequiredFields(for _: ClaimType) -> [String] {
        [
            "AAA Membership Number",
            "Policy Number",
            "Date of Loss",
            "Location of Property",
            "Description of Loss",
            "Contact Information",
            "Supporting Documents",
            "Estimated Repair Cost",
        ]
    }

    private func getGenericRequiredFields(for _: ClaimType) -> [String] {
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

    private func getProgressiveSections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(title: "Policy Details", fields: ["Policy Number", "Coverage Type", "Deductible"]),
            ClaimTemplate.FormSection(title: "Incident Information", fields: ["Date", "Time", "Location", "Cause"]),
            ClaimTemplate.FormSection(title: "Contact Information", fields: ["Name", "Phone", "Email", "Address"]),
            ClaimTemplate.FormSection(title: "Property Information", fields: ["Damaged Items", "Estimated Values", "Photos"]),
            ClaimTemplate.FormSection(title: "Additional Details", fields: ["Police Report", "Witnesses", "Other Insurance"]),
        ]
    }

    private func getNationwideSections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(title: "Policy Information", fields: ["Policy Number", "Agent Information"]),
            ClaimTemplate.FormSection(title: "Loss Details", fields: ["Date", "Time", "Location", "Cause"]),
            ClaimTemplate.FormSection(title: "Contact Information", fields: ["Insured Name", "Phone", "Email"]),
            ClaimTemplate.FormSection(title: "Property Damage", fields: ["Item List", "Damage Assessment", "Photos"]),
            ClaimTemplate.FormSection(title: "Supporting Documents", fields: ["Receipts", "Estimates", "Reports"]),
        ]
    }

    private func getFarmersSections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(title: "Policy & Agent", fields: ["Policy Number", "Agent Name", "Agent Contact"]),
            ClaimTemplate.FormSection(title: "Incident Details", fields: ["Date", "Time", "Location", "Description"]),
            ClaimTemplate.FormSection(title: "Contact Information", fields: ["Name", "Phone", "Email", "Address"]),
            ClaimTemplate.FormSection(title: "Damaged Property", fields: ["Item Inventory", "Values", "Condition"]),
            ClaimTemplate.FormSection(title: "Documentation", fields: ["Photos", "Receipts", "Police Reports"]),
        ]
    }

    private func getLibertyMutualSections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(title: "Policy Information", fields: ["Policy Number", "Coverage Details"]),
            ClaimTemplate.FormSection(title: "Incident Information", fields: ["Date", "Location", "Cause", "Description"]),
            ClaimTemplate.FormSection(title: "Contact Details", fields: ["Name", "Phone", "Email", "Address"]),
            ClaimTemplate.FormSection(title: "Property Details", fields: ["Damaged Items", "Replacement Values"]),
            ClaimTemplate.FormSection(title: "Supporting Evidence", fields: ["Photos", "Documents", "Estimates"]),
        ]
    }

    private func getTravelersSections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(title: "Policy Information", fields: ["Policy Number", "Coverage Type"]),
            ClaimTemplate.FormSection(title: "Loss Information", fields: ["Date", "Time", "Location", "Circumstances"]),
            ClaimTemplate.FormSection(title: "Contact Information", fields: ["Insured Name", "Phone", "Email"]),
            ClaimTemplate.FormSection(title: "Property Inventory", fields: ["Item Details", "Values", "Age"]),
            ClaimTemplate.FormSection(title: "Documentation", fields: ["Photos", "Receipts", "Repair Estimates"]),
        ]
    }

    private func getAIGSections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(title: "Policy Details", fields: ["Policy Number", "Effective Dates"]),
            ClaimTemplate.FormSection(title: "Loss Information", fields: ["Date", "Location", "Cause", "Description"]),
            ClaimTemplate.FormSection(title: "Contact Information", fields: ["Name", "Phone", "Email", "Address"]),
            ClaimTemplate.FormSection(title: "Property Assessment", fields: ["Damaged Items", "Values", "Condition"]),
            ClaimTemplate.FormSection(title: "Supporting Materials", fields: ["Photos", "Documents", "Expert Reports"]),
        ]
    }

    private func getAmicaSections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(title: "Policy Information", fields: ["Policy Number", "Coverage Limits"]),
            ClaimTemplate.FormSection(title: "Incident Details", fields: ["Date", "Time", "Location", "Description"]),
            ClaimTemplate.FormSection(title: "Contact Information", fields: ["Name", "Phone", "Email"]),
            ClaimTemplate.FormSection(title: "Property Information", fields: ["Item List", "Values", "Photos"]),
            ClaimTemplate.FormSection(title: "Additional Information", fields: ["Receipts", "Estimates", "Other Details"]),
        ]
    }

    private func getAAASections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(title: "Membership & Policy", fields: ["AAA Number", "Policy Number", "Coverage"]),
            ClaimTemplate.FormSection(title: "Incident Information", fields: ["Date", "Location", "Cause", "Description"]),
            ClaimTemplate.FormSection(title: "Contact Information", fields: ["Member Name", "Phone", "Email"]),
            ClaimTemplate.FormSection(title: "Property Details", fields: ["Damaged Items", "Values", "Documentation"]),
            ClaimTemplate.FormSection(title: "Supporting Documents", fields: ["Photos", "Receipts", "Estimates"]),
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

    private func createProgressiveLogo() -> Data? {
        createPlaceholderLogo(text: "Progressive", color: UIColor(red: 0, green: 0.36, blue: 0.67, alpha: 1))
    }

    private func createNationwideLogo() -> Data? {
        createPlaceholderLogo(text: "Nationwide", color: UIColor(red: 0, green: 0.24, blue: 0.65, alpha: 1))
    }

    private func createFarmersLogo() -> Data? {
        createPlaceholderLogo(text: "Farmers", color: UIColor(red: 0.78, green: 0.06, blue: 0.18, alpha: 1))
    }

    private func createLibertyMutualLogo() -> Data? {
        createPlaceholderLogo(text: "Liberty Mutual", color: UIColor(red: 1.0, green: 0.82, blue: 0, alpha: 1))
    }

    private func createTravelersLogo() -> Data? {
        createPlaceholderLogo(text: "Travelers", color: UIColor(red: 0.84, green: 0.10, blue: 0.13, alpha: 1))
    }

    private func createAIGLogo() -> Data? {
        createPlaceholderLogo(text: "AIG", color: UIColor(red: 0, green: 0.12, blue: 0.36, alpha: 1))
    }

    private func createAmicaLogo() -> Data? {
        createPlaceholderLogo(text: "Amica", color: UIColor(red: 0, green: 0.40, blue: 0.80, alpha: 1))
    }

    private func createAALogo() -> Data? {
        createPlaceholderLogo(text: "AAA", color: UIColor(red: 0, green: 0.31, blue: 0.62, alpha: 1))
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
    public let claimType: ClaimType
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

//
// Layer: Services
// Module: InsuranceClaimValidation
// Purpose: Validation logic and utility functions for insurance claims
//

import Foundation

public enum InsuranceClaimValidator {
    // MARK: - Validation Functions

    public static func validateClaimRequest(_ request: ClaimRequest) throws {
        guard !request.items.isEmpty else {
            throw ClaimError.noItemsSelected
        }

        guard !request.contactInfo.name.isEmpty else {
            throw ClaimError.missingRequiredFields
        }

        guard !request.incidentDescription.isEmpty else {
            throw ClaimError.missingRequiredFields
        }
    }

    public static func validateItemsForClaim(items: [Item]) -> [String] {
        var issues: [String] = []

        for item in items {
            if item.imageData == nil {
                issues.append("Missing photo for: \(item.name)")
            }
            if item.purchasePrice == nil {
                issues.append("Missing value for: \(item.name)")
            }
            if item.purchaseDate == nil {
                issues.append("Missing purchase date for: \(item.name)")
            }
        }

        return issues
    }

    // MARK: - Utility Functions

    public static func estimateClaimValue(items: [Item]) -> Decimal {
        items.compactMap(\.purchasePrice).reduce(0, +)
    }

    public static func getSupportedCompanies(for claimType: ClaimType) -> [InsuranceCompany] {
        InsuranceCompany.allCases.filter { company in
            company.supportedClaimTypes.contains(claimType)
        }
    }

    public static func getRequiredDocumentation(for claimType: ClaimType) -> [String] {
        claimType.requiredDocumentation
    }

    // MARK: - Filename Generation

    public static func generateFilename(for request: ClaimRequest) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: request.incidentDate)

        let claimTypeFormatted = request.claimType.rawValue.replacingOccurrences(of: " ", with: "_")
        let companyFormatted = request.insuranceCompany.rawValue.replacingOccurrences(of: " ", with: "_")

        let fileExtension = request.format.fileExtension

        return "Insurance_Claim_\(claimTypeFormatted)_\(companyFormatted)_\(dateString).\(fileExtension)"
    }

    // MARK: - Checklist Generation

    public static func generateChecklist(for request: ClaimRequest) -> [String] {
        var checklist = [
            "✓ Review all item details for accuracy",
            "✓ Verify contact information is current",
            "✓ Include all required documentation",
            "✓ Take photos of any additional damage",
        ]

        checklist.append(contentsOf: request.claimType.requiredDocumentation.map { "□ \($0)" })

        if request.policyNumber != nil {
            checklist.append("✓ Policy number included")
        } else {
            checklist.append("□ Obtain policy number from insurance company")
        }

        return checklist
    }

    // MARK: - Submission Instructions

    public static func generateSubmissionInstructions(for request: ClaimRequest) -> String {
        let companyName = request.insuranceCompany.rawValue

        var instructions = """
        SUBMISSION INSTRUCTIONS FOR \(companyName.uppercased())

        1. Review the generated claim document thoroughly
        2. Gather all required supporting documentation
        3. Contact your insurance agent or company claims department
        4. Submit claim via preferred method (online, phone, or mail)

        """

        switch request.insuranceCompany {
        case .stateFarm:
            instructions += """
            State Farm Specific:
            • File online at statefarm.com or call 1-800-STATE-FARM
            • Have your policy number ready
            • Upload photos through their mobile app
            """
        case .allstate:
            instructions += """
            Allstate Specific:
            • File online at allstate.com or call 1-800-ALLSTATE
            • Use QuickFoto Claim for photo uploads
            • Track claim status through MyAccount
            """
        case .geico:
            instructions += """
            GEICO Specific:
            • File online at geico.com or call 1-800-207-7847
            • Upload documents through GEICO Mobile app
            • Use Digital Claims Assistant for guidance
            """
        case .progressive:
            instructions += """
            Progressive Specific:
            • File online at progressive.com or call 1-800-274-4499
            • Use Snapshot app for photo uploads
            • Track claims through online account
            """
        case .usaa:
            instructions += """
            USAA Specific:
            • File online at usaa.com or call 1-800-531-USAA
            • Use USAA Mobile app for complete claim management
            • Access military-specific claim assistance
            """
        case .nationwide:
            instructions += """
            Nationwide Specific:
            • File online at nationwide.com or call 1-800-421-3535
            • Use SmartRide app for documentation
            • Access On Your Side claim assistance
            """
        case .farmers:
            instructions += """
            Farmers Specific:
            • File online at farmers.com or call 1-800-435-7764
            • Use Farmers mobile app for photos
            • Contact your local Farmers agent
            """
        case .libertymutual:
            instructions += """
            Liberty Mutual Specific:
            • File online at libertymutual.com or call 1-800-225-2467
            • Use Liberty Mutual mobile app
            • Access 24/7 claim reporting
            """
        case .travelers:
            instructions += """
            Travelers Specific:
            • File online at travelers.com or call 1-800-252-4633
            • Use Travelers mobile app for claim management
            • Access IntelliDrive claim features
            """
        case .amica:
            instructions += """
            Amica Specific:
            • File online at amica.com or call 1-800-242-6422
            • Use Amica mobile app for documentation
            • Access personalized claim service
            """
        default:
            instructions += """
            General Guidelines:
            • Contact your insurance company directly
            • Keep copies of all submitted documents
            • Follow up if you don't receive confirmation within 24-48 hours
            """
        }

        return instructions
    }
}

// MARK: - Error Types

public enum ClaimError: Error, LocalizedError {
    case noItemsSelected
    case invalidClaimType
    case templateNotFound
    case documentGenerationFailed
    case missingRequiredFields
    case invalidInsuranceCompany

    public var errorDescription: String? {
        switch self {
        case .noItemsSelected:
            "Please select items for the claim"
        case .invalidClaimType:
            "Invalid claim type selected"
        case .templateNotFound:
            "Template not found for selected insurance company"
        case .documentGenerationFailed:
            "Failed to generate claim document"
        case .missingRequiredFields:
            "Required claim information is missing"
        case .invalidInsuranceCompany:
            "Invalid insurance company selected"
        }
    }
}

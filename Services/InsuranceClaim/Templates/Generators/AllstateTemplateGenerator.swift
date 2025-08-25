//
// Layer: Services
// Module: InsuranceClaim/Templates/Generators
// Purpose: Allstate specific template generation and configuration
//

import Foundation
import UIKit

public struct AllstateTemplateGenerator {
    
    public init() {}
    
    public func createTemplate(for claimType: ClaimType) -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "Allstate",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createAllstateLogo(),
            headerText: "Allstate Insurance Company\nProperty Loss Claim",
            requiredFields: getRequiredFields(for: claimType),
            formSections: getFormSections(),
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
    
    private func getRequiredFields(for claimType: ClaimType) -> [String] {
        var fields = [
            "Policy Number",
            "Date of Loss",
            "Incident Description",
            "Property Location",
            "Contact Information",
            "List of Damaged Items",
            "Supporting Documentation",
            "Estimated Loss Amount",
        ]
        
        if claimType == .theft || claimType == .burglary {
            fields.append("Police Report Details")
        }
        
        return fields
    }
    
    private func getFormSections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(
                title: "Policyholder Information",
                fields: ["Policy Number", "Name", "Address", "Phone", "Email"]
            ),
            ClaimTemplate.FormSection(
                title: "Incident Details",
                fields: ["Date of Loss", "Location", "Cause", "Description"]
            ),
            ClaimTemplate.FormSection(
                title: "Damaged Property",
                fields: ["Item List", "Purchase Information", "Current Value", "Damage Assessment"]
            ),
            ClaimTemplate.FormSection(
                title: "Documentation",
                fields: ["Photos", "Receipts", "Estimates", "Additional Evidence"]
            ),
        ]
    }
    
    private func createAllstateLogo() -> Data? {
        let logoText = "Allstate"
        let image = UIGraphicsImageRenderer(size: CGSize(width: 180, height: 60))
            .image { context in
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 26),
                    .foregroundColor: UIColor(red: 0.0, green: 0.302, blue: 0.651, alpha: 1.0), // Allstate Blue
                ]
                
                let textSize = logoText.size(withAttributes: attributes)
                let textRect = CGRect(
                    x: (180 - textSize.width) / 2,
                    y: (60 - textSize.height) / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                
                logoText.draw(in: textRect, withAttributes: attributes)
            }
        
        return image.pngData()
    }
}
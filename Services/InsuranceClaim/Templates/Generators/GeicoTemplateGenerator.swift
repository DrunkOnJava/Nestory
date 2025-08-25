//
// Layer: Services
// Module: InsuranceClaim/Templates/Generators
// Purpose: GEICO specific template generation and configuration
//

import Foundation
import UIKit

public struct GeicoTemplateGenerator {
    
    public init() {}
    
    public func createTemplate(for claimType: ClaimType) -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "GEICO",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createGeicoLogo(),
            headerText: "GEICO Insurance\nHome Inventory Claim Form",
            requiredFields: getRequiredFields(for: claimType),
            formSections: getFormSections(),
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
            fields.append("Police Report Information")
        }
        
        return fields
    }
    
    private func getFormSections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(
                title: "Policy Details",
                fields: ["GEICO Policy Number", "Policyholder Name", "Contact Information"]
            ),
            ClaimTemplate.FormSection(
                title: "Loss Information",
                fields: ["Date and Time", "Location", "Cause", "Detailed Description"]
            ),
            ClaimTemplate.FormSection(
                title: "Property Inventory",
                fields: ["Item Details", "Purchase Information", "Replacement Cost", "Damage Level"]
            ),
            ClaimTemplate.FormSection(
                title: "Supporting Evidence",
                fields: ["Photographs", "Receipts", "Estimates", "Police Report (if applicable)"]
            ),
        ]
    }
    
    private func createGeicoLogo() -> Data? {
        let logoText = "GEICO"
        let image = UIGraphicsImageRenderer(size: CGSize(width: 160, height: 60))
            .image { context in
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 28),
                    .foregroundColor: UIColor(red: 0.0, green: 0.651, blue: 0.318, alpha: 1.0), // GEICO Green
                ]
                
                let textSize = logoText.size(withAttributes: attributes)
                let textRect = CGRect(
                    x: (160 - textSize.width) / 2,
                    y: (60 - textSize.height) / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                
                logoText.draw(in: textRect, withAttributes: attributes)
            }
        
        return image.pngData()
    }
}
//
// Layer: Services  
// Module: InsuranceClaim/Templates/Generators
// Purpose: Generic template generation for unsupported insurance companies
//

import Foundation
import UIKit

public struct GenericTemplateGenerator {
    
    public init() {}
    
    public func createTemplate(for claimType: ClaimType) -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "Insurance Company",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createGenericLogo(),
            headerText: "Insurance Claim Form\nHome Inventory Documentation",
            requiredFields: getGenericRequiredFields(for: claimType),
            formSections: getGenericFormSections(),
            legalDisclaimer: "I certify that the information provided in this claim is true and accurate to the best of my knowledge. I understand that providing false information may result in claim denial or policy cancellation.",
            submissionInstructions: """
            Submit this completed form to your insurance company using your preferred method:
            • Online portal or website
            • Email to your claims representative
            • Mail to the address provided by your insurer
            • In-person at a local office
            """,
            contactInformation: "Contact your insurance agent or company representative for assistance",
            formatting: ClaimTemplate.FormattingOptions(
                primaryColor: "#2E3B4E", // Professional Navy
                secondaryColor: "#FFFFFF",
                fontFamily: "Arial",
                logoPosition: .topCenter,
                includeWatermark: false,
                pageMargins: 50
            )
        )
    }
    
    private func getGenericRequiredFields(for claimType: ClaimType) -> [String] {
        var fields = [
            "Policy Number",
            "Policy Holder Name",
            "Date of Loss",
            "Time of Loss",
            "Cause of Loss",
            "Location of Loss",
            "Description of Damage",
            "Contact Information",
            "Estimated Loss Value",
            "Supporting Documentation",
        ]
        
        if claimType == .theft || claimType == .burglary {
            fields.append("Police Report Filed")
            fields.append("Police Report Number")
        }
        
        if claimType == .fire {
            fields.append("Fire Department Response")
        }
        
        if claimType == .flood || claimType == .water {
            fields.append("Water Source Information")
            fields.append("Mitigation Efforts")
        }
        
        return fields
    }
    
    private func getGenericFormSections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(
                title: "Policy Information",
                fields: ["Policy Number", "Policy Holder", "Agent Contact", "Coverage Details"]
            ),
            ClaimTemplate.FormSection(
                title: "Incident Information",
                fields: ["Date of Loss", "Time of Loss", "Cause", "Location", "Weather Conditions"]
            ),
            ClaimTemplate.FormSection(
                title: "Property Details",
                fields: ["Item Description", "Age", "Purchase Price", "Current Value", "Condition Before Loss"]
            ),
            ClaimTemplate.FormSection(
                title: "Damage Assessment",
                fields: ["Extent of Damage", "Repair Estimate", "Replacement Cost", "Salvage Value"]
            ),
            ClaimTemplate.FormSection(
                title: "Supporting Documentation",
                fields: ["Photographs", "Receipts", "Appraisals", "Repair Estimates", "Police Reports"]
            ),
            ClaimTemplate.FormSection(
                title: "Additional Information",
                fields: ["Witness Information", "Previous Claims", "Security Measures", "Comments"]
            ),
        ]
    }
    
    private func createGenericLogo() -> Data? {
        let logoText = "INSURANCE"
        let image = UIGraphicsImageRenderer(size: CGSize(width: 220, height: 60))
            .image { context in
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 24, weight: .medium),
                    .foregroundColor: UIColor(red: 0.180, green: 0.231, blue: 0.306, alpha: 1.0), // Professional Navy
                ]
                
                let textSize = logoText.size(withAttributes: attributes)
                let textRect = CGRect(
                    x: (220 - textSize.width) / 2,
                    y: (60 - textSize.height) / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                
                logoText.draw(in: textRect, withAttributes: attributes)
            }
        
        return image.pngData()
    }
}
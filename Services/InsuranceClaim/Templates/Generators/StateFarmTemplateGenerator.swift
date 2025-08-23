//
// Layer: Services
// Module: InsuranceClaim/Templates/Generators
// Purpose: State Farm specific template generation and configuration
//

import Foundation
import UIKit

public struct StateFarmTemplateGenerator {
    
    public init() {}
    
    public func createTemplate(for claimType: ClaimType) -> ClaimTemplate {
        ClaimTemplate(
            id: UUID(),
            companyName: "State Farm",
            claimType: claimType,
            templateVersion: "2024.1",
            logoData: createStateFarmLogo(),
            headerText: "State Farm Insurance Company\nHome Inventory Claim",
            requiredFields: getRequiredFields(for: claimType),
            formSections: getFormSections(),
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
    
    private func getRequiredFields(for claimType: ClaimType) -> [String] {
        var fields = [
            "Policy Number",
            "Date of Loss",
            "Time of Loss",
            "Cause of Loss",
            "Location of Property",
            "Description of Damage",
            "Contact Information",
            "Estimated Loss Amount",
        ]
        
        if claimType == .theft || claimType == .burglary {
            fields.append("Police Report Filed")
            fields.append("Police Report Number")
        }
        
        return fields
    }
    
    private func getFormSections() -> [ClaimTemplate.FormSection] {
        [
            ClaimTemplate.FormSection(
                title: "Policy Information",
                fields: ["Policy Number", "Policy Holder Name", "Contact Information"]
            ),
            ClaimTemplate.FormSection(
                title: "Loss Information",
                fields: ["Date of Loss", "Time of Loss", "Cause of Loss", "Location"]
            ),
            ClaimTemplate.FormSection(
                title: "Property Details",
                fields: ["Item Description", "Purchase Date", "Original Cost", "Estimated Replacement Cost"]
            ),
            ClaimTemplate.FormSection(
                title: "Supporting Documentation",
                fields: ["Photos", "Receipts", "Police Report (if applicable)", "Repair Estimates"]
            ),
        ]
    }
    
    private func createStateFarmLogo() -> Data? {
        let logoText = "STATE FARM"
        let image = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 60))
            .image { context in
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24),
                    .foregroundColor: UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0), // State Farm Red
                ]
                
                let textSize = logoText.size(withAttributes: attributes)
                let textRect = CGRect(
                    x: (200 - textSize.width) / 2,
                    y: (60 - textSize.height) / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                
                logoText.draw(in: textRect, withAttributes: attributes)
            }
        
        return image.pngData()
    }
}
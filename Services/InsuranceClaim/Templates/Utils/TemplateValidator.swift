//
// Layer: Services
// Module: InsuranceClaim/Templates/Utils
// Purpose: Template validation and customization utilities
//

import Foundation

public struct TemplateValidator {
    
    public init() {}
    
    /// Validates a claim template and returns any validation issues
    /// - Parameter template: The template to validate
    /// - Returns: Array of validation error messages, empty if valid
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
    
    /// Customizes a template with user-provided modifications
    /// - Parameters:
    ///   - template: The base template to customize
    ///   - customizations: The customizations to apply
    /// - Returns: A new template with customizations applied
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
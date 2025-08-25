//
// Layer: Services
// Module: InsuranceClaim
// Purpose: Orchestrates insurance company specific templates - modularized architecture
//

import Foundation

// Import modularized template components
// All template types, generators, and utilities are now organized in focused modules

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with PDFKit - Advanced PDF template manipulation  
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with CoreImage - Template image processing and watermarks

@MainActor
public struct ClaimTemplateManager {
    
    // MARK: - Template Generators
    
    private let stateFarmGenerator = StateFarmTemplateGenerator()
    private let allstateGenerator = AllstateTemplateGenerator()
    private let geicoGenerator = GeicoTemplateGenerator()
    private let genericGenerator = GenericTemplateGenerator()
    
    // MARK: - Utilities
    
    private let validator = TemplateValidator()
    
    // MARK: - Errors
    
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
            return stateFarmGenerator.createTemplate(for: claimType)
        case .allstate:
            return allstateGenerator.createTemplate(for: claimType)
        case .geico:
            return geicoGenerator.createTemplate(for: claimType)
        case .progressive, .nationwide, .farmers, .usaa, .libertymutual, .travelers, .aig, .amica, .aaa, .other:
            // Use generic generator for companies without specialized templates
            var template = genericGenerator.createTemplate(for: claimType)
            template.companyName = company.displayName
            return template
        }
    }

    // MARK: - Template Validation

    public func validateTemplate(_ template: ClaimTemplate) -> [String] {
        validator.validateTemplate(template)
    }

    // MARK: - Template Customization

    public func customizeTemplate(
        _ template: ClaimTemplate,
        with customizations: TemplateCustomizations
    ) -> ClaimTemplate {
        validator.customizeTemplate(template, with: customizations)
    }
}

// MARK: - Insurance Company Extensions

extension InsuranceCompany {
    public var displayName: String {
        switch self {
        case .stateFarm: return "State Farm"
        case .allstate: return "Allstate"
        case .geico: return "GEICO"
        case .progressive: return "Progressive"
        case .nationwide: return "Nationwide"
        case .farmers: return "Farmers"
        case .usaa: return "USAA"
        case .libertymutual: return "Liberty Mutual"
        case .travelers: return "Travelers"
        case .aig: return "AIG"
        case .amica: return "Amica"
        case .aaa: return "AAA"
        case .other: return "Other Insurance Company"
        }
    }
}
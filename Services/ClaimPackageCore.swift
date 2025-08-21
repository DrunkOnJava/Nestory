//
// Layer: Services
// Module: ClaimPackageCore
// Purpose: Core orchestration logic for claim package assembly with progress tracking
//

import Foundation
import SwiftData

// MARK: - Supporting Types

public struct ValidationIssue {
    public let itemId: UUID
    public let itemName: String
    public let issues: [String]
    public let severity: ValidationSeverity

    public init(itemId: UUID, itemName: String, issues: [String], severity: ValidationSeverity) {
        self.itemId = itemId
        self.itemName = itemName
        self.issues = issues
        self.severity = severity
    }
}

public enum ValidationSeverity {
    case critical
    case warning
    case info
}

@MainActor
public final class ClaimPackageCore: ObservableObject {
    // MARK: - Published Properties

    @Published public var isAssembling = false
    @Published public var assemblyProgress = 0.0
    @Published public var currentStep = ""
    @Published public var errorMessage: String?
    @Published public var lastGeneratedPackage: ClaimPackage?

    // MARK: - Dependencies

    private let documentProcessor: ClaimDocumentProcessor
    private let contentGenerator: ClaimContentGenerator
    private let packageExporter: ClaimPackageExporter

    // MARK: - Initialization

    public init() {
        self.documentProcessor = ClaimDocumentProcessor()
        self.contentGenerator = ClaimContentGenerator()
        self.packageExporter = ClaimPackageExporter()
    }

    // MARK: - Main Assembly Logic

    public func assembleClaimPackage(
        for scenario: ClaimScenario,
        items: [Item],
        options: ClaimPackageOptions = ClaimPackageOptions()
    ) async throws -> ClaimPackage {
        guard !items.isEmpty else {
            throw ClaimPackageError.noItemsSelected
        }

        isAssembling = true
        assemblyProgress = 0.0
        defer {
            isAssembling = false
        }

        do {
            // Step 1: Validate package requirements
            currentStep = "Validating documentation completeness..."
            assemblyProgress = 0.1
            let validation = try await validatePackageCompleteness(items: items, scenario: scenario)

            // Step 2: Generate cover letter and summary
            currentStep = "Generating claim summary and cover letter..."
            assemblyProgress = 0.2
            let coverLetter = try await contentGenerator.generateCoverLetter(
                scenario: scenario,
                items: items,
                options: options
            )

            // Step 3: Collect all documentation
            currentStep = "Collecting item documentation..."
            assemblyProgress = 0.4
            let documentation = try await documentProcessor.collectDocumentation(
                items: items,
                options: options
            )

            // Step 4: Generate required forms
            currentStep = "Generating insurance forms..."
            assemblyProgress = 0.6
            let forms = try await contentGenerator.generateRequiredForms(
                scenario: scenario,
                items: items,
                options: options
            )

            // Step 5: Create attestations
            currentStep = "Creating attestations and declarations..."
            assemblyProgress = 0.7
            let attestations = try await contentGenerator.generateAttestations(
                scenario: scenario,
                items: items,
                options: options
            )

            // Step 6: Assemble final package
            currentStep = "Assembling final package..."
            assemblyProgress = 0.9
            let package = try await packageExporter.createFinalPackage(
                scenario: scenario,
                items: items,
                coverLetter: coverLetter,
                documentation: documentation,
                forms: forms,
                attestations: attestations,
                validation: validation,
                options: options
            )

            currentStep = "Package assembly complete"
            assemblyProgress = 1.0
            lastGeneratedPackage = package

            return package

        } catch {
            currentStep = "Assembly failed"
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Validation Methods

    public func validatePackageCompleteness(
        items: [Item],
        scenario: ClaimScenario
    ) async throws -> PackageValidation {
        var issues: [ValidationIssue] = []
        var missing: [String] = []

        for item in items {
            var itemIssues: [String] = []

            // Check for photos
            if item.imageData == nil {
                itemIssues.append("No primary photo")
            }

            // Check for purchase documentation
            if item.purchasePrice == nil {
                itemIssues.append("No purchase price")
            }

            if item.purchaseDate == nil {
                itemIssues.append("No purchase date")
            }

            // Check for receipts
            if item.receipts.isEmpty, item.receiptImageData == nil {
                itemIssues.append("No receipt documentation")
            }

            // Check for serial numbers on valuable items
            if (item.purchasePrice ?? 0) > 500, item.serialNumber?.isEmpty != false {
                itemIssues.append("Missing serial number for valuable item")
            }

            // Check condition documentation for damaged items
            if scenario.requiresConditionDocumentation, item.conditionPhotos.isEmpty {
                itemIssues.append("Missing condition photos")
            }

            if !itemIssues.isEmpty {
                issues.append(ValidationIssue(
                    itemId: item.id,
                    itemName: item.name,
                    issues: itemIssues,
                    severity: .warning
                ))
            }
        }

        // Scenario-specific validation
        switch scenario.type {
        case .totalLoss:
            if items.count < 5 {
                missing.append("Total loss claims typically require comprehensive inventory")
            }
        case .theft:
            let hasPoliceReport = scenario.metadata["police_report"] != nil
            if !hasPoliceReport {
                missing.append("Police report reference for theft claim")
            }
        case .singleItem, .multipleItems, .roomBased:
            break
        }

        let isValid = issues.allSatisfy { $0.severity != .critical } && missing.isEmpty

        return PackageValidation(
            isValid: isValid,
            issues: issues,
            missingRequirements: missing,
            totalItems: items.count,
            documentedItems: items.count(where: { $0.imageData != nil }),
            totalValue: items.compactMap(\.purchasePrice).reduce(0, +),
            validationDate: Date()
        )
    }
}

//
// Layer: Services
// Module: ClaimContentGenerator
// Purpose: Content generation for insurance claim packages (forms, attestations, PDFs)
//

import Foundation
import SwiftData

@MainActor
public final class ClaimContentGenerator {
    // MARK: - Dependencies

    private let insuranceExportService: InsuranceExportService

    // MARK: - Initialization

    public init() {
        self.insuranceExportService = InsuranceExportService()
    }

    // MARK: - Cover Letter Generation

    public func generateCoverLetter(
        scenario: ClaimScenario,
        items: [Item],
        options: ClaimPackageOptions
    ) async throws -> ClaimCoverLetter {
        let totalValue = items.compactMap(\.purchasePrice).reduce(0, +)
        let affectedRooms = Set(items.compactMap(\.room))

        let summary = ClaimSummary(
            claimType: scenario.type,
            incidentDate: scenario.incidentDate,
            totalItems: items.count,
            totalValue: totalValue,
            affectedRooms: Array(affectedRooms),
            description: scenario.description
        )

        let letterContent = generateCoverLetterContent(summary: summary, options: options)

        return ClaimCoverLetter(
            summary: summary,
            content: letterContent,
            generatedDate: Date(),
            policyHolder: options.policyHolder,
            policyNumber: options.policyNumber
        )
    }

    // MARK: - Forms Generation

    public func generateRequiredForms(
        scenario: ClaimScenario,
        items: [Item],
        options _: ClaimPackageOptions
    ) async throws -> [ClaimForm] {
        var forms: [ClaimForm] = []

        // Standard insurance form
        let standardForm = try await insuranceExportService.exportInventory(
            items: items,
            categories: Array(Set(items.compactMap(\.category))),
            rooms: [], // TODO: Define Room type or use String array
            format: InsuranceExportService.ExportFormat.standardForm,
            options: ExportOptions()
        )

        forms.append(ClaimForm(
            type: .standardInventory,
            name: "Standard Insurance Inventory Form",
            fileURL: standardForm.fileURL,
            isRequired: true
        ))

        // Detailed spreadsheet
        let spreadsheet = try await insuranceExportService.exportInventory(
            items: items,
            categories: Array(Set(items.compactMap(\.category))),
            rooms: [], // TODO: Define Room type or use String array
            format: InsuranceExportService.ExportFormat.detailedSpreadsheet,
            options: ExportOptions()
        )

        forms.append(ClaimForm(
            type: .detailedSpreadsheet,
            name: "Detailed Item Spreadsheet",
            fileURL: spreadsheet.fileURL,
            isRequired: false
        ))

        // Scenario-specific forms
        if scenario.type == .theft {
            forms.append(ClaimForm(
                type: .policeReport,
                name: "Police Report Reference",
                fileURL: nil,
                isRequired: true,
                notes: "Please attach official police report separately"
            ))
        }

        return forms
    }

    // MARK: - Attestation Generation

    public func generateAttestations(
        scenario: ClaimScenario,
        items: [Item],
        options: ClaimPackageOptions
    ) async throws -> [Attestation] {
        var attestations: [Attestation] = []

        // Ownership attestation
        attestations.append(Attestation(
            type: .ownership,
            title: "Attestation of Ownership",
            content: generateOwnershipAttestation(items: items, options: options),
            requiresSignature: true
        ))

        // Value attestation
        attestations.append(Attestation(
            type: .value,
            title: "Attestation of Value",
            content: generateValueAttestation(items: items, options: options),
            requiresSignature: true
        ))

        // Scenario-specific attestations
        switch scenario.type {
        case .theft:
            attestations.append(Attestation(
                type: .incident,
                title: "Theft Incident Declaration",
                content: generateTheftAttestation(scenario: scenario, items: items, options: options),
                requiresSignature: true
            ))
        case .totalLoss:
            attestations.append(Attestation(
                type: .incident,
                title: "Total Loss Declaration",
                content: generateTotalLossAttestation(scenario: scenario, items: items, options: options),
                requiresSignature: true
            ))
        default:
            break
        }

        return attestations
    }

    // MARK: - PDF Generation

    public func generatePackageSummaryPDF(
        coverLetter: ClaimCoverLetter,
        validation _: PackageValidation,
        scenario _: ClaimScenario
    ) async throws -> Data {
        // Use existing PDFReportGenerator or create simple PDF
        coverLetter.content.data(using: .utf8) ?? Data()
    }

    public func generateAttestationPDF(attestation: Attestation) async throws -> Data {
        return attestation.content.data(using: .utf8) ?? Data()
    }

    public func generateComprehensivePDF(package _: ClaimPackage) async throws -> Data {
        // Generate combined PDF with all documentation
        "Comprehensive PDF placeholder".data(using: .utf8)!
    }

    // MARK: - Content Generation Methods

    private func generateCoverLetterContent(summary: ClaimSummary, options: ClaimPackageOptions) -> String {
        """
        INSURANCE CLAIM DOCUMENTATION PACKAGE

        Policy Holder: \(options.policyHolder ?? "Not Specified")
        Policy Number: \(options.policyNumber ?? "Not Specified")
        Claim Date: \(DateFormatter.longStyle.string(from: Date()))
        Incident Date: \(DateFormatter.longStyle.string(from: summary.incidentDate))

        CLAIM SUMMARY:
        Claim Type: \(summary.claimType.description)
        Total Items: \(summary.totalItems)
        Total Estimated Value: $\(summary.totalValue)
        Affected Areas: \(summary.affectedRooms.joined(separator: ", "))

        INCIDENT DESCRIPTION:
        \(summary.description)

        This package contains comprehensive documentation for the above claim, including:
        - Detailed inventory of affected items
        - Photographic evidence
        - Purchase documentation (receipts)
        - Warranty information where applicable
        - Condition assessments
        - Required attestations and declarations

        All documentation has been compiled and organized for your review and processing.

        Respectfully submitted,
        \(options.policyHolder ?? "Policy Holder")
        """
    }

    private func generateOwnershipAttestation(items: [Item], options: ClaimPackageOptions) -> String {
        """
        ATTESTATION OF OWNERSHIP

        I, \(options.policyHolder ?? "[Policy Holder Name]"), hereby attest under penalty of perjury that:

        1. I am the lawful owner of all items listed in this claim documentation
        2. All items were acquired through legitimate purchase or gift
        3. No items listed are subject to liens, encumbrances, or third-party ownership claims
        4. All purchase prices and dates listed are accurate to the best of my knowledge
        5. All photographic evidence represents the actual condition of items prior to the incident

        Total items attested: \(items.count)

        This attestation is made this \(DateFormatter.longStyle.string(from: Date())).

        ________________________________
        \(options.policyHolder ?? "[Policy Holder Name]")
        Policy Holder Signature
        """
    }

    private func generateValueAttestation(items: [Item], options: ClaimPackageOptions) -> String {
        let totalValue = items.compactMap(\.purchasePrice).reduce(0, +)
        return """
        ATTESTATION OF VALUE

        I, \(options.policyHolder ?? "[Policy Holder Name]"), hereby attest that:

        1. All purchase prices listed are based on actual purchase receipts or fair market value at time of acquisition
        2. Values have not been inflated or misrepresented
        3. Any estimated values are reasonable approximations based on comparable items
        4. Total claimed value: $\(totalValue)

        Items with purchase documentation: \(items.count(where: { $0.purchasePrice != nil }))
        Items with receipt images: \(items.count(where: { !$0.receipts.isEmpty || $0.receiptImageData != nil }))

        This attestation is made this \(DateFormatter.longStyle.string(from: Date())).

        ________________________________
        \(options.policyHolder ?? "[Policy Holder Name]")
        Policy Holder Signature
        """
    }

    private func generateTheftAttestation(scenario: ClaimScenario, items _: [Item], options: ClaimPackageOptions) -> String {
        """
        THEFT INCIDENT DECLARATION

        I, \(options.policyHolder ?? "[Policy Holder Name]"), hereby declare that:

        1. The items listed in this claim were stolen from my property
        2. The theft occurred on or about: \(DateFormatter.longStyle.string(from: scenario.incidentDate))
        3. I have reported this theft to local law enforcement
        4. Police report information: \(scenario.metadata["police_report"] ?? "[To be provided separately]")
        5. I have not recovered any of the stolen items
        6. No items were given away, sold, or disposed of voluntarily

        This declaration is made under penalty of perjury this \(DateFormatter.longStyle.string(from: Date())).

        ________________________________
        \(options.policyHolder ?? "[Policy Holder Name]")
        Policy Holder Signature
        """
    }

    private func generateTotalLossAttestation(scenario: ClaimScenario, items: [Item], options: ClaimPackageOptions) -> String {
        """
        TOTAL LOSS DECLARATION

        I, \(options.policyHolder ?? "[Policy Holder Name]"), hereby declare that:

        1. My property suffered a total loss on: \(DateFormatter.longStyle.string(from: scenario.incidentDate))
        2. The cause of loss was: \(scenario.description)
        3. All items listed were present at the property at the time of loss
        4. No items were removed prior to the incident
        5. This inventory represents my best effort to document all personal property

        Total items documented: \(items.count)
        Property address: \(options.propertyAddress ?? "[Property Address]")

        This declaration is made under penalty of perjury this \(DateFormatter.longStyle.string(from: Date())).

        ________________________________
        \(options.policyHolder ?? "[Policy Holder Name]")
        Policy Holder Signature
        """
    }
}

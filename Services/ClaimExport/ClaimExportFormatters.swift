//
// Layer: Services
// Module: ClaimExport
// Purpose: Format-specific export operations and data generation
//

import Foundation
import SwiftData

// MARK: - Format Export Operations

@MainActor
public final class ClaimExportFormatters {
    private let insuranceExportService: InsuranceExportService

    public init() {
        self.insuranceExportService = InsuranceExportService()
    }

    // MARK: - Format Dispatch

    public func exportClaimData(
        items: [Item],
        categories: [Category],
        rooms: [Room],
        format: InsuranceCompanyFormat,
        claim: ClaimSubmission
    ) async throws -> ExportResult {
        var options = ExportOptions()
        options.policyNumber = claim.policyNumber
        options.includePhotos = true
        options.includeReceipts = true
        options.includeWarrantyInfo = true

        switch format {
        case .acord:
            return try await exportACORDFormat(items: items, options: options)
        case .allstate, .statefarm, .geico:
            return try await exportSpreadsheetFormat(items: items, format: format)
        case .progressive, .farmers, .generic:
            return try await exportPDFFormat(items: items, categories: categories, rooms: rooms, options: options)
        case .liberty, .travelers:
            return try await exportComprehensivePackage(items: items, categories: categories, rooms: rooms, options: options)
        case .nationwide, .usaa:
            return try await exportJSONFormat(items: items, options: options)
        }
    }

    // MARK: - Format-Specific Export Methods

    private func exportACORDFormat(
        items: [Item],
        options: ExportOptions
    ) async throws -> ExportResult {
        // ACORD XML format implementation
        let xmlData = generateACORDXML(items: items, options: options)
        let fileName = "ACORD_Claim_\(Date().timeIntervalSince1970).xml"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        try xmlData.write(to: tempURL)

        return ExportResult(
            fileURL: tempURL,
            format: .xmlFormat,
            itemCount: items.count,
            totalValue: items.compactMap(\.purchasePrice).reduce(0, +),
            fileSize: xmlData.count
        )
    }

    private func exportSpreadsheetFormat(
        items: [Item],
        format _: InsuranceCompanyFormat
    ) async throws -> ExportResult {
        // Company-specific spreadsheet format
        try await insuranceExportService.exportInventory(
            items: items,
            categories: [],
            rooms: [],
            format: .detailedSpreadsheet,
            options: ExportOptions()
        )
    }

    private func exportPDFFormat(
        items: [Item],
        categories: [Category],
        rooms: [Room],
        options: ExportOptions
    ) async throws -> ExportResult {
        try await insuranceExportService.exportInventory(
            items: items,
            categories: categories,
            rooms: rooms,
            format: .standardForm,
            options: options
        )
    }

    private func exportComprehensivePackage(
        items: [Item],
        categories: [Category],
        rooms: [Room],
        options: ExportOptions
    ) async throws -> ExportResult {
        try await insuranceExportService.exportInventory(
            items: items,
            categories: categories,
            rooms: rooms,
            format: .digitalPackage,
            options: options
        )
    }

    private func exportJSONFormat(
        items: [Item],
        options: ExportOptions
    ) async throws -> ExportResult {
        let jsonData = try generateClaimJSON(items: items, options: options)
        let fileName = "Claim_Data_\(Date().timeIntervalSince1970).json"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        try jsonData.write(to: tempURL)

        return ExportResult(
            fileURL: tempURL,
            format: .standardForm, // Using existing enum
            itemCount: items.count,
            totalValue: items.compactMap(\.purchasePrice).reduce(0, +),
            fileSize: jsonData.count
        )
    }

    // MARK: - Data Generation

    private func generateACORDXML(items: [Item], options: ExportOptions) -> Data {
        // Simplified ACORD XML generation
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <ACORD xmlns="http://www.ACORD.org/standards/PC_Surety/ACORD1/xml/">
            <InsuranceSvcRq>
                <PolicyNumber>\(options.policyNumber ?? "")</PolicyNumber>
                <ClaimInfo>
                    <ItemCount>\(items.count)</ItemCount>
                    <TotalValue>\(items.compactMap(\.purchasePrice).reduce(0, +))</TotalValue>
                </ClaimInfo>
            </InsuranceSvcRq>
        </ACORD>
        """

        return xml.data(using: .utf8) ?? Data()
    }

    private func generateClaimJSON(items: [Item], options: ExportOptions) throws -> Data {
        let claimData: [String: Any] = [
            "policyNumber": options.policyNumber ?? "",
            "submissionDate": ISO8601DateFormatter().string(from: Date()),
            "items": items.map { item in [
                "id": item.id.uuidString,
                "name": item.name,
                "category": item.category?.name ?? "",
                "purchasePrice": item.purchasePrice ?? 0,
                "serialNumber": item.serialNumber ?? "",
                "hasPhotos": item.imageData != nil || !item.conditionPhotos.isEmpty,
                "hasReceipts": !(item.receipts?.isEmpty ?? true),
            ] },
        ]

        return try JSONSerialization.data(withJSONObject: claimData, options: .prettyPrinted)
    }

    // MARK: - Template Generation

    public func generateDefaultEmailMessage(for claim: ClaimSubmission) -> String {
        """
        Dear Claims Department,

        Please find attached my insurance claim submission for policy \(claim.policyNumber ?? "[Policy Number]").

        Claim Details:
        - Claim Type: \(claim.claimType.rawValue)
        - Incident Date: \(claim.incidentDate?.formatted(date: .abbreviated, time: .omitted) ?? "Not specified")
        - Total Items: \(claim.totalItemCount)
        - Total Claimed Value: $\(claim.totalClaimedValue)

        This submission includes detailed documentation for all claimed items, including photos and supporting documentation where available.

        Please confirm receipt of this submission and provide a claim reference number for future correspondence.

        Thank you for your prompt attention to this matter.

        Best regards,
        [Policyholder Name]
        """
    }
}

//
// Layer: Services
// Module: InsuranceClaim/ClaimDocumentGenerator
// Purpose: CSV/spreadsheet generation for claim documents with tabular data export
//

import Foundation

public struct ClaimSpreadsheetGenerator {
    public init() {}

    // MARK: - Spreadsheet Generation

    public func generateSpreadsheet(
        request: InsuranceClaimService.ClaimRequest,
        template: ClaimTemplate
    ) throws -> Data {
        let csvContent = buildCSVContent(request: request, template: template)
        
        guard let data = csvContent.data(using: .utf8) else {
            throw ClaimDocumentCore.GenerationError.documentCreationFailed
        }
        
        return data
    }

    // MARK: - CSV Building

    private func buildCSVContent(
        request: InsuranceClaimService.ClaimRequest,
        template: ClaimTemplate
    ) -> String {
        var csvLines: [String] = []

        // Add claim header information
        csvLines.append("# \(request.insuranceCompany.rawValue) Insurance Claim Export")
        csvLines.append("# Generated: \(ClaimDocumentHelpers.formatDate(request.createdAt))")
        csvLines.append("# Claim ID: \(String(request.id.uuidString.prefix(8)))")
        csvLines.append("# Claim Type: \(request.claimType.rawValue)")
        
        if let policyNumber = request.policyNumber {
            csvLines.append("# Policy Number: \(policyNumber)")
        }
        
        if let incidentDate = request.incidentDate {
            csvLines.append("# Incident Date: \(ClaimDocumentHelpers.formatDate(incidentDate))")
        }

        csvLines.append("") // Empty line

        // Add contact information section
        csvLines.append("# Contact Information")
        csvLines.append("Contact Type,Value")
        csvLines.append("Email,\(csvEscape(request.contactEmail ?? "Not provided"))")
        csvLines.append("Phone,\(csvEscape(request.contactPhone ?? "Not provided"))")
        csvLines.append("Address,\(csvEscape(request.contactAddress ?? "Not provided"))")
        csvLines.append("") // Empty line

        // Add items header
        csvLines.append("# Claimed Items")
        csvLines.append(buildItemsHeader())

        // Add items data
        let selectedItems = request.selectedItemIds.compactMap { id in
            request.allItems.first { $0.id == id }
        }

        for item in selectedItems {
            csvLines.append(buildItemRow(item))
        }

        csvLines.append("") // Empty line

        // Add summary section
        csvLines.append("# Summary")
        csvLines.append("Metric,Value")
        csvLines.append("Total Items,\(selectedItems.count)")
        csvLines.append("Total Claimed Value,\(ClaimDocumentHelpers.formatCurrency(ClaimDocumentHelpers.calculateTotalValue(for: selectedItems)))")
        
        // Add category breakdown
        let categoryBreakdown = buildCategoryBreakdown(selectedItems)
        for (category, count) in categoryBreakdown {
            csvLines.append("Items in \(category),\(count)")
        }

        return csvLines.joined(separator: "\n")
    }

    private func buildItemsHeader() -> String {
        let headers = [
            "Item ID",
            "Name",
            "Category",
            "Description",
            "Brand",
            "Model",
            "Serial Number",
            "Purchase Price",
            "Purchase Date",
            "Condition",
            "Location",
            "Photo Count",
            "Document Count"
        ]
        return headers.map(csvEscape).joined(separator: ",")
    }

    private func buildItemRow(_ item: Item) -> String {
        let fields = [
            item.id.uuidString,
            item.name,
            item.category?.name ?? "",
            item.itemDescription ?? "",
            item.brand ?? "",
            item.model ?? "",
            item.serialNumber ?? "",
            item.purchasePrice?.description ?? "",
            ClaimDocumentHelpers.formatDate(item.purchaseDate),
            item.condition?.rawValue ?? "",
            item.room?.name ?? "",
            String(item.photos?.count ?? 0),
            String(item.documents?.count ?? 0)
        ]
        return fields.map(csvEscape).joined(separator: ",")
    }

    private func buildCategoryBreakdown(_ items: [Item]) -> [String: Int] {
        var categoryBreakdown: [String: Int] = [:]
        
        for item in items {
            let categoryName = item.category?.name ?? "Uncategorized"
            categoryBreakdown[categoryName, default: 0] += 1
        }
        
        return categoryBreakdown
    }

    // MARK: - CSV Utilities

    private func csvEscape(_ field: String) -> String {
        // Handle CSV escaping rules
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return field
    }
}
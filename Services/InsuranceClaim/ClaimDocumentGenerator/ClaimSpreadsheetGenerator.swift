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
        request: ClaimRequest,
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
        request: ClaimRequest,
        template: ClaimTemplate
    ) -> String {
        var csvLines: [String] = []

        // Add claim header information
        csvLines.append("# \(request.insuranceCompany.rawValue) Insurance Claim Export")
        csvLines.append("# Generated: \(ClaimDocumentHelpers.formatDate(request.createdAt))")
        csvLines.append("# Claim ID: \(String(UUID().uuidString.prefix(8)))")
        csvLines.append("# Claim Type: \(request.claimType.rawValue)")
        
        if let policyNumber = request.policyNumber {
            csvLines.append("# Policy Number: \(policyNumber)")
        }
        
        csvLines.append("# Incident Date: \(ClaimDocumentHelpers.formatDate(request.incidentDate))")

        csvLines.append("") // Empty line

        // Add contact information section
        csvLines.append("# Contact Information")
        csvLines.append("Contact Type,Value")
        csvLines.append("Email,\(csvEscape(request.contactInfo.email))")
        csvLines.append("Phone,\(csvEscape(request.contactInfo.phone))")
        csvLines.append("Address,\(csvEscape(request.contactInfo.address))")
        csvLines.append("") // Empty line

        // Add items header
        csvLines.append("# Claimed Items")
        csvLines.append(buildItemsHeader())

        // Add items data
        let selectedItems = request.items

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
        let id = item.id.uuidString
        let name = item.name
        let category = item.category?.name ?? ""
        let description = item.itemDescription ?? ""
        let brand = item.brand ?? ""
        let model = item.modelNumber ?? ""
        let serialNumber = item.serialNumber ?? ""
        let purchasePrice = item.purchasePrice?.description ?? ""
        let purchaseDate = ClaimDocumentHelpers.formatDate(item.purchaseDate)
        let condition = item.condition
        let location = item.room?.name ?? ""
        let photoCount = String(item.photos.count)
        let documentCount = "0" // Documents not available in current Item model
        
        let fields = [
            id, name, category, description, brand, model, serialNumber,
            purchasePrice, purchaseDate, condition, location, photoCount, documentCount
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
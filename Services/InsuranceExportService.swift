//
// Layer: Services
// Module: InsuranceExport
// Purpose: Export detailed inventory for insurance companies
//
// REMINDER: This service MUST be wired up in SettingsView and accessible from main screen

import Foundation
import SwiftData
import UIKit
import UniformTypeIdentifiers

@MainActor
public final class InsuranceExportService: ObservableObject {
    @Published public var isExporting = false
    @Published public var exportProgress: Double = 0.0
    @Published public var errorMessage: String?

    public init() {}

    // MARK: - Export Formats

    public enum ExportFormat: String, CaseIterable {
        case standardForm = "Standard Insurance Form (PDF)"
        case detailedSpreadsheet = "Detailed Spreadsheet (Excel)"
        case digitalPackage = "Digital Evidence Package (ZIP)"
        case xmlFormat = "Industry XML Format"
        case claimsReady = "Claims-Ready Package"

        var fileExtension: String {
            switch self {
            case .standardForm: "pdf"
            case .detailedSpreadsheet: "xlsx"
            case .digitalPackage: "zip"
            case .xmlFormat: "xml"
            case .claimsReady: "zip"
            }
        }
    }

    // MARK: - Main Export Method

    public func exportInventory(
        items: [Item],
        categories: [Category],
        rooms: [Room],
        format: ExportFormat,
        options: ExportOptions
    ) async throws -> ExportResult {
        isExporting = true
        exportProgress = 0.0
        defer {
            isExporting = false
            exportProgress = 1.0
        }

        switch format {
        case .standardForm:
            return try await exportStandardForm(items: items, categories: categories, rooms: rooms, options: options)
        case .detailedSpreadsheet:
            return try await exportDetailedSpreadsheet(items: items, categories: categories, rooms: rooms, options: options)
        case .digitalPackage:
            return try await exportDigitalPackage(items: items, categories: categories, rooms: rooms, options: options)
        case .xmlFormat:
            return try await exportXMLFormat(items: items, categories: categories, rooms: rooms, options: options)
        case .claimsReady:
            return try await exportClaimsReadyPackage(items: items, categories: categories, rooms: rooms, options: options)
        }
    }

    // MARK: - Standard Insurance Form (PDF)

    private func exportStandardForm(items: [Item], categories _: [Category], rooms: [Room], options: ExportOptions) async throws -> ExportResult {
        var htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>Home Inventory Insurance Report</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 20px; }
                .header { background: #f0f0f0; padding: 20px; margin-bottom: 30px; }
                .header h1 { margin: 0; color: #333; }
                .metadata { margin: 10px 0; color: #666; }
                .summary-box { background: #fff; border: 2px solid #007AFF; padding: 15px; margin: 20px 0; }
                .summary-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
                .summary-item { text-align: center; }
                .summary-value { font-size: 24px; font-weight: bold; color: #007AFF; }
                .summary-label { color: #666; font-size: 12px; }
                .section { margin: 30px 0; page-break-inside: avoid; }
                .section-title { font-size: 18px; font-weight: bold; border-bottom: 2px solid #007AFF; padding-bottom: 5px; margin-bottom: 15px; }
                .item-card { border: 1px solid #ddd; padding: 15px; margin: 15px 0; page-break-inside: avoid; }
                .item-header { display: flex; justify-content: space-between; margin-bottom: 10px; }
                .item-name { font-weight: bold; font-size: 16px; }
                .item-value { color: #007AFF; font-weight: bold; }
                .item-details { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; margin: 10px 0; }
                .detail-row { font-size: 12px; }
                .detail-label { color: #666; }
                .photo-section { margin-top: 15px; }
                .photo-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; }
                .photo-item { width: 100%; height: 150px; object-fit: cover; border: 1px solid #ddd; }
                .footer { margin-top: 50px; padding-top: 20px; border-top: 2px solid #ccc; color: #666; font-size: 12px; }
                .page-break { page-break-after: always; }
                @media print {
                    .item-card { page-break-inside: avoid; }
                    .section { page-break-inside: avoid; }
                }
            </style>
        </head>
        <body>
        """

        // Header
        htmlContent += """
        <div class="header">
            <h1>Home Inventory Insurance Documentation</h1>
            <div class="metadata">
                <div>Policy Holder: \(options.policyHolderName ?? "Not Specified")</div>
                <div>Policy Number: \(options.policyNumber ?? "Not Specified")</div>
                <div>Property Address: \(options.propertyAddress ?? "Not Specified")</div>
                <div>Report Date: \(Date().formatted(date: .complete, time: .omitted))</div>
            </div>
        </div>
        """

        // Summary Statistics
        let totalValue = items.compactMap(\.purchasePrice).reduce(0, +)
        let itemsWithReceipts = items.count(where: { $0.receiptImageData != nil })
        let itemsWithSerialNumbers = items.count(where: { $0.serialNumber != nil })
        let itemsWithWarranty = items.count(where: { $0.warrantyExpirationDate != nil })

        htmlContent += """
        <div class="summary-box">
            <h2>Inventory Summary</h2>
            <div class="summary-grid">
                <div class="summary-item">
                    <div class="summary-value">\(items.count)</div>
                    <div class="summary-label">Total Items</div>
                </div>
                <div class="summary-item">
                    <div class="summary-value">$\(totalValue)</div>
                    <div class="summary-label">Total Value</div>
                </div>
                <div class="summary-item">
                    <div class="summary-value">\(itemsWithReceipts)</div>
                    <div class="summary-label">Items with Receipts</div>
                </div>
                <div class="summary-item">
                    <div class="summary-value">\(itemsWithSerialNumbers)</div>
                    <div class="summary-label">Items with Serial #</div>
                </div>
                <div class="summary-item">
                    <div class="summary-value">\(itemsWithWarranty)</div>
                    <div class="summary-label">Under Warranty</div>
                </div>
                <div class="summary-item">
                    <div class="summary-value">\(rooms.count)</div>
                    <div class="summary-label">Rooms Documented</div>
                </div>
            </div>
        </div>
        """

        // Group items by room if requested
        if options.groupByRoom {
            let itemsByRoom = Dictionary(grouping: items) { $0.room ?? "Unassigned" }

            for (room, roomItems) in itemsByRoom.sorted(by: { $0.key < $1.key }) {
                let roomTotal = roomItems.compactMap(\.purchasePrice).reduce(0, +)

                htmlContent += """
                <div class="section">
                    <div class="section-title">\(room) - \(roomItems.count) items - Total: $\(roomTotal)</div>
                """

                for item in roomItems {
                    htmlContent += generateItemCard(item: item, options: options)
                }

                htmlContent += "</div>"
                exportProgress += Double(roomItems.count) / Double(items.count) * 0.8
            }
        } else {
            // List all items
            htmlContent += "<div class=\"section\"><div class=\"section-title\">Complete Inventory</div>"
            for (index, item) in items.enumerated() {
                htmlContent += generateItemCard(item: item, options: options)
                exportProgress = Double(index + 1) / Double(items.count) * 0.8
            }
            htmlContent += "</div>"
        }

        // Footer
        htmlContent += """
        <div class="footer">
            <p><strong>Important Notice:</strong> This inventory documentation is prepared for insurance purposes. 
            All values and descriptions are based on owner-provided information. 
            Professional appraisal may be required for high-value items.</p>
            <p>Generated by Nestory Home Inventory App on \(Date().formatted())</p>
            <p>This document contains \(items.count) items with a total declared value of $\(totalValue)</p>
        </div>
        </body>
        </html>
        """

        // Convert HTML to PDF
        let pdfData = try await convertHTMLToPDF(html: htmlContent)

        // Save to temporary file
        let fileName = "Insurance_Inventory_\(Date().timeIntervalSince1970).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try pdfData.write(to: tempURL)

        exportProgress = 1.0

        return ExportResult(
            fileURL: tempURL,
            format: .standardForm,
            itemCount: items.count,
            totalValue: totalValue,
            fileSize: pdfData.count
        )
    }

    // MARK: - Detailed Spreadsheet Export

    private func exportDetailedSpreadsheet(items: [Item], categories _: [Category], rooms _: [Room], options _: ExportOptions) async throws -> ExportResult {
        // Create CSV with all fields (Excel can open CSV)
        var csvContent = "Item ID,Name,Description,Category,Room,Location,Quantity,Brand,Model,Serial Number,Purchase Date,Purchase Price,Currency,Warranty Expiration,Warranty Provider,Has Photo,Has Receipt,Receipt Text,Tags,Notes,Created Date,Updated Date\n"

        for item in items {
            let row = [
                item.id.uuidString,
                escapeCSV(item.name),
                escapeCSV(item.itemDescription ?? ""),
                escapeCSV(item.category?.name ?? ""),
                escapeCSV(item.room ?? ""),
                escapeCSV(item.specificLocation ?? ""),
                String(item.quantity),
                escapeCSV(item.brand ?? ""),
                escapeCSV(item.modelNumber ?? ""),
                escapeCSV(item.serialNumber ?? ""),
                item.purchaseDate?.formatted(date: .numeric, time: .omitted) ?? "",
                item.purchasePrice != nil ? String(describing: item.purchasePrice!) : "",
                item.currency,
                item.warrantyExpirationDate?.formatted(date: .numeric, time: .omitted) ?? "",
                escapeCSV(item.warrantyProvider ?? ""),
                item.imageData != nil ? "Yes" : "No",
                item.receiptImageData != nil ? "Yes" : "No",
                escapeCSV(item.extractedReceiptText ?? ""),
                escapeCSV(item.tags.joined(separator: "; ")),
                escapeCSV(item.notes ?? ""),
                item.createdAt.formatted(date: .numeric, time: .omitted),
                item.updatedAt.formatted(date: .numeric, time: .omitted),
            ].joined(separator: ",")

            csvContent += row + "\n"
        }

        // Add summary section
        csvContent += "\n\nSUMMARY\n"
        csvContent += "Total Items,\(items.count)\n"
        csvContent += "Total Value,\(items.compactMap(\.purchasePrice).reduce(0, +))\n"
        csvContent += "Items with Photos,\(items.count(where: { $0.imageData != nil }))\n"
        csvContent += "Items with Receipts,\(items.count(where: { $0.receiptImageData != nil }))\n"
        csvContent += "Items with Serial Numbers,\(items.count(where: { $0.serialNumber != nil }))\n"
        csvContent += "Items under Warranty,\(items.count(where: { $0.warrantyExpirationDate != nil && $0.warrantyExpirationDate! > Date() }))\n"

        let data = csvContent.data(using: .utf8)!
        let fileName = "Insurance_Inventory_Detailed_\(Date().timeIntervalSince1970).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: tempURL)

        return ExportResult(
            fileURL: tempURL,
            format: .detailedSpreadsheet,
            itemCount: items.count,
            totalValue: items.compactMap(\.purchasePrice).reduce(0, +),
            fileSize: data.count
        )
    }

    // MARK: - Digital Evidence Package

    private func exportDigitalPackage(items: [Item], categories: [Category], rooms: [Room], options: ExportOptions) async throws -> ExportResult {
        // This would create a ZIP file with:
        // - PDF report
        // - All photos in organized folders
        // - All receipts in a receipts folder
        // - CSV data file
        // - JSON backup

        // For now, return a simplified version
        let pdfResult = try await exportStandardForm(items: items, categories: categories, rooms: rooms, options: options)

        // In production, would create ZIP with all assets
        return ExportResult(
            fileURL: pdfResult.fileURL,
            format: .digitalPackage,
            itemCount: items.count,
            totalValue: items.compactMap(\.purchasePrice).reduce(0, +),
            fileSize: pdfResult.fileSize
        )
    }

    // MARK: - XML Format (Industry Standard)

    private func exportXMLFormat(items: [Item], categories _: [Category], rooms _: [Room], options: ExportOptions) async throws -> ExportResult {
        var xmlContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <HomeInventory xmlns="http://insurance.standards.org/inventory/2.0">
            <PolicyInformation>
                <PolicyHolder>\(options.policyHolderName ?? "")</PolicyHolder>
                <PolicyNumber>\(options.policyNumber ?? "")</PolicyNumber>
                <PropertyAddress>\(options.propertyAddress ?? "")</PropertyAddress>
                <ReportDate>\(Date().ISO8601Format())</ReportDate>
            </PolicyInformation>
            <Items>
        """

        for item in items {
            xmlContent += """
                <Item id="\(item.id.uuidString)">
                    <Name>\(escapeXML(item.name))</Name>
                    <Description>\(escapeXML(item.itemDescription ?? ""))</Description>
                    <Category>\(escapeXML(item.category?.name ?? ""))</Category>
                    <Location>
                        <Room>\(escapeXML(item.room ?? ""))</Room>
                        <SpecificLocation>\(escapeXML(item.specificLocation ?? ""))</SpecificLocation>
                    </Location>
                    <Identification>
                        <Brand>\(escapeXML(item.brand ?? ""))</Brand>
                        <Model>\(escapeXML(item.modelNumber ?? ""))</Model>
                        <SerialNumber>\(escapeXML(item.serialNumber ?? ""))</SerialNumber>
                    </Identification>
                    <Financial>
                        <PurchaseDate>\(item.purchaseDate?.ISO8601Format() ?? "")</PurchaseDate>
                        <PurchasePrice currency="\(item.currency)">\(item.purchasePrice ?? 0)</PurchasePrice>
                    </Financial>
                    <Warranty>
                        <ExpirationDate>\(item.warrantyExpirationDate?.ISO8601Format() ?? "")</ExpirationDate>
                        <Provider>\(escapeXML(item.warrantyProvider ?? ""))</Provider>
                    </Warranty>
                    <Documentation>
                        <HasPhoto>\(item.imageData != nil)</HasPhoto>
                        <HasReceipt>\(item.receiptImageData != nil)</HasReceipt>
                        <DocumentCount>\(item.documentNames.count)</DocumentCount>
                    </Documentation>
                </Item>
            """
        }

        xmlContent += """
            </Items>
            <Summary>
                <TotalItems>\(items.count)</TotalItems>
                <TotalValue>\(items.compactMap(\.purchasePrice).reduce(0, +))</TotalValue>
                <ItemsWithPhotos>\(items.count(where: { $0.imageData != nil }))</ItemsWithPhotos>
                <ItemsWithReceipts>\(items.count(where: { $0.receiptImageData != nil }))</ItemsWithReceipts>
            </Summary>
        </HomeInventory>
        """

        let data = xmlContent.data(using: .utf8)!
        let fileName = "Insurance_Inventory_\(Date().timeIntervalSince1970).xml"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: tempURL)

        return ExportResult(
            fileURL: tempURL,
            format: .xmlFormat,
            itemCount: items.count,
            totalValue: items.compactMap(\.purchasePrice).reduce(0, +),
            fileSize: data.count
        )
    }

    // MARK: - Claims-Ready Package

    private func exportClaimsReadyPackage(items: [Item], categories: [Category], rooms: [Room], options: ExportOptions) async throws -> ExportResult {
        // This creates a comprehensive package ready for insurance claims
        // Includes everything an adjuster would need

        // For now, use the standard form
        try await exportStandardForm(items: items, categories: categories, rooms: rooms, options: options)
    }

    // MARK: - Helper Methods

    private func generateItemCard(item: Item, options _: ExportOptions) -> String {
        var html = "<div class=\"item-card\">"

        // Header
        html += """
        <div class="item-header">
            <div class="item-name">\(escapeHTML(item.name))</div>
            <div class="item-value">$\(item.purchasePrice ?? 0)</div>
        </div>
        """

        // Details grid
        html += "<div class=\"item-details\">"

        if let description = item.itemDescription {
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Description:</span> \(escapeHTML(description))</div>"
        }

        if item.quantity > 1 {
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Quantity:</span> \(item.quantity)</div>"
        }

        if let brand = item.brand {
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Brand:</span> \(escapeHTML(brand))</div>"
        }

        if let model = item.modelNumber {
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Model:</span> \(escapeHTML(model))</div>"
        }

        if let serial = item.serialNumber {
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Serial #:</span> \(escapeHTML(serial))</div>"
        }

        if let purchaseDate = item.purchaseDate {
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Purchase Date:</span> \(purchaseDate.formatted(date: .abbreviated, time: .omitted))</div>"
        }

        if let warranty = item.warrantyExpirationDate {
            let isActive = warranty > Date()
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Warranty:</span> \(isActive ? "Active until" : "Expired") \(warranty.formatted(date: .abbreviated, time: .omitted))</div>"
        }

        if let location = item.specificLocation {
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Location:</span> \(escapeHTML(location))</div>"
        }

        html += "</div>"

        // Documentation status
        var docStatus: [String] = []
        if item.imageData != nil { docStatus.append("✓ Photo") }
        if item.receiptImageData != nil { docStatus.append("✓ Receipt") }
        if !item.documentNames.isEmpty { docStatus.append("✓ \(item.documentNames.count) Documents") }

        if !docStatus.isEmpty {
            html += "<div style=\"margin-top: 10px; color: #007AFF; font-size: 12px;\">\(docStatus.joined(separator: " • "))</div>"
        }

        html += "</div>"
        return html
    }

    private func convertHTMLToPDF(html: String) async throws -> Data {
        // In production, use proper HTML to PDF conversion
        // For now, return the HTML as data
        html.data(using: .utf8)!
    }

    private func escapeCSV(_ string: String) -> String {
        if string.contains(",") || string.contains("\"") || string.contains("\n") {
            return "\"\(string.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return string
    }

    private func escapeXML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }

    private func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}

// MARK: - Data Models

public struct ExportOptions {
    public var policyHolderName: String?
    public var policyNumber: String?
    public var propertyAddress: String?
    public var includePhotos: Bool = true
    public var includeReceipts: Bool = true
    public var includeWarrantyInfo: Bool = true
    public var groupByRoom: Bool = true
    public var includeDepreciation: Bool = false
    public var depreciationRate: Double = 0.1 // 10% per year default

    public init() {}
}

public struct ExportResult {
    public let fileURL: URL
    public let format: InsuranceExportService.ExportFormat
    public let itemCount: Int
    public let totalValue: Decimal
    public let fileSize: Int

    public var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(fileSize))
    }
}

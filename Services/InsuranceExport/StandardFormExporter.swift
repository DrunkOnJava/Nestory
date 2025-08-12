//
// Layer: Services
// Module: InsuranceExport
// Purpose: Generate standard insurance form as PDF/HTML
//

import Foundation

public enum StandardFormExporter {
    @MainActor
    public static func generateHTMLReport(
        items: [Item],
        rooms: [Room],
        options: ExportOptions,
        progressHandler: ((Double) -> Void)? = nil,
    ) async -> String {
        var htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>Home Inventory Insurance Report</title>
            \(HTMLTemplateGenerator.generateStyles())
        </head>
        <body>
        """

        // Add header
        htmlContent += HTMLTemplateGenerator.generateHeader(options: options)

        // Add summary
        htmlContent += HTMLTemplateGenerator.generateSummarySection(items: items, rooms: rooms)

        // Group items by room if requested
        if options.groupByRoom {
            htmlContent += generateRoomSections(items: items, progressHandler: progressHandler)
        } else {
            htmlContent += generateCompleteInventory(items: items, progressHandler: progressHandler)
        }

        // Add footer
        htmlContent += HTMLTemplateGenerator.generateFooter(items: items)

        htmlContent += """
        </body>
        </html>
        """

        return htmlContent
    }

    private static func generateRoomSections(
        items: [Item],
        progressHandler: ((Double) -> Void)?,
    ) -> String {
        var html = ""
        let itemsByRoom = Dictionary(grouping: items) { $0.room ?? "Unassigned" }
        var processedCount = 0

        for (room, roomItems) in itemsByRoom.sorted(by: { $0.key < $1.key }) {
            let roomTotal = roomItems.compactMap(\.purchasePrice).reduce(0, +)

            html += """
            <div class="section">
                <div class="section-title">\(room) - \(roomItems.count) items - Total: \(DataFormatHelpers.formatCurrency(roomTotal))</div>
            """

            for item in roomItems {
                html += generateItemCard(item: item)
                processedCount += 1
                progressHandler?(Double(processedCount) / Double(items.count) * 0.8)
            }

            html += "</div>"
        }

        return html
    }

    private static func generateCompleteInventory(
        items: [Item],
        progressHandler: ((Double) -> Void)?,
    ) -> String {
        var html = "<div class=\"section\"><div class=\"section-title\">Complete Inventory</div>"

        for (index, item) in items.enumerated() {
            html += generateItemCard(item: item)
            progressHandler?(Double(index + 1) / Double(items.count) * 0.8)
        }

        html += "</div>"
        return html
    }

    private static func generateItemCard(item: Item) -> String {
        var html = "<div class=\"item-card\">"

        // Header
        html += """
        <div class="item-header">
            <div class="item-name">\(DataFormatHelpers.escapeHTML(item.name))</div>
            <div class="item-value">\(DataFormatHelpers.formatCurrency(item.purchasePrice ?? 0, currencyCode: item.currency))</div>
        </div>
        """

        // Details grid
        html += "<div class=\"item-details\">"

        if let description = item.itemDescription {
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Description:</span> \(DataFormatHelpers.escapeHTML(description))</div>"
        }

        if item.quantity > 1 {
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Quantity:</span> \(item.quantity)</div>"
        }

        if let brand = item.brand {
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Brand:</span> \(DataFormatHelpers.escapeHTML(brand))</div>"
        }

        if let model = item.modelNumber {
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Model:</span> \(DataFormatHelpers.escapeHTML(model))</div>"
        }

        if let serial = item.serialNumber {
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Serial #:</span> \(DataFormatHelpers.escapeHTML(serial))</div>"
        }

        if let purchaseDate = item.purchaseDate {
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Purchase Date:</span> \(DataFormatHelpers.formatDate(purchaseDate))</div>"
        }

        if let warranty = item.warrantyExpirationDate {
            let isActive = warranty > Date()
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Warranty:</span> \(isActive ? "Active until" : "Expired") \(DataFormatHelpers.formatDate(warranty))</div>"
        }

        if let location = item.specificLocation {
            html += "<div class=\"detail-row\"><span class=\"detail-label\">Location:</span> \(DataFormatHelpers.escapeHTML(location))</div>"
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

    public static func generateFileName() -> String {
        "Insurance_Inventory_\(Date().timeIntervalSince1970).pdf"
    }
}

//
// Layer: Services
// Module: InsuranceExport
// Purpose: Export inventory data as CSV/spreadsheet format
//

import Foundation

public enum SpreadsheetExporter {
    @MainActor
    public static func exportToCSV(items: [Item]) async -> Data {
        var csvContent = "Item ID,Name,Description,Category,Room,Location,Quantity,Brand,Model,Serial Number,Purchase Date,Purchase Price,Currency,Warranty Expiration,Warranty Provider,Has Photo,Has Receipt,Receipt Text,Tags,Notes,Created Date,Updated Date\n"

        for item in items {
            let row = [
                item.id.uuidString,
                DataFormatHelpers.escapeCSV(item.name),
                DataFormatHelpers.escapeCSV(item.itemDescription ?? ""),
                DataFormatHelpers.escapeCSV(item.category?.name ?? ""),
                DataFormatHelpers.escapeCSV(item.room ?? ""),
                DataFormatHelpers.escapeCSV(item.specificLocation ?? ""),
                String(item.quantity),
                DataFormatHelpers.escapeCSV(item.brand ?? ""),
                DataFormatHelpers.escapeCSV(item.modelNumber ?? ""),
                DataFormatHelpers.escapeCSV(item.serialNumber ?? ""),
                item.purchaseDate?.formatted(date: .numeric, time: .omitted) ?? "",
                item.purchasePrice?.description ?? "",
                item.currency,
                item.warrantyExpirationDate?.formatted(date: .numeric, time: .omitted) ?? "",
                DataFormatHelpers.escapeCSV(item.warrantyProvider ?? ""),
                item.imageData != nil ? "Yes" : "No",
                item.receiptImageData != nil ? "Yes" : "No",
                DataFormatHelpers.escapeCSV(item.extractedReceiptText ?? ""),
                DataFormatHelpers.escapeCSV(item.tags.joined(separator: "; ")),
                DataFormatHelpers.escapeCSV(item.notes ?? ""),
                item.createdAt.formatted(date: .numeric, time: .omitted),
                item.updatedAt.formatted(date: .numeric, time: .omitted),
            ].joined(separator: ",")

            csvContent += row + "\n"
        }

        // Add summary section
        csvContent += "\n\nSUMMARY\n"
        csvContent += "Total Items,\(items.count)\n"
        csvContent += "Total Value,\(items.compactMap(\.purchasePrice).reduce(0, +))\n"
        csvContent += "Items with Photos,\(items.count { $0.imageData != nil })\n"
        csvContent += "Items with Receipts,\(items.count { $0.receiptImageData != nil })\n"
        csvContent += "Items with Serial Numbers,\(items.count { $0.serialNumber != nil })\n"
        let warrantyCount = items.count { item in
            guard let warrantyDate = item.warrantyExpirationDate else { return false }
            return warrantyDate > Date()
        }
        csvContent += "Items under Warranty,\(warrantyCount)\n"

        guard let csvData = csvContent.data(using: .utf8) else {
            // This should never fail as we're using valid UTF-8 strings
            return Data()
        }
        return csvData
    }

    public static func generateFileName() -> String {
        "Insurance_Inventory_Detailed_\(Date().timeIntervalSince1970).csv"
    }
}

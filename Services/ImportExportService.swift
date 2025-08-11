//
// Layer: Services
// Module: ImportExport
// Purpose: Handle CSV and JSON import/export for bulk data entry
//
// REMINDER: This service is WIRED UP in SettingsView:
// - Import: "Import Data" button with fileImporter
// - Export: "Export Data" button in ExportOptionsView
// Always ensure new services are accessible from the UI!

import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@MainActor
public final class ImportExportService: ObservableObject {
    public enum ImportError: LocalizedError {
        case invalidFormat
        case missingRequiredFields
        case parsingError(String)
        case dataConversionError

        public var errorDescription: String? {
            switch self {
            case .invalidFormat:
                "Invalid file format. Please use CSV or JSON."
            case .missingRequiredFields:
                "Missing required fields in import file."
            case let .parsingError(detail):
                "Error parsing file: \(detail)"
            case .dataConversionError:
                "Could not convert file data."
            }
        }
    }

    public struct ImportResult {
        public let itemsImported: Int
        public let itemsSkipped: Int
        public let errors: [String]

        public var summary: String {
            var parts: [String] = []
            if itemsImported > 0 {
                parts.append("\(itemsImported) items imported")
            }
            if itemsSkipped > 0 {
                parts.append("\(itemsSkipped) items skipped")
            }
            if !errors.isEmpty {
                parts.append("\(errors.count) errors")
            }
            return parts.joined(separator: ", ")
        }
    }

    public init() {}

    // MARK: - CSV Import

    public func importCSV(from url: URL, modelContext: ModelContext) async throws -> ImportResult {
        let data = try Data(contentsOf: url)
        guard let csvString = String(data: data, encoding: .utf8) else {
            throw ImportError.dataConversionError
        }

        let lines = csvString.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }

        guard lines.count > 1 else {
            throw ImportError.invalidFormat
        }

        // Parse header
        let headers = parseCSVLine(lines[0]).map { $0.lowercased().trimmingCharacters(in: .whitespaces) }

        // Validate required fields
        guard headers.contains("name") else {
            throw ImportError.missingRequiredFields
        }

        var itemsImported = 0
        var itemsSkipped = 0
        var errors: [String] = []

        // Parse data rows
        for (index, line) in lines.dropFirst().enumerated() {
            let values = parseCSVLine(line)

            if values.count != headers.count {
                errors.append("Row \(index + 2): Column count mismatch")
                itemsSkipped += 1
                continue
            }

            do {
                let item = try createItemFromCSVRow(headers: headers, values: values)
                modelContext.insert(item)
                itemsImported += 1
            } catch {
                errors.append("Row \(index + 2): \(error.localizedDescription)")
                itemsSkipped += 1
            }
        }

        try modelContext.save()

        return ImportResult(
            itemsImported: itemsImported,
            itemsSkipped: itemsSkipped,
            errors: errors,
        )
    }

    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var currentField = ""
        var inQuotes = false

        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == ",", !inQuotes {
                result.append(currentField.trimmingCharacters(in: .whitespaces))
                currentField = ""
            } else {
                currentField.append(char)
            }
        }

        result.append(currentField.trimmingCharacters(in: .whitespaces))
        return result
    }

    private func createItemFromCSVRow(headers: [String], values: [String]) throws -> Item {
        var itemData: [String: String] = [:]

        for (index, header) in headers.enumerated() {
            if index < values.count {
                itemData[header] = values[index]
            }
        }

        guard let name = itemData["name"], !name.isEmpty else {
            throw ImportError.missingRequiredFields
        }

        let item = Item(name: name)

        // Map CSV fields to Item properties
        item.itemDescription = itemData["description"]
        item.brand = itemData["brand"]
        item.modelNumber = itemData["model"] ?? itemData["model_number"]
        item.serialNumber = itemData["serial"] ?? itemData["serial_number"]
        item.notes = itemData["notes"]
        // Location could be stored in notes if present
        if let location = itemData["location"] {
            item.notes = (item.notes ?? "") + "\nLocation: \(location)"
        }
        item.currency = itemData["currency"] ?? "USD"

        // Parse quantity
        if let quantityStr = itemData["quantity"] ?? itemData["qty"],
           let quantity = Int(quantityStr)
        {
            item.quantity = quantity
        }

        // Parse purchase price
        if let priceStr = itemData["price"] ?? itemData["purchase_price"] ?? itemData["value"] {
            let cleanedPrice = priceStr.replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
            if let price = Decimal(string: cleanedPrice) {
                item.purchasePrice = price
            }
        }

        // Parse purchase date
        if let dateStr = itemData["purchase_date"] ?? itemData["date_purchased"] {
            item.purchaseDate = parseDate(dateStr)
        }

        // Warranty info can be stored in notes
        if let warrantyStr = itemData["warranty"] ?? itemData["warranty_expires"] {
            item.notes = (item.notes ?? "") + "\nWarranty: \(warrantyStr)"
        }

        // Parse tags
        if let tagsStr = itemData["tags"] {
            item.tags = tagsStr.components(separatedBy: ";")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }

        return item
    }

    private nonisolated func parseDate(_ dateString: String) -> Date? {
        let formatters = [
            "yyyy-MM-dd",
            "MM/dd/yyyy",
            "dd/MM/yyyy",
            "yyyy/MM/dd",
            "MM-dd-yyyy",
            "dd-MM-yyyy",
        ]

        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        return nil
    }

    // MARK: - JSON Import

    public func importJSON(from url: URL, modelContext: ModelContext) async throws -> ImportResult {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = self.parseDate(dateString) {
                return date
            }

            // Try ISO8601
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string \(dateString)",
            )
        }

        var itemsImported = 0
        let itemsSkipped = 0
        let errors: [String] = []

        // Try to decode as array of items
        if let jsonItems = try? decoder.decode([ImportableItem].self, from: data) {
            for (_, jsonItem) in jsonItems.enumerated() {
                let item = jsonItem.toItem()
                modelContext.insert(item)
                itemsImported += 1
            }
        } else if let jsonItem = try? decoder.decode(ImportableItem.self, from: data) {
            // Try single item
            let item = jsonItem.toItem()
            modelContext.insert(item)
            itemsImported += 1
        } else {
            throw ImportError.invalidFormat
        }

        try modelContext.save()

        return ImportResult(
            itemsImported: itemsImported,
            itemsSkipped: itemsSkipped,
            errors: errors,
        )
    }

    // MARK: - Export

    public func exportToCSV(items: [Item]) -> Data? {
        var csv = "Name,Description,Brand,Model,Serial Number,Quantity,Purchase Price,Currency,Purchase Date,Warranty Expires,Location,Tags,Notes\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for item in items {
            let row = [
                escapeCSVField(item.name),
                escapeCSVField(item.itemDescription ?? ""),
                escapeCSVField(item.brand ?? ""),
                escapeCSVField(item.modelNumber ?? ""),
                escapeCSVField(item.serialNumber ?? ""),
                "\(item.quantity)",
                item.purchasePrice?.description ?? "",
                item.currency,
                item.purchaseDate.map { dateFormatter.string(from: $0) } ?? "",
                "", // warranty field placeholder
                "", // location field placeholder
                escapeCSVField(item.tags.joined(separator: ";")),
                escapeCSVField(item.notes ?? ""),
            ].joined(separator: ",")

            csv.append(row + "\n")
        }

        return csv.data(using: .utf8)
    }

    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return field
    }

    public func exportToJSON(items: [Item]) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let exportableItems = items.map { ImportableItem(from: $0) }
        return try? encoder.encode(exportableItems)
    }
}

// MARK: - Importable Item Model

struct ImportableItem: Codable {
    let name: String
    let description: String?
    let brand: String?
    let modelNumber: String?
    let serialNumber: String?
    let quantity: Int
    let purchasePrice: Decimal?
    let currency: String
    let purchaseDate: Date?
    let tags: [String]
    let notes: String?

    init(from item: Item) {
        name = item.name
        description = item.itemDescription
        brand = item.brand
        modelNumber = item.modelNumber
        serialNumber = item.serialNumber
        quantity = item.quantity
        purchasePrice = item.purchasePrice
        currency = item.currency
        purchaseDate = item.purchaseDate
        tags = item.tags
        notes = item.notes
    }

    func toItem() -> Item {
        let item = Item(name: name)
        item.itemDescription = description
        item.brand = brand
        item.modelNumber = modelNumber
        item.serialNumber = serialNumber
        item.quantity = quantity
        item.purchasePrice = purchasePrice
        item.currency = currency
        item.purchaseDate = purchaseDate
        item.tags = tags
        item.notes = notes
        return item
    }
}

// MARK: - File Type Support

public extension UTType {
    static let csv = UTType(filenameExtension: "csv") ?? .commaSeparatedText
}

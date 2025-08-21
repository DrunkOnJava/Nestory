//
// Layer: Services
// Module: ImportExport
// Purpose: CSV import and export operations for ImportExportService
//

import Foundation
import os.log
import SwiftData

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with TabularData Framework - Use DataFrame for structured CSV operations with better type safety and performance

// MARK: - CSV Operations Extension

extension LiveImportExportService {
    // MARK: - CSV Import

    public func importCSV(from url: URL, modelContext: ModelContext) async throws -> ImportResult {
        // Extract self reference before entering Sendable closure
        let maxFileSize = maxFileSize
        let maxRowsPerImport = maxRowsPerImport
        let logger = logger

        return try await resilientExecutor.execute(
            operation: { @MainActor in
                // All operations now run on MainActor to match ModelContext requirements

                let startTime = Date()
                logger.info("Starting CSV import from: \(url.lastPathComponent)")

                // Validate file access and size
                guard url.startAccessingSecurityScopedResource() else {
                    throw ServiceError.fileAccessDenied(path: url.path)
                }
                defer { url.stopAccessingSecurityScopedResource() }

                let fileSize: Int
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                    fileSize = attributes[.size] as? Int ?? 0

                    if fileSize > maxFileSize {
                        throw ImportError.fileTooLarge(size: fileSize, maxSize: maxFileSize)
                    }
                } catch {
                    throw ServiceError.fromFileSystemError(error, path: url.path)
                }

                // Read and validate file data
                let data: Data
                let csvString: String

                do {
                    data = try Data(contentsOf: url)

                    // Try multiple encodings
                    if let utf8String = String(data: data, encoding: .utf8) {
                        csvString = utf8String
                    } else if let utf16String = String(data: data, encoding: .utf16) {
                        csvString = utf16String
                    } else if let latinString = String(data: data, encoding: .isoLatin1) {
                        csvString = latinString
                    } else {
                        throw ImportError.dataConversionError("Unsupported text encoding")
                    }
                } catch {
                    logger.error("Failed to read CSV file: \(error)")
                    throw ServiceError.fromFileSystemError(error, path: url.path)
                }

                // Validate CSV structure
                let lines = csvString.components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }

                guard !lines.isEmpty else {
                    throw ImportError.invalidFormat("File is empty")
                }

                guard lines.count > 1 else {
                    throw ImportError.invalidFormat("File contains only header row")
                }

                if lines.count > maxRowsPerImport {
                    logger.warning("CSV file has \(lines.count) rows, limiting to \(maxRowsPerImport)")
                }

                // Parse and validate headers
                let rawHeaders = await self.parseCSVLine(lines[0])
                let headers = rawHeaders.map { $0.lowercased().trimmingCharacters(in: .whitespaces) }

                let requiredFields = ["name"]
                let missingFields = requiredFields.filter { !headers.contains($0) }

                guard missingFields.isEmpty else {
                    throw ImportError.missingRequiredFields(missingFields)
                }

                // Process data rows with comprehensive error handling
                var itemsImported = 0
                var itemsSkipped = 0
                var errors: [String] = []
                var warnings: [String] = []

                let dataLines = Array(lines.dropFirst().prefix(maxRowsPerImport))

                for (index, line) in dataLines.enumerated() {
                    let rowNumber = index + 2 // +2 because we skipped header and are 1-indexed

                    do {
                        let values = await self.parseCSVLine(line)

                        if values.count != headers.count {
                            let error = "Row \(rowNumber): Expected \(headers.count) columns, got \(values.count)"
                            errors.append(error)
                            itemsSkipped += 1
                            continue
                        }

                        // Create item with enhanced error handling
                        do {
                            let item = try await self.createItemFromCSVRow(headers: headers, values: values)

                            // Validate item before insertion
                            if item.name.isEmpty {
                                warnings.append("Row \(rowNumber): Empty item name")
                            }

                            if item.purchasePrice == nil {
                                warnings.append("Row \(rowNumber): No purchase price specified")
                            }

                            modelContext.insert(item)
                            itemsImported += 1

                            // Periodic save to avoid memory issues
                            if itemsImported % 100 == 0 {
                                try modelContext.save()
                                logger.debug("Saved batch of 100 items (total: \(itemsImported))")
                            }
                        } catch {
                            let errorMsg = "Row \(rowNumber): Failed to create item - \(error.localizedDescription)"
                            errors.append(errorMsg)
                            itemsSkipped += 1
                            logger.warning("\(errorMsg)")
                        }
                    } catch {
                        let errorMsg = "Row \(rowNumber): Failed to parse CSV line - \(error.localizedDescription)"
                        errors.append(errorMsg)
                        itemsSkipped += 1
                    }
                }

                // Final save
                do {
                    try modelContext.save()
                    logger.info("CSV import completed: \(itemsImported) imported, \(itemsSkipped) skipped")
                } catch {
                    logger.error("Failed to save imported items: \(error)")
                    throw ServiceError.processingFailed(operation: "save imported items", reason: error.localizedDescription)
                }

                let processingTime = Date().timeIntervalSince(startTime)

                return ImportResult(
                    itemsImported: itemsImported,
                    itemsSkipped: itemsSkipped,
                    errors: errors,
                    warnings: warnings,
                    fileSize: fileSize,
                    processingTime: processingTime,
                )
            },
            operationType: "csvImport",
        )
    }

    // MARK: - CSV Export

    public func exportToCSV(items: [Item]) -> Data? {
        let headers = [
            "name", "description", "brand", "model_number", "serial_number",
            "purchase_price", "currency", "purchase_date", "quantity", "tags", "notes",
        ]

        var csvContent = headers.joined(separator: ",") + "\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for item in items {
            let row = [
                escapeCSVField(item.name),
                escapeCSVField(item.itemDescription ?? ""),
                escapeCSVField(item.brand ?? ""),
                escapeCSVField(item.modelNumber ?? ""),
                escapeCSVField(item.serialNumber ?? ""),
                item.purchasePrice?.description ?? "",
                item.currency,
                item.purchaseDate.map { dateFormatter.string(from: $0) } ?? "",
                String(item.quantity),
                escapeCSVField(item.tags.joined(separator: ";")),
                escapeCSVField(item.notes ?? ""),
            ]

            csvContent += row.joined(separator: ",") + "\n"
        }

        return csvContent.data(using: .utf8)
    }

    // MARK: - CSV Helper Methods

    func parseCSVLine(_ line: String) -> [String] {
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

    func createItemFromCSVRow(headers: [String], values: [String]) throws -> Item {
        var itemData: [String: String] = [:]

        for (index, header) in headers.enumerated() {
            if index < values.count {
                itemData[header] = values[index]
            }
        }

        guard let name = itemData["name"], !name.isEmpty else {
            throw ImportError.missingRequiredFields(["name"])
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

    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }

    nonisolated func parseDate(_ dateString: String) -> Date? {
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
}

//
// Layer: Services
// Module: ImportExport
// Purpose: Data models and error types for import/export operations
//

import Foundation

// MARK: - Import/Export Error Types

public enum ImportError: LocalizedError {
    case invalidFormat(String)
    case missingRequiredFields([String])
    case parsingError(row: Int, detail: String)
    case dataConversionError(String)
    case fileAccessError(String)
    case fileTooLarge(size: Int, maxSize: Int)
    case corruptedData(String)
    case networkError(String)

    public var errorDescription: String? {
        switch self {
        case let .invalidFormat(details):
            "Invalid file format: \(details)"
        case let .missingRequiredFields(fields):
            "Missing required fields: \(fields.joined(separator: ", "))"
        case let .parsingError(row, detail):
            "Error parsing row \(row): \(detail)"
        case let .dataConversionError(details):
            "Could not convert file data: \(details)"
        case let .fileAccessError(details):
            "Cannot access file: \(details)"
        case let .fileTooLarge(size, maxSize):
            "File too large (\(size) bytes). Maximum allowed: \(maxSize) bytes"
        case let .corruptedData(details):
            "File data is corrupted: \(details)"
        case let .networkError(details):
            "Network error during import: \(details)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .invalidFormat:
            "Please use a valid CSV or JSON file format"
        case .missingRequiredFields:
            "Ensure your file contains all required columns"
        case .parsingError:
            "Check the file format and fix any syntax errors"
        case .dataConversionError:
            "Check file encoding and data formats"
        case .fileAccessError:
            "Check file permissions and try again"
        case .fileTooLarge:
            "Split the file into smaller chunks or compress it"
        case .corruptedData:
            "Try re-exporting the data or using a different file"
        case .networkError:
            "Check your internet connection and try again"
        }
    }
}

// MARK: - Import Result Model

public struct ImportResult: Sendable {
    public let itemsImported: Int
    public let itemsSkipped: Int
    public let errors: [String]
    public let warnings: [String]
    public let fileSize: Int
    public let processingTime: TimeInterval

    public init(itemsImported: Int, itemsSkipped: Int, errors: [String], warnings: [String], fileSize: Int, processingTime: TimeInterval) {
        self.itemsImported = itemsImported
        self.itemsSkipped = itemsSkipped
        self.errors = errors
        self.warnings = warnings
        self.fileSize = fileSize
        self.processingTime = processingTime
    }

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
        if !warnings.isEmpty {
            parts.append("\(warnings.count) warnings")
        }
        return parts.joined(separator: ", ")
    }

    public var detailedSummary: String {
        let basic = summary
        let size = ByteCountFormatter().string(fromByteCount: Int64(fileSize))
        let time = String(format: "%.2fs", processingTime)
        return "\(basic) • \(size) processed in \(time)"
    }
}

// MARK: - Importable Item Model

struct ImportableItem: Codable {
    let name: String
    let description: String?
    let category: String?
    let purchasePrice: Decimal?
    let currency: String?
    let purchaseDate: Date?
    let warrantyExpirationDate: Date?
    let serialNumber: String?
    let modelNumber: String?
    let brand: String?
    let location: String?
    let tags: [String]?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case name, description, category, purchasePrice, currency
        case purchaseDate, warrantyExpirationDate, serialNumber
        case modelNumber, brand, location, tags, notes
    }
}

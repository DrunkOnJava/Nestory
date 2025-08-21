//
// Layer: Services
// Module: ExportService
// Purpose: Data export functionality for backup and sharing
//

import Foundation

// MARK: - ExportService Protocol

/// Export service for converting inventory data to various formats
public protocol ExportService: Sendable {
    /// Export data to CSV format
    func exportToCSV<T: Encodable>(_ data: [T]) async throws -> Data
    
    /// Export data to JSON format
    func exportToJSON<T: Encodable>(_ data: [T]) async throws -> Data
    
    /// Export data to Excel format
    func exportToExcel<T: Encodable>(_ data: [T]) async throws -> Data
    
    /// Export data to PDF format
    func exportToPDF<T: Encodable>(_ data: [T], template: PDFTemplate) async throws -> Data
    
    /// Export complete inventory backup
    func exportCompleteBackup() async throws -> InventoryBackup
    
    /// Export filtered data with custom fields
    func exportFiltered<T: Encodable>(_ data: [T], format: ExportFormat, fields: [String]) async throws -> Data
    
    /// Get available export formats for data type
    func getAvailableFormats<T>(for dataType: T.Type) -> [ExportFormat]
    
    /// Validate data before export
    func validateExportData<T>(_ data: [T]) async throws -> ExportValidation
}

// MARK: - Supporting Types

// Note: ExportFormat is now defined in Foundation/Models/ExportFormat.swift

/// PDF template configurations
public enum PDFTemplate: String, Sendable, CaseIterable {
    case insurance = "insurance"
    case inventory = "inventory"
    case warranty = "warranty"
    case receipt = "receipt"
    
    public var displayName: String {
        switch self {
        case .insurance: return "Insurance Report"
        case .inventory: return "Inventory List"
        case .warranty: return "Warranty Summary"
        case .receipt: return "Receipt Collection"
        }
    }
}

/// Complete inventory backup structure
public struct InventoryBackup: Sendable {
    public let items: [InventoryItem]
    public let categories: [CategoryData]
    public let warranties: [WarrantyData]
    public let receipts: [ReceiptData]
    public let metadata: BackupMetadata
    
    public init(
        items: [InventoryItem],
        categories: [CategoryData],
        warranties: [WarrantyData],
        receipts: [ReceiptData],
        metadata: BackupMetadata
    ) {
        self.items = items
        self.categories = categories
        self.warranties = warranties
        self.receipts = receipts
        self.metadata = metadata
    }
}

// Note: BackupMetadata is now defined in Foundation/Models/BackupMetadata.swift

/// Export validation result
public struct ExportValidation: Sendable {
    public let isValid: Bool
    public let issues: [ValidationIssue]
    public let warnings: [String]
    public let estimatedFileSize: Int
    
    public init(isValid: Bool, issues: [ValidationIssue], warnings: [String], estimatedFileSize: Int) {
        self.isValid = isValid
        self.issues = issues
        self.warnings = warnings
        self.estimatedFileSize = estimatedFileSize
    }
}

// ValidationIssue is defined in Foundation/Core/ValidationIssue.swift
// Services layer imports Foundation, so we can use the canonical type

/// Simplified data structures for export
public struct InventoryItem: Sendable, Codable {
    public let id: String
    public let name: String
    public let description: String?
    public let category: String?
    public let purchasePrice: Decimal?
    public let purchaseDate: Date?
    public let condition: String
    public let serialNumber: String?
    public let warrantyExpirationDate: Date?
    
    public init(
        id: String, name: String, description: String?, category: String?,
        purchasePrice: Decimal?, purchaseDate: Date?, condition: String,
        serialNumber: String?, warrantyExpirationDate: Date?
    ) {
        self.id = id; self.name = name; self.description = description
        self.category = category; self.purchasePrice = purchasePrice
        self.purchaseDate = purchaseDate; self.condition = condition
        self.serialNumber = serialNumber; self.warrantyExpirationDate = warrantyExpirationDate
    }
}

public struct CategoryData: Sendable, Codable {
    public let id: String
    public let name: String
    public let icon: String
    public let itemCount: Int
    
    public init(id: String, name: String, icon: String, itemCount: Int) {
        self.id = id; self.name = name; self.icon = icon; self.itemCount = itemCount
    }
}

public struct WarrantyData: Sendable, Codable {
    public let id: String
    public let itemId: String
    public let provider: String
    public let warrantyType: String
    public let startDate: Date
    public let expiresAt: Date
    
    public init(id: String, itemId: String, provider: String, warrantyType: String, startDate: Date, expiresAt: Date) {
        self.id = id; self.itemId = itemId; self.provider = provider
        self.warrantyType = warrantyType; self.startDate = startDate; self.expiresAt = expiresAt
    }
}

public struct ReceiptData: Sendable, Codable {
    public let id: String
    public let itemId: String?
    public let vendor: String
    public let total: Decimal?
    public let purchaseDate: Date
    public let receiptNumber: String?
    
    public init(id: String, itemId: String?, vendor: String, total: Decimal?, purchaseDate: Date, receiptNumber: String?) {
        self.id = id; self.itemId = itemId; self.vendor = vendor
        self.total = total; self.purchaseDate = purchaseDate; self.receiptNumber = receiptNumber
    }
}

// MARK: - Error Types

public enum ExportError: LocalizedError, Sendable {
    case invalidData(String)
    case formatNotSupported(ExportFormat)
    case fileSizeTooLarge(Int)
    case encodingFailed(String)
    case templateNotFound(PDFTemplate)
    case insufficientData
    case exportFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidData(let reason):
            return "Invalid data for export: \(reason)"
        case .formatNotSupported(let format):
            return "Export format '\(format.displayName)' is not supported"
        case .fileSizeTooLarge(let size):
            return "Export file size (\(size) bytes) exceeds maximum limit"
        case .encodingFailed(let reason):
            return "Failed to encode data: \(reason)"
        case .templateNotFound(let template):
            return "PDF template '\(template.displayName)' not found"
        case .insufficientData:
            return "Insufficient data to create export"
        case .exportFailed(let reason):
            return "Export operation failed: \(reason)"
        }
    }
}

// MARK: - Live Implementation Placeholder

/// Live implementation of ExportService
public struct LiveExportService: ExportService {
    
    public init() {}
    
    public func exportToCSV<T: Encodable>(_ data: [T]) async throws -> Data {
        // TODO: Implement CSV export
        throw ExportError.exportFailed("Not yet implemented")
    }
    
    public func exportToJSON<T: Encodable>(_ data: [T]) async throws -> Data {
        // TODO: Implement JSON export
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(data)
    }
    
    public func exportToExcel<T: Encodable>(_ data: [T]) async throws -> Data {
        // TODO: Implement Excel export
        throw ExportError.exportFailed("Not yet implemented")
    }
    
    public func exportToPDF<T: Encodable>(_ data: [T], template: PDFTemplate) async throws -> Data {
        // TODO: Implement PDF export
        throw ExportError.exportFailed("Not yet implemented")
    }
    
    public func exportCompleteBackup() async throws -> InventoryBackup {
        // TODO: Implement complete backup
        throw ExportError.exportFailed("Not yet implemented")
    }
    
    public func exportFiltered<T: Encodable>(_ data: [T], format: ExportFormat, fields: [String]) async throws -> Data {
        // TODO: Implement filtered export
        throw ExportError.exportFailed("Not yet implemented")
    }
    
    public func getAvailableFormats<T>(for dataType: T.Type) -> [ExportFormat] {
        // TODO: Return appropriate formats based on data type
        return [.json, .csv, .pdf]
    }
    
    public func validateExportData<T>(_ data: [T]) async throws -> ExportValidation {
        // TODO: Implement data validation
        return ExportValidation(
            isValid: !data.isEmpty,
            issues: [],
            warnings: [],
            estimatedFileSize: data.count * 1024 // Rough estimate
        )
    }
}
//
// Layer: Services
// Module: ClaimExport
// Purpose: Validation logic and business rules for claim export
//

import Foundation

// MARK: - Claim Validation

public enum ClaimExportValidators {
    // MARK: - Core Validation

    public static func validateClaimRequirements(
        items: [Item],
        format _: InsuranceCompanyFormat,
        requirements: ClaimValidationRequirements
    ) throws {
        var validationErrors: [String] = []

        if requirements.requiresPhotos {
            let itemsWithoutPhotos = items.filter(\.photos.isEmpty)
            if !itemsWithoutPhotos.isEmpty {
                validationErrors.append("\(itemsWithoutPhotos.count) items missing photos")
            }
        }

        if requirements.requiresReceipts {
            let itemsWithoutReceipts = items.filter(\.receipts.isEmpty)
            if !itemsWithoutReceipts.isEmpty {
                validationErrors.append("\(itemsWithoutReceipts.count) items missing receipts")
            }
        }

        if requirements.requiresSerialNumbers {
            let itemsWithoutSerial = items.filter { $0.serialNumber?.isEmpty != false }
            if !itemsWithoutSerial.isEmpty {
                validationErrors.append("\(itemsWithoutSerial.count) items missing serial numbers")
            }
        }

        if let minValue = requirements.minimumItemValue {
            let lowValueItems = items.filter { ($0.purchasePrice ?? 0) < minValue }
            if !lowValueItems.isEmpty {
                validationErrors.append("\(lowValueItems.count) items below minimum value threshold")
            }
        }

        if !validationErrors.isEmpty {
            throw ClaimExportError.validationFailed(validationErrors)
        }
    }

    // MARK: - Item Validation

    public static func validateItems(_ items: [Item]) -> [ValidationIssue] {
        var issues: [ExportValidationIssue] = []

        for item in items {
            // Check for missing photos
            if item.photos.isEmpty {
                issues.append(ExportValidationIssue(
                    itemId: item.id,
                    itemName: item.name,
                    severity: .warning,
                    category: .missingPhoto,
                    description: "No photos available for insurance documentation"
                ))
            }

            // Check for missing purchase price
            if item.purchasePrice == nil {
                issues.append(ExportValidationIssue(
                    itemId: item.id,
                    itemName: item.name,
                    severity: .error,
                    category: .missingValue,
                    description: "Purchase price required for claim valuation"
                ))
            }

            // Check for missing serial number on high-value items
            if (item.purchasePrice ?? 0) > 500, item.serialNumber?.isEmpty != false {
                issues.append(ExportValidationIssue(
                    itemId: item.id,
                    itemName: item.name,
                    severity: .warning,
                    category: .missingSerial,
                    description: "Serial number recommended for high-value items"
                ))
            }

            // Check for missing purchase date
            if item.purchaseDate == nil {
                issues.append(ExportValidationIssue(
                    itemId: item.id,
                    itemName: item.name,
                    severity: .info,
                    category: .missingDate,
                    description: "Purchase date helps establish item timeline"
                ))
            }
        }

        return issues
    }

    // MARK: - Format-Specific Validation

    public static func validateForFormat(
        items: [Item],
        format: InsuranceCompanyFormat
    ) -> [ValidationIssue] {
        var issues: [ExportValidationIssue] = []

        switch format {
        case .acord:
            // ACORD requires specific data structure
            for item in items where item.category == nil {
                issues.append(ExportValidationIssue(
                    itemId: item.id,
                    itemName: item.name,
                    severity: .warning,
                    category: .formatSpecific,
                    description: "ACORD format works best with item categories"
                ))
            }

        case .allstate, .statefarm, .geico:
            // Spreadsheet formats need structured data
            for item in items where item.purchasePrice == nil {
                issues.append(ExportValidationIssue(
                    itemId: item.id,
                    itemName: item.name,
                    severity: .error,
                    category: .formatSpecific,
                    description: "Spreadsheet format requires purchase price for all items"
                ))
            }

        case .progressive, .farmers:
            // PDF formats benefit from photos
            for item in items where item.photos.isEmpty {
                issues.append(ExportValidationIssue(
                    itemId: item.id,
                    itemName: item.name,
                    severity: .warning,
                    category: .formatSpecific,
                    description: "PDF format works best with item photos"
                ))
            }

        case .liberty, .travelers:
            // Comprehensive packages need complete data
            issues.append(contentsOf: validateItems(items).filter { $0.severity == .error })

        case .nationwide, .usaa:
            // JSON formats are flexible but benefit from complete data
            break

        case .generic:
            // Generic format is flexible
            break
        }

        return issues
    }

    // MARK: - File Validation

    public static func validateFileRequirements(
        fileSize: Int,
        requirements: ClaimValidationRequirements
    ) -> [ValidationIssue] {
        var issues: [ExportValidationIssue] = []

        if fileSize > requirements.maximumFileSize {
            issues.append(ExportValidationIssue(
                itemId: UUID(), // Global validation
                itemName: "Export File",
                severity: .error,
                category: .fileSize,
                description: "Export file exceeds maximum size limit (\(requirements.maximumFileSize / 1_000_000)MB)"
            ))
        }

        return issues
    }
}

// MARK: - Validation Types

public struct ExportValidationIssue: Identifiable {
    public let id = UUID()
    public let itemId: UUID
    public let itemName: String
    public let severity: ValidationSeverity
    public let category: ValidationCategory
    public let description: String

    public init(
        itemId: UUID,
        itemName: String,
        severity: ValidationSeverity,
        category: ValidationCategory,
        description: String
    ) {
        self.itemId = itemId
        self.itemName = itemName
        self.severity = severity
        self.category = category
        self.description = description
    }
}

// ValidationSeverity is defined in ClaimValidationService.swift

public enum ValidationCategory: String, CaseIterable {
    case missingPhoto = "Missing Photo"
    case missingValue = "Missing Value"
    case missingSerial = "Missing Serial"
    case missingDate = "Missing Date"
    case formatSpecific = "Format Specific"
    case fileSize = "File Size"
}

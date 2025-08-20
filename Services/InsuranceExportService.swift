//
// Layer: Services
// Module: InsuranceExport
// Purpose: Export detailed inventory for insurance companies - Main coordinator
//
// REMINDER: This service MUST be wired up in SettingsView and accessible from main screen

import Foundation
import SwiftData
import UIKit
import UniformTypeIdentifiers

public enum ExportError: LocalizedError {
    case dataConversionFailed
    case fileWriteFailed
    case missingData

    public var errorDescription: String? {
        switch self {
        case .dataConversionFailed:
            "Failed to convert data for export"
        case .fileWriteFailed:
            "Failed to write export file"
        case .missingData:
            "Required data is missing for export"
        }
    }
}

@MainActor
public final class InsuranceExportService: ObservableObject {
    @Published public var isExporting = false
    @Published public var exportProgress = 0.0
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
            case .standardForm:
                "pdf"
            case .detailedSpreadsheet:
                "xlsx"
            case .digitalPackage:
                "zip"
            case .xmlFormat:
                "xml"
            case .claimsReady:
                "zip"
            }
        }
    }

    // MARK: - Main Export Method

    public func exportInventory(
        items: [Item],
        categories: [Category],
        rooms: [Room],
        format: ExportFormat,
        options: ExportOptions,
    ) async throws -> ExportResult {
        isExporting = true
        exportProgress = 0.0
        defer {
            isExporting = false
            exportProgress = 1.0
        }

        switch format {
        case .standardForm:
            return try await exportStandardForm(items: items, rooms: rooms, options: options)
        case .detailedSpreadsheet:
            return try await exportDetailedSpreadsheet(items: items)
        case .digitalPackage:
            return try await exportDigitalPackage(
                items: items,
                categories: categories,
                rooms: rooms,
                options: options,
            )
        case .xmlFormat:
            return try await exportXMLFormat(items: items, options: options)
        case .claimsReady:
            return try await exportClaimsReadyPackage(
                items: items,
                categories: categories,
                rooms: rooms,
                options: options,
            )
        }
    }

    // MARK: - Export Methods

    private func exportStandardForm(
        items: [Item],
        rooms: [Room],
        options: ExportOptions,
    ) async throws -> ExportResult {
        let htmlContent = await StandardFormExporter.generateHTMLReport(
            items: items,
            rooms: rooms,
            options: options,
        ) { [weak self] progress in
            Task { @MainActor in
                self?.exportProgress = progress
            }
        }

        // Convert HTML to PDF (simplified for now)
        guard let pdfData = htmlContent.data(using: .utf8) else {
            throw ExportError.dataConversionFailed
        }

        // Save to temporary file
        let fileName = StandardFormExporter.generateFileName()
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
        try pdfData.write(to: tempURL)

        exportProgress = 1.0

        return ExportResult(
            fileURL: tempURL,
            format: .standardForm,
            itemCount: items.count,
            totalValue: items.compactMap(\.purchasePrice).reduce(0, +),
            fileSize: pdfData.count,
        )
    }

    private func exportDetailedSpreadsheet(items: [Item]) async throws -> ExportResult {
        let csvData = await SpreadsheetExporter.exportToCSV(items: items)

        let fileName = SpreadsheetExporter.generateFileName()
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
        try csvData.write(to: tempURL)

        return ExportResult(
            fileURL: tempURL,
            format: .detailedSpreadsheet,
            itemCount: items.count,
            totalValue: items.compactMap(\.purchasePrice).reduce(0, +),
            fileSize: csvData.count,
        )
    }

    private func exportXMLFormat(
        items: [Item],
        options: ExportOptions,
    ) async throws -> ExportResult {
        let xmlData = await XMLExporter.exportToXML(items: items, options: options)

        let fileName = XMLExporter.generateFileName()
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
        try xmlData.write(to: tempURL)

        return ExportResult(
            fileURL: tempURL,
            format: .xmlFormat,
            itemCount: items.count,
            totalValue: items.compactMap(\.purchasePrice).reduce(0, +),
            fileSize: xmlData.count,
        )
    }

    private func exportDigitalPackage(
        items: [Item],
        categories _: [Category],
        rooms: [Room],
        options: ExportOptions,
    ) async throws -> ExportResult {
        // This would create a ZIP file with all assets
        // For now, return the standard form
        try await exportStandardForm(items: items, rooms: rooms, options: options)
    }

    private func exportClaimsReadyPackage(
        items: [Item],
        categories _: [Category],
        rooms: [Room],
        options: ExportOptions,
    ) async throws -> ExportResult {
        // This creates a comprehensive package for insurance claims
        // For now, use the standard form
        try await exportStandardForm(items: items, rooms: rooms, options: options)
    }
}

// MARK: - Data Models

/// Configuration options for insurance export formats
public struct ExportOptions {
    /// Name of the policy holder
    public var policyHolderName: String?
    /// Insurance policy number
    public var policyNumber: String?
    /// Address of the insured property
    public var propertyAddress: String?
    /// Whether to include item photos in export
    public var includePhotos = true
    /// Whether to include receipt documentation
    public var includeReceipts = true
    /// Whether to include warranty information
    public var includeWarrantyInfo = true
    /// Whether to group items by room in the export
    public var groupByRoom = true
    /// Whether to calculate and include depreciated values
    public var includeDepreciation = false
    /// Annual depreciation rate (default 10%)
    public var depreciationRate = 0.1 // 10% per year default

    /// Initialize with default export options
    public init() {}
}

/// Result of an insurance export operation
public struct ExportResult {
    /// URL of the generated export file
    public let fileURL: URL
    /// Export format used
    public let format: InsuranceExportService.ExportFormat
    /// Number of items included in the export
    public let itemCount: Int
    /// Total value of all exported items
    public let totalValue: Decimal
    /// Size of the generated file in bytes
    public let fileSize: Int

    /// Human-readable file size string
    public var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(fileSize))
    }
}

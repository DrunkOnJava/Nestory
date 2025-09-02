//
// Layer: Services
// Module: Insurance
// Purpose: Generate comprehensive insurance claim reports - Main coordinator
//
// REMINDER: This service is WIRED UP in SettingsView via "Generate Insurance Report" button
// Always ensure new services are accessible from the UI!

import Foundation
import PDFKit
import SwiftData

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with AppleArchive - Compress insurance claim packages for efficient transfer
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with MessageUI - Email insurance reports directly with PDF attachments
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with FileProvider - Cloud storage integration for insurance document backup
import SwiftUI

// MARK: - InsuranceReportService Protocol

public protocol InsuranceReportService: Sendable {
    func generateInsuranceReport(
        items: [Item],
        categories: [Category],
        options: ReportOptions
    ) async throws -> Data
    
    func exportReport(
        _ data: Data,
        filename: String
    ) async throws -> URL
    
    func shareReport(_ url: URL) async
}

// MARK: - Live Implementation

@MainActor
public final class LiveInsuranceReportService: InsuranceReportService, ObservableObject {
    // MARK: - Types

    public enum ReportError: Error, LocalizedError, Sendable {
        case noItems
        case pdfGenerationFailed
        case dataAccessError

        public var errorDescription: String? {
            switch self {
            case .noItems:
                "No items to include in report"
            case .pdfGenerationFailed:
                "Failed to generate PDF report"
            case .dataAccessError:
                "Could not access inventory data"
            }
        }
    }

    // Note: ReportOptions and ReportMetadata are now defined in Foundation/Models/

    // MARK: - Properties

    private let pdfGenerator: PDFReportGenerator
    private let exportManager: ReportExportManager
    private let dataFormatter: ReportDataFormatter

    // MARK: - Initialization

    public init() {
        pdfGenerator = PDFReportGenerator()
        exportManager = ReportExportManager()
        dataFormatter = ReportDataFormatter()
    }

    // MARK: - Report Generation

    public func generateInsuranceReport(
        items: [Item],
        categories: [Category],
        options: ReportOptions
    ) async throws -> Data {
        guard !items.isEmpty else {
            throw ReportError.noItems
        }

        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                do {
                    let totalValue = dataFormatter.calculateTotalValue(items: items)
                    let metadata = ReportMetadata(
                        totalItems: items.count,
                        totalValue: totalValue
                    )

                    let pdfData = try pdfGenerator.generatePDF(
                        items: items,
                        categories: categories,
                        options: options,
                        metadata: metadata,
                    )

                    continuation.resume(returning: pdfData)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Export Functions

    public func exportReport(
        _ data: Data,
        filename: String = "HomeInventory_Insurance_Report",
    ) async throws -> URL {
        try exportManager.exportReport(data, filename: filename)
    }

    public func shareReport(_ url: URL) async {
        exportManager.shareReport(url)
    }

    public func saveToDocuments(_ data: Data, filename: String) async throws -> URL {
        try exportManager.saveToDocuments(data, filename: filename)
    }

    // MARK: - Utility Functions

    public func cleanupOldReports(
        daysToKeep: Int = BusinessConstants.Insurance.reportRetentionDays,
    ) {
        exportManager.cleanupOldReports(daysToKeep: daysToKeep)
    }

    public func calculateTotalValue(items: [Item]) -> Decimal {
        dataFormatter.calculateTotalValue(items: items)
    }
}

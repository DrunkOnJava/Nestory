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
import SwiftUI

@MainActor
public final class InsuranceReportService: ObservableObject {
    // MARK: - Types

    public enum ReportError: LocalizedError {
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

    public struct ReportOptions {
        public var includePhotos: Bool = true
        public var includeReceipts: Bool = true
        public var includeDepreciation: Bool = false
        public var groupByRoom: Bool = true
        public var includeSerialNumbers: Bool = true
        public var includePurchaseInfo: Bool = true
        public var includeTotalValue: Bool = true

        public init() {}
    }

    public struct ReportMetadata {
        public let generatedDate: Date
        public let totalItems: Int
        public let totalValue: Decimal
        public let reportId: UUID
        public let propertyAddress: String?
        public let policyNumber: String?

        public init(
            totalItems: Int,
            totalValue: Decimal,
            propertyAddress: String? = nil,
            policyNumber: String? = nil
        ) {
            generatedDate = Date()
            self.totalItems = totalItems
            self.totalValue = totalValue
            reportId = UUID()
            self.propertyAddress = propertyAddress
            self.policyNumber = policyNumber
        }
    }

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
        options: ReportOptions = ReportOptions(),
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
                        totalValue: totalValue,
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

    public func cleanupOldReports(daysToKeep: Int = 30) {
        exportManager.cleanupOldReports(daysToKeep: daysToKeep)
    }

    public func calculateTotalValue(items: [Item]) -> Decimal {
        dataFormatter.calculateTotalValue(items: items)
    }
}

//
// Layer: Services
// Module: InsuranceClaim/ClaimDocumentGenerator
// Purpose: Core coordination for claim document generation across multiple formats
//

import Foundation
import PDFKit
import UIKit

@MainActor
public struct ClaimDocumentCore {
    public enum GenerationError: LocalizedError {
        case invalidTemplate
        case photoProcessingFailed
        case documentCreationFailed
        case unsupportedFormat

        public var errorDescription: String? {
            switch self {
            case .invalidTemplate:
                "Invalid or corrupted template"
            case .photoProcessingFailed:
                "Failed to process item photos"
            case .documentCreationFailed:
                "Could not create claim document"
            case .unsupportedFormat:
                "Unsupported document format"
            }
        }
    }

    private let pdfGenerator: ClaimPDFGenerator
    private let jsonGenerator: ClaimJSONGenerator
    private let htmlGenerator: ClaimHTMLGenerator
    private let spreadsheetGenerator: ClaimSpreadsheetGenerator

    public init() {
        self.pdfGenerator = ClaimPDFGenerator()
        self.jsonGenerator = ClaimJSONGenerator()
        self.htmlGenerator = ClaimHTMLGenerator()
        self.spreadsheetGenerator = ClaimSpreadsheetGenerator()
    }

    // MARK: - Main Generation Method

    public func generateDocument(
        request: ClaimRequest,
        template: ClaimTemplate
    ) async throws -> Data {
        switch request.format {
        case .standardPDF, .detailedPDF:
            try await pdfGenerator.generatePDF(request: request, template: template)
        case .structuredJSON:
            try jsonGenerator.generateJSON(request: request, template: template)
        case .htmlPackage:
            try htmlGenerator.generateHTML(request: request, template: template)
        case .spreadsheet:
            try spreadsheetGenerator.generateSpreadsheet(request: request, template: template)
        }
    }

    // MARK: - Public Helper Access

    public func formatDate(_ date: Date?) -> String {
        ClaimDocumentHelpers.formatDate(date)
    }

    public func formatCurrency(_ amount: Decimal?) -> String {
        ClaimDocumentHelpers.formatCurrency(amount)
    }

    public func calculateTotalValue(for items: [Item]) -> Decimal {
        ClaimDocumentHelpers.calculateTotalValue(for: items)
    }
}
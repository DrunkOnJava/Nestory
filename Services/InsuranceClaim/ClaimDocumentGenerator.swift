//
// Layer: Services
// Module: InsuranceClaim
// Purpose: Facade for claim document generation using modular components
//

import Foundation
import PDFKit
import UIKit

// Modular components are automatically available within the same target
// ClaimDocumentCore, ClaimPDFGenerator, ClaimJSONGenerator, ClaimHTMLGenerator, 
// ClaimSpreadsheetGenerator, and ClaimDocumentHelpers are included in the project

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with PDFKit - Advanced form field population and annotations
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with CoreGraphics - Enhanced PDF rendering and layout

@MainActor
public struct ClaimDocumentGenerator {
    // Re-export core error types
    public typealias GenerationError = ClaimDocumentCore.GenerationError

    private let core: ClaimDocumentCore

    public init() {
        self.core = ClaimDocumentCore()
    }

    // MARK: - Main Generation Method (Delegated)

    public func generateDocument(
        request: ClaimRequest,
        template: ClaimTemplate
    ) async throws -> Data {
        try await core.generateDocument(request: request, template: template)
    }

    // MARK: - Helper Methods (Delegated)

    public func formatDate(_ date: Date?) -> String {
        core.formatDate(date)
    }

    public func formatCurrency(_ amount: Decimal?) -> String {
        core.formatCurrency(amount)
    }

    public func calculateTotalValue(for items: [Item]) -> Decimal {
        core.calculateTotalValue(for: items)
    }

    // MARK: - Validation (Static Access)

    public static func validateClaimRequest(_ request: ClaimRequest) -> [String] {
        ClaimDocumentHelpers.validateClaimRequest(request)
    }

    public static func getItemStatistics(_ items: [Item]) -> ItemStatistics {
        ClaimDocumentHelpers.getItemStatistics(items)
    }
}
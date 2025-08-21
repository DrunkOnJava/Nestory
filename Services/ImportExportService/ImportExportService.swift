//
// Layer: Services
// Module: ImportExportService
// Purpose: Protocol-first import/export service for bulk data operations
//

import Foundation
import SwiftData

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with UniformTypeIdentifiers - Use UTType for robust file type detection and handling instead of custom file extension logic

/// Protocol defining import/export capabilities for inventory data
@MainActor
public protocol ImportExportService: AnyObject, Sendable {
    // MARK: - CSV Operations

    func importCSV(from url: URL, modelContext: ModelContext) async throws -> ImportResult
    func exportToCSV(items: [Item]) -> Data?

    // MARK: - JSON Operations

    func importJSON(from url: URL, modelContext: ModelContext) async throws -> ImportResult
    func exportToJSON(items: [Item]) -> Data?
}
